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
        String sql = "INSERT INTO CaLamViec_Audit (CaLamViecID, ThaoTac, NguoiThucHien, GiaTriCu, GiaTriMoi, LyDo) VALUES (?, ?, ?, ?, ?, ?)";
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
    public List<CaLamViecAudit> getByCaLamViec(int caLamViecId) {
        List<CaLamViecAudit> list = new ArrayList<>();
        String sql = "SELECT au.*, acc.FullName as ActorName FROM CaLamViec_Audit au JOIN Accounts acc ON au.NguoiThucHien = acc.AccountID WHERE au.CaLamViecID = ? ORDER BY au.ThoiGian DESC";
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
        String sql = "SELECT au.*, acc.FullName as ActorName FROM CaLamViec_Audit au " +
                     "JOIN Accounts acc ON au.NguoiThucHien = acc.AccountID " +
                     "JOIN CaLamViec c ON au.CaLamViecID = c.CaLamViecID " +
                     "WHERE c.CoSoID = ? " +
                     "ORDER BY au.ThoiGian DESC";
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
        au.setAuditId(rs.getInt("AuditID"));
        au.setCaLamViecId(rs.getInt("CaLamViecID"));
        au.setThaoTac(rs.getString("ThaoTac"));
        au.setNguoiThucHien(rs.getInt("NguoiThucHien"));
        
        Timestamp ts = rs.getTimestamp("ThoiGian");
        if (ts != null) {
            au.setThoiGian(ts.toLocalDateTime());
        }
        
        au.setGiaTriCu(rs.getNString("GiaTriCu"));
        au.setGiaTriMoi(rs.getNString("GiaTriMoi"));
        au.setLyDo(rs.getNString("LyDo"));
        au.setTenNguoiThucHien(rs.getNString("ActorName"));
        return au;
    }
}
