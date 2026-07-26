package org.example.service;

import org.example.dao.ThongBaoDAO;
import org.example.model.ThongBao;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class NotificationServiceTest {

    private ThongBaoDAO dao;
    private NotificationService service;

    @BeforeEach
    void setUp() {
        dao = Mockito.mock(ThongBaoDAO.class);
        service = new NotificationService(dao);
    }

    // Test 1: BOOKING_CREATED insert đúng Customer AccountID, MaBanGhi, LoaiThongBao
    @Test
    void testBookingCreated_insertsCorrectAttributes() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(anyInt(), anyString(), anyString())).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(101);

        service.notifyBookingCreated(10, 125, false);

        ArgumentCaptor<ThongBao> captor = ArgumentCaptor.forClass(ThongBao.class);
        verify(dao).insert(captor.capture());
        ThongBao tb = captor.getValue();

        assertEquals(10, tb.getAccountId());
        assertEquals("BOOKING_CREATED", tb.getLoaiThongBao());
        assertEquals("125", tb.getMaBanGhi());
        assertTrue(tb.getNoiDung().contains("#125"));
    }

    // Test 2: BOOKING_CONFIRMED insert đúng
    @Test
    void testBookingConfirmed_insertsCorrectAttributes() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(anyInt(), anyString(), anyString())).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(102);

        service.notifyBookingConfirmed(10, 125);

        ArgumentCaptor<ThongBao> captor = ArgumentCaptor.forClass(ThongBao.class);
        verify(dao).insert(captor.capture());
        ThongBao tb = captor.getValue();

        assertEquals(10, tb.getAccountId());
        assertEquals("BOOKING_CONFIRMED", tb.getLoaiThongBao());
        assertEquals("125", tb.getMaBanGhi());
    }

    // Test 3: BOOKING_REJECTED chứa lý do
    @Test
    void testBookingRejected_containsReason() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(anyInt(), anyString(), anyString())).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(103);

        service.notifyBookingRejected(10, 125, "Sân đang bảo trì khẩn cấp");

        ArgumentCaptor<ThongBao> captor = ArgumentCaptor.forClass(ThongBao.class);
        verify(dao).insert(captor.capture());
        ThongBao tb = captor.getValue();

        assertEquals(10, tb.getAccountId());
        assertEquals("BOOKING_REJECTED", tb.getLoaiThongBao());
        assertEquals("125", tb.getMaBanGhi());
        assertTrue(tb.getNoiDung().contains("Sân đang bảo trì khẩn cấp"));
    }

    // Test 4: Duplicate cùng event không tạo bản ghi thứ hai
    @Test
    void testDuplicateSameEvent_skipsInsert() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(10, "BOOKING_CREATED", "125")).thenReturn(true);

        int result = service.sendNotification(10, "Tên", "Nội dung", "BOOKING_CREATED", "125", "/path");

        assertEquals(1, result);
        verify(dao, never()).insert(any());
    }

    // Test 5: Cùng booking nhưng CREATED và CONFIRMED tạo được hai bản ghi
    @Test
    void testSameBooking_differentEventsCreateDistinctRecords() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(eq(10), eq("BOOKING_CREATED"), eq("125"))).thenReturn(false);
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(eq(10), eq("BOOKING_CONFIRMED"), eq("125"))).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(201).thenReturn(202);

        service.notifyBookingCreated(10, 125, false);
        service.notifyBookingConfirmed(10, 125);

        ArgumentCaptor<ThongBao> captor = ArgumentCaptor.forClass(ThongBao.class);
        verify(dao, times(2)).insert(captor.capture());

        assertEquals("BOOKING_CREATED", captor.getAllValues().get(0).getLoaiThongBao());
        assertEquals("BOOKING_CONFIRMED", captor.getAllValues().get(1).getLoaiThongBao());
        assertEquals("125", captor.getAllValues().get(0).getMaBanGhi());
        assertEquals("125", captor.getAllValues().get(1).getMaBanGhi());
    }

    // Test 6: DAO insert trả 0 -> Service báo failure, không im lặng success
    @Test
    void testDaoInsertReturnsZero_serviceReportsFailure() {
        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(anyInt(), anyString(), anyString())).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(0);

        int result = service.sendNotification(10, "Tiêu đề", "Nội dung", "BOOKING_CREATED", "125", "/path");

        assertEquals(0, result);
    }

    // Test 7: Manager AccountID không bị dùng làm recipient
    @Test
    void testManagerAccountId_notUsedAsRecipient() {
        int customerAccountId = 10;
        int managerAccountId = 99;

        when(dao.existsByAccountIdAndLoaiAndMaBanGhi(anyInt(), anyString(), anyString())).thenReturn(false);
        when(dao.insert(any(ThongBao.class))).thenReturn(301);

        service.notifyBookingConfirmed(customerAccountId, 125);

        ArgumentCaptor<ThongBao> captor = ArgumentCaptor.forClass(ThongBao.class);
        verify(dao).insert(captor.capture());

        assertEquals(customerAccountId, captor.getValue().getAccountId());
        assertNotEquals(managerAccountId, captor.getValue().getAccountId());
    }
}
