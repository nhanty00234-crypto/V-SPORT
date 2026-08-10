package org.example.api;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dto.api.ApiDtos;
import org.example.model.CustomerReputationHistory;
import org.example.model.KhuyenMai;
import org.example.model.TaiKhoan;
import org.example.model.ThongBao;
import org.example.service.reputation.ReputationLabel;
import org.example.util.Constants;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

/**
 * Chuyển entity/model nội bộ sang DTO công khai cho mobile.
 *
 * Nguyên tắc: chỉ ánh xạ trường, KHÔNG chứa business logic (nghiệp vụ nằm ở tầng Service).
 * Mọi đường dẫn ảnh đều đi qua {@link ImageUrls} để Flutter tải được qua HTTP.
 */
public final class ApiMappers {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private ApiMappers() {}

    public static ApiDtos.CustomerDto customer(HttpServletRequest req, TaiKhoan tk) {
        ApiDtos.CustomerDto dto = new ApiDtos.CustomerDto();
        dto.accountId = tk.getAccountId();
        dto.fullName = tk.getFullName();
        dto.email = tk.getEmail();
        dto.phone = tk.getPhoneNumber();
        dto.avatar = ImageUrls.absolutize(req, tk.getAvatarUrl());
        dto.gender = tk.getGioiTinh();
        dto.dateOfBirth = toLocalDate(tk.getNgaySinh());
        dto.reputationScore = tk.getDiemUyTin();
        dto.reputationLabel = ReputationLabel.of(tk.getDiemUyTin());
        dto.favoriteSportId = tk.getMonTheThaoYeuThichId();
        dto.canBook = tk.getDiemUyTin() >= Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD;
        return dto;
    }

    public static ApiDtos.ReputationDto reputation(TaiKhoan tk) {
        ApiDtos.ReputationDto dto = new ApiDtos.ReputationDto();
        dto.score = tk.getDiemUyTin();
        dto.label = ReputationLabel.of(tk.getDiemUyTin());
        dto.lateCancelCount = tk.getLateCancelCount();
        dto.noShowCount = tk.getNoShowCount();
        dto.completedBookingCount = tk.getCompletedBookingCount();
        dto.bookingBlockThreshold = Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD;
        dto.canBook = tk.getDiemUyTin() >= Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD;
        return dto;
    }

    public static ApiDtos.ReputationHistoryDto reputationHistory(CustomerReputationHistory h) {
        ApiDtos.ReputationHistoryDto dto = new ApiDtos.ReputationHistoryDto();
        dto.id = h.getReputationHistoryId();
        dto.bookingId = h.getDatSanId();
        dto.actionType = h.getActionType();
        dto.scoreDelta = h.getScoreDelta();
        dto.scoreBefore = h.getScoreBefore();
        dto.scoreAfter = h.getScoreAfter();
        dto.reason = h.getReason();
        dto.createdAt = h.getCreatedAt() != null ? h.getCreatedAt().format(ISO) : null;
        return dto;
    }

    public static ApiDtos.NotificationDto notification(ThongBao tb) {
        ApiDtos.NotificationDto dto = new ApiDtos.NotificationDto();
        dto.notificationId = tb.getThongBaoId();
        dto.title = tb.getTieuDe();
        dto.content = tb.getNoiDung();
        dto.type = tb.getLoaiThongBao();
        dto.read = tb.getDaDoc();
        dto.sentAt = tb.getThoiGianGui() != null
                ? tb.getThoiGianGui().toInstant().atZone(ApiJson.VN_ZONE).toLocalDateTime().format(ISO)
                : null;
        dto.recordId = tb.getMaBanGhi();
        return dto;
    }

    public static ApiDtos.PromotionDto promotion(HttpServletRequest req, KhuyenMai km, String image) {
        ApiDtos.PromotionDto dto = new ApiDtos.PromotionDto();
        dto.promotionId = km.getKhuyenMaiID();
        dto.code = km.getMaCode();
        dto.description = km.getMoTa();
        dto.discountType = km.getLoaiGiam();
        dto.discountValue = km.getGiaTriGiam();
        dto.startDate = km.getNgayBatDau();
        dto.endDate = km.getNgayKetThuc();
        dto.facilityId = km.getCoSoID();
        dto.minOrderAmount = km.getGiaTriToiThieu();
        dto.maxDiscount = km.getGiamToiDa();
        dto.image = ImageUrls.absolutize(req, image);
        return dto;
    }

    public static LocalDate toLocalDate(Date date) {
        if (date == null) return null;
        if (date instanceof java.sql.Date) return ((java.sql.Date) date).toLocalDate();
        return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    }
}
