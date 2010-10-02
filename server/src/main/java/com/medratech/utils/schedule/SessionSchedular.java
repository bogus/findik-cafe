/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.utils.schedule;

import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.jms.JMSMessageProcessor;
import com.medratech.findik.jms.QueueSender;
import java.util.List;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

/**
 *
 * @author Administrator
 */
@Service("sessionSchedule")
public class SessionSchedular extends QuartzJobBean {

    @Autowired
    private CafeItemDao itemDao;

    @Autowired
    private QueueSender queueSender;

    @Autowired
    private JMSMessageProcessor jMSMessageProcessor;

    private static String queueName = "Queue.Client";

    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        
        List<CafeItem> list = itemDao.findByQuery("select c from CafeItem c where endTime <> 0 and endTime < "+Long.toString(System.currentTimeMillis()));
        for (CafeItem cafeItem : list) {
            cafeItem.setStatus(0);
            itemDao.update(cafeItem);
            if(cafeItem.getType() == 2)
                queueSender.send(queueName, "session:close:"+cafeItem.getGeneratedId());
            jMSMessageProcessor.sendStompMessage("close:"+cafeItem.getId());
        }
    }
}
