package org.example.controller.api.v1.auth;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.api.ApiErrorCode;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.model.TaiKhoan;
import org.example.security.JwtService;
import org.example.service.FacilityAccessService;
import org.example.service.reset.SimpleRateLimiter;
import org.example.util.Constants;
import org.example.util.PhoneUtil;

import java.io.IOException;
import java.util.List;

/**
 * POST /api/v1/auth/login   — đăng nhập bằng email/username hoặc số điện thoại + mật khẩu
 * POST /api/v1/auth/refresh — đổi refresh token lấy cặp token mới
 * POST /api/v1/auth/logout  — no-op phía server (token stateless); app tự xoá secure storage
 *
 * Xác thực mật khẩu tái sử dụng đúng pipeline BCrypt của Web
 * ({@link TaiKhoanDAO#dangNhapKhachHang}) — không có bảng người dùng riêng cho mobile,
 * không có thuật toán băm thứ hai.
 *
 * Chỉ role CUSTOMER được cấp token cho app này (mục VIII spec).
 */
@WebServlet("/api/v1/auth/*")
public class AuthApiServlet extends BaseApiServlet {

    private static final Logger logger = LogManager.getLogger(AuthApiServlet.class);

    /** Thông báo chung cho mọi trường hợp thất bại — chống dò tài khoản (giống Web). */
    private static final String GENERIC_LOGIN_FAIL = "Email, số điện thoại hoặc mật khẩu không chính xác.";
    private static final String DUMMY_BCRYPT_HASH =
            "$2a$10$e8vvlxZLrBB2hA2WySDYK.ILi34msUoVA8ngsFmy/8gfSI.T4majO";

