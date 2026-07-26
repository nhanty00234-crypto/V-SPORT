package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.HoanTienDAO;
import org.example.dao.impl.HoanTienDAOImpl;
import org.example.model.Hoantien;
import org.example.service.AuditLogService;
import org.example.util.DBUtil;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Quản lý toàn bộ vòng đời hoàn tiền.
 * State machine: Chờ xử lý → Đã duyệt → Đã hoàn tiền
 *                              └─────────→ Từ chối
 */
public class RefundService {

    private static final Logger logger = LogManager.getLogger(RefundService.class);

    public static final String TRANG_THAI_CHO_XU_LY = "Chờ xử lý";
    public static final String TRANG_THAI_DA_DUYET   = "Đã duyệt";
    public static final String TRANG_THAI_DA_HOAN    = "Đã hoàn tiền";
    public static final String TRANG_THAI_TU_CHOI    = "Từ chối";

    private final HoanTienDAO hoanTienDAO;
    private final NotificationService notificationService;

    public RefundService() {
        this(new HoanTienDAOImpl(), new NotificationService());
    }

    public RefundService(HoanTienDAO hoanTienDAO, NotificationService notificationService) {
        this.hoanTienDAO = hoanTienDAO;
        this.notificationService = notificationService;
    }

    public static class RefundResult {
        public final boolean success;
        public final String message;
        public final Integer hoanTienId;

        private RefundResult(boolean success, String message, Integer hoanTienId) {
            this.success = success;
            this.message = message;
            this.hoanTienId = hoanTienId;
        }

        public static RefundResult ok(int id, String msg) { return new RefundResult(true, msg, id); }
        public static RefundResult fail(String msg) { return new RefundResult(false, msg, null); }
    }

    /**
     * Tạo yêu cầu hoàn tiền sau khi booking đã bị hủy và có hóa đơn đã thanh toán.
     * Idempotent: nếu đã có yêu cầu cho hoaDonId này thì không tạo thêm.
     * Gọi trong transaction của BookingCancellationService (conn được truyền vào).
     *
     * @param conn  connection đang trong transaction — KHÔNG commit/rollback ở đây
     */
    public RefundResult createRefund(Connection conn, int hoaDonId, int accountId,
                                      BigDecimal soTienHoan, String lyDo) throws SQLException {
        if (hoanTienDAO.existsByHoaDonId(hoaDonId)) {
            // Idempotent — lấy ID của bản ghi đã tồn tại để trả về
            logger.info("HoaDonID={} đã có yêu cầu hoàn tiền, bỏ qua tạo mới", hoaDonId);
            return RefundResult.ok(0, "Yêu cầu hoàn tiền đã tồn tại.");
        }

        Hoantien ht = new Hoantien();
        ht.setHoaDonId(hoaDonId);
        ht.setAccountId(accountId);
        ht.setSoTienHoan(soTienHoan);
        ht.setLyDo(lyDo);
        ht.setTrangThai(TRANG_THAI_CHO_XU_LY);

        int id = hoanTienDAO.insert(conn, ht);
        if (id <= 0) {
            return RefundResult.fail("Không tạo được yêu cầu hoàn tiền.");
        }
        return RefundResult.ok(id, "Yêu cầu hoàn tiền #" + id + " đã được tạo.");
    }

    /** Gửi notification sau khi transaction đã commit (gọi bên ngoài transaction). */
    public void notifyRefundCreated(int accountId, int hoanTienId) {
        notificationService.notifyRefundRequested(accountId, hoanTienId);
    }

