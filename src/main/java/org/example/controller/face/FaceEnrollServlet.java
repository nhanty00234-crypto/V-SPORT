package org.example.controller.face;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.*;
import java.nio.file.*;
import java.util.Objects;
import java.util.*;

@WebServlet("/face/enroll")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class FaceEnrollServlet extends HttpServlet {

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        TaiKhoan user = getAuthorizedUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        int targetId = resolveTargetId(req, user);

        // Manager chỉ được xem nhân sự cùng cơ sở (getAccountById mới có CoSoID)
        if (targetId != user.getAccountId() && !isSameBranch(targetId, user)) {
            resp.setStatus(403);
            resp.getWriter().write("{\"error\":\"Không có quyền xem thông tin khuôn mặt của tài khoản này\"}");
            return;
        }

        TaiKhoan faceData = taiKhoanDAO.getFaceData(targetId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("enrolled", faceData != null && faceData.getFaceDescriptor() != null);
        result.put("imagePath", faceData != null ? faceData.getFaceImagePath() : null);
        result.put("enrolledAt", faceData != null && faceData.getFaceEnrolledAt() != null
                ? faceData.getFaceEnrolledAt().toString() : null);
        resp.getWriter().write(gson.toJson(result));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        TaiKhoan user = getAuthorizedUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }

        int targetId = resolveTargetId(req, user);

        // Manager chỉ được đăng ký cho nhân sự cùng cơ sở
        if (targetId != user.getAccountId() && !isSameBranch(targetId, user)) {
            resp.setStatus(403);
            resp.getWriter().write("{\"error\":\"Không có quyền đăng ký khuôn mặt cho tài khoản này\"}");
            return;
        }

        String contentType = req.getContentType();
        String descriptorJson;
        String imagePath = null;

        if (contentType != null && contentType.startsWith("application/json")) {
            // Self-enroll: descriptor array + snapshot base64 from face-api.js
            StringBuilder sb = new StringBuilder();
            try (BufferedReader r = req.getReader()) {
                String line;
                while ((line = r.readLine()) != null) sb.append(line);
            }
            JsonObject body = gson.fromJson(sb.toString(), JsonObject.class);
            if (body == null || !body.has("descriptor")) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (cần 128 số)\"}");
                return;
            }
            JsonArray arr = body.get("descriptor").getAsJsonArray();
            if (arr == null || arr.size() < 128) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (cần 128 số)\"}");
                return;
            }
            descriptorJson = arr.toString();
            String photo = body.has("photo") ? body.get("photo").getAsString() : null;
            imagePath = savePhotoBase64(photo, targetId);

        } else if (contentType != null && contentType.startsWith("multipart/form-data")) {
            // Manager upload: descriptor field + photo file part
            String descField = req.getParameter("descriptor");
            if (descField == null || descField.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu descriptor\"}");
                return;
            }
            descriptorJson = descField;
            Part filePart = req.getPart("photo");
            if (filePart != null && filePart.getSize() > 0) {
                imagePath = savePhotoStream(filePart.getInputStream(), targetId);
            }

        } else {
            resp.getWriter().write("{\"success\":false,\"error\":\"Content-Type không hỗ trợ\"}");
            return;
        }

        taiKhoanDAO.updateFaceData(targetId, descriptorJson, imagePath);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("enrolledAt", java.time.LocalDateTime.now().toString());
        resp.getWriter().write(gson.toJson(result));
    }

    // --- helpers ---

    /** Nhân sự đích phải cùng cơ sở với manager và thuộc role được phân ca. */
    private boolean isSameBranch(int targetId, TaiKhoan manager) {
        TaiKhoan target = taiKhoanDAO.getAccountById(targetId);
        return target != null
                && Objects.equals(target.getCoSoId(), manager.getCoSoId())
                && Constants.ALLOWED_SHIFT_ROLES.contains(target.getRoleId());
    }

    private int resolveTargetId(HttpServletRequest req, TaiKhoan user) {
        String targetParam = req.getParameter("targetAccountId");
        if (targetParam != null && user.getRoleId() == Constants.ROLE_MANAGER) {
            try { return Integer.parseInt(targetParam); } catch (NumberFormatException ignored) {}
        }
        return user.getAccountId();
    }

    private String savePhotoBase64(String base64DataUrl, int accountId) {
        if (base64DataUrl == null || !base64DataUrl.startsWith("data:image")) return null;
        try {
            byte[] bytes = Base64.getDecoder().decode(base64DataUrl.substring(base64DataUrl.indexOf(',') + 1));
            return saveBytes(bytes, accountId);
        } catch (Exception e) {
            return null;
        }
    }

    private String savePhotoStream(InputStream stream, int accountId) throws IOException {
        return saveBytes(stream.readAllBytes(), accountId);
    }

    private String saveBytes(byte[] bytes, int accountId) throws IOException {
        String dir = getServletContext().getRealPath("/uploads/face-photos");
        if (dir == null) {
            dir = new File(System.getProperty("user.home"), "v-sport/uploads/face-photos").getAbsolutePath();
        }
        new File(dir).mkdirs();
        String filename = "face_" + accountId + "_" + System.currentTimeMillis() + ".jpg";
        Files.write(Paths.get(dir, filename), bytes);
        return "/uploads/face-photos/" + filename;
    }

    /**
     * Chỉ Manager được đăng ký khuôn mặt — nhân viên không tự đăng ký nữa mà phải
     * đến gặp quản lý, quản lý đăng ký hộ tại /manager/face-settings.
     */
    private TaiKhoan getAuthorizedUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        return user.getRoleId() == Constants.ROLE_MANAGER ? user : null;
    }
}
