package org.example.service;

public class PayOSCheckoutSession {
    public final String checkoutUrl;
    public final String qrCode;
    public final Long expiredAt;
    public final long amount;

    public PayOSCheckoutSession(String checkoutUrl, String qrCode, Long expiredAt, long amount) {
        this.checkoutUrl = checkoutUrl;
        this.qrCode = qrCode;
        this.expiredAt = expiredAt;
        this.amount = amount;
    }
}