    /** Manager duyệt yêu cầu hoàn tiền. CoSoID phải được xác minh trước khi gọi. */
    public RefundResult approve(int hoanTienId, int managerAccountId, String ghiChu,
                                 HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findById(hoanTienId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền.");

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, TRANG_THAI_DA_DUYET,
                managerAccountId, ghiChu, null);
        if (!ok) return RefundResult.fail("Không thể duyệt — trạng thái không hợp lệ hoặc đã thay đổi.");

        AuditLogService.log(req, null, "APPROVE_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Manager duyệt hoàn tiền. Ghi chú: " + (ghiChu != null ? ghiChu : ""));

        notificationService.notifyRefundApproved(ht.getAccountId(), hoanTienId,
                ht.getSoTienHoan().toPlainString());
        return RefundResult.ok(hoanTienId, "Đã duyệt yêu cầu hoàn tiền #" + hoanTienId);
    }

    /** Manager từ chối yêu cầu hoàn tiền. */
    public RefundResult reject(int hoanTienId, int managerAccountId, String lyDo,
                                HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findById(hoanTienId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền.");

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, TRANG_THAI_TU_CHOI,
                managerAccountId, lyDo, null);
        if (!ok) return RefundResult.fail("Không thể từ chối — trạng thái không hợp lệ.");

        AuditLogService.log(req, null, "REJECT_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Manager từ chối: " + (lyDo != null ? lyDo : ""));

        notificationService.notifyRefundRejected(ht.getAccountId(), hoanTienId, lyDo);
        return RefundResult.ok(hoanTienId, "Đã từ chối yêu cầu hoàn tiền #" + hoanTienId);
    }

    /** Manager xác nhận đã chuyển khoản thành công. */
    public RefundResult confirmCompleted(int hoanTienId, int managerAccountId,
                                          String maGiaoDich, String ghiChu,
                                          HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findById(hoanTienId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền.");

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, TRANG_THAI_DA_HOAN,
                managerAccountId, ghiChu, maGiaoDich);
        if (!ok) return RefundResult.fail("Không thể xác nhận — trạng thái phải là 'Đã duyệt'.");

        AuditLogService.log(req, null, "COMPLETE_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Hoàn tiền thành công. Mã GD: " + (maGiaoDich != null ? maGiaoDich : ""));

        notificationService.notifyRefundCompleted(ht.getAccountId(), hoanTienId,
                ht.getSoTienHoan().toPlainString());
        return RefundResult.ok(hoanTienId, "Đã xác nhận hoàn tiền #" + hoanTienId);
    }

    public Hoantien findById(int hoanTienId) {
        return hoanTienDAO.findById(hoanTienId);
    }

    public List<Hoantien> getByCoSo(int coSoId, int page) {
        return hoanTienDAO.findByCoSoId(coSoId, page, 20);
    }

    public List<Hoantien> getByCustomer(int accountId, int page) {
        return hoanTienDAO.findByAccountId(accountId, page, 20);
    }

    /**
     * Đọc số tiền hóa đơn từ DB (không trust client).
     * Trả về null nếu hóa đơn không tồn tại / chưa thanh toán PayOS.
     */
    public static BigDecimal loadPaidAmount(int hoaDonId) {
        String sql = "SELECT TongThanhToan FROM HoaDon " +
                     "WHERE HoaDonID = ? AND TrangThaiThanhToan = N'Đã thanh toán'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double v = rs.getDouble("TongThanhToan");
                    return BigDecimal.valueOf(v);
                }
            }
        } catch (SQLException e) {
            logger.error("loadPaidAmount hoaDonId={}: {}", hoaDonId, e.getMessage(), e);
        }
        return null;
    }

    /**
     * Lấy HoaDonID đã thanh toán từ DatSanID — không trust tham số client.
     * Trả về -1 nếu không tìm thấy.
     */
    public static int findPaidHoaDonId(int datSanId) {
        String sql = "SELECT HoaDonID FROM HoaDon " +
                     "WHERE DatSanID = ? AND TrangThaiThanhToan = N'Đã thanh toán' " +
                     "AND LoaiHoaDon IS NULL OR LoaiHoaDon = N'Đặt sân'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("HoaDonID");
            }
        } catch (SQLException e) {
            logger.error("findPaidHoaDonId datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return -1;
    }
}
