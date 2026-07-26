package org.example.dao;

import org.example.model.Hoantien;

import java.sql.Connection;
import java.util.List;

public interface HoanTienDAO {

    /** Tạo yêu cầu hoàn tiền mới. Trả về HoanTienID được sinh, hoặc 0 nếu thất bại. */
    int insert(Hoantien ht);

    /** Tạo hoàn tiền trong transaction đang có (dùng khi cancel booking cùng conn). */
    int insert(Connection conn, Hoantien ht);

    Hoantien findById(int hoanTienId);

    /** Kiểm tra đã có yêu cầu hoàn tiền cho HoaDonID chưa (idempotency). */
    boolean existsByHoaDonId(int hoaDonId);

    /** Manager: lấy danh sách hoàn tiền của cơ sở mình, phân trang. */
    List<Hoantien> findByCoSoId(int coSoId, int page, int pageSize);

    /** Customer: lấy danh sách hoàn tiền của mình. */
    List<Hoantien> findByAccountId(int accountId, int page, int pageSize);

    /**
     * Chuyển trạng thái (state machine):
     *  Chờ xử lý → Đã duyệt / Từ chối
     *  Đã duyệt   → Đã hoàn tiền
     * Luôn ghi AccountID_NguoiXuLy, GhiChuXuLy, ThoiGianXuLy.
     * Với "Đã hoàn tiền" còn ghi MaGiaoDichHoan.
     * Trả về true nếu cập nhật thành công (kiểm tra trạng thái nguồn hợp lệ).
     */
    boolean updateTrangThai(int hoanTienId, String trangThaiMoi,
                             int accountIdNguoiXuLy, String ghiChuXuLy,
                             String maGiaoDichHoan);

    /**
     * Cập nhật thông tin tài khoản ngân hàng nhận tiền (customer cung cấp sau khi tạo yêu cầu).
     * Chỉ được phép khi TrangThai = 'Chờ xử lý'.
     */
    boolean updateBankInfo(int hoanTienId, int accountId,
                            String nganHangNhan, String soTaiKhoanNhan, String chuTaiKhoanNhan);
}
