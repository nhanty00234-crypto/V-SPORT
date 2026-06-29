<%@ page import="java.sql.*" %>
<%@ page import="org.example.util.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Test DB</title></head>
<body>
    <h2>Test DB Connection & Query</h2>
    <%
        try (Connection conn = DBUtil.getConnection()) {
            out.println("<p>Connection: OK</p>");
            
            // Query San
            String sanSql = "SELECT SanID, TenSan, LoaiSanID, CoSoID, TrangThai, MoTa, HinhAnh FROM San ORDER BY CoSoID, SanID";
            try (PreparedStatement ps = conn.prepareStatement(sanSql);
                 ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;
                }
                out.println("<p>San count: " + count + "</p>");
            } catch (Exception ex) {
                out.println("<p style='color:red;'>SQL San Error: " + ex.getMessage() + "</p>");
                ex.printStackTrace(new java.io.PrintWriter(out));
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Connection Error: " + e.getMessage() + "</p>");
            e.printStackTrace(new java.io.PrintWriter(out));
        }
    %>
</body>
</html>
