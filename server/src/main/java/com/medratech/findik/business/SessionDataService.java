/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.business;

import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.SessionData;
import com.medratech.findik.domain.Tariff;
import com.medratech.utils.service.BaseService;
import java.util.List;

/**
 *
 * @author Administrator
 */
public interface SessionDataService extends BaseService<SessionData> {
    public List<SessionData> getData(long type);
}
