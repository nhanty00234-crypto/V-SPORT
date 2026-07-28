package org.example.service;

import org.example.dao.ThongBaoDAO;
import org.example.dao.impl.ThongBaoDAOImpl;
import org.example.model.ThongBao;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.Date;
import java.util.List;

/**
 * Service gửi và quản lý thông báo cho mọi role.
 * Mọi nghiệp vụ tạo ThongBao phải đi qua đây — không tạo trực tiếp qua DAO từ Servlet.
 */
public class NotificationService {

    private static final Logger logger = LogManager.getLogger(NotificationService.class);
    private static final int DEFAULT_PAGE_SIZE = 20;

    private final ThongBaoDAO dao;

    public NotificationService() {
        this(new ThongBaoDAOImpl());
    }

    public NotificationService(ThongBaoDAO dao) {
        this.dao = dao;
    }

    /**
     * Tạo thông báo cho một tài khoản.
     * Nếu maBanGhi khác null, kiểm tra trùng (loai + maBanGhi) để tránh tạo duplicate khi retry.
     *
     * @return ThongBaoID được tạo, hoặc 0 nếu thất bại / đã tồn tại
     */
    public int sendNotification(int accountId, String tieuDe, String noiDung,
                                String loaiThongBao, String maBanGhi, String duongDan) {
        logger.info("NOTIFICATION_INSERT_START eventType={} accountId={} recordId={} path={}",
                loaiThongBao, accountId, maBanGhi, duongDan);

        if (maBanGhi != null && dao.existsByAccountIdAndLoaiAndMaBanGhi(accountId, loaiThongBao, maBanGhi)) {
            logger.info("NOTIFICATION_INSERT_IDEMPOTENT_SKIPPED accountId={} eventType={} recordId={}",
                    accountId, loaiThongBao, maBanGhi);
            return 1;
        }

        ThongBao tb = new ThongBao();
        tb.setAccountId(accountId);
        tb.setTieuDe(tieuDe);
        tb.setNoiDung(noiDung);
        tb.setLoaiThongBao(loaiThongBao);
        tb.setDaDoc(false);
        tb.setThoiGianGui(new Date());
        tb.setMaBanGhi(maBanGhi);
        tb.setDuongDan(duongDan);

        int id = dao.insert(tb);
        if (id > 0 || id == -1) {
            int returnId = id > 0 ? id : 1;
            logger.info("NOTIFICATION_INSERT_SUCCESS notificationId={} accountId={} eventType={}",
                    returnId, accountId, loaiThongBao);
            return returnId;
        } else {
            logger.error("NOTIFICATION_INSERT_FAILED accountId={} eventType={} recordId={}",
                    accountId, loaiThongBao, maBanGhi);
            return 0;
        }
    }

    /** Lấy N thông báo mới nhất (TOP limit) cho header dropdown. */
    public List<ThongBao> getLatestNotifications(int accountId, int limit) {
        return dao.findLatestByAccountId(accountId, limit);
    }

    /** Lấy danh sách thông báo có phân trang mặc định. */
    public List<ThongBao> getNotifications(int accountId, int page) {
        return dao.findByAccountId(accountId, page, DEFAULT_PAGE_SIZE);
    }

    /** Lấy danh sách thông báo có phân trang tùy chỉnh. */
    public List<ThongBao> getNotifications(int accountId, int page, int pageSize) {
        return dao.findByAccountId(accountId, page, pageSize);
    }

    /** Đếm tổng số thông báo chưa bị xóa. */
    public int countTotal(int accountId) {
        return dao.countByAccountId(accountId);
    }

    /** Đếm số chưa đọc. */
    public int countUnread(int accountId) {
        return dao.countUnread(accountId);
    }

    /**
     * Đánh dấu một thông báo đã đọc — kiểm tra owner để chống IDOR.
     *
     * @return true nếu thành công, false nếu không tìm thấy hoặc không phải owner
     */
    public boolean markAsRead(int thongBaoId, int accountId) {
        return dao.markAsRead(thongBaoId, accountId);
    }

