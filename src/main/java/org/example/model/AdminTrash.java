package org.example.model;

import java.time.LocalDateTime;

public class AdminTrash {
    private int trashId;
    private String entityType;
    private int entityId;
    private String displayName;
    private String sourceTable;
    private String oldStatus;
    private Integer deletedBy;
    private String deletedByName;
    private LocalDateTime deletedAt;
    private String reason;
    private boolean restored;
    private Integer restoredBy;
    private LocalDateTime restoredAt;

    public int getTrashId() { return trashId; }
    public void setTrashId(int trashId) { this.trashId = trashId; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public int getEntityId() { return entityId; }
    public void setEntityId(int entityId) { this.entityId = entityId; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getSourceTable() { return sourceTable; }
    public void setSourceTable(String sourceTable) { this.sourceTable = sourceTable; }

    public String getOldStatus() { return oldStatus; }
    public void setOldStatus(String oldStatus) { this.oldStatus = oldStatus; }

    public Integer getDeletedBy() { return deletedBy; }
    public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }

    public String getDeletedByName() { return deletedByName; }
    public void setDeletedByName(String deletedByName) { this.deletedByName = deletedByName; }

    public LocalDateTime getDeletedAt() { return deletedAt; }
    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public boolean isRestored() { return restored; }
    public void setRestored(boolean restored) { this.restored = restored; }

    public Integer getRestoredBy() { return restoredBy; }
    public void setRestoredBy(Integer restoredBy) { this.restoredBy = restoredBy; }

    public LocalDateTime getRestoredAt() { return restoredAt; }
    public void setRestoredAt(LocalDateTime restoredAt) { this.restoredAt = restoredAt; }
}
