package org.example.dto.qr;

/**
 * DTO công khai trả về khi resolve QR/short code (Customer quét bằng camera
 * hoặc nhập short code - endpoint public, task sau). KHÔNG chứa bất kỳ định
 * danh nội bộ nào (SanQRID, SanID, CoSoID, token, short code, CreatedBy,
 * UpdatedBy, RegenerateCount, entity proxy...) - chỉ dữ liệu cần hiển thị cho
 * người quét. Immutable, không có setter, không có tham chiếu tới entity JPA.
 */
public final class SanQRResolveDTO {

    /** Khớp SanQRService.ResolveOutcome nhưng là String độc lập - DTO không phụ thuộc ngược vào Service/enum nội bộ. */
    private final String resultCode;
    private final String message;
    private final String tenCoSo;
    private final String tenSan;
    private final String tenMonTheThao;
    private final boolean available;
    private final Integer sanId;

    private SanQRResolveDTO(String resultCode, String message, String tenCoSo,
                             String tenSan, String tenMonTheThao, boolean available) {
        this(resultCode, message, tenCoSo, tenSan, tenMonTheThao, available, null);
    }

    private SanQRResolveDTO(String resultCode, String message, String tenCoSo,
                             String tenSan, String tenMonTheThao, boolean available, Integer sanId) {
        this.resultCode = resultCode;
        this.message = message;
        this.tenCoSo = tenCoSo;
        this.tenSan = tenSan;
        this.tenMonTheThao = tenMonTheThao;
        this.available = available;
        this.sanId = sanId;
    }

    public static SanQRResolveDTO ok(String tenCoSo, String tenSan, String tenMonTheThao) {
        return new SanQRResolveDTO("OK", "Mã hợp lệ.", tenCoSo, tenSan, tenMonTheThao, true);
    }

    /** Như {@link #ok}, nhưng có thêm sanId cho các use case cần gọi API tiếp theo (VD: QR-03A) - vẫn không lộ CoSoID/token. */
    public static SanQRResolveDTO okWithSanId(String tenCoSo, String tenSan, String tenMonTheThao, Integer sanId) {
        return new SanQRResolveDTO("OK", "Mã hợp lệ.", tenCoSo, tenSan, tenMonTheThao, true, sanId);
    }

    public static SanQRResolveDTO notFound() {
        return new SanQRResolveDTO("NOT_FOUND", "Mã không tồn tại hoặc không hợp lệ.", null, null, null, false);
    }

    public static SanQRResolveDTO revoked() {
        return new SanQRResolveDTO("REVOKED", "Mã QR này đã cũ, vui lòng lấy mã mới từ cơ sở.", null, null, null, false);
    }

    public static SanQRResolveDTO disabled(String tenCoSo, String tenSan) {
        return new SanQRResolveDTO("DISABLED", "Mã QR của sân này đang tạm ngưng sử dụng.", tenCoSo, tenSan, null, false);
    }

    public static SanQRResolveDTO facilityInactive(String tenCoSo, String tenSan) {
        return new SanQRResolveDTO("FACILITY_INACTIVE", "Sân hiện không sẵn sàng phục vụ.", tenCoSo, tenSan, null, false);
    }

    public String getResultCode() { return resultCode; }
    public String getMessage() { return message; }
    public String getTenCoSo() { return tenCoSo; }
    public String getTenSan() { return tenSan; }
    public String getTenMonTheThao() { return tenMonTheThao; }
    public boolean isAvailable() { return available; }
    public Integer getSanId() { return sanId; }
}
