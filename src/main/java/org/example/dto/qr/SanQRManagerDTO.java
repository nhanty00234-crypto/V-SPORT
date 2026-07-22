package org.example.dto.qr;

import java.time.LocalDateTime;

/**
 * DTO trả về cho Manager khi liệt kê/xem chi tiết QR của sân mình quản lý.
 * KHÔNG BAO GIỜ chứa raw token (UUID) - chỉ short code, và chỉ ở dạng đầy đủ
 * trong detail (list dùng maskedShortCode). Manager không cần token thô để
 * làm gì: tải PNG/in đều đi qua endpoint ảnh phía server (xem
 * SanQRImageServlet), không qua việc lộ token ra JSON.
 */
public final class SanQRManagerDTO {

    private final int sanId;
    private final String tenSan;
    private final String tenLoaiSan;
    private final String tenMonTheThao;
    private final String trangThaiSan;
    private final boolean hasQr;
    private final String qrStatus;          // ACTIVE | DISABLED | REVOKED | null (chưa tạo)
    private final String qrStatusLabel;     // Nhãn tiếng Việt hiển thị
    private final String maskedShortCode;   // VS-••••2M
    private final String fullShortCode;     // chỉ set khi trả detail
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
    private final int regenerateCount;
    private final boolean canCreate;
    private final boolean canEnable;
    private final boolean canDisable;
    private final boolean canRegenerate;
    private final boolean canPrint;

    private SanQRManagerDTO(Builder b) {
        this.sanId = b.sanId;
        this.tenSan = b.tenSan;
        this.tenLoaiSan = b.tenLoaiSan;
        this.tenMonTheThao = b.tenMonTheThao;
        this.trangThaiSan = b.trangThaiSan;
        this.hasQr = b.hasQr;
        this.qrStatus = b.qrStatus;
        this.qrStatusLabel = b.qrStatusLabel;
        this.maskedShortCode = b.maskedShortCode;
        this.fullShortCode = b.fullShortCode;
        this.createdAt = b.createdAt;
        this.updatedAt = b.updatedAt;
        this.regenerateCount = b.regenerateCount;
        this.canCreate = b.canCreate;
        this.canEnable = b.canEnable;
        this.canDisable = b.canDisable;
        this.canRegenerate = b.canRegenerate;
        this.canPrint = b.canPrint;
    }

    public static Builder builder() { return new Builder(); }

    public static final class Builder {
        private int sanId;
        private String tenSan;
        private String tenLoaiSan;
        private String tenMonTheThao;
        private String trangThaiSan;
        private boolean hasQr;
        private String qrStatus;
        private String qrStatusLabel;
        private String maskedShortCode;
        private String fullShortCode;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
        private int regenerateCount;
        private boolean canCreate;
        private boolean canEnable;
        private boolean canDisable;
        private boolean canRegenerate;
        private boolean canPrint;

        public Builder sanId(int v) { this.sanId = v; return this; }
        public Builder tenSan(String v) { this.tenSan = v; return this; }
        public Builder tenLoaiSan(String v) { this.tenLoaiSan = v; return this; }
        public Builder tenMonTheThao(String v) { this.tenMonTheThao = v; return this; }
        public Builder trangThaiSan(String v) { this.trangThaiSan = v; return this; }
        public Builder hasQr(boolean v) { this.hasQr = v; return this; }
        public Builder qrStatus(String v) { this.qrStatus = v; return this; }
        public Builder qrStatusLabel(String v) { this.qrStatusLabel = v; return this; }
        public Builder maskedShortCode(String v) { this.maskedShortCode = v; return this; }
        public Builder fullShortCode(String v) { this.fullShortCode = v; return this; }
        public Builder createdAt(LocalDateTime v) { this.createdAt = v; return this; }
        public Builder updatedAt(LocalDateTime v) { this.updatedAt = v; return this; }
        public Builder regenerateCount(int v) { this.regenerateCount = v; return this; }
        public Builder canCreate(boolean v) { this.canCreate = v; return this; }
        public Builder canEnable(boolean v) { this.canEnable = v; return this; }
        public Builder canDisable(boolean v) { this.canDisable = v; return this; }
        public Builder canRegenerate(boolean v) { this.canRegenerate = v; return this; }
        public Builder canPrint(boolean v) { this.canPrint = v; return this; }

        public SanQRManagerDTO build() { return new SanQRManagerDTO(this); }
    }

    /** VS-XXXXXX -> VS-••••XX (giữ 2 ký tự cuối để Manager phân biệt nhanh trong list mà không lộ full code). */
    public static String mask(String shortCode) {
        if (shortCode == null || shortCode.length() < 4) return shortCode;
        String prefix = shortCode.contains("-") ? shortCode.substring(0, shortCode.indexOf('-') + 1) : "";
        String body = shortCode.substring(prefix.length());
        if (body.length() <= 2) return prefix + body;
        String tail = body.substring(body.length() - 2);
        return prefix + "••••" + tail;
    }

    public int getSanId() { return sanId; }
    public String getTenSan() { return tenSan; }
    public String getTenLoaiSan() { return tenLoaiSan; }
    public String getTenMonTheThao() { return tenMonTheThao; }
    public String getTrangThaiSan() { return trangThaiSan; }
    public boolean isHasQr() { return hasQr; }
    public String getQrStatus() { return qrStatus; }
    public String getQrStatusLabel() { return qrStatusLabel; }
    public String getMaskedShortCode() { return maskedShortCode; }
    public String getFullShortCode() { return fullShortCode; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public int getRegenerateCount() { return regenerateCount; }
    public boolean isCanCreate() { return canCreate; }
    public boolean isCanEnable() { return canEnable; }
    public boolean isCanDisable() { return canDisable; }
    public boolean isCanRegenerate() { return canRegenerate; }
    public boolean isCanPrint() { return canPrint; }
}
