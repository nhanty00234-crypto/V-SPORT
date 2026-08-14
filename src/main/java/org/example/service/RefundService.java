package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.HoanTienDAO;
import org.example.dao.impl.HoanTienDAOImpl;
import org.example.model.Hoantien;
import org.example.util.DBUtil;
import org.example.util.RefundStatus;

import jakarta.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Quản lý toàn bộ vòng đời hoàn tiền Customer self-service.
 * State machine (org.example.util.RefundStatus):
 *   CHO_BO_SUNG_THONG_TIN <-> CHO_XU_LY --(duyệt)--> DA_DUYET --(bắt đầu xử lý)--> DANG_HOAN_TIEN --(xác nhận)--> DA_HOAN_TIEN
 *                                       --(từ chối)--> TU_CHOI
 *   CHO_XU_LY / CHO_BO_SUNG_THONG_TIN --(customer hủy)--> DA_HUY
 *
 * Đây là service DUY NHẤT được dùng cho refund từ nay — không dùng
 * org.example.service.refund.RefundService (luồng cũ, giữ nguyên không sửa để không phá code
 * đang chạy, nhưng không mở rộng thêm để tránh khoét sâu xung đột 2 tập giá trị TrangThai).
 */
public class RefundService {

    private static final Logger logger = LogManager.getLogger(RefundService.class);

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
     * Idempotent: nếu đã có yêu cầu đang hoạt động cho hoaDonId này thì không tạo thêm.
     * Gọi trong transaction của BookingCancellationService (conn được truyền vào).
     *
     * @param conn  connection đang trong transaction — KHÔNG commit/rollback ở đây
     */
    public RefundResult createRefund(Connection conn, int hoaDonId, int datSanId, int coSoId, int accountId,
                                      BigDecimal soTienDaThanhToan, String lyDo) throws SQLException {
        return createRefund(conn, hoaDonId, datSanId, coSoId, accountId, soTienDaThanhToan, soTienDaThanhToan, lyDo);
    }

    public RefundResult createRefund(Connection conn, int hoaDonId, int datSanId, int coSoId, int accountId,
                                      BigDecimal soTienDeNghiHoan, BigDecimal soTienDaThanhToan, String lyDo) throws SQLException {
        if (hoanTienDAO.existsActiveByHoaDonId(hoaDonId)) {
            logger.info("HoaDonID={} đã có yêu cầu hoàn tiền đang hoạt động, bỏ qua tạo mới", hoaDonId);
            return RefundResult.ok(0, "Yêu cầu hoàn tiền đã tồn tại.");
        }

        Hoantien ht = new Hoantien();
        ht.setHoaDonId(hoaDonId);
        ht.setDatSanId(datSanId);
        ht.setCoSoId(coSoId);
        ht.setAccountId(accountId);
        ht.setSoTienHoan(soTienDeNghiHoan != null ? soTienDeNghiHoan : soTienDaThanhToan);
        ht.setSoTienDaThanhToan(soTienDaThanhToan);
        ht.setSoTienDeNghiHoan(soTienDeNghiHoan != null ? soTienDeNghiHoan : soTienDaThanhToan);
        ht.setLyDo(lyDo);
        // Chưa có thông tin ngân hàng lúc booking bị hủy tự động -> chờ Customer bổ sung.
        ht.setTrangThai(RefundStatus.CHO_BO_SUNG_THONG_TIN);

        int id = hoanTienDAO.insert(conn, ht);
        if (id <= 0) {
            return RefundResult.fail("Không tạo được yêu cầu hoàn tiền.");
        }
        return RefundResult.ok(id, "Yêu cầu hoàn tiền #" + id + " đã được tạo.");
    }

