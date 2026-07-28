package org.example.service.billsplit;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.NhomChiaTienChiTietDAO;
import org.example.dao.NhomChiaTienDAO;
import org.example.dao.impl.NhomChiaTienChiTietDAOImpl;
import org.example.dao.impl.NhomChiaTienDAOImpl;
import org.example.model.NhomChiaTien;
import org.example.model.NhomChiaTienChiTiet;
import org.example.service.NotificationService;
import org.example.util.BillSplitShareStatus;
import org.example.util.BillSplitStatus;
import org.example.util.BillSplitType;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.example.util.ShareTokenGenerator;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Chia tiền nhóm (Group Bill Split) — nghiệp vụ Customer, KHÁC HOÀN TOÀN với "Tách hóa đơn
 * dịch vụ" phía Staff (ServiceBillSeparationService/SplitBillServlet, HoaDon.LoaiHoaDon='SPLIT').
 * Không đụng, không đổi tên, không thay thế nghiệp vụ đó.
 *
 * Server luôn tự tính lại từng phần và validate tổng — không bao giờ tin số tiền/participant
 * list gửi từ client JavaScript.
 */
public class BillSplitService {

    private static final Logger logger = LogManager.getLogger(BillSplitService.class);

    private final NhomChiaTienDAO billSplitDAO;
    private final NhomChiaTienChiTietDAO shareDAO;
    private final NotificationService notificationService;

    public BillSplitService() {
        this(new NhomChiaTienDAOImpl(), new NhomChiaTienChiTietDAOImpl(), new NotificationService());
    }

    public BillSplitService(NhomChiaTienDAO billSplitDAO, NhomChiaTienChiTietDAO shareDAO,
                             NotificationService notificationService) {
        this.billSplitDAO = billSplitDAO;
        this.shareDAO = shareDAO;
        this.notificationService = notificationService;
    }

    public static class Result {
        public final boolean success;
        public final String message;
        public final Integer billSplitId;

        private Result(boolean success, String message, Integer billSplitId) {
            this.success = success;
            this.message = message;
            this.billSplitId = billSplitId;
        }

        public static Result ok(int id, String msg) { return new Result(true, msg, id); }
        public static Result fail(String msg) { return new Result(false, msg, null); }
    }

    /** 1 participant nhập từ Customer — accountId có thể null nếu chưa có tài khoản V-SPORT. */
    public static class ParticipantInput {
        public Integer accountId;
        public String displayName;
        public BigDecimal amount; // chỉ dùng khi splitType=CUSTOM, null khi EQUAL

        public ParticipantInput(Integer accountId, String displayName, BigDecimal amount) {
            this.accountId = accountId;
            this.displayName = displayName;
            this.amount = amount;
        }
    }

