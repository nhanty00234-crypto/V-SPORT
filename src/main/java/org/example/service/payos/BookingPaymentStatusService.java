package org.example.service.payos;

import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.service.NotificationService;
import org.example.service.PayOSConfigurationService;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.example.util.TimeUtil;
import vn.payos.PayOS;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Kiểm tra trạng thái thanh toán PayOS của một booking (luồng orderCode = DatSanID).
 *
 * Logic này trước đây nằm trong {@code DatSanServlet.handlePayOSStatus}; đã hạ xuống Service để
 * Web và REST API mobile dùng CHUNG. Vẫn giữ nguyên nguyên tắc quan trọng:
 *  - Nếu DB đã chốt trạng thái thì trả ngay, không gọi PayOS dư thừa.
 *  - Nếu còn "Chờ thanh toán" và chưa hết hạn giữ chỗ thì query PayOS server-to-server (vì webhook
 *    không tới được localhost), rồi finalize bằng ĐÚNG finalizer dùng chung với webhook
 *    ({@link PayOSLegacyBookingFinalizationService}) — không có bộ cập nhật trạng thái thứ hai.
 *  - Không bao giờ tự đánh dấu PAID chỉ vì client bấm nút.
 */
public class BookingPaymentStatusService {

    private static final Logger LOGGER = Logger.getLogger(BookingPaymentStatusService.class.getName());

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final PayOSLegacyBookingFinalizationService finalizationService =
            new PayOSLegacyBookingFinalizationService();
    private final NotificationService notificationService = new NotificationService();

    public static class Status {
        /** pending | paid | cancelled | expired | settled | not_found */
        public final String status;
        public final boolean paid;
        public final String bookingStatus;
        public final long remainingSeconds;
        public final String message;

        Status(String status, boolean paid, String bookingStatus, long remainingSeconds, String message) {
            this.status = status;
            this.paid = paid;
            this.bookingStatus = bookingStatus;
            this.remainingSeconds = remainingSeconds;
            this.message = message != null ? message : defaultMessageFor(status);
        }

        public boolean isNotFound() { return "not_found".equals(status); }
    }

    private static String defaultMessageFor(String status) {
        return switch (status) {
            case "paid" -> "Thanh toán đã được xác nhận.";
            case "cancelled" -> "Đơn đã được hủy.";
            case "expired" -> "Mã thanh toán đã hết hạn.";
            case "settled" -> "Đơn đã được xử lý.";
            case "not_found" -> "Không tìm thấy đơn.";
            default -> "Chưa nhận được thanh toán.";
        };
    }

    /**
     * @param accountId chủ sở hữu hợp lệ; booking không thuộc account này sẽ trả "not_found"
     *                  (chống IDOR — không tiết lộ đơn của người khác có tồn tại hay không).
     */
    public Status check(int datSanId, int accountId) {
        Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
        if (lich == null || lich.getAccountId() == null || !lich.getAccountId().equals(accountId)) {
            return new Status("not_found", false, null, 0, null);
        }

        String trangThai = lich.getTrangThai();
        if (Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(trangThai)) {
            return new Status("paid", true, trangThai, 0, null);
        }
        if (Constants.TRANG_THAI_DAT_SAN_DA_HUY.equals(trangThai)) {
            return new Status("cancelled", false, trangThai, 0, null);
        }

        LocalDateTime holdExpiresAt = lich.getHoldExpiresAt();
        boolean holdExpired = TimeUtil.isPastUtc(holdExpiresAt);
        boolean isExpiredStatus = Constants.TRANG_THAI_DAT_SAN_QUA_HAN.equals(trangThai)
                || (Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai) && holdExpired);

