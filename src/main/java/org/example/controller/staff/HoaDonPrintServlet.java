package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.TaiKhoan;
import org.example.service.invoice.InvoiceView;
import org.example.service.invoice.InvoiceViewService;

import java.io.IOException;
import java.util.NoSuchElementException;

/**
 * Route CHỈ ĐỌC để xem trước / in lại hóa đơn (bill 80mm).
 * Không tạo hóa đơn, không thanh toán, không trừ kho, không cập nhật trạng thái.
 * Dùng chung InvoiceViewService với API chi tiết hóa đơn (HoaDonDetailServlet) - cùng
 * một nguồn dữ liệu cho modal thanh toán và trang in, không query hai cách khác nhau.
 */
@WebServlet("/staff/hoa-don/in")
public class HoaDonPrintServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(HoaDonPrintServlet.class);

    private final InvoiceViewService invoiceViewService = new InvoiceViewService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Kiểm tra đăng nhập + role Staff (4) hoặc Manager (2)
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            return;
        }

        // 2. Parse HoaDonID an toàn
        String idStr = req.getParameter("id");
        int hoaDonId;
        try {
            if (idStr == null || idStr.isEmpty()) {
                throw new NumberFormatException("missing id");
            }
            hoaDonId = Integer.parseInt(idStr.trim());
            if (hoaDonId <= 0) throw new NumberFormatException("non-positive id");
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã hóa đơn không hợp lệ.");
            return;
        }

        try {
            InvoiceView invoice = invoiceViewService.load(hoaDonId, user, req.getContextPath());
            req.setAttribute("invoice", invoice);
            req.getRequestDispatcher("/staff/HoaDonPrint.jsp").forward(req, resp);
        } catch (NoSuchElementException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        } catch (Exception e) {
            logger.error("Không thể tải hóa đơn #{}", hoaDonId, e);
            if (!resp.isCommitted()) {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tải hóa đơn.");
            }
        }
    }
}
