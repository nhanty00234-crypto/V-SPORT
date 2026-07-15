package org.example.dao;

import org.example.model.CoSoNganHang;

public interface CoSoNganHangDAO {
    /** Trả về null nếu cơ sở chưa cấu hình tài khoản ngân hàng nhận chuyển khoản. */
    CoSoNganHang findByCoSoId(int coSoId) throws Exception;
}
