package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.Hoantien;
import org.example.model.TaiKhoan;
import org.example.service.RefundQrService;
import org.example.service.RefundService;
import org.example.util.Constants;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;
import java.io.InputStream;

/**
 * GET  /customer/hoan-tien              — danh sách yêu cầu hoàn tiền của mình
 * GET  /customer/hoan-tien?id=X         — chi tiết 1 yêu cầu (chỉ nếu thuộc mình)
 * POST /customer/hoan-tien?action=      — request | update-bank | upload-qr | cancel
 *
 * Mọi thao tác đều dùng findByIdAndAccountId ở tầng DAO — chống IDOR, không chỉ lọc ở JSP.
 * Không tin số tiền từ client: requestRefundSelfService tự đọc lại HoaDon.TongThanhToan.
 */
@WebServlet("/customer/hoan-tien")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = RefundQrService.MAX_FILE_BYTES,
        maxRequestSize = RefundQrService.MAX_FILE_BYTES + 1024 * 1024
)
public class RefundCustomerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(RefundCustomerServlet.class);

    private final RefundService refundService = new RefundService();
    private final RefundQrService refundQrService = new RefundQrService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireCustomer(req, resp);
        if (user == null) return;

        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isBlank()) {
            int hoanTienId = parseIntSafe(idParam, 0);
            Hoantien ht = hoanTienId > 0 ? refundService.findByIdAndAccountId(hoanTienId, user.getAccountId()) : null;
            if (ht == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy yêu cầu hoàn tiền.");
                return;
            }
            req.setAttribute("hoanTien", ht);
            req.getRequestDispatcher("/customer/HoanTienChiTiet.jsp").forward(req, resp);
            return;
        }

        int page = Math.max(1, parseIntSafe(req.getParameter("page"), 1));
        req.setAttribute("danhSachHoanTien", refundService.getByCustomer(user.getAccountId(), page));
        req.setAttribute("page", page);
        req.getRequestDispatcher("/customer/HoanTien.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireCustomer(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        RefundService.RefundResult result;

        switch (action != null ? action : "") {
            case "request": {
                int datSanId = parseIntSafe(req.getParameter("datSanId"), 0);
                if (datSanId <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?error=invalid");
                    return;
                }
                String lyDo = sanitize(req.getParameter("lyDo"));
                String nganHang = sanitize(req.getParameter("nganHang"));
                String soTaiKhoan = sanitize(req.getParameter("soTaiKhoan"));
                String chuTaiKhoan = sanitize(req.getParameter("chuTaiKhoan"));
                result = refundService.requestRefundSelfService(datSanId, user.getAccountId(), lyDo,
                        nganHang, soTaiKhoan, chuTaiKhoan, null);
                if (result.success && result.hoanTienId != null && result.hoanTienId > 0) {
                    String qrRelPath = tryUploadQr(req, result.hoanTienId, user.getAccountId());
                    if (qrRelPath == null) {
                        logger.info("RefundCustomerServlet: không có QR đính kèm hoặc upload lỗi cho HoanTien #{}", result.hoanTienId);
                    }
                }
                break;
            }
            case "update-bank": {
                int hoanTienId = parseIntSafe(req.getParameter("hoanTienId"), 0);
                String nganHang = sanitize(req.getParameter("nganHang"));
                String soTaiKhoan = sanitize(req.getParameter("soTaiKhoan"));
                String chuTaiKhoan = sanitize(req.getParameter("chuTaiKhoan"));
                result = refundService.updateBankInfo(hoanTienId, user.getAccountId(), nganHang, soTaiKhoan, chuTaiKhoan, null);
                if (result.success) {
                    tryUploadQr(req, hoanTienId, user.getAccountId());
                }
                break;
            }
            case "upload-qr": {
                int hoanTienId = parseIntSafe(req.getParameter("hoanTienId"), 0);
                if (hoanTienId <= 0) {
                    resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?error=invalid");
                    return;
                }
                String path = tryUploadQr(req, hoanTienId, user.getAccountId());
                result = path != null
                        ? RefundService.RefundResult.ok(hoanTienId, "Đã cập nhật ảnh QR nhận tiền.")
                        : RefundService.RefundResult.fail("Không thể tải ảnh QR. Vui lòng thử lại.");
                break;
            }
            case "cancel": {
                int hoanTienId = parseIntSafe(req.getParameter("hoanTienId"), 0);
                result = refundService.cancelByCustomer(hoanTienId, user.getAccountId());
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?error=unknown_action");
                return;
        }

        if (result.success) {
            resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?success=1"
                    + (result.hoanTienId != null && result.hoanTienId > 0 ? "&id=" + result.hoanTienId : ""));
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?error=" + encodeParam(result.message));
        }
    }

    /** Đọc Part "qrImage" nếu có kèm trong multipart request và upload qua RefundQrService. */
    private String tryUploadQr(HttpServletRequest req, int hoanTienId, int accountId) {
        try {
            Part part = req.getPart("qrImage");
            if (part == null || part.getSize() <= 0) return null;
            byte[] bytes;
            try (InputStream is = part.getInputStream()) {
                bytes = is.readAllBytes();
            }
            return refundQrService.uploadQr(hoanTienId, accountId, bytes, part.getSubmittedFileName());
        } catch (RefundQrService.QrException e) {
            logger.warn("tryUploadQr hoanTienId={}: {}", hoanTienId, e.getMessage());
            return null;
        } catch (Exception e) {
            // Request không phải multipart (form không kèm ảnh) — không phải lỗi, bỏ qua.
            return null;
        }
    }

    private TaiKhoan requireCustomer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI()));
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_KHACH_HANG) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private static int parseIntSafe(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static String sanitize(String s) {
        return (s != null) ? s.trim() : null;
    }

    private static String encodeParam(String s) {
        if (s == null) return "";
        try { return java.net.URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }
}
