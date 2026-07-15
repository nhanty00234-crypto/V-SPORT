package org.example.scheduler;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Khởi tạo/tắt scheduler quét vòng đời đặt sân mỗi 60 giây (P0-1: trước đây KHÔNG có scheduler
 * thật sự - sweep chỉ chạy lazy, gắn kèm side effect nguy hiểm vào các hàm đọc danh sách).
 *
 * scheduleWithFixedDelay đảm bảo không có hai lần chạy chồng nhau trong CÙNG một JVM (lần kế
 * tiếp chỉ bắt đầu sau khi lần trước hoàn tất). Triển khai thực tế của dự án là một Tomcat
 * instance duy nhất (start_server.bat, một CATALINA_HOME) nên đây là đủ; nếu sau này chạy nhiều
 * instance song song, cần thêm khóa cấp DB (vd sp_getapplock) - xem báo cáo cuối cùng.
 */
@WebListener
public class BookingSchedulerListener implements ServletContextListener {

    private static final Logger logger = LogManager.getLogger(BookingSchedulerListener.class);
    private static final long INITIAL_DELAY_SECONDS = 10;
    private static final long PERIOD_SECONDS = 60;

    private ScheduledExecutorService executor;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "booking-expiry-scheduler");
            t.setDaemon(true);
            return t;
        });
        executor.scheduleWithFixedDelay(BookingExpiryScheduler::runSweep, INITIAL_DELAY_SECONDS, PERIOD_SECONDS, TimeUnit.SECONDS);
        logger.info("BookingSchedulerListener: scheduler khởi động, chu kỳ {}s.", PERIOD_SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (executor == null) return;
        executor.shutdown();
        try {
            if (!executor.awaitTermination(10, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
            Thread.currentThread().interrupt();
        }
        logger.info("BookingSchedulerListener: scheduler đã dừng.");
    }
}
