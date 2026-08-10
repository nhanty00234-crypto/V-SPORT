package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "qr_requests")
public class QRRequest {
    public static final String TYPE_CALL_STAFF = "CALL_STAFF";
    public static final String TYPE_ORDER_ITEM = "ORDER_ITEM";
    public static final String TYPE_SERVICE_REQUEST = "SERVICE_REQUEST";
    public static final String TYPE_PAYMENT_REQUEST = "PAYMENT_REQUEST";

    public static final String PAYMENT_METHOD_TRANSFER = "Chuyển khoản";
    public static final String PAYMENT_METHOD_CASH = "Tiền mặt";

    public static final String STATUS_NEW = "NEW";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_DONE = "DONE";
    public static final String STATUS_CANCELLED = "CANCELLED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "request_id")
    private int requestId;

    @Column(name = "court_id", nullable = false)
    private int sanId;

    @Column(name = "facility_id", nullable = false)
    private int coSoId;

    @Column(name = "guest_token", nullable = false, length = 64)
    private String guestToken;

    @Column(name = "customer_account_id")
    private Integer customerId;

    @Column(name = "request_type", nullable = false, length = 20)
    private String requestType;

    @Column(name = "items_json", columnDefinition = "nvarchar(max)")
    private String itemsJson;

    @Column(name = "note", length = 255)
    private String note;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "handled_by_staff_id")
    private Integer handledByStaffId;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
        if (status == null) status = STATUS_NEW;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
    public String getGuestToken() { return guestToken; }
    public void setGuestToken(String guestToken) { this.guestToken = guestToken; }
    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }
    public String getItemsJson() { return itemsJson; }
    public void setItemsJson(String itemsJson) { this.itemsJson = itemsJson; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public Integer getHandledByStaffId() { return handledByStaffId; }
    public void setHandledByStaffId(Integer handledByStaffId) { this.handledByStaffId = handledByStaffId; }
}
