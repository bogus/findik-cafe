/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.business;

import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.Tariff;
import com.medratech.utils.service.BaseService;
import java.util.List;

/**
 *
 * @author Administrator
 */
public interface CafeItemService extends BaseService<CafeItem> {
    public List<CafeItem> getData(int type);
    public List<CafeItem> getData(Tariff tariff);
    public long getVersion(long id);
    public CafeItem refresh(long id);
}
