package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.example.dao.HoaDonDAO;
import org.example.model.HoaDon;
import org.example.model.Hoantien;
import org.example.model.ChiTietHoaDon;
import org.example.util.JPAUtil;

import java.math.BigDecimal;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class HoaDonDAOImpl implements HoaDonDAO {

    private static final Logger logger = LogManager.getLogger(HoaDonDAOImpl.class);

    @Override
    public BigDecimal getTotalDoanhThu() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Double sum = em.createQuery("SELECT SUM(h.tongThanhToan) FROM HoaDon h WHERE h.trangThaiThanhToan = 'Đã thanh toán'", Double.class)
                    .getSingleResult();
            return sum != null ? BigDecimal.valueOf(sum) : BigDecimal.ZERO;
        } catch (Exception e) {
            logger.error("Lỗi khi lấy tổng doanh thu", e);
            return BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }

    @Override
    public BigDecimal getRevenueToday() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Double sum = em.createQuery("SELECT SUM(h.tongThanhToan) FROM HoaDon h WHERE CAST(h.ngayLap AS date) = CURRENT_DATE AND h.trangThaiThanhToan = 'Đã thanh toán'", Double.class)
                    .getSingleResult();
            return sum != null ? BigDecimal.valueOf(sum) : BigDecimal.ZERO;
        } catch (Exception e) {
            logger.error("Lỗi khi lấy doanh thu hôm nay", e);
            return BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }

    @Override
    public long countOrdersToday() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(h) FROM HoaDon h WHERE CAST(h.ngayLap AS date) = CURRENT_DATE AND h.trangThaiThanhToan = 'Đã thanh toán'", Long.class)
                    .getSingleResult();
            return count != null ? count : 0;
        } catch (Exception e) {
            logger.error("Lỗi khi đếm đơn hàng hôm nay", e);
            return 0;
        } finally {
            em.close();
        }
    }

    @Override
    public List<HoaDon> getRecentInvoices(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT h FROM HoaDon h ORDER BY h.ngayLap DESC", HoaDon.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<HoaDon> getAllHoaDon() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT h FROM HoaDon h ORDER BY h.ngayLap DESC", HoaDon.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public HoaDon getHoaDonById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(HoaDon.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean updateHoaDon(HoaDon hd) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(hd);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật hóa đơn ID {}: {}", hd.getHoaDonId(), e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<Hoantien> getAllHoanTien() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT r FROM Hoantien r ORDER BY r.thoiGianYeuCau DESC", Hoantien.class).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public Hoantien getHoanTienById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(Hoantien.class, id);
        } finally {
            em.close();
        }
    }

    @Override
    public boolean updateHoanTien(Hoantien ht) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(ht);
            trans.commit();
            return true;
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật hoàn tiền ID {}: {}", ht.getHoanTienId(), e.getMessage(), e);
            if (trans.isActive()) trans.rollback();
            return false;
        } finally {
            em.close();
        }
    }

    @Override
    public List<ChiTietHoaDon> getChiTietByHoaDonId(int hoaDonId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM ChiTietHoaDon c WHERE c.HoaDonID = :hoaDonId", ChiTietHoaDon.class)
                    .setParameter("hoaDonId", hoaDonId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public BigDecimal getRevenueTodayByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Double sum = em.createQuery("SELECT SUM(h.tongThanhToan) FROM HoaDon h JOIN h.datSan d JOIN d.san s WHERE s.coSoID = :coSoId AND CAST(h.ngayLap AS date) = CURRENT_DATE AND h.trangThaiThanhToan = 'Đã thanh toán'", Double.class)
                    .setParameter("coSoId", coSoId)
                    .getSingleResult();
            return sum != null ? BigDecimal.valueOf(sum) : BigDecimal.ZERO;
        } catch (Exception e) {
            logger.error("Lỗi khi lấy doanh thu hôm nay theo cơ sở " + coSoId, e);
            return BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }

    @Override
    public long countOrdersTodayByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(h) FROM HoaDon h JOIN h.datSan d JOIN d.san s WHERE s.coSoID = :coSoId AND CAST(h.ngayLap AS date) = CURRENT_DATE AND h.trangThaiThanhToan = 'Đã thanh toán'", Long.class)
                    .setParameter("coSoId", coSoId)
                    .getSingleResult();
            return count != null ? count : 0;
        } catch (Exception e) {
            logger.error("Lỗi khi đếm đơn hàng hôm nay theo cơ sở " + coSoId, e);
            return 0;
        } finally {
            em.close();
        }
    }

    @Override
    public List<HoaDon> getRecentInvoicesByCoSo(int coSoId, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT h FROM HoaDon h JOIN FETCH h.datSan d JOIN FETCH d.san s WHERE s.coSoID = :coSoId ORDER BY h.ngayLap DESC", HoaDon.class)
                    .setParameter("coSoId", coSoId)
                    .setMaxResults(limit)
                    .getResultList();
        } catch (Exception e) {
            logger.error("Lỗi khi lấy hóa đơn gần đây theo cơ sở " + coSoId, e);
            return List.of();
        } finally {
            em.close();
        }
    }

    @Override
    public BigDecimal getTotalDoanhThuByCoSo(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Double sum = em.createQuery("SELECT SUM(h.tongThanhToan) FROM HoaDon h JOIN h.datSan d JOIN d.san s WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán'", Double.class)
                    .setParameter("coSoId", coSoId)
                    .getSingleResult();
            return sum != null ? BigDecimal.valueOf(sum) : BigDecimal.ZERO;
        } catch (Exception e) {
            logger.error("Lỗi khi lấy tổng doanh thu theo cơ sở " + coSoId, e);
            return BigDecimal.ZERO;
        } finally {
            em.close();
        }
    }
}