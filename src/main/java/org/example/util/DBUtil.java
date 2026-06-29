package org.example.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class DBUtil {
    private static final String URL = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
    private static final String USER = "sa";
    private static final String PASSWORD = "TOP1@iyounguru!";

    private static HikariDataSource dataSource;
    private static final Logger logger = LogManager.getLogger(DBUtil.class);

    static {
        try {
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
            return null;
        }
    }
}

