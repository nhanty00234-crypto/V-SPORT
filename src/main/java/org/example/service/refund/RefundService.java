package org.example.service.refund;

import org.example.model.Hoantien;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RefundService {

    private static final Logger logger = LogManager.getLogger(RefundService.class);

    public static class RefundResult {
        public final boolean success;
        public final String message;
        public final Integer refundId;

        public RefundResult(boolean success, String message, Integer refundId) {
            this.success = success;
            this.message = message;
            this.refundId = refundId;
        }

        public static RefundResult ok(String message, int refundId) {
            return new RefundResult(true, message, refundId);
        }

        public static RefundResult fail(String message) {
            return new RefundResult(false, message, null);
        }
    }

    /**
     * Tạo yêu cầu hoàn tiền cho đơn đặt sân của khách hàng (Double refund & IDOR protected).
     */
    public RefundResult requestRefund(int datSanId, int customerAccountId, BigDecimal requestedAmount, String reason) {
        if (requestedAmount == null || requestedAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return RefundResult.fail("Số tiền hoàn phải lớn hơn 0.");
        }

        String sqlCheckBooking = "SELECT lds.account_id, h.invoice_id, h.grand_total, h.payment_status " +
                                 "FROM bookings lds INNER JOIN invoices h ON lds.booking_id = h.booking_id " +
                                 "WHERE lds.booking_id = ?";
        String sqlCheckDoubleRefund = "SELECT COUNT(*) FROM refunds WHERE booking_id = ? AND status IN (N'CHO_XU_LY', N'DA_DUYET')";
        String sqlInsertRefund = "INSERT INTO refunds (booking_id, invoice_id, account_id, refunded_amount, reason, status, requested_at) " +
                                 "VALUES (?, ?, ?, ?, ?, N'CHO_XU_LY', GETDATE())";

        try (Connection conn = DBUtil.getConnection()) {
            int hoaDonId;
            BigDecimal paidAmount;

            try (PreparedStatement ps = conn.prepareStatement(sqlCheckBooking)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return RefundResult.fail("Không tìm thấy đơn đặt sân hoặc hóa đơn tương ứng.");
                    }
                    int accOwner = rs.getInt("account_id");
                    if (accOwner != customerAccountId) {
                        return RefundResult.fail("Bạn không có quyền yêu cầu hoàn tiền cho đơn đặt sân này.");
                    }
                    String paymentStatus = rs.getString("payment_status");
                    if (!"Đã thanh toán".equalsIgnoreCase(paymentStatus)) {
                        return RefundResult.fail("Đơn đặt sân chưa được thanh toán nên không thể yêu cầu hoàn tiền.");
                    }
                    hoaDonId = rs.getInt("invoice_id");
                    paidAmount = rs.getBigDecimal("grand_total");
                }
            }

            if (requestedAmount.compareTo(paidAmount) > 0) {
                return RefundResult.fail("Số tiền yêu cầu hoàn (" + requestedAmount + ") vượt quá số tiền đã thực trả (" + paidAmount + ").");
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlCheckDoubleRefund)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        return RefundResult.fail("Đơn đặt sân này đã có yêu cầu hoàn tiền đang chờ xử lý hoặc đã được duyệt.");
                    }
                }
            }

            int refundId;
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertRefund, PreparedStatement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, datSanId);
                ps.setInt(2, hoaDonId);
                ps.setInt(3, customerAccountId);
                ps.setBigDecimal(4, requestedAmount);
                ps.setNString(5, reason != null ? reason.trim() : "Khách yêu cầu hoàn tiền");
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) return RefundResult.fail("Không thể tạo bản ghi hoàn tiền.");
                    refundId = keys.getInt(1);
                }
            }

            return RefundResult.ok("Yêu cầu hoàn tiền đã được gửi thành công. Ban quản lý sẽ xem xét và xử lý.", refundId);
        } catch (SQLException e) {
            logger.error("Error creating refund request for datSanId={}: {}", datSanId, e.getMessage(), e);
            return RefundResult.fail("Lỗi cơ sở dữ liệu khi tạo yêu cầu hoàn tiền.");
        }
    }

    /**
     * Phê duyệt yêu cầu hoàn tiền bởi Manager/Admin.
     */
    public RefundResult approveRefund(int refundId, int managerAccountId, String note) {
        String sqlSelect = "SELECT booking_id, account_id, refunded_amount, status FROM refunds WITH (UPDLOCK, ROWLOCK) WHERE refund_id = ?";
        String sqlUpdate = "UPDATE refunds SET status = N'DA_DUYET', approver_account_id = ?, refunded_at = GETDATE(), note = ? WHERE refund_id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int customerId;
                int datSanId;
                BigDecimal refundAmount;
                String currentStatus;

                try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                    ps.setInt(1, refundId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền #" + refundId);
                        }
                        datSanId = rs.getInt("booking_id");
                        customerId = rs.getInt("account_id");
                        refundAmount = rs.getBigDecimal("refunded_amount");
                        currentStatus = rs.getString("status");
                    }
                }

                if (!"CHO_XU_LY".equalsIgnoreCase(currentStatus)) {
                    conn.rollback();
                    return RefundResult.fail("Yêu cầu hoàn tiền này đã được xử lý trước đó (Trạng thái: " + currentStatus + ").");
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setInt(1, managerAccountId);
                    ps.setNString(2, note != null ? note.trim() : "Đã duyệt hoàn tiền.");
                    ps.setInt(3, refundId);
                    ps.executeUpdate();
                }

                notifyCustomer(conn, customerId, "Yêu cầu hoàn tiền #" + refundId + " đã được phê duyệt",
                        "Yêu cầu hoàn tiền " + String.format("%,.0f", refundAmount) + " VNĐ cho đơn đặt sân #" + datSanId + " đã được chấp thuận.",
                        "REFUND_" + refundId);

                conn.commit();
                return RefundResult.ok("Đã phê duyệt hoàn tiền thành công cho yêu cầu #" + refundId, refundId);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Error approving refund #{}: {}", refundId, e.getMessage(), e);
            return RefundResult.fail("Lỗi hệ thống khi phê duyệt hoàn tiền.");
        }
    }

    /**
     * Từ chối yêu cầu hoàn tiền bởi Manager/Admin.
     */
    public RefundResult rejectRefund(int refundId, int managerAccountId, String reason) {
        if (reason == null || reason.trim().length() < 5) {
            return RefundResult.fail("Vui lòng cung cấp lý do từ chối cụ thể (tối thiểu 5 ký tự).");
        }

        String sqlSelect = "SELECT booking_id, account_id, status FROM refunds WHERE refund_id = ?";
        String sqlUpdate = "UPDATE refunds SET status = N'TU_CHUOI', approver_account_id = ?, refunded_at = GETDATE(), note = ? WHERE refund_id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int customerId;
                int datSanId;
                String currentStatus;

                try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                    ps.setInt(1, refundId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền #" + refundId);
                        }
                        datSanId = rs.getInt("booking_id");
                        customerId = rs.getInt("account_id");
                        currentStatus = rs.getString("status");
                    }
                }

                if (!"CHO_XU_LY".equalsIgnoreCase(currentStatus)) {
                    conn.rollback();
                    return RefundResult.fail("Yêu cầu hoàn tiền này đã được xử lý trước đó.");
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setInt(1, managerAccountId);
                    ps.setNString(2, reason.trim());
                    ps.setInt(3, refundId);
                    ps.executeUpdate();
                }

                notifyCustomer(conn, customerId, "Yêu cầu hoàn tiền #" + refundId + " bị từ chối",
                        "Yêu cầu hoàn tiền cho đơn đặt sân #" + datSanId + " không được chấp thuận. Lý do: " + reason.trim(),
                        "REFUND_REJECT_" + refundId);

                conn.commit();
                return RefundResult.ok("Đã từ chối yêu cầu hoàn tiền #" + refundId, refundId);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Error rejecting refund #{}: {}", refundId, e.getMessage(), e);
            return RefundResult.fail("Lỗi hệ thống khi từ chối yêu cầu hoàn tiền.");
        }
    }

    /**
     * Lấy danh sách yêu cầu hoàn tiền của một tài khoản khách hàng.
     */
    public List<Hoantien> getRefundsByAccount(int accountId) {
        List<Hoantien> list = new ArrayList<>();
        String sql = "SELECT refund_id, booking_id, invoice_id, account_id, refunded_amount, reason, status, requested_at, refunded_at, note " +
                     "FROM refunds WHERE account_id = ? ORDER BY requested_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Hoantien h = new Hoantien();
                    h.setHoanTienId(rs.getInt("refund_id"));
                    h.setAccountId(rs.getInt("account_id"));
                    h.setSoTienHoan(rs.getBigDecimal("refunded_amount"));
                    h.setLyDo(rs.getNString("reason"));
                    h.setTrangThai(rs.getString("status"));
                    h.setThoiGianYeuCau(rs.getTimestamp("requested_at"));
                    h.setThoiGianHoan(rs.getTimestamp("refunded_at"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            logger.error("Error fetching refunds for accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    private void notifyCustomer(Connection conn, int customerId, String title, String body, String refCode) {
        String sqlInsert = "INSERT INTO notifications (account_id, title, content, notification_type, is_read, sent_at, reference_id, link_url) " +
                           "VALUES (?, ?, ?, N'HE_THONG', 0, GETDATE(), ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
            ps.setInt(1, customerId);
            ps.setNString(2, title);
            ps.setNString(3, body);
            ps.setString(4, refCode);
            ps.setString(5, "/customer/lich-su-dat-san");
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.warn("Failed to insert notification for customerId={}: {}", customerId, e.getMessage());
        }
    }
}
