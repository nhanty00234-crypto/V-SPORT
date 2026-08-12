package org.example.api;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.security.JwtService;
import org.example.util.Constants;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Lớp nền cho mọi servlet REST /api/v1/*.
 *
 * Trách nhiệm: đọc/ghi JSON, chuẩn hóa mã lỗi + HTTP status, và xác thực Bearer token
 * thành {@link TaiKhoan} thật lấy từ database. KHÔNG chứa business logic — mọi nghiệp vụ
 * phải nằm ở tầng Service dùng chung với Web (xem service/booking, service/payos, ...).
 *
 * Không bao giờ tin AccountID do client gửi lên: account luôn được suy ra từ token.
 */
public abstract class BaseApiServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(BaseApiServlet.class);

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    /** Ném ra khi request không hợp lệ về mặt xác thực/nghiệp vụ; handler bắt và trả JSON chuẩn. */
    public static class ApiException extends RuntimeException {
        public final int status;
        public final String errorCode;

        public ApiException(int status, String errorCode, String message) {
            super(message);
            this.status = status;
            this.errorCode = errorCode;
        }
    }

    protected static ApiException badRequest(String msg) {
        return new ApiException(HttpServletResponse.SC_BAD_REQUEST, ApiErrorCode.VALIDATION_ERROR, msg);
    }

    protected static ApiException notFound(String msg) {
        return new ApiException(HttpServletResponse.SC_NOT_FOUND, ApiErrorCode.NOT_FOUND, msg);
    }

    protected static ApiException forbidden(String msg) {
        return new ApiException(HttpServletResponse.SC_FORBIDDEN, ApiErrorCode.FORBIDDEN, msg);
    }

    protected static ApiException conflict(String errorCode, String msg) {
        return new ApiException(HttpServletResponse.SC_CONFLICT, errorCode, msg);
    }

    // ------------------------------------------------------------------
    // Ghi response
    // ------------------------------------------------------------------

    protected void writeJson(HttpServletResponse resp, int status, Object body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(ApiJson.toJson(body));
    }

    protected void ok(HttpServletResponse resp, Object data) throws IOException {
        writeJson(resp, HttpServletResponse.SC_OK, ApiResponse.ok(data));
    }

    protected void ok(HttpServletResponse resp, String message, Object data) throws IOException {
        writeJson(resp, HttpServletResponse.SC_OK, ApiResponse.ok(message, data));
    }

    protected void created(HttpServletResponse resp, String message, Object data) throws IOException {
        writeJson(resp, HttpServletResponse.SC_CREATED, ApiResponse.ok(message, data));
    }

    protected void fail(HttpServletResponse resp, int status, String errorCode, String message) throws IOException {
        writeJson(resp, status, ApiResponse.error(errorCode, message));
    }

    /**
     * Bọc toàn bộ handler: ApiException -> JSON lỗi tương ứng, exception khác -> 500 kèm log.
     * Không bao giờ để Tomcat render trang HTML lỗi cho client mobile.
     */
    protected void handle(HttpServletRequest req, HttpServletResponse resp, ApiHandler handler) throws IOException {
        try {
            req.setCharacterEncoding("UTF-8");
            handler.run();
        } catch (ApiException e) {
            fail(resp, e.status, e.errorCode, e.getMessage());
        } catch (JwtService.JwtException e) {
            fail(resp, HttpServletResponse.SC_UNAUTHORIZED,
                    e.expired ? ApiErrorCode.TOKEN_EXPIRED : ApiErrorCode.INVALID_TOKEN, e.getMessage());
        } catch (Exception e) {
            logger.error("API_ERROR {} {}: {}", req.getMethod(), req.getRequestURI(), e.getMessage(), e);
            fail(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ApiErrorCode.INTERNAL_ERROR,
                    "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        }
    }

    @FunctionalInterface
    protected interface ApiHandler {
        void run() throws Exception;
    }

    // ------------------------------------------------------------------
    // Xác thực
    // ------------------------------------------------------------------

    // TODO: Bảo mật đã tắt tạm thời cho môi trường phát triển.
    // Bật lại khi tích hợp xác thực: khôi phục requireCustomer() gốc từ git history.

    /** Trả null khi không có token (bảo mật tắt). Khi có token hợp lệ, trả TaiKhoan tương ứng. */
    protected TaiKhoan requireCustomer(HttpServletRequest req) {
        return optionalCustomer(req);
    }

    /** Token tùy chọn: trả null nếu không có hoặc không hợp lệ. */
    protected TaiKhoan optionalCustomer(HttpServletRequest req) {
        String header = req.getHeader("Authorization");
        if (header == null || header.isBlank()) return null;
        if (!header.regionMatches(true, 0, "Bearer ", 0, 7)) return null;
        try {
            JwtService.Claims claims = JwtService.verify(header.substring(7).trim());
            if (!JwtService.TYPE_ACCESS.equals(claims.type)) return null;
            TaiKhoan account = taiKhoanDAO.getAccountById(claims.accountId);
            if (account == null || Boolean.TRUE.equals(account.isDeleted()) || account.isLocked()) return null;
            return account;
        } catch (RuntimeException e) {
            return null;
        }
    }

    // ------------------------------------------------------------------
    // Đọc request
    // ------------------------------------------------------------------

    /** Body JSON -> object. Ném 400 nếu body rỗng hoặc sai định dạng. */
    protected <T> T readBody(HttpServletRequest req, Class<T> type) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new java.io.InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        if (sb.length() == 0) {
            throw badRequest("Thiếu dữ liệu trong request body.");
        }
        T parsed;
        try {
            parsed = ApiJson.fromJson(sb.toString(), type);
        } catch (RuntimeException e) {
            throw badRequest("Dữ liệu JSON không hợp lệ.");
        }
        if (parsed == null) throw badRequest("Dữ liệu JSON không hợp lệ.");
        return parsed;
    }

    /** Các segment của pathInfo, VD "/12/courts" -> ["12", "courts"]. Không bao giờ null. */
    protected String[] pathSegments(HttpServletRequest req) {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) return new String[0];
        String trimmed = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
        if (trimmed.endsWith("/")) trimmed = trimmed.substring(0, trimmed.length() - 1);
        if (trimmed.isEmpty()) return new String[0];
        return trimmed.split("/");
    }

    protected int requireInt(String raw, String fieldName) {
        try {
            return Integer.parseInt(raw.trim());
        } catch (RuntimeException e) {
            throw badRequest(fieldName + " không hợp lệ.");
        }
    }

    protected Integer optionalInt(HttpServletRequest req, String param) {
        String raw = req.getParameter(param);
        if (raw == null || raw.isBlank()) return null;
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            throw badRequest("Tham số " + param + " không hợp lệ.");
        }
    }

    protected Double optionalDouble(HttpServletRequest req, String param) {
        String raw = req.getParameter(param);
        if (raw == null || raw.isBlank()) return null;
        try {
            return Double.parseDouble(raw.trim());
        } catch (NumberFormatException e) {
            throw badRequest("Tham số " + param + " không hợp lệ.");
        }
    }

    /** page >= 1 (mặc định 1). */
    protected int pageParam(HttpServletRequest req) {
        Integer p = optionalInt(req, "page");
        return (p == null || p < 1) ? 1 : p;
    }

    /** size trong [1, Constants.MAX_PAGE_SIZE] (mặc định 20). */
    protected int sizeParam(HttpServletRequest req) {
        Integer s = optionalInt(req, "size");
        if (s == null || s < 1) return Constants.DEFAULT_PAGE_SIZE;
        return Math.min(s, Constants.MAX_PAGE_SIZE);
    }

    protected void methodNotAllowed(HttpServletResponse resp) throws IOException {
        fail(resp, HttpServletResponse.SC_METHOD_NOT_ALLOWED, ApiErrorCode.VALIDATION_ERROR,
                "Phương thức không được hỗ trợ cho đường dẫn này.");
    }
}
