package org.example.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Khởi động ứng dụng: chạy các migration schema nhỏ, idempotent.
 * Không dùng hbm2ddl vì Hibernate entity có thể ánh xạ cột chưa có trong DB.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    private static final Logger logger = LogManager.getLogger(AppStartupListener.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        addHoaDonGhiChuColumn();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // không cần dọn dẹp
    }

    /**
     * Thêm cột GhiChu vào bảng dbo.HoaDon nếu chưa tồn tại.
     * HoaDon.java có @Column(name="GhiChu") nhưng cột chưa được tạo trong DB,
     * khiến Hibernate ném "Invalid column name 'GhiChu'" khi em.find(HoaDon.class, id).
     */
    private void addHoaDonGhiChuColumn() {
        String checkSql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoaDon') AND name = 'GhiChu'";
        String alterSql = "ALTER TABLE dbo.HoaDon ADD GhiChu NVARCHAR(500) NULL";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                try (Statement st = conn.createStatement()) {
                    st.execute(alterSql);
                    logger.info("AppStartupListener: Đã thêm cột GhiChu vào bảng dbo.HoaDon.");
                }
            } else {
                logger.debug("AppStartupListener: Cột GhiChu đã tồn tại trong dbo.HoaDon, bỏ qua migration.");
            }
        } catch (Exception e) {
            logger.error("AppStartupListener: Lỗi khi kiểm tra/thêm cột GhiChu vào dbo.HoaDon: {}", e.getMessage(), e);
        }
    }
}
