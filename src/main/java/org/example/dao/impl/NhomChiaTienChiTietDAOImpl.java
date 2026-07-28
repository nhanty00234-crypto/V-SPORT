package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.NhomChiaTienChiTietDAO;
import org.example.model.NhomChiaTienChiTiet;
import org.example.util.BillSplitShareStatus;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NhomChiaTienChiTietDAOImpl implements NhomChiaTienChiTietDAO {

    private static final Logger logger = LogManager.getLogger(NhomChiaTienChiTietDAOImpl.class);

    private static final String INSERT_SQL =
        "INSERT INTO NhomChiaTienChiTiet (NhomChiaTienID, AccountID, DisplayName, ShareToken, SoTien, TrangThai, CreatedAt, UpdatedAt) " +
        "VALUES (?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

    @Override
    public int insert(Connection conn, NhomChiaTienChiTiet ct) {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ct.getNhomChiaTienId());
            if (ct.getAccountId() != null) ps.setInt(2, ct.getAccountId());
            else ps.setNull(2, Types.INTEGER);
            ps.setNString(3, ct.getDisplayName());
            ps.setString(4, ct.getShareToken());
            ps.setBigDecimal(5, ct.getSoTien());
            ps.setString(6, ct.getTrangThai() != null ? ct.getTrangThai() : BillSplitShareStatus.PENDING);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert NhomChiaTienChiTiet: {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public List<NhomChiaTienChiTiet> findByNhomChiaTienId(int nhomChiaTienId) {
        List<NhomChiaTienChiTiet> list = new ArrayList<>();
        String sql = "SELECT * FROM NhomChiaTienChiTiet WHERE NhomChiaTienID = ? ORDER BY ChiTietID ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByNhomChiaTienId nhomChiaTienId={}: {}", nhomChiaTienId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public NhomChiaTienChiTiet findById(int chiTietId) {
        String sql = "SELECT * FROM NhomChiaTienChiTiet WHERE ChiTietID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chiTietId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById chiTietId={}: {}", chiTietId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public NhomChiaTienChiTiet findByShareToken(String shareToken) {
        if (shareToken == null || shareToken.isBlank()) return null;
        String sql = "SELECT * FROM NhomChiaTienChiTiet WHERE ShareToken = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shareToken);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByShareToken token={}...: {}", org.example.util.ShareTokenGenerator.maskForLog(shareToken), e.getMessage(), e);
        }
        return null;
    }

    @Override
    public NhomChiaTienChiTiet findByIdAndNhomChiaTienId(int chiTietId, int nhomChiaTienId) {
        String sql = "SELECT * FROM NhomChiaTienChiTiet WHERE ChiTietID = ? AND NhomChiaTienID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, chiTietId);
            ps.setInt(2, nhomChiaTienId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndNhomChiaTienId chiTietId={} nhomChiaTienId={}: {}", chiTietId, nhomChiaTienId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public int countByNhomChiaTienId(int nhomChiaTienId) {
        String sql = "SELECT COUNT(*) FROM NhomChiaTienChiTiet WHERE NhomChiaTienID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countByNhomChiaTienId nhomChiaTienId={}: {}", nhomChiaTienId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public int countPaidByNhomChiaTienId(int nhomChiaTienId) {
        String sql = "SELECT COUNT(*) FROM NhomChiaTienChiTiet WHERE NhomChiaTienID = ? AND TrangThai = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            ps.setString(2, BillSplitShareStatus.PAID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countPaidByNhomChiaTienId nhomChiaTienId={}: {}", nhomChiaTienId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public BigDecimal sumPaidByNhomChiaTienId(int nhomChiaTienId) {
        String sql = "SELECT SUM(SoTien) FROM NhomChiaTienChiTiet WHERE NhomChiaTienID = ? AND TrangThai = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            ps.setString(2, BillSplitShareStatus.PAID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal v = rs.getBigDecimal(1);
                    return v != null ? v : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            logger.error("sumPaidByNhomChiaTienId nhomChiaTienId={}: {}", nhomChiaTienId, e.getMessage(), e);
        }
        return BigDecimal.ZERO;
    }

    @Override
    public boolean updateTrangThai(Connection conn, int chiTietId, String trangThaiCu, String trangThaiMoi,
                                    String paymentMethod, String paymentTransactionId, Integer payerAccountId,
                                    Integer confirmedByStaffId) {
        if (!BillSplitShareStatus.isValid(trangThaiMoi) || !BillSplitShareStatus.isValid(trangThaiCu)) {
            logger.warn("updateTrangThai ChiTiet: trạng thái không hợp lệ cũ='{}' mới='{}'", trangThaiCu, trangThaiMoi);
            return false;
        }
        StringBuilder sql = new StringBuilder("UPDATE NhomChiaTienChiTiet SET TrangThai = ?, UpdatedAt = GETDATE()");
        List<Object> params = new ArrayList<>();
        params.add(trangThaiMoi);

        if (paymentMethod != null) {
            sql.append(", PaymentMethod = ?");
            params.add(paymentMethod);
        }
        if (paymentTransactionId != null) {
            sql.append(", PaymentTransactionID = ?");
            params.add(paymentTransactionId);
        }
        if (payerAccountId != null) {
            sql.append(", PayerAccountID = ?");
            params.add(payerAccountId);
        }
        if (confirmedByStaffId != null) {
            sql.append(", ConfirmedByStaffID = ?");
            params.add(confirmedByStaffId);
        }
        if (BillSplitShareStatus.PAID.equals(trangThaiMoi)) {
            sql.append(", PaidAt = GETDATE()");
        }
        sql.append(" WHERE ChiTietID = ? AND TrangThai = ?");
        params.add(chiTietId);
        params.add(trangThaiCu);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai(conn) chiTietId={}: {}", chiTietId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateTrangThai(int chiTietId, String trangThaiCu, String trangThaiMoi,
                                    String paymentMethod, String paymentTransactionId, Integer payerAccountId,
                                    Integer confirmedByStaffId) {
        try (Connection conn = DBUtil.getConnection()) {
            return updateTrangThai(conn, chiTietId, trangThaiCu, trangThaiMoi, paymentMethod,
                    paymentTransactionId, payerAccountId, confirmedByStaffId);
        } catch (SQLException e) {
            logger.error("updateTrangThai chiTietId={}: {}", chiTietId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public int cancelAllByNhomChiaTienId(Connection conn, int nhomChiaTienId) {
        String sql = "UPDATE NhomChiaTienChiTiet SET TrangThai = ?, UpdatedAt = GETDATE() " +
                     "WHERE NhomChiaTienID = ? AND TrangThai IN (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, BillSplitShareStatus.CANCELLED);
            ps.setInt(2, nhomChiaTienId);
            ps.setString(3, BillSplitShareStatus.PENDING);
            ps.setString(4, BillSplitShareStatus.PROCESSING);
            return ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("cancelAllByNhomChiaTienId nhomChiaTienId={}: {}", nhomChiaTienId, e.getMessage(), e);
            return 0;
        }
    }

    private static void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            int idx = i + 1;
            if (p instanceof Integer) ps.setInt(idx, (Integer) p);
            else if (p instanceof String) ps.setString(idx, (String) p);
            else ps.setObject(idx, p);
        }
    }

    private NhomChiaTienChiTiet map(ResultSet rs) throws SQLException {
        NhomChiaTienChiTiet ct = new NhomChiaTienChiTiet();
        ct.setChiTietId(rs.getInt("ChiTietID"));
        ct.setNhomChiaTienId(rs.getInt("NhomChiaTienID"));
        int accId = rs.getInt("AccountID");
        if (!rs.wasNull()) ct.setAccountId(accId);
        ct.setDisplayName(rs.getNString("DisplayName"));
        ct.setShareToken(rs.getString("ShareToken"));
        BigDecimal st = rs.getBigDecimal("SoTien");
        ct.setSoTien(st != null ? st : BigDecimal.ZERO);
        ct.setTrangThai(rs.getString("TrangThai"));
        ct.setPaymentMethod(rs.getString("PaymentMethod"));
        ct.setPaymentTransactionId(rs.getString("PaymentTransactionID"));
        int payerId = rs.getInt("PayerAccountID");
        if (!rs.wasNull()) ct.setPayerAccountId(payerId);
        ct.setPaidAt(rs.getTimestamp("PaidAt"));
        int staffId = rs.getInt("ConfirmedByStaffID");
        if (!rs.wasNull()) ct.setConfirmedByStaffId(staffId);
        ct.setCreatedAt(rs.getTimestamp("CreatedAt"));
        ct.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return ct;
    }
}
