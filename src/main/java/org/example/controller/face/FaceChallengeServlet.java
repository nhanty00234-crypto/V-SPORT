package org.example.controller.face;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.FaceChallengeTokenDAO;
import org.example.dao.impl.FaceChallengeTokenDAOImpl;
import org.example.model.FaceChallengeToken;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet("/face/challenge")
public class FaceChallengeServlet extends HttpServlet {

    private static final String[] ALL_CHALLENGES = {"blink", "turn_left", "turn_right", "smile"};
    private static final int TTL_SECONDS = 180;
    private final FaceChallengeTokenDAO tokenDAO = new FaceChallengeTokenDAOImpl();
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

        // Random 2 trong 4 challenges, shuffle thứ tự
        List<String> pool = new ArrayList<>(Arrays.asList(ALL_CHALLENGES));
        Collections.shuffle(pool);
        List<String> chosen = pool.subList(0, 2);

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

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("token", token.getTokenId());
        result.put("challenges", chosen);
        result.put("ttlSeconds", TTL_SECONDS);
        resp.getWriter().write(gson.toJson(result));
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
