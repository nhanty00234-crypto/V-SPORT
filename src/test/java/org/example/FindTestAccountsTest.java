package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class FindTestAccountsTest {

    @Test
    void findAccounts() throws Exception {
        System.out.println("=== SEARCHING FOR TEST ACCOUNTS ===");
        String sql = "SELECT AccountID, Username, FullName, RoleID, CoSoID, IsLocked, IsDeleted " +
                "FROM dbo.Accounts " +
                "WHERE CoSoID = 7 AND RoleID IN (1, 2, 4);";

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int accId = rs.getInt("AccountID");
                    String username = rs.getString("Username");
                    String fullName = rs.getString("FullName");
                    int roleId = rs.getInt("RoleID");
                    int coSoId = rs.getInt("CoSoID");
                    boolean isLocked = rs.getBoolean("IsLocked");
                    boolean isDeleted = rs.getBoolean("IsDeleted");

                    System.out.printf("AccountID: %d | Username: %s | FullName: %s | RoleID: %d | CoSoID: %d | Locked: %b | Deleted: %b%n",
                            accId, username, fullName, roleId, coSoId, isLocked, isDeleted);
                }
            }
        }
        System.out.println("=== SEARCH COMPLETED ===");
    }
}
