package org.example.dto.qr;

import java.time.LocalDateTime;

public final class QRRequestDTO {
    private final int requestId;
    private final int sanId;
    private final String tenSan;
    private final String requestType;
    private final String itemsJson;
    private final String note;
    private final String status;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public QRRequestDTO(int requestId, int sanId, String tenSan, String requestType,
                         String itemsJson, String note, String status,
                         LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.requestId = requestId;
        this.sanId = sanId;
        this.tenSan = tenSan;
        this.requestType = requestType;
        this.itemsJson = itemsJson;
        this.note = note;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getRequestId() { return requestId; }
    public int getSanId() { return sanId; }
    public String getTenSan() { return tenSan; }
    public String getRequestType() { return requestType; }
    public String getItemsJson() { return itemsJson; }
    public String getNote() { return note; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
