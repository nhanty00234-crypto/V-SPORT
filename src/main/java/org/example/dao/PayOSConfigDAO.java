package org.example.dao;

import org.example.dto.payment.PayOSConfigState;
import org.example.dto.payment.PayOSCredentials;

import java.util.Map;

public interface PayOSConfigDAO {

    /** Đọc giá trị PayOS thô của một CoSo — null nếu CoSoID không tồn tại trong bảng CoSo. */
    PayOSCredentials findPayOSConfigurationStatusByCoSoId(int coSoId);

    /** Ghi 3 giá trị PayOS đã merge/validate (service layer chịu trách nhiệm merge). Trả về true nếu đúng 1 dòng bị ảnh hưởng. */
    boolean updatePayOSConfiguration(int coSoId, String clientId, String apiKey, String checksumKey);

    /** Chỉ dùng nội bộ cho tầng thanh toán backend — không expose qua servlet/API. */
    PayOSCredentials getPayOSCredentialsForInternalUse(int coSoId);

    /** Trạng thái PayOS cho toàn bộ CoSo chưa xóa mềm — dùng cho badge ở trang danh sách, tránh N+1 query. */
    Map<Integer, PayOSConfigState> findStatusForAllCoSo();
}
