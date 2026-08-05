package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Chạy sql/migration_qr_request_payment.sql trên DB thật rồi xác nhận
 * constraint CK_QRRequest_Type đã chấp nhận PAYMENT_REQUEST. Idempotent,
 * an toàn chạy lại - theo đúng convention RunSanQRMigrationTest.java.
 */
class RunQRRequestPaymentMigrationTest {

    @Test
    void runMigrationAndVerify() throws Exception {
        System.out.println("=== STARTING QRRequest PAYMENT MIGRATION RUNNER ===");
        String content = new String(Files.readAllBytes(Paths.get("sql/migration_qr_request_payment.sql")));

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
            assertNotNull(conn, "Database connection should not be null");
            try (Statement stmt = conn.createStatement()) {
                for (int i = 0; i < batches.size(); i++) {
                    System.out.println("Executing Batch " + (i + 1) + " of " + batches.size() + "...");
                    stmt.execute(batches.get(i));
                }
            }

            String definition;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT definition FROM sys.check_constraints WHERE name = 'CK_QRRequest_Type' " +
                    "AND parent_object_id = OBJECT_ID('dbo.QRRequest')")) {
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next(), "CK_QRRequest_Type constraint phải tồn tại sau migration");
                    definition = rs.getString("definition");
                }
            }
            assertTrue(definition != null && definition.contains("PAYMENT_REQUEST"),
                "CK_QRRequest_Type phải chấp nhận PAYMENT_REQUEST, thực tế: " + definition);
            System.out.println("SUCCESS: CK_QRRequest_Type now allows PAYMENT_REQUEST!");
        }
        System.out.println("=== QRRequest PAYMENT MIGRATION RUNNER COMPLETED ===");
    }
}