    /**
     * Customer tạo yêu cầu hoàn tiền tự thao tác (self-service), kèm luôn thông tin ngân hàng.
     * Không trust số tiền/HoaDonID từ client tham số ngoài datSanId — số tiền đọc lại từ DB.
     */
    public RefundResult requestRefundSelfService(int datSanId, int accountId, String lyDo,
                                                  String nganHang, String soTaiKhoan, String chuTaiKhoan,
                                                  String qrPath) {
        int hoaDonId = findPaidHoaDonId(datSanId);
        if (hoaDonId <= 0) {
            return RefundResult.fail("Không tìm thấy hóa đơn đã thanh toán cho đơn đặt sân này.");
        }
        BigDecimal paid = loadPaidAmount(hoaDonId);
        if (paid == null || paid.signum() <= 0) {
            return RefundResult.fail("Đơn đặt sân chưa được thanh toán nên không thể yêu cầu hoàn tiền.");
        }
        if (hoanTienDAO.existsActiveByHoaDonId(hoaDonId)) {
            return RefundResult.fail("Đơn đặt sân này đã có yêu cầu hoàn tiền đang xử lý.");
        }
        Integer coSoId = findCoSoIdByDatSanId(datSanId);

        Hoantien ht = new Hoantien();
        ht.setHoaDonId(hoaDonId);
        ht.setDatSanId(datSanId);
        if (coSoId != null) ht.setCoSoId(coSoId);
        ht.setAccountId(accountId);
        ht.setSoTienHoan(paid);
        ht.setSoTienDaThanhToan(paid);
        ht.setSoTienDeNghiHoan(paid);
        ht.setLyDo(lyDo);
        ht.setGhiChuKhachHang(lyDo);
        ht.setNganHangNhan(nganHang);
        ht.setSoTaiKhoanNhan(soTaiKhoan);
        ht.setChuTaiKhoanNhan(chuTaiKhoan);
        ht.setQrNhanTienPath(qrPath);
        // Đủ ngân hàng ngay từ đầu -> vào thẳng CHO_XU_LY, không cần bổ sung.
        boolean hasBank = nganHang != null && !nganHang.isBlank()
                && soTaiKhoan != null && !soTaiKhoan.isBlank()
                && chuTaiKhoan != null && !chuTaiKhoan.isBlank();
        ht.setTrangThai(hasBank ? RefundStatus.CHO_XU_LY : RefundStatus.CHO_BO_SUNG_THONG_TIN);

        int id = hoanTienDAO.insert(ht);
        if (id <= 0) return RefundResult.fail("Không tạo được yêu cầu hoàn tiền.");

        notificationService.notifyRefundRequested(accountId, id);
        return RefundResult.ok(id, "Yêu cầu hoàn tiền #" + id + " đã được tạo.");
    }

    /** Gửi notification sau khi transaction đã commit (gọi bên ngoài transaction). */
    public void notifyRefundCreated(int accountId, int hoanTienId) {
        notificationService.notifyRefundRequested(accountId, hoanTienId);
    }

    /** Customer bổ sung/sửa thông tin ngân hàng + QR — chỉ khi trạng thái còn cho phép sửa. */
    public RefundResult updateBankInfo(int hoanTienId, int accountId,
                                        String nganHang, String soTaiKhoan, String chuTaiKhoan, String qrPath) {
        if (nganHang == null || nganHang.isBlank() || soTaiKhoan == null || soTaiKhoan.isBlank()
                || chuTaiKhoan == null || chuTaiKhoan.isBlank()) {
            return RefundResult.fail("Vui lòng nhập đầy đủ tên ngân hàng, số tài khoản và tên chủ tài khoản.");
        }
        boolean ok = hoanTienDAO.updateBankInfo(hoanTienId, accountId, nganHang.trim(), soTaiKhoan.trim(),
                chuTaiKhoan.trim(), qrPath);
        if (!ok) {
            return RefundResult.fail("Không thể cập nhật — yêu cầu đã được xử lý hoặc không tồn tại.");
        }
        return RefundResult.ok(hoanTienId, "Đã cập nhật thông tin ngân hàng nhận tiền.");
    }

    /** Customer tự hủy yêu cầu hoàn tiền khi chưa được Manager xử lý. */
    public RefundResult cancelByCustomer(int hoanTienId, int accountId) {
        Hoantien ht = hoanTienDAO.findByIdAndAccountId(hoanTienId, accountId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền.");
        if (!RefundStatus.CANCELLABLE_BY_CUSTOMER.contains(ht.getTrangThai())) {
            return RefundResult.fail("Yêu cầu đã được xử lý, không thể tự hủy.");
        }
        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, ht.getTrangThai(), RefundStatus.DA_HUY,
                null, "Khách hàng tự hủy yêu cầu.", null, null, null);
        if (!ok) return RefundResult.fail("Không thể hủy — trạng thái đã thay đổi.");
        return RefundResult.ok(hoanTienId, "Đã hủy yêu cầu hoàn tiền #" + hoanTienId);
    }

