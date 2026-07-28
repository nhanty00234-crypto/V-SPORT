package org.example.service.refund;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class RefundServiceTest {

    private RefundService refundService;

    @BeforeEach
    void setUp() {
        refundService = new RefundService();
    }

    @Test
    void testRequestRefundInvalidAmountFails() {
        RefundService.RefundResult result = refundService.requestRefund(
                100, 5, BigDecimal.ZERO, "Khách đổi ý"
        );
        assertFalse(result.success);
        assertTrue(result.message.contains("lớn hơn 0"));
    }

    @Test
    void testRequestRefundNegativeAmountFails() {
        RefundService.RefundResult result = refundService.requestRefund(
                100, 5, new BigDecimal("-50000"), "Khách đổi ý"
        );
        assertFalse(result.success);
        assertTrue(result.message.contains("lớn hơn 0"));
    }

    @Test
    void testRejectRefundWithoutReasonFails() {
        RefundService.RefundResult result = refundService.rejectRefund(
                50, 1, "Ngắn"
        );
        assertFalse(result.success);
        assertTrue(result.message.contains("5 ký tự"));
    }

    @Test
    void testRejectRefundNullReasonFails() {
        RefundService.RefundResult result = refundService.rejectRefund(
                50, 1, null
        );
        assertFalse(result.success);
        assertTrue(result.message.contains("5 ký tự"));
    }
}
