package org.example.service.payos;

import org.example.dto.payment.PayOSCredentials;
import vn.payos.PayOS;

/**
 * Tạo PayOS SDK client theo credentials của một CoSo cụ thể, KHÔNG cache.
 * Mỗi lời gọi tạo một client mới từ credentials hiện hành - đảm bảo Admin đổi
 * key xong là request kế tiếp dùng ngay key mới, không cần cơ chế invalidate.
 */
public final class PayOSClientFactory {
    private PayOSClientFactory() {}

    public static PayOS create(PayOSCredentials credentials) {
        if (credentials == null || !credentials.isClientIdConfigured()
                || !credentials.isApiKeyConfigured() || !credentials.isChecksumKeyConfigured()) {
            throw new IllegalStateException("Thiếu cấu hình PayOS.");
        }
        return new PayOS(credentials.getClientId(), credentials.getApiKey(), credentials.getChecksumKey());
    }
}