    /** Manager yêu cầu Customer bổ sung thêm thông tin (ví dụ ngân hàng sai/thiếu). */
    public RefundResult requestMoreInfo(int hoanTienId, int coSoId, int managerAccountId, String ghiChu,
                                         HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền thuộc cơ sở của bạn.");
        if (!RefundStatus.CHO_XU_LY.equals(ht.getTrangThai())) {
            return RefundResult.fail("Chỉ có thể yêu cầu bổ sung khi đơn đang ở trạng thái Chờ xử lý.");
        }
        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, RefundStatus.CHO_XU_LY, RefundStatus.CHO_BO_SUNG_THONG_TIN,
                managerAccountId, ghiChu, null, null, null);
        if (!ok) return RefundResult.fail("Không thể chuyển trạng thái — đã bị thay đổi trước đó.");

        AuditLogService.log(req, null, "REFUND_REQUEST_MORE_INFO", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Manager yêu cầu bổ sung thông tin: " + (ghiChu != null ? ghiChu : ""));

        notificationService.notifyRefundNeedMoreInfo(ht.getAccountId(), hoanTienId, ghiChu);
        return RefundResult.ok(hoanTienId, "Đã yêu cầu khách bổ sung thông tin.");
    }

    /** Manager duyệt yêu cầu hoàn tiền. Số tiền duyệt không được vượt số tiền khách thực trả. */
    public RefundResult approve(int hoanTienId, int coSoId, int managerAccountId, BigDecimal soTienDuocDuyet,
                                 String ghiChu, HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền thuộc cơ sở của bạn.");
        if (!RefundStatus.CHO_XU_LY.equals(ht.getTrangThai())) {
            return RefundResult.fail("Chỉ có thể duyệt khi đơn đang ở trạng thái Chờ xử lý.");
        }
        BigDecimal maxAmount = ht.getSoTienDaThanhToan() != null ? ht.getSoTienDaThanhToan() : ht.getSoTienHoan();
        if (soTienDuocDuyet == null || soTienDuocDuyet.signum() <= 0) {
            return RefundResult.fail("Số tiền được duyệt phải lớn hơn 0.");
        }
        if (maxAmount != null && soTienDuocDuyet.compareTo(maxAmount) > 0) {
            return RefundResult.fail("Số tiền duyệt (" + soTienDuocDuyet + ") không được vượt số tiền khách đã thực trả (" + maxAmount + ").");
        }

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, RefundStatus.CHO_XU_LY, RefundStatus.DA_DUYET,
                managerAccountId, ghiChu, null, null, soTienDuocDuyet);
        if (!ok) return RefundResult.fail("Không thể duyệt — trạng thái không hợp lệ hoặc đã thay đổi.");

        AuditLogService.log(req, null, "APPROVE_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Manager duyệt hoàn tiền " + soTienDuocDuyet + ". Ghi chú: " + (ghiChu != null ? ghiChu : ""));

