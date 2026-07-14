package org.example.util;

import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Helper lấy AccountID của người dùng đang đăng nhập từ session một cách an
 * toàn, chấp nhận vài kiểu lưu trữ khác nhau (Integer, Number, String) để
 * không phụ thuộc vào việc attribute "accountId" được set kiểu gì.
 */
public final class SessionUtil {

    private static final Logger logger = LogManager.getLogger(SessionUtil.class);

    private SessionUtil() {}

    public static Integer getCurrentAccountId(HttpSession session) {
        if (session == null) return null;
        Object raw = session.getAttribute("accountId");
        if (raw == null) {
            Object user = session.getAttribute("user");
            if (user instanceof org.example.model.TaiKhoan) {
                return ((org.example.model.TaiKhoan) user).getAccountId();
            }
            logger.warn("Không xác định được AccountID của Admin trong session.");
            return null;
        }
        if (raw instanceof Integer) return (Integer) raw;
        if (raw instanceof Number) return ((Number) raw).intValue();
        if (raw instanceof String) {
            try {
                return Integer.valueOf((String) raw);
            } catch (NumberFormatException e) {
                logger.warn("Không xác định được AccountID của Admin trong session.");
                return null;
            }
        }
        logger.warn("Không xác định được AccountID của Admin trong session.");
        return null;
    }
}
