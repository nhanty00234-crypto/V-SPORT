package org.example.scheduler;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.service.BookingLifecycleService;

/**
 * Orchestrator gọi các sweep AN TOÀN của vòng đời đặt sân. KHÔNG BAO GIỜ tự hoàn thành một
 * booking "Đang sử dụng" hay tự giải phóng sân của ca chưa checkout - việc đó chỉ được phép
 * qua transaction checkout chính thức (CheckoutService). Chỉ xử lý:
 *   1. "Chờ xác nhận" quá hạn duyệt -> "Đã hủy" (LichDatSanDAOImpl.updateExpiredBookingsAndFields,
 *      cũng tự chữa lành San "mồ côi" như một tác dụng phụ an toàn - xem Javadoc của hàm đó).
 *   2. "Chờ thanh toán" quá hạn giữ chỗ -> "Quá hạn" (BookingLifecycleService.runExpirySweep).
 * Gọi được nhiều lần an toàn (idempotent) - mỗi lệnh UPDATE đều có điều kiện WHERE loại trừ
 * các dòng đã xử lý. Dùng chung bởi cả BookingSchedulerListener (định kỳ 60s) lẫn lazy sweep ở
 * các hàm đọc danh sách (CheckInDAO.getDanhSachSan, v.v.) - gọi trùng lặp không gây hại.
 */
public final class BookingExpiryScheduler {

    private static final Logger logger = LogManager.getLogger(BookingExpiryScheduler.class);

    private BookingExpiryScheduler() {
    }

    public static void runSweep() {
        try {
            LichDatSanDAOImpl.updateExpiredBookingsAndFields();
            BookingLifecycleService.runExpirySweep();
        } catch (Exception e) {
            // Sweep không được làm sập scheduler thread hay request đang gọi lazy sweep - log và bỏ qua,
            // lần chạy kế tiếp (60s sau, hoặc lần đọc danh sách kế tiếp) sẽ tự thử lại.
            logger.error("BookingExpiryScheduler.runSweep thất bại: {}", e.getMessage(), e);
        }
    }
}
