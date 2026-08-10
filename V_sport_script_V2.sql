-- ============================================================================
-- V_sport_script_V2.sql — V-SPORT (Microsoft SQL Server)
-- Script tạo mới toàn bộ cấu trúc database, phiên bản V2.
--
-- KHÁC BIỆT SO VỚI V_sport_script.sql (V1):
--   1. QUY ƯỚC ĐẶT TÊN: toàn bộ tên bảng và tên cột đã đổi sang TIẾNG ANH,
--      dạng snake_case, tên bảng số nhiều (accounts, bookings, invoices...).
--      V1 dùng tên tiếng Việt PascalCase lẫn lộn (LichDatSan, actual_start_time,
--      SanPham_DichVu) — V2 nhất quán 100%.
--   2. BỎ 2 BẢNG CHẾT:
--        - LichSuELO           (hệ thống ELO — chỉ có model, 0 DAO/service/UI)
--        - CaLamViec_Availability (đăng ký giờ rảnh — bỏ theo yêu cầu)
--      Kèm theo bỏ các cột chết: Accounts.DiemTrinhDo (ELO),
--      Accounts.NhanThongBaoSOS (module SOS chưa bao giờ triển khai).
--   3. KHÔI PHỤC 9 BẢNG mà code Java vẫn đang dùng nhưng V1 đã cắt nhầm:
--        teams, team_members, team_invitations, team_join_requests  (đội nhóm)
--        reviews                                                    (đánh giá)
--        bill_split_groups, bill_split_shares                       (chia tiền nhóm)
--        booking_services                                           (dịch vụ đặt kèm)
--        qr_requests                                                (gọi nhân viên qua QR)
--   4. SỬA LỖI có sẵn trong V1: chỉ mục UX_HoaDon_OneMainPerBooking bị mất mệnh đề
--      WHERE (xem sql/migration_court_checkout.sql). Thiếu WHERE thì một lượt đặt
--      sân không thể vừa có hóa đơn MAIN vừa có hóa đơn SERVICE — V2 khôi phục bộ lọc.
--   5. SEED DATA: nạp đủ 4 vai trò với ID cố định + 1 tài khoản admin.
--
-- ⚠️  LƯU Ý QUAN TRỌNG — GIÁ TRỊ TIẾNG VIỆT KHÔNG ĐƯỢC DỊCH:
--      Chỉ TÊN BẢNG/TÊN CỘT đổi sang tiếng Anh. Các GIÁ TRỊ lưu trong cột
--      (N'Chờ xác nhận', N'Đã hủy', N'Mới chơi'...) là DỮ LIỆU, được so sánh
--      trực tiếp với hằng số trong src/main/java/org/example/util/Constants.java.
--      Dịch chúng sang tiếng Anh sẽ làm hỏng toàn bộ luồng nghiệp vụ.
--
-- ⚠️  VAI TRÒ (roles) GIỮ NGUYÊN TUYỆT ĐỐI — khớp Constants.java dòng 10-13:
--      1 = Admin, 2 = Manager, 3 = Khách hàng, 4 = Lễ tân
--
-- CÁCH CHẠY:
--      sqlcmd -S <server> -E -i V_sport_script_V2.sql -f 65001
--      (tham số -f 65001 bắt buộc — file chứa nhiều ký tự tiếng Việt)
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID(N'V_SPORT_V2') IS NULL
BEGIN
    CREATE DATABASE V_SPORT_V2;
END
GO

USE V_SPORT_V2;
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- §1. BẢNG TRA CỨU (không phụ thuộc bảng nào)
-- ============================================================================

-- ---------- roles — Vai trò (KHÔNG ĐỔI CẤU TRÚC) ----------
IF OBJECT_ID('dbo.roles','U') IS NULL
CREATE TABLE dbo.roles (
    role_id                      INT                IDENTITY(1,1) NOT NULL,
    role_name                    NVARCHAR(50)       NOT NULL,
    CONSTRAINT pk_roles PRIMARY KEY (role_id)
);
GO

-- ---------- sports — Môn thể thao ----------
IF OBJECT_ID('dbo.sports','U') IS NULL
CREATE TABLE dbo.sports (
    sport_id                     INT                IDENTITY(1,1) NOT NULL,
    sport_name                   NVARCHAR(50)       NOT NULL,
    CONSTRAINT pk_sports PRIMARY KEY (sport_id)
);
GO

-- ---------- product_categories — Danh mục sản phẩm ----------
IF OBJECT_ID('dbo.product_categories','U') IS NULL
CREATE TABLE dbo.product_categories (
    category_id                  INT                IDENTITY(1,1) NOT NULL,
    category_name                NVARCHAR(100)      NOT NULL,
    CONSTRAINT pk_product_categories PRIMARY KEY (category_id)
);
GO

-- ============================================================================
-- §2. TÀI KHOẢN & CƠ SỞ
-- ============================================================================

-- ---------- facilities — Cơ sở / chi nhánh ----------
IF OBJECT_ID('dbo.facilities','U') IS NULL
CREATE TABLE dbo.facilities (
    facility_id                  INT                IDENTITY(1,1) NOT NULL,
    facility_name                NVARCHAR(100)      NOT NULL,
    address                      NVARCHAR(255)      NULL,
    phone_number                 VARCHAR(15)        NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_facilities_status DEFAULT (N'Hoạt động'),
    opening_time                 TIME               NULL,
    closing_time                 TIME               NULL,
    image_path                   NVARCHAR(500)      NULL,
    description                  NVARCHAR(MAX)      NULL,
    business_type                NVARCHAR(255)      NULL,
    planned_court_count          INT                NULL CONSTRAINT df_facilities_planned_court_count DEFAULT ((0)),
    manager_account_id           INT                NULL,
    payos_client_id              VARCHAR(255)       NULL,
    payos_api_key                VARCHAR(255)       NULL,
    payos_checksum_key           VARCHAR(255)       NULL,
    is_deleted                   BIT                NULL CONSTRAINT df_facilities_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    latitude                     DECIMAL(10,7)      NULL,
    longitude                    DECIMAL(10,7)      NULL,
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id)
);
GO

-- ---------- accounts — Tài khoản ----------
-- ĐÃ BỎ so với V1: DiemTrinhDo (ELO — chức năng chết), NhanThongBaoSOS (SOS — chưa triển khai)
IF OBJECT_ID('dbo.accounts','U') IS NULL
CREATE TABLE dbo.accounts (
    account_id                   INT                IDENTITY(1,1) NOT NULL,
    username                     VARCHAR(50)        NULL,
    password_hash                VARCHAR(72)        NOT NULL,   -- BCrypt cost 12 → luôn 60 ký tự
    failed_login_count           INT                NULL CONSTRAINT df_accounts_failed_login_count DEFAULT ((0)),
    is_locked                    BIT                NULL CONSTRAINT df_accounts_is_locked DEFAULT ((0)),
    last_login_at                DATETIME           NULL,
    google_id                    VARCHAR(100)       NULL,
    facebook_id                  VARCHAR(100)       NULL,
    zalo_id                      VARCHAR(100)       NULL,
    messenger_id                 VARCHAR(100)       NULL,
    full_name                    NVARCHAR(100)      NULL,
    phone_number                 VARCHAR(15)        NULL,
    email                        VARCHAR(100)       NULL,
    role_id                      INT                NULL,
    facility_id                  INT                NULL,
    -- Uy tín & thống kê hành vi đặt sân
    reputation_score             INT                NULL CONSTRAINT df_accounts_reputation_score DEFAULT ((100)),
    completed_booking_count      INT                NOT NULL CONSTRAINT df_accounts_completed_booking_count DEFAULT ((0)),
    late_cancel_count            INT                NOT NULL CONSTRAINT df_accounts_late_cancel_count DEFAULT ((0)),
    no_show_count                INT                NOT NULL CONSTRAINT df_accounts_no_show_count DEFAULT ((0)),
    -- Thông tin ngân hàng (dùng khi hoàn tiền)
    bank_code                    VARCHAR(20)        NULL,
    bank_account_number          VARCHAR(50)        NULL,
    qr_image_path                NVARCHAR(500)      NULL,
    -- Hồ sơ cá nhân
    avatar_url                   NVARCHAR(255)      NULL,
    cover_image_url              NVARCHAR(500)      NULL,
    date_of_birth                DATE               NULL,
    gender                       NVARCHAR(10)       NULL,
    height_cm                    INT                NULL,
    weight_kg                    INT                NULL,
    special_note                 NVARCHAR(500)      NULL,
    -- Cá nhân hoá thể thao
    preferred_position           NVARCHAR(50)       NULL,
    favorite_positions           NVARCHAR(255)      NULL,
    favorite_sport_id            INT                NULL,
    skill_level                  VARCHAR(30)        NULL,
    play_goal                    NVARCHAR(255)      NULL,
    play_frequency               VARCHAR(30)        NULL,
    -- Tuỳ chọn thông báo
    receive_marketing_notification BIT              NOT NULL CONSTRAINT df_accounts_receive_marketing_notification DEFAULT ((1)),
    -- Vòng đời bản ghi
    created_at                   DATETIME           NULL CONSTRAINT df_accounts_created_at DEFAULT (getdate()),
    is_deleted                   BIT                NULL CONSTRAINT df_accounts_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_accounts PRIMARY KEY (account_id)
);
GO

