/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.dao.jpa;

import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.utils.dao.BaseDaoImpl;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Administrator
 */
@Repository("cafeItemDaoImpl")
public class CafeItemDaoImpl extends BaseDaoImpl<CafeItem, Long> implements CafeItemDao{}
