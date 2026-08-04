package org.example.controller.face;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CaLamViecDAO;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.FaceChallengeTokenDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.dao.impl.FaceChallengeTokenDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.CoSoFaceConfig;
import org.example.model.FaceChallengeToken;
import org.example.model.TaiKhoan;
import org.example.util.AttendanceWindow;
import org.example.util.Constants;
import org.example.util.FaceDescriptorMatcher;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/face/checkin")
public class FaceCheckInServlet extends HttpServlet {

    private static final double MATCH_THRESHOLD = 0.6; // default threshold khi chi nhánh chưa cấu hình
    // Mẫu số quy đổi khoảng cách -> phần trăm, đồng bộ với FaceChallengeServlet để hai endpoint
    // báo cùng một thang điểm bất kể threshold của chi nhánh (slider có thể lên tới 0.75).
    private static final double MAX_DISTANCE = 0.8;

    private final FaceChallengeTokenDAO tokenDAO = new FaceChallengeTokenDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final CoSoFaceConfigDAO configDAO = new CoSoFaceConfigDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        TaiKhoan user = getSessionUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"success\":false,\"error\":\"Chưa đăng nhập hoặc không có quyền\"}");
            return;
        }

        // Parse JSON body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }

        JsonObject body;
        try {
            body = gson.fromJson(sb.toString(), JsonObject.class);
        } catch (Exception e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"success\":false,\"error\":\"Body JSON không hợp lệ\"}");
            return;
        }

        String tokenId  = body.has("token")       ? body.get("token").getAsString()       : null;
        int    caId     = body.has("caLamViecId")  ? body.get("caLamViecId").getAsInt()    : 0;
        String action   = body.has("action")       ? body.get("action").getAsString()      : "checkin";
        JsonArray descArr = body.has("descriptor") ? body.get("descriptor").getAsJsonArray() : null;
        String snapshot = body.has("snapshot")     ? body.get("snapshot").getAsString()    : null;

        if (tokenId == null || caId == 0 || descArr == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu dữ liệu bắt buộc (token, caLamViecId, descriptor)\"}");
            return;
        }
        if (descArr.size() < 128) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor khuôn mặt không hợp lệ\"}");
            return;
        }

        // --- Validate token ---
        FaceChallengeToken token = tokenDAO.findById(tokenId);
        if (token == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không tồn tại\"}");
            return;
        }
        if (token.isExpired()) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token đã hết hạn. Vui lòng thử lại.\"}");
            return;
        }
        if (token.isUsed()) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token đã được sử dụng\"}");
            return;
        }
        if (token.getAccountId() != user.getAccountId()) {
            resp.setStatus(403);
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không thuộc về tài khoản này\"}");
            return;
        }
        if (token.getCaLamViecId() != caId) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không khớp ca làm việc\"}");
            return;
        }

        // --- Ca phải thuộc về người đang đăng nhập; vào ca phải đúng khung giờ ---
        CaLamViec ca = caLamViecDAO.getCaById(caId);
        if (ca == null || ca.getAccountId() != user.getAccountId() || ca.isDeleted()) {
            resp.setStatus(403);
            resp.getWriter().write("{\"success\":false,\"error\":\"Ca làm việc không hợp lệ\"}");
            return;
        }
        if (!"checkout".equals(action)) {
            String windowError = AttendanceWindow.validateCheckIn(ca);
            if (windowError != null) {
                resp.getWriter().write("{\"success\":false,\"error\":" + gson.toJson(windowError) + "}");
                return;
            }
        }

        // --- Load stored face descriptor ---
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        if (faceData == null || faceData.getFaceDescriptor() == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Bạn chưa đăng ký khuôn mặt. Liên hệ quản lý.\"}");
            return;
        }

        // Nhiều mẫu: lấy khoảng cách tới mẫu gần nhất. parse() nhận cả định dạng cũ một mẫu.
        double[][] storedSamples = FaceDescriptorMatcher.parse(faceData.getFaceDescriptor());
        if (storedSamples.length == 0) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Dữ liệu khuôn mặt đã lưu bị lỗi. Liên hệ quản lý đăng ký lại.\"}");
            return;
        }

        double[] incomingDesc = new double[128];
        for (int i = 0; i < Math.min(128, descArr.size()); i++) {
            incomingDesc[i] = descArr.get(i).getAsDouble();
        }

        double distance = FaceDescriptorMatcher.minDistance(storedSamples, incomingDesc);

        // Lấy threshold của chi nhánh (nếu có), fallback về default
        double threshold = MATCH_THRESHOLD;
        if (user.getCoSoId() != null) {
            try {
                CoSoFaceConfig cfg = configDAO.findByCoSo(user.getCoSoId());
                if (cfg != null) threshold = cfg.getConfidenceMin();
            } catch (Exception ignored) { /* dùng default */ }
        }

        double confidence = Math.max(0, Math.min(100, (1 - distance / MAX_DISTANCE) * 100));

        if (distance > threshold) {
            resp.getWriter().write(String.format(
                "{\"success\":false,\"error\":\"Khuôn mặt không khớp (%.1f%%). Vui lòng thử lại.\",\"confidence\":%.1f}",
                confidence, confidence));
            return;
        }

        // --- Mark token used (chống replay) ---
        tokenDAO.markUsed(tokenId);

        // --- Lưu snapshot ---
        String imagePath = saveSnapshot(snapshot, user.getAccountId(), caId, action);

        // --- Ghi vào DB ---
        boolean ok;
        if ("checkout".equals(action)) {
            ok = caLamViecDAO.faceCheckOut(caId, imagePath, confidence);
        } else {
            // Luồng một chạm không còn challenge tư thế; hậu kiểm dựa vào ảnh snapshot.
            ok = caLamViecDAO.faceCheckIn(caId, imagePath, confidence, false);
        }

        if (!ok) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Không thể cập nhật ca làm việc. Ca có thể đã được điểm danh.\"}");
            return;
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("confidence", Math.round(confidence * 10.0) / 10.0);
        result.put("action", action);
        resp.getWriter().write(gson.toJson(result));
    }

    // --- Helpers ---

    private String saveSnapshot(String base64DataUrl, int accountId, int caId, String action) {
        if (base64DataUrl == null || !base64DataUrl.startsWith("data:image")) return null;
        try {
            String base64 = base64DataUrl.substring(base64DataUrl.indexOf(',') + 1);
            byte[] bytes = Base64.getDecoder().decode(base64);

            String dir = getServletContext().getRealPath("/uploads/face-checkin");
            if (dir == null) {
                dir = new File(System.getProperty("user.home"), "v-sport/uploads/face-checkin").getAbsolutePath();
            }
            new File(dir).mkdirs();

            String filename = accountId + "_ca" + caId + "_" + action + "_" + System.currentTimeMillis() + ".jpg";
            Files.write(Paths.get(dir, filename), bytes);
            return "/uploads/face-checkin/" + filename;
        } catch (Exception e) {
            return null;
        }
    }

    private TaiKhoan getSessionUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        int role = user.getRoleId();
        if (role != Constants.ROLE_BAO_VE && role != Constants.ROLE_LE_TAN) return null;
        return user;
    }
}
