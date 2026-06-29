package org.example.dao.impl;

import org.example.dao.CustomerBranchDAO;
import org.example.util.JPAUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import java.util.List;

public class CustomerBranchDAOImpl implements CustomerBranchDAO {

    private EntityManager getEntityManager() {
        return JPAUtil.getEntityManager();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getTopCustomers(int coSoId, boolean sortBySpending, int limit) {
        EntityManager em = getEntityManager();
        try {
            String orderBy = sortBySpending ? "TotalSpent DESC" : "BookingCount DESC";
            String sql = "SELECT t.AccountID, t.FullName, t.Username, t.Email, " +
                         "COUNT(l.DatSanID) as BookingCount, " +
                         "SUM(l.TongTienDuKien) as TotalSpent " +
                         "FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 AND l.TrangThai IN (N'Đã thanh toán', N'Success', N'Đã hoàn thành') " +
                         "GROUP BY t.AccountID, t.FullName, t.Username, t.Email " +
                         "ORDER BY " + orderBy;
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            query.setMaxResults(limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getBranchReviews(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT dg.DanhGiaID, dg.SoSao, dg.BinhLuan, dg.NgayDanhGia, " +
                         "t.FullName, t.Username, s.TenSan " +
                         "FROM DanhGia dg " +
                         "JOIN LichDatSan l ON dg.DatSanID = l.DatSanID " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON dg.AccountID_NguoiDanhGia = t.AccountID " +
                         "WHERE s.CoSoID = ?1 " +
                         "ORDER BY dg.NgayDanhGia DESC";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getRiskBookings(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT l.DatSanID, l.NgayDat, l.GioBatDau, l.GioKetThuc, l.TongTienDuKien, " +
                         "t.FullName, t.Username, s.TenSan " +
                         "FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 AND l.TrangThai IN (N'Chờ thanh toán', N'Pending') " +
                         "AND l.NgayDat >= CAST(GETDATE() AS DATE) " +
                         "ORDER BY l.NgayDat ASC, l.GioBatDau ASC";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getHighRiskCancelers(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT t.AccountID, t.FullName, t.Username, t.Email, " +
                         "COUNT(l.DatSanID) as TotalBookings, " +
                         "SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) as CanceledBookings, " +
                         "((CAST(SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.DatSanID)) * 100) as CancelRate " +
                         "FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 " +
                         "GROUP BY t.AccountID, t.FullName, t.Username, t.Email " +
                         "HAVING COUNT(l.DatSanID) >= 3 AND (CAST(SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.DatSanID)) >= 0.30 " +
                         "ORDER BY CancelRate DESC";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
