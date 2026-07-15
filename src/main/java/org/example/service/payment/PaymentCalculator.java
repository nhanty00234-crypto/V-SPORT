package org.example.service.payment;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Nguồn công thức duy nhất cho số tiền còn phải thu, dùng chung bởi mọi phương thức
 * thanh toán (tiền mặt, chuyển khoản, PayOS, QR): remainingAmount = max(grossTotal - paidAmount, 0).
 */
public final class PaymentCalculator {

    private PaymentCalculator() {
    }

    public static BigDecimal remainingAmount(BigDecimal grossTotal, BigDecimal alreadyPaid) {
        return nz(grossTotal).subtract(nz(alreadyPaid)).max(BigDecimal.ZERO).setScale(0, RoundingMode.HALF_UP);
    }

    public static boolean isFullyCovered(BigDecimal grossTotal, BigDecimal alreadyPaid) {
        return remainingAmount(grossTotal, alreadyPaid).signum() == 0;
    }

    private static BigDecimal nz(BigDecimal n) {
        return n == null ? BigDecimal.ZERO : n;
    }
}
