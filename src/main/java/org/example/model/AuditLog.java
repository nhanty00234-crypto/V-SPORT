package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "AuditLog")
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AuditLogID")
    private long auditLogId;

    @Column(name = "ActorAccountID")
    private Integer actorAccountId;

    @Column(name = "ActorName", nullable = false)
    private String actorName;

    @Column(name = "ActorRole", nullable = false)
    private int actorRole;

    @Column(name = "CoSoID")
    private Integer coSoId;

    @Column(name = "Action", nullable = false, length = 100)
    private String action;

    @Column(name = "EntityType", nullable = false, length = 100)
    private String entityType;

    @Column(name = "EntityID", length = 50)
    private String entityId;

    @Column(name = "EntityName", length = 500)
    private String entityName;

    @Column(name = "Details", columnDefinition = "NVARCHAR(MAX)")
    private String details;

    @Column(name = "IpAddress", length = 50)
    private String ipAddress;

    @Column(name = "CreatedAt", nullable = false)
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
