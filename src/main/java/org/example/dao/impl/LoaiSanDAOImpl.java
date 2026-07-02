package org.example.dao.impl;

import org.example.dao.LoaiSanDAO;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.util.JPAUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import java.util.List;

/**
 * Implementation của LoaiSanDAO sử dụng JPA
 */
public class LoaiSanDAOImpl implements LoaiSanDAO {

    private static final Logger logger = LogManager.getLogger(LoaiSanDAOImpl.class);

    @Override
    public List<LoaiSan> getAllLoaiSan() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT l FROM LoaiSan l WHERE l.isDeleted = false", LoaiSan.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public LoaiSan getLoaiSanById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(LoaiSan.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public List<LoaiSan> getLoaiSansByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT l FROM LoaiSan l WHERE l.coSoID = :coSoId AND l.isDeleted = false", LoaiSan.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<MonTheThao> getAllMonTheThao() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT m FROM MonTheThao m", MonTheThao.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public boolean insert(LoaiSan loaiSan) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(loaiSan);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi thêm LoaiSan: {}", e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(LoaiSan loaiSan) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(loaiSan);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi cập nhật LoaiSan ID {}: {}", loaiSan.getLoaiSanID(), e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean hardDelete(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            LoaiSan ls = em.find(LoaiSan.class, id);
            if (ls != null) {
                em.remove(ls);
                trans.commit();
                return true;
            }
            trans.rollback();
            return false;
        } catch (Exception e) {
            logger.error("Lỗi xóa LoaiSan ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
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
            LoaiSan ls = em.find(LoaiSan.class, id);
            if (ls == null || ls.isDeleted()) { trans.rollback(); return false; }
            ls.setDeleted(true);
            ls.setDeletedAt(java.time.LocalDateTime.now());
            ls.setDeletedBy(actorId);
            em.merge(ls);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi soft delete LoaiSan ID {}: {}", id, e.getMessage(), e);
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
            LoaiSan ls = em.find(LoaiSan.class, id);
            if (ls == null || !ls.isDeleted()) { trans.rollback(); return false; }
            ls.setDeleted(false);
            ls.setDeletedAt(null);
            ls.setDeletedBy(null);
            em.merge(ls);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi restore LoaiSan ID {}: {}", id, e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<LoaiSan> findDeletedByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT l FROM LoaiSan l WHERE l.coSoID = :coSoId AND l.isDeleted = true", LoaiSan.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<LoaiSan> findDeletedOlderThan(int days) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT l FROM LoaiSan l WHERE l.isDeleted = true AND l.deletedAt < :cutoff", LoaiSan.class)
                    .setParameter("cutoff", java.time.LocalDateTime.now().minusDays(days))
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
