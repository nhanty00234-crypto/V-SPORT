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
        String sql = "INSERT INTO admin_trash (entity_type, entity_id, display_name, source_table, old_status, deleted_by, Reason) " +
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
        String sql = "SELECT t.*, a.full_name AS DeletedByName FROM admin_trash t " +
                     "LEFT JOIN accounts a ON a.account_id = t.deleted_by WHERE t.trash_id = ?";
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
                "SELECT t.*, a.full_name AS DeletedByName FROM admin_trash t " +
                "LEFT JOIN accounts a ON a.account_id = t.deleted_by WHERE 1=1");
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
        sql.append(" ORDER BY t.deleted_at DESC");

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
        String sql = "UPDATE admin_trash SET is_restored = 1, restored_by = ?, restored_at = SYSUTCDATETIME() " +
                     "WHERE trash_id = ? AND is_restored = 0";
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
        t.setTrashId(rs.getInt("trash_id"));
        t.setEntityType(rs.getString("entity_type"));
        t.setEntityId(rs.getInt("entity_id"));
        t.setDisplayName(rs.getString("display_name"));
        t.setSourceTable(rs.getString("source_table"));
        t.setOldStatus(rs.getString("old_status"));
        int deletedBy = rs.getInt("deleted_by");
        t.setDeletedBy(rs.wasNull() ? null : deletedBy);
        t.setDeletedByName(rs.getString("DeletedByName"));
        Timestamp deletedAt = rs.getTimestamp("deleted_at");
        if (deletedAt != null) t.setDeletedAt(deletedAt.toLocalDateTime());
        t.setReason(rs.getString("Reason"));
        t.setRestored(rs.getBoolean("is_restored"));
        int restoredBy = rs.getInt("restored_by");
        t.setRestoredBy(rs.wasNull() ? null : restoredBy);
        Timestamp restoredAt = rs.getTimestamp("restored_at");
        if (restoredAt != null) t.setRestoredAt(restoredAt.toLocalDateTime());
        return t;
    }
}
