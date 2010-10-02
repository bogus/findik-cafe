/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.jms;

/**
 *
 * @author Administrator
 */
public interface JMSMessageProcessor {
    public void routeMessages(String text);
    public void sendStompMessage(String text);
}
