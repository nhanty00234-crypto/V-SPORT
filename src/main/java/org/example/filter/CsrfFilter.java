package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

/**
 * CSRF protection cho tất cả POST endpoints của customer/manager/admin/staff.
 * Dùng Synchronizer Token Pattern: token sinh ra lần đầu khi session tồn tại,
 * lưu trong session, validate trên mọi POST.
 * AJAX dùng header X-CSRF-Token, form dùng hidden field _csrf.
 */
@WebFilter(urlPatterns = {"/customer/*", "/manager/*", "/admin/*", "/staff/*"})
public class CsrfFilter implements Filter {

    // PayOS webhook callback gọi từ server bên ngoài — không có session/token
    private static final Set<String> CSRF_EXEMPT = Set.of(
        "/customer/payos-return",
        "/customer/payos-cancel"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Sinh token nếu session đang tồn tại nhưng chưa có token
        if (session != null && session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
        }

        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String contextPath = req.getContextPath();
            String uri = req.getRequestURI().substring(contextPath.length());
            int qIdx = uri.indexOf('?');
            if (qIdx > 0) uri = uri.substring(0, qIdx);

            if (!CSRF_EXEMPT.contains(uri)) {
                if (!isValidCsrf(req)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token không hợp lệ.");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isValidCsrf(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute("csrfToken");
        if (sessionToken == null) return false;

        // Form POST: hidden field _csrf
        String formToken = req.getParameter("_csrf");
        if (sessionToken.equals(formToken)) return true;

        // AJAX: header X-CSRF-Token
        String headerToken = req.getHeader("X-CSRF-Token");
        return sessionToken.equals(headerToken);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
