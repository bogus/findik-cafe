/*
 * @Id: $Id$
 */
package com.medratech.utils.dao;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * @author Alexander Snaps <asnaps@axen.be>
 * @version $Revision$
 * @param <E> Type of the entity
 * @param <ID> Type of the identifier of the entity.
 */
public interface BaseDao<T, PK extends Serializable>
{
        public List<T> findAll();

        public List<T> findByQuery(String query, Map<String, Object> args);

        public List<T> findByQuery(String query, Object[] args);

        public List<T> findByNamedQuery(String queryName, Map<String, Object> args);

        public List<T> findByNamedQuery(String queryName, Object[] args);

        public List<T> findByQuery(String query);

        public List<T> findByNamedQuery(String queryName);

        public T findById(PK id);

        public T persist(T entity);

        public void flush();

        public void clear();

        public void remove(T entity);
        
        public void update(T entity);

}

