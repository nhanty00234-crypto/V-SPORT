package org.example.service.booking;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.service.NotificationService;
import org.example.service.RefundService;
import org.example.service.reputation.CustomerReputationService;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;

/**
 * Hủy booking do khách tự thao tác (mục 5, 16 spec). Servlet chỉ nhận request và gọi service này -
 * không được duplicate logic tính hủy sớm/hủy sát giờ hay trừ điểm ở bất kỳ Servlet nào khác.
 */
public class BookingCancellationService {

    private static final Logger logger = LogManager.getLogger(BookingCancellationService.class);

    private final LichDatSanDAO lichDatSanDAO;
    private final RefundService refundService;
    private final NotificationService notificationService;

    public BookingCancellationService() {
        this(new LichDatSanDAOImpl(), new RefundService(), new NotificationService());
    }

    public BookingCancellationService(LichDatSanDAO lichDatSanDAO) {
        this(lichDatSanDAO, new RefundService(), new NotificationService());
    }

    public BookingCancellationService(LichDatSanDAO lichDatSanDAO, RefundService refundService,
                                       NotificationService notificationService) {
        this.lichDatSanDAO = lichDatSanDAO;
        this.refundService = refundService;
        this.notificationService = notificationService;
    }

    public static class CancellationPreview {
        public boolean success = false;
        public String message = "";
        public int datSanId;
        public boolean paid = false;
        public String paymentStatus = "UNPAID";
        public String paymentMethod;
        public BigDecimal amountPaid = BigDecimal.ZERO;
        public boolean cancellationAllowed = false;
        public boolean refundEligible = false;
        public BigDecimal cancellationFee = BigDecimal.ZERO;
        public BigDecimal refundableAmount = BigDecimal.ZERO;
        public int reputationPenalty = 0;
        public double hoursBeforeStart = 0.0;
        public boolean refundAlreadyExists = false;
        public Integer existingHoanTienId = null;
        public String policyMessage = "";

        public CancellationPreview() {}
    }

    public static class CancelResult {
        public final boolean success;
        public final boolean alreadyCancelled;
        public final boolean lateCancel;
        public final String message;
        public final Integer newReputationScore;
        public final Integer createdHoanTienId;
        public final BigDecimal refundableAmount;
        public final BigDecimal amountPaid;
        public final BigDecimal cancellationFee;

        private CancelResult(boolean success, boolean alreadyCancelled, boolean lateCancel,
                              String message, Integer newReputationScore, Integer createdHoanTienId,
                              BigDecimal refundableAmount, BigDecimal amountPaid, BigDecimal cancellationFee) {
            this.success = success;
            this.alreadyCancelled = alreadyCancelled;
            this.lateCancel = lateCancel;
            this.message = message;
            this.newReputationScore = newReputationScore;
            this.createdHoanTienId = createdHoanTienId;
            this.refundableAmount = refundableAmount;
            this.amountPaid = amountPaid;
            this.cancellationFee = cancellationFee;
        }

        public static CancelResult ok(boolean lateCancel, String message, Integer newReputationScore, Integer createdHoanTienId,
                              BigDecimal refundableAmount, BigDecimal amountPaid, BigDecimal cancellationFee) {
            return new CancelResult(true, false, lateCancel, message, newReputationScore, createdHoanTienId, refundableAmount, amountPaid, cancellationFee);
        }

        public static CancelResult ok(boolean lateCancel, String message, Integer newReputationScore) {
            return new CancelResult(true, false, lateCancel, message, newReputationScore, null, BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
        }

        public static CancelResult alreadyDone(String message) {
            return new CancelResult(false, true, false, message, null, null, null, null, null);
        }

        public static CancelResult fail(String message) {
            return new CancelResult(false, false, false, message, null, null, null, null, null);
        }
    }

    /** Trạng thái nguồn được phép hủy bởi khách (mục 10 spec). Logic thuần — test riêng, không đụng DB. */
    public static boolean isCancellableStatus(String trangThai) {
        return Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN.equals(trangThai)
                || Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(trangThai)
                || Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai);
    }

