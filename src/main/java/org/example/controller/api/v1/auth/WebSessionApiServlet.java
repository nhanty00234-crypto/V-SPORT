package org.example.controller.api.v1.auth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.util.Map;

@WebServlet("/api/v1/auth/me")
public class WebSessionApiServlet extends HttpServlet {

    private static final Map<Integer, String> ROLE_NAMES = Map.of(
        1, "ADMIN",
        2, "MANAGER",
        3, "CUSTOMER",
        4, "STAFF"
    );

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        addCors(req, resp);

        HttpSession session = req.getSession(false);
        TaiKhoan tk = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (tk == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String roleName = ROLE_NAMES.getOrDefault(tk.getRoleId(), "CUSTOMER");
        String avatarJson = tk.getAvatarUrl() != null
            ? "\"" + escape(tk.getAvatarUrl()) + "\""
            : "null";

        resp.getWriter().write(String.format(
            "{\"id\":%d,\"email\":\"%s\",\"phone\":\"%s\",\"fullName\":\"%s\",\"role\":\"%s\",\"avatarUrl\":%s}",
            tk.getAccountId(),
            escape(tk.getEmail()),
            escape(tk.getPhoneNumber() != null ? tk.getPhoneNumber() : ""),
            escape(tk.getFullName() != null ? tk.getFullName() : ""),
            roleName,
            avatarJson
        ));
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        addCors(req, resp);
        resp.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type, Accept");
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private void addCors(HttpServletRequest req, HttpServletResponse resp) {
        String origin = req.getHeader("Origin");
        if (origin == null) return;
        String lower = origin.toLowerCase();
        if (lower.startsWith("http://localhost:") || lower.startsWith("http://127.0.0.1:")) {
            resp.setHeader("Access-Control-Allow-Origin", origin);
            resp.setHeader("Access-Control-Allow-Credentials", "true");
            resp.setHeader("Vary", "Origin");
        }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
