package org.example.dao;

import org.example.model.KyLuong;

import java.time.LocalDate;
import java.util.List;

public interface KyLuongDAO {

    /** Tạo kỳ lương mới, trả về KyLuongID vừa sinh. */
    int insert(KyLuong ky) throws Exception;

    /** Lấy kỳ lương THUỘC cơ sở này; trả null nếu id không tồn tại hoặc thuộc cơ sở khác (chống IDOR). */
    KyLuong findById(int kyLuongId, int coSoId) throws Exception;

    /** Danh sách kỳ lương của cơ sở, mới nhất trước, kèm số nhân viên và tổng chi đã tính. */
    List<KyLuong> listByCoSo(int coSoId) throws Exception;

    /** Đổi trạng thái kỳ (Draft | DangTinh | DaPhat). Chỉ tác động nếu kỳ thuộc cơ sở. */
    void updateTrangThai(int kyLuongId, int coSoId, String trangThai) throws Exception;

    /** Kỳ có NgayPhatLuong đúng bằng homNay, dùng để bật banner nhắc phát lương. Null nếu không có. */
    KyLuong findKyPhatLuongHomNay(int coSoId, LocalDate homNay) throws Exception;
}
