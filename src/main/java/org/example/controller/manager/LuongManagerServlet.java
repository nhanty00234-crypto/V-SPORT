package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.CauHinhLuong;
import org.example.model.KyLuong;
import org.example.model.TaiKhoan;
import org.example.model.YeuCauUngLuong;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Các trang quản lý lương của manager. Mọi thao tác đều lấy CoSoID từ session —
 * không bao giờ từ request param, nên manager không thể chạm dữ liệu cơ sở khác.
 */
@WebServlet({"/manager/luong", "/manager/luong/cau-hinh", "/manager/luong/phat", "/manager/luong/ung-luong"})
public class LuongManagerServlet extends HttpServlet {

    private final LuongService luongService = new LuongService();
    private final UngLuongService ungLuongService = new UngLuongService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/manager/luong/cau-hinh" -> {
                    req.setAttribute("dsCauHinh", luongService.danhSachCauHinh(coSoId));
                    req.getRequestDispatcher("/manager/CauHinhLuong.jsp").forward(req, resp);
                }
                case "/manager/luong/phat" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    KyLuong ky = null;
                    for (KyLuong k : luongService.danhSachKy(coSoId)) {
                        if (k.getKyLuongId() == kyLuongId) { ky = k; break; }
                    }
                    if (ky == null) {
                        req.getSession().setAttribute("flashError", "Kỳ lương không tồn tại.");
                        resp.sendRedirect(req.getContextPath() + "/manager/luong");
                        return;
                    }
                    req.setAttribute("ky", ky);
                    req.setAttribute("dsBangLuong", luongService.bangLuongCuaKy(kyLuongId, coSoId));
                    req.setAttribute("laNgayPhat", LocalDate.now().equals(ky.getNgayPhatLuong()));
                    req.getRequestDispatcher("/manager/PhatLuong.jsp").forward(req, resp);
                }
                case "/manager/luong/ung-luong" -> {
                    String loc = req.getParameter("trangThai");
                    if (loc != null && loc.isBlank()) loc = null;
                    req.setAttribute("dsYeuCau", ungLuongService.danhSachChoManager(coSoId, loc));
                    req.setAttribute("locTrangThai", loc);
                    req.getRequestDispatcher("/manager/DuyetUngLuong.jsp").forward(req, resp);
                }
                default -> {
                    req.setAttribute("dsKy", luongService.danhSachKy(coSoId));
                    req.setAttribute("kyPhatHomNay", luongService.kyPhatLuongHomNay(coSoId));
                    req.setAttribute("soUngChoDuyet",
                            ungLuongService.danhSachChoManager(coSoId, YeuCauUngLuong.CHO_DUYET).size());
                    req.getRequestDispatcher("/manager/Luong.jsp").forward(req, resp);
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi tải trang lương", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();
        HttpSession session = req.getSession();

        try {
            if ("/manager/luong/cau-hinh".equals(req.getServletPath())) {
                luuCauHinh(req, coSoId);
                resp.sendRedirect(req.getContextPath() + "/manager/luong/cau-hinh");
                return;
            }

            String action = req.getParameter("action");
            switch (action == null ? "" : action) {
                case "tao-ky" -> {
                    int id = luongService.taoKy(coSoId, manager.getAccountId(),
                            req.getParameter("tenKy"),
                            parseDate(req.getParameter("ngayBatDau")),
                            parseDate(req.getParameter("ngayKetThuc")),
                            parseDate(req.getParameter("ngayPhatLuong")));
                    session.setAttribute("flashSuccess", "Đã tạo kỳ lương (mã #" + id + ").");
                }
                case "tinh-luong" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    int soNv = luongService.tinhLuongChoKy(kyLuongId, coSoId);
                    session.setAttribute("flashSuccess", "Đã tính lương cho " + soNv + " nhân viên.");
                }
                case "chot-phat" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    luongService.chotPhatLuong(kyLuongId, coSoId);
                    session.setAttribute("flashSuccess", "Đã chốt phát lương cho kỳ này.");
                }
                default -> session.setAttribute("flashError", "Hành động không hợp lệ.");
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý thao tác lương", e);
        }
        resp.sendRedirect(req.getContextPath() + "/manager/luong");
    }

    /** Lưu cấu hình lương cho MỘT nhân viên (form inline trên từng dòng bảng). */
    private void luuCauHinh(HttpServletRequest req, int coSoId) throws Exception {
        CauHinhLuong ch = new CauHinhLuong();
        ch.setAccountId(parseInt(req.getParameter("accountId"), 0));
        ch.setCoSoId(coSoId);
        ch.setLuongCoBan(parseTien(req.getParameter("luongCoBan")));
        ch.setPhuCapMoiCa(parseTien(req.getParameter("phuCapMoiCa")));
        ch.setHanMucUng(parseTien(req.getParameter("hanMucUng")));
        ch.setGhiChu(req.getParameter("ghiChu"));

        if (ch.getAccountId() <= 0) {
            req.getSession().setAttribute("flashError", "Thiếu thông tin nhân viên.");
            return;
        }
        // Chỉ cho lưu nếu nhân viên thật sự thuộc cơ sở của manager — listByCoSo là nguồn
        // sự thật duy nhất về "nhân viên của tôi".
        boolean thuocCoSo = luongService.danhSachCauHinh(coSoId).stream()
                .anyMatch(x -> x.getAccountId() == ch.getAccountId());
        if (!thuocCoSo) {
            req.getSession().setAttribute("flashError", "Không có quyền thao tác trên nhân viên này.");
            return;
        }

        luongService.luuCauHinh(ch);
        req.getSession().setAttribute("flashSuccess", "Đã lưu cấu hình lương.");
    }

    private static BigDecimal parseTien(String v) {
        if (v == null || v.isBlank()) return BigDecimal.ZERO;
        try {
            // Form có thể gửi "5.000.000" hoặc "5,000,000" — bỏ mọi ký tự phân cách.
            return new BigDecimal(v.replaceAll("[^0-9]", ""));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private static LocalDate parseDate(String v) {
        try {
            return LocalDate.parse(v);
        } catch (Exception e) {
            return null;
        }
    }

    private static int parseInt(String v, int fallback) {
        try {
            return Integer.parseInt(v);
        } catch (Exception e) {
            return fallback;
        }
    }

    private TaiKhoan getManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
