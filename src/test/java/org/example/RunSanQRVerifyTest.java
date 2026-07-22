package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Chạy sql/verify_san_qr.sql trên DB thật và in kết quả từng SELECT ra console
 * để kiểm tra thủ công (script này chỉ đọc, không assert cứng vì nội dung phụ
 * thuộc dữ liệu hiện có trên DB, không phải trạng thái cố định).
 */
class RunSanQRVerifyTest {

    @Test
    void runVerifyAndPrint() throws Exception {
        System.out.println("=== STARTING SanQR VERIFY RUNNER ===");
        String content = new String(Files.readAllBytes(Paths.get("sql/verify_san_qr.sql")));

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
            try (Statement stmt = conn.createStatement()) {
                for (String batch : batches) {
                    boolean hasResult = stmt.execute(batch);
                    if (hasResult) {
                        try (ResultSet rs = stmt.getResultSet()) {
                            printResultSet(rs);
                        }
                    }
                }
            }
        }
        System.out.println("=== SanQR VERIFY RUNNER COMPLETED ===");
    }

    private void printResultSet(ResultSet rs) throws Exception {
        ResultSetMetaData meta = rs.getMetaData();
        int cols = meta.getColumnCount();
        StringBuilder header = new StringBuilder();
        for (int i = 1; i <= cols; i++) {
            if (i > 1) header.append(" | ");
            header.append(meta.getColumnLabel(i));
        }
        System.out.println(header);
        int rowCount = 0;
        while (rs.next()) {
            rowCount++;
            StringBuilder row = new StringBuilder();
            for (int i = 1; i <= cols; i++) {
                if (i > 1) row.append(" | ");
                row.append(rs.getString(i));
            }
            System.out.println(row);
        }
        System.out.println("(" + rowCount + " dòng)");
        System.out.println("---");
    }
}
