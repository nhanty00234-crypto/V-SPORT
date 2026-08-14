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
        String sql = "INSERT INTO DanhGia (DatSanID, AccountID_NguoiDanhGia, SoSao, BinhLuan, NgayDanhGia) " +
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
        String sql = "SELECT 1 FROM DanhGia WHERE DatSanID = ? AND AccountID_NguoiDanhGia = ?";
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
        String sql = "SELECT 1 FROM LichDatSan " +
                     "WHERE DatSanID = ? AND AccountID = ? AND TrangThai = N'Hoàn thành'";
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
            "SELECT dg.*, tk.FullName AS CustomerName FROM DanhGia dg " +
            "JOIN LichDatSan lds ON dg.DatSanID = lds.DatSanID " +
            "JOIN San s ON lds.SanID = s.SanID " +
            "LEFT JOIN TaiKhoan tk ON dg.AccountID_NguoiDanhGia = tk.AccountID " +
            "WHERE s.CoSoID = ? " +
            (hasStarFilter ? "AND dg.SoSao = ? " : "") +
            (hasNameFilter ? "AND tk.FullName LIKE ? " : "") +
            (hasDateFrom   ? "AND dg.NgayDanhGia >= ? " : "") +
            (hasDateTo     ? "AND dg.NgayDanhGia < DATEADD(day,1,?) " : "") +
            "ORDER BY dg.NgayDanhGia DESC " +
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
            "SELECT AVG(CAST(dg.SoSao AS FLOAT)) FROM DanhGia dg " +
            "JOIN LichDatSan lds ON dg.DatSanID = lds.DatSanID " +
            "JOIN San s ON lds.SanID = s.SanID " +
            "WHERE s.CoSoID = ?";
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
        String sql = "SELECT * FROM DanhGia WHERE AccountID_NguoiDanhGia = ? " +
                     "ORDER BY NgayDanhGia DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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
        dg.setDanhGiaId(rs.getInt("DanhGiaID"));
        dg.setDatSanId(rs.getInt("DatSanID"));
        dg.setAccountIdNguoiDanhGia(rs.getInt("AccountID_NguoiDanhGia"));
        int bdb = rs.getInt("AccountID_NguoiBiDanhGia");
        if (!rs.wasNull()) dg.setAccountIdNguoiBiDanhGia(bdb);
        dg.setSoSao(rs.getInt("SoSao"));
        dg.setBinhLuan(rs.getString("BinhLuan"));
        Timestamp ts = rs.getTimestamp("NgayDanhGia");
        if (ts != null) dg.setNgayDanhGia(ts.toLocalDateTime());
        return dg;
    }
}