    /**
     * Đánh dấu tất cả thông báo chưa đọc là đã đọc.
     *
     * @return số bản ghi được cập nhật
     */
    public int markAllAsRead(int accountId) {
        return dao.markAllAsRead(accountId);
    }

    // -----------------------------------------------------------------------
    // Các helper gửi thông báo nghiệp vụ chuẩn hóa cho Customer
    // -----------------------------------------------------------------------

    public void notifyBookingCreated(int accountId, int datSanId) {
        notifyBookingCreated(accountId, datSanId, false);
    }

    public void notifyBookingCreated(int accountId, int datSanId, boolean isPayOS) {
        String tieuDe = isPayOS ? "Yêu cầu đặt sân đã được tạo" : "Yêu cầu đặt sân đã được gửi";
        String noiDung = isPayOS
                ? "Đơn đặt sân #" + datSanId + " đã được tạo. Vui lòng hoàn tất thanh toán để giữ chỗ."
                : "Đơn đặt sân #" + datSanId + " đã được tạo và đang chờ cơ sở xác nhận.";
        sendNotification(accountId,
                tieuDe,
                noiDung,
                "BOOKING_CREATED",
                String.valueOf(datSanId),
                "/customer/dat-san?openHistory=true&datSanId=" + datSanId);
    }

    public void notifyBookingConfirmed(int accountId, int datSanId) {
        sendNotification(accountId,
                "Đơn đặt sân đã được xác nhận",
                "Đơn đặt sân #" + datSanId + " của bạn đã được xác nhận. Hẹn gặp bạn tại sân!",
                "BOOKING_CONFIRMED",
                String.valueOf(datSanId),
                "/customer/dat-san?openHistory=true&datSanId=" + datSanId);
    }

    public void notifyBookingRejected(int accountId, int datSanId, String lyDo) {
        sendNotification(accountId,
                "Đơn đặt sân bị từ chối",
                "Đơn đặt sân #" + datSanId + " bị từ chối" + (lyDo != null && !lyDo.trim().isEmpty() ? ": " + lyDo.trim() : "."),
                "BOOKING_REJECTED",
                String.valueOf(datSanId),
                "/customer/dat-san?openHistory=true&datSanId=" + datSanId);
    }

    public void notifyBookingCancelled(int accountId, int datSanId) {
        sendNotification(accountId,
                "Đơn đặt sân đã bị hủy",
                "Đơn đặt sân #" + datSanId + " đã được hủy thành công.",
                "BOOKING_CANCELLED",
                String.valueOf(datSanId),
                "/customer/dat-san?openHistory=true&datSanId=" + datSanId);
    }

    public void notifyPaymentSuccess(int accountId, int hoaDonId, String soTien) {
        sendNotification(accountId,
                "Thanh toán thành công",
                "Thanh toán " + soTien + " VND cho hóa đơn #" + hoaDonId + " đã được ghi nhận.",
                "PAYMENT_SUCCESS",
                String.valueOf(hoaDonId),
                "/customer/dat-san?openHistory=true");
    }

    public void notifyHoldExpired(int accountId, int datSanId) {
        sendNotification(accountId,
                "Giữ chỗ đã hết hạn",
                "Giữ chỗ cho đơn #" + datSanId + " đã hết hạn. Sân đã được mở lại.",
                "BOOKING_CANCELLED",
                String.valueOf(datSanId),
                "/customer/dat-san");
    }

    public void notifyRefundRequested(int accountId, int hoanTienId) {
        sendNotification(accountId,
                "Yêu cầu hoàn tiền đã được tạo",
                "Yêu cầu hoàn tiền #" + hoanTienId + " của bạn đang được xử lý.",
                "REFUND_REQUESTED",
                String.valueOf(hoanTienId),
                "/customer/dat-san?openHistory=true");
    }

