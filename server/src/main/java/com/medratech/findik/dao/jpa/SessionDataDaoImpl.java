package com.medratech.findik.dao.jpa;

import com.medratech.findik.dao.SessionDataDao;
import java.util.List;

import com.medratech.findik.dao.TIBBlacklistDao;
import com.medratech.findik.domain.SessionData;
import com.medratech.findik.domain.TIBBlacklist;
import com.medratech.utils.dao.BaseDaoImpl;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository 
public class SessionDataDaoImpl extends BaseDaoImpl<SessionData, Long> implements
		SessionDataDao {


}
