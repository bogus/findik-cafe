/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.medratech.findik.dao.jpa;

import com.medratech.findik.dao.CafeItemDao;
import com.medratech.findik.dao.OptionsDao;
import com.medratech.findik.domain.CafeItem;
import com.medratech.findik.domain.Options;
import com.medratech.utils.dao.BaseDaoImpl;
import org.springframework.stereotype.Repository;

/**
 *
 * @author Administrator
 */
@Repository
public class OptionsDaoImpl extends BaseDaoImpl<Options, Long> implements OptionsDao{}
