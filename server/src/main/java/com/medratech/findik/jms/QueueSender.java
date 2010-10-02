/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.jms;

/**
 *
 * @author Administrator
 */
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

@Component
public class QueueSender
{
    private final JmsTemplate jmsTemplate;

    @Autowired
    public QueueSender( final JmsTemplate jmsTemplate )
    {
        this.jmsTemplate = jmsTemplate;
    }

    public void send( final String queue, final String message )
    {
        jmsTemplate.convertAndSend( queue, message );
    }
}