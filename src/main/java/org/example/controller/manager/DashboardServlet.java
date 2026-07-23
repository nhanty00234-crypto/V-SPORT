package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.SanDAO;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.DatSanDAO;
import org.example.dao.impl.DatSanDAOImpl;
import org.example.dao.HoaDonDAO;
import org.example.dao.impl.HoaDonDAOImpl;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.service.manager.NhanSuService;
import org.example.model.Lichdatsan;
import org.example.model.HoaDon;
import org.example.model.San;
import org.example.model.DanhGia;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet điều hướng Dashboard cho Manager (role 2)
 * Dựa trên vai trò người dùng, hiển thị dashboard tương ứng
 */
@WebServlet("/manager/dashboard")
public class DashboardServlet extends HttpServlet {

    private TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private SanDAO sanDAO = new SanDAOImpl();
    private DatSanDAO datSanDAO = new DatSanDAOImpl();
    private HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private NhanSuService nhanSuService = new NhanSuService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // Kiểm tra đăng nhập và quyền
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        // Chỉ cho phép Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập dashboard này.");
            return;
        }

        // Lấy thông tin dashboard cho Manager
        Map<String, Object> dashboardData = getDashboardData(user);

        // Đặt dữ liệu vào request
        req.setAttribute("pageTitle", "Dashboard - Vận hành cơ sở");
        req.setAttribute("userFullName", user.getUsername());
        req.setAttribute("userRole", "Quản lý cơ sở");
        req.setAttribute("dashboardData", dashboardData);
        req.setAttribute("currentPage", "dashboard");

        // Forward tới JSP dashboard
        req.getRequestDispatcher("/manager/Dashboard.jsp").forward(req, resp);
    }

    /**
     * Lấy dữ liệu thống kê cho dashboard Manager
     */
    private Map<String, Object> getDashboardData(TaiKhoan user) {
        Map<String, Object> data = new HashMap<>();
        Integer coSoId = user.getCoSoId();

        if (coSoId == null) {
            return data;
        }

        try {
            // Thống kê sân của cơ sở
            List<San> dsSan = sanDAO.getSansByCoSo(coSoId);
            long totalFields = dsSan.size();
            long activeFields = dsSan.stream()
                .filter(s -> "Sẵn sàng".equals(s.getTrangThai()) || "Đang dùng".equals(s.getTrangThai()))
                .count();

            // Thống kê đặt sân hôm nay của cơ sở
            List<Lichdatsan> dsLichToday = lichDatSanDAO.getLichDatSanTodayByCoSo(coSoId);
            long bookingsTodayCount = dsLichToday.size();

            // Thống kê doanh thu hôm nay của cơ sở
            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);

            // Thống kê tổng doanh thu của cơ sở
            BigDecimal totalRevenue = hoaDonDAO.getTotalDoanhThuByCoSo(coSoId);

            // Thống kê nhân viên của cơ sở
            long totalStaff = 0;
            List<?> staffList = nhanSuService.getStaffListByBranch(coSoId);
            if (staffList != null) {
                totalStaff = staffList.size();
            }

            // Danh sách hóa đơn gần đây (limit 5)
            List<HoaDon> recentInvoices = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 5);

            data.put("totalFields", totalFields);
            data.put("activeFields", activeFields);
            data.put("bookingsTodayCount", bookingsTodayCount);
            data.put("revenueToday", revenueToday);
            data.put("totalRevenue", totalRevenue);
            data.put("totalStaff", totalStaff);
            data.put("recentInvoices", recentInvoices);
            data.put("todayBookingsList", dsLichToday);

            // Doanh thu tháng này và tháng trước
            BigDecimal revenueThisMonth = getRevenueThisMonth(coSoId);
            BigDecimal revenueLastMonth = getRevenueLastMonth(coSoId);
            data.put("revenueThisMonth", revenueThisMonth);
            data.put("revenueLastMonth", revenueLastMonth);

            // Tăng trưởng doanh thu (%)
            if (revenueLastMonth != null && revenueLastMonth.compareTo(BigDecimal.ZERO) > 0) {
                double growth = revenueThisMonth.subtract(revenueLastMonth)
                    .divide(revenueLastMonth, 4, java.math.RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100)).doubleValue();
                data.put("revenueGrowth", Math.round(growth * 10.0) / 10.0);
            } else {
                data.put("revenueGrowth", null);
            }

            // Doanh thu breakdown theo sân
            data.put("revenueBySan", getRevenueBySan(coSoId));

            // Doanh thu 6 tháng gần nhất
            data.put("revenueByMonth", getRevenueByMonth(coSoId));

            // Đánh giá khách hàng
            data.put("danhGiaList", getRecentDanhGia(coSoId));
            data.put("avgSoSao", getAvgSoSao(coSoId));
            data.put("totalDanhGia", getTotalDanhGia(coSoId));

            // Thêm dữ liệu cho biểu đồ
            data.put("revenueChart", getRevenueChartData(coSoId));
            data.put("bookingChart", getBookingChartData(coSoId));
            data.put("shiftChart", getShiftChartData(coSoId));

        } catch (Exception e) {
            System.err.println("Error getting dashboard data: " + e.getMessage());
            e.printStackTrace();
        }

        return data;
    }

    /**
     * Dữ liệu cho biểu đồ doanh thu theo tuần
     */
    private Map<String, Object> getRevenueChartData(int coSoId) {
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("type", "line");
        
        String[] labels = new String[]{"Tuần 5", "Tuần 4", "Tuần 3", "Tuần 2", "Tuần 1"};
        double[] data = new double[5];
        
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate startOfPeriod = today.minusWeeks(5);
            
            List<HoaDon> invoices = em.createQuery(
                "SELECT h FROM HoaDon h JOIN h.datSan d JOIN d.san s " +
                "WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán' " +
                "AND h.ngayLap >= :startDate ORDER BY h.ngayLap ASC", HoaDon.class)
                .setParameter("coSoId", coSoId)
                .setParameter("startDate", java.sql.Date.valueOf(startOfPeriod))
                .getResultList();
                
            for (HoaDon h : invoices) {
                java.time.LocalDate invoiceDate = new java.sql.Date(h.getNgayLap().getTime()).toLocalDate();
                long weeksAgo = java.time.temporal.ChronoUnit.WEEKS.between(invoiceDate, today);
                if (weeksAgo >= 0 && weeksAgo < 5) {
                    int index = 4 - (int) weeksAgo;
                    data[index] += h.getTongThanhToan() / 1_000_000.0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        for (int i = 0; i < 5; i++) {
            data[i] = Math.round(data[i] * 100.0) / 100.0;
        }

        chartData.put("labels", labels);
        chartData.put("data", data);
        chartData.put("title", "Doanh thu theo tuần (triệu VNĐ)");
        return chartData;
    }

    /**
     * Dữ liệu cho biểu đồ đặt sân theo tuần
     */
    private Map<String, Object> getBookingChartData(int coSoId) {
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("type", "bar");
        String[] labels = new String[]{"Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ nhật"};
        int[] data = new int[7];
        
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate monday = today.with(java.time.DayOfWeek.MONDAY);
            java.time.LocalDate sunday = today.with(java.time.DayOfWeek.SUNDAY);
            
            List<Lichdatsan> bookings = em.createQuery(
                "SELECT d FROM Lichdatsan d JOIN d.san s " +
                "WHERE s.coSoID = :coSoId AND d.ngayDat BETWEEN :start AND :end", Lichdatsan.class)
                .setParameter("coSoId", coSoId)
                .setParameter("start", monday)
                .setParameter("end", sunday)
                .getResultList();
                
            for (Lichdatsan b : bookings) {
                int dayOfWeek = b.getNgayDat().getDayOfWeek().getValue();
                data[dayOfWeek - 1]++;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        chartData.put("labels", labels);
        chartData.put("data", data);
        chartData.put("title", "Số lượt đặt sân theo ngày trong tuần");
        return chartData;
    }

    /**
     * Dữ liệu cho biểu đồ ca làm việc theo loại
     */
    private Map<String, Object> getShiftChartData(int coSoId) {
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("type", "doughnut");
        String[] labels = new String[]{"Ca sáng", "Ca chiều", "Ca tối", "Ca đêm", "Khác"};
        int[] data = new int[5];
        
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate monday = today.with(java.time.DayOfWeek.MONDAY);
            java.time.LocalDate sunday = today.with(java.time.DayOfWeek.SUNDAY);
            
            List<org.example.model.CaLamViec> shifts = em.createQuery(
                "SELECT c FROM CaLamViec c " +
                "WHERE c.coSoId = :coSoId AND c.ngayLam BETWEEN :start AND :end", org.example.model.CaLamViec.class)
                .setParameter("coSoId", coSoId)
                .setParameter("start", monday)
                .setParameter("end", sunday)
                .getResultList();
                
            for (org.example.model.CaLamViec s : shifts) {
                String name = s.getTenCa();
                if (name == null) {
                    data[4]++;
                } else if (name.toLowerCase().contains("sáng")) {
                    data[0]++;
                } else if (name.toLowerCase().contains("chiều")) {
                    data[1]++;
                } else if (name.toLowerCase().contains("tối")) {
                    data[2]++;
                } else if (name.toLowerCase().contains("đêm")) {
                    data[3]++;
                } else {
                    data[4]++;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        
        chartData.put("labels", labels);
        chartData.put("data", data);
        chartData.put("title", "Phân bổ ca làm việc");
        return chartData;
    }

    private BigDecimal getRevenueThisMonth(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate start = today.withDayOfMonth(1);
            java.time.LocalDate end = today.withDayOfMonth(today.lengthOfMonth());
            BigDecimal result = em.createQuery(
                "SELECT COALESCE(SUM(h.tongThanhToan), 0) FROM HoaDon h JOIN h.datSan d JOIN d.san s " +
                "WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán' " +
                "AND h.ngayLap BETWEEN :start AND :end", BigDecimal.class)
                .setParameter("coSoId", coSoId)
                .setParameter("start", java.sql.Date.valueOf(start))
                .setParameter("end", java.sql.Date.valueOf(end))
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) { return BigDecimal.ZERO; } finally { em.close(); }
    }

    private BigDecimal getRevenueLastMonth(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate lastMonth = java.time.LocalDate.now().minusMonths(1);
            java.time.LocalDate start = lastMonth.withDayOfMonth(1);
            java.time.LocalDate end = lastMonth.withDayOfMonth(lastMonth.lengthOfMonth());
            BigDecimal result = em.createQuery(
                "SELECT COALESCE(SUM(h.tongThanhToan), 0) FROM HoaDon h JOIN h.datSan d JOIN d.san s " +
                "WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán' " +
                "AND h.ngayLap BETWEEN :start AND :end", BigDecimal.class)
                .setParameter("coSoId", coSoId)
                .setParameter("start", java.sql.Date.valueOf(start))
                .setParameter("end", java.sql.Date.valueOf(end))
                .getSingleResult();
            return result != null ? result : BigDecimal.ZERO;
        } catch (Exception e) { return BigDecimal.ZERO; } finally { em.close(); }
    }

    private List<Object[]> getRevenueBySan(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalDate start = today.withDayOfMonth(1);
            java.time.LocalDate end = today.withDayOfMonth(today.lengthOfMonth());
            return em.createQuery(
                "SELECT s.tenSan, COALESCE(SUM(h.tongThanhToan), 0) FROM HoaDon h " +
                "JOIN h.datSan d JOIN d.san s " +
                "WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán' " +
                "AND h.ngayLap BETWEEN :start AND :end " +
                "GROUP BY s.sanID, s.tenSan ORDER BY SUM(h.tongThanhToan) DESC", Object[].class)
                .setParameter("coSoId", coSoId)
                .setParameter("start", java.sql.Date.valueOf(start))
                .setParameter("end", java.sql.Date.valueOf(end))
                .getResultList();
        } catch (Exception e) { return new ArrayList<>(); } finally { em.close(); }
    }

    private java.util.LinkedHashMap<String, BigDecimal> getRevenueByMonth(int coSoId) {
        java.util.LinkedHashMap<String, BigDecimal> map = new java.util.LinkedHashMap<>();
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            for (int i = 5; i >= 0; i--) {
                java.time.LocalDate m = today.minusMonths(i);
                java.time.LocalDate start = m.withDayOfMonth(1);
                java.time.LocalDate end = m.withDayOfMonth(m.lengthOfMonth());
                String label = "T" + m.getMonthValue() + "/" + m.getYear() % 100;
                BigDecimal rev = em.createQuery(
                    "SELECT COALESCE(SUM(h.tongThanhToan), 0) FROM HoaDon h JOIN h.datSan d JOIN d.san s " +
                    "WHERE s.coSoID = :coSoId AND h.trangThaiThanhToan = 'Đã thanh toán' " +
                    "AND h.ngayLap BETWEEN :start AND :end", BigDecimal.class)
                    .setParameter("coSoId", coSoId)
                    .setParameter("start", java.sql.Date.valueOf(start))
                    .setParameter("end", java.sql.Date.valueOf(end))
                    .getSingleResult();
                map.put(label, rev != null ? rev : BigDecimal.ZERO);
            }
        } catch (Exception e) { } finally { em.close(); }
        return map;
    }

    private List<DanhGia> getRecentDanhGia(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                "SELECT dg FROM DanhGia dg JOIN Lichdatsan lds ON lds.datSanId = dg.datSanId " +
                "JOIN lds.san s WHERE s.coSoID = :coSoId " +
                "ORDER BY dg.ngayDanhGia DESC", DanhGia.class)
                .setParameter("coSoId", coSoId)
                .setMaxResults(20)
                .getResultList();
        } catch (Exception e) { return new ArrayList<>(); } finally { em.close(); }
    }

    private Double getAvgSoSao(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            Double avg = em.createQuery(
                "SELECT AVG(dg.soSao) FROM DanhGia dg JOIN Lichdatsan lds ON lds.datSanId = dg.datSanId " +
                "JOIN lds.san s WHERE s.coSoID = :coSoId", Double.class)
                .setParameter("coSoId", coSoId)
                .getSingleResult();
            return avg != null ? Math.round(avg * 10.0) / 10.0 : null;
        } catch (Exception e) { return null; } finally { em.close(); }
    }

    private long getTotalDanhGia(int coSoId) {
        jakarta.persistence.EntityManager em = org.example.util.JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                "SELECT COUNT(dg) FROM DanhGia dg JOIN Lichdatsan lds ON lds.datSanId = dg.datSanId " +
                "JOIN lds.san s WHERE s.coSoID = :coSoId", Long.class)
                .setParameter("coSoId", coSoId)
                .getSingleResult();
            return count != null ? count : 0L;
        } catch (Exception e) { return 0L; } finally { em.close(); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
