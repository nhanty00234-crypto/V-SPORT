package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.*;
import org.example.dao.impl.*;
import org.example.model.*;
import org.example.service.manager.NhanSuService;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Session-based REST endpoints cho Next.js Manager portal.
 * GET /api/v1/web/manager/dashboard
 * GET /api/v1/web/manager/san
 * GET /api/v1/web/manager/dat-san
 * GET /api/v1/web/manager/hoa-don
 * GET /api/v1/web/manager/kho-dich-vu
 * GET /api/v1/web/manager/khuyen-mai
 * GET /api/v1/web/manager/nhan-su
 * GET /api/v1/web/manager/ca-lam-viec
 * GET /api/v1/web/manager/ma-qr-san
 * GET /api/v1/web/manager/hoan-tien
 * GET /api/v1/web/manager/thung-rac
 * GET /api/v1/web/manager/audit-log
 */
@WebServlet("/api/v1/web/manager/*")
public class WebManagerApiServlet extends HttpServlet {

    private final SanDAO sanDAO = new SanDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private final NhanSuService nhanSuService = new NhanSuService();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final SanPhamDichVuDAO sanPhamDAO = new SanPhamDichVuDAOImpl();
    private final HoanTienDAO hoanTienDAO = new HoanTienDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final QRRequestDAO qrRequestDAO = new QRRequestDAOImpl();
    private final AuditLogDAO auditLogDAO = new AuditLogDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        switch (path) {
            case "/dashboard":   handleDashboard(req, resp, user); break;
            case "/san":         handleSan(resp, user); break;
            case "/dat-san":     handleDatSan(req, resp, user); break;
            case "/hoa-don":     handleHoaDon(req, resp, user); break;
            case "/kho-dich-vu": handleKhoDichVu(resp, user); break;
            case "/khuyen-mai":  handleKhuyenMai(resp, user); break;
            case "/nhan-su":     handleNhanSu(resp, user); break;
            case "/ca-lam-viec": handleCaLamViec(req, resp, user); break;
            case "/ma-qr-san":   handleMaQrSan(req, resp, user); break;
            case "/hoan-tien":   handleHoanTien(req, resp, user); break;
            case "/thung-rac":   handleThungRac(resp, user); break;
            case "/audit-log":   handleAuditLog(req, resp, user); break;
            default:
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
        }
    }

    // ── Dashboard ──────────────────────────────────────────────────────────────
    private void handleDashboard(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Tài khoản chưa liên kết cơ sở\"}"); return; }
        try {
            List<San> dsSan = sanDAO.getSansByCoSo(coSoId);
            long totalFields = dsSan.size();
            long activeFields = dsSan.stream().filter(s -> "Sẵn sàng".equals(s.getTrangThai()) || "Đang dùng".equals(s.getTrangThai())).count();
            List<Lichdatsan> todayList = lichDatSanDAO.getLichDatSanTodayByCoSo(coSoId);
            long todayCount = todayList.size();
            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);
            BigDecimal totalRevenue = hoaDonDAO.getTotalDoanhThuByCoSo(coSoId);
            List<?> staffList = nhanSuService.getStaffListByBranch(coSoId);
            long totalStaff = staffList != null ? staffList.size() : 0;
            List<HoaDon> recentInvoices = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 5);

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"coSoId\":").append(coSoId).append(",");
            sb.append("\"managerName\":\"").append(escape(user.getFullName() != null ? user.getFullName() : user.getUsername())).append("\",");
            sb.append("\"totalFields\":").append(totalFields).append(",");
            sb.append("\"activeFields\":").append(activeFields).append(",");
            sb.append("\"todayBookings\":").append(todayCount).append(",");
            sb.append("\"revenueToday\":").append(revenueToday != null ? revenueToday.longValue() : 0).append(",");
            sb.append("\"totalRevenue\":").append(totalRevenue != null ? totalRevenue.longValue() : 0).append(",");
            sb.append("\"totalStaff\":").append(totalStaff).append(",");
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

    // ── Sân ────────────────────────────────────────────────────────────────────
    private void handleSan(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<San> list = sanDAO.getSansByCoSo(coSoId);
            StringBuilder sb = new StringBuilder("{\"courts\":[");
            for (int i = 0; i < list.size(); i++) {
                San s = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(s.getSanID())
                  .append(",\"ten\":\"").append(escape(s.getTenSan())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(s.getTrangThai())).append("\"")
                  .append(",\"moTa\":\"").append(escape(s.getMoTa())).append("\"")
                  .append(",\"giaKhongDen\":").append(s.getGiaKhongDen())
                  .append(",\"giaCoDen\":").append(s.getGiaCoDen())
                  .append(",\"loaiSanId\":").append(s.getLoaiSanID())
                  .append(",\"tenLoaiSan\":\"").append(escape(s.getTenLoaiSan())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Đặt sân ────────────────────────────────────────────────────────────────
    private void handleDatSan(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<Lichdatsan> list = lichDatSanDAO.getLichDatSanByCoSo(coSoId);
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
                sb.append(",\"createdTime\":\"").append(l.getCreatedTime() != null ? l.getCreatedTime().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Hóa đơn ────────────────────────────────────────────────────────────────
    private void handleHoaDon(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<HoaDon> allHd = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 200);
            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);
            BigDecimal totalRevenue = hoaDonDAO.getTotalDoanhThuByCoSo(coSoId);
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"revenueToday\":").append(revenueToday != null ? revenueToday.longValue() : 0).append(",");
            sb.append("\"totalRevenue\":").append(totalRevenue != null ? totalRevenue.longValue() : 0).append(",");
            sb.append("\"invoices\":[");
            for (int i = 0; i < allHd.size(); i++) {
                HoaDon h = allHd.get(i);
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

    // ── Kho dịch vụ ────────────────────────────────────────────────────────────
    private void handleKhoDichVu(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<SanPham_DichVu> list = sanPhamDAO.findByCoSo(coSoId);
            long lowStock = list.stream().filter(p -> p.getSoLuongTon() > 0 && p.getSoLuongTon() <= 5).count();
            long outOfStock = list.stream().filter(p -> p.getSoLuongTon() == 0).count();
            double totalValue = list.stream().mapToDouble(p -> p.getDonGia() * p.getSoLuongTon()).sum();
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"total\":").append(list.size()).append(",");
            sb.append("\"lowStock\":").append(lowStock).append(",");
            sb.append("\"outOfStock\":").append(outOfStock).append(",");
            sb.append("\"totalInventoryValue\":").append((long) totalValue).append(",");
            sb.append("\"products\":[");
            for (int i = 0; i < list.size(); i++) {
                SanPham_DichVu p = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(p.getSanPhamID())
                  .append(",\"ten\":\"").append(escape(p.getTenSanPham())).append("\"")
                  .append(",\"donGia\":").append(p.getDonGia())
                  .append(",\"soLuongTon\":").append(p.getSoLuongTon())
                  .append(",\"trangThai\":\"").append(escape(p.getTrangThai())).append("\"")
                  .append(",\"skuCode\":\"").append(escape(p.getSkuCode())).append("\"")
                  .append(",\"danhMucId\":").append(p.getDanhMucID())
                  .append(",\"donViTinh\":\"").append(escape(p.getDonViTinh())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Khuyến mãi ─────────────────────────────────────────────────────────────
    private void handleKhuyenMai(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<KhuyenMai> list = khuyenMaiDAO.findByCoSoId(coSoId);
            LocalDate today = LocalDate.now();
            long active = list.stream().filter(k -> "Đang diễn ra".equals(k.getTrangThai())).count();
            long upcoming = list.stream().filter(k -> "Sắp diễn ra".equals(k.getTrangThai())).count();
            long expired = list.stream().filter(k -> "Đã kết thúc".equals(k.getTrangThai())).count();
            long totalUsage = list.stream().mapToLong(KhuyenMai::getSoLanDaDung).sum();
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"countActive\":").append(active).append(",");
            sb.append("\"countUpcoming\":").append(upcoming).append(",");
            sb.append("\"countExpired\":").append(expired).append(",");
            sb.append("\"totalUsage\":").append(totalUsage).append(",");
            sb.append("\"promotions\":[");
            for (int i = 0; i < list.size(); i++) {
                KhuyenMai k = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(k.getKhuyenMaiID())
                  .append(",\"maCode\":\"").append(escape(k.getMaCode())).append("\"")
                  .append(",\"moTa\":\"").append(escape(k.getMoTa())).append("\"")
                  .append(",\"loaiGiam\":\"").append(escape(k.getLoaiGiam())).append("\"")
                  .append(",\"giaTriGiam\":").append(k.getGiaTriGiam())
                  .append(",\"ngayBatDau\":\"").append(k.getNgayBatDau() != null ? k.getNgayBatDau().toString() : "").append("\"")
                  .append(",\"ngayKetThuc\":\"").append(k.getNgayKetThuc() != null ? k.getNgayKetThuc().toString() : "").append("\"")
                  .append(",\"soLanToiDa\":").append(k.getSoLanToiDa() != null ? k.getSoLanToiDa() : 0)
                  .append(",\"soLanDaDung\":").append(k.getSoLanDaDung())
                  .append(",\"trangThai\":\"").append(escape(k.getTrangThai())).append("\"")
                  .append(",\"giaTriToiThieu\":").append(k.getGiaTriToiThieu() != null ? k.getGiaTriToiThieu().longValue() : 0)
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Nhân sự ────────────────────────────────────────────────────────────────
    private void handleNhanSu(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<NhanSuService.NhanSuDTO> list = nhanSuService.getStaffListByBranch(coSoId);
            StringBuilder sb = new StringBuilder("{\"staff\":[");
            for (int i = 0; i < list.size(); i++) {
                NhanSuService.NhanSuDTO s = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(s.getAccountId())
                  .append(",\"username\":\"").append(escape(s.getUsername())).append("\"")
                  .append(",\"fullName\":\"").append(escape(s.getFullName())).append("\"")
                  .append(",\"email\":\"").append(escape(s.getEmail())).append("\"")
                  .append(",\"phone\":\"").append(escape(s.getPhoneNumber())).append("\"")
                  .append(",\"roleId\":").append(s.getRoleId())
                  .append(",\"roleName\":\"").append(escape(s.getRoleName())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(s.getStatusDisplay())).append("\"")
                  .append(",\"locked\":").append(s.isLocked())
                  .append(",\"initial\":\"").append(escape(s.getInitial())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Ca làm việc ────────────────────────────────────────────────────────────
    private void handleCaLamViec(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            String fromStr = req.getParameter("from");
            String toStr = req.getParameter("to");
            LocalDate from = fromStr != null ? LocalDate.parse(fromStr) : LocalDate.now().withDayOfMonth(1);
            LocalDate to = toStr != null ? LocalDate.parse(toStr) : from.plusMonths(1).minusDays(1);
            List<CaLamViec> list = caLamViecDAO.getShiftsByCoSoAndDateRange(coSoId, from, to);
            StringBuilder sb = new StringBuilder("{\"shifts\":[");
            for (int i = 0; i < list.size(); i++) {
                CaLamViec c = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(c.getCaLamViecId())
                  .append(",\"accountId\":").append(c.getAccountId())
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

    // ── Mã QR sân ──────────────────────────────────────────────────────────────
    private void handleMaQrSan(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<San> courts = sanDAO.getSansByCoSo(coSoId);
            List<QRRequest> qrList = qrRequestDAO.findByCoSoAndStatus(coSoId, null);
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"courts\":[");
            for (int i = 0; i < courts.size(); i++) {
                San s = courts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(s.getSanID())
                  .append(",\"ten\":\"").append(escape(s.getTenSan())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(s.getTrangThai())).append("\"")
                  .append("}");
            }
            sb.append("],\"qrRequests\":[");
            for (int i = 0; i < qrList.size(); i++) {
                QRRequest q = qrList.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(q.getRequestId())
                  .append(",\"sanId\":").append(q.getSanId())
                  .append(",\"status\":\"").append(escape(q.getStatus())).append("\"")
                  .append(",\"createdAt\":\"").append(q.getCreatedAt() != null ? q.getCreatedAt().toString() : "").append("\"")
                  .append(",\"note\":\"").append(escape(q.getNote())).append("\"")
                  .append(",\"requestType\":\"").append(escape(q.getRequestType())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Hoàn tiền ──────────────────────────────────────────────────────────────
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
                  .append(",\"maGiaoDichHoan\":\"").append(escape(h.getMaGiaoDichHoan())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Thùng rác ──────────────────────────────────────────────────────────────
    private void handleThungRac(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            List<San> deletedCourts = sanDAO.findDeletedByCoSo(coSoId);
            List<Lichdatsan> deletedBookings = lichDatSanDAO.findDeletedByCoSo(coSoId);
            List<SanPham_DichVu> deletedProducts = sanPhamDAO.findDeletedByCoSo(coSoId);
            List<NhanSuService.NhanSuDTO> deletedStaff = nhanSuService.getDeletedStaffListByBranch(coSoId);
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"courts\":[");
            for (int i = 0; i < deletedCourts.size(); i++) {
                San s = deletedCourts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(s.getSanID())
                  .append(",\"ten\":\"").append(escape(s.getTenSan())).append("\"")
                  .append(",\"deletedAt\":\"").append(s.getDeletedAt() != null ? s.getDeletedAt().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("],\"bookings\":[");
            for (int i = 0; i < deletedBookings.size(); i++) {
                Lichdatsan l = deletedBookings.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(l.getDatSanId())
                  .append(",\"ngayDat\":\"").append(l.getNgayDat() != null ? l.getNgayDat().toString() : "").append("\"")
                  .append(",\"trangThai\":\"").append(escape(l.getTrangThai())).append("\"")
                  .append("}");
            }
            sb.append("],\"products\":[");
            for (int i = 0; i < deletedProducts.size(); i++) {
                SanPham_DichVu p = deletedProducts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(p.getSanPhamID())
                  .append(",\"ten\":\"").append(escape(p.getTenSanPham())).append("\"")
                  .append(",\"deletedAt\":\"").append(p.getDeletedAt() != null ? p.getDeletedAt().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("],\"staff\":[");
            for (int i = 0; i < deletedStaff.size(); i++) {
                NhanSuService.NhanSuDTO s = deletedStaff.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(s.getAccountId())
                  .append(",\"fullName\":\"").append(escape(s.getFullName())).append("\"")
                  .append(",\"email\":\"").append(escape(s.getEmail())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Audit log ──────────────────────────────────────────────────────────────
    private void handleAuditLog(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) { resp.setStatus(400); resp.getWriter().write("{\"error\":\"Chưa liên kết cơ sở\"}"); return; }
        try {
            String pageStr = req.getParameter("page");
            int page = pageStr != null ? Integer.parseInt(pageStr) : 1;
            List<AuditLog> list = auditLogDAO.findByCoSo(coSoId, page, 50);
            StringBuilder sb = new StringBuilder("{\"logs\":[");
            for (int i = 0; i < list.size(); i++) {
                AuditLog a = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(a.getAuditLogId())
                  .append(",\"actorName\":\"").append(escape(a.getActorName())).append("\"")
                  .append(",\"actorRole\":").append(a.getActorRole())
                  .append(",\"action\":\"").append(escape(a.getAction())).append("\"")
                  .append(",\"entityType\":\"").append(escape(a.getEntityType())).append("\"")
                  .append(",\"entityName\":\"").append(escape(a.getEntityName())).append("\"")
                  .append(",\"details\":\"").append(escape(a.getDetails())).append("\"")
                  .append(",\"ipAddress\":\"").append(escape(a.getIpAddress())).append("\"")
                  .append(",\"createdAt\":\"").append(a.getCreatedAt() != null ? a.getCreatedAt().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Auth helper ────────────────────────────────────────────────────────────
    private TaiKhoan requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
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
