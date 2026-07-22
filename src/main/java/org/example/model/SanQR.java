package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * QR bảo mật gắn 1-1 với một sân (SanID unique). Token là UUID không đoán được -
 * dùng để Customer quét, KHÔNG dùng SanID trong URL/QR in ra (tránh dò tuần tự
 * sang sân khác). Regenerate SỬA token trong CÙNG bản ghi này (không tạo dòng
 * mới) - token cũ được lưu lại ở SanQRTokenHistory và đánh dấu REVOKED.
 */
@Entity
@Table(name = "SanQR")
public class SanQR {

    public static final String ACTIVE = "ACTIVE";
    public static final String DISABLED = "DISABLED";
    public static final String REVOKED = "REVOKED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SanQRID")
    private int sanQRId;

    @Column(name = "SanID", nullable = false)
    private int sanId;

    @Column(name = "Token", nullable = false, columnDefinition = "uniqueidentifier")
    private UUID token;

    /**
     * Mã ngắn dự phòng khi Customer không quét được QR bằng camera (không cấp
     * quyền, camera lỗi, QR mờ). Sinh bằng SecureRandom qua SanQRSecurityUtil,
     * KHÔNG suy ra được từ SanID/token. Có thể null tạm thời cho các bản ghi
     * tạo trước khi có hardening này - Service tự backfill khi phát hiện null.
     */
    @Column(name = "ShortCode", length = 12)
    private String shortCode;

    @Column(name = "TrangThai", nullable = false, length = 20)
    private String trangThai;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "CreatedBy")
    private Integer createdBy;

    @Column(name = "UpdatedAt", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "UpdatedBy")
    private Integer updatedBy;

    @Column(name = "RegenerateCount", nullable = false)
    private int regenerateCount;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
        if (token == null) token = UUID.randomUUID();
        if (trangThai == null) trangThai = ACTIVE;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public SanQR() {
    }

    public int getSanQRId() { return sanQRId; }
    public void setSanQRId(int sanQRId) { this.sanQRId = sanQRId; }

    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }

    public UUID getToken() { return token; }
    public void setToken(UUID token) { this.token = token; }

    public String getShortCode() { return shortCode; }
    public void setShortCode(String shortCode) { this.shortCode = shortCode; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(Integer updatedBy) { this.updatedBy = updatedBy; }

    public int getRegenerateCount() { return regenerateCount; }
    public void setRegenerateCount(int regenerateCount) { this.regenerateCount = regenerateCount; }

    public boolean isActive() { return ACTIVE.equals(trangThai); }
}
