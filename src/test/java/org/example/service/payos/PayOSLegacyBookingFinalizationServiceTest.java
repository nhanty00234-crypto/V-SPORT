package org.example.service.payos;

import org.junit.jupiter.api.Test;

import static org.example.service.payos.PayOSLegacyBookingFinalizationService.StatusOutcome.*;
import static org.example.service.payos.PayOSLegacyBookingFinalizationService.classifyStatus;
import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * classifyStatus() là logic thuần (không chạm DB) tách ra từ confirmPaid() để kiểm thử được
 * không cần TEST_DB_URL - phần còn lại của confirmPaid() (khóa DB, tạo/lấy MAIN invoice,
 * ghi các cột thanh toán) cần một SQL Server thật, xem CheckoutServiceSplitBillIntegrationTest
 * cho các kịch bản đó (gated bởi TEST_DB_URL, không chạy trong môi trường này).
 */
class PayOSLegacyBookingFinalizationServiceTest {

    @Test void confirmed_isEligible() {
        assertEquals(ELIGIBLE, classifyStatus("Chờ thanh toán"));
    }

    @Test void expiredByScheduler_stillEligible_paymentArrivedConcurrentlyMustNotBeLost() {
        assertEquals(ELIGIBLE, classifyStatus("Quá hạn"));
    }

    @Test void alreadyConfirmed_idempotentLookup() {
        assertEquals(ALREADY_CONFIRMED, classifyStatus("Đã xác nhận"));
    }

    @Test void explicitlyCancelled_neverAutoReconfirmed() {
        assertEquals(CANCELLED, classifyStatus("Đã hủy"));
    }

    @Test void anyOtherStatus_rejectedAsUnexpected() {
        assertEquals(UNEXPECTED, classifyStatus("Đang sử dụng"));
        assertEquals(UNEXPECTED, classifyStatus("Đã hoàn thành"));
        assertEquals(UNEXPECTED, classifyStatus("Không đến"));
    }
}