    /**
     * Tính trước thông tin hủy sân (Preview API) - không sửa đổi DB.
     */
    public CancellationPreview calculatePreview(int datSanId, int accountId) {
        CancellationPreview preview = new CancellationPreview();
        preview.datSanId = datSanId;

        Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
        if (lich == null) {
            logger.warn("[cancellation-preview] BOOKING_ID_NOT_FOUND datSanId={}, accountId={}", datSanId, accountId);
            preview.message = "Không tìm thấy đơn đặt sân.";
            return preview;
        }
        if (lich.getAccountId() == null || lich.getAccountId() != accountId) {
            logger.warn("[cancellation-preview] BOOKING_NOT_OWNED_BY_ACCOUNT datSanId={}, bookingAccountId={}, requestAccountId={}",
                    datSanId, lich.getAccountId(), accountId);
            preview.message = "Bạn không có quyền xem đơn này.";
            return preview;
        }

        if (!isCancellableStatus(lich.getTrangThai())) {
            logger.info("[cancellation-preview] BOOKING_FILTERED_BY_STATUS datSanId={}, accountId={}, trangThai={}",
                    datSanId, accountId, lich.getTrangThai());
            preview.message = "Chỉ có thể hủy đơn đang ở trạng thái 'Chờ xác nhận', 'Đã xác nhận' hoặc 'Chờ thanh toán'. Đơn hiện tại ở trạng thái '" + lich.getTrangThai() + "'.";
            return preview;
        }
        if (Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(lich.getTrangThai())
                && org.example.util.TimeUtil.isPastUtc(lich.getHoldExpiresAt())) {
            preview.message = "Đơn giữ chỗ đã hết hạn, không thể hủy.";
            return preview;
        }

        preview.cancellationAllowed = true;

        // Doc thong tin thanh toan thuc te tu DB (Khong trust client)
        int hoaDonId = RefundService.findPaidHoaDonId(datSanId);
        BigDecimal paidAmt = null;
        if (hoaDonId > 0) {
            paidAmt = RefundService.loadPaidAmount(hoaDonId);
            if (paidAmt == null) {
                logger.warn("[cancellation-preview] PAYMENT_RECORD_MISSING hoaDonId={} datSanId={} accountId={}",
                        hoaDonId, datSanId, accountId);
            }
        } else {
            logger.info("[cancellation-preview] BOOKING_FOUND_BUT_INVOICE_MISSING datSanId={} accountId={} " +
                    "trangThai={} depositAmount={}", datSanId, accountId,
                    lich.getTrangThai(), lich.getDepositAmount());
        }
        if (paidAmt == null || paidAmt.compareTo(BigDecimal.ZERO) == 0) {
            paidAmt = lich.getDepositAmount();
        }
        if (paidAmt == null) {
            paidAmt = BigDecimal.ZERO;
        }

        preview.amountPaid = paidAmt;
        preview.paid = paidAmt.compareTo(BigDecimal.ZERO) > 0;
        preview.paymentStatus = preview.paid ? "PAID" : "UNPAID";
        preview.paymentMethod = lich.getPaymentMethodConfirmed() != null
                ? lich.getPaymentMethodConfirmed()
                : (preview.paid ? "PayOS" : "Tiền mặt");

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime bookingStart = LocalDateTime.of(lich.getNgayDat(), lich.getGioBatDau());
        double hoursBeforeStart = java.time.Duration.between(now, bookingStart).toMinutes() / 60.0;
        preview.hoursBeforeStart = Math.round(hoursBeforeStart * 10.0) / 10.0;

        CancelDecision.CancelType decision = CancelDecision.decide(now, bookingStart, Constants.LATE_CANCEL_HOURS, Constants.MID_CANCEL_HOURS);

        if (hoursBeforeStart < 0) {
            preview.cancellationAllowed = false;
            preview.refundEligible = false;
            preview.cancellationFee = paidAmt;
            preview.refundableAmount = BigDecimal.ZERO;
            preview.reputationPenalty = Math.abs(Constants.CANCEL_PENALTY_UNDER_6H);
            preview.policyMessage = "Đơn đã qua giờ bắt đầu, không thể hủy hoàn tiền.";
        } else if (decision == CancelDecision.CancelType.EARLY_CANCEL) {
            preview.reputationPenalty = Math.abs(Constants.CANCEL_PENALTY_24H_PLUS);
            preview.cancellationFee = BigDecimal.ZERO;
            preview.refundableAmount = paidAmt;
            preview.policyMessage = "Hủy trước 24 giờ trước giờ bắt đầu (Miễn phí hủy, hoàn 100%).";
        } else if (decision == CancelDecision.CancelType.MID_CANCEL) {
            preview.reputationPenalty = Math.abs(Constants.CANCEL_PENALTY_6H_TO_24H);
            preview.cancellationFee = BigDecimal.ZERO;
            preview.refundableAmount = paidAmt;
            preview.policyMessage = "Hủy từ 6 đến 24 giờ trước giờ bắt đầu (Trừ 5 điểm uy tín, hoàn 100%).";
        } else {
            preview.reputationPenalty = Math.abs(Constants.CANCEL_PENALTY_UNDER_6H);
            preview.cancellationFee = paidAmt.multiply(new BigDecimal("0.10")).setScale(0, java.math.RoundingMode.HALF_UP);
            preview.refundableAmount = paidAmt.subtract(preview.cancellationFee);
            preview.policyMessage = "Hủy dưới 6 giờ trước giờ bắt đầu (Trừ 10 điểm uy tín, phí giữ lại 10%).";
        }

        preview.refundEligible = preview.paid && preview.cancellationAllowed && preview.refundableAmount.compareTo(BigDecimal.ZERO) > 0;

        org.example.dao.HoanTienDAO htDAO = new org.example.dao.impl.HoanTienDAOImpl();
        org.example.model.Hoantien activeHt = htDAO.findActiveByDatSanId(datSanId);
        if (activeHt != null) {
            preview.refundAlreadyExists = true;
            preview.existingHoanTienId = activeHt.getHoanTienId();
        }

        preview.success = true;
        preview.message = preview.refundEligible
                ? "Booking đủ điều kiện gửi yêu cầu hoàn tiền."
                : (preview.paid ? "Booking đã thanh toán nhưng không đủ điều kiện hoàn tiền." : "Booking chưa thanh toán.");
        return preview;
    }

