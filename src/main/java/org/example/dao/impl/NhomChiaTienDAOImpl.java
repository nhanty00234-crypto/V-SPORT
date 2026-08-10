package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.NhomChiaTienDAO;
import org.example.model.NhomChiaTien;
import org.example.util.BillSplitStatus;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NhomChiaTienDAOImpl implements NhomChiaTienDAO {

    private static final Logger logger = LogManager.getLogger(NhomChiaTienDAOImpl.class);

    private static final String INSERT_SQL =
        "INSERT INTO bill_split_groups (invoice_id, booking_id, created_by_account_id, split_type, total_amount, status, expires_at, created_at, updated_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";

    @Override
    public int insert(Connection conn, NhomChiaTien nct) {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, nct.getHoaDonId());
            ps.setInt(2, nct.getDatSanId());
            ps.setInt(3, nct.getCreatedByAccountId());
            ps.setString(4, nct.getSplitType());
            ps.setBigDecimal(5, nct.getTongTien());
            ps.setString(6, nct.getTrangThai() != null ? nct.getTrangThai() : BillSplitStatus.ACTIVE);
            if (nct.getExpiresAt() != null) ps.setTimestamp(7, new Timestamp(nct.getExpiresAt().getTime()));
            else ps.setNull(7, Types.TIMESTAMP);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert NhomChiaTien: {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public NhomChiaTien findById(int nhomChiaTienId) {
        String sql = "SELECT * FROM bill_split_groups WHERE split_group_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById NhomChiaTienID={}: {}", nhomChiaTienId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public NhomChiaTien findByIdAndCreatedBy(int nhomChiaTienId, int accountId) {
        String sql = "SELECT * FROM bill_split_groups WHERE split_group_id = ? AND created_by_account_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nhomChiaTienId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndCreatedBy NhomChiaTienID={} accountId={}: {}", nhomChiaTienId, accountId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public NhomChiaTien findActiveByHoaDonId(int hoaDonId) {
        String sql = "SELECT * FROM bill_split_groups WHERE invoice_id = ? AND status IN (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            ps.setString(2, BillSplitStatus.ACTIVE);
            ps.setString(3, BillSplitStatus.PARTIALLY_PAID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findActiveByHoaDonId hoaDonId={}: {}", hoaDonId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<NhomChiaTien> findByDatSanId(int datSanId) {
        List<NhomChiaTien> list = new ArrayList<>();
        String sql = "SELECT * FROM bill_split_groups WHERE booking_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByDatSanId datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean updateTrangThai(Connection conn, int nhomChiaTienId, String trangThaiCu, String trangThaiMoi) {
        if (!BillSplitStatus.isValid(trangThaiMoi) || !BillSplitStatus.isValid(trangThaiCu)) {
            logger.warn("updateTrangThai NhomChiaTien: trạng thái không hợp lệ cũ='{}' mới='{}'", trangThaiCu, trangThaiMoi);
            return false;
        }
        String sql = "UPDATE bill_split_groups SET status = ?, updated_at = GETDATE() WHERE split_group_id = ? AND status = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trangThaiMoi);
            ps.setInt(2, nhomChiaTienId);
            ps.setString(3, trangThaiCu);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai(conn) NhomChiaTienID={}: {}", nhomChiaTienId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateTrangThai(int nhomChiaTienId, String trangThaiCu, String trangThaiMoi) {
        try (Connection conn = DBUtil.getConnection()) {
            return updateTrangThai(conn, nhomChiaTienId, trangThaiCu, trangThaiMoi);
        } catch (SQLException e) {
            logger.error("updateTrangThai NhomChiaTienID={}: {}", nhomChiaTienId, e.getMessage(), e);
            return false;
        }
    }

    private NhomChiaTien map(ResultSet rs) throws SQLException {
        NhomChiaTien nct = new NhomChiaTien();
        nct.setNhomChiaTienId(rs.getInt("split_group_id"));
        nct.setHoaDonId(rs.getInt("invoice_id"));
        nct.setDatSanId(rs.getInt("booking_id"));
        nct.setCreatedByAccountId(rs.getInt("created_by_account_id"));
        nct.setSplitType(rs.getString("split_type"));
        BigDecimal tt = rs.getBigDecimal("total_amount");
        nct.setTongTien(tt != null ? tt : BigDecimal.ZERO);
        nct.setTrangThai(rs.getString("status"));
        nct.setExpiresAt(rs.getTimestamp("expires_at"));
        nct.setCreatedAt(rs.getTimestamp("created_at"));
        nct.setUpdatedAt(rs.getTimestamp("updated_at"));
        return nct;
    }
}
