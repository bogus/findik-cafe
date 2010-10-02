/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.jms;

import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.dao.SessionDataDao;
import com.medratech.findik.dao.TariffDao;
import com.medratech.findik.dao.jpa.CafeItemDaoImpl;
import com.medratech.findik.domain.CafeItem;
import java.io.IOException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.activemq.transport.stomp.StompConnection;
import org.apache.activemq.transport.stomp.StompFrame;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
/**
 *
 * @author Administrator
 */
@Transactional
@Service
public class JMSMessageProcessorImpl implements JMSMessageProcessor {

    @Autowired
    protected CafeItemDao itemDao;

    @Autowired
    protected TariffDao tItemDao;

    @Autowired
    protected SessionDataDao sItemDao;

    public void routeMessages(String text)
    {
        String[] arr = text.split(":");
        if(arr.length != 3)
            return;
        
        System.out.println(text);
        CafeItem cafeItem = new CafeItem();
        List<CafeItem> list = new ArrayList<CafeItem>();
        
        if(arr[0].equals("session"))
        {
            if(arr[1].equals("open"))
            {
                try {
                    list = itemDao.findByQuery("select c from CafeItem c where generatedId='"+arr[2]+"'");
                } catch (NullPointerException ex) {
                    System.err.println(ex.getMessage() + "\nselect c from CafeItem c where generatedId="+arr[2]);
                }
                try {
                    if(list.isEmpty()) {
                        return;
                    }
                    else {
                        cafeItem = list.get(0);
                        cafeItem.setHasOpenRequest(Boolean.TRUE);
                        itemDao.update(cafeItem);
                        sendStompMessage("open:"+cafeItem.getId());
                    }
                } catch (NullPointerException ex) {
                } catch (Exception ex) {
                }
            }
            else if(arr[1].equals("close"))
            {                
                try {
                    list = itemDao.findByQuery("select c from CafeItem c where generatedId='"+arr[2]+"'");
                } catch (NullPointerException ex) {
                    System.err.println(ex.getMessage() + "\nselect c from CafeItem c where generatedId="+arr[2]);
                }
                try {
                    if(list.isEmpty()) {
                        return;
                    }
                    else {
                        cafeItem = list.get(0);
                        cafeItem.setStatus(0);
                        itemDao.update(cafeItem);
                        sendStompMessage("close:"+cafeItem.getId());
                    }
                } catch (NullPointerException ex) {
                } catch (Exception ex) {
                }
            }
            else if(arr[1].equals("changetime"))
            {
                String[] data = arr[2].split("@_@");
                try {
                    list = itemDao.findByQuery("select c from CafeItem c where generatedId='"+data[0]+"'");
                } catch (NullPointerException ex) {
                    System.err.println(ex.getMessage() + "\nselect c from CafeItem c where generatedId="+data[0]);
                }

                 try {
                    if(list.isEmpty()) {
                        return;
                    }
                    else {
                        cafeItem = list.get(0);
                        cafeItem.setEndTime(System.currentTimeMillis() + new Long(data[1])*60*1000);
                        itemDao.update(cafeItem);
                        sendStompMessage("changetime:"+cafeItem.getId()+":"+cafeItem.getEndTime().toString());
                    }
                } catch (NullPointerException ex) {
                } catch (Exception ex) {
                }

            }
            else if(arr[1].equals("register"))
            {
                Boolean isUpdated = false;
                String[] data = arr[2].split("@_@");
                try {
                    list = itemDao.findByQuery("select c from CafeItem c where generatedId='"+data[0]+"'");
                } catch (NullPointerException ex) {
                    System.err.println(ex.getMessage() + "\nselect c from CafeItem c where generatedId="+data[0]);
                }
                try {
                    if(list.isEmpty()) {
                        cafeItem.setType(2);
                        cafeItem.setName(data[2]);
                        cafeItem.setHostname(data[2]);
                        cafeItem.setGeneratedId(data[0]);
                        cafeItem.setIP(data[1]);
                        itemDao.persist(cafeItem);
                        isUpdated = true;
                    }
                    else {
                        cafeItem = list.get(0);
                        if(!cafeItem.getName().equals(data[2])) {
                            cafeItem.setName(data[2]);
                            cafeItem.setHostname(data[2]);
                            isUpdated = true;
                        }
                        if(!cafeItem.getIP().equals(data[1])) {
                            cafeItem.setIP(data[1]);
                            isUpdated = true;
                        }
                        if(isUpdated) {
                            itemDao.update(cafeItem);
                            sendStompMessage("update");
                        }
                    }
                } catch (NullPointerException ex) {
                } catch (Exception ex) {
                }
            }
        }
        else if(arr[0].equals("util"))
        {
            
        }

    }

    public void sendStompMessage(String text)
    {
        StompConnection connection = new StompConnection();
        try {
            connection.open("localhost", 61613);
            connection.connect(null, null);
            connection.begin("tx1");
            connection.send("/topic/FINDIK.NOTIFICATIONS", text, "tx1", null);
            connection.commit("tx1");
            connection.disconnect();
        } catch (UnknownHostException ex) {
        } catch (IOException ex) {
        } catch (Exception ex) {
        }
    }

}
