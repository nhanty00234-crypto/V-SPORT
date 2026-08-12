package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.*;
import org.example.dao.impl.*;
import org.example.model.*;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Session-based REST endpoints cho Next.js Staff portal.
 * GET /api/v1/web/staff/dashboard
 * GET /api/v1/web/staff/bookings      — today bookings (check-in list)
 * GET /api/v1/web/staff/dat-san       — all bookings by co-so
 * GET /api/v1/web/staff/hoa-don       — recent invoices
 * GET /api/v1/web/staff/hoan-tien     — refund requests
 * GET /api/v1/web/staff/ca-lam-viec   — this staff's shifts
 * GET /api/v1/web/staff/yeu-cau-qr    — QR requests for co-so
 */
@WebServlet("/api/v1/web/staff/*")
public class WebStaffApiServlet extends HttpServlet {

    private final SanDAO sanDAO = new SanDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private final HoanTienDAO hoanTienDAO = new HoanTienDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final QRRequestDAO qrRequestDAO = new QRRequestDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireStaff(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        switch (path) {
            case "/dashboard":    handleDashboard(resp, user); break;
            case "/bookings":     handleBookings(resp, user); break;
            case "/dat-san":      handleDatSan(resp, user); break;
            case "/hoa-don":      handleHoaDon(resp, user); break;
            case "/hoan-tien":    handleHoanTien(req, resp, user); break;
            case "/ca-lam-viec":  handleCaLamViec(req, resp, user); break;
            case "/yeu-cau-qr":   handleYeuCauQr(resp, user); break;
            default:
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
        }
    }

