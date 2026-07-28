package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.model.NhomChiaTienChiTiet;
import org.example.service.billsplit.BillSplitService;
import org.example.util.QrCodeRenderer;

import java.io.IOException;

/**
 * Render QR trỏ tới trang thanh toán Share (paymentUrl), không phải VietQR ngân hàng — Customer
 * chủ booking chia sẻ ảnh này để participant quét mở đúng link thanh toán phần của họ. Token đã
 * được xác thực tồn tại trước khi render — không tạo QR cho token rác để tránh lộ khả năng brute-force.
 *
 * GET /chia-tien/qr?token=X
 */
@WebServlet("/chia-tien/qr")
public class BillSplitQrServlet extends HttpServlet {

    private final BillSplitService billSplitService = new BillSplitService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String token = req.getParameter("token");
        NhomChiaTienChiTiet ct = token != null ? billSplitService.getShareByToken(token) : null;
        if (ct == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String paymentUrl = absoluteBaseUrl(req) + req.getContextPath() + "/chia-tien/thanh-toan?token=" + token;
        try {
            byte[] png = QrCodeRenderer.toPngBytes(paymentUrl, 320);
            resp.setContentType("image/png");
            resp.setContentLengthLong(png.length);
            resp.setHeader("Cache-Control", "private, no-store, no-cache, must-revalidate");
            resp.getOutputStream().write(png);
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private String absoluteBaseUrl(HttpServletRequest req) {
        return req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() != 80 && req.getServerPort() != 443 ? ":" + req.getServerPort() : "");
    }
}
