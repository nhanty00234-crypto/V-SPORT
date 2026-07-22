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
 * Chạy sql/migration_san_qr_hardening.sql trên DB thật rồi xác nhận cột
 * ShortCode/TokenHash tồn tại. Migration idempotent (kiểm tra IF NOT EXISTS
 * trước khi ALTER), an toàn chạy lại.
 */
class RunSanQRHardeningMigrationTest {

    @Test
    void runMigrationAndVerify() throws Exception {
        System.out.println("=== STARTING SanQR HARDENING MIGRATION RUNNER ===");
        String content = new String(Files.readAllBytes(Paths.get("sql/migration_san_qr_hardening.sql")));

        String[] rawBatches = content.split("(?im)^\\s*GO\\s*$");
        List<String> batches = new ArrayList<>();
        for (String raw : rawBatches) {
            String clean = raw.trim();
            if (clean.toUpperCase().startsWith("USE ")) {
                int nextLine = clean.indexOf('\n');
                clean = nextLine != -1 ? clean.substring(nextLine).trim() : "";
            }
            if (!clean.isEmpty()) batches.add(clean);
        }

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            try (Statement stmt = conn.createStatement()) {
                for (int i = 0; i < batches.size(); i++) {
                    System.out.println("Executing Batch " + (i + 1) + " of " + batches.size() + "...");
                    stmt.execute(batches.get(i));
                }
            }

            DatabaseMetaData metaData = conn.getMetaData();
            boolean shortCodeExists = false;
            try (ResultSet cols = metaData.getColumns(null, null, "SanQR", "ShortCode")) {
                if (cols.next()) shortCodeExists = true;
            }
            assertTrue(shortCodeExists, "SanQR.ShortCode phải tồn tại sau migration");
            System.out.println("SUCCESS: SanQR.ShortCode exists!");

            boolean tokenHashExists = false;
            try (ResultSet cols = metaData.getColumns(null, null, "SanQRTokenHistory", "TokenHash")) {
                if (cols.next()) tokenHashExists = true;
            }
            assertTrue(tokenHashExists, "SanQRTokenHistory.TokenHash phải tồn tại sau migration");
            System.out.println("SUCCESS: SanQRTokenHistory.TokenHash exists!");
        }
        System.out.println("=== SanQR HARDENING MIGRATION RUNNER COMPLETED ===");
    }
}
