package org.example.service.admin;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Soft-delete và thu hồi CoSo cùng với bản ghi AdminTrash tương ứng, chạy
 * trong CÙNG một transaction JDBC (một Connection, autoCommit=false) để
 * tránh tình trạng CoSo đã xóa nhưng AdminTrash không có dòng, hoặc CoSo
 * đã thu hồi nhưng AdminTrash vẫn còn đánh dấu "chưa thu hồi".
 */
public class FacilityTrashService {

    private static final Logger logger = LogManager.getLogger(FacilityTrashService.class);

    public static class Result {
        public final boolean success;
        public final String message;

        private Result(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        static Result ok(String message) { return new Result(true, message); }
        static Result fail(String message) { return new Result(false, message); }
    }

    /**
     * Soft-delete một CoSo và ghi đúng một dòng AdminTrash. Nếu đã có dòng
     * AdminTrash chưa thu hồi cho CoSo này (dữ liệu bất thường), không ghi
     * trùng — chỉ báo là cơ sở đã ở trong thùng rác.
     */
    public Result softDeleteFacility(int coSoId, int actorId) {
        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null) {
                logger.error("Không thể kết nối cơ sở dữ liệu khi soft-delete CoSoID={}", coSoId);
                return Result.fail("Lỗi hệ thống khi xóa cơ sở.");
            }
            conn.setAutoCommit(false);
            try {
                String tenCoSo;
                String oldStatus;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT facility_name, status FROM facilities WHERE facility_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)")) {
                    ps.setInt(1, coSoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return Result.fail("Cơ sở không tồn tại hoặc đã bị xóa trước đó.");
                        }
                        tenCoSo = rs.getNString("facility_name");
                        oldStatus = rs.getNString("status");
                    }
                }

                int sanDangSuDung = 0;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM courts WHERE facility_id = ? AND status = N'Đang sử dụng'")) {
                    ps.setInt(1, coSoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) sanDangSuDung = rs.getInt(1);
                    }
                }

                int paymentPending = 0;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM payos_payment_attempts WHERE facility_id = ? AND status = N'PENDING'")) {
                    ps.setInt(1, coSoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) paymentPending = rs.getInt(1);
                    }
                }

                if (sanDangSuDung > 0 || paymentPending > 0) {
                    conn.rollback();
                    StringBuilder msg = new StringBuilder("Không thể ngừng hoạt động cơ sở vì đang có ");
                    if (sanDangSuDung > 0) msg.append(sanDangSuDung).append(" sân sử dụng");
                    if (sanDangSuDung > 0 && paymentPending > 0) msg.append(" và ");
                    if (paymentPending > 0) msg.append(paymentPending).append(" giao dịch chờ thanh toán");
                    msg.append(". Vui lòng xử lý xong trước khi ngừng hoạt động.");
                    return Result.fail(msg.toString());
                }

                int updated;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE facilities SET is_deleted = 1, deleted_at = SYSUTCDATETIME(), deleted_by = ? " +
                        "WHERE facility_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)")) {
                    ps.setInt(1, actorId);
                    ps.setInt(2, coSoId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    conn.rollback();
                    return Result.fail("Cơ sở không tồn tại hoặc đã bị xóa trước đó.");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM admin_trash WHERE entity_type = 'facilities' AND entity_id = ? AND is_restored = 0")) {
                    ps.setInt(1, coSoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            conn.commit();
                            logger.warn("AdminTrash đã có dòng chưa thu hồi cho CoSoID={}, bỏ qua insert trùng", coSoId);
                            return Result.ok("Cơ sở đã ở trong thùng rác.");
                        }
                    }
                }

                int trashId = -1;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO admin_trash (entity_type, entity_id, display_name, source_table, old_status, deleted_by, is_restored) " +
                        "VALUES ('facilities', ?, ?, 'facilities', ?, ?, 0)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, coSoId);
                    ps.setNString(2, tenCoSo);
                    ps.setNString(3, oldStatus);
                    ps.setInt(4, actorId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return Result.fail("Không thể ghi vào thùng rác.");
                    }
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) trashId = keys.getInt(1);
                    }
                }

                conn.commit();
                logger.info("Admin soft deleted facility: adminId={}, coSoId={}, trashId={}", actorId, coSoId, trashId);
                return Result.ok("Đã chuyển vào thùng rác.");
            } catch (SQLException e) {
                conn.rollback();
                logger.error("Lỗi soft-delete CoSoID={}: {}", coSoId, e.getMessage(), e);
                return Result.fail("Lỗi hệ thống khi xóa cơ sở.");
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Lỗi kết nối khi soft-delete CoSoID={}: {}", coSoId, e.getMessage(), e);
            return Result.fail("Lỗi hệ thống khi xóa cơ sở.");
        }
    }

    /**
     * Thu hồi một CoSo từ AdminTrash: đặt lại IsDeleted=0, TrangThai=OldStatus
     * và đánh dấu AdminTrash.IsRestored=1, trong cùng transaction.
     */
    public Result restoreFacility(int trashId, int actorId) {
        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null) {
                logger.error("Không thể kết nối cơ sở dữ liệu khi thu hồi TrashID={}", trashId);
                return Result.fail("Lỗi hệ thống khi thu hồi.");
            }
            conn.setAutoCommit(false);
            try {
                int entityId;
                String oldStatus;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT entity_id, old_status, entity_type FROM admin_trash WHERE trash_id = ? AND is_restored = 0")) {
                    ps.setInt(1, trashId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return Result.fail("Không tìm thấy mục cần thu hồi hoặc đã được thu hồi trước đó.");
                        }
                        if (!"facilities".equals(rs.getString("entity_type"))) {
                            conn.rollback();
                            return Result.fail("Loại dữ liệu không hợp lệ cho thao tác này.");
                        }
                        entityId = rs.getInt("entity_id");
                        oldStatus = rs.getNString("old_status");
                    }
                }

                String updateCoSoSql = "UPDATE facilities SET is_deleted = 0, deleted_at = NULL, deleted_by = NULL" +
                        (oldStatus != null ? ", status = ?" : "") + " WHERE facility_id = ?";
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(updateCoSoSql)) {
                    int idx = 1;
                    if (oldStatus != null) ps.setNString(idx++, oldStatus);
                    ps.setInt(idx, entityId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    conn.rollback();
                    return Result.fail("Không tìm thấy cơ sở gốc để thu hồi.");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE admin_trash SET is_restored = 1, restored_by = ?, restored_at = SYSUTCDATETIME() " +
                        "WHERE trash_id = ? AND is_restored = 0")) {
                    ps.setInt(1, actorId);
                    ps.setInt(2, trashId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return Result.fail("Mục này đã được thu hồi trước đó.");
                    }
                }

                conn.commit();
                logger.info("Admin restored trash item: adminId={}, trashId={}, entityType={}, entityId={}",
                        actorId, trashId, "facilities", entityId);
                return Result.ok("Đã thu hồi thành công.");
            } catch (SQLException e) {
                conn.rollback();
                logger.error("Lỗi thu hồi TrashID={}: {}", trashId, e.getMessage(), e);
                return Result.fail("Lỗi hệ thống khi thu hồi.");
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Lỗi kết nối khi thu hồi TrashID={}: {}", trashId, e.getMessage(), e);
            return Result.fail("Lỗi hệ thống khi thu hồi.");
        }
    }
}
