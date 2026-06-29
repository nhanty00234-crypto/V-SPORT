package org.example.util;


import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Centralized validation utilities cho toàn hệ thống
 * Tất cả validation logic nên đặt ở đây, tránh lặp code
 */
public final class ValidationUtils {

    // Regex patterns
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );
    private static final Pattern VIETNAM_PHONE_PATTERN = Pattern.compile(
        "^[0-9]{10,15}$"
    );
    private static final Pattern USERNAME_PATTERN = Pattern.compile(
        "^[A-Za-z0-9_]{3,50}$"
    );
    private static final Pattern PASSWORD_STRONG_PATTERN = Pattern.compile(
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$"
    );

    private ValidationUtils() {
        // Private constructor
    }

    // ========== EMAIL VALIDATION ==========
    public static void validateEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống");
        }
        String trimmed = email.trim();
        if (trimmed.contains(" ") || trimmed.contains("\t")) {
            throw new IllegalArgumentException("Email không được chứa khoảng trắng");
        }
        if (!EMAIL_PATTERN.matcher(trimmed).matches()) {
            throw new IllegalArgumentException("Định dạng email không hợp lệ");
        }
    }

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        if (trimmed.isEmpty() || trimmed.contains(" ") || trimmed.contains("\t")) {
            return false;
        }
        return EMAIL_PATTERN.matcher(trimmed).matches();
    }

    // ========== PHONE VALIDATION ==========
    public static void validateVietnamPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại không được để trống");
        }
        String cleaned = phone.trim().replaceAll("[^0-9]", "");
        if (!VIETNAM_PHONE_PATTERN.matcher(cleaned).matches()) {
            throw new IllegalArgumentException("Số điện thoại không hợp lệ (10-15 chữ số)");
        }
    }

    public static boolean isValidVNPhone(String phone) {
        if (phone == null) return false;
        String cleaned = phone.trim().replaceAll("[^0-9]", "");
        return VIETNAM_PHONE_PATTERN.matcher(cleaned).matches();
    }

    // ========== USERNAME VALIDATION ==========
    public static void validateUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không được để trống");
        }
        String trimmed = username.trim();
        if (trimmed.contains(" ") || trimmed.contains("\t")) {
            throw new IllegalArgumentException("Tên đăng nhập không được chứa khoảng trắng");
        }
        if (!USERNAME_PATTERN.matcher(trimmed).matches()) {
            throw new IllegalArgumentException(
                "Tên đăng nhập chỉ chứa chữ cái, số, dấu gạch dưới (3-50 ký tự)");
        }
    }

    public static boolean isValidUsername(String username) {
        if (username == null) return false;
        return USERNAME_PATTERN.matcher(username.trim()).matches();
    }

    // ========== PASSWORD VALIDATION ==========
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

        if (!PASSWORD_STRONG_PATTERN.matcher(password).matches()) {
            throw new IllegalArgumentException(
                "Mật khẩu phải chứa: chữ hoa, chữ thường, số và ký tự đặc biệt");
        }
    }

    public static boolean isStrongPassword(String password) {
        if (password == null || password.isEmpty()) return false;
        return PASSWORD_STRONG_PATTERN.matcher(password).matches();
    }

    // ========== DATE VALIDATION ==========
    public static void validatePastOrPresentDate(LocalDate date, String fieldName) {
        if (date == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (date.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(fieldName + " không được ở tương lai");
        }
    }

    public static void validateNotPastDate(LocalDate date, String fieldName) {
        if (date == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (date.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException(fieldName + " không được ở quá khứ");
        }
    }

    // ========== TIME VALIDATION ==========
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

    // ========== NUMBER VALIDATION ==========
    public static void validatePositiveNumber(Number number, String fieldName) {
        if (number == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (number.doubleValue() < 0) {
            throw new IllegalArgumentException(fieldName + " phải lớn hơn hoặc bằng 0");
        }
    }

    public static void validateMinValue(Number number, String fieldName, double minValue) {
        if (number == null) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
        if (number.doubleValue() < minValue) {
            throw new IllegalArgumentException(fieldName + " phải lớn hơn hoặc bằng " + minValue);
        }
    }

    // ========== STRING VALIDATION ==========
    public static void validateRequiredString(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(fieldName + " không được để trống");
        }
    }

    public static void validateMaxLength(String value, String fieldName, int maxLength) {
        if (value != null && value.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " tối đa " + maxLength + " ký tự");
        }
    }

    // ========== DATE PARSING ==========
    public static Date parseDate(String dateStr, String format) {
        try {
            LocalDate localDate = LocalDate.parse(dateStr, DateTimeFormatter.ofPattern(format));
            return Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng ngày không hợp lệ, mong đợi: " + format);
        }
    }

    public static LocalTime parseTime(String timeStr) {
        try {
            return LocalTime.parse(timeStr);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng giờ không hợp lệ, mong đợi: HH:mm");
        }
    }

    // ========== COMBINED VALIDATIONS ==========
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
            validateRequiredString(fullName, "fullName");
        } catch (IllegalArgumentException e) {
            errors.put("fullName", e.getMessage());
        }

        // Role check
        if (roleId == 1 || roleId == 2) {
            errors.put("role", "Không thể tạo tài khoản có quyền Quản trị hoặc Quản lý");
        }

        return errors;
    }

    // ========== RANGE CHECK ==========
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
}