    private static final int LOGIN_ID_MAX_ATTEMPTS = 5;
    private static final int LOGIN_IP_MAX_ATTEMPTS = 20;
    private static final long LOGIN_RATE_WINDOW_MS = 5 * 60_000L;

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final FacilityAccessService facilityAccessService = new FacilityAccessService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            String[] seg = pathSegments(req);
            String action = seg.length > 0 ? seg[0] : "";
            switch (action) {
                case "login" -> login(req, resp);
                case "refresh" -> refresh(req, resp);
                case "logout" -> ok(resp, "Đã đăng xuất.", null);
                default -> throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    private void login(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        ApiDtos.LoginRequest body = readBody(req, ApiDtos.LoginRequest.class);
        String password = body.password;
        boolean byPhone = body.phone != null && !body.phone.isBlank();
        String identifier = byPhone ? body.phone.trim() : (body.email != null ? body.email.trim() : null);

        if (identifier == null || identifier.isEmpty() || password == null || password.isEmpty()) {
            throw badRequest("Vui lòng nhập đầy đủ tài khoản và mật khẩu.");
        }

        String normalizedPhone = byPhone ? PhoneUtil.normalizeVN(identifier) : null;
        if (byPhone && normalizedPhone == null) {
            throw badRequest("Số điện thoại không hợp lệ. Vui lòng nhập số di động Việt Nam.");
        }

        // Rate limit theo identifier + IP, áp dụng TRƯỚC khi truy vấn DB (giống Web).
        long now = System.currentTimeMillis();
        String idKey = "api-login-id:" + (byPhone ? normalizedPhone : identifier.toLowerCase());
        String ipKey = "api-login-ip:" + req.getRemoteAddr();
        if (!SimpleRateLimiter.SHARED.tryAcquire(idKey, LOGIN_ID_MAX_ATTEMPTS, LOGIN_RATE_WINDOW_MS, now)
                || !SimpleRateLimiter.SHARED.tryAcquire(ipKey, LOGIN_IP_MAX_ATTEMPTS, LOGIN_RATE_WINDOW_MS, now)) {
            logger.warn("API_LOGIN_RATE_LIMITED ip={}", req.getRemoteAddr());
            throw new ApiException(HttpServletResponse.SC_UNAUTHORIZED,
                    ApiErrorCode.INVALID_CREDENTIALS, GENERIC_LOGIN_FAIL);
        }

        TaiKhoan account = null;
        if (byPhone) {
            List<TaiKhoan> matches = taiKhoanDAO.timTaiKhoanHoatDongTheoPhone(
                    PhoneUtil.lookupVariants(normalizedPhone));
            if (matches.size() == 1) {
                if (org.mindrot.jbcrypt.BCrypt.checkpw(password, matches.get(0).getPassword())) {
                    account = matches.get(0);
                }
            } else {
                // 0 hoặc nhiều hơn 1 kết quả: vẫn chạy một lần BCrypt giả để giữ thời gian phản hồi
                // tương đồng (chống timing attack dò số điện thoại tồn tại).
                org.mindrot.jbcrypt.BCrypt.checkpw(password, DUMMY_BCRYPT_HASH);
            }
        } else {
            account = taiKhoanDAO.dangNhapKhachHang(identifier, password);
        }

        if (account == null) {
            logger.warn("API_LOGIN_FAILED ip={}", req.getRemoteAddr());
            throw new ApiException(HttpServletResponse.SC_UNAUTHORIZED,
                    ApiErrorCode.INVALID_CREDENTIALS, GENERIC_LOGIN_FAIL);
        }
        if (account.getRoleId() != Constants.ROLE_KHACH_HANG) {
            logger.warn("API_LOGIN_NON_CUSTOMER accountId={} roleId={}", account.getAccountId(), account.getRoleId());
            throw new ApiException(HttpServletResponse.SC_FORBIDDEN, ApiErrorCode.NOT_CUSTOMER,
                    "Ứng dụng này chỉ dành cho tài khoản khách hàng. Vui lòng dùng bản web cho tài khoản nội bộ.");
        }
        if (account.isLocked()) {
            throw new ApiException(HttpServletResponse.SC_FORBIDDEN, ApiErrorCode.ACCOUNT_LOCKED,
                    "Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.");
        }
        if (account.getCoSoId() != null && !facilityAccessService.isFacilityActive(account.getCoSoId())) {
            throw new ApiException(HttpServletResponse.SC_FORBIDDEN, ApiErrorCode.FORBIDDEN,
                    "Cơ sở của tài khoản này đã ngừng hoạt động.");
        }

        loadPreferredSportId(account);
        logger.info("API_LOGIN_SUCCESS accountId={} ip={}", account.getAccountId(), req.getRemoteAddr());
        ok(resp, "Đăng nhập thành công.", buildAuthResponse(req, account));
    }

    private void refresh(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        ApiDtos.RefreshRequest body = readBody(req, ApiDtos.RefreshRequest.class);
        if (body.refreshToken == null || body.refreshToken.isBlank()) {
            throw badRequest("Thiếu refreshToken.");
        }
        JwtService.Claims claims = JwtService.verify(body.refreshToken);
        if (!JwtService.TYPE_REFRESH.equals(claims.type)) {
            throw new ApiException(HttpServletResponse.SC_UNAUTHORIZED, ApiErrorCode.INVALID_TOKEN,
                    "Token không phải refresh token.");
        }
        TaiKhoan account = taiKhoanDAO.getAccountById(claims.accountId);
        if (account == null || Boolean.TRUE.equals(account.isDeleted()) || account.isLocked()
                || account.getRoleId() != Constants.ROLE_KHACH_HANG) {
            throw new ApiException(HttpServletResponse.SC_UNAUTHORIZED, ApiErrorCode.UNAUTHORIZED,
                    "Tài khoản không còn hợp lệ. Vui lòng đăng nhập lại.");
        }
        loadPreferredSportId(account);
        ok(resp, "Làm mới token thành công.", buildAuthResponse(req, account));
    }

    private ApiDtos.AuthResponse buildAuthResponse(HttpServletRequest req, TaiKhoan account) {
        ApiDtos.AuthResponse res = new ApiDtos.AuthResponse();
        res.accessToken = JwtService.issueAccessToken(account.getAccountId(), account.getRoleId());
        res.refreshToken = JwtService.issueRefreshToken(account.getAccountId(), account.getRoleId());
        res.expiresIn = JwtService.ACCESS_TTL_SECONDS;
        res.customer = ApiMappers.customer(req, account);
        return res;
    }

    /** Nạp môn thể thao yêu thích như DangNhapServlet làm khi đăng nhập Web (không critical). */
    private void loadPreferredSportId(TaiKhoan user) {
        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT TOP 1 MonTheThaoID FROM MonTheThaoYeuThich WHERE AccountID = ?")) {
            ps.setInt(1, user.getAccountId());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) user.setMonTheThaoYeuThichId(rs.getInt("MonTheThaoID"));
            }
        } catch (Exception e) {
            logger.warn("loadPreferredSportId accountId={}: {}", user.getAccountId(), e.getMessage());
        }
    }
}
