package org.example.dao.impl;

import org.example.dao.YeuCauNghiDAO;
import org.example.model.YeuCauNghi;
import org.example.util.DBUtil;
import org.example.util.JPAUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Implementation của YeuCauNghiDAO sử dụng JPA/Hibernate
 */
public class YeuCauNghiDAOImpl implements YeuCauNghiDAO {

    private static final Logger logger = LogManager.getLogger(YeuCauNghiDAOImpl.class);

    private EntityManager getEntityManager() {
        return JPAUtil.getEntityManager();
    }

    @Override
    public int insert(YeuCauNghi yeuCauNghi) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(yeuCauNghi);
            trans.commit();
            return 1;
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            e.printStackTrace();
            return 0;
        } finally {
            em.close();
        }
    }

    @Override
    public boolean update(YeuCauNghi yeuCauNghi) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(yeuCauNghi);
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
    public boolean hardDelete(int yeuCauNghiID) {
        EntityManager em = getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            YeuCauNghi ycn = em.find(YeuCauNghi.class, yeuCauNghiID);
            if (ycn != null) {
                em.remove(ycn);
                trans.commit();
                return true;
            }
            trans.commit();
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
    public boolean softDelete(int yeuCauNghiID, int actorId) {
        String sql = "UPDATE YeuCauNghi SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ? " +
                     "WHERE YeuCauNghiID = ? AND IsDeleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorId);
            ps.setInt(2, yeuCauNghiID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi soft delete yêu cầu nghỉ ID {}: {}", yeuCauNghiID, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean restore(int yeuCauNghiID) {
        String sql = "UPDATE YeuCauNghi SET IsDeleted = 0, DeletedAt = NULL, DeletedBy = NULL " +
                     "WHERE YeuCauNghiID = ? AND IsDeleted = 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, yeuCauNghiID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi restore yêu cầu nghỉ ID {}: {}", yeuCauNghiID, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<YeuCauNghi> findDeletedByCoSo(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT ycn.* FROM YeuCauNghi ycn " +
                         "JOIN Accounts a ON ycn.AccountID = a.AccountID " +
                         "WHERE a.CoSoID = ? AND ycn.IsDeleted = 1 " +
                         "ORDER BY ycn.DeletedAt DESC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, coSoId)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<Integer> findDeletedIdsOlderThan(int days) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT YeuCauNghiID FROM YeuCauNghi " +
                     "WHERE IsDeleted = 1 AND DeletedAt < DATEADD(day, -?, GETDATE())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("YeuCauNghiID"));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedIdsOlderThan yêu cầu nghỉ days {}: {}", days, e.getMessage(), e);
        }
        return ids;
    }

    @Override
    public YeuCauNghi findById(int yeuCauNghiID) {
        EntityManager em = getEntityManager();
        try {
            // Dùng native query để join với các bảng khác lấy thông tin chi tiết
            String sql = "SELECT ycn.*, " +
                         "tk.FullName AS TenNhanVien, " +
                         "cs.TenCoSo, " +
                         "r.RoleName, " +
                         "ql.FullName AS QuanLyXuLy " +
                         "FROM YeuCauNghi ycn " +
                         "LEFT JOIN dbo.Accounts tk ON ycn.AccountID = tk.AccountID " +
                         "LEFT JOIN dbo.Roles r ON tk.RoleID = r.RoleID " +
                         "LEFT JOIN dbo.CoSo cs ON ycn.CoSoID = cs.CoSoID " +
                         "LEFT JOIN dbo.Accounts ql ON ycn.XuLyBy = ql.AccountID " +
                         "WHERE ycn.YeuCauNghiID = ?";

            List<YeuCauNghi> result = em.createNativeQuery(sql, YeuCauNghi.class)
                .setParameter(1, yeuCauNghiID)
                .getResultList();

            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findAll() {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT ycn.*, " +
                         "tk.FullName AS TenNhanVien, " +
                         "cs.TenCoSo, " +
                         "r.RoleName, " +
                         "ql.FullName AS QuanLyXuLy " +
                         "FROM V_YeuCauNghi_ChiTiet ycn " +
                         "WHERE ycn.IsDeleted = 0 " +
                         "ORDER BY ycn.NgayNghi DESC";

            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findByAccountID(int accountID) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT * FROM V_YeuCauNghi_ChiTiet WHERE AccountID = ? AND IsDeleted = 0 ORDER BY NgayNghi DESC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, accountID)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findByCoSoIDAndTrangThai(int coSoID, String trangThai) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT * FROM V_YeuCauNghi_ChiTiet WHERE CoSoID = ? AND TrangThai = ? AND IsDeleted = 0 ORDER BY NgayGui DESC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, coSoID)
                     .setParameter(2, trangThai)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findByCoSoID(int coSoID) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT * FROM V_YeuCauNghi_ChiTiet WHERE CoSoID = ? AND IsDeleted = 0 ORDER BY NgayNghi DESC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, coSoID)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findByAccountIDAndTrangThai(int accountID, String trangThai) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT * FROM V_YeuCauNghi_ChiTiet WHERE AccountID = ? AND TrangThai = ? AND IsDeleted = 0 ORDER BY NgayNghi DESC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, accountID)
                     .setParameter(2, trangThai)
                     .getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public int countPendingByCoSoID(int coSoID) {
        EntityManager em = getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(y) FROM YeuCauNghi y WHERE y.CoSoID = :coSoID AND y.TrangThai = 'ChoDuyet' AND y.isDeleted = false",
                Long.class)
                .setParameter("coSoID", coSoID)
                .getSingleResult();
            return count.intValue();
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findByNgayNghiAndAccountID(LocalDate ngayNghi, int accountID) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<YeuCauNghi> query = em.createQuery(
                "SELECT y FROM YeuCauNghi y WHERE y.NgayNghi = :ngayNghi AND y.AccountID = :accountID AND y.isDeleted = false",
                YeuCauNghi.class);
            query.setParameter("ngayNghi", ngayNghi);
            query.setParameter("accountID", accountID);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public boolean existsByAccountIDAndNgayNghi(int accountID, LocalDate ngayNghi) {
        EntityManager em = getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(y) FROM YeuCauNghi y WHERE y.AccountID = :accountID AND y.NgayNghi = :ngayNghi AND y.TrangThai IN ('ChoDuyet', 'DaDuyet') AND y.isDeleted = false",
                Long.class)
                .setParameter("accountID", accountID)
                .setParameter("ngayNghi", ngayNghi)
                .getSingleResult();
            return count > 0;
        } finally {
            em.close();
        }
    }

    @Override
    public List<YeuCauNghi> findUpcomingByAccountID(int accountID) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT * FROM V_YeuCauNghi_ChiTiet " +
                         "WHERE AccountID = ? AND NgayNghi >= CAST(DATEADD(hour, 7, GETUTCDATE()) AS DATE) AND IsDeleted = 0 " +
                         "ORDER BY NgayNghi ASC";
            return em.createNativeQuery(sql, YeuCauNghi.class)
                     .setParameter(1, accountID)
                     .getResultList();
        } finally {
            em.close();
        }
    }
}
