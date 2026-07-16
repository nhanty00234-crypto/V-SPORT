package org.example.util;

public final class SecretMaskUtil {
    private SecretMaskUtil() {}

    public static String mask(String value) {
        if (value == null || value.isEmpty()) return null;
        if (value.length() <= 8) return "••••";
        return value.substring(0, 4) + "••••" + value.substring(value.length() - 4);
    }
}