    /**
     * Tạo BillSplit mới cho một HoaDon. Kiểm tra đầy đủ theo mục 2 spec:
     *  - booking thuộc đúng accountId;
     *  - hóa đơn chưa thanh toán hoàn toàn;
     *  - chưa có BillSplit đang hoạt động cho hóa đơn này.
     * Không trust totalAmount từ client — luôn đọc lại HoaDon.TongThanhToan.
     */
    public Result createSplit(int datSanId, int accountId, String splitType, List<ParticipantInput> participants) {
        if (!BillSplitType.IMPLEMENTED.contains(splitType)) {
            return Result.fail("Chỉ hỗ trợ chia đều (EQUAL) hoặc tùy chỉnh (CUSTOM) ở giai đoạn hiện tại.");
        }
        if (participants == null || participants.size() < 2) {
            return Result.fail("Cần ít nhất 2 người để chia tiền nhóm.");
        }

        BookingInvoiceInfo info = loadBookingInvoiceInfo(datSanId);
        if (info == null) {
            return Result.fail("Không tìm thấy hóa đơn cho đơn đặt sân này.");
        }
        if (info.ownerAccountId != accountId) {
            logger.warn("IDOR attempt: AccountID={} tạo BillSplit cho DatSanID={} của AccountID={}",
                    accountId, datSanId, info.ownerAccountId);
            return Result.fail("Bạn không có quyền chia tiền cho đơn đặt sân này.");
        }
        if (Constants.TRANG_THAI_HOA_DON_DA_TT.equals(info.trangThaiThanhToan)) {
            return Result.fail("Hóa đơn đã thanh toán hoàn toàn, không cần chia tiền.");
        }
        if (!isBookingFinished(datSanId)) {
            return Result.fail("Chỉ có thể chia tiền khi phiên sân đã kết thúc hoặc hóa đơn đã được chốt.");
        }
        if (billSplitDAO.findActiveByHoaDonId(info.hoaDonId) != null) {
            return Result.fail("Hóa đơn này đã có một phiên chia tiền đang hoạt động.");
        }

        BigDecimal totalAmount = BigDecimal.valueOf(info.tongThanhToan).setScale(2, RoundingMode.HALF_UP);
        List<ShareAmount> shareAmounts;
        if (BillSplitType.EQUAL.equals(splitType)) {
            shareAmounts = computeEqualShares(totalAmount, participants);
        } else {
            shareAmounts = validateCustomShares(totalAmount, participants);
            if (shareAmounts == null) {
                return Result.fail(lastValidationError);
            }
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            NhomChiaTien nct = new NhomChiaTien();
            nct.setHoaDonId(info.hoaDonId);
            nct.setDatSanId(datSanId);
            nct.setCreatedByAccountId(accountId);
            nct.setSplitType(splitType);
            nct.setTongTien(totalAmount);
            nct.setTrangThai(BillSplitStatus.ACTIVE);
            int billSplitId = billSplitDAO.insert(conn, nct);
            if (billSplitId <= 0) {
                conn.rollback();
                return Result.fail("Không thể tạo phiên chia tiền.");
            }

            for (ShareAmount sa : shareAmounts) {
                NhomChiaTienChiTiet ct = new NhomChiaTienChiTiet();
                ct.setNhomChiaTienId(billSplitId);
                ct.setAccountId(sa.input.accountId);
                ct.setDisplayName(safeDisplayName(sa.input.displayName));
                ct.setShareToken(ShareTokenGenerator.generate());
                ct.setSoTien(sa.amount);
                ct.setTrangThai(BillSplitShareStatus.PENDING);
                int shareId = shareDAO.insert(conn, ct);
                if (shareId <= 0) {
                    conn.rollback();
                    return Result.fail("Không thể tạo phần chia tiền.");
                }
            }

            conn.commit();
            notificationService.notifyBillSplitCreated(accountId, billSplitId);
            return Result.ok(billSplitId, "Đã tạo chia tiền nhóm #" + billSplitId + " với " + shareAmounts.size() + " phần.");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            logger.error("createSplit datSanId={}: {}", datSanId, e.getMessage(), e);
            return Result.fail("Hệ thống gặp lỗi khi tạo chia tiền nhóm.");
        } finally {
            closeQuietly(conn);
        }
    }

    private String lastValidationError;

    /** EQUAL: chia đều, phần dư do làm tròn cộng vào chủ booking (participant đầu tiên trong danh sách). */
    private List<ShareAmount> computeEqualShares(BigDecimal totalAmount, List<ParticipantInput> participants) {
        int n = participants.size();
        BigDecimal base = totalAmount.divide(BigDecimal.valueOf(n), 2, RoundingMode.DOWN);
        BigDecimal distributed = base.multiply(BigDecimal.valueOf(n));
        BigDecimal remainder = totalAmount.subtract(distributed);

        List<ShareAmount> result = new ArrayList<>();
        for (int i = 0; i < n; i++) {
            BigDecimal amount = base;
            if (i == 0) amount = amount.add(remainder); // chủ booking = participants.get(0) theo contract servlet
            result.add(new ShareAmount(participants.get(i), amount));
        }
        return result;
    }

    /** CUSTOM: kiểm tra mỗi phần > 0, tổng đúng bằng tổng hóa đơn, không trùng/âm. */
    private List<ShareAmount> validateCustomShares(BigDecimal totalAmount, List<ParticipantInput> participants) {
        BigDecimal sum = BigDecimal.ZERO;
        List<ShareAmount> result = new ArrayList<>();
        for (ParticipantInput p : participants) {
            if (p.amount == null || p.amount.signum() <= 0) {
                lastValidationError = "Mỗi phần chia phải lớn hơn 0.";
                return null;
            }
            sum = sum.add(p.amount);
            result.add(new ShareAmount(p, p.amount.setScale(2, RoundingMode.HALF_UP)));
        }
        if (sum.setScale(2, RoundingMode.HALF_UP).compareTo(totalAmount) != 0) {
            lastValidationError = "Tổng các phần (" + sum + ") phải bằng đúng tổng hóa đơn (" + totalAmount + ").";
            return null;
        }
        return result;
    }

