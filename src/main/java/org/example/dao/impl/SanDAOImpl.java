package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.example.dao.SanDAO;
import org.example.model.San;
import org.example.util.JPAUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.List;

public class SanDAOImpl implements SanDAO {

    private static final Logger logger = LogManager.getLogger(SanDAOImpl.class);

    @Override
    public List<San> getAllSan() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT s FROM San s WHERE s.isDeleted = false", San.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public San getSanById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(San.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public long countSanByTrangThai(String trangThai) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(s) FROM San s WHERE s.trangThai = :trangThai AND s.isDeleted = false", Long.class)
                    .setParameter("trangThai", trangThai)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public long getTotalSan() {
        return 0;
    }

    @Override
    public List<San> getSansByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT s FROM San s WHERE s.coSoID = :coSoId AND s.isDeleted = false", San.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countSansByLoaiSanId(int loaiSanId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(s) FROM San s WHERE s.loaiSanID = :loaiSanId AND s.isDeleted = false", Long.class)
                    .setParameter("loaiSanId", loaiSanId)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public void insert(San san) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(san);
            trans.commit();
        } catch (Exception e) {
            logger.error("Lỗi thêm San: {}", e.getMessage(), e);
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public void update(San existing) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(existing);
            trans.commit();
        } catch (Exception e) {
            logger.error("Lỗi cập nhật San ID {}: {}", existing.getSanID(), e.getMessage(), e);
            if (trans.isActive()) {
                trans.rollback();
            }
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean softDelete(int id, int actorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            San s = em.find(San.class, id);
            if (s == null || s.isDeleted()) { trans.rollback(); return false; }
            s.setDeleted(true);
            s.setDeletedAt(java.time.LocalDateTime.now());
            s.setDeletedBy(actorId);
            em.merge(s);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi soft delete San ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean restore(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            San s = em.find(San.class, id);
            if (s == null || !s.isDeleted()) { trans.rollback(); return false; }
            s.setDeleted(false);
            s.setDeletedAt(null);
            s.setDeletedBy(null);
            em.merge(s);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi restore San ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<San> findDeletedByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT s FROM San s WHERE s.coSoID = :coSoId AND s.isDeleted = true", San.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<San> findDeletedOlderThan(int days) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT s FROM San s WHERE s.isDeleted = true AND s.deletedAt < :cutoff", San.class)
                    .setParameter("cutoff", java.time.LocalDateTime.now().minusDays(days))
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
