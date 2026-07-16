package org.example.dto.payment;

/**
 * DTO nội bộ chứa khóa PayOS thô của một Cơ Sở.
 * KHÔNG serialize ra JSON, KHÔNG log, KHÔNG trả về frontend.
 * getCredentialsForPayment() (PayOSConfigurationService) là nơi duy nhất
 * được phép đọc giá trị thật — chỉ dùng nội bộ tầng thanh toán backend.
 */
public final class PayOSCredentials {
    private final String clientId;
    private final String apiKey;
    private final String checksumKey;

    public PayOSCredentials(String clientId, String apiKey, String checksumKey) {
        this.clientId = clientId;
        this.apiKey = apiKey;
        this.checksumKey = checksumKey;
    }

    public String getClientId() { return clientId; }
    public String getApiKey() { return apiKey; }
    public String getChecksumKey() { return checksumKey; }

    public boolean isClientIdConfigured() { return isFilled(clientId); }
    public boolean isApiKeyConfigured() { return isFilled(apiKey); }
    public boolean isChecksumKeyConfigured() { return isFilled(checksumKey); }

    public PayOSConfigState toState() {
        return PayOSConfigState.fromRawValues(clientId, apiKey, checksumKey);
    }

    private static boolean isFilled(String value) {
        return value != null && !value.trim().isEmpty();
    }

    /** Không bao giờ in giá trị thật — chặn rò rỉ nếu vô tình bị log hoặc nối chuỗi. */
    @Override
    public String toString() {
        return "PayOSCredentials[REDACTED]";
    }
}
