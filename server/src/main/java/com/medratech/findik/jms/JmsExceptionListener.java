/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.jms;

/**
 *
 * @author Administrator
 */
import javax.jms.ExceptionListener;
import javax.jms.JMSException;

import org.springframework.stereotype.Component;

@Component
public class JmsExceptionListener implements ExceptionListener
{
    public void onException( final JMSException e )
    {
        e.printStackTrace();
    }
}