        if (!Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai) && !isExpiredStatus) {
            // "Chờ xác nhận" (trả tại quầy) hoặc trạng thái khác -> không áp dụng luồng QR PayOS.
            return new Status("settled", false, trangThai, 0, null);
        }
        if (isExpiredStatus) {
            return new Status("expired", false, trangThai, 0, null);
        }

        long remaining = TimeUtil.secondsUntilUtc(holdExpiresAt);

        Integer coSoId = findCoSoIdByDatSanId(datSanId);
        if (coSoId == null) {
            LOGGER.warning("PAYOS_STATUS_CHECK: không tìm thấy CoSoID cho DatSanID=" + datSanId);
            return new Status("pending", false, trangThai, remaining, "Chưa nhận được thanh toán.");
        }
        var credentials = new PayOSConfigurationService().getCredentialsForPayment(coSoId);
        if (credentials == null) {
            LOGGER.warning("PAYOS_STATUS_CHECK: CoSoID=" + coSoId + " chưa cấu hình PayOS, DatSanID=" + datSanId);
            return new Status("pending", false, trangThai, remaining, "Chưa nhận được thanh toán.");
        }

        vn.payos.model.v2.paymentRequests.PaymentLink link;
        PayOS client = PayOSClientFactory.create(credentials);
        try {
            link = client.paymentRequests().get((long) datSanId);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "PAYOS_STATUS_CHECK_FAILED datSanId=" + datSanId + " coSoId=" + coSoId
                    + " loại lỗi=" + e.getClass().getSimpleName(), e);
            return new Status("pending", false, trangThai, remaining,
                    "Không thể kiểm tra trạng thái lúc này. Vui lòng thử lại.");
        } finally {
            client.close();
        }

        LOGGER.info(String.format("PAYOS_STATUS_CHECK datSanId=%d coSoId=%d payosStatus=%s amountPaid=%d",
                datSanId, coSoId, link.getStatus(), link.getAmountPaid()));

        if (link.getStatus() != vn.payos.model.v2.paymentRequests.PaymentLinkStatus.PAID) {
            return new Status("pending", false, trangThai, remaining, "Chưa nhận được thanh toán.");
        }

        String reference = (link.getTransactions() != null && !link.getTransactions().isEmpty())
                ? link.getTransactions().get(0).getReference() : null;
        PayOSLegacyBookingFinalizationService.Result result =
                finalizationService.confirmPaid(datSanId, BigDecimal.valueOf(link.getAmountPaid()), reference);
        LOGGER.info("PAYOS_STATUS_CHECK_FINALIZE_RESULT datSanId=" + datSanId + " result=" + result.code());

        switch (result.code()) {
            case CONFIRMED, ALREADY_CONFIRMED -> {
                if (result.code() == PayOSLegacyBookingFinalizationService.ResultCode.CONFIRMED
                        && result.accountId() != null && result.hoaDonId() != null) {
                    notificationService.notifyPaymentSuccess(result.accountId(), result.hoaDonId(),
                            String.valueOf(link.getAmountPaid()));
                }
                return new Status("paid", true, Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN, 0, null);
            }
            case AMOUNT_MISMATCH -> {
                return new Status("pending", false, trangThai, remaining,
                        "Số tiền chuyển khoản chưa khớp. Vui lòng kiểm tra lại nội dung và số tiền.");
            }
            case CANCELLED -> {
                return new Status("cancelled", false, Constants.TRANG_THAI_DAT_SAN_DA_HUY, 0, null);
            }
            default -> {
                return new Status("pending", false, trangThai, remaining,
                        "Không thể xác nhận thanh toán lúc này. Vui lòng thử lại.");
            }
        }
    }

    /** CoSoID của một DatSanID — để lấy đúng credentials PayOS theo cơ sở (không tin client). */
    public Integer findCoSoIdByDatSanId(int datSanId) {
        String sql = "SELECT s.facility_id FROM bookings l JOIN courts s ON s.court_id = l.court_id WHERE l.booking_id = ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("facility_id") : null;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "findCoSoIdByDatSanId lỗi datSanId=" + datSanId, e);
            return null;
        }
    }
}