    public void notifyRefundApproved(int accountId, int hoanTienId, String soTien) {
        sendNotification(accountId,
                "Yêu cầu hoàn tiền đã được duyệt",
                "Yêu cầu hoàn tiền #" + hoanTienId + " (" + soTien + " VND) đã được duyệt.",
                "REFUND_APPROVED",
                String.valueOf(hoanTienId),
                "/customer/dat-san?openHistory=true");
    }

    public void notifyRefundRejected(int accountId, int hoanTienId, String lyDo) {
        sendNotification(accountId,
                "Yêu cầu hoàn tiền bị từ chối",
                "Yêu cầu hoàn tiền #" + hoanTienId + " bị từ chối" + (lyDo != null && !lyDo.trim().isEmpty() ? ": " + lyDo.trim() : "."),
                "REFUND_REJECTED",
                String.valueOf(hoanTienId),
                "/customer/dat-san?openHistory=true");
    }

    public void notifyRefundCompleted(int accountId, int hoanTienId, String soTien) {
        sendNotification(accountId,
                "Hoàn tiền thành công",
                "Chúng tôi đã hoàn " + soTien + " VND cho yêu cầu #" + hoanTienId + ". Vui lòng kiểm tra tài khoản ngân hàng.",
                "REFUND_COMPLETED",
                String.valueOf(hoanTienId),
                "/customer/dat-san?openHistory=true");
    }

    public void notifyRefundNeedMoreInfo(int accountId, int hoanTienId, String ghiChu) {
        sendNotification(accountId,
                "Cần bổ sung thông tin hoàn tiền",
                "Yêu cầu hoàn tiền #" + hoanTienId + " cần bạn bổ sung thông tin ngân hàng"
                        + (ghiChu != null && !ghiChu.trim().isEmpty() ? ": " + ghiChu.trim() : "."),
                "REFUND_NEED_MORE_INFO",
                String.valueOf(hoanTienId),
                "/customer/hoan-tien");
    }

    public void notifyRefundProcessing(int accountId, int hoanTienId) {
        sendNotification(accountId,
                "Đang xử lý hoàn tiền",
                "Yêu cầu hoàn tiền #" + hoanTienId + " của bạn đang được chuyển khoản.",
                "REFUND_PROCESSING",
                String.valueOf(hoanTienId),
                "/customer/hoan-tien");
    }

    // -----------------------------------------------------------------------
    // Chia tiền nhóm (BillSplit)
    // -----------------------------------------------------------------------

    public void notifyBillSplitCreated(int accountId, int billSplitId) {
        sendNotification(accountId,
                "Đã tạo chia tiền nhóm",
                "Yêu cầu chia tiền nhóm #" + billSplitId + " đã được tạo. Hãy gửi link/QR cho từng người.",
                "BILL_SPLIT_CREATED",
                String.valueOf(billSplitId),
                "/customer/chia-tien-nhom?id=" + billSplitId);
    }

    public void notifyBillSplitSharePaid(int accountId, int billSplitId, String displayName, String soTien) {
        sendNotification(accountId,
                "Có người đã thanh toán phần chia tiền",
                displayName + " đã thanh toán " + soTien + " VND cho nhóm chia tiền #" + billSplitId + ".",
                "BILL_SPLIT_SHARE_PAID",
                String.valueOf(billSplitId) + "_" + displayName.hashCode(),
                "/customer/chia-tien-nhom?id=" + billSplitId);
    }

    public void notifyBillSplitCompleted(int accountId, int billSplitId) {
        sendNotification(accountId,
                "Chia tiền nhóm đã hoàn tất",
                "Tất cả thành viên đã thanh toán xong cho nhóm chia tiền #" + billSplitId + ".",
                "BILL_SPLIT_COMPLETED",
                String.valueOf(billSplitId),
                "/customer/chia-tien-nhom?id=" + billSplitId);
    }
}
