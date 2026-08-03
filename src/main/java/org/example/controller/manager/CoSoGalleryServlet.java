package org.example.controller.manager;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Quản lý gallery ảnh cơ sở (CoSo.HinhAnh lưu JSON array).
 * GET  /manager/co-so-gallery        → list ảnh hiện tại
 * POST /manager/co-so-gallery        → action=upload (multipart file "image") | action=delete (param url)
 */
@WebServlet("/manager/co-so-gallery")
@MultipartConfig(fileSizeThreshold = 512 * 1024, maxFileSize = 8 * 1024 * 1024, maxRequestSize = 50 * 1024 * 1024)
public class CoSoGalleryServlet extends HttpServlet {

    private static final Set<String> ALLOWED_TYPES = Set.of("image/jpeg", "image/png", "image/webp", "image/gif");
    private static final int MAX_IMAGES = 10;
    private static final Gson GSON = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;
        List<String> urls = loadUrls(user.getCoSoId());
        writeJson(resp, 200, Map.of("images", urls));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;
        String action = req.getParameter("action");
        if ("upload".equals(action)) {
            doUpload(req, resp, user.getCoSoId());
        } else if ("delete".equals(action)) {
            doDelete(req, resp, user.getCoSoId());
        } else {
            writeJson(resp, 400, Map.of("error", "action không hợp lệ"));
        }
    }

    private void doUpload(HttpServletRequest req, HttpServletResponse resp, int coSoId) throws IOException, ServletException {
        Part part = req.getPart("image");
        if (part == null || part.getSize() == 0) {
            writeJson(resp, 400, Map.of("error", "Không có file được gửi lên.")); return;
        }
        String ct = part.getContentType();
        if (ct == null || !ALLOWED_TYPES.contains(ct)) {
            writeJson(resp, 400, Map.of("error", "Chỉ hỗ trợ JPG, PNG, WEBP, GIF.")); return;
        }
        List<String> urls = loadUrls(coSoId);
        if (urls.size() >= MAX_IMAGES) {
            writeJson(resp, 400, Map.of("error", "Tối đa " + MAX_IMAGES + " ảnh cho mỗi cơ sở.")); return;
        }

        String ext = resolveExt(part.getSubmittedFileName(), ct);
        String fileName = "coso-" + UUID.randomUUID() + ext;
        File dir = CourtsImageServeServlet.courtsDir();
        if (!dir.exists()) dir.mkdirs();
        part.write(new File(dir, fileName).getAbsolutePath());

        String url = "/media/courts/" + fileName;
        urls.add(url);
        saveUrls(coSoId, urls);
        writeJson(resp, 200, Map.of("url", url, "images", urls));
    }

    private void doDelete(HttpServletRequest req, HttpServletResponse resp, int coSoId) throws IOException {
        String url = req.getParameter("url");
        if (url == null || url.isBlank()) {
            writeJson(resp, 400, Map.of("error", "Thiếu tham số url.")); return;
        }
        List<String> urls = loadUrls(coSoId);
        urls.remove(url.trim());
        saveUrls(coSoId, urls);
        writeJson(resp, 200, Map.of("images", urls));
    }

    private List<String> loadUrls(int coSoId) {
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT HinhAnh FROM CoSo WHERE CoSoID=?")) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return parseJson(rs.getString("HinhAnh"));
            }
        } catch (Exception e) { /* log */ }
        return new ArrayList<>();
    }

    private void saveUrls(int coSoId, List<String> urls) {
        String json = urls.isEmpty() ? null : GSON.toJson(urls);
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE CoSo SET HinhAnh=? WHERE CoSoID=?")) {
            ps.setString(1, json);
            ps.setInt(2, coSoId);
            ps.executeUpdate();
        } catch (Exception e) { /* log */ }
    }

    public static List<String> parseJson(String raw) {
        if (raw == null || raw.isBlank()) return new ArrayList<>();
        String trimmed = raw.trim();
        if (trimmed.startsWith("[")) {
            try {
                //noinspection unchecked
                List<String> list = new Gson().fromJson(trimmed, List.class);
                return list != null ? new ArrayList<>(list) : new ArrayList<>();
            } catch (Exception ignored) {}
        }
        List<String> single = new ArrayList<>();
        single.add(trimmed);
        return single;
    }

    private String resolveExt(String name, String ct) {
        String n = name == null ? "" : name.toLowerCase();
        if (n.endsWith(".jpg") || n.endsWith(".jpeg")) return ".jpg";
        if (n.endsWith(".png")) return ".png";
        if (n.endsWith(".webp")) return ".webp";
        if (n.endsWith(".gif")) return ".gif";
        return switch (ct) {
            case "image/jpeg" -> ".jpg";
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            default -> ".gif";
        };
    }

    private TaiKhoan requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Object obj = req.getSession(false) != null ? req.getSession(false).getAttribute("user") : null;
        if (!(obj instanceof TaiKhoan u) || u.getRoleId() != Constants.ROLE_MANAGER || u.getCoSoId() == null) {
            writeJson(resp, 403, Map.of("error", "Không có quyền truy cập."));
            return null;
        }
        return u;
    }

    private void writeJson(HttpServletResponse resp, int status, Object body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(GSON.toJson(body));
    }
}
