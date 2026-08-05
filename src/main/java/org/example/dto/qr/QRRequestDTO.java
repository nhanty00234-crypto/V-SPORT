package org.example.dto.qr;

public final class QRRequestDTO {
    private final int requestId;
    private final int sanId;
    private final String tenSan;
    private final String requestType;
    private final String itemsJson;
    private final String note;
    private final String status;
    private final String createdAt;
    private final String updatedAt;

    public QRRequestDTO(int requestId, int sanId, String tenSan, String requestType,
                         String itemsJson, String note, String status,
                         String createdAt, String updatedAt) {
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
    public String getCreatedAt() { return createdAt; }
    public String getUpdatedAt() { return updatedAt; }
}
