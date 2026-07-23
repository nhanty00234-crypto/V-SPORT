package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.service.manager.SanQRService;

import java.io.IOException;

/**
 * Customer-facing entry point khi quét QR sân. Servlet này chỉ đọc/resolve
 * short code rồi forward sang QuetQR.jsp - KHÔNG tạo/sửa/xoá bất kỳ bản ghi
 * nào (không check-in, không QRRequest).
 */
@WebServlet({"/qr/*"})
public class SanQRResolveServlet extends HttpServlet {

    private final SanQRService sanQRService = new SanQRService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String shortCode = pathInfo != null ? pathInfo.replace("/", "") : null;
        if (shortCode == null || shortCode.isBlank()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        SanQRService.PublicResolveResult result = sanQRService.resolveActiveShortCode(shortCode);
        SanQRResolveDTO dto = result.dto;
        req.setAttribute("resolveDto", dto);
        req.setAttribute("shortCode", shortCode);
        req.setAttribute("sanId", dto != null ? dto.getSanId() : null);
        req.getRequestDispatcher("/customer/QuetQR.jsp").forward(req, resp);
    }
}