-- ---------- facility_capabilities — Năng lực / quyền mở dịch vụ của cơ sở ----------
IF OBJECT_ID('dbo.facility_capabilities','U') IS NULL
CREATE TABLE dbo.facility_capabilities (
    capability_id                INT                IDENTITY(1,1) NOT NULL,
    facility_id                  INT                NOT NULL,
    capability_type              NVARCHAR(50)       NOT NULL,
    status                       NVARCHAR(20)       NOT NULL CONSTRAINT df_facility_capabilities_status DEFAULT (N'PENDING'),
    requested_at                 DATETIME2          NOT NULL CONSTRAINT df_facility_capabilities_requested_at DEFAULT (sysutcdatetime()),
    approved_by                  INT                NULL,
    approved_at                  DATETIME2          NULL,
    reject_reason                NVARCHAR(500)      NULL,
    note                         NVARCHAR(500)      NULL,
    updated_at                   DATETIME2          NOT NULL CONSTRAINT df_facility_capabilities_updated_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_facility_capabilities PRIMARY KEY (capability_id)
);
GO

-- ---------- facility_bank_accounts — Tài khoản ngân hàng của cơ sở (1:1) ----------
IF OBJECT_ID('dbo.facility_bank_accounts','U') IS NULL
CREATE TABLE dbo.facility_bank_accounts (
    facility_id                  INT                NOT NULL,
    bank_name                    NVARCHAR(100)      NOT NULL,
    bank_short_code              VARCHAR(20)        NOT NULL,
    account_holder_name          NVARCHAR(100)      NOT NULL,
    account_number               VARCHAR(50)        NOT NULL,
    updated_at                   DATETIME2          NOT NULL CONSTRAINT df_facility_bank_accounts_updated_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_facility_bank_accounts PRIMARY KEY (facility_id)
);
GO

-- ============================================================================
-- §3. SÂN & MÃ QR SÂN
-- ============================================================================

-- ---------- court_types — Loại sân (kèm bảng giá) ----------
IF OBJECT_ID('dbo.court_types','U') IS NULL
CREATE TABLE dbo.court_types (
    court_type_id                INT                IDENTITY(1,1) NOT NULL,
    sport_id                     INT                NOT NULL,
    facility_id                  INT                NULL,
    type_name                    NVARCHAR(50)       NOT NULL,
    price_without_light          DECIMAL(18,2)      NULL,
    price_with_light             DECIMAL(18,2)      NULL,
    light_start_time             TIME               NULL CONSTRAINT df_court_types_light_start_time DEFAULT ('17:30:00'),
    light_end_time               TIME               NULL,
    is_deleted                   BIT                NOT NULL CONSTRAINT df_court_types_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_court_types PRIMARY KEY (court_type_id)
);
GO

-- ---------- courts — Sân ----------
IF OBJECT_ID('dbo.courts','U') IS NULL
CREATE TABLE dbo.courts (
    court_id                     INT                IDENTITY(1,1) NOT NULL,
    court_name                   NVARCHAR(50)       NOT NULL,
    court_type_id                INT                NULL,
    facility_id                  INT                NOT NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_courts_status DEFAULT (N'Sẵn sàng'),
    description                  NVARCHAR(MAX)      NULL,
    image_path                   NVARCHAR(500)      NULL,
    is_deleted                   BIT                NULL CONSTRAINT df_courts_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_courts PRIMARY KEY (court_id)
);
GO

-- ---------- court_qr_codes — Mã QR gắn tại sân ----------
IF OBJECT_ID('dbo.court_qr_codes','U') IS NULL
CREATE TABLE dbo.court_qr_codes (
    court_qr_id                  INT                IDENTITY(1,1) NOT NULL,
    court_id                     INT                NOT NULL,
    token                        UNIQUEIDENTIFIER   NOT NULL CONSTRAINT df_court_qr_codes_token DEFAULT (newid()),
    short_code                   NVARCHAR(12)       NULL,
    status                       NVARCHAR(20)       NOT NULL CONSTRAINT df_court_qr_codes_status DEFAULT (N'ACTIVE'),
    regenerate_count             INT                NOT NULL CONSTRAINT df_court_qr_codes_regenerate_count DEFAULT ((0)),
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_court_qr_codes_created_at DEFAULT (sysutcdatetime()),
    created_by                   INT                NULL,
    updated_at                   DATETIME2          NOT NULL CONSTRAINT df_court_qr_codes_updated_at DEFAULT (sysutcdatetime()),
    updated_by                   INT                NULL,
    CONSTRAINT pk_court_qr_codes PRIMARY KEY (court_qr_id)
);
GO

-- ---------- court_qr_token_history — Lịch sử cấp/thu hồi token QR ----------
IF OBJECT_ID('dbo.court_qr_token_history','U') IS NULL
CREATE TABLE dbo.court_qr_token_history (
    history_id                   INT                IDENTITY(1,1) NOT NULL,
    court_qr_id                  INT                NOT NULL,
    court_id                     INT                NOT NULL,
    token                        UNIQUEIDENTIFIER   NULL,
    token_hash                   NVARCHAR(64)       NULL,
    short_code                   NVARCHAR(12)       NULL,
    status                       NVARCHAR(20)       NOT NULL CONSTRAINT df_court_qr_token_history_status DEFAULT (N'ISSUED'),
    issued_at                    DATETIME2          NOT NULL CONSTRAINT df_court_qr_token_history_issued_at DEFAULT (sysutcdatetime()),
    revoked_at                   DATETIME2          NULL,
    revoked_by                   INT                NULL,
    revoke_reason                NVARCHAR(200)      NULL,
    CONSTRAINT pk_court_qr_token_history PRIMARY KEY (history_id)
);
GO

-- ============================================================================
-- §4. ĐẶT SÂN
-- ============================================================================

-- ---------- bookings — Lượt đặt sân ----------
-- LƯU Ý: 2 cặp cột thời gian thực tế phục vụ 2 mục đích KHÁC NHAU, đều đang được dùng:
--   actual_start_time_of_day / actual_end_time_of_day (TIME)     → hiển thị giờ trong ngày (CheckInDAO)
--   actual_started_at        / actual_ended_at        (DATETIME2) → mốc thời gian đầy đủ để tính tiền (CheckoutService)
IF OBJECT_ID('dbo.bookings','U') IS NULL
CREATE TABLE dbo.bookings (
    booking_id                   INT                IDENTITY(1,1) NOT NULL,
    account_id                   INT                NULL,
    court_id                     INT                NULL,
    booking_date                 DATE               NOT NULL,
    start_time                   TIME               NOT NULL,
    end_time                     TIME               NOT NULL,
    apply_light_price            BIT                NULL CONSTRAINT df_bookings_apply_light_price DEFAULT ((0)),
    estimated_total              DECIMAL(18,2)      NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_bookings_status DEFAULT (N'Chờ xác nhận'),
    note                         NVARCHAR(255)      NULL,
    booking_source               NVARCHAR(50)       NULL,
    time_mode                    NVARCHAR(30)       NULL,
    reserved_duration_minutes    INT                NULL,
    -- Giữ chỗ & đặt cọc
    hold_expires_at              DATETIME2          NULL,
    deposit_amount               DECIMAL(18,2)      NULL,
    -- Xác nhận
    payment_method_confirmed     NVARCHAR(50)       NULL,
    transaction_code             NVARCHAR(100)      NULL,
    confirmed_at                 DATETIME2          NULL,
    confirmed_by                 INT                NULL,
    confirm_source               NVARCHAR(20)       NULL,
    -- Thời gian chơi thực tế
    actual_start_time_of_day     TIME               NULL,
    actual_end_time_of_day       TIME               NULL,
    actual_started_at            DATETIME2          NULL,
    actual_ended_at              DATETIME2          NULL,
    pricing_finalized_at         DATETIME2          NULL,
    early_checkout_reason        NVARCHAR(255)      NULL,
    early_checkout_discount      DECIMAL(18,2)      NULL,
    no_show_at                   DATETIME2          NULL,
    -- Huỷ
    cancel_type                  NVARCHAR(20)       NULL,
    cancel_reason                NVARCHAR(255)      NULL,
    cancelled_at                 DATETIME2          NULL,
    cancelled_by                 INT                NULL,
    requires_refund_review       BIT                NOT NULL CONSTRAINT df_bookings_requires_refund_review DEFAULT ((0)),
    -- Thanh toán PayOS
    payos_order_code             BIGINT             NULL,
    payos_payment_link_id        VARCHAR(255)       NULL,
    payos_qr_payload             NVARCHAR(MAX)      NULL,
    payos_checkout_url           NVARCHAR(1024)     NULL,
    payos_bin                    VARCHAR(20)        NULL,
    payos_account_number         VARCHAR(64)        NULL,
    payos_account_name           NVARCHAR(255)      NULL,
    payos_amount                 DECIMAL(18,2)      NULL,
    payos_description            NVARCHAR(255)      NULL,
    payos_expires_at             DATETIME2          NULL,
    -- Vòng đời bản ghi
    created_at                   DATETIME           NULL CONSTRAINT df_bookings_created_at DEFAULT (getdate()),
    is_deleted                   BIT                NULL CONSTRAINT df_bookings_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id)
);
GO