        notificationService.notifyRefundApproved(ht.getAccountId(), hoanTienId, soTienDuocDuyet.toPlainString());
        return RefundResult.ok(hoanTienId, "Đã duyệt yêu cầu hoàn tiền #" + hoanTienId);
    }

    /** Manager từ chối yêu cầu hoàn tiền — bắt buộc lý do. */
    public RefundResult reject(int hoanTienId, int coSoId, int managerAccountId, String lyDo,
                                HttpServletRequest req) {
        if (lyDo == null || lyDo.isBlank()) {
            return RefundResult.fail("Vui lòng nhập lý do từ chối.");
        }
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền thuộc cơ sở của bạn.");
        if (!RefundStatus.CHO_XU_LY.equals(ht.getTrangThai()) && !RefundStatus.CHO_BO_SUNG_THONG_TIN.equals(ht.getTrangThai())) {
            return RefundResult.fail("Không thể từ chối — trạng thái không hợp lệ.");
        }

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, ht.getTrangThai(), RefundStatus.TU_CHOI,
                managerAccountId, null, null, lyDo.trim(), null);
        if (!ok) return RefundResult.fail("Không thể từ chối — trạng thái không hợp lệ.");

        AuditLogService.log(req, null, "REJECT_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Manager từ chối: " + lyDo.trim());

        notificationService.notifyRefundRejected(ht.getAccountId(), hoanTienId, lyDo.trim());
        return RefundResult.ok(hoanTienId, "Đã từ chối yêu cầu hoàn tiền #" + hoanTienId);
    }

    /** Manager xác nhận bắt đầu xử lý chuyển khoản (DA_DUYET -> DANG_HOAN_TIEN). */
    public RefundResult startProcessing(int hoanTienId, int coSoId, int managerAccountId, HttpServletRequest req) {
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền thuộc cơ sở của bạn.");
        if (!RefundStatus.DA_DUYET.equals(ht.getTrangThai())) {
            return RefundResult.fail("Chỉ có thể chuyển sang đang hoàn tiền khi đơn đã được duyệt.");
        }
        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, RefundStatus.DA_DUYET, RefundStatus.DANG_HOAN_TIEN,
                managerAccountId, null, null, null, null);
        if (!ok) return RefundResult.fail("Không thể chuyển trạng thái — đã bị thay đổi trước đó.");

        AuditLogService.log(req, null, "REFUND_START_PROCESSING", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId, "Manager bắt đầu xử lý hoàn tiền.");

        notificationService.notifyRefundProcessing(ht.getAccountId(), hoanTienId);
        return RefundResult.ok(hoanTienId, "Đã chuyển sang trạng thái đang hoàn tiền.");
    }

    /** Manager xác nhận đã chuyển khoản thành công — bắt buộc mã giao dịch. */
    public RefundResult confirmCompleted(int hoanTienId, int coSoId, int managerAccountId,
                                          String maGiaoDich, String ghiChu,
                                          HttpServletRequest req) {
        if (maGiaoDich == null || maGiaoDich.isBlank()) {
            return RefundResult.fail("Vui lòng nhập mã giao dịch hoàn tiền.");
        }
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        if (ht == null) return RefundResult.fail("Không tìm thấy yêu cầu hoàn tiền thuộc cơ sở của bạn.");
        if (!RefundStatus.DANG_HOAN_TIEN.equals(ht.getTrangThai())) {
            return RefundResult.fail("Chỉ có thể xác nhận hoàn tất khi đơn đang ở trạng thái đang hoàn tiền.");
        }

        boolean ok = hoanTienDAO.updateTrangThai(hoanTienId, RefundStatus.DANG_HOAN_TIEN, RefundStatus.DA_HOAN_TIEN,
                managerAccountId, ghiChu, maGiaoDich.trim(), null, null);
        if (!ok) return RefundResult.fail("Không thể xác nhận — trạng thái không hợp lệ.");

        AuditLogService.log(req, null, "COMPLETE_REFUND", "HoanTien",
                String.valueOf(hoanTienId), "HoanTien #" + hoanTienId,
                "Hoàn tiền thành công. Mã GD: " + maGiaoDich.trim());

        BigDecimal soTien = ht.getSoTienDuocDuyet() != null ? ht.getSoTienDuocDuyet() : ht.getSoTienHoan();
        notificationService.notifyRefundCompleted(ht.getAccountId(), hoanTienId, soTien.toPlainString());
        return RefundResult.ok(hoanTienId, "Đã xác nhận hoàn tiền #" + hoanTienId);
    }

    public Hoantien findById(int hoanTienId) {
        return hoanTienDAO.findById(hoanTienId);
    }

    public Hoantien findByIdAndAccountId(int hoanTienId, int accountId) {
        return hoanTienDAO.findByIdAndAccountId(hoanTienId, accountId);
    }

    public Hoantien findByIdAndCoSoId(int hoanTienId, int coSoId) {
        return hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
    }

    public List<Hoantien> getByCoSo(int coSoId, int page) {
        return hoanTienDAO.findByCoSoId(coSoId, page, 20);
    }

    public List<Hoantien> getByCoSoAndTrangThai(int coSoId, String trangThai, int page) {
        return hoanTienDAO.findByCoSoIdAndTrangThai(coSoId, trangThai, page, 20);
    }

    public List<Hoantien> getByCustomer(int accountId, int page) {
        return hoanTienDAO.findByAccountId(accountId, page, 20);
    }

    /**
     * Đọc số tiền hóa đơn từ DB (không trust client).
     * Trả về null nếu hóa đơn không tồn tại / chưa thanh toán.
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
                     "AND (LoaiHoaDon IS NULL OR LoaiHoaDon = N'MAIN')";
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

    /** Lấy CoSoID từ DatSanID (qua San) — dùng để denormalize vào HoanTien.CoSoID lúc tạo. */
    public static Integer findCoSoIdByDatSanId(int datSanId) {
        String sql = "SELECT s.CoSoID FROM LichDatSan lds JOIN San s ON lds.SanID = s.SanID WHERE lds.DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("CoSoID");
            }
        } catch (SQLException e) {
            logger.error("findCoSoIdByDatSanId datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return null;
    }
}
