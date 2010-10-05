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
@Transactional @Service("sessionDataService")
@RemotingDestination
public class SessionDataServiceImpl implements SessionDataService
{
    @Autowired
    protected SessionDataDao itemDao;

    @Autowired
    protected CafeItemDao cItemDao;

    public List<SessionData> getData() {
        //return itemDao.findAll();
        return new ArrayList<SessionData>();
    }

    public List<SessionData> getData(long id) {
        return itemDao.findByQuery("select s from SessionData s where cafeItemId="+new Long(id).toString());
    }

    public List<SessionData> getData(long date, boolean isDate) {
        return itemDao.findByQuery("select s from SessionData s where s.eventStartTime > "
                + new Long(date).toString() + " and s.eventEndTime < " + new Long(date + (24*60*60*1000)).toString()
                + " and s.eventEndTime <> 0");
    }

    public SessionData insertData(SessionData data) {
        return data;
    }

    public SessionData deleteData(SessionData data) {
        return data;
    }

    public SessionData updateData(SessionData data) {
        return data;
    }

}
