/*
 * @Id: $Id$
 */
package com.medratech.utils.service;

import com.medratech.utils.dao.BaseDao;
import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * @author Alexander Snaps <asnaps@axen.be>
 * @version $Revision$
 * @param <E> Type of the entity
 * @param <ID> Type of the identifier of the entity.
 */
public interface BaseService<T>
{
        public List<T> getData();
        public T insertData(T data);
        public T updateData(T data);
        public T removeData(T data);
}

