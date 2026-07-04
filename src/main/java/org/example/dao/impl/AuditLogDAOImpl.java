package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import org.example.dao.AuditLogDAO;
import org.example.model.AuditLog;
import org.example.util.JPAUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

public class AuditLogDAOImpl implements AuditLogDAO {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogDAOImpl.class);

    @Override
    public void save(AuditLog log) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(log);
            tx.commit();
        } catch (Exception e) {
            logger.error("Lỗi lưu AuditLog: {}", e.getMessage(), e);
            if (tx.isActive()) tx.rollback();
        } finally {
            em.close();
        }
    }

    @Override
    public List<AuditLog> findAll(int page, int pageSize) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM AuditLog a ORDER BY a.createdAt DESC", AuditLog.class)
                    .setFirstResult((page - 1) * pageSize)
                    .setMaxResults(pageSize)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<AuditLog> findByCoSo(int coSoId, int page, int pageSize) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM AuditLog a WHERE a.coSoId = :coSoId ORDER BY a.createdAt DESC", AuditLog.class)
                    .setParameter("coSoId", coSoId)
                    .setFirstResult((page - 1) * pageSize)
                    .setMaxResults(pageSize)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(a) FROM AuditLog a", Long.class).getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(a) FROM AuditLog a WHERE a.coSoId = :coSoId", Long.class)
                    .setParameter("coSoId", coSoId).getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public List<AuditLog> findWithFilters(Integer coSoId, String entityType, String action,
                                           String dateFrom, String dateTo, int page, int pageSize) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT a FROM AuditLog a WHERE 1=1");
            if (coSoId != null) jpql.append(" AND a.coSoId = :coSoId");
            if (entityType != null && !entityType.isEmpty()) jpql.append(" AND a.entityType = :entityType");
            if (action != null && !action.isEmpty()) jpql.append(" AND a.action = :action");
            if (dateFrom != null && !dateFrom.isEmpty()) jpql.append(" AND a.createdAt >= :dateFrom");
            if (dateTo != null && !dateTo.isEmpty()) jpql.append(" AND a.createdAt <= :dateTo");
            jpql.append(" ORDER BY a.createdAt DESC");

            TypedQuery<AuditLog> q = em.createQuery(jpql.toString(), AuditLog.class);
            setFilterParams(q, coSoId, entityType, action, dateFrom, dateTo);
            return q.setFirstResult((page - 1) * pageSize).setMaxResults(pageSize).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countWithFilters(Integer coSoId, String entityType, String action,
                                  String dateFrom, String dateTo) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT COUNT(a) FROM AuditLog a WHERE 1=1");
            if (coSoId != null) jpql.append(" AND a.coSoId = :coSoId");
            if (entityType != null && !entityType.isEmpty()) jpql.append(" AND a.entityType = :entityType");
            if (action != null && !action.isEmpty()) jpql.append(" AND a.action = :action");
            if (dateFrom != null && !dateFrom.isEmpty()) jpql.append(" AND a.createdAt >= :dateFrom");
            if (dateTo != null && !dateTo.isEmpty()) jpql.append(" AND a.createdAt <= :dateTo");

            TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class);
            setFilterParams(q, coSoId, entityType, action, dateFrom, dateTo);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    private void setFilterParams(TypedQuery<?> q, Integer coSoId, String entityType,
                                  String action, String dateFrom, String dateTo) {
        if (coSoId != null) q.setParameter("coSoId", coSoId);
        if (entityType != null && !entityType.isEmpty()) q.setParameter("entityType", entityType);
        if (action != null && !action.isEmpty()) q.setParameter("action", action);
        if (dateFrom != null && !dateFrom.isEmpty())
            q.setParameter("dateFrom", java.time.LocalDateTime.parse(dateFrom + "T00:00:00"));
        if (dateTo != null && !dateTo.isEmpty())
            q.setParameter("dateTo", java.time.LocalDateTime.parse(dateTo + "T23:59:59"));
    }
}
