package org.example.dto.payment;

import java.math.BigDecimal;

public final class PayOSPaymentAttemptView {
    private final int hoaDonId;
    private final long orderCode;
    private final String paymentLinkId;
    private final String checkoutUrl;
    private final String qrCode;
    private final BigDecimal amount;
    private final String description;
    private final PayOSPaymentAttemptStatus status;

    public PayOSPaymentAttemptView(int hoaDonId, long orderCode, String paymentLinkId, String checkoutUrl,
                                    String qrCode, BigDecimal amount, String description,
                                    PayOSPaymentAttemptStatus status) {
        this.hoaDonId = hoaDonId;
        this.orderCode = orderCode;
        this.paymentLinkId = paymentLinkId;
        this.checkoutUrl = checkoutUrl;
        this.qrCode = qrCode;
        this.amount = amount;
        this.description = description;
        this.status = status;
    }

    public int getHoaDonId() { return hoaDonId; }
    public long getOrderCode() { return orderCode; }
    public String getPaymentLinkId() { return paymentLinkId; }
    public String getCheckoutUrl() { return checkoutUrl; }
    public String getQrCode() { return qrCode; }
    public BigDecimal getAmount() { return amount; }
    public String getDescription() { return description; }
    public PayOSPaymentAttemptStatus getStatus() { return status; }
}
