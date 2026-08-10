package org.example.dao.impl;

import org.example.dao.CaLamViecAuditDAO;
import org.example.model.CaLamViecAudit;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CaLamViecAuditDAOImpl implements CaLamViecAuditDAO {

    private static final Logger logger = LogManager.getLogger(CaLamViecAuditDAOImpl.class);

    @Override
    public boolean insert(CaLamViecAudit audit) {
        String sql = "INSERT INTO work_shift_audits (work_shift_id, action, performed_by, old_value, new_value, reason) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, audit.getCaLamViecId());
            ps.setString(2, audit.getThaoTac());
            ps.setInt(3, audit.getNguoiThucHien());
            ps.setString(4, audit.getGiaTriCu());
            ps.setString(5, audit.getGiaTriMoi());
            ps.setString(6, audit.getLyDo());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error inserting audit log: {}", e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean insertWithConnection(CaLamViecAudit audit, Connection conn) throws SQLException {
        String sql = "INSERT INTO work_shift_audits (work_shift_id, action, performed_by, old_value, new_value, reason) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, audit.getCaLamViecId());
            ps.setString(2, audit.getThaoTac());
            ps.setInt(3, audit.getNguoiThucHien());
            ps.setString(4, audit.getGiaTriCu());
            ps.setString(5, audit.getGiaTriMoi());
            ps.setString(6, audit.getLyDo());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public List<CaLamViecAudit> getByCaLamViec(int caLamViecId) {
        List<CaLamViecAudit> list = new ArrayList<>();
        String sql = "SELECT au.*, acc.full_name as actor_name FROM work_shift_audits au JOIN accounts acc ON au.performed_by = acc.account_id WHERE au.work_shift_id = ? ORDER BY au.performed_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, caLamViecId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting audit log for shift ID {}: {}", caLamViecId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<CaLamViecAudit> getByCoSo(int coSoId) {
        List<CaLamViecAudit> list = new ArrayList<>();
        String sql = "SELECT au.*, acc.full_name as actor_name FROM work_shift_audits au " +
                     "JOIN accounts acc ON au.performed_by = acc.account_id " +
                     "JOIN work_shifts c ON au.work_shift_id = c.work_shift_id " +
                     "WHERE c.facility_id = ? " +
                     "ORDER BY au.performed_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting audit log for branch ID {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    private CaLamViecAudit mapResultSet(ResultSet rs) throws SQLException {
        CaLamViecAudit au = new CaLamViecAudit();
        au.setAuditId(rs.getInt("audit_id"));
        au.setCaLamViecId(rs.getInt("work_shift_id"));
        au.setThaoTac(rs.getString("action"));
        au.setNguoiThucHien(rs.getInt("performed_by"));
        
        Timestamp ts = rs.getTimestamp("performed_at");
        if (ts != null) {
            au.setThoiGian(ts.toLocalDateTime());
        }
        
        au.setGiaTriCu(rs.getNString("old_value"));
        au.setGiaTriMoi(rs.getNString("new_value"));
        au.setLyDo(rs.getNString("reason"));
        au.setTenNguoiThucHien(rs.getNString("actor_name"));
        return au;
    }
}
