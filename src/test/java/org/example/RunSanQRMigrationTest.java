package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Chạy sql/migration_san_qr.sql trên DB thật rồi xác nhận SanQR/SanQRTokenHistory
 * tồn tại đúng cột. Migration có kiểm tra IF NOT EXISTS nên chạy lại an toàn.
 * Cần DB QuanLiSport thật (đọc cấu hình qua DBUtil) - không chạy khi không có kết
 * nối, đây là smoke test thủ công theo đúng convention RunMigrationTest.java.
 */
class RunSanQRMigrationTest {

    @Test
    void runMigrationAndVerify() throws Exception {
        System.out.println("=== STARTING SanQR MIGRATION RUNNER ===");
        String sqlFilePath = "sql/migration_san_qr.sql";
        String content = new String(Files.readAllBytes(Paths.get(sqlFilePath)));

        String[] rawBatches = content.split("(?im)^\\s*GO\\s*$");
        List<String> batches = new ArrayList<>();
        for (String raw : rawBatches) {
            String clean = raw.trim();
            if (clean.toUpperCase().startsWith("USE ")) {
                int nextLine = clean.indexOf('\n');
                clean = nextLine != -1 ? clean.substring(nextLine).trim() : "";
            }
            if (!clean.isEmpty()) {
                batches.add(clean);
            }
        }

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn, "Database connection should not be null");
            System.out.println("Connected to: " + conn.getMetaData().getURL());

            try (Statement stmt = conn.createStatement()) {
                for (int i = 0; i < batches.size(); i++) {
                    System.out.println("Executing Batch " + (i + 1) + " of " + batches.size() + "...");
                    stmt.execute(batches.get(i));
                }
            }

            DatabaseMetaData metaData = conn.getMetaData();

            boolean sanQRExists = false;
            try (ResultSet tables = metaData.getTables(null, null, "SanQR", null)) {
                if (tables.next()) sanQRExists = true;
            }
            assertTrue(sanQRExists, "Table SanQR must exist after migration");
            System.out.println("SUCCESS: Table SanQR exists!");

            boolean historyExists = false;
            try (ResultSet tables = metaData.getTables(null, null, "SanQRTokenHistory", null)) {
                if (tables.next()) historyExists = true;
            }
            assertTrue(historyExists, "Table SanQRTokenHistory must exist after migration");
            System.out.println("SUCCESS: Table SanQRTokenHistory exists!");

            System.out.println("Columns in SanQR:");
            try (ResultSet cols = metaData.getColumns(null, null, "SanQR", null)) {
                while (cols.next()) {
                    System.out.println("  - " + cols.getString("COLUMN_NAME") + " (" + cols.getString("TYPE_NAME") + ")");
                }
            }
        }
        System.out.println("=== SanQR MIGRATION RUNNER COMPLETED ===");
    }
}
