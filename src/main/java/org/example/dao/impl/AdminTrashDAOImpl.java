package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.AdminTrashDAO;
import org.example.model.AdminTrash;
import org.example.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminTrashDAOImpl implements AdminTrashDAO {

    private static final Logger logger = LogManager.getLogger(AdminTrashDAOImpl.class);

    @Override
    public boolean log(String entityType, int entityId, String displayName, String sourceTable,
                        String oldStatus, Integer deletedBy, String reason) {
        String sql = "INSERT INTO AdminTrash (EntityType, EntityID, DisplayName, SourceTable, OldStatus, DeletedBy, Reason) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entityType);
            ps.setInt(2, entityId);
            ps.setString(3, displayName);
            ps.setString(4, sourceTable);
            ps.setString(5, oldStatus);
            if (deletedBy != null) ps.setInt(6, deletedBy); else ps.setNull(6, Types.INTEGER);
            ps.setString(7, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi ghi AdminTrash cho {}#{}: {}", entityType, entityId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public AdminTrash getById(int trashId) {
        String sql = "SELECT t.*, a.FullName AS DeletedByName FROM AdminTrash t " +
                     "LEFT JOIN Accounts a ON a.AccountID = t.DeletedBy WHERE t.TrashID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, trashId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("Lỗi lấy AdminTrash ID {}: {}", trashId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<AdminTrash> search(String entityType, String restoredFilter, Integer deletedBy) {
        StringBuilder sql = new StringBuilder(
                "SELECT t.*, a.FullName AS DeletedByName FROM AdminTrash t " +
                "LEFT JOIN Accounts a ON a.AccountID = t.DeletedBy WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (entityType != null && !entityType.isEmpty() && !"all".equalsIgnoreCase(entityType)) {
            sql.append(" AND t.EntityType = ?");
            params.add(entityType);
        }
        if ("restored".equalsIgnoreCase(restoredFilter)) {
            sql.append(" AND t.IsRestored = 1");
        } else if ("not_restored".equalsIgnoreCase(restoredFilter)) {
            sql.append(" AND t.IsRestored = 0");
        }
        if (deletedBy != null) {
            sql.append(" AND t.DeletedBy = ?");
            params.add(deletedBy);
        }
        sql.append(" ORDER BY t.DeletedAt DESC");

        List<AdminTrash> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi tìm kiếm AdminTrash: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean markRestored(int trashId, int restoredBy) {
        String sql = "UPDATE AdminTrash SET IsRestored = 1, RestoredBy = ?, RestoredAt = SYSUTCDATETIME() " +
                     "WHERE TrashID = ? AND IsRestored = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, restoredBy);
            ps.setInt(2, trashId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi đánh dấu thu hồi AdminTrash ID {}: {}", trashId, e.getMessage(), e);
            return false;
        }
    }

    private AdminTrash map(ResultSet rs) throws SQLException {
        AdminTrash t = new AdminTrash();
        t.setTrashId(rs.getInt("TrashID"));
        t.setEntityType(rs.getString("EntityType"));
        t.setEntityId(rs.getInt("EntityID"));
        t.setDisplayName(rs.getString("DisplayName"));
        t.setSourceTable(rs.getString("SourceTable"));
        t.setOldStatus(rs.getString("OldStatus"));
        int deletedBy = rs.getInt("DeletedBy");
        t.setDeletedBy(rs.wasNull() ? null : deletedBy);
        t.setDeletedByName(rs.getString("DeletedByName"));
        Timestamp deletedAt = rs.getTimestamp("DeletedAt");
        if (deletedAt != null) t.setDeletedAt(deletedAt.toLocalDateTime());
        t.setReason(rs.getString("Reason"));
        t.setRestored(rs.getBoolean("IsRestored"));
        int restoredBy = rs.getInt("RestoredBy");
        t.setRestoredBy(rs.wasNull() ? null : restoredBy);
        Timestamp restoredAt = rs.getTimestamp("RestoredAt");
        if (restoredAt != null) t.setRestoredAt(restoredAt.toLocalDateTime());
        return t;
    }
}