    private static class ShareAmount {
        final ParticipantInput input;
        final BigDecimal amount;
        ShareAmount(ParticipantInput input, BigDecimal amount) {
            this.input = input;
            this.amount = amount;
        }
    }

    /** Chủ booking hủy BillSplit — chỉ khi chưa ai thanh toán (mục 11 spec). Vô hiệu hóa toàn bộ token cũ. */
    public Result cancelSplit(int billSplitId, int accountId) {
        NhomChiaTien nct = billSplitDAO.findByIdAndCreatedBy(billSplitId, accountId);
        if (nct == null) return Result.fail("Không tìm thấy phiên chia tiền.");
        if (!BillSplitStatus.CANCELLABLE.contains(nct.getTrangThai())) {
            return Result.fail("Đã có người thanh toán, không thể hủy phiên chia tiền này.");
        }
        if (shareDAO.countPaidByNhomChiaTienId(billSplitId) > 0) {
            return Result.fail("Đã có người thanh toán, không thể hủy phiên chia tiền này.");
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            boolean ok = billSplitDAO.updateTrangThai(conn, billSplitId, nct.getTrangThai(), BillSplitStatus.CANCELLED);
            if (!ok) {
                conn.rollback();
                return Result.fail("Không thể hủy — trạng thái đã thay đổi.");
            }
            shareDAO.cancelAllByNhomChiaTienId(conn, billSplitId);
            conn.commit();
            return Result.ok(billSplitId, "Đã hủy phiên chia tiền #" + billSplitId + ". Các link chia sẻ đã bị vô hiệu hóa.");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            logger.error("cancelSplit billSplitId={}: {}", billSplitId, e.getMessage(), e);
            return Result.fail("Hệ thống gặp lỗi khi hủy phiên chia tiền.");
        } finally {
            closeQuietly(conn);
        }
    }

    /**
     * Đánh dấu 1 Share đã thanh toán trong transaction, cập nhật BillSplit + hóa đơn gốc.
     * Dùng chung cho cả webhook PayOS lẫn Staff xác nhận tại sân.
     */
    public Result markSharePaid(int shareId, String paymentMethod, String paymentTransactionId,
                                 Integer payerAccountId, Integer confirmedByStaffId) {
        NhomChiaTienChiTiet ct = shareDAO.findById(shareId);
        if (ct == null) return Result.fail("Không tìm thấy phần chia tiền.");
        if (!BillSplitShareStatus.PAYABLE_FROM.contains(ct.getTrangThai())) {
            // Chống thanh toán 2 lần — nếu đã PAID/CANCELLED/EXPIRED thì từ chối rõ ràng, không âm thầm ok.
            return Result.fail("Phần chia tiền này đã được xử lý trước đó (trạng thái: " + ct.getTrangThai() + ").");
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            boolean ok = shareDAO.updateTrangThai(conn, shareId, ct.getTrangThai(), BillSplitShareStatus.PAID,
                    paymentMethod, paymentTransactionId, payerAccountId, confirmedByStaffId);
            if (!ok) {
                conn.rollback();
                return Result.fail("Không thể xác nhận thanh toán — đã được xử lý ở nơi khác (chống double payment).");
            }

            NhomChiaTien nct = billSplitDAO.findById(ct.getNhomChiaTienId());
            if (nct == null) {
                conn.rollback();
                return Result.fail("Không tìm thấy phiên chia tiền tương ứng.");
            }

            BigDecimal totalPaid = shareDAO.sumPaidByNhomChiaTienId(ct.getNhomChiaTienId());
            int totalShares = shareDAO.countByNhomChiaTienId(ct.getNhomChiaTienId());
            int paidShares = shareDAO.countPaidByNhomChiaTienId(ct.getNhomChiaTienId());
            boolean fullyPaid = totalPaid.compareTo(nct.getTongTien()) >= 0 || paidShares >= totalShares;

            String newBillSplitStatus = fullyPaid ? BillSplitStatus.PAID : BillSplitStatus.PARTIALLY_PAID;
            billSplitDAO.updateTrangThai(conn, ct.getNhomChiaTienId(), nct.getTrangThai(), newBillSplitStatus);

            // Chỉ đóng hóa đơn khi tổng đã thanh toán bằng đúng tổng phải trả (mục 9 spec).
            updateHoaDonPaymentStatus(conn, nct.getHoaDonId(), fullyPaid);

            conn.commit();

            notificationService.notifyBillSplitSharePaid(nct.getCreatedByAccountId(), nct.getNhomChiaTienId(),
                    ct.getDisplayName(), ct.getSoTien().toPlainString());
            if (fullyPaid) {
                notificationService.notifyBillSplitCompleted(nct.getCreatedByAccountId(), nct.getNhomChiaTienId());
            }
            return Result.ok(nct.getNhomChiaTienId(), "Đã xác nhận thanh toán phần của " + ct.getDisplayName() + ".");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            logger.error("markSharePaid shareId={}: {}", shareId, e.getMessage(), e);
            return Result.fail("Hệ thống gặp lỗi khi xác nhận thanh toán.");
        } finally {
            closeQuietly(conn);
        }
    }

