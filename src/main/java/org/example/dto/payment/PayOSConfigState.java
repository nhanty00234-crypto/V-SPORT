package org.example.dto.payment;

public enum PayOSConfigState {
    NOT_CONFIGURED,
    PARTIAL,
    CONFIGURED;

    public static PayOSConfigState fromRawValues(String clientId, String apiKey, String checksumKey) {
        int filled = 0;
        if (isFilled(clientId)) filled++;
        if (isFilled(apiKey)) filled++;
        if (isFilled(checksumKey)) filled++;
        if (filled == 0) return NOT_CONFIGURED;
        if (filled == 3) return CONFIGURED;
        return PARTIAL;
    }

    private static boolean isFilled(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