-- ---------- booking_services — Dịch vụ đặt kèm theo lượt đặt sân (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.booking_services','U') IS NULL
CREATE TABLE dbo.booking_services (
    booking_service_id           INT                IDENTITY(1,1) NOT NULL,
    booking_id                   INT                NOT NULL,
    product_id                   INT                NOT NULL,
    quantity                     INT                NOT NULL,
    unit_price                   DECIMAL(18,2)      NOT NULL,
    total_price                  DECIMAL(18,2)      NOT NULL,
    status                       NVARCHAR(50)       NOT NULL CONSTRAINT df_booking_services_status DEFAULT (N'Chờ chuẩn bị'),
    note                         NVARCHAR(255)      NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_booking_services_created_at DEFAULT (sysdatetime()),
    delivered_at                 DATETIME2          NULL,
    delivered_by                 INT                NULL,
    CONSTRAINT pk_booking_services PRIMARY KEY (booking_service_id)
);
GO

-- ---------- booking_extensions — Gia hạn giờ chơi ----------
IF OBJECT_ID('dbo.booking_extensions','U') IS NULL
CREATE TABLE dbo.booking_extensions (
    extension_id                 INT                IDENTITY(1,1) NOT NULL,
    booking_id                   INT                NOT NULL,
    old_end_time                 TIME               NOT NULL,
    new_end_time                 TIME               NOT NULL,
    old_end_at                   DATETIME2          NULL,
    new_end_at                   DATETIME2          NULL,
    additional_amount            DECIMAL(18,2)      NOT NULL,
    operator_account_id          INT                NOT NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_booking_extensions_created_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_booking_extensions PRIMARY KEY (extension_id)
);
GO

-- ---------- soft_holds — Giữ chỗ tạm thời (2 phút) ----------
IF OBJECT_ID('dbo.soft_holds','U') IS NULL
CREATE TABLE dbo.soft_holds (
    soft_hold_id                 INT                IDENTITY(1,1) NOT NULL,
    account_id                   INT                NOT NULL,
    court_id                     INT                NOT NULL,
    booking_date                 DATE               NOT NULL,
    start_time                   TIME               NOT NULL,
    end_time                     TIME               NOT NULL,
    created_at                   DATETIME           NOT NULL CONSTRAINT df_soft_holds_created_at DEFAULT (getdate()),
    CONSTRAINT pk_soft_holds PRIMARY KEY (soft_hold_id)
);
GO

-- ---------- court_charge_segments — Chi tiết tính tiền sân theo khung giờ đèn ----------
IF OBJECT_ID('dbo.court_charge_segments','U') IS NULL
CREATE TABLE dbo.court_charge_segments (
    segment_id                   INT                IDENTITY(1,1) NOT NULL,
    invoice_id                   INT                NOT NULL,
    booking_id                   INT                NOT NULL,
    segment_order                INT                NOT NULL,
    start_at                     DATETIME2          NOT NULL,
    end_at                       DATETIME2          NOT NULL,
    duration_minutes             INT                NOT NULL,
    rate_type                    NVARCHAR(30)       NOT NULL,
    hourly_rate                  DECIMAL(18,2)      NOT NULL,
    amount                       DECIMAL(18,2)      NOT NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_court_charge_segments_created_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_court_charge_segments PRIMARY KEY (segment_id)
);
GO

-- ---------- customer_reputation_history — Lịch sử điểm uy tín khách hàng ----------
IF OBJECT_ID('dbo.customer_reputation_history','U') IS NULL
CREATE TABLE dbo.customer_reputation_history (
    reputation_history_id        BIGINT             IDENTITY(1,1) NOT NULL,
    account_id                   INT                NOT NULL,
    booking_id                   INT                NULL,
    action_type                  NVARCHAR(30)       NOT NULL,
    score_delta                  INT                NOT NULL,
    score_before                 INT                NOT NULL,
    score_after                  INT                NOT NULL,
    reason                       NVARCHAR(255)      NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_customer_reputation_history_created_at DEFAULT (sysutcdatetime()),
    created_by                   INT                NULL,
    ip_address                   NVARCHAR(50)       NULL,
    CONSTRAINT pk_customer_reputation_history PRIMARY KEY (reputation_history_id)
);
GO

-- ============================================================================
-- §5. HOÁ ĐƠN & THANH TOÁN
-- ============================================================================

-- ---------- invoices — Hoá đơn ----------
IF OBJECT_ID('dbo.invoices','U') IS NULL
CREATE TABLE dbo.invoices (
    invoice_id                   INT                IDENTITY(1,1) NOT NULL,
    booking_id                   INT                NULL,
    customer_account_id          INT                NULL,
    staff_account_id             INT                NULL,
    issued_at                    DATETIME           NULL CONSTRAINT df_invoices_issued_at DEFAULT (getdate()),
    court_total                  DECIMAL(18,2)      NULL CONSTRAINT df_invoices_court_total DEFAULT ((0)),
    service_total                DECIMAL(18,2)      NULL CONSTRAINT df_invoices_service_total DEFAULT ((0)),
    parking_fee                  DECIMAL(18,2)      NULL CONSTRAINT df_invoices_parking_fee DEFAULT ((0)),
    promotion_id                 INT                NULL,
    discount_amount              DECIMAL(18,2)      NULL CONSTRAINT df_invoices_discount_amount DEFAULT ((0)),
    grand_total                  DECIMAL(18,2)      NULL,
    payment_method               NVARCHAR(50)       NULL,
    payment_status               NVARCHAR(50)       NULL,
    invoice_type                 NVARCHAR(50)       NULL CONSTRAINT df_invoices_invoice_type DEFAULT (N'MAIN'),
    parent_invoice_id            INT                NULL,
    payment_reference            NVARCHAR(50)       NULL,
    note                         NVARCHAR(500)      NULL,
    is_deleted                   BIT                NULL CONSTRAINT df_invoices_is_deleted DEFAULT ((0)),
    CONSTRAINT pk_invoices PRIMARY KEY (invoice_id)
);
GO

-- ---------- invoice_items — Chi tiết hoá đơn ----------
IF OBJECT_ID('dbo.invoice_items','U') IS NULL
CREATE TABLE dbo.invoice_items (
    invoice_item_id              INT                IDENTITY(1,1) NOT NULL,
    invoice_id                   INT                NULL,
    product_id                   INT                NULL,
    quantity                     INT                NOT NULL,
    unit_price_at_sale           DECIMAL(18,2)      NULL,
    line_total                   DECIMAL(18,2)      NULL,
    CONSTRAINT pk_invoice_items PRIMARY KEY (invoice_item_id)
);
GO

-- ---------- refunds — Yêu cầu hoàn tiền ----------
IF OBJECT_ID('dbo.refunds','U') IS NULL
CREATE TABLE dbo.refunds (
    refund_id                    INT                IDENTITY(1,1) NOT NULL,
    invoice_id                   INT                NOT NULL,
    booking_id                   INT                NULL,
    account_id                   INT                NOT NULL,
    facility_id                  INT                NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_refunds_status DEFAULT (N'Chờ xử lý'),
    reason                       NVARCHAR(255)      NULL,
    customer_note                NVARCHAR(500)      NULL,
    reject_reason                NVARCHAR(500)      NULL,
    -- Số tiền
    paid_amount                  DECIMAL(18,2)      NULL,
    requested_amount             DECIMAL(18,2)      NULL,
    approved_amount              DECIMAL(18,2)      NULL,
    refunded_amount              DECIMAL(18,2)      NULL,
    -- Tài khoản nhận tiền
    receiving_bank_name          NVARCHAR(100)      NULL,
    receiving_account_number     NVARCHAR(30)       NULL,
    receiving_account_holder     NVARCHAR(100)      NULL,
    receiving_qr_path            NVARCHAR(500)      NULL,
    -- Xử lý
    approver_account_id          INT                NULL,
    processor_account_id         INT                NULL,
    processing_note              NVARCHAR(500)      NULL,
    refund_transaction_code      NVARCHAR(100)      NULL,
    note                         NVARCHAR(255)      NULL,
    requested_at                 DATETIME           NULL CONSTRAINT df_refunds_requested_at DEFAULT (getdate()),
    approved_at                  DATETIME2          NULL,
    processed_at                 DATETIME           NULL,
    refunded_at                  DATETIME           NULL,
    completed_at                 DATETIME2          NULL,
    updated_at                   DATETIME2          NOT NULL CONSTRAINT df_refunds_updated_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_refunds PRIMARY KEY (refund_id)
);
GO

-- ---------- payos_payment_attempts — Lần tạo link thanh toán PayOS ----------
IF OBJECT_ID('dbo.payos_payment_attempts','U') IS NULL
CREATE TABLE dbo.payos_payment_attempts (
    attempt_id                   BIGINT             IDENTITY(1,1) NOT NULL,
    invoice_id                   INT                NOT NULL,
    booking_id                   INT                NOT NULL,
    facility_id                  INT                NOT NULL,
    order_code                   BIGINT             NOT NULL,
    payment_link_id              NVARCHAR(100)      NULL,
    checkout_url                 NVARCHAR(1000)     NULL,
    qr_code                      NVARCHAR(MAX)      NULL,
    status                       NVARCHAR(30)       NOT NULL,
    amount                       DECIMAL(18,2)      NOT NULL,
    description                  NVARCHAR(100)      NOT NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_payos_payment_attempts_created_at DEFAULT (sysutcdatetime()),
    paid_at                      DATETIME2          NULL,
    cancelled_at                 DATETIME2          NULL,
    last_checked_at              DATETIME2          NULL,
    failure_reason               NVARCHAR(500)      NULL,
    CONSTRAINT pk_payos_payment_attempts PRIMARY KEY (attempt_id)
);
GO

-- ---------- bill_split_groups — Nhóm chia tiền (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.bill_split_groups','U') IS NULL
CREATE TABLE dbo.bill_split_groups (
    split_group_id               INT                IDENTITY(1,1) NOT NULL,
    invoice_id                   INT                NOT NULL,
    booking_id                   INT                NOT NULL,
    created_by_account_id        INT                NOT NULL,
    split_type                   NVARCHAR(20)       NOT NULL,
    total_amount                 DECIMAL(18,2)      NOT NULL,
    status                       NVARCHAR(20)       NOT NULL CONSTRAINT df_bill_split_groups_status DEFAULT (N'DRAFT'),
    expires_at                   DATETIME           NULL,
    created_at                   DATETIME           NOT NULL CONSTRAINT df_bill_split_groups_created_at DEFAULT (getdate()),
    updated_at                   DATETIME           NOT NULL CONSTRAINT df_bill_split_groups_updated_at DEFAULT (getdate()),
    CONSTRAINT pk_bill_split_groups PRIMARY KEY (split_group_id)
);
GO

-- ---------- bill_split_shares — Phần chia của từng người (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.bill_split_shares','U') IS NULL
CREATE TABLE dbo.bill_split_shares (
    share_id                     INT                IDENTITY(1,1) NOT NULL,
    split_group_id               INT                NOT NULL,
    account_id                   INT                NULL,
    display_name                 NVARCHAR(100)      NOT NULL,
    share_token                  CHAR(43)           NOT NULL,
    amount                       DECIMAL(18,2)      NOT NULL,
    status                       NVARCHAR(20)       NOT NULL CONSTRAINT df_bill_split_shares_status DEFAULT (N'PENDING'),
    payment_method               NVARCHAR(30)       NULL,
    payment_transaction_id       NVARCHAR(100)      NULL,
    payer_account_id             INT                NULL,
    paid_at                      DATETIME           NULL,
    confirmed_by_staff_id        INT                NULL,
    created_at                   DATETIME           NOT NULL CONSTRAINT df_bill_split_shares_created_at DEFAULT (getdate()),
    updated_at                   DATETIME           NOT NULL CONSTRAINT df_bill_split_shares_updated_at DEFAULT (getdate()),
    CONSTRAINT pk_bill_split_shares PRIMARY KEY (share_id)
);
GO

-- ============================================================================
-- §6. SẢN PHẨM / DỊCH VỤ & KHUYẾN MÃI
-- ============================================================================

-- ---------- products_services — Sản phẩm & dịch vụ bán tại cơ sở ----------
IF OBJECT_ID('dbo.products_services','U') IS NULL
CREATE TABLE dbo.products_services (
    product_id                   INT                IDENTITY(1,1) NOT NULL,
    category_id                  INT                NOT NULL,
    facility_id                  INT                NOT NULL,
    product_name                 NVARCHAR(100)      NOT NULL,
    sku_code                     NVARCHAR(50)       NULL,
    unit_price                   DECIMAL(18,2)      NULL,
    cost_price                   DECIMAL(18,2)      NULL,
    unit_of_measure              NVARCHAR(20)       NULL,
    stock_quantity               INT                NULL CONSTRAINT df_products_services_stock_quantity DEFAULT ((0)),
    description                  NVARCHAR(255)      NULL,
    image_path                   NVARCHAR(500)      NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_products_services_status DEFAULT (N'Đang kinh doanh'),
    is_deleted                   BIT                NULL CONSTRAINT df_products_services_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_products_services PRIMARY KEY (product_id)
);
GO

-- ---------- promotions — Khuyến mãi ----------
IF OBJECT_ID('dbo.promotions','U') IS NULL
CREATE TABLE dbo.promotions (
    promotion_id                 INT                IDENTITY(1,1) NOT NULL,
    promo_code                   VARCHAR(50)        NOT NULL,
    description                  NVARCHAR(255)      NULL,
    discount_type                NVARCHAR(20)       NOT NULL,
    discount_value               DECIMAL(18,2)      NULL,
    min_order_amount             DECIMAL(18,2)      NULL CONSTRAINT df_promotions_min_order_amount DEFAULT ((0)),
    max_discount_amount          DECIMAL(18,2)      NULL CONSTRAINT df_promotions_max_discount_amount DEFAULT ((0)),
    start_date                   DATE               NOT NULL,
    end_date                     DATE               NOT NULL,
    max_usage_count              INT                NULL,
    used_count                   INT                NULL CONSTRAINT df_promotions_used_count DEFAULT ((0)),
    facility_id                  INT                NULL,
    is_public                    BIT                NOT NULL CONSTRAINT df_promotions_is_public DEFAULT ((1)),
    status                       NVARCHAR(20)       NULL CONSTRAINT df_promotions_status DEFAULT (N'Hoạt động'),
    is_deleted                   BIT                NULL CONSTRAINT df_promotions_is_deleted DEFAULT ((0)),
    CONSTRAINT pk_promotions PRIMARY KEY (promotion_id)
);
GO

-- ---------- promotion_images — Ảnh của chương trình khuyến mãi ----------
IF OBJECT_ID('dbo.promotion_images','U') IS NULL
CREATE TABLE dbo.promotion_images (
    image_id                     INT                IDENTITY(1,1) NOT NULL,
    promotion_id                 INT                NOT NULL,
    file_path                    NVARCHAR(500)      NOT NULL,
    original_file_name           NVARCHAR(255)      NULL,
    mime_type                    NVARCHAR(100)      NULL,
    file_size                    BIGINT             NULL,
    width                        INT                NULL,
    height                       INT                NULL,
    display_order                INT                NOT NULL CONSTRAINT df_promotion_images_display_order DEFAULT ((0)),
    is_cover                     BIT                NOT NULL CONSTRAINT df_promotion_images_is_cover DEFAULT ((0)),
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_promotion_images_created_at DEFAULT (sysutcdatetime()),
    updated_at                   DATETIME2          NULL,
    CONSTRAINT pk_promotion_images PRIMARY KEY (image_id)
);
GO

-- ---------- promotion_usages — Lịch sử sử dụng khuyến mãi ----------
IF OBJECT_ID('dbo.promotion_usages','U') IS NULL
CREATE TABLE dbo.promotion_usages (
    usage_id                     INT                IDENTITY(1,1) NOT NULL,
    promotion_id                 INT                NOT NULL,
    account_id                   INT                NOT NULL,
    booking_id                   INT                NULL,
    discount_amount              DECIMAL(18,2)      NOT NULL CONSTRAINT df_promotion_usages_discount_amount DEFAULT ((0)),
    used_at                      DATETIME           NOT NULL CONSTRAINT df_promotion_usages_used_at DEFAULT (getdate()),
    CONSTRAINT pk_promotion_usages PRIMARY KEY (usage_id)
);
GO

-- ============================================================================
-- §7. GHÉP KÈO, ĐỘI NHÓM & ĐÁNH GIÁ
-- ============================================================================

-- ---------- matches — Kèo ghép người chơi ----------
IF OBJECT_ID('dbo.matches','U') IS NULL
CREATE TABLE dbo.matches (
    match_id                     INT                IDENTITY(1,1) NOT NULL,
    booking_id                   INT                NULL,
    creator_account_id           INT                NULL,
    creator_team_id              INT                NULL,
    sport_id                     INT                NULL,
    description                  NVARCHAR(MAX)      NULL,
    skill_level                  NVARCHAR(50)       NULL,
    needed_player_count          INT                NULL,
    approval_mode                NVARCHAR(20)       NULL,
    status                       NVARCHAR(50)       NULL CONSTRAINT df_matches_status DEFAULT (N'Đang tìm'),
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_matches_created_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_matches PRIMARY KEY (match_id)
);
GO

-- ---------- match_participants — Người tham gia kèo ----------
IF OBJECT_ID('dbo.match_participants','U') IS NULL
CREATE TABLE dbo.match_participants (
    participant_id               INT                IDENTITY(1,1) NOT NULL,
    match_id                     INT                NULL,
    participant_account_id       INT                NULL,
    participant_team_id          INT                NULL,
    participation_status         NVARCHAR(50)       NULL CONSTRAINT df_match_participants_participation_status DEFAULT (N'Chờ duyệt'),
    participation_position       NVARCHAR(50)       NULL,
    CONSTRAINT pk_match_participants PRIMARY KEY (participant_id)
);
GO

-- ---------- favorite_sports — Môn thể thao yêu thích của tài khoản ----------
IF OBJECT_ID('dbo.favorite_sports','U') IS NULL
CREATE TABLE dbo.favorite_sports (
    account_id                   INT                NOT NULL,
    sport_id                     INT                NOT NULL,
    added_at                     DATETIME           NULL CONSTRAINT df_favorite_sports_added_at DEFAULT (getdate()),
    CONSTRAINT pk_favorite_sports PRIMARY KEY (account_id, sport_id)
);
GO

-- ---------- reviews — Đánh giá sau khi chơi (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.reviews','U') IS NULL
CREATE TABLE dbo.reviews (
    review_id                    INT                IDENTITY(1,1) NOT NULL,
    booking_id                   INT                NULL,
    reviewer_account_id          INT                NULL,
    reviewed_account_id          INT                NULL,
    rating                       INT                NULL,
    comment                      NVARCHAR(MAX)      NULL,
    created_at                   DATETIME           NULL CONSTRAINT df_reviews_created_at DEFAULT (getdate()),
    CONSTRAINT pk_reviews PRIMARY KEY (review_id)
);
GO

-- ---------- teams — Đội nhóm người chơi (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.teams','U') IS NULL
CREATE TABLE dbo.teams (
    team_id                      INT                IDENTITY(1,1) NOT NULL,
    team_name                    NVARCHAR(50)       NOT NULL,
    description                  NVARCHAR(255)      NULL,
    sport_id                     INT                NOT NULL,
    captain_account_id           INT                NOT NULL,
    location_text                NVARCHAR(255)      NULL,
    avatar_path                  NVARCHAR(500)      NULL,
    cover_image_path             NVARCHAR(500)      NULL,
    max_members                  INT                NOT NULL,
    status                       VARCHAR(30)        NOT NULL CONSTRAINT df_teams_status DEFAULT ('ACTIVE'),
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_teams_created_at DEFAULT (sysutcdatetime()),
    updated_at                   DATETIME2          NULL,
    is_deleted                   BIT                NOT NULL CONSTRAINT df_teams_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME2          NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_teams PRIMARY KEY (team_id)
);
GO

-- ---------- team_members — Thành viên đội (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.team_members','U') IS NULL
CREATE TABLE dbo.team_members (
    team_member_id               INT                IDENTITY(1,1) NOT NULL,
    team_id                      INT                NOT NULL,
    account_id                   INT                NOT NULL,
    member_role                  VARCHAR(30)        NOT NULL,
    member_status                VARCHAR(30)        NOT NULL CONSTRAINT df_team_members_member_status DEFAULT ('ACTIVE'),
    joined_at                    DATETIME2          NOT NULL CONSTRAINT df_team_members_joined_at DEFAULT (sysutcdatetime()),
    left_at                      DATETIME2          NULL,
    added_by                     INT                NULL,
    CONSTRAINT pk_team_members PRIMARY KEY (team_member_id)
);
GO

-- ---------- team_invitations — Lời mời vào đội (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.team_invitations','U') IS NULL
CREATE TABLE dbo.team_invitations (
    invitation_id                INT                IDENTITY(1,1) NOT NULL,
    team_id                      INT                NOT NULL,
    invited_account_id           INT                NOT NULL,
    invited_by_account_id        INT                NOT NULL,
    proposed_role                VARCHAR(30)        NOT NULL CONSTRAINT df_team_invitations_proposed_role DEFAULT ('MEMBER'),
    status                       VARCHAR(30)        NOT NULL CONSTRAINT df_team_invitations_status DEFAULT ('PENDING'),
    message                      NVARCHAR(255)      NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_team_invitations_created_at DEFAULT (sysutcdatetime()),
    expires_at                   DATETIME2          NULL,
    responded_at                 DATETIME2          NULL,
    CONSTRAINT pk_team_invitations PRIMARY KEY (invitation_id)
);
GO

-- ---------- team_join_requests — Yêu cầu xin vào đội (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.team_join_requests','U') IS NULL
CREATE TABLE dbo.team_join_requests (
    join_request_id              INT                IDENTITY(1,1) NOT NULL,
    team_id                      INT                NOT NULL,
    requester_account_id         INT                NOT NULL,
    message                      NVARCHAR(255)      NULL,
    status                       VARCHAR(30)        NOT NULL CONSTRAINT df_team_join_requests_status DEFAULT ('PENDING'),
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_team_join_requests_created_at DEFAULT (sysutcdatetime()),
    reviewed_at                  DATETIME2          NULL,
    reviewed_by_account_id       INT                NULL,
    CONSTRAINT pk_team_join_requests PRIMARY KEY (join_request_id)
);
GO

-- ============================================================================
-- §8. NHÂN SỰ & VẬN HÀNH
-- ============================================================================

-- ---------- work_shifts — Ca làm việc (chỉ áp dụng cho role 4 = Lễ tân) ----------
IF OBJECT_ID('dbo.work_shifts','U') IS NULL
CREATE TABLE dbo.work_shifts (
    work_shift_id                INT                IDENTITY(1,1) NOT NULL,
    account_id                   INT                NOT NULL,
    facility_id                  INT                NOT NULL,
    work_date                    DATE               NOT NULL,
    start_time                   TIME               NOT NULL,
    end_time                     TIME               NOT NULL,
    day_of_week                  INT                NULL,
    shift_name                   NVARCHAR(50)       NULL,
    position                     NVARCHAR(50)       NULL,
    break_minutes                INT                NOT NULL CONSTRAINT df_work_shifts_break_minutes DEFAULT ((0)),
    status                       VARCHAR(30)        NOT NULL CONSTRAINT df_work_shifts_status DEFAULT ('Draft'),
    is_published                 BIT                NOT NULL CONSTRAINT df_work_shifts_is_published DEFAULT ((0)),
    is_custom_time               BIT                NOT NULL CONSTRAINT df_work_shifts_is_custom_time DEFAULT ((0)),
    custom_time_reason           NVARCHAR(255)      NULL,
    actual_check_in_at           DATETIME           NULL,
    actual_check_out_at          DATETIME           NULL,
    note                         NVARCHAR(255)      NULL,
    is_deleted                   BIT                NOT NULL CONSTRAINT df_work_shifts_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_work_shifts PRIMARY KEY (work_shift_id)
);
GO

-- ---------- work_shift_audits — Nhật ký thay đổi ca làm ----------
IF OBJECT_ID('dbo.work_shift_audits','U') IS NULL
CREATE TABLE dbo.work_shift_audits (
    audit_id                     INT                IDENTITY(1,1) NOT NULL,
    work_shift_id                INT                NOT NULL,
    action                       VARCHAR(50)        NOT NULL,
    performed_by                 INT                NOT NULL,
    performed_at                 DATETIME           NULL CONSTRAINT df_work_shift_audits_performed_at DEFAULT (getdate()),
    old_value                    NVARCHAR(MAX)      NULL,
    new_value                    NVARCHAR(MAX)      NULL,
    reason                       NVARCHAR(255)      NULL,
    CONSTRAINT pk_work_shift_audits PRIMARY KEY (audit_id)
);
GO

-- ---------- work_shift_swap_requests — Yêu cầu đổi ca ----------
IF OBJECT_ID('dbo.work_shift_swap_requests','U') IS NULL
CREATE TABLE dbo.work_shift_swap_requests (
    swap_request_id              INT                IDENTITY(1,1) NOT NULL,
    requester_account_id         INT                NOT NULL,
    requester_work_shift_id      INT                NOT NULL,
    target_account_id            INT                NOT NULL,
    target_work_shift_id         INT                NULL,
    reason                       NVARCHAR(255)      NULL,
    status                       VARCHAR(30)        NOT NULL CONSTRAINT df_work_shift_swap_requests_status DEFAULT ('ChoXacNhan'),
    approver_account_id          INT                NULL,
    requested_at                 DATETIME           NULL CONSTRAINT df_work_shift_swap_requests_requested_at DEFAULT (getdate()),
    approved_at                  DATETIME           NULL,
    manager_note                 NVARCHAR(255)      NULL,
    CONSTRAINT pk_work_shift_swap_requests PRIMARY KEY (swap_request_id)
);
GO

-- ---------- qr_requests — Yêu cầu gọi nhân viên / gọi món qua QR (KHÔI PHỤC) ----------
IF OBJECT_ID('dbo.qr_requests','U') IS NULL
CREATE TABLE dbo.qr_requests (
    request_id                   INT                IDENTITY(1,1) NOT NULL,
    court_id                     INT                NOT NULL,
    facility_id                  INT                NOT NULL,
    guest_token                  VARCHAR(64)        NOT NULL,
    customer_account_id          INT                NULL,
    request_type                 VARCHAR(20)        NOT NULL,
    items_json                   NVARCHAR(MAX)      NULL,
    note                         NVARCHAR(255)      NULL,
    status                       VARCHAR(20)        NOT NULL CONSTRAINT df_qr_requests_status DEFAULT ('NEW'),
    handled_by_staff_id          INT                NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_qr_requests_created_at DEFAULT (sysdatetime()),
    updated_at                   DATETIME2          NOT NULL CONSTRAINT df_qr_requests_updated_at DEFAULT (sysdatetime()),
    CONSTRAINT pk_qr_requests PRIMARY KEY (request_id)
);
GO

-- ============================================================================
-- §9. THÔNG BÁO, KIỂM TOÁN & THÙNG RÁC
-- ============================================================================

-- ---------- notifications — Thông báo ----------
IF OBJECT_ID('dbo.notifications','U') IS NULL
CREATE TABLE dbo.notifications (
    notification_id              INT                IDENTITY(1,1) NOT NULL,
    account_id                   INT                NOT NULL,
    title                        NVARCHAR(200)      NOT NULL,
    content                      NVARCHAR(MAX)      NULL,
    notification_type            NVARCHAR(50)       NULL,
    reference_id                 INT                NULL,
    link_url                     VARCHAR(500)       NULL,
    is_read                      BIT                NULL CONSTRAINT df_notifications_is_read DEFAULT ((0)),
    sent_at                      DATETIME           NULL CONSTRAINT df_notifications_sent_at DEFAULT (getdate()),
    is_deleted                   BIT                NOT NULL CONSTRAINT df_notifications_is_deleted DEFAULT ((0)),
    deleted_at                   DATETIME           NULL,
    deleted_by                   INT                NULL,
    CONSTRAINT pk_notifications PRIMARY KEY (notification_id)
);
GO

-- ---------- audit_logs — Nhật ký kiểm toán ----------
IF OBJECT_ID('dbo.audit_logs','U') IS NULL
CREATE TABLE dbo.audit_logs (
    audit_log_id                 BIGINT             IDENTITY(1,1) NOT NULL,
    actor_account_id             INT                NULL,
    actor_name                   NVARCHAR(255)      NOT NULL,
    actor_role_id                INT                NOT NULL,
    facility_id                  INT                NULL,
    action                       NVARCHAR(100)      NOT NULL,
    entity_type                  NVARCHAR(100)      NOT NULL,
    entity_id                    NVARCHAR(50)       NULL,
    entity_name                  NVARCHAR(500)      NULL,
    details                      NVARCHAR(MAX)      NULL,
    ip_address                   NVARCHAR(50)       NULL,
    created_at                   DATETIME2          NOT NULL CONSTRAINT df_audit_logs_created_at DEFAULT (sysutcdatetime()),
    CONSTRAINT pk_audit_logs PRIMARY KEY (audit_log_id)
);
GO

-- ---------- admin_trash — Thùng rác quản trị ----------
IF OBJECT_ID('dbo.admin_trash','U') IS NULL
CREATE TABLE dbo.admin_trash (
    trash_id                     INT                IDENTITY(1,1) NOT NULL,
    entity_type                  NVARCHAR(100)      NOT NULL,
    entity_id                    INT                NOT NULL,
    display_name                 NVARCHAR(255)      NULL,
    source_table                 NVARCHAR(100)      NOT NULL,
    old_status                   NVARCHAR(100)      NULL,
    reason                       NVARCHAR(500)      NULL,
    deleted_by                   INT                NULL,
    deleted_at                   DATETIME2          NOT NULL CONSTRAINT df_admin_trash_deleted_at DEFAULT (sysutcdatetime()),
    is_restored                  BIT                NOT NULL CONSTRAINT df_admin_trash_is_restored DEFAULT ((0)),
    restored_by                  INT                NULL,
    restored_at                  DATETIME2          NULL,
    CONSTRAINT pk_admin_trash PRIMARY KEY (trash_id)
);
GO

-- ============================================================================
-- §10. KHOÁ NGOẠI
-- Tất cả FK dùng NO ACTION (mặc định) — không suy đoán CASCADE.
-- ============================================================================

-- accounts
ALTER TABLE dbo.accounts ADD CONSTRAINT fk_accounts_role          FOREIGN KEY (role_id)           REFERENCES dbo.roles(role_id);
ALTER TABLE dbo.accounts ADD CONSTRAINT fk_accounts_facility      FOREIGN KEY (facility_id)       REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.accounts ADD CONSTRAINT fk_accounts_favorite_sport FOREIGN KEY (favorite_sport_id) REFERENCES dbo.sports(sport_id);
ALTER TABLE dbo.accounts ADD CONSTRAINT fk_accounts_deleted_by    FOREIGN KEY (deleted_by)        REFERENCES dbo.accounts(account_id);
GO

-- facilities
ALTER TABLE dbo.facilities ADD CONSTRAINT fk_facilities_manager    FOREIGN KEY (manager_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.facilities ADD CONSTRAINT fk_facilities_deleted_by FOREIGN KEY (deleted_by)         REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.facility_capabilities ADD CONSTRAINT fk_facility_capabilities_facility    FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.facility_capabilities ADD CONSTRAINT fk_facility_capabilities_approved_by FOREIGN KEY (approved_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.facility_bank_accounts ADD CONSTRAINT fk_facility_bank_accounts_facility  FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
GO

-- courts
ALTER TABLE dbo.court_types ADD CONSTRAINT fk_court_types_sport      FOREIGN KEY (sport_id)    REFERENCES dbo.sports(sport_id);
ALTER TABLE dbo.court_types ADD CONSTRAINT fk_court_types_facility   FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.court_types ADD CONSTRAINT fk_court_types_deleted_by FOREIGN KEY (deleted_by)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.courts      ADD CONSTRAINT fk_courts_court_type      FOREIGN KEY (court_type_id) REFERENCES dbo.court_types(court_type_id);
ALTER TABLE dbo.courts      ADD CONSTRAINT fk_courts_facility        FOREIGN KEY (facility_id)   REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.courts      ADD CONSTRAINT fk_courts_deleted_by      FOREIGN KEY (deleted_by)    REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.court_qr_codes ADD CONSTRAINT fk_court_qr_codes_court      FOREIGN KEY (court_id)   REFERENCES dbo.courts(court_id);
ALTER TABLE dbo.court_qr_codes ADD CONSTRAINT fk_court_qr_codes_created_by FOREIGN KEY (created_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.court_qr_codes ADD CONSTRAINT fk_court_qr_codes_updated_by FOREIGN KEY (updated_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.court_qr_token_history ADD CONSTRAINT fk_court_qr_token_history_qr         FOREIGN KEY (court_qr_id) REFERENCES dbo.court_qr_codes(court_qr_id);
ALTER TABLE dbo.court_qr_token_history ADD CONSTRAINT fk_court_qr_token_history_court      FOREIGN KEY (court_id)    REFERENCES dbo.courts(court_id);
ALTER TABLE dbo.court_qr_token_history ADD CONSTRAINT fk_court_qr_token_history_revoked_by FOREIGN KEY (revoked_by)  REFERENCES dbo.accounts(account_id);
GO

-- bookings
ALTER TABLE dbo.bookings ADD CONSTRAINT fk_bookings_account      FOREIGN KEY (account_id)   REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bookings ADD CONSTRAINT fk_bookings_court        FOREIGN KEY (court_id)     REFERENCES dbo.courts(court_id);
ALTER TABLE dbo.bookings ADD CONSTRAINT fk_bookings_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bookings ADD CONSTRAINT fk_bookings_cancelled_by FOREIGN KEY (cancelled_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bookings ADD CONSTRAINT fk_bookings_deleted_by   FOREIGN KEY (deleted_by)   REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.booking_services ADD CONSTRAINT fk_booking_services_booking      FOREIGN KEY (booking_id)   REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.booking_services ADD CONSTRAINT fk_booking_services_product      FOREIGN KEY (product_id)   REFERENCES dbo.products_services(product_id);
ALTER TABLE dbo.booking_services ADD CONSTRAINT fk_booking_services_delivered_by FOREIGN KEY (delivered_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.booking_extensions ADD CONSTRAINT fk_booking_extensions_booking  FOREIGN KEY (booking_id)          REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.booking_extensions ADD CONSTRAINT fk_booking_extensions_operator FOREIGN KEY (operator_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.soft_holds ADD CONSTRAINT fk_soft_holds_account FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.soft_holds ADD CONSTRAINT fk_soft_holds_court   FOREIGN KEY (court_id)   REFERENCES dbo.courts(court_id);
GO

ALTER TABLE dbo.court_charge_segments ADD CONSTRAINT fk_court_charge_segments_invoice FOREIGN KEY (invoice_id) REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.court_charge_segments ADD CONSTRAINT fk_court_charge_segments_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.customer_reputation_history ADD CONSTRAINT fk_customer_reputation_history_account    FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.customer_reputation_history ADD CONSTRAINT fk_customer_reputation_history_booking    FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.customer_reputation_history ADD CONSTRAINT fk_customer_reputation_history_created_by FOREIGN KEY (created_by) REFERENCES dbo.accounts(account_id);
GO

-- invoices
ALTER TABLE dbo.invoices ADD CONSTRAINT fk_invoices_booking   FOREIGN KEY (booking_id)          REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.invoices ADD CONSTRAINT fk_invoices_customer  FOREIGN KEY (customer_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.invoices ADD CONSTRAINT fk_invoices_staff     FOREIGN KEY (staff_account_id)    REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.invoices ADD CONSTRAINT fk_invoices_promotion FOREIGN KEY (promotion_id)        REFERENCES dbo.promotions(promotion_id);
ALTER TABLE dbo.invoices ADD CONSTRAINT fk_invoices_parent    FOREIGN KEY (parent_invoice_id)   REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.invoice_items ADD CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.invoice_items ADD CONSTRAINT fk_invoice_items_product FOREIGN KEY (product_id) REFERENCES dbo.products_services(product_id);
GO

ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_invoice   FOREIGN KEY (invoice_id)           REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_booking   FOREIGN KEY (booking_id)           REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_account   FOREIGN KEY (account_id)           REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_facility  FOREIGN KEY (facility_id)          REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_approver  FOREIGN KEY (approver_account_id)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.refunds ADD CONSTRAINT fk_refunds_processor FOREIGN KEY (processor_account_id) REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.payos_payment_attempts ADD CONSTRAINT fk_payos_payment_attempts_invoice  FOREIGN KEY (invoice_id)  REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.payos_payment_attempts ADD CONSTRAINT fk_payos_payment_attempts_booking  FOREIGN KEY (booking_id)  REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.payos_payment_attempts ADD CONSTRAINT fk_payos_payment_attempts_facility FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
GO

ALTER TABLE dbo.bill_split_groups ADD CONSTRAINT fk_bill_split_groups_invoice    FOREIGN KEY (invoice_id)            REFERENCES dbo.invoices(invoice_id);
ALTER TABLE dbo.bill_split_groups ADD CONSTRAINT fk_bill_split_groups_booking    FOREIGN KEY (booking_id)            REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.bill_split_groups ADD CONSTRAINT fk_bill_split_groups_created_by FOREIGN KEY (created_by_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bill_split_shares ADD CONSTRAINT fk_bill_split_shares_group        FOREIGN KEY (split_group_id)        REFERENCES dbo.bill_split_groups(split_group_id);
ALTER TABLE dbo.bill_split_shares ADD CONSTRAINT fk_bill_split_shares_account      FOREIGN KEY (account_id)            REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bill_split_shares ADD CONSTRAINT fk_bill_split_shares_payer        FOREIGN KEY (payer_account_id)      REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.bill_split_shares ADD CONSTRAINT fk_bill_split_shares_confirmed_by FOREIGN KEY (confirmed_by_staff_id) REFERENCES dbo.accounts(account_id);
GO

-- products & promotions
ALTER TABLE dbo.products_services ADD CONSTRAINT fk_products_services_category   FOREIGN KEY (category_id) REFERENCES dbo.product_categories(category_id);
ALTER TABLE dbo.products_services ADD CONSTRAINT fk_products_services_facility   FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.products_services ADD CONSTRAINT fk_products_services_deleted_by FOREIGN KEY (deleted_by)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.promotions        ADD CONSTRAINT fk_promotions_facility          FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.promotion_images  ADD CONSTRAINT fk_promotion_images_promotion   FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(promotion_id);
ALTER TABLE dbo.promotion_usages  ADD CONSTRAINT fk_promotion_usages_promotion   FOREIGN KEY (promotion_id) REFERENCES dbo.promotions(promotion_id);
ALTER TABLE dbo.promotion_usages  ADD CONSTRAINT fk_promotion_usages_account     FOREIGN KEY (account_id)   REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.promotion_usages  ADD CONSTRAINT fk_promotion_usages_booking     FOREIGN KEY (booking_id)   REFERENCES dbo.bookings(booking_id);
GO

-- matches, teams, reviews
ALTER TABLE dbo.matches ADD CONSTRAINT fk_matches_booking      FOREIGN KEY (booking_id)         REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.matches ADD CONSTRAINT fk_matches_creator      FOREIGN KEY (creator_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.matches ADD CONSTRAINT fk_matches_creator_team FOREIGN KEY (creator_team_id)    REFERENCES dbo.teams(team_id);
ALTER TABLE dbo.matches ADD CONSTRAINT fk_matches_sport        FOREIGN KEY (sport_id)           REFERENCES dbo.sports(sport_id);
ALTER TABLE dbo.match_participants ADD CONSTRAINT fk_match_participants_match   FOREIGN KEY (match_id)               REFERENCES dbo.matches(match_id);
ALTER TABLE dbo.match_participants ADD CONSTRAINT fk_match_participants_account FOREIGN KEY (participant_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.match_participants ADD CONSTRAINT fk_match_participants_team    FOREIGN KEY (participant_team_id)    REFERENCES dbo.teams(team_id);
GO

ALTER TABLE dbo.favorite_sports ADD CONSTRAINT fk_favorite_sports_account FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.favorite_sports ADD CONSTRAINT fk_favorite_sports_sport   FOREIGN KEY (sport_id)   REFERENCES dbo.sports(sport_id);
ALTER TABLE dbo.reviews ADD CONSTRAINT fk_reviews_booking  FOREIGN KEY (booking_id)          REFERENCES dbo.bookings(booking_id);
ALTER TABLE dbo.reviews ADD CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.reviews ADD CONSTRAINT fk_reviews_reviewed FOREIGN KEY (reviewed_account_id) REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.teams ADD CONSTRAINT fk_teams_sport      FOREIGN KEY (sport_id)           REFERENCES dbo.sports(sport_id);
ALTER TABLE dbo.teams ADD CONSTRAINT fk_teams_captain    FOREIGN KEY (captain_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.teams ADD CONSTRAINT fk_teams_deleted_by FOREIGN KEY (deleted_by)         REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_members ADD CONSTRAINT fk_team_members_team     FOREIGN KEY (team_id)    REFERENCES dbo.teams(team_id);
ALTER TABLE dbo.team_members ADD CONSTRAINT fk_team_members_account  FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_members ADD CONSTRAINT fk_team_members_added_by FOREIGN KEY (added_by)   REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_invitations ADD CONSTRAINT fk_team_invitations_team       FOREIGN KEY (team_id)               REFERENCES dbo.teams(team_id);
ALTER TABLE dbo.team_invitations ADD CONSTRAINT fk_team_invitations_invited    FOREIGN KEY (invited_account_id)    REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_invitations ADD CONSTRAINT fk_team_invitations_invited_by FOREIGN KEY (invited_by_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_join_requests ADD CONSTRAINT fk_team_join_requests_team        FOREIGN KEY (team_id)                REFERENCES dbo.teams(team_id);
ALTER TABLE dbo.team_join_requests ADD CONSTRAINT fk_team_join_requests_requester   FOREIGN KEY (requester_account_id)   REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.team_join_requests ADD CONSTRAINT fk_team_join_requests_reviewed_by FOREIGN KEY (reviewed_by_account_id) REFERENCES dbo.accounts(account_id);
GO

-- work shifts & qr requests
ALTER TABLE dbo.work_shifts ADD CONSTRAINT fk_work_shifts_account    FOREIGN KEY (account_id)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.work_shifts ADD CONSTRAINT fk_work_shifts_facility   FOREIGN KEY (facility_id) REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.work_shifts ADD CONSTRAINT fk_work_shifts_deleted_by FOREIGN KEY (deleted_by)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.work_shift_audits ADD CONSTRAINT fk_work_shift_audits_shift        FOREIGN KEY (work_shift_id) REFERENCES dbo.work_shifts(work_shift_id);
ALTER TABLE dbo.work_shift_audits ADD CONSTRAINT fk_work_shift_audits_performed_by FOREIGN KEY (performed_by)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.work_shift_swap_requests ADD CONSTRAINT fk_work_shift_swap_requests_requester       FOREIGN KEY (requester_account_id)    REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.work_shift_swap_requests ADD CONSTRAINT fk_work_shift_swap_requests_requester_shift FOREIGN KEY (requester_work_shift_id) REFERENCES dbo.work_shifts(work_shift_id);
ALTER TABLE dbo.work_shift_swap_requests ADD CONSTRAINT fk_work_shift_swap_requests_target          FOREIGN KEY (target_account_id)       REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.work_shift_swap_requests ADD CONSTRAINT fk_work_shift_swap_requests_target_shift    FOREIGN KEY (target_work_shift_id)    REFERENCES dbo.work_shifts(work_shift_id);
ALTER TABLE dbo.work_shift_swap_requests ADD CONSTRAINT fk_work_shift_swap_requests_approver        FOREIGN KEY (approver_account_id)     REFERENCES dbo.accounts(account_id);
GO

ALTER TABLE dbo.qr_requests ADD CONSTRAINT fk_qr_requests_court    FOREIGN KEY (court_id)            REFERENCES dbo.courts(court_id);
ALTER TABLE dbo.qr_requests ADD CONSTRAINT fk_qr_requests_facility FOREIGN KEY (facility_id)         REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.qr_requests ADD CONSTRAINT fk_qr_requests_customer FOREIGN KEY (customer_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.qr_requests ADD CONSTRAINT fk_qr_requests_staff    FOREIGN KEY (handled_by_staff_id) REFERENCES dbo.accounts(account_id);
GO

-- notifications, audit, trash
ALTER TABLE dbo.notifications ADD CONSTRAINT fk_notifications_account    FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.notifications ADD CONSTRAINT fk_notifications_deleted_by FOREIGN KEY (deleted_by) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.audit_logs    ADD CONSTRAINT fk_audit_logs_actor         FOREIGN KEY (actor_account_id) REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.audit_logs    ADD CONSTRAINT fk_audit_logs_facility      FOREIGN KEY (facility_id)      REFERENCES dbo.facilities(facility_id);
ALTER TABLE dbo.admin_trash   ADD CONSTRAINT fk_admin_trash_deleted_by   FOREIGN KEY (deleted_by)  REFERENCES dbo.accounts(account_id);
ALTER TABLE dbo.admin_trash   ADD CONSTRAINT fk_admin_trash_restored_by  FOREIGN KEY (restored_by) REFERENCES dbo.accounts(account_id);
GO

-- ============================================================================
-- §11. CHECK CONSTRAINTS
-- ⚠️  Các chuỗi tiếng Việt dưới đây là GIÁ TRỊ DỮ LIỆU — KHÔNG dịch sang tiếng Anh.
-- ============================================================================

ALTER TABLE dbo.accounts ADD CONSTRAINT ck_accounts_height_cm     CHECK (height_cm IS NULL OR height_cm BETWEEN 50 AND 260);
ALTER TABLE dbo.accounts ADD CONSTRAINT ck_accounts_weight_kg     CHECK (weight_kg IS NULL OR weight_kg BETWEEN 20 AND 300);
ALTER TABLE dbo.accounts ADD CONSTRAINT ck_accounts_skill_level   CHECK (skill_level IS NULL OR skill_level IN (N'Mới chơi', N'Cơ bản', N'Trung bình', N'Khá', N'Nâng cao'));
ALTER TABLE dbo.accounts ADD CONSTRAINT ck_accounts_play_frequency CHECK (play_frequency IS NULL OR play_frequency IN (N'1 lần/tuần', N'2-3 lần/tuần', N'4+ lần/tuần', N'Không cố định'));
GO

ALTER TABLE dbo.court_charge_segments ADD CONSTRAINT ck_court_charge_segments_duration CHECK (duration_minutes > 0);
ALTER TABLE dbo.court_charge_segments ADD CONSTRAINT ck_court_charge_segments_amounts  CHECK (hourly_rate >= 0 AND amount >= 0);
ALTER TABLE dbo.court_charge_segments ADD CONSTRAINT ck_court_charge_segments_rate_type CHECK (rate_type IN (N'WITHOUT_LIGHT', N'WITH_LIGHT'));
GO

ALTER TABLE dbo.booking_services ADD CONSTRAINT ck_booking_services_status CHECK (status IN (N'Chờ chuẩn bị', N'Đã giao', N'Đã hủy'));
ALTER TABLE dbo.reviews          ADD CONSTRAINT ck_reviews_rating          CHECK (rating IS NULL OR rating BETWEEN 1 AND 5);
GO

-- ============================================================================
-- §12. CHỈ MỤC DUY NHẤT
-- LƯU Ý: các chỉ mục có WHERE (filtered unique index) BẮT BUỘC phải giữ mệnh đề lọc.
--        Bỏ WHERE ... IS NOT NULL sẽ khiến bản ghi thứ 2 có giá trị NULL bị chặn.
-- ============================================================================

CREATE UNIQUE INDEX uq_accounts_username    ON dbo.accounts (username)    WHERE username IS NOT NULL;
CREATE UNIQUE INDEX uq_accounts_email       ON dbo.accounts (email)       WHERE email IS NOT NULL;
CREATE UNIQUE INDEX uq_accounts_google_id   ON dbo.accounts (google_id)   WHERE google_id IS NOT NULL;
CREATE UNIQUE INDEX uq_accounts_facebook_id ON dbo.accounts (facebook_id) WHERE facebook_id IS NOT NULL;
GO

CREATE UNIQUE INDEX uq_facility_capabilities_facility_type ON dbo.facility_capabilities (facility_id, capability_type);
CREATE UNIQUE INDEX uq_court_qr_codes_court      ON dbo.court_qr_codes (court_id);
CREATE UNIQUE INDEX uq_court_qr_codes_token      ON dbo.court_qr_codes (token);
CREATE UNIQUE INDEX uq_court_qr_codes_short_code ON dbo.court_qr_codes (short_code) WHERE short_code IS NOT NULL;
CREATE UNIQUE INDEX uq_court_qr_token_history_token ON dbo.court_qr_token_history (token) WHERE token IS NOT NULL;
GO

-- SỬA LỖI V1: chỉ mục này ở V1 thiếu mệnh đề WHERE, khiến một lượt đặt sân không thể
-- vừa có hoá đơn MAIN vừa có hoá đơn SERVICE. Nguồn đúng: sql/migration_court_checkout.sql
CREATE UNIQUE INDEX uq_invoices_one_main_per_booking ON dbo.invoices (booking_id)
    WHERE booking_id IS NOT NULL AND invoice_type = N'MAIN';
GO

CREATE UNIQUE INDEX uq_court_charge_segments_invoice_order ON dbo.court_charge_segments (invoice_id, segment_order);
CREATE UNIQUE INDEX uq_customer_reputation_history_idem    ON dbo.customer_reputation_history (account_id, booking_id, action_type);
CREATE UNIQUE INDEX uq_payos_payment_attempts_order_code   ON dbo.payos_payment_attempts (order_code);
CREATE UNIQUE INDEX uq_bill_split_shares_token             ON dbo.bill_split_shares (share_token);
CREATE UNIQUE INDEX uq_promotions_promo_code               ON dbo.promotions (promo_code);
CREATE UNIQUE INDEX uq_promotion_images_one_cover          ON dbo.promotion_images (promotion_id) WHERE is_cover = 1;
CREATE UNIQUE INDEX uq_notifications_account_type_ref      ON dbo.notifications (account_id, notification_type, reference_id);
GO

CREATE UNIQUE INDEX uq_match_participants_active ON dbo.match_participants (match_id, participant_account_id)
    WHERE participation_status IN (N'Chờ duyệt', N'Đã tham gia');
CREATE UNIQUE INDEX uq_team_members_active ON dbo.team_members (team_id, account_id) WHERE member_status = 'ACTIVE';
GO

-- ============================================================================
-- §13. CHỈ MỤC TÌM KIẾM
-- ============================================================================

CREATE INDEX ix_audit_logs_actor       ON dbo.audit_logs (actor_account_id);
CREATE INDEX ix_audit_logs_facility    ON dbo.audit_logs (facility_id);
CREATE INDEX ix_audit_logs_created_at  ON dbo.audit_logs (created_at);
CREATE INDEX ix_audit_logs_entity_type ON dbo.audit_logs (entity_type);
GO

CREATE INDEX ix_facility_capabilities_facility ON dbo.facility_capabilities (facility_id);
CREATE INDEX ix_facility_capabilities_status   ON dbo.facility_capabilities (status);
GO

CREATE INDEX ix_bookings_payos_order_code ON dbo.bookings (payos_order_code);
CREATE INDEX ix_bookings_court_date       ON dbo.bookings (court_id, booking_date, status);
CREATE INDEX ix_bookings_account          ON dbo.bookings (account_id, booking_date);
CREATE INDEX ix_booking_services_booking  ON dbo.booking_services (booking_id);
CREATE INDEX ix_soft_holds_court_date     ON dbo.soft_holds (court_id, booking_date, created_at);
GO

CREATE INDEX ix_customer_reputation_history_account ON dbo.customer_reputation_history (account_id, created_at);
CREATE INDEX ix_customer_reputation_history_booking ON dbo.customer_reputation_history (booking_id);
GO

CREATE INDEX ix_invoices_parent_type   ON dbo.invoices (parent_invoice_id, invoice_type);
CREATE INDEX ix_refunds_facility       ON dbo.refunds (facility_id);
CREATE INDEX ix_refunds_booking        ON dbo.refunds (booking_id);
CREATE INDEX ix_refunds_status         ON dbo.refunds (status);
CREATE INDEX ix_payos_payment_attempts_invoice         ON dbo.payos_payment_attempts (invoice_id);
CREATE INDEX ix_payos_payment_attempts_payment_link_id ON dbo.payos_payment_attempts (payment_link_id);
CREATE INDEX ix_bill_split_shares_group ON dbo.bill_split_shares (split_group_id);
GO

CREATE INDEX ix_promotion_images_promotion       ON dbo.promotion_images (promotion_id, display_order);
CREATE INDEX ix_promotion_usages_account_promo   ON dbo.promotion_usages (account_id, promotion_id);
CREATE INDEX ix_promotion_usages_booking         ON dbo.promotion_usages (booking_id);
GO

CREATE INDEX ix_matches_status_booking ON dbo.matches (status, booking_id);
CREATE INDEX ix_team_members_account   ON dbo.team_members (account_id);
CREATE INDEX ix_reviews_reviewed       ON dbo.reviews (reviewed_account_id);
GO

CREATE INDEX ix_court_qr_codes_status            ON dbo.court_qr_codes (status);
CREATE INDEX ix_court_qr_token_history_court     ON dbo.court_qr_token_history (court_id);
CREATE INDEX ix_court_qr_token_history_qr        ON dbo.court_qr_token_history (court_qr_id);
CREATE INDEX ix_court_qr_token_history_hash      ON dbo.court_qr_token_history (token_hash);
GO

CREATE INDEX ix_work_shifts_account_date   ON dbo.work_shifts (account_id, work_date);
CREATE INDEX ix_work_shifts_facility_date  ON dbo.work_shifts (facility_id, work_date);
CREATE INDEX ix_work_shift_audits_shift    ON dbo.work_shift_audits (work_shift_id);
CREATE INDEX ix_qr_requests_facility_status ON dbo.qr_requests (facility_id, status, created_at);
GO

CREATE INDEX ix_notifications_inbox  ON dbo.notifications (is_read, is_deleted, account_id, sent_at);
CREATE INDEX ix_notifications_unread ON dbo.notifications (account_id, is_read);
GO

-- ============================================================================
-- §14. DỮ LIỆU KHỞI TẠO
-- ============================================================================

-- ---------- 14a. roles — BẮT BUỘC đúng ID, khớp Constants.java dòng 10-13 ----------
--   1 = Admin, 2 = Manager, 3 = Khách hàng, 4 = Lễ tân
SET IDENTITY_INSERT dbo.roles ON;

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_id = 1) INSERT INTO dbo.roles (role_id, role_name) VALUES (1, N'Admin');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_id = 2) INSERT INTO dbo.roles (role_id, role_name) VALUES (2, N'Manager');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_id = 3) INSERT INTO dbo.roles (role_id, role_name) VALUES (3, N'Khách hàng');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_id = 4) INSERT INTO dbo.roles (role_id, role_name) VALUES (4, N'Lễ tân');

SET IDENTITY_INSERT dbo.roles OFF;
GO

-- ---------- 14b. sports — Môn thể thao cơ bản ----------
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Bóng đá')     INSERT INTO dbo.sports (sport_name) VALUES (N'Bóng đá');
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Cầu lông')    INSERT INTO dbo.sports (sport_name) VALUES (N'Cầu lông');
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Bóng chuyền') INSERT INTO dbo.sports (sport_name) VALUES (N'Bóng chuyền');
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Bóng rổ')     INSERT INTO dbo.sports (sport_name) VALUES (N'Bóng rổ');
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Tennis')      INSERT INTO dbo.sports (sport_name) VALUES (N'Tennis');
IF NOT EXISTS (SELECT 1 FROM dbo.sports WHERE sport_name = N'Pickleball')  INSERT INTO dbo.sports (sport_name) VALUES (N'Pickleball');
GO

-- ---------- 14c. Tài khoản ADMIN ----------
--   Email    : nhanntty00234@gmail.com
--   Mật khẩu : Password123!
--   Hash     : BCrypt cost 12 (khớp BCrypt.hashpw(pw, BCrypt.gensalt(12)) trong code)
--   ⚠️  Đổi mật khẩu này ngay sau lần đăng nhập đầu tiên.
IF NOT EXISTS (SELECT 1 FROM dbo.accounts WHERE email = 'nhanntty00234@gmail.com')
    INSERT INTO dbo.accounts (
        username, password_hash, email, full_name, role_id,
        is_locked, is_deleted, failed_login_count, reputation_score
    )
    VALUES (
        'admin',
        '$2a$12$mQlGT.OEufrGid.HI7ZfGuIdVz3XTxFzNQSmhlmAlWYMTRfL6Ne/G',
        'nhanntty00234@gmail.com',
        N'Quản trị viên hệ thống',
        1,          -- role_id = 1 = Admin
        0,
        0,
        0,
        100
    );
GO

-- ============================================================================
-- §15. KIỂM TRA SAU KHI CHẠY
-- ============================================================================

PRINT N'--- Số bảng đã tạo (kỳ vọng: 42) ---';
SELECT COUNT(*) AS total_tables FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo');

PRINT N'--- Vai trò (kỳ vọng: 4 dòng, ID 1..4) ---';
SELECT role_id, role_name FROM dbo.roles ORDER BY role_id;

PRINT N'--- Tài khoản admin ---';
SELECT a.account_id, a.email, a.full_name, a.role_id, r.role_name, LEN(a.password_hash) AS hash_length
FROM dbo.accounts a
JOIN dbo.roles r ON r.role_id = a.role_id
WHERE a.email = 'nhanntty00234@gmail.com';
GO
