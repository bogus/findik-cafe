/*
 * @Id: $Id$
 */
package com.medratech.utils.dao;

import org.springframework.transaction.annotation.Transactional;
import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceContextType;
import javax.persistence.Query;
import javax.persistence.TemporalType;

/**
 * @author Alexander Snaps <asnaps@axen.be>
 * @version $Revision$
 * @param <E> Type of the entity
 * @param <ID> Type of the identifier of the entity.
 */
@Transactional
public abstract class BaseDaoImpl<T, PK extends Serializable> implements BaseDao<T, PK> {

    @PersistenceContext(type=PersistenceContextType.EXTENDED)
    private EntityManager entityManager;
    protected Class<T> classType;

    @SuppressWarnings("unchecked")
    
    public BaseDaoImpl() {
        this.classType = (Class<T>) ((ParameterizedType) getClass().getGenericSuperclass()).getActualTypeArguments()[0];
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    public Class<T> getClassType() {
        return classType;
    }

    public List<T> findAll() {
        @SuppressWarnings("unchecked")
        List<T> results = getEntityManager().createQuery(
                "select o from " + getClassType().getSimpleName() + " o").getResultList();
        return results;
    }

    protected List<T> findByQuery(Query q, Map<String, Object> args) {
        if (args != null) {
            for (Map.Entry<String, Object> entry : args.entrySet()) {
                if (entry.getValue() instanceof Date) {
                    q.setParameter(entry.getKey(), (Date) entry.getValue(),
                            TemporalType.TIMESTAMP);
                } else if (entry.getValue() instanceof Calendar) {
                    q.setParameter(entry.getKey(), (Calendar) entry.getValue(),
                            TemporalType.TIMESTAMP);
                } else {
                    q.setParameter(entry.getKey(), entry.getValue());
                }
            }
        }
        @SuppressWarnings("unchecked")
        List<T> results = q.getResultList();
        return results;
    }

    protected List<T> findByQuery(Query q, Object[] args) {
        if (args != null) {
            int position = 1;
            for (Object value : args) {
                if (value instanceof Date) {
                    q.setParameter(position++, (Date) value,
                            TemporalType.TIMESTAMP);
                } else if (value instanceof Calendar) {
                    q.setParameter(position++, (Calendar) value,
                            TemporalType.TIMESTAMP);
                } else {
                    q.setParameter(position++, value);
                }
            }
        }
        @SuppressWarnings("unchecked")
        List<T> results = q.getResultList();
        return results;
    }

    @Override
    public List<T> findByNamedQuery(String queryName, Map<String, Object> args) {
        return findByQuery(getEntityManager().createNamedQuery(queryName), args);
    }

    @Override
    public List<T> findByNamedQuery(String queryName, Object[] args) {
        return findByQuery(getEntityManager().createNamedQuery(queryName), args);
    }

    @Override
    public List<T> findByNamedQuery(String queryName) {
        return findByQuery(getEntityManager().createNamedQuery(queryName), new Object[]{});
    }

    @Override
    public List<T> findByQuery(String query, Map<String, Object> args) {
        return findByQuery(getEntityManager().createQuery(query), args);
    }

    @Override
    public List<T> findByQuery(String query, Object[] args) {
        return findByQuery(getEntityManager().createQuery(query), args);
    }

    @Override
    public List<T> findByQuery(String query) {
        return findByQuery(getEntityManager().createQuery(query), new Object[]{});
    }

    public T findById(PK id) {
        return getEntityManager().find(getClassType(), id);
    }

    @Transactional
    public T persist(T entity) {
        getEntityManager().persist(entity);
        return entity;
    }

    public void flush() {
        getEntityManager().flush();
    }

    public void clear() {
        getEntityManager().clear();
    }

    public void remove(T entity) {
        getEntityManager().remove(entity);
    }

    public void update(T entity) {
        T merge = getEntityManager().merge(entity);
    }
}
