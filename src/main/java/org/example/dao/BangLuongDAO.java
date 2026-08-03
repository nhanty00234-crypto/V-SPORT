package org.example.dao;

import org.example.model.BangLuong;

import java.util.List;

public interface BangLuongDAO {

    /** Tạo mới hoặc ghi đè dòng lương của (kỳ, nhân viên). Dùng khi manager bấm "Tính lương". */
    void upsert(BangLuong bl) throws Exception;

    /** Toàn bộ dòng lương của một kỳ, kèm thông tin hiển thị và tài khoản ngân hàng của nhân viên. */
    List<BangLuong> listByKy(int kyLuongId) throws Exception;

    /** Một dòng lương, chỉ trả về nếu kỳ lương của nó thuộc coSoId (chống IDOR). */
    BangLuong findById(int bangLuongId, int coSoId) throws Exception;

    /** Đổi trạng thái một dòng lương (ví dụ khi manager xác nhận đã chuyển khoản). */
    void updateTrangThai(int bangLuongId, String trangThai) throws Exception;

    /** Đổi trạng thái toàn bộ dòng lương của một kỳ (khi manager chốt phát lương). */
    void updateTrangThaiTheoKy(int kyLuongId, String trangThai) throws Exception;

    /** Lịch sử bảng lương của một nhân viên qua các kỳ, mới nhất trước. */
    List<BangLuong> listByAccount(int accountId) throws Exception;
}
