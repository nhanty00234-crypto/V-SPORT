package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ResetTestPasswordTest {

    @Test
    void resetPassword() throws Exception {
        System.out.println("=== RESETTING TEST PASSWORD ===");
        String newPassword = "123456";
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));

        String sql = "UPDATE dbo.Accounts SET Password = ? WHERE Username = ? AND CoSoID = 7;";

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, hashedPassword);
                ps.setString(2, "Long01");
                int rows = ps.executeUpdate();
                System.out.println("Updated " + rows + " rows.");
                assertTrue(rows > 0, "Should update at least one staff account");
            }
        }
        System.out.println("=== PASSWORD RESET COMPLETED ===");
    }
}
