package org.example.service.billing;

import org.example.dao.CheckInDAO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class ServiceBillSeparationServiceTest {

    private CheckInDAO checkInDAO;
    private ServiceBillSeparationService service;

    @BeforeEach
    void setUp() {
        checkInDAO = mock(CheckInDAO.class);
        service = new ServiceBillSeparationService(checkInDAO);
    }

    @Test
    void testSplitServiceBillSuccess() throws Exception {
        when(checkInDAO.addServicesSplitBill(eq(100), any(), any(), eq(true), eq("Tiền mặt"), eq(5), eq(1)))
                .thenReturn(999);

        int[] productIds = new int[]{1, 2};
        int[] quantities = new int[]{2, 1};

        ServiceBillSeparationService.SplitBillResult result = service.splitServiceBill(
                100, productIds, quantities, true, "Tiền mặt", 5, 1);

        assertTrue(result.success);
        assertEquals(999, result.splitHoaDonId);
        assertTrue(result.message.contains("999"));
    }

    @Test
    void testSplitServiceBillValidationError() throws Exception {
        when(checkInDAO.addServicesSplitBill(anyInt(), any(), any(), anyBoolean(), any(), anyInt(), anyInt()))
                .thenThrow(new CheckInDAO.CheckInException("Sản phẩm không đủ tồn kho."));

        int[] productIds = new int[]{1};
        int[] quantities = new int[]{50};

        ServiceBillSeparationService.SplitBillResult result = service.splitServiceBill(
                100, productIds, quantities, false, null, 5, 1);

        assertFalse(result.success);
        assertNull(result.splitHoaDonId);
        assertEquals("Sản phẩm không đủ tồn kho.", result.message);
    }

    @Test
    void testSplitServiceBillSystemException() throws Exception {
        when(checkInDAO.addServicesSplitBill(anyInt(), any(), any(), anyBoolean(), any(), anyInt(), anyInt()))
                .thenThrow(new RuntimeException("Database connection timeout"));

        int[] productIds = new int[]{1};
        int[] quantities = new int[]{1};

        ServiceBillSeparationService.SplitBillResult result = service.splitServiceBill(
                100, productIds, quantities, false, null, 5, 1);

        assertFalse(result.success);
        assertNull(result.splitHoaDonId);
        assertTrue(result.message.contains("Database connection timeout"));
    }
}
