package org.example.dao;

import org.example.model.CauHinhLuong;

import java.util.List;

public interface CauHinhLuongDAO {

    /** Cấu hình lương của một nhân viên tại một cơ sở; null nếu manager chưa cấu hình. */
    CauHinhLuong findByAccount(int accountId, int coSoId) throws Exception;

    /**
     * Danh sách nhân sự hưởng lương (RoleID 4 = lễ tân, 5 = bảo vệ) của cơ sở, kèm cấu hình
     * lương nếu đã có. Nhân viên chưa cấu hình vẫn xuất hiện với cauHinhLuongId = 0 và các
     * khoản tiền = 0, để manager thấy được ai còn thiếu cấu hình.
     */
    List<CauHinhLuong> listByCoSo(int coSoId) throws Exception;

    /** Tạo mới nếu chưa có, cập nhật nếu đã có (khoá theo UNIQUE(AccountID, CoSoID)). */
    void upsert(CauHinhLuong ch) throws Exception;
}