    /** "Thanh toán phần còn lại" — chủ booking trả phần chưa ai thanh toán, server tự tính số tiền tại thời điểm request. */
    public BigDecimal calculateRemainingAmount(int billSplitId) {
        NhomChiaTien nct = billSplitDAO.findById(billSplitId);
        if (nct == null) return BigDecimal.ZERO;
        BigDecimal paid = shareDAO.sumPaidByNhomChiaTienId(billSplitId);
        BigDecimal remaining = nct.getTongTien().subtract(paid);
        return remaining.signum() > 0 ? remaining : BigDecimal.ZERO;
    }

    /**
     * Chủ booking thanh toán toàn bộ phần còn thiếu (mục 10 spec) — hủy các share PENDING/
     * PROCESSING chưa ai trả (chúng đã được gộp vào khoản thanh toán này) và tạo 1 share mới
     * đại diện đúng số tiền còn thiếu tại thời điểm request (không tin amount từ client),
     * gán AccountID = chủ booking. Trả về shareId mới để tiếp tục luồng thanh toán (PayOS/tại sân).
     */
    public Result createRemainingShare(int billSplitId, int accountId) {
        NhomChiaTien nct = billSplitDAO.findByIdAndCreatedBy(billSplitId, accountId);
        if (nct == null) return Result.fail("Không tìm thấy phiên chia tiền.");
        if (BillSplitStatus.isTerminal(nct.getTrangThai())) {
            return Result.fail("Phiên chia tiền đã kết thúc.");
        }
        BigDecimal remaining = calculateRemainingAmount(billSplitId);
        if (remaining.signum() <= 0) {
            return Result.fail("Hóa đơn đã được thanh toán đầy đủ.");
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // Vô hiệu hóa các share cũ chưa ai trả — số tiền của chúng được gộp vào remaining ở trên.
            shareDAO.cancelAllByNhomChiaTienId(conn, billSplitId);

            NhomChiaTienChiTiet ct = new NhomChiaTienChiTiet();
            ct.setNhomChiaTienId(billSplitId);
            ct.setAccountId(accountId);
            ct.setDisplayName("Phần còn lại (chủ booking)");
            ct.setShareToken(ShareTokenGenerator.generate());
            ct.setSoTien(remaining);
            ct.setTrangThai(BillSplitShareStatus.PENDING);
            int shareId = shareDAO.insert(conn, ct);
            if (shareId <= 0) {
                conn.rollback();
                return Result.fail("Không thể tạo phần thanh toán còn lại.");
            }

            conn.commit();
            return Result.ok(shareId, "Đã tạo yêu cầu thanh toán phần còn lại: " + remaining.toPlainString() + " đ.");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            logger.error("createRemainingShare billSplitId={}: {}", billSplitId, e.getMessage(), e);
            return Result.fail("Hệ thống gặp lỗi khi tạo thanh toán phần còn lại.");
        } finally {
            closeQuietly(conn);
        }
    }

    public NhomChiaTien findById(int billSplitId) {
        return billSplitDAO.findById(billSplitId);
    }

    public NhomChiaTien findByIdAndCreatedBy(int billSplitId, int accountId) {
        return billSplitDAO.findByIdAndCreatedBy(billSplitId, accountId);
    }

    public List<NhomChiaTien> findByDatSanId(int datSanId) {
        return billSplitDAO.findByDatSanId(datSanId);
    }

    public List<NhomChiaTienChiTiet> getShares(int billSplitId) {
        return shareDAO.findByNhomChiaTienId(billSplitId);
    }

