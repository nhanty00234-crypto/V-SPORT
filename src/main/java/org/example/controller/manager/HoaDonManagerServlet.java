package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/manager/hoa-don")
public class HoaDonManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(HoaDonManagerServlet.class);
    private static final com.google.gson.Gson gson = new com.google.gson.Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        if ("detail".equals(action)) {
            handleDetail(req, resp, user);
            return;
        }
        if ("stats".equals(action)) {
            handleStats(req, resp, user);
            return;
        }

        // Default: load invoice list
        String filterStatus = req.getParameter("filterStatus");
        String filterLoai    = req.getParameter("filterLoai");
        String filterFrom    = req.getParameter("filterFrom");
        String filterTo      = req.getParameter("filterTo");
        String filterSearch  = req.getParameter("filterSearch");
        String pageStr       = req.getParameter("page");
        int page = 1;
        try { if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr)); } catch (NumberFormatException ignored) {}
        int pageSize = 20;
        int offset   = (page - 1) * pageSize;

        List<Map<String, Object>> invoices = new ArrayList<>();
        int totalCount = 0;
        Map<String, Object> stats = new HashMap<>();

        try (Connection conn = DBUtil.getConnection()) {
            boolean hasLoaiHoaDon = columnExists(conn, "invoices", "invoice_type");
            boolean hasParentHoaDonID = columnExists(conn, "invoices", "parent_invoice_id");
            boolean hasGhiChu = columnExists(conn, "invoices", "note");
            // Stats
            String sqlStats = buildStatsSql(hasLoaiHoaDon);
            try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                ps.setInt(1, user.getCoSoId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        stats.put("totalCount",    rs.getInt("totalCount"));
                        stats.put("tongDoanhThu",  rs.getDouble("tongDoanhThu"));
                        stats.put("mainChuaTT",    rs.getInt("mainChuaTT"));
                        stats.put("splitChuaTT",   rs.getInt("splitChuaTT"));
                    }
                }
            }

            // Build WHERE clause
            StringBuilder where = new StringBuilder(
                "WHERE s.facility_id = ? ");
            List<Object> params = new ArrayList<>();
            params.add(user.getCoSoId());

            if (filterStatus != null && !filterStatus.isEmpty()) {
                where.append("AND hd.payment_status = ? ");
                params.add(filterStatus);
            }
            if (filterLoai != null && !filterLoai.isEmpty()) {
                if (!hasLoaiHoaDon) {
                    if (!"MAIN".equals(filterLoai)) {
                        where.append("AND 1 = 0 ");
                    }
                } else if ("MAIN".equals(filterLoai)) {
                    where.append("AND (hd.invoice_type = N'MAIN' OR hd.invoice_type IS NULL) ");
                } else {
                    where.append("AND hd.invoice_type = ? ");
                    params.add(filterLoai);
                }
            }
            if (filterFrom != null && !filterFrom.isEmpty()) {
                where.append("AND CAST(hd.issued_at AS DATE) >= ? ");
                params.add(filterFrom);
            }
            if (filterTo != null && !filterTo.isEmpty()) {
                where.append("AND CAST(hd.issued_at AS DATE) <= ? ");
                params.add(filterTo);
            }
            if (filterSearch != null && !filterSearch.trim().isEmpty()) {
                where.append("AND (CAST(hd.invoice_id AS NVARCHAR) LIKE ? OR acc.full_name LIKE ? OR s.court_name LIKE ?) ");
                String like = "%" + filterSearch.trim() + "%";
                params.add(like); params.add(like); params.add(like);
            }

            String baseQuery =
                "FROM invoices hd " +
                "INNER JOIN bookings lds ON hd.booking_id = lds.booking_id " +
                "INNER JOIN courts s ON lds.court_id = s.court_id " +
                "LEFT JOIN accounts acc ON lds.account_id = acc.account_id " +
                "LEFT JOIN accounts nv ON hd.staff_account_id = nv.account_id " +
                where;

            // Count
            String sqlCount = "SELECT COUNT(*) " + baseQuery;
            try (PreparedStatement ps = conn.prepareStatement(sqlCount)) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            // Data
            String sqlList =
                "SELECT hd.invoice_id, hd.booking_id, hd.issued_at, hd.court_total, hd.service_total, " +
                "hd.grand_total, hd.payment_status, hd.payment_method, " +
                (hasLoaiHoaDon ? "hd.invoice_type" : "CAST(N'MAIN' AS NVARCHAR(50))") + " AS invoice_type, " +
                (hasGhiChu ? "hd.note" : "CAST(NULL AS NVARCHAR(500))") + " AS note, " +
                (hasParentHoaDonID ? "hd.parent_invoice_id" : "CAST(NULL AS INT)") + " AS parent_invoice_id, " +
                "s.court_name, lds.booking_date, lds.start_time, lds.end_time, " +
                "acc.full_name AS TenKhachHang, nv.full_name AS TenNhanVien " +
                baseQuery +
                "ORDER BY hd.issued_at DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            List<Object> listParams = new ArrayList<>(params);
            listParams.add(offset);
            listParams.add(pageSize);
            try (PreparedStatement ps = conn.prepareStatement(sqlList)) {
                for (int i = 0; i < listParams.size(); i++) {
                    ps.setObject(i + 1, listParams.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new LinkedHashMap<>();
                        row.put("hoaDonId",          rs.getInt("invoice_id"));
                        row.put("datSanId",           rs.getInt("booking_id"));
                        row.put("ngayLap",            rs.getTimestamp("issued_at") != null
                                ? rs.getTimestamp("issued_at").toString().substring(0, 16) : "");
                        row.put("tongTienSan",        rs.getDouble("court_total"));
                        row.put("tongTienDichVu",     rs.getDouble("service_total"));
                        row.put("tongThanhToan",      rs.getDouble("grand_total"));
                        row.put("trangThai",          rs.getString("payment_status"));
                        row.put("phuongThuc",         rs.getString("payment_method"));
                        String loai = rs.getString("invoice_type");
                        row.put("loaiHoaDon",         loai == null ? "MAIN" : loai);
                        row.put("ghiChu",             rs.getString("note"));
                        row.put("parentHoaDonId",     rs.getObject("parent_invoice_id"));
                        row.put("tenSan",             rs.getString("court_name"));
                        row.put("ngayDat",            rs.getDate("booking_date") != null ? rs.getDate("booking_date").toString() : "");
                        row.put("gioBatDau",          rs.getTime("start_time") != null ? rs.getTime("start_time").toString().substring(0,5) : "");
                        row.put("gioKetThuc",         rs.getTime("end_time") != null ? rs.getTime("end_time").toString().substring(0,5) : "");
                        row.put("tenKhachHang",       rs.getString("TenKhachHang"));
                        row.put("tenNhanVien",        rs.getString("TenNhanVien"));
                        invoices.add(row);
                    }
                }
            }
        } catch (Exception e) {
            logger.error("HoaDonManagerServlet doGet error: {}", e.getMessage(), e);
            req.setAttribute("errorMsg", "Lỗi tải danh sách hóa đơn: " + e.getMessage());
        }

        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        List<Map<String, Object>> serviceProducts = loadServiceProducts(user.getCoSoId());
        List<Map<String, Object>> payableBookings = loadPayableBookings(user.getCoSoId());

        req.setAttribute("serviceProducts", serviceProducts);
        req.setAttribute("payableBookings", payableBookings);
        req.setAttribute("invoices",     invoices);
        req.setAttribute("stats",        stats);
        req.setAttribute("totalCount",   totalCount);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("currentPage",  page);
        req.setAttribute("filterStatus", filterStatus);
        req.setAttribute("filterLoai",   filterLoai);
        req.setAttribute("filterFrom",   filterFrom);
        req.setAttribute("filterTo",     filterTo);
        req.setAttribute("filterSearch", filterSearch);
        req.setAttribute("pageTitle",    "Quản lý hóa đơn");
        req.getRequestDispatcher("/manager/QuanLyHoaDon.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            resp.getWriter().write("{\"ok\":false,\"msg\":\"Không có quyền.\"}");
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("payInvoice".equals(action)) {
                int hoaDonId        = Integer.parseInt(req.getParameter("hoaDonId"));
                String paymentMethod = req.getParameter("phuongThucThanhToan");
                if (paymentMethod == null || paymentMethod.trim().isEmpty()) paymentMethod = "Tiền mặt";
                payInvoice(hoaDonId, user, paymentMethod);
                AuditLogService.log(req, user, AuditLogService.ACTION_UPDATE, AuditLogService.ENTITY_HOA_DON,
                        String.valueOf(hoaDonId), "Hóa đơn #" + hoaDonId,
                        "Manager thanh toán hóa đơn bằng " + paymentMethod + ".");
                resp.getWriter().write("{\"ok\":true,\"msg\":\"Đã thanh toán hóa đơn #" + hoaDonId + " thành công.\"}");
            } else if ("createServiceInvoice".equals(action)) {
                int newHoaDonId = createServiceInvoice(req, user);
                AuditLogService.log(req, user, AuditLogService.ACTION_CREATE, AuditLogService.ENTITY_HOA_DON,
                        String.valueOf(newHoaDonId), "Hóa đơn #" + newHoaDonId,
                        "Manager tạo hóa đơn dịch vụ.");
                resp.getWriter().write("{\"ok\":true,\"msg\":\"Đã tạo hóa đơn dịch vụ #" + newHoaDonId + ".\",\"hoaDonId\":" + newHoaDonId + "}");
            } else if ("cancelInvoice".equals(action)) {
                int hoaDonId = Integer.parseInt(req.getParameter("hoaDonId"));
                cancelInvoice(hoaDonId, user);
                AuditLogService.log(req, user, AuditLogService.ACTION_CANCEL, AuditLogService.ENTITY_HOA_DON,
                        String.valueOf(hoaDonId), "Hóa đơn #" + hoaDonId,
                        "Manager hủy hóa đơn.");
                resp.getWriter().write("{\"ok\":true,\"msg\":\"Đã hủy hóa đơn #" + hoaDonId + ".\"}");
            } else {
                resp.getWriter().write("{\"ok\":false,\"msg\":\"Hành động không hợp lệ.\"}");
            }
        } catch (Exception e) {
            logger.error("HoaDonManagerServlet doPost error: {}", e.getMessage(), e);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Lỗi hệ thống.";
            resp.getWriter().write("{\"ok\":false,\"msg\":\"" + msg + "\"}");
        }
    }

    // --- Private helpers ---

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try {
            int hoaDonId = Integer.parseInt(req.getParameter("hoaDonId"));
            Map<String, Object> detail = new LinkedHashMap<>();

            try (Connection conn = DBUtil.getConnection()) {
                boolean hasLoaiHoaDon = columnExists(conn, "invoices", "invoice_type");
                boolean hasParentHoaDonID = columnExists(conn, "invoices", "parent_invoice_id");
                boolean hasGhiChu = columnExists(conn, "invoices", "note");
                String sql =
                    "SELECT hd.invoice_id, hd.booking_id, hd.issued_at, hd.court_total, hd.service_total, " +
                    "hd.parking_fee, hd.discount_amount, hd.grand_total, hd.payment_status, hd.payment_method, " +
                    (hasLoaiHoaDon ? "hd.invoice_type" : "CAST(N'MAIN' AS NVARCHAR(50))") + " AS invoice_type, " +
                    (hasGhiChu ? "hd.note" : "CAST(NULL AS NVARCHAR(500))") + " AS note, " +
                    (hasParentHoaDonID ? "hd.parent_invoice_id" : "CAST(NULL AS INT)") + " AS parent_invoice_id, " +
                    "s.court_name, s.facility_id, lds.booking_date, lds.start_time, lds.end_time, " +
                    "acc.full_name AS TenKhachHang, nv.full_name AS TenNhanVien " +
                    "FROM invoices hd " +
                    "INNER JOIN bookings lds ON hd.booking_id = lds.booking_id " +
                    "INNER JOIN courts s ON lds.court_id = s.court_id " +
                    "LEFT JOIN accounts acc ON lds.account_id = acc.account_id " +
                    "LEFT JOIN accounts nv ON hd.staff_account_id = nv.account_id " +
                    "WHERE hd.invoice_id = ? AND s.facility_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, hoaDonId);
                    ps.setInt(2, user.getCoSoId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            resp.getWriter().write("{\"ok\":false,\"msg\":\"Không tìm thấy hóa đơn.\"}");
                            return;
                        }
                        String loai = rs.getString("invoice_type");
                        detail.put("hoaDonId",         rs.getInt("invoice_id"));
                        detail.put("datSanId",          rs.getInt("booking_id"));
                        detail.put("ngayLap",           rs.getTimestamp("issued_at") != null
                                ? rs.getTimestamp("issued_at").toString().substring(0, 16) : "");
                        detail.put("tongTienSan",       rs.getDouble("court_total"));
                        detail.put("tongTienDichVu",    rs.getDouble("service_total"));
                        detail.put("phiGuiXe",          rs.getDouble("parking_fee"));
                        detail.put("giamGia",           rs.getDouble("discount_amount"));
                        detail.put("tongThanhToan",     rs.getDouble("grand_total"));
                        detail.put("trangThai",         rs.getString("payment_status"));
                        detail.put("phuongThuc",        rs.getString("payment_method"));
                        detail.put("loaiHoaDon",        loai == null ? "MAIN" : loai);
                        detail.put("ghiChu",            rs.getString("note"));
                        detail.put("parentHoaDonId",    rs.getObject("parent_invoice_id"));
                        detail.put("tenSan",            rs.getString("court_name"));
                        detail.put("ngayDat",           rs.getDate("booking_date") != null ? rs.getDate("booking_date").toString() : "");
                        detail.put("gioBatDau",         rs.getTime("start_time") != null ? rs.getTime("start_time").toString().substring(0,5) : "");
                        detail.put("gioKetThuc",        rs.getTime("end_time") != null ? rs.getTime("end_time").toString().substring(0,5) : "");
                        detail.put("tenKhachHang",      rs.getString("TenKhachHang"));
                        detail.put("tenNhanVien",       rs.getString("TenNhanVien"));
                    }
                }

                // Line items
                String sqlItems =
                    "SELECT sp.product_name, ct.quantity, ct.unit_price_at_sale, ct.line_total " +
                    "FROM invoice_items ct " +
                    "INNER JOIN products_services sp ON ct.product_id = sp.product_id " +
                    "WHERE ct.invoice_id = ?";
                List<Map<String, Object>> items = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(sqlItems)) {
                    ps.setInt(1, hoaDonId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> item = new LinkedHashMap<>();
                            item.put("tenSanPham", rs.getString("product_name"));
                            item.put("soLuong",    rs.getInt("quantity"));
                            item.put("donGia",     rs.getDouble("unit_price_at_sale"));
                            item.put("thanhTien",  rs.getDouble("line_total"));
                            items.add(item);
                        }
                    }
                }
                detail.put("items", items);
            }

            resp.getWriter().write(gson.toJson(detail));
        } catch (Exception e) {
            logger.error("handleDetail error: {}", e.getMessage(), e);
            resp.getWriter().write("{\"ok\":false,\"msg\":\"" + e.getMessage().replace("\"","'") + "\"}");
        }
    }

    private void handleStats(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        try (Connection conn = DBUtil.getConnection()) {
            String sql = buildStatsSql(columnExists(conn, "invoices", "invoice_type"));
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, user.getCoSoId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Map<String, Object> stats = new LinkedHashMap<>();
                        stats.put("totalCount",   rs.getInt("totalCount"));
                        stats.put("tongDoanhThu", rs.getDouble("tongDoanhThu"));
                        stats.put("mainChuaTT",   rs.getInt("mainChuaTT"));
                        stats.put("splitChuaTT",  rs.getInt("splitChuaTT"));
                        resp.getWriter().write(gson.toJson(stats));
                        return;
                    }
                }
            }
        } catch (Exception e) {
            logger.error("handleStats error: {}", e.getMessage(), e);
        }
        resp.getWriter().write("{}");
    }


    private List<Map<String, Object>> loadServiceProducts(int coSoId) {
        List<Map<String, Object>> products = new ArrayList<>();
        String sql = "SELECT product_id, product_name, unit_price, unit_of_measure, stock_quantity " +
                     "FROM products_services " +
                     "WHERE facility_id = ? AND (status IS NULL OR status <> N'Ngừng kinh doanh') " +
                     "AND ISNULL(is_deleted, 0) = 0 " +
                     "ORDER BY product_name";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("sanPhamId", rs.getInt("product_id"));
                    row.put("tenSanPham", rs.getString("product_name"));
                    row.put("donGia", rs.getDouble("unit_price"));
                    row.put("donViTinh", rs.getString("unit_of_measure"));
                    row.put("soLuongTon", rs.getInt("stock_quantity"));
                    products.add(row);
                }
            }
        } catch (Exception e) {
            logger.error("loadServiceProducts error: {}", e.getMessage(), e);
        }
        return products;
    }

    private List<Map<String, Object>> loadPayableBookings(int coSoId) {
        List<Map<String, Object>> bookings = new ArrayList<>();
        String sql = "SELECT TOP 80 lds.booking_id, lds.booking_date, lds.start_time, lds.end_time, lds.account_id, " +
                     "s.court_name, acc.full_name AS TenKhachHang " +
                     "FROM bookings lds " +
                     "INNER JOIN courts s ON lds.court_id = s.court_id " +
                     "LEFT JOIN accounts acc ON lds.account_id = acc.account_id " +
                     "WHERE s.facility_id = ? AND ISNULL(lds.is_deleted, 0) = 0 " +
                     "AND lds.status NOT IN (N'Đã hủy', N'Từ chối') " +
                     "ORDER BY lds.booking_date DESC, lds.start_time DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("datSanId", rs.getInt("booking_id"));
                    row.put("accountId", rs.getObject("account_id"));
                    row.put("label", "#" + rs.getInt("booking_id") + " · " + rs.getString("court_name") + " · " +
                            (rs.getDate("booking_date") != null ? rs.getDate("booking_date").toString() : "") + " " +
                            (rs.getTime("start_time") != null ? rs.getTime("start_time").toString().substring(0, 5) : "") + "-" +
                            (rs.getTime("end_time") != null ? rs.getTime("end_time").toString().substring(0, 5) : "") +
                            " · " + (rs.getString("TenKhachHang") != null ? rs.getString("TenKhachHang") : "Khách vãng lai"));
                    bookings.add(row);
                }
            }
        } catch (Exception e) {
            logger.error("loadPayableBookings error: {}", e.getMessage(), e);
        }
        return bookings;
    }

    private int createServiceInvoice(HttpServletRequest req, TaiKhoan user) throws Exception {
        int datSanId = Integer.parseInt(req.getParameter("datSanId"));
        boolean payNow = "true".equalsIgnoreCase(req.getParameter("payNow"));
        String paymentMethod = req.getParameter("phuongThucThanhToan");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) paymentMethod = "Tiền mặt";
        String ghiChuInput = req.getParameter("ghiChu");
        String ghiChu = (ghiChuInput == null || ghiChuInput.trim().isEmpty()) ? "Manager lập hóa đơn dịch vụ" : ghiChuInput.trim();
        if (ghiChu.length() > 255) ghiChu = ghiChu.substring(0, 255);

        String[] productIds = req.getParameterValues("productId");
        String[] quantities = req.getParameterValues("quantity");
        if (productIds == null || quantities == null || productIds.length != quantities.length) {
            throw new Exception("Vui lòng chọn ít nhất một dịch vụ hợp lệ.");
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (!columnExists(conn, "invoices", "invoice_type") || !columnExists(conn, "invoices", "note")) {
                    throw new Exception("Database chưa có cột LoaiHoaDon/GhiChu cho hóa đơn dịch vụ. Vui lòng chạy script /sql/migration_hoadon_loai.sql rồi thử lại.");
                }
                Integer customerAccountId = null;
                String sqlBooking = "SELECT lds.account_id, s.facility_id FROM bookings lds INNER JOIN courts s ON lds.court_id = s.court_id WHERE lds.booking_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlBooking)) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new Exception("Không tìm thấy đơn đặt sân #" + datSanId);
                        if (rs.getInt("facility_id") != user.getCoSoId()) throw new Exception("Đơn đặt sân không thuộc cơ sở của bạn.");
                        Object accObj = rs.getObject("account_id");
                        if (accObj != null) customerAccountId = ((Number) accObj).intValue();
                    }
                }

                double total = 0;
                List<int[]> validItems = new ArrayList<>();
                String sqlProduct = "SELECT product_name, unit_price, stock_quantity FROM products_services WHERE product_id = ? AND facility_id = ? AND ISNULL(is_deleted, 0) = 0";
                try (PreparedStatement ps = conn.prepareStatement(sqlProduct)) {
                    for (int i = 0; i < productIds.length; i++) {
                        int productId;
                        int qty;
                        try {
                            productId = Integer.parseInt(productIds[i]);
                            qty = Integer.parseInt(quantities[i]);
                        } catch (NumberFormatException ex) {
                            continue;
                        }
                        if (productId <= 0 || qty <= 0) continue;
                        ps.setInt(1, productId);
                        ps.setInt(2, user.getCoSoId());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) throw new Exception("Sản phẩm #" + productId + " không thuộc cơ sở của bạn.");
                            int stock = rs.getInt("stock_quantity");
                            double price = rs.getDouble("unit_price");
                            if (stock < qty) throw new Exception("Sản phẩm " + rs.getString("product_name") + " chỉ còn " + stock + ".");
                            validItems.add(new int[]{productId, qty, (int) Math.round(price)});
                            total += price * qty;
                        }
                    }
                }
                if (validItems.isEmpty() || total <= 0) throw new Exception("Vui lòng nhập số lượng dịch vụ lớn hơn 0.");

                String status = payNow ? "Đã thanh toán" : "Chưa thanh toán";
                String sqlInsertHD = "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, " +
                        "court_total, service_total, parking_fee, discount_amount, grand_total, payment_status, payment_method, invoice_type, note) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, ?, ?, N'SPLIT', ?)";
                int hoaDonId;
                try (PreparedStatement ps = conn.prepareStatement(sqlInsertHD, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, datSanId);
                    if (customerAccountId != null) ps.setInt(2, customerAccountId); else ps.setNull(2, Types.INTEGER);
                    ps.setInt(3, user.getAccountId());
                    ps.setDouble(4, total);
                    ps.setDouble(5, total);
                    ps.setNString(6, status);
                    if (payNow) ps.setNString(7, paymentMethod.trim()); else ps.setNull(7, Types.NVARCHAR);
                    ps.setNString(8, ghiChu);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) throw new Exception("Không lấy được mã hóa đơn mới.");
                        hoaDonId = keys.getInt(1);
                    }
                }

                String sqlInsertCT = "INSERT INTO invoice_items (invoice_id, product_id, quantity, unit_price_at_sale, line_total) VALUES (?, ?, ?, ?, ?)";
                String sqlStock = "UPDATE products_services SET stock_quantity = stock_quantity - ? WHERE product_id = ? AND facility_id = ? AND stock_quantity >= ?";
                try (PreparedStatement psCT = conn.prepareStatement(sqlInsertCT);
                     PreparedStatement psStock = conn.prepareStatement(sqlStock)) {
                    for (int[] item : validItems) {
                        int productId = item[0];
                        int qty = item[1];
                        double price = item[2];
                        psStock.setInt(1, qty);
                        psStock.setInt(2, productId);
                        psStock.setInt(3, user.getCoSoId());
                        psStock.setInt(4, qty);
                        if (psStock.executeUpdate() == 0) throw new Exception("Không đủ tồn kho cho sản phẩm #" + productId);

                        psCT.setInt(1, hoaDonId);
                        psCT.setInt(2, productId);
                        psCT.setInt(3, qty);
                        psCT.setDouble(4, price);
                        psCT.setDouble(5, price * qty);
                        psCT.addBatch();
                    }
                    psCT.executeBatch();
                }

                conn.commit();
                return hoaDonId;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void payInvoice(int hoaDonId, TaiKhoan user, String paymentMethod) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Verify invoice belongs to this coSo and is unpaid
                boolean hasLoaiHoaDon = columnExists(conn, "invoices", "invoice_type");
                String sqlCheck =
                    "SELECT hd.payment_status, s.facility_id, lds.status AS TrangThaiDatSan, " +
                    (hasLoaiHoaDon ? "hd.invoice_type" : "CAST(NULL AS NVARCHAR(50))") + " AS invoice_type " +
                    "FROM invoices hd " +
                    "INNER JOIN bookings lds ON hd.booking_id = lds.booking_id " +
                    "INNER JOIN courts s ON lds.court_id = s.court_id " +
                    "WHERE hd.invoice_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                    ps.setInt(1, hoaDonId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new Exception("Không tìm thấy hóa đơn #" + hoaDonId);
                        if (rs.getInt("facility_id") != user.getCoSoId())
                            throw new Exception("Hóa đơn không thuộc cơ sở của bạn.");
                        if ("Đã thanh toán".equals(rs.getString("payment_status")))
                            throw new Exception("Hóa đơn này đã được thanh toán trước đó.");
                        String loaiHoaDon = rs.getString("invoice_type");
                        if (hasLoaiHoaDon && (loaiHoaDon == null || "MAIN".equalsIgnoreCase(loaiHoaDon))) {
                            throw new Exception("Hóa đơn sân chính phải thanh toán tại màn hình Mở sân/Check-in để cập nhật đồng bộ trạng thái sân và lịch đặt.");
                        }
                    }
                }
                String sqlPay =
                    "UPDATE invoices SET payment_status = N'Đã thanh toán', " +
                    "payment_method = ?, staff_account_id = ?, issued_at = GETDATE() " +
                    "WHERE invoice_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlPay)) {
                    ps.setString(1, paymentMethod.trim());
                    ps.setInt(2, user.getAccountId());
                    ps.setInt(3, hoaDonId);
                    if (ps.executeUpdate() == 0) throw new Exception("Cập nhật hóa đơn thất bại.");
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void cancelInvoice(int hoaDonId, TaiKhoan user) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sqlCheck =
                    "SELECT hd.payment_status, s.facility_id " +
                    "FROM invoices hd " +
                    "INNER JOIN bookings lds ON hd.booking_id = lds.booking_id " +
                    "INNER JOIN courts s ON lds.court_id = s.court_id " +
                    "WHERE hd.invoice_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                    ps.setInt(1, hoaDonId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new Exception("Không tìm thấy hóa đơn #" + hoaDonId);
                        if (rs.getInt("facility_id") != user.getCoSoId())
                            throw new Exception("Hóa đơn không thuộc cơ sở của bạn.");
                        if ("Đã thanh toán".equals(rs.getString("payment_status")))
                            throw new Exception("Không thể hủy hóa đơn đã thanh toán.");
                    }
                }
                String sqlCancel =
                    "UPDATE invoices SET payment_status = N'Đã hủy', staff_account_id = ? " +
                    "WHERE invoice_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlCancel)) {
                    ps.setInt(1, user.getAccountId());
                    ps.setInt(2, hoaDonId);
                    if (ps.executeUpdate() == 0) throw new Exception("Cập nhật hóa đơn thất bại.");
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        String sql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, tableName);
            ps.setNString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String buildStatsSql(boolean hasLoaiHoaDon) {
        String paidMainCondition = hasLoaiHoaDon
                ? "TrangThaiThanhToan = N'Đã thanh toán' AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)"
                : "TrangThaiThanhToan = N'Đã thanh toán'";
        String unpaidMainCondition = hasLoaiHoaDon
                ? "TrangThaiThanhToan = N'Chưa thanh toán' AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)"
                : "TrangThaiThanhToan = N'Chưa thanh toán'";
        String unpaidSplitCondition = hasLoaiHoaDon
                ? "TrangThaiThanhToan = N'Chưa thanh toán' AND LoaiHoaDon = N'SPLIT'"
                : "1 = 0";

        return "SELECT " +
                "  COUNT(*) AS totalCount, " +
                "  SUM(CASE WHEN " + paidMainCondition + " THEN grand_total ELSE 0 END) AS tongDoanhThu, " +
                "  SUM(CASE WHEN " + unpaidMainCondition + " THEN 1 ELSE 0 END) AS mainChuaTT, " +
                "  SUM(CASE WHEN " + unpaidSplitCondition + " THEN 1 ELSE 0 END) AS splitChuaTT " +
                "FROM invoices hd " +
                "INNER JOIN bookings lds ON hd.booking_id = lds.booking_id " +
                "INNER JOIN courts s ON lds.court_id = s.court_id " +
                "WHERE s.facility_id = ?";
    }
}
