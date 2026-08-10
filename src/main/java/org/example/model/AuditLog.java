package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "audit_log_id")
    private long auditLogId;

    @Column(name = "actor_account_id")
    private Integer actorAccountId;

    @Column(name = "actor_name", nullable = false)
    private String actorName;

    @Column(name = "actor_role_id", nullable = false)
    private int actorRole;

    @Column(name = "facility_id")
    private Integer coSoId;

    @Column(name = "action", nullable = false, length = 100)
    private String action;

    @Column(name = "entity_type", nullable = false, length = 100)
    private String entityType;

    @Column(name = "entity_id", length = 50)
    private String entityId;

    @Column(name = "entity_name", length = 500)
    private String entityName;

    @Column(name = "details", columnDefinition = "NVARCHAR(MAX)")
    private String details;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public AuditLog() {}

    // Getters and setters
    public long getAuditLogId() { return auditLogId; }
    public void setAuditLogId(long auditLogId) { this.auditLogId = auditLogId; }
    public Integer getActorAccountId() { return actorAccountId; }
    public void setActorAccountId(Integer actorAccountId) { this.actorAccountId = actorAccountId; }
    public String getActorName() { return actorName; }
    public void setActorName(String actorName) { this.actorName = actorName; }
    public int getActorRole() { return actorRole; }
    public void setActorRole(int actorRole) { this.actorRole = actorRole; }
    public Integer getCoSoId() { return coSoId; }
    public void setCoSoId(Integer coSoId) { this.coSoId = coSoId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public String getEntityId() { return entityId; }
    public void setEntityId(String entityId) { this.entityId = entityId; }
    public String getEntityName() { return entityName; }
    public void setEntityName(String entityName) { this.entityName = entityName; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
