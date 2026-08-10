package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "customer_reputation_history")
public class CustomerReputationHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reputation_history_id")
    private long reputationHistoryId;

    @Column(name = "account_id")
    private int accountId;

    @Column(name = "booking_id")
    private Integer datSanId;

    @Column(name = "action_type", length = 30)
    private String actionType;

    @Column(name = "score_delta")
    private int scoreDelta;

    @Column(name = "score_before")
    private int scoreBefore;

    @Column(name = "score_after")
    private int scoreAfter;

    @Column(name = "reason", length = 255)
    private String reason;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "created_by")
    private Integer createdBy;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    public long getReputationHistoryId() { return reputationHistoryId; }
    public void setReputationHistoryId(long reputationHistoryId) { this.reputationHistoryId = reputationHistoryId; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }

    public Integer getDatSanId() { return datSanId; }
    public void setDatSanId(Integer datSanId) { this.datSanId = datSanId; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public int getScoreDelta() { return scoreDelta; }
    public void setScoreDelta(int scoreDelta) { this.scoreDelta = scoreDelta; }

    public int getScoreBefore() { return scoreBefore; }
    public void setScoreBefore(int scoreBefore) { this.scoreBefore = scoreBefore; }

    public int getScoreAfter() { return scoreAfter; }
    public void setScoreAfter(int scoreAfter) { this.scoreAfter = scoreAfter; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Integer getCreatedBy() { return createdBy; }
    public void setCreatedBy(Integer createdBy) { this.createdBy = createdBy; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
}
