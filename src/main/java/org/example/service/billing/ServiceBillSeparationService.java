package org.example.service.billing;

import org.example.dao.CheckInDAO;
import org.example.model.HoaDon;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Service quản lý tách/chia hóa đơn (Service Bill Separation).
 * Hỗ trợ tách tiền dịch vụ phát sinh ngoài tiền sân thành hóa đơn riêng (SPLIT)
 * và tự động gửi thông báo tới khách hàng.
 */
public class ServiceBillSeparationService {

    private static final Logger logger = LogManager.getLogger(ServiceBillSeparationService.class);
    private final CheckInDAO checkInDAO;

    public ServiceBillSeparationService() {
        this(new CheckInDAO());
    }

    public ServiceBillSeparationService(CheckInDAO checkInDAO) {
        this.checkInDAO = checkInDAO;
    }

    public static class SplitBillResult {
        public final boolean success;
        public final String message;
        public final Integer splitHoaDonId;

        public SplitBillResult(boolean success, String message, Integer splitHoaDonId) {
            this.success = success;
            this.message = message;
            this.splitHoaDonId = splitHoaDonId;
        }

        public static SplitBillResult ok(String message, int splitHoaDonId) {
            return new SplitBillResult(true, message, splitHoaDonId);
        }

        public static SplitBillResult fail(String message) {
            return new SplitBillResult(false, message, null);
        }
    }

    public static class BillSummaryDTO {
        public int datSanId;
        public double mainBillAmount;
        public String mainBillStatus;
        public double splitBillsTotal;
        public double grandTotal;
        public List<HoaDon> splitBills = new ArrayList<>();
    }

    /**
     * Tách dịch vụ phát sinh thành hóa đơn riêng biệt (LoaiHoaDon = 'SPLIT').
     */
    public SplitBillResult splitServiceBill(int datSanId, int[] productIds, int[] quantities,
                                             boolean payNow, String paymentMethod, int staffAccountId,
                                             int requiredCoSoId) {
        try {
            int splitHoaDonId = checkInDAO.addServicesSplitBill(datSanId, productIds, quantities, payNow, paymentMethod, staffAccountId, requiredCoSoId);

            // Tự động tạo ThongBao thông báo cho khách hàng
            notifyCustomerAboutSplitBill(datSanId, splitHoaDonId);

            return SplitBillResult.ok("Đã tách hóa đơn dịch vụ #" + splitHoaDonId + " thành công.", splitHoaDonId);
        } catch (CheckInDAO.CheckInException e) {
            logger.warn("CheckIn validation error during split bill for datSanId={}: {}", datSanId, e.getMessage());
            return SplitBillResult.fail(e.getMessage());
        } catch (Exception e) {
            logger.error("System error during split bill for datSanId={}: {}", datSanId, e.getMessage(), e);
            return SplitBillResult.fail("Hệ thống gặp lỗi khi tách hóa đơn: " + e.getMessage());
        }
    }

    /**
     * Lấy thông tin tổng hợp hóa đơn chính và các hóa đơn tách của booking.
     */
    public BillSummaryDTO getBillSummary(int datSanId) {
        BillSummaryDTO summary = new BillSummaryDTO();
        summary.datSanId = datSanId;

        String sqlMain = "SELECT invoice_id, grand_total, payment_status FROM invoices WHERE booking_id = ? AND (invoice_type IS NULL OR invoice_type = 'MAIN')";
        String sqlSplits = "SELECT invoice_id, grand_total, payment_status, payment_method, issued_at, note " +
                           "FROM invoices WHERE booking_id = ? AND invoice_type = 'SPLIT' ORDER BY issued_at DESC";

        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlMain)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        summary.mainBillAmount = rs.getDouble("grand_total");
                        summary.mainBillStatus = rs.getString("payment_status");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlSplits)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        HoaDon h = new HoaDon();
                        h.setHoaDonId(rs.getInt("invoice_id"));
                        h.setDatSanId(datSanId);
                        h.setTongThanhToan(rs.getDouble("grand_total"));
                        h.setTrangThaiThanhToan(rs.getString("payment_status"));
                        h.setPhuongThucThanhToan(rs.getString("payment_method"));
                        h.setNgayLap(rs.getTimestamp("issued_at"));
                        h.setLoaiHoaDon("SPLIT");
                        h.setGhiChu(rs.getNString("note"));
                        summary.splitBills.add(h);
                        summary.splitBillsTotal += h.getTongThanhToan();
                    }
                }
            }

            summary.grandTotal = summary.mainBillAmount + summary.splitBillsTotal;
        } catch (SQLException e) {
            logger.error("Error fetching bill summary for datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return summary;
    }

    private void notifyCustomerAboutSplitBill(int datSanId, int splitHoaDonId) {
        String sqlFindCustomer = "SELECT account_id FROM bookings WHERE booking_id = ?";
        String sqlInsertNotification = "INSERT INTO notifications (account_id, title, content, notification_type, is_read, sent_at, reference_id, link_url) " +
                                        "VALUES (?, N'Hóa đơn dịch vụ mới', ?, N'HE_THONG', 0, GETDATE(), ?, ?)";
        try (Connection conn = DBUtil.getConnection()) {
            Integer customerId = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlFindCustomer)) {
                ps.setInt(1, datSanId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int accId = rs.getInt("account_id");
                        if (!rs.wasNull()) customerId = accId;
                    }
                }
            }

            if (customerId != null && customerId > 0) {
                try (PreparedStatement ps = conn.prepareStatement(sqlInsertNotification)) {
                    ps.setInt(1, customerId);
                    ps.setNString(2, "Một hóa đơn dịch vụ tách riêng #" + splitHoaDonId + " đã được tạo cho ca đặt sân #" + datSanId + ".");
                    ps.setString(3, "BILL_SPLIT_" + splitHoaDonId);
                    ps.setString(4, "/customer/lich-su-dat-san");
                    ps.executeUpdate();
                }
            }
        } catch (Throwable e) {
            logger.warn("Failed to send notification for split bill #{}: {}", splitHoaDonId, e.getMessage());
        }
    }
}