    public NhomChiaTienChiTiet getShareByToken(String shareToken) {
        return shareDAO.findByShareToken(shareToken);
    }

    public NhomChiaTienChiTiet getShareByIdAndBillSplitId(int shareId, int billSplitId) {
        return shareDAO.findByIdAndNhomChiaTienId(shareId, billSplitId);
    }

    /** Dùng cho Staff xác nhận thanh toán — CoSoID ownership được servlet kiểm tra riêng qua NhomChiaTien.DatSanID. */
    public NhomChiaTienChiTiet getShareById(int shareId) {
        return shareDAO.findById(shareId);
    }

    // -------------------------------------------------------------------------------------

    private static class BookingInvoiceInfo {
        int hoaDonId;
        int ownerAccountId;
        double tongThanhToan;
        String trangThaiThanhToan;
    }

    private BookingInvoiceInfo loadBookingInvoiceInfo(int datSanId) {
        String sql = "SELECT h.HoaDonID, lds.AccountID, h.TongThanhToan, h.TrangThaiThanhToan " +
                     "FROM LichDatSan lds JOIN HoaDon h ON lds.DatSanID = h.DatSanID " +
                     "WHERE lds.DatSanID = ? AND (h.LoaiHoaDon IS NULL OR h.LoaiHoaDon = 'MAIN')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BookingInvoiceInfo info = new BookingInvoiceInfo();
                    info.hoaDonId = rs.getInt("HoaDonID");
                    info.ownerAccountId = rs.getInt("AccountID");
                    info.tongThanhToan = rs.getDouble("TongThanhToan");
                    info.trangThaiThanhToan = rs.getString("TrangThaiThanhToan");
                    return info;
                }
            }
        } catch (SQLException e) {
            logger.error("loadBookingInvoiceInfo datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return null;
    }

    /** Phiên đã kết thúc hoặc hóa đơn đã chốt — dùng LichDatSan.TrangThai/ActualEndAt làm nguồn sự thật. */
    private boolean isBookingFinished(int datSanId) {
        String sql = "SELECT TrangThai, ActualEndAt, GioKetThuc, NgayDat FROM LichDatSan WHERE DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
                String trangThai = rs.getString("TrangThai");
                if (rs.getTimestamp("ActualEndAt") != null) return true;
                if (Constants.TRANG_THAI_DAT_SAN_DA_HOAN_THANH.equals(trangThai)) return true;
                // Fallback: giờ kết thúc theo lịch đã qua.
                java.sql.Date ngayDat = rs.getDate("NgayDat");
                java.sql.Time gioKetThuc = rs.getTime("GioKetThuc");
                if (ngayDat != null && gioKetThuc != null) {
                    java.time.LocalDateTime end = java.time.LocalDateTime.of(ngayDat.toLocalDate(), gioKetThuc.toLocalTime());
                    return end.isBefore(java.time.LocalDateTime.now());
                }
                return false;
            }
        } catch (SQLException e) {
            logger.error("isBookingFinished datSanId={}: {}", datSanId, e.getMessage(), e);
            return false;
        }
    }

    /** Cập nhật TrangThaiThanhToan của HoaDon gốc theo tiến độ chia tiền (mục 9 spec). */
    private void updateHoaDonPaymentStatus(Connection conn, int hoaDonId, boolean fullyPaid) throws SQLException {
        String newStatus = fullyPaid ? Constants.TRANG_THAI_HOA_DON_DA_TT : Constants.TRANG_THAI_HOA_DON_MOT_PHAN;
        String sql = "UPDATE HoaDon SET TrangThaiThanhToan = ? WHERE HoaDonID = ? AND TrangThaiThanhToan <> ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, newStatus);
            ps.setInt(2, hoaDonId);
            ps.setNString(3, Constants.TRANG_THAI_HOA_DON_DA_TT); // không hạ cấp hóa đơn đã full lại về một phần
            ps.executeUpdate();
        }
    }

    private static String safeDisplayName(String s) {
        if (s == null || s.isBlank()) return "Người chơi";
        String t = s.trim();
        return t.length() > 100 ? t.substring(0, 100) : t;
    }

    private static void rollbackQuietly(Connection conn) {
        if (conn == null) return;
        try { conn.rollback(); } catch (SQLException ignored) {}
    }

    private static void closeQuietly(Connection conn) {
        if (conn == null) return;
        try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
    }
}
