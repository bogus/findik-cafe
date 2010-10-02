/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.business.impl;

import com.medratech.findik.business.*;
import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.dao.OptionsDao;
import com.medratech.findik.dao.SessionDataDao;
import com.medratech.findik.dao.TariffDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.Options;
import com.medratech.findik.domain.SessionData;
import com.medratech.findik.domain.Tariff;
import com.medratech.findik.jms.QueueSender;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.flex.remoting.RemotingDestination;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Administrator
 */
@Transactional @Service("optionsService")
@RemotingDestination
public class OptionsServiceImpl implements OptionsService
{
    @Autowired
    protected OptionsDao itemDao;

    public List<Options> getData() {
        try {
            if(itemDao.findAll().size() == 0)
            {
                Options options = new Options();
                itemDao.persist(options);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
            
        return itemDao.findAll();
    }

    public Options insertData(Options data) {
        return data;
    }

    public Options removeData(Options data) {
        return data;
    }

    public Options updateData(Options data) {
        Options options = itemDao.findById(data.getId());
        options.setBanner(data.getBanner());
        options.setOpenSessionAutomatically(data.getOpenSessionAutomatically());
        options.setRecoverPassword(data.getRecoverPassword());
        options.setScreenSaverImage(data.getScreenSaverImage());
        itemDao.update(options);
        return options;
    }

}
