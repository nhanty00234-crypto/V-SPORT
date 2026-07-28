package org.example.dao;

import org.example.model.Hoantien;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.List;

public interface HoanTienDAO {

    /** Tạo yêu cầu hoàn tiền mới. Trả về HoanTienID được sinh, hoặc 0 nếu thất bại. */
    int insert(Hoantien ht);

    /** Tạo hoàn tiền trong transaction đang có (dùng khi cancel booking cùng conn). */
    int insert(Connection conn, Hoantien ht);

    Hoantien findById(int hoanTienId);

    /** Chống IDOR: chỉ trả về nếu HoanTien thuộc đúng AccountID (Customer xem/sửa refund của mình). */
    Hoantien findByIdAndAccountId(int hoanTienId, int accountId);

    /** Chống IDOR: chỉ trả về nếu HoanTien thuộc đúng CoSoID (Manager xử lý refund của cơ sở mình). */
    Hoantien findByIdAndCoSoId(int hoanTienId, int coSoId);

    /** Kiểm tra đã có yêu cầu hoàn tiền cho HoaDonID chưa (idempotency) — chỉ tính các yêu cầu chưa bị hủy/từ chối. */
    boolean existsActiveByHoaDonId(int hoaDonId);

    /** Manager: lấy danh sách hoàn tiền của cơ sở mình, phân trang. */
    List<Hoantien> findByCoSoId(int coSoId, int page, int pageSize);

    /** Manager: lấy danh sách hoàn tiền của cơ sở mình lọc theo trạng thái. */
    List<Hoantien> findByCoSoIdAndTrangThai(int coSoId, String trangThai, int page, int pageSize);

    /** Customer: lấy danh sách hoàn tiền của mình. */
    List<Hoantien> findByAccountId(int accountId, int page, int pageSize);

    /** Lấy yêu cầu hoàn tiền đang hoạt động theo DatSanID (nếu có). */
    Hoantien findActiveByDatSanId(int datSanId);

    /** Lấy bản đồ DatSanID -> Hoantien cho tất cả các yêu cầu hoàn tiền của customer. */
    java.util.Map<Integer, Hoantien> findActiveMapByAccountId(int accountId);

    /**
     * Chuyển trạng thái (state machine RefundStatus) — câu UPDATE luôn kiểm tra trạng thái nguồn
     * (WHERE ... AND TrangThai = ?) để chống double submit đổi trạng thái hai lần. Trả về true chỉ
     * khi thực sự có 1 dòng bị ảnh hưởng.
     */
    boolean updateTrangThai(int hoanTienId, String trangThaiCu, String trangThaiMoi,
                            Integer accountIdNguoiXuLy, String ghiChuXuLy, String maGiaoDichHoan,
                            String lyDoTuChoi, BigDecimal soTienDuocDuyet);

    /**
     * Cập nhật thông tin tài khoản ngân hàng + QR nhận tiền (customer cung cấp sau khi tạo yêu cầu).
     * Chỉ được phép khi TrangThai thuộc RefundStatus.EDITABLE_BY_CUSTOMER — kiểm tra ngay trong WHERE,
     * không chỉ ở tầng service, để chống race condition 2 request cùng lúc.
     */
    boolean updateBankInfo(int hoanTienId, int accountId,
                            String nganHangNhan, String soTaiKhoanNhan, String chuTaiKhoanNhan,
                            String qrNhanTienPath);

    /** Chỉ cập nhật đường dẫn QR (dùng khi Customer chỉ đổi ảnh QR, không đổi field khác). */
    boolean updateQrPath(int hoanTienId, int accountId, String qrNhanTienPath);
}
