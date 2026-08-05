package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.model.SanQR;
import org.example.model.TaiKhoan;
import org.example.service.manager.SanQRService;
import org.example.service.manager.SanService;
import org.example.util.Constants;

import java.io.IOException;

/**
 * Cho Manager xem trước giao diện khách hàng khi quét QR sân — đúng giao diện
 * thật, không cần quét mã. Ownership được kiểm tra qua SanService (cùng pattern
 * với SanQRPrintServlet). Thanh toán bị ẩn vì manager chỉ xem trước, không đặt.
 */
@WebServlet("/manager/ma-qr-san-xem")
public class SanQRPreviewServlet extends HttpServlet {

    private final SanService sanService = new SanService();
    private final SanQRService sanQRService = new SanQRService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
            response.sendRedirect(request.getContextPath() + "/dangnhap");
            return;
        }

        int sanId;
        try {
            sanId = Integer.parseInt(request.getParameter("sanId"));
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        // Xác minh ownership — getSanById ném exception nếu sân không thuộc cơ sở này
        try {
            sanService.getSanById(sanId, manager.getCoSoId());
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Sân không thuộc cơ sở của bạn.");
            return;
        }

        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || SanQR.REVOKED.equals(sanQR.getTrangThai())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sân chưa có mã QR hợp lệ.");
            return;
        }

        SanQRService.PublicResolveResult result = sanQRService.resolveActiveShortCode(sanQR.getShortCode());
        SanQRResolveDTO dto = (result != null && result.dto != null) ? result.dto : null;

        request.setAttribute("resolveDto", dto);
        request.setAttribute("shortCode", sanQR.getShortCode());
        request.setAttribute("sanId", sanId);
        request.setAttribute("previewMode", true); // ẩn nút Thanh toán
        request.getRequestDispatcher("/customer/QuetQR.jsp").forward(request, response);
    }
}
