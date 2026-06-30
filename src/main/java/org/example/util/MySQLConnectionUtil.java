package org.example.util;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Tiện ích kết nối đã chuyển hướng sang SQL Server (DBUtil) để chạy trực tiếp trên database của dự án.
 */
public class MySQLConnectionUtil {
    public static Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }
}
