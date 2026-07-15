package org.example.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class DBUtil {
    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    private static HikariDataSource dataSource;
    private static final Logger logger = LogManager.getLogger(DBUtil.class);

    private static String getConfig(String envName, String propertyName) {
        String val = System.getenv(envName);
        if (val == null || val.trim().isEmpty()) {
            val = System.getProperty(propertyName);
        }
        if (val == null || val.trim().isEmpty()) {
            throw new IllegalStateException("Cấu hình bắt buộc bị thiếu: env " + envName + " hoặc system property " + propertyName);
        }
        return val.trim();
    }

    static {
        try {
            URL = getConfig("DB_URL", "db.url");
            USER = getConfig("DB_USERNAME", "db.username");
            PASSWORD = getConfig("DB_PASSWORD", "db.password");

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(URL);
            config.setUsername(USER);
            config.setPassword(PASSWORD);
            config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Connection pool settings for performance
            config.setMaximumPoolSize(20);
            config.setMinimumIdle(5);
            config.setIdleTimeout(300000);
            config.setConnectionTimeout(30000); // 30 seconds
            config.setMaxLifetime(1800000);

            // Optimization for SQL Server
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            logger.info("DBUtil: HikariCP data source initialized successfully");
        } catch (Exception e) {
            logger.error("DBUtil: Failed to initialize HikariCP data source", e);
            throw new RuntimeException("Error initializing HikariCP data source", e);
        }
    }

    public static Connection getConnection() {
        try {
            return dataSource.getConnection();
        } catch (SQLException e) {
            logger.error("DBUtil: Failed to get database connection", e);
            throw new IllegalStateException("Không thể kết nối cơ sở dữ liệu.", e);
        }
    }

    public static String getURL() { return URL; }
    public static String getUSER() { return USER; }
    public static String getPASSWORD() { return PASSWORD; }
}

