package org.example.model;

import java.time.LocalDateTime;

public class FaceChallengeToken {
    private String tokenId;
    private int accountId;
    private int caLamViecId;
    private String action; // "checkin" hoặc "checkout"
    private String challenges; // JSON string: ["blink","turn_left"]
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private LocalDateTime usedAt;

    public String getTokenId() { return tokenId; }
    public void setTokenId(String tokenId) { this.tokenId = tokenId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getCaLamViecId() { return caLamViecId; }
    public void setCaLamViecId(int caLamViecId) { this.caLamViecId = caLamViecId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getChallenges() { return challenges; }
    public void setChallenges(String challenges) { this.challenges = challenges; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public LocalDateTime getUsedAt() { return usedAt; }
    public void setUsedAt(LocalDateTime usedAt) { this.usedAt = usedAt; }

    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }
    public boolean isUsed() {
        return usedAt != null;
    }
}
