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
            String sql = "SELECT t.account_id, t.full_name, t.username, t.email, " +
                         "COUNT(l.booking_id) as BookingCount, " +
                         "SUM(l.estimated_total) as TotalSpent " +
                         "FROM bookings l " +
                         "JOIN courts s ON l.court_id = s.court_id " +
                         "JOIN accounts t ON l.account_id = t.account_id " +
                         "WHERE s.facility_id = ?1 AND l.status IN (N'Đã thanh toán', N'Success', N'Đã hoàn thành') " +
                         "GROUP BY t.account_id, t.full_name, t.username, t.email " +
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
            String sql = "SELECT dg.review_id, dg.rating, dg.comment, dg.created_at, " +
                         "t.full_name, t.username, s.court_name " +
                         "FROM reviews dg " +
                         "JOIN bookings l ON dg.booking_id = l.booking_id " +
                         "JOIN courts s ON l.court_id = s.court_id " +
                         "JOIN accounts t ON dg.reviewer_account_id = t.account_id " +
                         "WHERE s.facility_id = ?1 " +
                         "ORDER BY dg.created_at DESC";
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
            String sql = "SELECT l.booking_id, l.booking_date, l.start_time, l.end_time, l.estimated_total, " +
                         "t.full_name, t.username, s.court_name " +
                         "FROM bookings l " +
                         "JOIN courts s ON l.court_id = s.court_id " +
                         "JOIN accounts t ON l.account_id = t.account_id " +
                         "WHERE s.facility_id = ?1 AND l.status IN (N'Chờ thanh toán', N'Pending') " +
                         "AND l.booking_date >= CAST(DATEADD(hour, 7, GETUTCDATE()) AS DATE) " +
                         "ORDER BY l.booking_date ASC, l.start_time ASC";
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
            String sql = "SELECT t.account_id, t.full_name, t.username, t.email, " +
                         "COUNT(l.booking_id) as TotalBookings, " +
                         "SUM(CASE WHEN l.status IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) as CanceledBookings, " +
                         "((CAST(SUM(CASE WHEN l.status IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.booking_id)) * 100) as CancelRate " +
                         "FROM bookings l " +
                         "JOIN courts s ON l.court_id = s.court_id " +
                         "JOIN accounts t ON l.account_id = t.account_id " +
                         "WHERE s.facility_id = ?1 " +
                         "GROUP BY t.account_id, t.full_name, t.username, t.email " +
                         "HAVING COUNT(l.booking_id) >= 3 AND (CAST(SUM(CASE WHEN l.status IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.booking_id)) >= 0.30 " +
                         "ORDER BY CancelRate DESC";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
