package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import org.example.util.StaffQrUploadPaths;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Locale;

/**
 * Stream ảnh QR ngân hàng tĩnh của nhân viên. Dữ liệu nhạy cảm: mỗi request kiểm tra quyền,
 * không cache, không lộ đường dẫn filesystem.
 *
 * GET /nhan-vien/qr-image?accountId=X
 */
@WebServlet("/nhan-vien/qr-image")
public class NhanVienQrServeServlet extends HttpServlet {

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int accountId;
        try {
            accountId = Integer.parseInt(req.getParameter("accountId"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        TaiKhoan target = taiKhoanDAO.getAccountById(accountId);
        if (target == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        boolean laChinhMinh = user.getAccountId() == accountId;
        boolean laManagerCungCoSo = user.getRoleId() == Constants.ROLE_MANAGER
                && user.getCoSoId() != null
                && user.getCoSoId().equals(target.getCoSoId());
        if (!laChinhMinh && !laManagerCungCoSo) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File file = StaffQrUploadPaths.resolveSafely(target.getQrImagePath());
        if (file == null || !file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = guessContentType(file.getName());
        if (contentType == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "private, no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        Files.copy(file.toPath(), resp.getOutputStream());
    }

    private static String guessContentType(String fileName) {
        String lower = fileName.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".webp")) return "image/webp";
        return null;
    }
}
