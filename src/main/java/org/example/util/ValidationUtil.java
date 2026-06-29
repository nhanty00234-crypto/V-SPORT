package org.example.util;


import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Centralized validation utilities cho toàn hệ thống V-SPORT
 * Provides both boolean validation methods (isValid...) and exception-throwing methods (validate...)
 */
public class ValidationUtil {
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
    private static final String PHONE_VN_REGEX = "^(0|\\+84)[35789][0-9]{8}$";
    private static final String USERNAME_REGEX = "^[A-Za-z0-9_]{3,50}$";
    private static final String PASSWORD_STRONG_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$";

    private ValidationUtil() {
        // Private constructor
    }

    // ==================== BOOLEAN VALIDATION (isValid...) ====================
    /**
     * @deprecated Use isValidEmail(email) directly
     */
    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        if (trimmed.isEmpty() || trimmed.contains(" ") || trimmed.contains("\t")) {
            return false;
        }
        return Pattern.compile(EMAIL_REGEX).matcher(trimmed).matches();
    }

    /**
     * @deprecated Use isValidVietnamPhone(phone) for new code
     */
    public static boolean isValidVNPhone(String phone) {
        if (phone == null) return false;
        String trimmed = phone.trim();
        return Pattern.compile(PHONE_VN_REGEX).matcher(trimmed).matches();
    }

    public static boolean isValidVietnamPhone(String phone) {
        if (phone == null) return false;
        String cleaned = phone.trim().replaceAll("[^0-9]", "");
        return cleaned.matches("^[0-9]{10,15}$");
    }

    public static boolean isValidUsername(String username) {
        if (username == null) return false;
        return Pattern.compile(USERNAME_REGEX).matcher(username.trim()).matches();
    }

    public static boolean isStrongPassword(String password) {
        if (password == null || password.isEmpty()) return false;
        return Pattern.compile(PASSWORD_STRONG_REGEX).matcher(password).matches();
    }

    public static boolean isValidDate(String dateStr, String format) {
        if (dateStr == null || dateStr.isEmpty()) return false;
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format);
            LocalDate.parse(dateStr.trim(), formatter);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    // ==================== EXCEPTION VALIDATION (validate...) ====================
    /**
     * Validate email, throw IllegalArgumentException nếu không hợp lệ
     */
    public static void validateEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống");
        }
        String trimmed = email.trim();
        if (trimmed.contains(" ") || trimmed.contains("\t")) {
            throw new IllegalArgumentException("Email không được chứa khoảng trắng");
        }
        if (!Pattern.compile(EMAIL_REGEX).matcher(trimmed).matches()) {
            throw new IllegalArgumentException("Định dạng email không hợp lệ");
        }
    }

    /**
     * Validate số điện thoại Việt Nam, throw IllegalArgumentException nếu không hợp lệ
     */
    public static void validateVietnamPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại không được để trống");
        }
        String cleaned = phone.trim().replaceAll("[^0-9]", "");
        if (!cleaned.matches("^[0-9]{10,15}$")) {
            throw new IllegalArgumentException("Số điện thoại không hợp lệ (10-15 chữ số)");
        }
    }

    /**
     * Validate username, throw IllegalArgumentException nếu không hợp lệ
     */
    public static void validateUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không được để trống");
        }
        String trimmed = username.trim();
        if (trimmed.contains(" ") || trimmed.contains("\t")) {
            throw new IllegalArgumentException("Tên đăng nhập không được chứa khoảng trắng");
        }
        if (!Pattern.compile(USERNAME_REGEX).matcher(trimmed).matches()) {
            throw new IllegalArgumentException(
                "Tên đăng nhập chỉ chứa chữ cái, số, dấu gạch dưới (3-50 ký tự)");
        }
    }

    /**
     * Validate mật khẩu mạnh, throw IllegalArgumentException nếu không đủ mạnh
     */
    public static void validateStrongPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được để trống");
        }
        if (password.trim().isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được chỉ chứa khoảng trắng");
        }
        if (password.length() < 8) {
            throw new IllegalArgumentException("Mật khẩu phải có ít nhất 8 ký tự");
        }

        if (!Pattern.compile(PASSWORD_STRONG_REGEX).matcher(password).matches()) {
            throw new IllegalArgumentException(
                "Mật khẩu phải chứa: chữ hoa, chữ thường, số và ký tự đặc biệt");
        }
    }

    /**
     * Validate date là quá khứ hoặc hiện tại
     */
    public static void validatePastOrPresentDate(LocalDate date, String fieldName) {
        if (date == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (date.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(fieldName + " không được ở tương lai");
        }
    }

    /**
     * Validate date không được ở quá khứ
     */
    public static void validateNotPastDate(LocalDate date, String fieldName) {
        if (date == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException(fieldName + " không được ở quá khứ");
        }
    }

    /**
     * Validate time range: startTime < endTime
     */
    public static void validateTimeRange(LocalTime startTime, LocalTime endTime) {
        if (startTime == null) {
            throw new IllegalArgumentException("Giờ bắt đầu không được để trống");
        }
        if (endTime == null) {
            throw new IllegalArgumentException("Giờ kết thúc không được để trống");
        }
        if (!startTime.isBefore(endTime)) {
            throw new IllegalArgumentException("Giờ bắt đầu phải trước giờ kết thúc");
        }
    }

    /**
     * Validate số phải >= 0
     */
    public static void validatePositiveNumber(Number number, String fieldName) {
        if (number == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (number.doubleValue() < 0) {
            throw new IllegalArgumentException(fieldName + " phải lớn hơn hoặc bằng 0");
        }
    }

    /**
     * Validate string không được để trống
     */
    public static void validateRequiredString(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
    }

    /**
     * Validate string length tối đa
     */
    public static void validateMaxLength(String value, String fieldName, int maxLength) {
        if (value != null && value.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " tối đa " + maxLength + " ký tự");
        }
    }

    /**
     * Validate value nằm trong range [min, max]
     */
    public static void validateInRange(int value, String fieldName, int min, int max) {
        if (value < min || value > max) {
            throw new IllegalArgumentException(
                String.format("%s phải từ %d đến %d", fieldName, min, max));
        }
    }

    public static void validateInRange(double value, String fieldName, double min, double max) {
        if (value < min || value > max) {
            throw new IllegalArgumentException(
                String.format("%s phải từ %.2f đến %.2f", fieldName, min, max));
        }
    }

    // ==================== PARSING ====================
    /**
     * Parse date string với format, throw IllegalArgumentException nếu fail
     */
    public static LocalDate parseDate(String dateStr, String format) {
        try {
            return LocalDate.parse(dateStr, DateTimeFormatter.ofPattern(format));
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng ngày không hợp lệ, mong đợi: " + format);
        }
    }

    /**
     * Parse time string (HH:mm), throw IllegalArgumentException nếu fail
     */
    public static LocalTime parseTime(String timeStr) {
        try {
            return LocalTime.parse(timeStr);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng giờ không hợp lệ, mong đợi: HH:mm");
        }
    }

    /**
     * Parse date cũ (legacy), trả về java.util.Date
     */
    public static java.util.Date parseDateLegacy(String dateStr, String format) {
        if (dateStr == null || dateStr.isEmpty()) return null;
        try {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(format);
            return sdf.parse(dateStr);
        } catch (Exception e) {
            return null;
        }
    }

    // ==================== COMBINED VALIDATIONS ====================
    /**
     * Validate tất cả fields cho việc tạo staff mới
     * @return Map của errors, empty nếu không có lỗi
     */
    public static Map<String, String> validateStaffCreate(
        String username, String email, String phone, String fullName, int roleId
    ) {
        Map<String, String> errors = new HashMap<>();

        try {
            validateUsername(username);
        } catch (IllegalArgumentException e) {
            errors.put("username", e.getMessage());
        }

        try {
            validateEmail(email);
        } catch (IllegalArgumentException e) {
            errors.put("email", e.getMessage());
        }

        if (phone != null && !phone.trim().isEmpty()) {
            try {
                validateVietnamPhone(phone);
            } catch (IllegalArgumentException e) {
                errors.put("phone", e.getMessage());
            }
        }

        try {
            validateRequiredString(fullName, "Họ và tên");
        } catch (IllegalArgumentException e) {
            errors.put("fullName", e.getMessage());
        }

        // Role check
        if (roleId == 1 || roleId == 2) {
            errors.put("role", "Không thể tạo tài khoản có quyền Quản trị hoặc Quản lý");
        }

        return errors;
    }
}
