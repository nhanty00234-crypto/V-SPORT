package org.example.dao.impl;

import org.example.dao.SanPhamDichVuDAO;
import org.example.model.SanPham_DichVu;
import org.example.util.JPAUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.List;

public class SanPhamDichVuDAOImpl implements SanPhamDichVuDAO {

    private EntityManager getEntityManager() {
        return JPAUtil.getEntityManager();
    }

    @Override
    public List<SanPham_DichVu> findByCoSo(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT s FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId AND s.isDeleted = false ORDER BY s.TenSanPham ASC", SanPham_DichVu.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<SanPham_DichVu> findByCoSoAndCategory(int coSoId, int categoryId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery("SELECT s FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId AND s.DanhMucID = :categoryId AND s.isDeleted = false ORDER BY s.TenSanPham ASC", SanPham_DichVu.class)
                    .setParameter("coSoId", coSoId)
                    .setParameter("categoryId", categoryId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public SanPham_DichVu findById(int id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(SanPham_DichVu.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public SanPham_DichVu findBySkuAndCoSo(String sku, int coSoId) {
        EntityManager em = getEntityManager();
        try {
            List<SanPham_DichVu> list = em.createQuery("SELECT s FROM SanPham_DichVu s WHERE s.SkuCode = :sku AND s.CoSoID = :coSoId AND s.isDeleted = false", SanPham_DichVu.class)
                    .setParameter("sku", sku)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean insert(SanPham_DichVu sp) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(sp);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(SanPham_DichVu sp) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(sp);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean hardDelete(int id) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            SanPham_DichVu sp = em.find(SanPham_DichVu.class, id);
            if (sp != null) {
                em.createNativeQuery("UPDATE ChiTietHoaDon SET SanPhamID = NULL WHERE SanPhamID = ?").setParameter(1, id).executeUpdate();
                em.remove(sp);
                trans.commit();
                return true;
            }
            trans.rollback();
            return false;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean softDelete(int id, int actorId) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            SanPham_DichVu sp = em.find(SanPham_DichVu.class, id);
            if (sp == null || sp.isDeleted()) { trans.rollback(); return false; }
            sp.setDeleted(true);
            sp.setDeletedAt(java.time.LocalDateTime.now());
            sp.setDeletedBy(actorId);
            em.merge(sp);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean restore(int id) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            SanPham_DichVu sp = em.find(SanPham_DichVu.class, id);
            if (sp == null || !sp.isDeleted()) { trans.rollback(); return false; }
            sp.setDeleted(false);
            sp.setDeletedAt(null);
            sp.setDeletedBy(null);
            em.merge(sp);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<SanPham_DichVu> findDeletedByCoSo(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                    "SELECT s FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId AND s.isDeleted = true", SanPham_DichVu.class)
                    .setParameter("coSoId", coSoId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<SanPham_DichVu> findDeletedOlderThan(int days) {
        EntityManager em = getEntityManager();
        try {
            return em.createQuery(
                    "SELECT s FROM SanPham_DichVu s WHERE s.isDeleted = true AND s.deletedAt < :cutoff", SanPham_DichVu.class)
                    .setParameter("cutoff", java.time.LocalDateTime.now().minusDays(days))
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public boolean existsInInvoices(int sanPhamId) {
        EntityManager em = getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(c) FROM ChiTietHoaDon c WHERE c.SanPhamID = :sanPhamId", Long.class)
                    .setParameter("sanPhamId", sanPhamId)
                    .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }
}
