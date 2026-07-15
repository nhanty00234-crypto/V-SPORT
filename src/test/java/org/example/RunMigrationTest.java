package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.io.IOException;
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

class RunMigrationTest {

    @Test
    void runMigrationAndVerify() throws Exception {
        System.out.println("=== STARTING MIGRATION RUNNER ===");
        String sqlFilePath = "sql/migration_payos_payment_attempt.sql";
        String content = new String(Files.readAllBytes(Paths.get(sqlFilePath)));

        // Split by "GO" case-insensitively on its own line (using multiline flag ?m)
        String[] rawBatches = content.split("(?im)^\\s*GO\\s*$");
        List<String> batches = new ArrayList<>();
        for (String raw : rawBatches) {
            String clean = raw.trim();
            // Remove USE statement as the database name is already specified in the JDBC URL connection string
            if (clean.toUpperCase().startsWith("USE ")) {
                int nextLine = clean.indexOf('\n');
                if (nextLine != -1) {
                    clean = clean.substring(nextLine).trim();
                } else {
                    clean = "";
                }
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
                    String sqlBatch = batches.get(i);
                    System.out.println("Executing Batch " + (i + 1) + " of " + batches.size() + "...");
                    stmt.execute(sqlBatch);
                }
            }

            // Verification
            DatabaseMetaData metaData = conn.getMetaData();
            boolean tableExists = false;
            try (ResultSet tables = metaData.getTables(null, null, "PayOSPaymentAttempt", null)) {
                if (tables.next()) {
                    tableExists = true;
                }
            }

            assertTrue(tableExists, "Table PayOSPaymentAttempt must exist after migration");
            System.out.println("SUCCESS: Table PayOSPaymentAttempt exists!");

            // Print columns
            System.out.println("Columns in PayOSPaymentAttempt:");
            try (ResultSet cols = metaData.getColumns(null, null, "PayOSPaymentAttempt", null)) {
                while (cols.next()) {
                    String colName = cols.getString("COLUMN_NAME");
                    String colType = cols.getString("TYPE_NAME");
                    int size = cols.getInt("COLUMN_SIZE");
                    System.out.println("  - " + colName + " (" + colType + ", size=" + size + ")");
                }
            }
        }
        System.out.println("=== MIGRATION RUNNER COMPLETED ===");
    }
}
