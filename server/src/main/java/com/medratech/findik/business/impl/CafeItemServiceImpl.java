/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.business.impl;

import com.medratech.findik.business.*;
import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.dao.SessionDataDao;
import com.medratech.findik.dao.TariffDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.SessionData;
import com.medratech.findik.domain.Tariff;
import com.medratech.findik.jms.QueueSender;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.flex.remoting.RemotingDestination;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Administrator
 */
@Transactional @Service("cafeItemService")
@RemotingDestination
public class CafeItemServiceImpl implements CafeItemService
{
    @Autowired
    protected CafeItemDao itemDao;

    @Autowired
    protected TariffDao tItemDao;

    @Autowired
    protected SessionDataDao sItemDao;

    @Autowired
    private QueueSender queueSender;

    private static String queueName = "Queue.Client";

    public List<CafeItem> getData() {
        //return itemDao.findAll();
        return new ArrayList<CafeItem>();
    }

    public List<CafeItem> getData(int type) {
        return itemDao.findByQuery("select c from CafeItem c where type="+Integer.toString(type));
    }

    public List<CafeItem> getData(Tariff tariff) {
        return itemDao.findByQuery("select c from CafeItem c where tariff="+Long.toString(tariff.getId()));
    }

    public long getVersion(long id) {
        CafeItem cafeItem = itemDao.findById(id);
        return cafeItem.getVersion();
    }

    public CafeItem insertData(CafeItem data) {
        if(data.getType() < 2) {
            CafeItem cafeItem = new CafeItem();
            cafeItem.setName(data.getName());
            cafeItem.setType(data.getType());
            itemDao.persist(cafeItem);
            return cafeItem;
        }
        return data;
    }

    public CafeItem removeData(CafeItem data) {
        CafeItem cafeItem = itemDao.findById(data.getId());
        itemDao.remove(cafeItem);
        return data;
    }

    public CafeItem updateData(CafeItem data) {
        
        CafeItem cafeItem = itemDao.findById(data.getId());
        Tariff tariff = tItemDao.findById(data.getTariff().getId());
        if(tariff.getId() != data.getTariff().getId())
            cafeItem.setTariff(tariff);
        if(cafeItem.getStatus() != data.getStatus()) {
            cafeItem.setStatus(data.getStatus());
            if(cafeItem.getType() == 2)
            {
                if(cafeItem.getStatus() == 0)
                    queueSender.send(queueName, "session:close:"+cafeItem.getGeneratedId());
                else if(cafeItem.getStatus() == 1)
                    queueSender.send(queueName, "session:open:"+cafeItem.getGeneratedId());
            }
            if(cafeItem.getStatus() == 0)
            {
                SessionData sessionData = new SessionData();
                sessionData.setEventEndTime(System.currentTimeMillis());
                sessionData.setEventStartTime(cafeItem.getStartTime());
                sessionData.setEventData(data.getBill().toString());

                try {
                    List<SessionData> sessionDataList = cafeItem.getSessionData();
                    if(sessionData == null)
                        sessionDataList = new ArrayList<SessionData>();
                    sessionDataList.add(sessionData);
                    cafeItem.setSessionData(sessionDataList);
                } catch (NullPointerException e) {
                }
            }
        }
        if(cafeItem.getStartTime() != data.getStartTime())
            cafeItem.setStartTime(data.getStartTime());
        if(cafeItem.getEndTime() != data.getEndTime()) {
            cafeItem.setEndTime(data.getEndTime());
            if(cafeItem.getType() == 2 && cafeItem.getEndTime() != 0)
            {                   
                queueSender.send(queueName, "session:changetime:"+cafeItem.getGeneratedId()+"@_@"+cafeItem.getEndTime().toString());
            }
        }
        if(cafeItem.getBill() != data.getBill())
            cafeItem.setBill(data.getBill());
        if(cafeItem.getHasOpenRequest() != data.getHasOpenRequest())
            cafeItem.setHasOpenRequest(data.getHasOpenRequest());
        itemDao.update(cafeItem);

        return cafeItem;
    }

    public CafeItem refresh(long id)
    {
        return itemDao.findById(id);
    }
}
