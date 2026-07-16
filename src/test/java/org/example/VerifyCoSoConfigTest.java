package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class VerifyCoSoConfigTest {

    @Test
    void verifyCoSoConfigurations() throws Exception {
        System.out.println("=== VERIFYING COSO PAYOS CONFIGURATION ===");
        String sql = "SELECT " +
                "    CoSoID, " +
                "    TenCoSo, " +
                "    CASE WHEN NULLIF(LTRIM(RTRIM(PayOS_ClientID)), '') IS NULL " +
                "         THEN 0 ELSE 1 END AS ClientConfigured, " +
                "    CASE WHEN NULLIF(LTRIM(RTRIM(PayOS_ApiKey)), '') IS NULL " +
                "         THEN 0 ELSE 1 END AS ApiConfigured, " +
                "    CASE WHEN NULLIF(LTRIM(RTRIM(PayOS_ChecksumKey)), '') IS NULL " +
                "         THEN 0 ELSE 1 END AS ChecksumConfigured, " +
                "    LEN(PayOS_ClientID) AS ClientLength, " +
                "    LEN(PayOS_ApiKey) AS ApiLength, " +
                "    LEN(PayOS_ChecksumKey) AS ChecksumLength " +
                "FROM dbo.CoSo;";

        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("CoSoID");
                    String name = rs.getString("TenCoSo");
                    boolean clientOk = rs.getInt("ClientConfigured") == 1;
                    boolean apiOk = rs.getInt("ApiConfigured") == 1;
                    boolean checksumOk = rs.getInt("ChecksumConfigured") == 1;
                    int clientLen = rs.getInt("ClientLength");
                    int apiLen = rs.getInt("ApiLength");
                    int checksumLen = rs.getInt("ChecksumLength");

                    System.out.printf("CoSoID: %d | TenCoSo: %s | ClientConfigured: %b (len=%d) | ApiConfigured: %b (len=%d) | ChecksumConfigured: %b (len=%d)%n",
                            id, name, clientOk, clientLen, apiOk, apiLen, checksumOk, checksumLen);
                }
            }
        }
        System.out.println("=== COSO CONFIGURATION VERIFIED ===");
    }
}
