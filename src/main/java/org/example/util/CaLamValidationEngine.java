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

    public static class ValidationResult {
        private final boolean valid;
        private final List<String> errors;    // Hard conflicts (blocking)
        private final List<String> warnings;  // Soft conflicts (warning only)

        public ValidationResult(List<String> errors, List<String> warnings) {
            this.errors = errors != null ? errors : new ArrayList<>();
            this.warnings = warnings != null ? warnings : new ArrayList<>();
            this.valid = this.errors.isEmpty();
        }

        public boolean isValid() { return valid; }
        public List<String> getErrors() { return errors; }
        public List<String> getWarnings() { return warnings; }
    }

    /**
     * Validates a shift assignment against all VN labor laws, double bookings, leaves, etc.
     */
    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, Integer excludeCaLamViecId) {
        return validateShift(accountId, ngayLam, gioBatDau, gioKetThuc, 0, excludeCaLamViecId);
    }

    public ValidationResult validateShift(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, int gioNghi, Integer excludeCaLamViecId) {
        List<String> errors = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        TaiKhoan staff = taiKhoanDAO.getAccountById(accountId);
        if (staff == null) {
            errors.add("Nhân viên không tồn tại.");
            return new ValidationResult(errors, warnings);
        }

        // Validate gioNghi boundary
        if (gioNghi < 0) {
            errors.add("Giờ nghỉ giữa ca không được là số âm.");
        } else if (gioBatDau != null && gioKetThuc != null) {
            long duration = java.time.Duration.between(gioBatDau, gioKetThuc).toMinutes();
            if (duration < 0) duration += 24 * 60;
            if (gioNghi >= duration) {
                errors.add("Giờ nghỉ giữa ca phải nhỏ hơn thời lượng ca làm việc (" + duration + " phút).");
            }
        }

        // 1. Check double-booking (System-wide overlap check)
        List<CaLamViec> allShifts = caLamViecDAO.getAllCaLamViec(); // Simple lookup for demo or customized search
        for (CaLamViec shift : allShifts) {
            if (shift.getAccountId() == accountId && ngayLam.equals(shift.getNgayLam())) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                boolean overlap = gioBatDau.isBefore(shift.getGioKetThuc()) && gioKetThuc.isAfter(shift.getGioBatDau());
                if (overlap) {
                    errors.add(String.format("Trùng ca: Nhân viên đã có ca làm việc từ %s đến %s vào ngày %s (Cơ sở ID: %d)",
                            shift.getGioBatDau(), shift.getGioKetThuc(), ngayLam, shift.getCoSoId()));
                }
            }
        }

        // 2. Check Leave Requests Overlap
        List<YeuCauNghi> approvedLeaves = yeuCauNghiDAO.findByAccountIDAndTrangThai(accountId, "DaDuyet");
        for (YeuCauNghi leave : approvedLeaves) {
            if (ngayLam.equals(leave.getNgayNghi())) {
                String loai = leave.getLoaiNghi();
                if ("FullDay".equalsIgnoreCase(loai)) {
                    errors.add("Xếp ca cho người đang nghỉ: Nhân viên có lịch nghỉ phép cả ngày đã được phê duyệt.");
                } else if ("HalfDay_Morning".equalsIgnoreCase(loai)) {
                    // Morning leave: 08:00 - 12:00
                    boolean overlapMorning = gioBatDau.isBefore(LocalTime.of(12, 0));
                    if (overlapMorning) {
                        errors.add("Xếp ca cho người đang nghỉ: Nhân viên nghỉ phép buổi sáng (trước 12:00).");
                    }
                } else if ("HalfDay_Afternoon".equalsIgnoreCase(loai)) {
                    // Afternoon leave: 12:00 - 18:00 or later
                    boolean overlapAfternoon = gioKetThuc.isAfter(LocalTime.of(12, 0));
                    if (overlapAfternoon) {
                        errors.add("Xếp ca cho người đang nghỉ: Nhân viên nghỉ phép buổi chiều (sau 12:00).");
                    }
                }
            }
        }

        // 3. Minimum Rest Time between shifts (>= 12 hours VN labor standard or customizable)
        // Check shifts ending on the day before, or starting on the day after
        for (CaLamViec shift : allShifts) {
            if (shift.getAccountId() == accountId) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                // Check if shift is the day before
                if (shift.getNgayLam() != null && shift.getNgayLam().plusDays(1).equals(ngayLam)) {
                    // Previous shift ends, current shift starts
                    long restMinutes = Duration.between(shift.getGioKetThuc(), gioBatDau).toMinutes();
                    if (shift.getGioKetThuc().isAfter(gioBatDau)) {
                        // overnight or backwards time handling
                        restMinutes += 1440;
                    }
                    if (restMinutes < 12 * 60) {
                        warnings.add(String.format("Cảnh báo giờ nghỉ tối thiểu: Ca làm liền trước kết thúc lúc %s ngày %s, khoảng cách nghỉ chưa đủ 12 tiếng.",
                                shift.getGioKetThuc(), shift.getNgayLam()));
                    }
                }
                // Check if current shift is day before another shift
                if (shift.getNgayLam() != null && ngayLam.plusDays(1).equals(shift.getNgayLam())) {
                    long restMinutes = Duration.between(gioKetThuc, shift.getGioBatDau()).toMinutes();
                    if (gioKetThuc.isAfter(shift.getGioBatDau())) {
                        restMinutes += 1440;
                    }
                    if (restMinutes < 12 * 60) {
                        warnings.add(String.format("Cảnh báo giờ nghỉ tối thiểu: Ca tiếp theo bắt đầu lúc %s ngày %s, khoảng cách nghỉ chưa đủ 12 tiếng.",
                                shift.getGioBatDau(), shift.getNgayLam()));
                    }
                }
            }
        }

        // 4. Maximum work hours validation (Max 8 hours/day standard, 12 hours overtime)
        long currentMinutes = Duration.between(gioBatDau, gioKetThuc).toMinutes();
        if (gioKetThuc.isBefore(gioBatDau)) {
            currentMinutes += 1440; // Overnight
        }
        currentMinutes -= gioNghi;
        
        long dailyMinutes = currentMinutes;
        for (CaLamViec shift : allShifts) {
            if (shift.getAccountId() == accountId && ngayLam.equals(shift.getNgayLam())) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                long shiftMins = Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes();
                if (shift.getGioKetThuc().isBefore(shift.getGioBatDau())) {
                    shiftMins += 1440; // Overnight
                }
                dailyMinutes += (shiftMins - shift.getGioNghi());
            }
        }

        if (dailyMinutes > 12 * 60) {
            errors.add("Vượt giờ làm tối đa: Tổng số giờ làm việc trong ngày của nhân viên vượt quá 12 tiếng.");
        } else if (dailyMinutes > 8 * 60) {
            warnings.add("Cảnh báo: Tổng số giờ làm việc trong ngày của nhân viên vượt quá 8 tiếng tiêu chuẩn.");
        }

        // Check Weekly Limit (Max 48 hours/week)
        LocalDate startOfWeek = ngayLam.minusDays(ngayLam.getDayOfWeek().getValue() - 1); // Monday
        LocalDate endOfWeek = startOfWeek.plusDays(6); // Sunday
        long weeklyMinutes = currentMinutes;
        for (CaLamViec shift : allShifts) {
            if (shift.getAccountId() == accountId && shift.getNgayLam() != null &&
                    !shift.getNgayLam().isBefore(startOfWeek) && !shift.getNgayLam().isAfter(endOfWeek)) {
                if (excludeCaLamViecId != null && shift.getCaLamViecId() == excludeCaLamViecId.intValue()) {
                    continue;
                }
                long shiftMins = Duration.between(shift.getGioBatDau(), shift.getGioKetThuc()).toMinutes();
                if (shift.getGioKetThuc().isBefore(shift.getGioBatDau())) {
                    shiftMins += 1440; // Overnight
                }
                weeklyMinutes += (shiftMins - shift.getGioNghi());
            }
        }

        if (weeklyMinutes > 48 * 60) {
            errors.add("Vượt giờ làm tối đa: Tổng số giờ làm việc trong tuần này vượt quá 48 tiếng.");
        } else if (weeklyMinutes > 40 * 60) {
            warnings.add("Cảnh báo: Tổng số giờ làm việc trong tuần này vượt quá 40 tiếng tiêu chuẩn.");
        }

        return new ValidationResult(errors, warnings);
    }
}
