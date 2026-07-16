package org.example;

import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class ListTablesTest {

    @Test
    void listTables() throws Exception {
        System.out.println("=== LISTING ALL TABLES ===");
        try (Connection conn = DBUtil.getConnection()) {
            assertNotNull(conn);
            DatabaseMetaData metaData = conn.getMetaData();
            try (ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"})) {
                while (tables.next()) {
                    String tableName = tables.getString("TABLE_NAME");
                    System.out.println("Table: " + tableName);
                }
            }
        }
        System.out.println("=== LISTING COMPLETED ===");
    }
}
