package org.example.api;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * CORS chỉ cho REST API mobile. KHÔNG áp lên phần Web JSP (giữ nguyên hành vi cũ).
 *
 * App Flutter native không gửi Origin nên thực tế không cần CORS; filter này phục vụ
 * Flutter Web / công cụ thử API. Vì API dùng Bearer token (không dùng cookie), ta KHÔNG
 * bật Allow-Credentials — nhờ vậy wildcard không tạo ra lỗ hổng CSRF.
 *
 * Danh sách origin được phép đọc từ env/property API_ALLOWED_ORIGINS (phân tách bằng dấu phẩy).
 * Nếu không cấu hình: chỉ echo lại origin localhost/127.0.0.1 (môi trường dev), production
 * bắt buộc khai báo tường minh (mục XV spec — không mở "*" thiếu kiểm soát).
 */
@WebFilter(urlPatterns = {"/api/v1/*"})
public class ApiCorsFilter implements Filter {

    private Set<String> allowedOrigins;

    @Override
    public void init(jakarta.servlet.FilterConfig config) {
        String raw = System.getenv("API_ALLOWED_ORIGINS");
        if (raw == null || raw.isBlank()) raw = System.getProperty("api.allowed.origins");
        allowedOrigins = new HashSet<>();
        if (raw != null && !raw.isBlank()) {
            Arrays.stream(raw.split(",")).map(String::trim).filter(s -> !s.isEmpty())
                    .forEach(allowedOrigins::add);
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String origin = req.getHeader("Origin");
        if (origin != null && isAllowed(origin)) {
            resp.setHeader("Access-Control-Allow-Origin", origin);
            resp.setHeader("Vary", "Origin");
            resp.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type, Accept");
            resp.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS");
            resp.setHeader("Access-Control-Max-Age", "600");
        }

        if ("OPTIONS".equalsIgnoreCase(req.getMethod())) {
            resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }
        chain.doFilter(request, response);
    }

    private boolean isAllowed(String origin) {
        if (allowedOrigins.contains(origin)) return true;
        if (!allowedOrigins.isEmpty()) return false;
        String lower = origin.toLowerCase();
        return lower.startsWith("http://localhost:") || lower.startsWith("http://127.0.0.1:");
    }
}
