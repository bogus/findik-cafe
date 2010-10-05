/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.business.impl;

import com.medratech.findik.business.*;
import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.dao.PriceListDao;
import com.medratech.findik.dao.TariffDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.PriceList;
import com.medratech.findik.domain.Tariff;
import com.medratech.findik.jms.JMSMessageProcessor;
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
@Transactional @Service("tariffService")
@RemotingDestination
public class TariffServiceImpl implements TariffService
{
    @Autowired
    protected TariffDao itemDao;

    @Autowired
    protected CafeItemDao cItemDao;

    @Autowired
    protected PriceListDao pItemDao;

    @Autowired
    private JMSMessageProcessor jMSMessageProcessor;

    public List<Tariff> getData() {
        return itemDao.findAll();
    }

    public Tariff insertData(Tariff data) {
        Tariff tariff = new Tariff();
        tariff.setName(data.getName());
        List<PriceList> prices = new ArrayList<PriceList>();
        for(int i = 0 ; i < 7*24 ; i++)
        {
            PriceList price = new PriceList();
            price.setDay(data.getPrices().get(i).getDay());
            price.setHour(data.getPrices().get(i).getHour());
            price.setPrice(data.getPrices().get(i).getPrice());
            prices.add(price);
        }
        tariff.setPrices(prices);
        tariff.setMinBillTime(data.getMinBillTime());
        itemDao.persist(tariff);
        return tariff;
    }

    public Tariff deleteData(Tariff data) {
        Tariff tariff = itemDao.findById(data.getId());
        Tariff tariff2 = itemDao.findAll().get(0);
        try {
            Boolean isUpdated = false;
            List<CafeItem> cafeItems = cItemDao.findByQuery("select c from CafeItem "
                    + "c where tariff_id="+data.getId().toString());
            for(CafeItem cafeItem : cafeItems )
            {
                cafeItem.setTariff(tariff2);
                cItemDao.update(cafeItem);
                isUpdated = true;
            }
            if(isUpdated)
                jMSMessageProcessor.sendStompMessage("update:all");
        } catch (Exception e) {
            e.printStackTrace();
        }
        itemDao.remove(tariff);
        return tariff;
    }
    
    public Tariff updateData(Tariff data) {
        Tariff tariff = itemDao.findById(data.getId());
        for (PriceList priceList : data.getPrices()) {
            PriceList tmp = pItemDao.findById(priceList.getId());
            tmp.setPrice(priceList.getPrice());
            pItemDao.update(tmp);
        }
        tariff.setMinBillTime(data.getMinBillTime());
        return data;
    }

}
