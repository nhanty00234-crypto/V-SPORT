package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.reset.SimpleRateLimiter;

import java.io.IOException;
import java.util.Set;

/**
 * Rate limiting cho booking và cancel endpoints.
 * Giới hạn: 5 request/phút per IP và 5 request/phút per account.
 * Tái dùng SimpleRateLimiter.SHARED (đã có trong project).
 */
@WebFilter(urlPatterns = {"/customer/dat-san", "/customer/dat_san",
                           "/customer/huy-dat-san", "/customer/refund-cancel"})
public class BookingRateLimitFilter implements Filter {

    private static final int MAX_PER_MINUTE = 5;
    private static final long WINDOW_MS = 60_000L;

    private static final Set<String> RATE_LIMITED_PATHS = Set.of(
        "/customer/dat-san", "/customer/dat_san",
        "/customer/huy-dat-san", "/customer/refund-cancel"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Chỉ giới hạn POST
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI().substring(contextPath.length());
        int qIdx = uri.indexOf('?');
        if (qIdx > 0) uri = uri.substring(0, qIdx);

        if (!RATE_LIMITED_PATHS.contains(uri)) {
            chain.doFilter(request, response);
            return;
        }

        long now = System.currentTimeMillis();
        String ip = getClientIp(req);

        // Rate limit per IP
        String ipKey = "booking-ip:" + ip;
        if (!SimpleRateLimiter.SHARED.tryAcquire(ipKey, MAX_PER_MINUTE, WINDOW_MS, now)) {
            sendRateLimitResponse(resp, req);
            return;
        }

        // Rate limit per account (nếu đã đăng nhập)
        HttpSession session = req.getSession(false);
        if (session != null) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            if (user != null) {
                String accountKey = "booking-acc:" + user.getAccountId();
                if (!SimpleRateLimiter.SHARED.tryAcquire(accountKey, MAX_PER_MINUTE, WINDOW_MS, now)) {
                    sendRateLimitResponse(resp, req);
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private void sendRateLimitResponse(HttpServletResponse resp, HttpServletRequest req)
            throws IOException {
        resp.setStatus(429);
        String accept = req.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Bạn thao tác quá nhanh. Vui lòng thử lại sau 1 phút.\"}");
        } else {
            resp.setContentType("text/html;charset=UTF-8");
            resp.getWriter().write("<h3 style='font-family:sans-serif;padding:40px'>Bạn thao tác quá nhanh. Vui lòng thử lại sau 1 phút.</h3>");
        }
    }

    private String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            return ip.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
