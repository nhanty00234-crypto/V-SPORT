package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Lịch sử MỌI token/short code từng cấp cho một sân (kể cả token đang active
 * hiện tại). Khi regenerate, token cũ được ghi REVOKED tại đây. Mục đích: nếu
 * một QR giấy cũ (đã bị thay) bị quét lại, Service layer tra bảng này để trả
 * lỗi rõ ràng "mã QR đã cũ" thay vì lỗi chung "không tìm thấy" - phân biệt QR
 * cũ với QR giả.
 *
 * CHỈ lưu SHA-256 hash của token/short code (TokenHash/ShortCode ở đây là giá
 * trị plaintext short code - short code KHÔNG nhạy cảm bằng token vì nó chỉ
 * dùng làm fallback nhập tay, xem SanQRSecurityUtil), KHÔNG lưu token plaintext
 * - lịch sử chỉ cần trả lời "token vừa quét có từng active không", không cần
 * đọc lại giá trị gốc để làm gì khác.
 */
@Entity
@Table(name = "SanQRTokenHistory")
public class SanQRTokenHistory {

    public static final String ISSUED = "ISSUED";
    public static final String REVOKED = "REVOKED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "HistoryID")
    private int historyId;

    @Column(name = "SanQRID", nullable = false)
    private int sanQRId;

    @Column(name = "SanID", nullable = false)
    private int sanId;

    @Column(name = "TokenHash", length = 64)
    private String tokenHash;

    @Column(name = "ShortCode", length = 12)
    private String shortCode;

    @Column(name = "TrangThai", nullable = false, length = 20)
    private String trangThai;

    @Column(name = "IssuedAt", nullable = false)
    private LocalDateTime issuedAt;

    @Column(name = "RevokedAt")
    private LocalDateTime revokedAt;

    @Column(name = "RevokedBy")
    private Integer revokedBy;

    @Column(name = "RevokeReason", length = 200)
    private String revokeReason;

    @PrePersist
    protected void onCreate() {
        if (issuedAt == null) issuedAt = LocalDateTime.now();
        if (trangThai == null) trangThai = ISSUED;
    }

    public SanQRTokenHistory() {
    }

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getSanQRId() { return sanQRId; }
    public void setSanQRId(int sanQRId) { this.sanQRId = sanQRId; }

    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }

    public String getTokenHash() { return tokenHash; }
    public void setTokenHash(String tokenHash) { this.tokenHash = tokenHash; }

    public String getShortCode() { return shortCode; }
    public void setShortCode(String shortCode) { this.shortCode = shortCode; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public LocalDateTime getIssuedAt() { return issuedAt; }
    public void setIssuedAt(LocalDateTime issuedAt) { this.issuedAt = issuedAt; }

    public LocalDateTime getRevokedAt() { return revokedAt; }
    public void setRevokedAt(LocalDateTime revokedAt) { this.revokedAt = revokedAt; }

    public Integer getRevokedBy() { return revokedBy; }
    public void setRevokedBy(Integer revokedBy) { this.revokedBy = revokedBy; }

    public String getRevokeReason() { return revokeReason; }
    public void setRevokeReason(String revokeReason) { this.revokeReason = revokeReason; }
}
