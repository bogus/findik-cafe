package com.medratech.findik.dao.jpa;

import java.util.List;

import com.medratech.findik.dao.TIBBlacklistDao;
import com.medratech.findik.dao.TariffDao;
import com.medratech.findik.domain.TIBBlacklist;
import com.medratech.findik.domain.Tariff;
import com.medratech.utils.dao.BaseDaoImpl;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Repository
public class TariffDaoImpl extends BaseDaoImpl<Tariff, Long> implements
		TariffDao {


}
