package org.example.util;

import org.example.dao.CaLamViecDAO;
import org.example.dao.YeuCauNghiDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.YeuCauNghiDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.YeuCauNghi;
import org.example.model.TaiKhoan;

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

    public CaLamValidationEngine() {
        this.caLamViecDAO = new CaLamViecDAOImpl();
        this.yeuCauNghiDAO = new YeuCauNghiDAOImpl();
        this.taiKhoanDAO = new TaiKhoanDAOImpl();
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
        List<ValidationItem> errors = new ArrayList<>();
        List<ValidationItem> warnings = new ArrayList<>();

        if (ngayLam == null) {
            errors.add(new ValidationItem("NULL_DATE", "Ngày làm việc không được để trống.", "ngayLam", null));
            return new ValidationResult(errors, warnings);
        }

        if (gioBatDau == null || gioKetThuc == null) {
            errors.add(new ValidationItem("NULL_TIME", "Giờ bắt đầu và giờ kết thúc không được để trống.", "gioBatDau", null));
            return new ValidationResult(errors, warnings);
        }

        TaiKhoan staff = taiKhoanDAO.getAccountById(accountId);
        if (staff == null) {
            errors.add(new ValidationItem("STAFF_NOT_FOUND", "Nhân viên không tồn tại.", "accountId", accountId));
            return new ValidationResult(errors, warnings);
        }

        if (staff.getRoleId() != org.example.util.Constants.ROLE_STAFF) {
            errors.add(new ValidationItem("INVALID_ROLE", "Nhân viên được phân ca phải là Staff (không được phân ca cho Manager hoặc Admin).", "accountId", staff.getRoleId()));
        }

        if (coSoId != null && staff.getCoSoId() != null && !staff.getCoSoId().equals(coSoId)) {
            errors.add(new ValidationItem("BRANCH_MISMATCH", "Không cho phép xếp ca cho nhân viên của cơ sở khác.", "coSoId", coSoId));
        }

        if (excludeCaLamViecId != null) {
            CaLamViec existing = caLamViecDAO.getCaById(excludeCaLamViecId);
            if (existing != null) {
                if ("CheckedIn".equalsIgnoreCase(existing.getTrangThai())) {
                    errors.add(new ValidationItem("SHIFT_ACTIVE", "Không thể sửa ca làm việc đang ở trạng thái CheckedIn.", "trangThai", "CheckedIn"));
                }
                if ("CheckedOut".equalsIgnoreCase(existing.getTrangThai())) {
                    errors.add(new ValidationItem("SHIFT_COMPLETED", "Không thể sửa ca làm việc đã ở trạng thái CheckedOut.", "trangThai", "CheckedOut"));
                }
                if ("Confirmed".equalsIgnoreCase(existing.getTrangThai())) {
                    warnings.add(new ValidationItem("SHIFT_CONFIRMED", "Ca làm việc đã được nhân viên xác nhận. Thay đổi sẽ tự động gửi thông báo cho nhân viên.", "trangThai", "Confirmed"));
                }
            }
        }

        long durationMins = Duration.between(gioBatDau, gioKetThuc).toMinutes();
        if (gioKetThuc.isBefore(gioBatDau)) {
            durationMins += 1440;
        }
        if (gioNghi < 0) {
            errors.add(new ValidationItem("INVALID_BREAK", "Giờ nghỉ giữa ca không được là số âm.", "gioNghi", gioNghi));
        } else if (gioNghi >= durationMins) {
            errors.add(new ValidationItem("INVALID_BREAK_DURATION", "Giờ nghỉ giữa ca phải nhỏ hơn thời lượng ca làm việc (" + durationMins + " phút).", "gioNghi", gioNghi));
        }

        if (excludeCaLamViecId == null && ngayLam.isBefore(LocalDate.now())) {
            errors.add(new ValidationItem("PAST_DATE", "Không thể xếp ca làm việc trong quá khứ.", "ngayLam", ngayLam));
        }

        long shiftNet = durationMins - gioNghi;
        if (shiftNet < 30) {
            errors.add(new ValidationItem("MIN_DURATION", "Độ dài ca làm việc tối thiểu phải là 30 phút sau khi trừ giờ nghỉ.", "duration", shiftNet));
        }

        if (durationMins > 10 * 60) {
            warnings.add(new ValidationItem("MAX_DURATION", "Cảnh báo sức khỏe: Ca làm việc đơn kéo dài hơn 10 tiếng, nguy cơ quá tải (burnout).", "duration", durationMins));
        }

        if (shiftNet > 6 * 60 && gioNghi < 30) {
            warnings.add(new ValidationItem("MANDATORY_BREAK", "Cảnh báo vi phạm Bộ luật Lao động: Ca làm việc trên 6 tiếng yêu cầu thời gian nghỉ giữa ca ít nhất 30 phút.", "gioNghi", gioNghi));
        }

        List<CaLamViec> relatedShifts = caLamViecDAO.getShiftsByAccountAndDateRange(accountId, ngayLam.minusDays(7), ngayLam.plusDays(7));

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
                if (restMinutes < 12 * 60) {
                    warnings.add(new ValidationItem("REST_HOURS_BEFORE", String.format("Cảnh báo giờ nghỉ tối thiểu: Ca làm liền trước kết thúc lúc %s ngày %s, khoảng cách nghỉ chưa đủ 12 tiếng.",
                            shift.getGioKetThuc(), shift.getNgayLam()), "gioBatDau", shift));
                }
            }
            if (shift.getNgayLam() != null && ngayLam.plusDays(1).equals(shift.getNgayLam())) {
                long restMinutes = Duration.between(gioKetThuc, shift.getGioBatDau()).toMinutes();
                if (gioKetThuc.isAfter(shift.getGioBatDau())) {
                    restMinutes += 1440;
                }
                if (restMinutes < 12 * 60) {
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
