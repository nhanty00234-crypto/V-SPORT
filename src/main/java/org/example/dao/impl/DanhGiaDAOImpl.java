package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.DanhGiaDAO;
import org.example.model.DanhGia;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class DanhGiaDAOImpl implements DanhGiaDAO {

    private static final Logger logger = LogManager.getLogger(DanhGiaDAOImpl.class);

    @Override
    public int insert(DanhGia dg) {
        String sql = "INSERT INTO reviews (booking_id, reviewer_account_id, rating, comment, created_at) " +
                     "VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, dg.getDatSanId());
            ps.setInt(2, dg.getAccountIdNguoiDanhGia());
            ps.setInt(3, dg.getSoSao());
            // BinhLuan đã được escape/sanitize ở Service layer
            ps.setNString(4, dg.getBinhLuan());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert DanhGia datSanId={}: {}", dg.getDatSanId(), e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public boolean existsByDatSanAndAccount(int datSanId, int accountId) {
        String sql = "SELECT 1 FROM reviews WHERE booking_id = ? AND reviewer_account_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("existsByDatSanAndAccount: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean isBookingCompletedByCustomer(int datSanId, int accountId) {
        // Kiểm tra booking hoàn thành thuộc customer — không trust client
        String sql = "SELECT 1 FROM bookings " +
                     "WHERE booking_id = ? AND account_id = ? AND status = N'Hoàn thành'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("isBookingCompletedByCustomer: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public List<DanhGia> findByCoSoId(int coSoId, int filterSoSao, String searchName,
                                       java.time.LocalDate dateFrom, java.time.LocalDate dateTo,
                                       int page, int pageSize) {
        List<DanhGia> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        boolean hasStarFilter = filterSoSao >= 1 && filterSoSao <= 5;
        boolean hasNameFilter = searchName != null && !searchName.trim().isEmpty();
        boolean hasDateFrom   = dateFrom != null;
        boolean hasDateTo     = dateTo   != null;
        String sql =
            "SELECT dg.*, tk.full_name AS CustomerName FROM reviews dg " +
            "JOIN bookings lds ON dg.booking_id = lds.booking_id " +
            "JOIN courts s ON lds.court_id = s.court_id " +
            "LEFT JOIN TaiKhoan tk ON dg.reviewer_account_id = tk.account_id " +
            "WHERE s.facility_id = ? " +
            (hasStarFilter ? "AND dg.rating = ? " : "") +
            (hasNameFilter ? "AND tk.full_name LIKE ? " : "") +
            (hasDateFrom   ? "AND dg.created_at >= ? " : "") +
            (hasDateTo     ? "AND dg.created_at < DATEADD(day,1,?) " : "") +
            "ORDER BY dg.created_at DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setInt(idx++, coSoId);
            if (hasStarFilter) ps.setInt(idx++, filterSoSao);
            if (hasNameFilter) ps.setNString(idx++, "%" + searchName.trim() + "%");
            if (hasDateFrom)   ps.setDate(idx++, java.sql.Date.valueOf(dateFrom));
            if (hasDateTo)     ps.setDate(idx++, java.sql.Date.valueOf(dateTo));
            ps.setInt(idx++, offset);
            ps.setInt(idx, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DanhGia dg = map(rs);
                    dg.setCustomerName(rs.getString("CustomerName"));
                    list.add(dg);
                }
            }
        } catch (SQLException e) {
            logger.error("findByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public double avgByCoSoId(int coSoId) {
        String sql =
            "SELECT AVG(CAST(dg.rating AS FLOAT)) FROM reviews dg " +
            "JOIN bookings lds ON dg.booking_id = lds.booking_id " +
            "JOIN courts s ON lds.court_id = s.court_id " +
            "WHERE s.facility_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double v = rs.getDouble(1);
                    return rs.wasNull() ? 0.0 : v;
                }
            }
        } catch (SQLException e) {
            logger.error("avgByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return 0.0;
    }

    @Override
    public List<DanhGia> findByAccountId(int accountId, int page, int pageSize) {
        List<DanhGia> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql = "SELECT * FROM reviews WHERE reviewer_account_id = ? " +
                     "ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByAccountId accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    private DanhGia map(ResultSet rs) throws SQLException {
        DanhGia dg = new DanhGia();
        dg.setDanhGiaId(rs.getInt("review_id"));
        dg.setDatSanId(rs.getInt("booking_id"));
        dg.setAccountIdNguoiDanhGia(rs.getInt("reviewer_account_id"));
        int bdb = rs.getInt("reviewed_account_id");
        if (!rs.wasNull()) dg.setAccountIdNguoiBiDanhGia(bdb);
        dg.setSoSao(rs.getInt("rating"));
        dg.setBinhLuan(rs.getString("comment"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) dg.setNgayDanhGia(ts.toLocalDateTime());
        return dg;
    }
}
