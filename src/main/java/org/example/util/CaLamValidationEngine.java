package org.example.util;

import org.example.dao.CaLamViecDAO;
import org.example.dao.YeuCauNghiDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.CoSoDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.YeuCauNghiDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.YeuCauNghi;
import org.example.model.TaiKhoan;
import org.example.model.CoSo;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class CaLamValidationEngine {

    private final CaLamViecDAO caLamViecDAO;
    private final YeuCauNghiDAO yeuCauNghiDAO;
    private final TaiKhoanDAO taiKhoanDAO;
    private final CoSoDAO coSoDAO;

    public CaLamValidationEngine() {
        this.caLamViecDAO = new CaLamViecDAOImpl();
        this.yeuCauNghiDAO = new YeuCauNghiDAOImpl();
        this.taiKhoanDAO = new TaiKhoanDAOImpl();
        this.coSoDAO = new CoSoDAOImpl();
    }

    public static class ValidationItem {
        private final String code;
        private final String message;
        private final String field;
        private final Object context;

        public ValidationItem(String code, String message, String field, Object context) {
            this.code = code;
            this.message = message;
            this.field = field;
            this.context = context;
        }

        public String getCode() { return code; }
        public String getMessage() { return message; }
        public String getField() { return field; }
        public Object getContext() { return context; }
    }

    public static class ValidationResult {
        private final boolean valid;
        private final List<ValidationItem> errors;
        private final List<ValidationItem> warnings;
        private final boolean requiresManagerConfirm;

        public ValidationResult(List<ValidationItem> errors, List<ValidationItem> warnings) {
            this.errors = errors != null ? errors : new ArrayList<>();
            this.warnings = warnings != null ? warnings : new ArrayList<>();
            this.valid = this.errors.isEmpty();
            this.requiresManagerConfirm = this.errors.isEmpty() && !this.warnings.isEmpty();
        }

        public boolean isValid() { return valid; }
        public List<ValidationItem> getErrorsItems() { return errors; }
        public List<ValidationItem> getWarningsItems() { return warnings; }
        public boolean isRequiresManagerConfirm() { return requiresManagerConfirm; }

        public List<String> getErrors() {
            List<String> list = new ArrayList<>();
            for (ValidationItem item : errors) {
                list.add(item.getMessage());
            }
            return list;
        }

        public List<String> getWarnings() {
            List<String> list = new ArrayList<>();
            for (ValidationItem item : warnings) {
                list.add(item.getMessage());
            }
            return list;
        }
    }

    /**
     * Validates a shift assignment against all VN labor laws, double bookings, leaves, etc.
     */
    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, Integer excludeCaLamViecId) {
        return validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, 0, excludeCaLamViecId);
    }

    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId) {
        Integer coSoId = null;
        if (excludeCaLamViecId != null) {
            CaLamViec existing = caLamViecDAO.getCaById(excludeCaLamViecId);
            if (existing != null) {
                coSoId = existing.getCoSoId();
            }
        }
        return validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, excludeCaLamViecId, coSoId);
    }

    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId, Integer coSoId) {
        return validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, excludeCaLamViecId, coSoId, false, null);
    }

    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId, Integer coSoId, boolean isCustomTime, String customTimeReason) {
        List<ValidationItem> errors = new ArrayList<>();
        List<ValidationItem> warnings = new ArrayList<>();

        if (isCustomTime) {
            if (customTimeReason == null || customTimeReason.trim().isEmpty()) {
                errors.add(new ValidationItem("NULL_CUSTOM_REASON", "Lý do tùy chỉnh giờ làm không được để trống.", "customTimeReason", null));
            } else if (customTimeReason.length() > 255) {
                errors.add(new ValidationItem("INVALID_CUSTOM_REASON", "Lý do tùy chỉnh giờ làm không được vượt quá 255 ký tự.", "customTimeReason", null));
            }
        }

        if (gioBatDau != null && gioKetThuc != null) {
            if (gioBatDau.equals(LocalTime.of(22, 0)) && gioKetThuc.equals(LocalTime.of(6, 0))) {
                errors.add(new ValidationItem("NIGHT_SHIFT_UNSUPPORTED", "Mẫu ca đêm chưa được hỗ trợ.", "gioBatDau", null));
                return new ValidationResult(errors, warnings);
            }
            if (gioBatDau.equals(gioKetThuc)) {
                errors.add(new ValidationItem("INVALID_TIME_ORDER", "Giờ bắt đầu phải trước giờ kết thúc.", "gioBatDau", null));
                return new ValidationResult(errors, warnings);
            }
            if (!gioBatDau.isBefore(gioKetThuc)) {
                errors.add(new ValidationItem("OVERNIGHT_UNSUPPORTED", "Ca qua ngày chưa được hỗ trợ.", "gioBatDau", null));
                return new ValidationResult(errors, warnings);
            }
        }

        if (ngayLam == null) {
            errors.add(new ValidationItem("NULL_DATE", "Ngày làm việc không được để trống.", "ngayLam", null));
            return new ValidationResult(errors, warnings);
        }

        if (gioBatDau == null || gioKetThuc == null) {
            errors.add(new ValidationItem("NULL_TIME", "Giờ bắt đầu và giờ kết thúc không được để trống.", "gioBatDau", null));
            return new ValidationResult(errors, warnings);
        }

        // Rule 5: start_time < end_time
        if (!gioBatDau.isBefore(gioKetThuc)) {
            errors.add(new ValidationItem("INVALID_TIME_ORDER", "Giờ bắt đầu phải trước giờ kết thúc.", "gioBatDau", null));
            return new ValidationResult(errors, warnings);
        }

        // Rule 2: Employee tồn tại
        TaiKhoan staff = taiKhoanDAO.getAccountById(accountId);
        if (staff == null) {
            errors.add(new ValidationItem("STAFF_NOT_FOUND", "Nhân viên không tồn tại.", "accountId", accountId));
            return new ValidationResult(errors, warnings);
        }

        // Rule 4: Employee đang active
        if (staff.isLocked() || staff.isDeleted() == Boolean.TRUE) {
            errors.add(new ValidationItem("STAFF_INACTIVE", "Nhân viên không hoạt động.", "accountId", accountId));
            return new ValidationResult(errors, warnings);
        }

        int roleId = staff.getRoleId();
        if (!Constants.ALLOWED_SHIFT_ROLES.contains(roleId)) {
            errors.add(new ValidationItem("INVALID_ROLE", "Nhân viên không có vai trò phù hợp để phân ca.", "accountId", roleId));
        }

        // Rule 3: Employee thuộc facility của manager (coSoId)
        if (coSoId != null && (staff.getCoSoId() == null || !staff.getCoSoId().equals(coSoId))) {
            errors.add(new ValidationItem("BRANCH_MISMATCH", "Không cho phép xếp ca cho nhân viên thuộc cơ sở khác.", "coSoId", coSoId));
        }

        // Rule 10: Không sửa hoặc hủy ca đã completed (CheckedOut hoặc Completed)
        if (excludeCaLamViecId != null) {
            CaLamViec existing = caLamViecDAO.getCaById(excludeCaLamViecId);
            if (existing != null) {
                if (Constants.SHIFT_STATUS_CHECKED_IN.equalsIgnoreCase(existing.getTrangThai())) {
                    errors.add(new ValidationItem("SHIFT_ACTIVE", "Không thể sửa ca làm việc đang ở trạng thái CheckedIn.", "trangThai", Constants.SHIFT_STATUS_CHECKED_IN));
                }
                if (Constants.isTerminalStatus(existing.getTrangThai())) {
                    errors.add(new ValidationItem("SHIFT_COMPLETED", "Không thể sửa ca làm việc đã hoàn thành.", "trangThai", existing.getTrangThai()));
                }
                if (Constants.SHIFT_STATUS_CONFIRMED.equalsIgnoreCase(existing.getTrangThai())) {
                    warnings.add(new ValidationItem("SHIFT_CONFIRMED", "Ca làm việc đã được nhân viên xác nhận. Thay đổi sẽ tự động gửi thông báo cho nhân viên.", "trangThai", Constants.SHIFT_STATUS_CONFIRMED));
                }
            }
        }

        long durationMins = Duration.between(gioBatDau, gioKetThuc).toMinutes();
        if (gioNghi < 0) {
            errors.add(new ValidationItem("INVALID_BREAK", "Giờ nghỉ giữa ca không được là số âm.", "gioNghi", gioNghi));
        } else if (gioNghi >= durationMins) {
            errors.add(new ValidationItem("INVALID_BREAK_DURATION", "Giờ nghỉ giữa ca phải nhỏ hơn thời lượng ca làm việc (" + durationMins + " phút).", "gioNghi", gioNghi));
        }

        // Rule 7: Không tạo ca trong quá khứ
        java.time.LocalDateTime shiftStart = java.time.LocalDateTime.of(ngayLam, gioBatDau);
        if (shiftStart.isBefore(java.time.LocalDateTime.now())) {
            if (excludeCaLamViecId == null) {
                errors.add(new ValidationItem("PAST_DATETIME", "Không thể tạo ca làm việc trong quá khứ.", "ngayLam", ngayLam));
            } else {
                CaLamViec oldShift = caLamViecDAO.getCaById(excludeCaLamViecId);
                if (oldShift != null) {
                    java.time.LocalDateTime oldStart = java.time.LocalDateTime.of(oldShift.getNgayLam(), oldShift.getGioBatDau());
                    if (!oldStart.equals(shiftStart) && shiftStart.isBefore(java.time.LocalDateTime.now())) {
                        errors.add(new ValidationItem("PAST_DATETIME", "Không thể thay đổi ca làm việc thành thời gian trong quá khứ.", "ngayLam", ngayLam));
                    }
                }
            }
        }

        // Rule 9: Ca nằm trong giờ hoạt động của facility
        if (coSoId != null) {
            CoSo coSo = coSoDAO.getCoSoById(coSoId);
            if (coSo != null) {
                LocalTime openTime = coSo.getGioMoCua();
                LocalTime closeTime = coSo.getGioDongCua();
                if (openTime != null && closeTime != null) {
                    boolean isWithin = false;
                    if (closeTime.isAfter(openTime)) {
                        isWithin = !gioBatDau.isBefore(openTime) && !gioKetThuc.isAfter(closeTime);
                    } else {
                        // Crosses midnight
                        boolean startInClosed = gioBatDau.isAfter(closeTime) && gioBatDau.isBefore(openTime);
                        boolean endInClosed = gioKetThuc.isAfter(closeTime) && gioKetThuc.isBefore(openTime);
                        isWithin = !startInClosed && !endInClosed;
                        if (isWithin) {
                            if (gioBatDau.isBefore(closeTime) && gioKetThuc.isAfter(openTime)) {
                                isWithin = false;
                            }
                        }
                    }
                    if (!isWithin) {
                        errors.add(new ValidationItem("FACILITY_HOURS_VIOLATION", 
                            String.format("Ca làm việc phải nằm trong giờ hoạt động của cơ sở (%s - %s).", openTime, closeTime), 
                            "gioBatDau", null));
                    }
                }
            }
        }

        long shiftNet = durationMins - gioNghi;
        if (shiftNet < Constants.MIN_SHIFT_MINUTES) {
            errors.add(new ValidationItem("MIN_DURATION", "Độ dài ca làm việc tối thiểu phải là 60 phút sau khi trừ giờ nghỉ.", "duration", shiftNet));
        }

        if (shiftNet > Constants.MAX_SHIFT_MINUTES) {
            errors.add(new ValidationItem("MAX_DURATION_EXCEEDED", "Độ dài ca làm việc không được vượt quá 12 tiếng (720 phút) sau khi trừ giờ nghỉ.", "duration", shiftNet));
        } else if (durationMins > 10 * 60) {
            warnings.add(new ValidationItem("MAX_DURATION", "Cảnh báo sức khỏe: Ca làm việc đơn kéo dài hơn 10 tiếng, nguy cơ quá tải (burnout).", "duration", durationMins));
        }

        if (shiftNet > 6 * 60 && gioNghi < 30) {
            warnings.add(new ValidationItem("MANDATORY_BREAK", "Cảnh báo vi phạm Bộ luật Lao động: Ca làm việc trên 6 tiếng yêu cầu thời gian nghỉ giữa ca ít nhất 30 phút.", "gioNghi", gioNghi));
        }

        List<CaLamViec> relatedShifts = caLamViecDAO.getShiftsByAccountAndDateRange(accountId, ngayLam.minusDays(7), ngayLam.plusDays(7))
            .stream()
            .filter(s -> !Constants.SHIFT_STATUS_CANCELLED.equalsIgnoreCase(s.getTrangThai()))
            .collect(java.util.stream.Collectors.toList());

        java.util.Set<LocalDate> shiftDates = new java.util.HashSet<>();
        shiftDates.add(ngayLam);
        for (CaLamViec s : relatedShifts) {
            if (s.getNgayLam() != null) {
                if (excludeCaLamViecId != null && s.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                shiftDates.add(s.getNgayLam());
            }
        }
        boolean has7ConsecutiveDays = false;
        for (int offset = 0; offset <= 6; offset++) {
            LocalDate windowStart = ngayLam.minusDays(offset);
            boolean allDaysHaveShifts = true;
            for (int i = 0; i <= 6; i++) {
                if (!shiftDates.contains(windowStart.plusDays(i))) {
                    allDaysHaveShifts = false;
                    break;
                }
            }
            if (allDaysHaveShifts) {
                has7ConsecutiveDays = true;
                break;
            }
        }
        if (has7ConsecutiveDays) {
            warnings.add(new ValidationItem("WEEKLY_REST", "Cảnh báo vi phạm Bộ luật Lao động: Nhân viên làm việc liên tục 7 ngày không có ngày nghỉ.", "ngayLam", shiftDates));
        }

        for (CaLamViec shift : relatedShifts) {
            if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                continue;
            }
            if (shift.getNgayLam() != null && Math.abs(shift.getNgayLam().toEpochDay() - ngayLam.toEpochDay()) <= 1) {
                if (shiftsOverlap(ngayLam, gioBatDau, gioKetThuc, shift.getNgayLam(), shift.getGioBatDau(), shift.getGioKetThuc())) {
                    errors.add(new ValidationItem("SHIFT_OVERLAP", String.format("Trùng ca: Nhân viên đã có ca làm việc từ %s đến %s vào ngày %s (Cơ sở ID: %d)",
                            shift.getGioBatDau(), shift.getGioKetThuc(), shift.getNgayLam(), shift.getCoSoId()), "gioBatDau", shift));
                }
            }
        }

        List<YeuCauNghi> approvedLeaves = yeuCauNghiDAO.findByAccountIDAndTrangThai(accountId, "DaDuyet");
        for (YeuCauNghi leave : approvedLeaves) {
            if (ngayLam.equals(leave.getNgayNghi())) {
                String loai = leave.getLoaiNghi();
                if ("FullDay".equalsIgnoreCase(loai)) {
                    errors.add(new ValidationItem("LEAVE_FULLDAY", "Xếp ca cho người đang nghỉ: Nhân viên có lịch nghỉ phép cả ngày đã được phê duyệt.", "ngayLam", leave));
                } else {
                    boolean morningOverlap = gioBatDau.isBefore(LocalTime.NOON);
                    boolean afternoonOverlap = (gioKetThuc.isAfter(LocalTime.NOON) || gioKetThuc.isBefore(gioBatDau)) 
                                                && gioBatDau.isBefore(LocalTime.of(23, 59));
                    if ("HalfDay_Morning".equalsIgnoreCase(loai) && morningOverlap) {
                        errors.add(new ValidationItem("LEAVE_HALFDAY_MORNING", "Xếp ca cho người đang nghỉ: Nhân viên nghỉ phép buổi sáng (trước 12:00).", "ngayLam", leave));
                    } else if ("HalfDay_Afternoon".equalsIgnoreCase(loai) && afternoonOverlap) {
                        errors.add(new ValidationItem("LEAVE_HALFDAY_AFTERNOON", "Xếp ca cho người đang nghỉ: Nhân viên nghỉ phép buổi chiều (sau 12:00).", "ngayLam", leave));
                    }
                }
            }
        }

        List<YeuCauNghi> pendingLeaves = yeuCauNghiDAO.findByAccountIDAndTrangThai(accountId, "ChoDuyet");
        for (YeuCauNghi leave : pendingLeaves) {
            if (ngayLam.equals(leave.getNgayNghi())) {
                warnings.add(new ValidationItem("PENDING_LEAVE", "Cảnh báo: Nhân viên có đơn xin nghỉ đang chờ duyệt vào ngày này.", "ngayLam", leave));
                break;
            }
        }

        for (CaLamViec shift : relatedShifts) {
            if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                continue;
            }
            if (shift.getNgayLam() != null && shift.getNgayLam().plusDays(1).equals(ngayLam)) {
                long restMinutes = Duration.between(shift.getGioKetThuc(), gioBatDau).toMinutes();
                if (shift.getGioKetThuc().isAfter(gioBatDau)) {
                    restMinutes += 1440;
                }
                if (restMinutes < Constants.MIN_REST_MINUTES) {
                    errors.add(new ValidationItem("REST_HOURS_CRITICAL", String.format("Vi phạm nghỉ ngơi tối thiểu: Ca liền trước kết thúc lúc %s ngày %s, khoảng cách nghỉ dưới 8 tiếng.",
                            shift.getGioKetThuc(), shift.getNgayLam()), "gioBatDau", shift));
                } else if (restMinutes < Constants.WARN_REST_MINUTES) {
                    warnings.add(new ValidationItem("REST_HOURS_BEFORE", String.format("Cảnh báo giờ nghỉ tối thiểu: Ca làm liền trước kết thúc lúc %s ngày %s, khoảng cách nghỉ chưa đủ 12 tiếng.",
                            shift.getGioKetThuc(), shift.getNgayLam()), "gioBatDau", shift));
                }
            }
            if (shift.getNgayLam() != null && ngayLam.plusDays(1).equals(shift.getNgayLam())) {
                long restMinutes = Duration.between(gioKetThuc, shift.getGioBatDau()).toMinutes();
                if (gioKetThuc.isAfter(shift.getGioBatDau())) {
                    restMinutes += 1440;
                }
                if (restMinutes < Constants.MIN_REST_MINUTES) {
                    errors.add(new ValidationItem("REST_HOURS_CRITICAL_AFTER", String.format("Vi phạm nghỉ ngơi tối thiểu: Ca tiếp theo bắt đầu lúc %s ngày %s, khoảng cách nghỉ dưới 8 tiếng.",
                            shift.getGioBatDau(), shift.getNgayLam()), "gioKetThuc", shift));
                } else if (restMinutes < Constants.WARN_REST_MINUTES) {
                    warnings.add(new ValidationItem("REST_HOURS_AFTER", String.format("Cảnh báo giờ nghỉ tối thiểu: Ca tiếp theo bắt đầu lúc %s ngày %s, khoảng cách nghỉ chưa đủ 12 tiếng.",
                            shift.getGioBatDau(), shift.getNgayLam()), "gioKetThuc", shift));
                }
            }
        }

        long dailyMinutes = shiftNet;
        for (CaLamViec shift : relatedShifts) {
            if (shift.getNgayLam() != null && ngayLam.equals(shift.getNgayLam())) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                long shiftMins = Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes();
                if (shift.getGioKetThuc().isBefore(shift.getGioBatDau())) {
                    shiftMins += 1440;
                }
                dailyMinutes += (shiftMins - shift.getGioNghi());
            }
        }

        if (dailyMinutes > 12 * 60) {
            errors.add(new ValidationItem("DAILY_LIMIT_OVERTIME", "Vượt giờ làm tối đa: Tổng số giờ làm việc trong ngày của nhân viên vượt quá 12 tiếng.", "duration", dailyMinutes));
        } else if (dailyMinutes > 8 * 60) {
            warnings.add(new ValidationItem("DAILY_LIMIT_STANDARD", "Cảnh báo: Tổng số giờ làm việc trong ngày của nhân viên vượt quá 8 tiếng tiêu chuẩn.", "duration", dailyMinutes));
        }

        long shiftCountToday = 1;
        for (CaLamViec shift : relatedShifts) {
            if (shift.getNgayLam() != null && ngayLam.equals(shift.getNgayLam())) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                shiftCountToday++;
            }
        }
        if (shiftCountToday > Constants.MAX_SHIFTS_PER_DAY) {
            errors.add(new ValidationItem("MAX_SHIFTS_PER_DAY",
                String.format("Nhân viên không thể có quá %d ca trong cùng một ngày (hiện tại: %d ca).", Constants.MAX_SHIFTS_PER_DAY, shiftCountToday),
                "ngayLam", shiftCountToday));
        }

        LocalDate startOfWeek = ngayLam.minusDays(ngayLam.getDayOfWeek().getValue() - 1);
        LocalDate endOfWeek = startOfWeek.plusDays(6);
        long weeklyMinutes = shiftNet;
        for (CaLamViec shift : relatedShifts) {
            if (shift.getNgayLam() != null && !shift.getNgayLam().isBefore(startOfWeek) && !shift.getNgayLam().isAfter(endOfWeek)) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                long shiftMins = Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes();
                if (shift.getGioKetThuc().isBefore(shift.getGioBatDau())) {
                    shiftMins += 1440;
                }
                weeklyMinutes += (shiftMins - shift.getGioNghi());
            }
        }

        if (weeklyMinutes > 48 * 60) {
            errors.add(new ValidationItem("WEEKLY_LIMIT_OVERTIME", "Vượt giờ làm tối đa: Tổng số giờ làm việc trong tuần này vượt quá 48 tiếng.", "duration", weeklyMinutes));
        } else if (weeklyMinutes > 40 * 60) {
            warnings.add(new ValidationItem("WEEKLY_LIMIT_STANDARD", "Cảnh báo: Tổng số giờ làm việc trong tuần này vượt quá 40 tiếng tiêu chuẩn.", "duration", weeklyMinutes));
        }

        LocalDate startOfMonth = ngayLam.withDayOfMonth(1);
        LocalDate endOfMonth = ngayLam.withDayOfMonth(ngayLam.lengthOfMonth());
        List<CaLamViec> monthlyShifts = caLamViecDAO.getShiftsByAccountAndDateRange(accountId, startOfMonth, endOfMonth)
            .stream()
            .filter(s -> !Constants.SHIFT_STATUS_CANCELLED.equalsIgnoreCase(s.getTrangThai()))
            .collect(java.util.stream.Collectors.toList());
        long monthlyMinutes = shiftNet;
        for (CaLamViec shift : monthlyShifts) {
            if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                continue;
            }
            long shiftMins = Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes();
            if (shift.getGioKetThuc().isBefore(shift.getGioBatDau())) {
                shiftMins += 1440;
            }
            monthlyMinutes += (shiftMins - shift.getGioNghi());
        }
        if (monthlyMinutes > Constants.MONTHLY_HOUR_LIMIT_MINUTES) {
            errors.add(new ValidationItem("MONTHLY_LIMIT",
                String.format("Vượt giới hạn giờ làm tháng: Tổng giờ làm trong tháng %d/%d vượt quá 160 tiếng (%d phút / %d phút cho phép).",
                    ngayLam.getMonthValue(), ngayLam.getYear(), monthlyMinutes, Constants.MONTHLY_HOUR_LIMIT_MINUTES),
                "duration", monthlyMinutes));
        }

        // P2-5: TODO — Availability check (nhân viên đăng ký ngày nghỉ / lịch cá nhân).
        // Requires CaLamViecAvailabilityDAO.findByAccountAndDate(accountId, ngayLam).
        // Block nếu nhân viên có đăng ký "Không có sẵn" (UNAVAILABLE) cho ngayLam.

        return new ValidationResult(errors, warnings);
    }

    private int toMin(LocalTime time) {
        return time.getHour() * 60 + time.getMinute();
    }

    private boolean shiftsOverlap(LocalDate d1, LocalTime s1, LocalTime e1, LocalDate d2, LocalTime s2, LocalTime e2) {
        long epoch1 = d1.toEpochDay();
        long epoch2 = d2.toEpochDay();
        
        long start1 = epoch1 * 1440 + toMin(s1);
        long end1 = epoch1 * 1440 + toMin(e1) + (e1.isBefore(s1) ? 1440 : 0);
        
        long start2 = epoch2 * 1440 + toMin(s2);
        long end2 = epoch2 * 1440 + toMin(e2) + (e2.isBefore(s2) ? 1440 : 0);
        
        return start1 < end2 && end1 > start2;
    }
}
