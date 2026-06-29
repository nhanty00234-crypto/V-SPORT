import java.sql.*;

public class TestDB2 {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;";
        // Assuming we need username/password, but in DBUtil it gets from persistence.xml or directly.
        // Wait, DBUtil uses HikariCP and properties file or just hardcoded?
        // Let's just use DBUtil to get connection!
    }
}