    public CancelResult cancelByCustomer(int datSanId, int accountId, String reason,
                                          HttpServletRequest req, TaiKhoan actor) {
        Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
        if (lich == null) {
            return CancelResult.fail("Không tìm thấy đơn đặt sân.");
        }
        if (lich.getAccountId() == null || lich.getAccountId() != accountId) {
            logger.warn("IDOR attempt: AccountID={} co huy don ID={} cua AccountID={}",
                    accountId, datSanId, lich.getAccountId());
            return CancelResult.fail("Bạn không có quyền hủy đơn này.");
        }
        if (!isCancellableStatus(lich.getTrangThai())) {
            return CancelResult.fail("Chỉ có thể hủy đơn đang ở trạng thái 'Chờ xác nhận', 'Đã xác nhận' hoặc " +
                    "'Chờ thanh toán'. Đơn của bạn hiện đang ở trạng thái '" + lich.getTrangThai() + "'.");
        }
        if (Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(lich.getTrangThai())
                && org.example.util.TimeUtil.isPastUtc(lich.getHoldExpiresAt())) {
            return CancelResult.fail("Đơn giữ chỗ đã hết hạn, không thể hủy (đã tự động giải phóng).");
        }

        CancellationPreview preview = calculatePreview(datSanId, accountId);
        if (!preview.success || !preview.cancellationAllowed) {
            return CancelResult.fail(preview.message != null && !preview.message.isBlank() ? preview.message : "Không thể hủy đơn đặt sân.");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime bookingStart = LocalDateTime.of(lich.getNgayDat(), lich.getGioBatDau());
        CancelDecision.CancelType decision = CancelDecision.decide(now, bookingStart, Constants.LATE_CANCEL_HOURS, Constants.MID_CANCEL_HOURS);
        String cancelType;
        if (decision == CancelDecision.CancelType.LATE_CANCEL) {
            cancelType = Constants.CANCEL_TYPE_LATE;
        } else if (decision == CancelDecision.CancelType.MID_CANCEL) {
            cancelType = Constants.CANCEL_TYPE_MID;
        } else {
            cancelType = Constants.CANCEL_TYPE_EARLY;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            Integer newScore = null;
            int createdHoanTienId = 0;
            try {
                int rows = lichDatSanDAO.cancelByCustomer(conn, datSanId, accountId, cancelType, reason);
                if (rows == 0) {
                    conn.rollback();
                    return CancelResult.alreadyDone("Booking đã được hủy trước đó hoặc không còn ở trạng thái có thể hủy.");
                }
                if (decision == CancelDecision.CancelType.LATE_CANCEL) {
                    newScore = CustomerReputationService.applyDelta(conn, accountId, datSanId,
                            Constants.REPUTATION_ACTION_LATE_CANCEL, Constants.CANCEL_PENALTY_UNDER_6H,
                            "Khách hủy sát giờ (dưới " + Constants.LATE_CANCEL_HOURS + " tiếng trước giờ chơi)",
                            accountId, AuditLogService.getClientIp(req));
                } else if (decision == CancelDecision.CancelType.MID_CANCEL) {
                    newScore = CustomerReputationService.applyDelta(conn, accountId, datSanId,
                            Constants.REPUTATION_ACTION_CANCEL_6_TO_24, Constants.CANCEL_PENALTY_6H_TO_24H,
                            "Khách hủy từ 6 đến dưới 24 giờ trước giờ chơi",
                            accountId, AuditLogService.getClientIp(req));
                }

                if (preview.paid && preview.refundEligible && preview.refundableAmount.compareTo(BigDecimal.ZERO) > 0) {
                    int hoaDonId = RefundService.findPaidHoaDonId(datSanId);
                    Integer coSoId = RefundService.findCoSoIdByDatSanId(datSanId);
                    RefundService.RefundResult rr = refundService.createRefund(conn, hoaDonId > 0 ? hoaDonId : 0, datSanId,
                            coSoId != null ? coSoId : 0, accountId,
                            preview.refundableAmount, preview.amountPaid, reason != null && !reason.isBlank() ? reason.trim() : "Khách hủy đơn đặt sân");
                    if (rr.success && rr.hoanTienId != null) {
                        createdHoanTienId = rr.hoanTienId;
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }

            boolean isPenalized = (decision != CancelDecision.CancelType.EARLY_CANCEL);
            AuditLogService.log(req, actor, AuditLogService.ACTION_CANCEL, AuditLogService.ENTITY_DAT_SAN,
                    String.valueOf(datSanId), "Đơn đặt sân #" + datSanId,
                    "Khách hủy sân (" + cancelType + ")"
                            + (reason != null && !reason.isBlank() ? " - Lý do: " + reason.trim() : "")
                            + (createdHoanTienId > 0 ? " | HoanTien #" + createdHoanTienId : ""));

            notificationService.notifyBookingCancelled(accountId, datSanId);
            if (createdHoanTienId > 0) {
                refundService.notifyRefundCreated(accountId, createdHoanTienId);
            }

            String message;
            if (createdHoanTienId > 0) {
                message = "Đã hủy đơn #" + datSanId + ". Yêu cầu hoàn tiền #" + createdHoanTienId
                        + " đã được tạo. Vui lòng kiểm tra và bổ sung thông tin ngân hàng.";
            } else if (preview.paid && !preview.refundEligible) {
                message = "Đã hủy đơn đặt sân #" + datSanId + ". Đơn của bạn không đủ điều kiện hoàn tiền theo chính sách.";
            } else if (decision == CancelDecision.CancelType.LATE_CANCEL) {
                message = "Bạn đã hủy sát giờ (dưới 6 tiếng). Điểm uy tín của bạn bị trừ "
                        + Math.abs(Constants.CANCEL_PENALTY_UNDER_6H) + " điểm.";
            } else if (decision == CancelDecision.CancelType.MID_CANCEL) {
                message = "Bạn đã hủy trước 6h đến 24h. Điểm uy tín của bạn bị trừ "
                        + Math.abs(Constants.CANCEL_PENALTY_6H_TO_24H) + " điểm.";
            } else {
                message = "Đã hủy đơn đặt sân #" + datSanId + " thành công.";
            }
            return CancelResult.ok(isPenalized, message, newScore, createdHoanTienId > 0 ? createdHoanTienId : null,
                    preview.refundableAmount, preview.amountPaid, preview.cancellationFee);
        } catch (SQLException e) {
            logger.error("Loi khi huy booking #{} cho AccountID={}: {}", datSanId, accountId, e.getMessage(), e);
            return CancelResult.fail("Hệ thống gặp lỗi khi hủy đơn. Vui lòng thử lại.");
        }
    }
}
