package org.example.service.payment;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class PaymentCalculatorTest {

    @Test void remainingAmount_noDeposit_returnsFullGross() {
        assertEquals(new BigDecimal("500000"),
                PaymentCalculator.remainingAmount(new BigDecimal("500000"), BigDecimal.ZERO));
    }

    @Test void remainingAmount_partialDeposit_subtractsDeposit() {
        assertEquals(new BigDecimal("300000"),
                PaymentCalculator.remainingAmount(new BigDecimal("500000"), new BigDecimal("200000")));
    }

    @Test void remainingAmount_depositEqualsGross_returnsZero() {
        assertEquals(0, BigDecimal.ZERO.compareTo(
                PaymentCalculator.remainingAmount(new BigDecimal("500000"), new BigDecimal("500000"))));
    }

    @Test void remainingAmount_depositExceedsGross_clampedToZeroNotNegative() {
        assertEquals(0, BigDecimal.ZERO.compareTo(
                PaymentCalculator.remainingAmount(new BigDecimal("500000"), new BigDecimal("999999"))));
    }

    @Test void remainingAmount_nullInputs_treatedAsZero() {
        assertEquals(0, BigDecimal.ZERO.compareTo(PaymentCalculator.remainingAmount(null, null)));
        assertEquals(new BigDecimal("100000"), PaymentCalculator.remainingAmount(new BigDecimal("100000"), null));
    }

    @Test void isFullyCovered_trueWhenRemainingZero() {
        assertTrue(PaymentCalculator.isFullyCovered(new BigDecimal("500000"), new BigDecimal("500000")));
        assertTrue(PaymentCalculator.isFullyCovered(new BigDecimal("500000"), new BigDecimal("600000")));
    }

    @Test void isFullyCovered_falseWhenRemainingPositive() {
        assertFalse(PaymentCalculator.isFullyCovered(new BigDecimal("500000"), new BigDecimal("100000")));
    }
}
