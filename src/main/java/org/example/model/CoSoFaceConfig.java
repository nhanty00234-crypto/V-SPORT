package org.example.model;

import java.time.LocalDateTime;

public class CoSoFaceConfig {
    private int coSoId;
    private boolean faceRequired;
    private double confidenceMin; // 0.0 - 1.0, default 0.6
    private LocalDateTime updatedAt;

    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
    public boolean isFaceRequired() { return faceRequired; }
    public void setFaceRequired(boolean faceRequired) { this.faceRequired = faceRequired; }
    public double getConfidenceMin() { return confidenceMin; }
    public void setConfidenceMin(double confidenceMin) { this.confidenceMin = confidenceMin; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
