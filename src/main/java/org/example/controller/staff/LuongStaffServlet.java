package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;
import org.example.util.ImageInspector;
import org.example.util.StaffQrUploadPaths;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.util.UUID;

/**
 * Trang "Lương của tôi" cho lễ tân. Guard dùng lại toàn bộ logic này qua LuongGuardServlet.
 * AccountID/CoSoID luôn lấy từ session — nhân viên không thể xem lương người khác.
 */
@WebServlet("/staff/luong")
@MultipartConfig(fileSizeThreshold = 1 << 16, maxFileSize = 3 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class LuongStaffServlet extends HttpServlet {

    /** Giới hạn ảnh QR: 3MB, tối thiểu 120×120 để còn quét được. */
    private static final int MAX_QR_BYTES = 3 * 1024 * 1024;
    private static final int MIN_QR_EDGE = 120;

    protected final LuongService luongService = new LuongService();
    protected final UngLuongService ungLuongService = new UngLuongService();
    protected final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    /** Role được phép vào trang này. Guard servlet override thành ROLE_BAO_VE. */
    protected int vaiTroChoPhep() {
        return Constants.ROLE_LE_TAN;
    }

    /** URL của chính trang này, dùng để redirect sau POST. */
    protected String duongDan() {
        return "/staff/luong";
    }

    /**
     * Sidebar của guard tô sáng mục đang mở dựa trên requestScope.guardPage; sidebar staff
     * lại dựa trên URI nên bản staff không cần đặt gì. Guard servlet override.
     */
    protected void danhDauSidebar(HttpServletRequest req) {
        // staff: không cần
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan me = getNhanVien(req, resp);
        if (me == null) return;
        try {
            // Đọc lại từ DB: session có thể đang giữ bản cũ chưa có thông tin ngân hàng vừa lưu.
            danhDauSidebar(req);
            TaiKhoan moiNhat = taiKhoanDAO.getAccountById(me.getAccountId());
            req.setAttribute("nhanVien", moiNhat == null ? me : moiNhat);
            req.setAttribute("dsBangLuong", luongService.lichSuLuongCuaToi(me.getAccountId()));
            req.setAttribute("dsYeuCau", ungLuongService.lichSuCuaToi(me.getAccountId()));
            req.setAttribute("hanMucConLai", ungLuongService.hanMucConLai(me.getAccountId(), me.getCoSoId()));
            req.getRequestDispatcher("/staff/LuongCuaToi.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Lỗi tải trang lương của tôi", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan me = getNhanVien(req, resp);
        if (me == null) return;
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "gui-ung" -> {
                    ungLuongService.guiYeuCau(me.getAccountId(), me.getCoSoId(),
                            parseTien(req.getParameter("soTienUng")), req.getParameter("lyDo"));
                    session.setAttribute("flashSuccess", "Đã gửi yêu cầu ứng lương, chờ quản lý duyệt.");
                }
                case "huy-ung" -> {
                    int id = Integer.parseInt(req.getParameter("yeuCauId"));
                    boolean ok = ungLuongService.huy(id, me.getAccountId());
                    session.setAttribute(ok ? "flashSuccess" : "flashError",
                            ok ? "Đã huỷ yêu cầu ứng lương."
                               : "Không thể huỷ — yêu cầu đã được xử lý.");
                }
                case "luu-ngan-hang" -> {
                    taiKhoanDAO.updateBankInfo(me.getAccountId(),
                            req.getParameter("maNganHang"), req.getParameter("soTaiKhoan"));
                    session.setAttribute("flashSuccess", "Đã cập nhật tài khoản ngân hàng nhận lương.");
                }
                case "upload-qr" -> uploadQr(req, me);
                default -> session.setAttribute("flashError", "Hành động không hợp lệ.");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý thao tác lương", e);
        }
        resp.sendRedirect(req.getContextPath() + duongDan());
    }

    /** Lưu ảnh QR tĩnh: kiểm tra magic bytes qua ImageInspector, ghi ra ngoài webroot. */
    private void uploadQr(HttpServletRequest req, TaiKhoan me) throws Exception {
        Part part = req.getPart("qrImage");
        if (part == null || part.getSize() <= 0) {
            req.getSession().setAttribute("flashError", "Vui lòng chọn ảnh QR.");
            return;
        }
        if (part.getSize() > MAX_QR_BYTES) {
            req.getSession().setAttribute("flashError", "Ảnh QR vượt quá 3MB.");
            return;
        }

        byte[] bytes;
        try (InputStream in = part.getInputStream()) {
            bytes = in.readAllBytes();
        }
        ImageInspector.Result kq = ImageInspector.inspect(bytes, MIN_QR_EDGE, MIN_QR_EDGE);
        if (!kq.valid) {
            req.getSession().setAttribute("flashError", kq.error);
            return;
        }

        File dir = StaffQrUploadPaths.nhanVienDir(me.getAccountId());
        Files.createDirectories(dir.toPath());
        String fileName = UUID.randomUUID() + kq.extension;
        Files.write(new File(dir, fileName).toPath(), bytes);

        // Xoá ảnh cũ để không tích rác trong thư mục upload.
        TaiKhoan hienTai = taiKhoanDAO.getAccountById(me.getAccountId());
        String cu = hienTai == null ? null : hienTai.getQrImagePath();
        taiKhoanDAO.updateQrImagePath(me.getAccountId(),
                StaffQrUploadPaths.relativePath(me.getAccountId(), fileName));
        if (cu != null && !cu.isBlank()) {
            File fileCu = StaffQrUploadPaths.resolveSafely(cu);
            if (fileCu != null && fileCu.isFile()) {
                Files.deleteIfExists(fileCu.toPath());
            }
        }
        req.getSession().setAttribute("flashSuccess", "Đã tải lên ảnh QR ngân hàng.");
    }

    private static BigDecimal parseTien(String v) {
        if (v == null || v.isBlank()) return BigDecimal.ZERO;
        try {
            return new BigDecimal(v.replaceAll("[^0-9]", ""));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    protected TaiKhoan getNhanVien(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != vaiTroChoPhep() || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
