package org.example.dto.api;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * Toàn bộ DTO request/response của REST API mobile (/api/v1/*), gom trong một file để dễ tra cứu
 * hợp đồng JSON. Đây là ranh giới giữa entity database và client — KHÔNG serialize thẳng entity
 * JPA ra ngoài (tránh lộ cột nội bộ và tránh lazy-loading proxy).
 *
 * Field name khớp trực tiếp key JSON (Gson serialize theo field). Đổi tên field = đổi hợp đồng API.
 */
public final class ApiDtos {

    private ApiDtos() {}

    // ===================== AUTH =====================

    /** Đăng nhập bằng email/username HOẶC số điện thoại (một trong hai). */
    public static class LoginRequest {
        public String email;
        public String phone;
        public String password;
    }

    public static class RefreshRequest {
        public String refreshToken;
    }

    public static class AuthResponse {
        public String accessToken;
        public String refreshToken;
        public String tokenType = "Bearer";
        public long expiresIn;          // giây
        public CustomerDto customer;
    }

    // ===================== CUSTOMER =====================

    public static class CustomerDto {
        public int accountId;
        public String fullName;
        public String email;
        public String phone;
        public String avatar;
        public String gender;
        public LocalDate dateOfBirth;
        public int reputationScore;
        public String reputationLabel;
        public int skillScore;
        public Integer favoriteSportId;
        public boolean canBook;
    }

    public static class UpdateProfileRequest {
        public String fullName;
        public String phone;
        public String gender;
        public String dateOfBirth;   // yyyy-MM-dd
        public String avatar;        // URL ảnh (app tự upload lên nơi khác hoặc giữ nguyên)
    }

    public static class ReputationDto {
        public int score;
        public String label;
        public int lateCancelCount;
        public int noShowCount;
        public int completedBookingCount;
        public int bookingBlockThreshold;
        public boolean canBook;
    }

    public static class ReputationHistoryDto {
        public long id;
        public Integer bookingId;
        public String actionType;
        public int scoreDelta;
        public int scoreBefore;
        public int scoreAfter;
        public String reason;
        public String createdAt;
    }

    // ===================== CATALOG =====================

    public static class SportDto {
        public int sportId;
        public String name;
        public int courtCount;
        public int facilityCount;
    }

    public static class FacilitySummaryDto {
        public int facilityId;
        public String name;
        public String address;
        public String phone;
        public Double latitude;
        public Double longitude;
        public Double distanceKm;
        public String image;
        public String openTime;
        public String closeTime;
        public boolean openNow;
        public double minPrice;
        public int readyCourtCount;
        public List<String> sports;
        public boolean hasPromotion;
    }

    public static class FacilityDetailDto {
        public int facilityId;
        public String name;
        public String address;
        public String phone;
        public String description;
        public Double latitude;
        public Double longitude;
        public String image;
        public String openTime;
        public String closeTime;
        public boolean openNow;
        public String status;
        public List<SportDto> sports;
        public List<CourtDto> courts;
        public List<PromotionDto> promotions;
    }

    public static class CourtDto {
        public int courtId;
        public String name;
        public int facilityId;
        public int courtTypeId;
        public String courtTypeName;
        public int sportId;
        public String sportName;
        public String status;
        public String image;
        public String description;
        public BigDecimal priceWithoutLight;
        public BigDecimal priceWithLight;
        public String lightingStart;
        public String lightingEnd;
    }

    // ===================== AVAILABILITY / BOOKING =====================

    public static class SlotDto {
        public LocalTime startTime;
        public LocalTime endTime;
        public boolean available;
        public String reason;      // null nếu available
        public BigDecimal price;   // giá của đúng khung giờ này, do server tính
    }

    public static class AvailabilityDto {
        public int courtId;
        public String courtName;
        public int facilityId;
        public LocalDate date;
        public String openTime;
        public String closeTime;
        public int slotMinutes;
        public List<SlotDto> slots;
    }

    public static class QuoteRequest {
        public int courtId;
        public String bookingDate;
        public String startTime;
        public String endTime;
        public String promotionCode;
    }

    public static class QuoteDto {
        public int courtId;
        public LocalDate bookingDate;
        public LocalTime startTime;
        public LocalTime endTime;
        public long durationMinutes;
        public BigDecimal courtAmount;
        public BigDecimal discountAmount;
        public BigDecimal totalAmount;
        public boolean promotionApplied;
        public String promotionMessage;
    }

    public static class CreateBookingRequest {
        public int courtId;
        public String bookingDate;    // yyyy-MM-dd
        public String startTime;      // HH:mm
        public String endTime;        // HH:mm
        public String note;
        public String promotionCode;
        /** "payos" = giữ chỗ + thanh toán online; "counter" (mặc định) = thanh toán tại quầy. */
        public String paymentMethod;
    }

    public static class BookingDto {
        public int bookingId;
        public int courtId;
        public String courtName;
        public int facilityId;
        public String facilityName;
        public String facilityAddress;
        public String sportName;
        public LocalDate bookingDate;
        public LocalTime startTime;
        public LocalTime endTime;
        public String status;
        public BigDecimal totalAmount;
        public boolean lightingApplied;
        public String note;
        public String source;
        public String createdAt;
        public Long holdRemainingSeconds;
        public boolean cancellable;
        public boolean payable;
        public String image;
    }

    public static class CancelBookingRequest {
        public String reason;
    }

    public static class CancelPreviewDto {
        public boolean cancellationAllowed;
        public boolean refundEligible;
        public boolean paid;
        public BigDecimal amountPaid;
        public BigDecimal cancellationFee;
        public BigDecimal refundableAmount;
        public int reputationPenalty;
        public double hoursBeforeStart;
        public String policyMessage;
        public boolean refundAlreadyExists;
        public Integer existingRefundId;
    }

    public static class CancelResultDto {
        public int bookingId;
        public Integer refundId;
        public Integer newReputationScore;
        public BigDecimal refundableAmount;
        public BigDecimal cancellationFee;
    }

    // ===================== PAYMENT =====================

    public static class PaymentDto {
        public int bookingId;
        public long orderCode;
        public long amount;
        public String description;
        /** Payload VietQR thô — Flutter tự render thành ảnh QR bằng thư viện qr_flutter. */
        public String qrPayload;
        public String checkoutUrl;
        public String bankBin;
        public String accountNumber;
        public String accountName;
        public Long expiresAtEpoch;
    }

    public static class PaymentStatusDto {
        public int bookingId;
        /** pending | paid | cancelled | expired | settled */
        public String status;
        public boolean paid;
        public String bookingStatus;
        public long remainingSeconds;
        public String message;
    }

    // ===================== PROMOTION =====================

    public static class PromotionDto {
        public int promotionId;
        public String code;
        public String description;
        public String discountType;   // PhanTram | SoTien
        public double discountValue;
        public LocalDate startDate;
        public LocalDate endDate;
        public Integer facilityId;
        public BigDecimal minOrderAmount;
        public BigDecimal maxDiscount;
        public String image;
    }

    public static class ValidatePromotionRequest {
        public String code;
        public Integer facilityId;
        public BigDecimal amount;
        public String bookingDate;
    }

    public static class ValidatePromotionDto {
        public boolean valid;
        public String message;
        public BigDecimal discountAmount;
        public BigDecimal finalAmount;
    }

    // ===================== QR / SERVICE REQUEST =====================

    public static class QrContextDto {
        public String resultCode;      // OK | NOT_FOUND | REVOKED | DISABLED | FACILITY_INACTIVE
        public String message;
        public boolean available;
        public Integer courtId;
        public String courtName;
        public String facilityName;
        public String sportName;
        /** Token phiên khách dùng cho /service-requests — do server sinh, gắn với chính QR này. */
        public String sessionToken;
        public List<String> availableActions;
        public Integer activeBookingId;
        public List<ProductDto> products;
    }

    public static class ProductDto {
        public int productId;
        public String name;
        public double price;
        public String unit;
        public int stock;
    }

    public static class ServiceRequestRequest {
        public String sessionToken;
        /** CALL_STAFF | ORDER_ITEM | SERVICE_REQUEST | PAYMENT_REQUEST */
        public String type;
        public String note;
        public List<OrderItem> items;

        public static class OrderItem {
            public int sanPhamId;
            public int soLuong;
        }
    }

    public static class ServiceRequestDto {
        public int requestId;
        public int courtId;
        public String courtName;
        public String type;
        public String note;
        public String status;
        public String createdAt;
        public String updatedAt;
    }

    // ===================== NOTIFICATION =====================

    public static class NotificationDto {
        public int notificationId;
        public String title;
        public String content;
        public String type;
        public boolean read;
        public String sentAt;
        public String recordId;
    }

    public static class NotificationListDto {
        public int total;
        public int unread;
        public int page;
        public int size;
        public List<NotificationDto> items;
    }

    // ===================== REFUND =====================

    public static class RefundDto {
        public int refundId;
        public Integer bookingId;
        public int invoiceId;
        public BigDecimal requestedAmount;
        public BigDecimal approvedAmount;
        public BigDecimal paidAmount;
        public String status;
        public String reason;
        public String rejectReason;
        public String bankName;
        public String bankAccountNumber;
        public String bankAccountHolder;
        public String requestedAt;
        public String completedAt;
    }

    public static class RefundBankInfoRequest {
        public String bankName;
        public String bankAccountNumber;
        public String bankAccountHolder;
    }

    // ===================== HOME =====================

    public static class HomeDto {
        public CustomerDto customer;
        public List<SportDto> sports;
        public List<FacilitySummaryDto> featuredFacilities;
        public List<PromotionDto> promotions;
        public List<BookingDto> upcomingBookings;
        public int unreadNotifications;
    }

    // ===================== PAGING =====================

    public static class PageDto<T> {
        public int page;
        public int size;
        public int total;
        public List<T> items;

        public PageDto(int page, int size, int total, List<T> items) {
            this.page = page;
            this.size = size;
            this.total = total;
            this.items = items;
        }
    }
}
