package org.example.dto.payment;

public final class PayOSConfigurationStatus {
    private final int coSoId;
    private final String coSoName;
    private final PayOSConfigState state;
    private final boolean clientIdConfigured;
    private final boolean apiKeyConfigured;
    private final boolean checksumKeyConfigured;
    private final String clientIdMasked;
    private final String apiKeyMasked;
    private final String checksumKeyMasked;
    private final String lastUpdatedAt;

    public PayOSConfigurationStatus(int coSoId, String coSoName, PayOSConfigState state,
                                     boolean clientIdConfigured, boolean apiKeyConfigured, boolean checksumKeyConfigured,
                                     String clientIdMasked, String apiKeyMasked, String checksumKeyMasked,
                                     String lastUpdatedAt) {
        this.coSoId = coSoId;
        this.coSoName = coSoName;
        this.state = state;
        this.clientIdConfigured = clientIdConfigured;
        this.apiKeyConfigured = apiKeyConfigured;
        this.checksumKeyConfigured = checksumKeyConfigured;
        this.clientIdMasked = clientIdMasked;
        this.apiKeyMasked = apiKeyMasked;
        this.checksumKeyMasked = checksumKeyMasked;
        this.lastUpdatedAt = lastUpdatedAt;
    }

    public int getCoSoId() { return coSoId; }
    public String getCoSoName() { return coSoName; }
    public PayOSConfigState getState() { return state; }
    public boolean isClientIdConfigured() { return clientIdConfigured; }
    public boolean isApiKeyConfigured() { return apiKeyConfigured; }
    public boolean isChecksumKeyConfigured() { return checksumKeyConfigured; }
    public String getClientIdMasked() { return clientIdMasked; }
    public String getApiKeyMasked() { return apiKeyMasked; }
    public String getChecksumKeyMasked() { return checksumKeyMasked; }
    public String getLastUpdatedAt() { return lastUpdatedAt; }
}
