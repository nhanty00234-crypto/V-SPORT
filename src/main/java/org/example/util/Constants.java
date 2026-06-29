package org.example.util;

/**
 * Constants cho hệ thống V-SPORT
 * Centralize tất cả các giá trị constant để dễ maintain và tránh magic strings/numbers
 */
public final class Constants {

    // ========== ROLES ==========
    public static final int ROLE_ADMIN = 1;
    public static final int ROLE_MANAGER = 2;
    public static final int ROLE_KHACH_HANG = 3;
    public static final int ROLE_LE_TAN = 4;
    public static final int ROLE_BAO_VE = 5;

    // ========== BOOKING (LichDatSan) STATUS ==========
    public static final String TRANG_THAI_DAT_SAN_CHO_XAC_NHAN = "Chờ xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_XAC_NHAN = "Đã xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_HUY = "Đã hủy";
    public static final String TRANG_THAI_DAT_SAN_DANG_CHOI = "Đang chơi";
    public static final String TRANG_THAI_DAT_SAN_DA_HOAN_THANH = "Đã hoàn thành";

    // ========== INVOICE (HoaDon) STATUS ==========
    public static final String TRANG_THAI_HOA_DON_CHUA_TT = "Chưa thanh toán";
    public static final String TRANG_THAI_HOA_DON_DA_TT = "Đã thanh toán";
    public static final String TRANG_THAI_HOA_DON_HOAN_TIEN = "Hoàn tiền";
    public static final String TRANG_THAI_HOA_DON_GHI_NO = "Ghi nợ";

    // ========== PAYMENT METHODS ==========
    public static final String PT_TIEN_MAT = "Tiền mặt";
    public static final String PT_CHUYEN_KHOAN = "Chuyển khoản";
    public static final String PT_VI_DIEN_TU = "Ví điện tử";
    public static final String PT_THE = "Thẻ";

    // ========== COURT (San) STATUS ==========
    public static final String TRANG_THAI_SAN_SAN_SANG = "Sẵn sàng";
    public static final String TRANG_THAI_SAN_TAM_DONG = "Tạm đóng";
    public static final String TRANG_THAI_SAN_BAO_MAINTENANCE = "Bảo trì";

    // ========== PRODUCT/SERVICE (SanPham_DichVu) STATUS ==========
    public static final String TRANG_THAI_SP_DANG_KINH_DOANH = "Đang kinh doanh";
    public static final String TRANG_THAI_SP_TAM_HET_HANG = "Tạm hết hàng";
    public static final String TRANG_THAI_SP_NGUNG_KINH_DOANH = "Ngừng kinh doanh";

    // ========== PROMOTION (KhuyenMai) STATUS ==========
    public static final String TRANG_THAI_KM_HOAT_DONG = "Hoạt động";
    public static final String TRANG_THAI_KM_TAM_DUNG = "Tạm dừng";
    public static final String TRANG_THAI_KM_HET_HAN = "Hết hạn";

    // ========== REFUND (HoanTien) STATUS ==========
    public static final String TRANG_THAI_HOAN_TIEN_CHO_DUYET = "Chờ xử lý";
    public static final String TRANG_THAI_HOAN_TIEN_DA_DUYET = "Đã duyệt";
    public static final String TRANG_THAI_HOAN_TIEN_TU_CHOI = "Từ chối";
    public static final String TRANG_THAI_HOAN_TIEN_DA_HOAN = "Đã hoàn tiền";

    // ========== SOS REQUEST (YeuCauSOS) STATUS ==========
    public static final String TRANG_THAI_SOS_DANG_TIM = "Đang tìm";
    public static final String TRANG_THAI_SOS_DA_TIM_DUOC = "Đã tìm đủ";
    public static final String TRANG_THAI_SOS_HET_HAN = "Hết hạn";

    // ========== SHIFT (CaLamViec) DEFAULT ==========
    public static final int DEFAULT_SHIFT_DURATION_HOURS = 8;

    // ========== PAGINATION ==========
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 100;

    // ========== VALIDATION ==========
    public static final int PASSWORD_MIN_LENGTH = 8;
    public static final int PHONE_MIN_LENGTH = 10;
    public static final int PHONE_MAX_LENGTH = 15;

    // ========== DATE/TIME FORMATS ==========
    public static final String DATE_FORMAT_YYYY_MM_DD = "yyyy-MM-dd";
    public static final String DATETIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
    public static final String TIME_FORMAT_HH_MM = "HH:mm";

    // ========== FILE UPLOAD ==========
    public static final long MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB
    public static final String[] ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"};

    // ========== MESSAGES ==========
    public static final String MSG_SUCCESS_OPERATION = "Thao tác thành công";
    public static final String MSG_ERROR_DEFAULT = "Đã xảy ra lỗi, vui lòng thử lại";

    private Constants() {
        // Private constructor to prevent instantiation
    }
}
