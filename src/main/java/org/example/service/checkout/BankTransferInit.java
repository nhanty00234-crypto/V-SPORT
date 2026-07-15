package org.example.service.checkout;

import java.math.BigDecimal;

/** Kết quả khởi tạo/chốt yêu cầu chuyển khoản cho một hóa đơn - amount là số tiền còn phải thu (đã trừ paidAmount). */
public record BankTransferInit(int datSanId, int hoaDonId, BigDecimal amount, BigDecimal paidAmount,
                                String paymentReference) {
}
