/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.jms;

/**
 *
 * @author Administrator
 */
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.stereotype.Component;

@Component
public class QueueListener implements MessageListener
{
    @Autowired
    private JMSMessageProcessor jMSMessageProcessor;

    public void onMessage( final Message message )
    {
        if ( message instanceof TextMessage )
        {
            final TextMessage textMessage = (TextMessage) message;
            try
            {
                jMSMessageProcessor.routeMessages(textMessage.getText());
            }
            catch (final JMSException e)
            {
                e.printStackTrace();
            }
        }
    }
}

