package org.example.controller.face;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
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
import org.example.util.Constants;
import org.example.util.FaceDescriptorMatcher;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet("/face/challenge")
public class FaceChallengeServlet extends HttpServlet {

    private static final int TTL_SECONDS = 180;
    /** Khoảng cách Euclidean coi như hoàn toàn khác người — dùng để quy đổi ra % khớp. */
    private static final double MAX_DISTANCE = 0.8;

    private final FaceChallengeTokenDAO tokenDAO = new FaceChallengeTokenDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final CoSoFaceConfigDAO faceConfigDAO = new CoSoFaceConfigDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        TaiKhoan user = getUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String caIdStr = req.getParameter("caLamViecId");
        String action = req.getParameter("action");
        if (caIdStr == null || action == null) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu caLamViecId hoặc action\"}");
            return;
        }

        int caId;
        try { caId = Integer.parseInt(caIdStr); } catch (NumberFormatException e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"caLamViecId không hợp lệ\"}");
            return;
        }

        // Fix 3: shift ownership validation (IDOR guard)
        CaLamViec ca = caLamViecDAO.getCaById(caId);
        if (ca == null || ca.getAccountId() != user.getAccountId()) {
            resp.setStatus(403);
            resp.getWriter().write("{\"error\":\"Ca làm việc không hợp lệ\"}");
            return;
        }

        // Không còn challenge tư thế: luồng điểm danh chỉ bắt khuôn mặt rồi gửi.
        // Token vẫn được cấp để chống phát lại (replay) ở /face/checkin.
        List<String> chosen = Collections.emptyList();

        FaceChallengeToken token = new FaceChallengeToken();
        token.setTokenId(UUID.randomUUID().toString());
        token.setAccountId(user.getAccountId());
        token.setCaLamViecId(caId);
        token.setAction(action);
        token.setChallenges(gson.toJson(chosen));
        token.setCreatedAt(LocalDateTime.now());
        token.setExpiresAt(LocalDateTime.now().plusSeconds(TTL_SECONDS));

        tokenDAO.insert(token);
        // Xóa token cũ hết hạn (cleanup không quan trọng)
        try { tokenDAO.deleteExpired(); } catch (Exception ignored) {}

        // Descriptor đã đăng ký + ngưỡng của cơ sở: gửi kèm để client hiển thị % khớp
        // theo thời gian thực. Server vẫn tự chấm lại ở /face/checkin nên đây chỉ là UX.
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        double threshold = 0.6;
        if (user.getCoSoId() != null) {
            CoSoFaceConfig cfg = faceConfigDAO.findByCoSo(user.getCoSoId());
            if (cfg != null) threshold = cfg.getConfidenceMin();
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("token", token.getTokenId());
        result.put("challenges", chosen);
        result.put("ttlSeconds", TTL_SECONDS);
        result.put("threshold", threshold);
        result.put("maxDistance", MAX_DISTANCE);
        result.put("requiredPercent", toPercent(threshold));
        if (faceData != null && faceData.getFaceDescriptor() != null) {
            double[][] samples = FaceDescriptorMatcher.parse(faceData.getFaceDescriptor());
            if (samples.length > 0) result.put("descriptors", samples);
        }
        resp.getWriter().write(gson.toJson(result));
    }

    /** Quy đổi khoảng cách Euclidean sang % khớp để hiển thị cho người dùng. */
    private static int toPercent(double distance) {
        double pct = (1.0 - distance / MAX_DISTANCE) * 100.0;
        return (int) Math.round(Math.max(0, Math.min(100, pct)));
    }

    private TaiKhoan getUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        int role = user.getRoleId();
        if (role != Constants.ROLE_BAO_VE && role != Constants.ROLE_LE_TAN && role != Constants.ROLE_MANAGER) return null;
        return user;
    }
}
