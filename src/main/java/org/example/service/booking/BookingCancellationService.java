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

    public static class CancelResult {
        public final boolean success;
        public final boolean alreadyCancelled;
        public final boolean lateCancel;
        public final String message;
        public final Integer newReputationScore;

        private CancelResult(boolean success, boolean alreadyCancelled, boolean lateCancel,
                              String message, Integer newReputationScore) {
            this.success = success;
            this.alreadyCancelled = alreadyCancelled;
            this.lateCancel = lateCancel;
            this.message = message;
            this.newReputationScore = newReputationScore;
        }

        static CancelResult ok(boolean lateCancel, String message, Integer newReputationScore) {
            return new CancelResult(true, false, lateCancel, message, newReputationScore);
        }

        static CancelResult alreadyDone(String message) {
            return new CancelResult(false, true, false, message, null);
        }

        static CancelResult fail(String message) {
            return new CancelResult(false, false, false, message, null);
        }
    }

    /** Trạng thái nguồn được phép hủy bởi khách (mục 10 spec). Logic thuần — test riêng, không đụng DB. */
    public static boolean isCancellableStatus(String trangThai) {
        return Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN.equals(trangThai)
                || Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(trangThai)
                || Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai);
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
        // Booking đã thanh toán PayOS → cho phép hủy + tạo yêu cầu hoàn tiền tự động
        final boolean isPaidPayos = Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(lich.getTrangThai())
                && (Constants.PT_PAYOS.equals(lich.getPaymentMethodConfirmed())
                    || (lich.getGhiChu() != null && lich.getGhiChu().contains(Constants.PAYOS_PAID_GHI_CHU_MARKER)));
        if (!isCancellableStatus(lich.getTrangThai())) {
            return CancelResult.fail("Chỉ có thể hủy đơn đang ở trạng thái 'Chờ xác nhận', 'Đã xác nhận' hoặc " +
                    "'Chờ thanh toán'. Đơn của bạn hiện đang ở trạng thái '" + lich.getTrangThai() + "'.");
        }
        // HoldExpiresAt lưu UTC → so sánh bằng Instant UTC (TimeUtil), không dùng giờ JVM/VN.
        // (NgayDat/GioBatDau bên dưới là giờ theo lịch địa phương — giữ nguyên so sánh local.)
        if (Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(lich.getTrangThai())
                && org.example.util.TimeUtil.isPastUtc(lich.getHoldExpiresAt())) {
            return CancelResult.fail("Đơn giữ chỗ đã hết hạn, không thể hủy (đã tự động giải phóng).");
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
                if (isPaidPayos) {
                    // Tìm hóa đơn đã thanh toán (không trust client) và tạo refund trong cùng transaction
                    int hoaDonId = RefundService.findPaidHoaDonId(datSanId);
                    if (hoaDonId > 0) {
                        BigDecimal soTien = RefundService.loadPaidAmount(hoaDonId);
                        if (soTien != null) {
                            RefundService.RefundResult rr = refundService.createRefund(conn, hoaDonId, accountId,
                                    soTien, reason != null ? reason.trim() : "Khách hủy đơn");
                            if (rr.success) createdHoanTienId = rr.hoanTienId != null ? rr.hoanTienId : 0;
                        }
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
<<<<<<< HEAD
                    (isLate ? "Khách hủy sát giờ (Late Cancel)" : "Khách hủy sớm (Early Cancel)")
                            + (reason != null && !reason.isBlank() ? " - Lý do: " + reason.trim() : "")
                            + (createdHoanTienId > 0 ? " | HoanTien #" + createdHoanTienId : ""));

            // Gửi thông báo sau khi commit
            notificationService.notifyBookingCancelled(accountId, datSanId);
            if (createdHoanTienId > 0) {
                refundService.notifyRefundCreated(accountId, createdHoanTienId);
            }

            String message;
            if (isPaidPayos && createdHoanTienId > 0) {
                message = "Đã hủy đơn #" + datSanId + ". Yêu cầu hoàn tiền #" + createdHoanTienId
                        + " đã được tạo và đang chờ xử lý.";
            } else if (isLate) {
                message = "Bạn đã hủy sát giờ. Hệ thống đã ghi nhận và điểm uy tín của bạn bị trừ "
                        + Math.abs(Constants.LATE_CANCEL_PENALTY) + " điểm.";
            } else {
                message = "Đã hủy đơn đặt sân #" + datSanId + " thành công.";
            }
            return CancelResult.ok(isLate, message, newScore);
=======
                    "Khách hủy sân (" + cancelType + ")"
                            + (reason != null && !reason.isBlank() ? " - Lý do: " + reason.trim() : ""));

            String message;
            if (decision == CancelDecision.CancelType.LATE_CANCEL) {
                message = "Bạn đã hủy sát giờ (dưới 6 tiếng). Điểm uy tín của bạn bị trừ "
                        + Math.abs(Constants.CANCEL_PENALTY_UNDER_6H) + " điểm.";
            } else if (decision == CancelDecision.CancelType.MID_CANCEL) {
                message = "Bạn đã hủy trước 6h đến 24h. Điểm uy tín của bạn bị trừ "
                        + Math.abs(Constants.CANCEL_PENALTY_6H_TO_24H) + " điểm.";
            } else {
                message = "Đã hủy đơn đặt sân #" + datSanId + " thành công.";
            }
            return CancelResult.ok(isPenalized, message, newScore);
>>>>>>> fix/teacher-review-remediation
        } catch (SQLException e) {
            logger.error("Loi khi huy booking #{} cho AccountID={}: {}", datSanId, accountId, e.getMessage(), e);
            return CancelResult.fail("Hệ thống gặp lỗi khi hủy đơn. Vui lòng thử lại.");
        }
    }
}