    private void handleDashboard(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<San> dsSan = sanDAO.getSansByCoSo(coSoId);
            long totalFields = dsSan.size();
            long activeFields = dsSan.stream().filter(s -> "Sẵn sàng".equals(s.getTrangThai()) || "Đang dùng".equals(s.getTrangThai())).count();
            List<Lichdatsan> todayList = lichDatSanDAO.getLichDatSanTodayByCoSo(coSoId);
            long todayCount = todayList.size();
            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);
            List<HoaDon> recentInvoices = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 5);

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"coSoId\":").append(coSoId).append(",");
            sb.append("\"staffName\":\"").append(escape(user.getFullName() != null ? user.getFullName() : user.getUsername())).append("\",");
            sb.append("\"totalFields\":").append(totalFields).append(",");
            sb.append("\"activeFields\":").append(activeFields).append(",");
            sb.append("\"todayBookings\":").append(todayCount).append(",");
            sb.append("\"revenueToday\":").append(revenueToday != null ? revenueToday.longValue() : 0).append(",");
            sb.append("\"recentInvoices\":[");
            for (int i = 0; i < recentInvoices.size(); i++) {
                HoaDon h = recentInvoices.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(h.getHoaDonId())
                  .append(",\"total\":").append((long) h.getTongThanhToan())
                  .append(",\"status\":\"").append(escape(h.getTrangThaiThanhToan())).append("\"")
                  .append(",\"date\":\"").append(h.getNgayLap() != null ? h.getNgayLap().toString() : "").append("\"}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleBookings(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<Lichdatsan> list = lichDatSanDAO.getLichDatSanTodayByCoSo(coSoId);
            writeLichDatSanList(resp, list);
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleDatSan(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<Lichdatsan> list = lichDatSanDAO.getLichDatSanByCoSo(coSoId);
            writeLichDatSanList(resp, list);
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void writeLichDatSanList(HttpServletResponse resp, List<Lichdatsan> list) throws IOException {
        StringBuilder sb = new StringBuilder("{\"bookings\":[");
        for (int i = 0; i < list.size(); i++) {
            Lichdatsan l = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"id\":").append(l.getDatSanId())
              .append(",\"accountId\":").append(l.getAccountId())
              .append(",\"sanId\":").append(l.getSanId())
              .append(",\"ngayDat\":\"").append(l.getNgayDat() != null ? l.getNgayDat().toString() : "").append("\"")
              .append(",\"gioBatDau\":\"").append(l.getGioBatDau() != null ? l.getGioBatDau().toString() : "").append("\"")
              .append(",\"gioKetThuc\":\"").append(l.getGioKetThuc() != null ? l.getGioKetThuc().toString() : "").append("\"")
              .append(",\"tongTien\":").append(l.getTongTienDuKien() != null ? l.getTongTienDuKien() : 0)
              .append(",\"trangThai\":\"").append(escape(l.getTrangThai())).append("\"");
            if (l.getAccount() != null) {
                sb.append(",\"tenKhach\":\"").append(escape(l.getAccount().getFullName())).append("\"")
                  .append(",\"phone\":\"").append(escape(l.getAccount().getPhoneNumber())).append("\"");
            } else {
                sb.append(",\"tenKhach\":\"\",\"phone\":\"\"");
            }
            if (l.getSan() != null) {
                sb.append(",\"tenSan\":\"").append(escape(l.getSan().getTenSan())).append("\"");
            } else {
                sb.append(",\"tenSan\":\"\"");
            }
            sb.append("}");
        }
        sb.append("]}");
        resp.getWriter().write(sb.toString());
    }

    private void handleHoaDon(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<HoaDon> list = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 100);
            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"revenueToday\":").append(revenueToday != null ? revenueToday.longValue() : 0).append(",");
            sb.append("\"invoices\":[");
            for (int i = 0; i < list.size(); i++) {
                HoaDon h = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(h.getHoaDonId())
                  .append(",\"datSanId\":").append(h.getDatSanId())
                  .append(",\"accountId\":").append(h.getAccountIdKhachHang())
                  .append(",\"total\":").append((long) h.getTongThanhToan())
                  .append(",\"status\":\"").append(escape(h.getTrangThaiThanhToan())).append("\"")
                  .append(",\"date\":\"").append(h.getNgayLap() != null ? h.getNgayLap().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleHoanTien(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            String pageStr = req.getParameter("page");
            int page = pageStr != null ? Integer.parseInt(pageStr) : 1;
            List<Hoantien> list = hoanTienDAO.findByCoSoId(coSoId, page, 50);
            StringBuilder sb = new StringBuilder("{\"refunds\":[");
            for (int i = 0; i < list.size(); i++) {
                Hoantien h = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(h.getHoanTienId())
                  .append(",\"hoaDonId\":").append(h.getHoaDonId())
                  .append(",\"accountId\":").append(h.getAccountId())
                  .append(",\"soTienHoan\":").append(h.getSoTienHoan() != null ? h.getSoTienHoan().longValue() : 0)
                  .append(",\"lyDo\":\"").append(escape(h.getLyDo())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(h.getTrangThai())).append("\"")
                  .append(",\"thoiGianYeuCau\":\"").append(h.getThoiGianYeuCau() != null ? h.getThoiGianYeuCau().toString() : "").append("\"")
                  .append(",\"ghiChuXuLy\":\"").append(escape(h.getGhiChuXuLy())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleCaLamViec(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        try {
            String fromStr = req.getParameter("from");
            String toStr = req.getParameter("to");
            LocalDate from = fromStr != null ? LocalDate.parse(fromStr) : LocalDate.now().withDayOfMonth(1);
            LocalDate to = toStr != null ? LocalDate.parse(toStr) : from.plusMonths(1).minusDays(1);
            List<CaLamViec> list = caLamViecDAO.getCaByAccountIDAndDateRange(user.getAccountId(), from, to);
            StringBuilder sb = new StringBuilder("{\"shifts\":[");
            for (int i = 0; i < list.size(); i++) {
                CaLamViec c = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(c.getCaLamViecId())
                  .append(",\"tenCa\":\"").append(escape(c.getTenCa())).append("\"")
                  .append(",\"viTri\":\"").append(escape(c.getViTri())).append("\"")
                  .append(",\"ngayLam\":\"").append(c.getNgayLam() != null ? c.getNgayLam().toString() : "").append("\"")
                  .append(",\"gioBatDau\":\"").append(c.getGioBatDau() != null ? c.getGioBatDau().toString() : "").append("\"")
                  .append(",\"gioKetThuc\":\"").append(c.getGioKetThuc() != null ? c.getGioKetThuc().toString() : "").append("\"")
                  .append(",\"trangThai\":\"").append(escape(c.getTrangThai())).append("\"")
                  .append(",\"ghiChu\":\"").append(escape(c.getGhiChu())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleYeuCauQr(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<QRRequest> list = qrRequestDAO.findByCoSoAndStatus(coSoId, null);
            StringBuilder sb = new StringBuilder("{\"requests\":[");
            for (int i = 0; i < list.size(); i++) {
                QRRequest q = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(q.getRequestId())
                  .append(",\"sanId\":").append(q.getSanId())
                  .append(",\"status\":\"").append(escape(q.getStatus())).append("\"")
                  .append(",\"createdAt\":\"").append(q.getCreatedAt() != null ? q.getCreatedAt().toString() : "").append("\"")
                  .append(",\"note\":\"").append(escape(q.getNote())).append("\"")
                  .append(",\"requestType\":\"").append(escape(q.getRequestType())).append("\"")
                  .append(",\"handledByStaffId\":").append(q.getHandledByStaffId() != null ? q.getHandledByStaffId() : 0)
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private TaiKhoan requireStaff(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_LE_TAN) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
            return null;
        }
        return user;
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
