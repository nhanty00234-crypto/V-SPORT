-- ============================================================
-- 09-full-schema.sql — V-SPORT / QuanLiSport (Microsoft SQL Server)
-- Chỉ chứa CẤU TRÚC. Không chứa INSERT, mật khẩu, API key, PayOS key,
-- chuỗi kết nối hay dữ liệu cá nhân.
-- Nguồn: snapshot INFORMATION_SCHEMA của DB thật ngày 2026-08-02
--        (docs/erd/schema-full.json) + các file migration trong sql/.
-- Cột/bảng đánh dấu [MIGRATION-ONLY] tồn tại trong migration SQL nhưng
-- CHƯA có trong snapshot DB — chưa xác minh đã chạy trên DB thật.
-- ============================================================

-- ---------- Accounts — Tài khoản ----------
IF OBJECT_ID('dbo.Accounts','U') IS NULL
CREATE TABLE dbo.Accounts (
    AccountID                    INT                IDENTITY(1,1) NOT NULL,
    Username                     VARCHAR(50)        NULL,
    Password                     VARCHAR(MAX)       NOT NULL,
    FailedLoginCount             INT                NULL CONSTRAINT DF_Accounts_FailedLoginCount DEFAULT ((0)),
    IsLocked                     BIT                NULL CONSTRAINT DF_Accounts_IsLocked DEFAULT ((0)),
    LastLogin                    DATETIME           NULL,
    GoogleID                     VARCHAR(100)       NULL,
    FacebookID                   VARCHAR(100)       NULL,
    FullName                     NVARCHAR(100)      NULL,
    PhoneNumber                  VARCHAR(15)        NULL,
    Email                        VARCHAR(100)       NULL,
    RoleID                       INT                NULL,
    ZaloID                       VARCHAR(100)       NULL,
    MessengerID                  VARCHAR(100)       NULL,
    DiemUyTin                    INT                NULL CONSTRAINT DF_Accounts_DiemUyTin DEFAULT ((100)),
    DiemTrinhDo                  INT                NULL CONSTRAINT DF_Accounts_DiemTrinhDo DEFAULT ((1000)),
    MaNganHang                   VARCHAR(20)        NULL,
    SoTaiKhoan                   VARCHAR(50)        NULL,
    ViTriSoTruong                NVARCHAR(50)       NULL,
    NhanThongBaoSOS              BIT                NULL CONSTRAINT DF_Accounts_NhanThongBaoSOS DEFAULT ((1)),
    NgaySinh                     DATE               NULL,
    GioiTinh                     NVARCHAR(10)       NULL,
    CreatedAt                    DATETIME           NULL CONSTRAINT DF_Accounts_CreatedAt DEFAULT (getdate()),
    IsDeleted                    BIT                NULL CONSTRAINT DF_Accounts_IsDeleted DEFAULT ((0)),
    CoSoID                       INT                NULL,
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    AvatarUrl                    NVARCHAR(255)      NULL,
    CompletedBookingCount        INT                NOT NULL CONSTRAINT DF_Accounts_CompletedBookingCount DEFAULT ((0)),
    LateCancelCount              INT                NOT NULL CONSTRAINT DF_Accounts_LateCancelCount DEFAULT ((0)),
    NoShowCount                  INT                NOT NULL CONSTRAINT DF_Accounts_NoShowCount DEFAULT ((0)),
    NhanThongBaoMarketing        BIT                NOT NULL CONSTRAINT DF_Accounts_NhanThongBaoMarketing DEFAULT ((1)),
    FaceDescriptor               NVARCHAR(MAX)      NULL,  -- [MIGRATION-ONLY]
    FaceImagePath                NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    FaceEnrolledAt               DATETIME           NULL,  -- [MIGRATION-ONLY]
    CoverImageUrl                NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    ChieuCaoCm                   INT                NULL,  -- [MIGRATION-ONLY]
    CanNangKg                    INT                NULL,  -- [MIGRATION-ONLY]
    GhiChuDacBiet                NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    ViTriYeuThich                NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    MonTheThaoYeuThichID         INT                NULL,  -- [MIGRATION-ONLY]
    TrinhDoChoi                  VARCHAR(30)        NULL,  -- [MIGRATION-ONLY]
    MucTieuChoi                  NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    TanSuatChoi                  VARCHAR(30)        NULL,  -- [MIGRATION-ONLY]
    QrImagePath                  NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_Accounts PRIMARY KEY (AccountID)
);
GO

-- ---------- AdminTrash — Thùng rác quản trị ----------
IF OBJECT_ID('dbo.AdminTrash','U') IS NULL
CREATE TABLE dbo.AdminTrash (
    TrashID                      INT                IDENTITY(1,1) NOT NULL,
    EntityType                   NVARCHAR(100)      NOT NULL,
    EntityID                     INT                NOT NULL,
    DisplayName                  NVARCHAR(255)      NULL,
    SourceTable                  NVARCHAR(100)      NOT NULL,
    OldStatus                    NVARCHAR(100)      NULL,
    DeletedBy                    INT                NULL,
    DeletedAt                    DATETIME2          NOT NULL CONSTRAINT DF_AdminTrash_DeletedAt DEFAULT (sysutcdatetime()),
    Reason                       NVARCHAR(500)      NULL,
    IsRestored                   BIT                NOT NULL CONSTRAINT DF_AdminTrash_IsRestored DEFAULT ((0)),
    RestoredBy                   INT                NULL,
    RestoredAt                   DATETIME2          NULL,
    CONSTRAINT PK_AdminTrash PRIMARY KEY (TrashID)
);
GO

-- ---------- AuditLog — Nhật ký kiểm toán ----------
IF OBJECT_ID('dbo.AuditLog','U') IS NULL
CREATE TABLE dbo.AuditLog (
    AuditLogID                   BIGINT             IDENTITY(1,1) NOT NULL,
    ActorAccountID               INT                NULL,
    ActorName                    NVARCHAR(255)      NOT NULL,
    ActorRole                    INT                NOT NULL,
    CoSoID                       INT                NULL,
    Action                       NVARCHAR(100)      NOT NULL,
    EntityType                   NVARCHAR(100)      NOT NULL,
    EntityID                     NVARCHAR(50)       NULL,
    EntityName                   NVARCHAR(500)      NULL,
    Details                      NVARCHAR(MAX)      NULL,
    IpAddress                    NVARCHAR(50)       NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_AuditLog_CreatedAt DEFAULT (getdate()),
    CONSTRAINT PK_AuditLog PRIMARY KEY (AuditLogID)
);
GO

-- ---------- BangLuong — Bảng lương ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.BangLuong','U') IS NULL
CREATE TABLE dbo.BangLuong (
    BangLuongID                  INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    KyLuongID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    LuongCoBan                   DECIMAL(18,0)      NOT NULL CONSTRAINT DF_BangLuong_LuongCoBan DEFAULT (0),  -- [MIGRATION-ONLY]
    TongPhuCap                   DECIMAL(18,0)      NOT NULL CONSTRAINT DF_BangLuong_TongPhuCap DEFAULT (0),  -- [MIGRATION-ONLY]
    TongKhauTru                  DECIMAL(18,0)      NOT NULL CONSTRAINT DF_BangLuong_TongKhauTru DEFAULT (0),  -- [MIGRATION-ONLY]
    TongLuongThuc                DECIMAL(18,0)      NOT NULL CONSTRAINT DF_BangLuong_TongLuongThuc DEFAULT (0),  -- [MIGRATION-ONLY]
    SoCaLamViec                  INT                NOT NULL CONSTRAINT DF_BangLuong_SoCaLamViec DEFAULT (0),  -- [MIGRATION-ONLY]
    TrangThai                    VARCHAR(30)        NOT NULL CONSTRAINT DF_BangLuong_TrangThai DEFAULT ('ChuaTinh'),  -- [MIGRATION-ONLY]
    GhiChu                       NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_BangLuong_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_BangLuong PRIMARY KEY (BangLuongID)
);
GO

-- ---------- BookingExtension — Gia hạn đặt sân ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.BookingExtension','U') IS NULL
CREATE TABLE dbo.BookingExtension (
    ExtensionID                  INT                IDENTITY(1,1) NOT NULL,  -- [MIGRATION-ONLY]
    DatSanID                     INT                NOT NULL,  -- [MIGRATION-ONLY]
    OldGioKetThuc                TIME               NOT NULL,  -- [MIGRATION-ONLY]
    NewGioKetThuc                TIME               NOT NULL,  -- [MIGRATION-ONLY]
    OldGioKetThucDateTime        DATETIME2          NULL,  -- [MIGRATION-ONLY]
    NewGioKetThucDateTime        DATETIME2          NULL,  -- [MIGRATION-ONLY]
    AdditionalAmount             DECIMAL(18,2)      NOT NULL,  -- [MIGRATION-ONLY]
    OperatorAccountID            INT                NOT NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_BookingExtension_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_BookingExtension PRIMARY KEY (ExtensionID)
);
GO

-- ---------- CaLamViec — Ca làm việc ----------
IF OBJECT_ID('dbo.CaLamViec','U') IS NULL
CREATE TABLE dbo.CaLamViec (
    CaLamViecID                  INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    NgayLam                      DATE               NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    GhiChu                       NVARCHAR(255)      NULL,
    Thu                          INT                NULL,
    IsPublished                  BIT                NOT NULL CONSTRAINT DF_CaLamViec_IsPublished DEFAULT ((0)),
    TenCa                        NVARCHAR(50)       NULL,
    ViTri                        NVARCHAR(50)       NULL,
    TrangThai                    VARCHAR(30)        NOT NULL CONSTRAINT DF_CaLamViec_TrangThai DEFAULT ('Draft'),
    GioNghi                      INT                NOT NULL CONSTRAINT DF_CaLamViec_GioNghi DEFAULT ((0)),
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_CaLamViec_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    IsCustomTime                 BIT                NOT NULL CONSTRAINT DF_CaLamViec_IsCustomTime DEFAULT ((0)),
    CustomTimeReason             NVARCHAR(255)      NULL,
    FaceVerified                 BIT                NOT NULL CONSTRAINT DF_CaLamViec_FaceVerified DEFAULT (0),  -- [MIGRATION-ONLY]
    FaceCheckInImage             NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    FaceConfidence               FLOAT              NULL,  -- [MIGRATION-ONLY]
    FaceLivenessPassed           BIT                NOT NULL CONSTRAINT DF_CaLamViec_FaceLivenessPassed DEFAULT (0),  -- [MIGRATION-ONLY]
    FaceCheckOutImage            NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    FaceCheckOutConfidence       FLOAT              NULL,  -- [MIGRATION-ONLY]
    GioVaoThuc                   DATETIME           NULL,  -- [MIGRATION-ONLY]
    GioRaThuc                    DATETIME           NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_CaLamViec PRIMARY KEY (CaLamViecID)
);
GO

-- ---------- CaLamViec_Audit — Nhật ký ca làm việc ----------
IF OBJECT_ID('dbo.CaLamViec_Audit','U') IS NULL
CREATE TABLE dbo.CaLamViec_Audit (
    AuditID                      INT                NOT NULL,
    CaLamViecID                  INT                NOT NULL,
    ThaoTac                      VARCHAR(50)        NOT NULL,
    NguoiThucHien                INT                NOT NULL,
    ThoiGian                     DATETIME           NULL CONSTRAINT DF_CaLamViec_Audit_ThoiGian DEFAULT (getdate()),
    GiaTriCu                     NVARCHAR(MAX)      NULL,
    GiaTriMoi                    NVARCHAR(MAX)      NULL,
    LyDo                         NVARCHAR(255)      NULL,
    CONSTRAINT PK_CaLamViec_Audit PRIMARY KEY (AuditID)
);
GO

-- ---------- CaLamViec_Availability — Thời gian rảnh nhân viên ----------
IF OBJECT_ID('dbo.CaLamViec_Availability','U') IS NULL
CREATE TABLE dbo.CaLamViec_Availability (
    AvailabilityID               INT                NOT NULL,
    AccountID                    INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    Ngay                         DATE               NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    TrangThai                    VARCHAR(20)        NOT NULL CONSTRAINT DF_CaLamViec_Availability_TrangThai DEFAULT ('Ranh'),
    GhiChu                       NVARCHAR(255)      NULL,
    CreatedAt                    DATETIME           NULL CONSTRAINT DF_CaLamViec_Availability_CreatedAt DEFAULT (getdate()),
    DuyetTrangThai               VARCHAR(20)        NULL CONSTRAINT DF_CaLamViec_Availability_DuyetTrangThai DEFAULT ('DaDuyet'),
    PhanHoi                      NVARCHAR(255)      NULL,
    CONSTRAINT PK_CaLamViec_Availability PRIMARY KEY (AvailabilityID)
);
GO

-- ---------- CaLamViec_SwapRequest — Yêu cầu đổi ca ----------
IF OBJECT_ID('dbo.CaLamViec_SwapRequest','U') IS NULL
CREATE TABLE dbo.CaLamViec_SwapRequest (
    SwapRequestID                INT                NOT NULL,
    AccountID_Gui                INT                NOT NULL,
    CaLamViecID_Gui              INT                NOT NULL,
    AccountID_Nhan               INT                NOT NULL,
    CaLamViecID_Nhan             INT                NULL,
    LyDo                         NVARCHAR(255)      NULL,
    TrangThai                    VARCHAR(30)        NOT NULL CONSTRAINT DF_CaLamViec_SwapRequest_TrangThai DEFAULT ('ChoXacNhan'),
    NguoiDuyet                   INT                NULL,
    NgayGui                      DATETIME           NULL CONSTRAINT DF_CaLamViec_SwapRequest_NgayGui DEFAULT (getdate()),
    NgayDuyet                    DATETIME           NULL,
    GhiChuQuanLy                 NVARCHAR(255)      NULL,
    CONSTRAINT PK_CaLamViec_SwapRequest PRIMARY KEY (SwapRequestID)
);
GO

-- ---------- CauHinhLuong — Cấu hình lương ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.CauHinhLuong','U') IS NULL
CREATE TABLE dbo.CauHinhLuong (
    CauHinhLuongID               INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    CoSoID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    LuongCoBan                   DECIMAL(18,0)      NOT NULL CONSTRAINT DF_CauHinhLuong_LuongCoBan DEFAULT (0),  -- [MIGRATION-ONLY]
    PhuCapMoiCa                  DECIMAL(18,0)      NOT NULL CONSTRAINT DF_CauHinhLuong_PhuCapMoiCa DEFAULT (0),  -- [MIGRATION-ONLY]
    HanMucUng                    DECIMAL(18,0)      NOT NULL CONSTRAINT DF_CauHinhLuong_HanMucUng DEFAULT (0),  -- [MIGRATION-ONLY]
    GhiChu                       NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_CauHinhLuong_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    UpdatedAt                    DATETIME           NOT NULL CONSTRAINT DF_CauHinhLuong_UpdatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_CauHinhLuong PRIMARY KEY (CauHinhLuongID)
);
GO

-- ---------- ChiaHoaDon — Chia hóa đơn (cũ) ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.ChiaHoaDon','U') IS NULL
CREATE TABLE dbo.ChiaHoaDon (
    ChiaHoaDonID                 INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    HoaDonID                     INT                NOT NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    SoTienPhanBo                 DECIMAL(18,2)      NOT NULL,  -- [MIGRATION-ONLY]
    DaTra                        BIT                NULL CONSTRAINT DF_ChiaHoaDon_DaTra DEFAULT (0),  -- [MIGRATION-ONLY]
    ThoiGianTra                  DATETIME           NULL,  -- [MIGRATION-ONLY]
    GhiChu                       NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_ChiaHoaDon PRIMARY KEY (ChiaHoaDonID)
);
GO

-- ---------- ChiTietGhepKeo — Người tham gia kèo ----------
IF OBJECT_ID('dbo.ChiTietGhepKeo','U') IS NULL
CREATE TABLE dbo.ChiTietGhepKeo (
    ChiTietKeoID                 INT                IDENTITY(1,1) NOT NULL,
    KeoID                        INT                NULL,
    AccountID_NguoiThamGia       INT                NULL,
    TrangThaiThamGia             NVARCHAR(50)       NULL CONSTRAINT DF_ChiTietGhepKeo_TrangThaiThamGia DEFAULT (N'Chờ duyệt'),
    ViTriThamGia                 NVARCHAR(50)       NULL,
    TeamIDNguoiThamGia           INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_ChiTietGhepKeo PRIMARY KEY (ChiTietKeoID)
);
GO

-- ---------- ChiTietHoaDon — Chi tiết hóa đơn ----------
IF OBJECT_ID('dbo.ChiTietHoaDon','U') IS NULL
CREATE TABLE dbo.ChiTietHoaDon (
    ChiTietID                    INT                IDENTITY(1,1) NOT NULL,
    HoaDonID                     INT                NULL,
    SanPhamID                    INT                NULL,
    SoLuong                      INT                NOT NULL,
    DonGiaTaiThoiDiemBan         FLOAT              NULL,
    ThanhTien                    FLOAT              NULL,
    CONSTRAINT PK_ChiTietHoaDon PRIMARY KEY (ChiTietID)
);
GO

-- ---------- CoSo — Cơ sở thể thao ----------
IF OBJECT_ID('dbo.CoSo','U') IS NULL
CREATE TABLE dbo.CoSo (
    CoSoID                       INT                IDENTITY(1,1) NOT NULL,
    TenCoSo                      NVARCHAR(100)      NOT NULL,
    DiaChi                       NVARCHAR(255)      NULL,
    SoDienThoai                  VARCHAR(15)        NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_CoSo_TrangThai DEFAULT (N'Hoạt động'),
    GioMoCua                     TIME               NULL,
    GioDongCua                   TIME               NULL,
    HinhAnh                      NVARCHAR(500)      NULL,
    MoTa                         NVARCHAR(MAX)      NULL,
    LoaiHinhKinhDoanh            NVARCHAR(255)      NULL,
    SoLuongSanDuKien             INT                NULL CONSTRAINT DF_CoSo_SoLuongSanDuKien DEFAULT ((0)),
    AccountID_QuanLy             INT                NULL,
    PayOS_ClientID               VARCHAR(255)       NULL,
    PayOS_ApiKey                 VARCHAR(255)       NULL,
    PayOS_ChecksumKey            VARCHAR(255)       NULL,
    IsDeleted                    BIT                NULL CONSTRAINT DF_CoSo_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    ViDo                         DECIMAL(10,7)      NULL,
    KinhDo                       DECIMAL(10,7)      NULL,
    CONSTRAINT PK_CoSo PRIMARY KEY (CoSoID)
);
GO

-- ---------- CoSoCapability — Năng lực cơ sở ----------
IF OBJECT_ID('dbo.CoSoCapability','U') IS NULL
CREATE TABLE dbo.CoSoCapability (
    CapabilityID                 INT                IDENTITY(1,1) NOT NULL,
    CoSoID                       INT                NOT NULL,
    CapabilityType               NVARCHAR(50)       NOT NULL,
    TrangThai                    NVARCHAR(20)       NOT NULL CONSTRAINT DF_CoSoCapability_TrangThai DEFAULT (N'PENDING'),
    RequestedAt                  DATETIME2          NOT NULL CONSTRAINT DF_CoSoCapability_RequestedAt DEFAULT (sysutcdatetime()),
    ApprovedBy                   INT                NULL,
    ApprovedAt                   DATETIME2          NULL,
    RejectReason                 NVARCHAR(500)      NULL,
    Note                         NVARCHAR(500)      NULL,
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_CoSoCapability_UpdatedAt DEFAULT (sysutcdatetime()),
    CONSTRAINT PK_CoSoCapability PRIMARY KEY (CapabilityID)
);
GO

-- ---------- CoSoFaceConfig — Cấu hình khuôn mặt cơ sở ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.CoSoFaceConfig','U') IS NULL
CREATE TABLE dbo.CoSoFaceConfig (
    CoSoID                       INT                NULL,  -- [MIGRATION-ONLY]
    FaceRequired                 BIT                NOT NULL CONSTRAINT DF_CoSoFaceConfig_FaceRequired DEFAULT (0),  -- [MIGRATION-ONLY]
    ConfidenceMin                FLOAT              NOT NULL CONSTRAINT DF_CoSoFaceConfig_ConfidenceMin DEFAULT (0.6),  -- [MIGRATION-ONLY]
    UpdatedAt                    DATETIME           NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_CoSoFaceConfig PRIMARY KEY (CoSoID)
);
GO

-- ---------- CoSoNganHang — Tài khoản ngân hàng cơ sở ----------
IF OBJECT_ID('dbo.CoSoNganHang','U') IS NULL
CREATE TABLE dbo.CoSoNganHang (
    CoSoID                       INT                NOT NULL,
    BankName                     NVARCHAR(100)      NOT NULL,
    BankShortCode                VARCHAR(20)        NOT NULL,
    AccountName                  NVARCHAR(100)      NOT NULL,
    AccountNumber                VARCHAR(50)        NOT NULL,
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_CoSoNganHang_UpdatedAt DEFAULT (getdate()),
    CONSTRAINT PK_CoSoNganHang PRIMARY KEY (CoSoID)
);
GO

-- ---------- CourtChargeSegment — Đoạn tính tiền sân ----------
IF OBJECT_ID('dbo.CourtChargeSegment','U') IS NULL
CREATE TABLE dbo.CourtChargeSegment (
    SegmentID                    INT                IDENTITY(1,1) NOT NULL,
    HoaDonID                     INT                NOT NULL,
    DatSanID                     INT                NOT NULL,
    SegmentOrder                 INT                NOT NULL,
    StartAt                      DATETIME2          NOT NULL,
    EndAt                        DATETIME2          NOT NULL,
    DurationMinutes              INT                NOT NULL,
    RateType                     NVARCHAR(30)       NOT NULL,
    HourlyRate                   DECIMAL(18,2)      NOT NULL,
    Amount                       DECIMAL(18,2)      NOT NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_CourtChargeSegment_CreatedAt DEFAULT (getdate()),
    CONSTRAINT PK_CourtChargeSegment PRIMARY KEY (SegmentID)
);
GO

-- ---------- CustomerReputationHistory — Lịch sử điểm uy tín ----------
IF OBJECT_ID('dbo.CustomerReputationHistory','U') IS NULL
CREATE TABLE dbo.CustomerReputationHistory (
    ReputationHistoryID          BIGINT             IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NOT NULL,
    DatSanID                     INT                NULL,
    ActionType                   NVARCHAR(30)       NOT NULL,
    ScoreDelta                   INT                NOT NULL,
    ScoreBefore                  INT                NOT NULL,
    ScoreAfter                   INT                NOT NULL,
    Reason                       NVARCHAR(255)      NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_CustomerReputationHistory_CreatedAt DEFAULT (getdate()),
    CreatedBy                    INT                NULL,
    IpAddress                    NVARCHAR(50)       NULL,
    CONSTRAINT PK_CustomerReputationHistory PRIMARY KEY (ReputationHistoryID)
);
GO

-- ---------- DanhGia — Đánh giá ----------
IF OBJECT_ID('dbo.DanhGia','U') IS NULL
CREATE TABLE dbo.DanhGia (
    DanhGiaID                    INT                IDENTITY(1,1) NOT NULL,
    DatSanID                     INT                NULL,
    AccountID_NguoiDanhGia       INT                NULL,
    AccountID_NguoiBiDanhGia     INT                NULL,
    SoSao                        INT                NULL,
    BinhLuan                     NVARCHAR(MAX)      NULL,
    NgayDanhGia                  DATETIME           NULL CONSTRAINT DF_DanhGia_NgayDanhGia DEFAULT (getdate()),
    CONSTRAINT PK_DanhGia PRIMARY KEY (DanhGiaID)
);
GO

-- ---------- DanhMucSanPham — Danh mục sản phẩm ----------
IF OBJECT_ID('dbo.DanhMucSanPham','U') IS NULL
CREATE TABLE dbo.DanhMucSanPham (
    DanhMucID                    INT                IDENTITY(1,1) NOT NULL,
    TenDanhMuc                   NVARCHAR(100)      NOT NULL,
    CONSTRAINT PK_DanhMucSanPham PRIMARY KEY (DanhMucID)
);
GO

-- ---------- FaceChallengeToken — Token thử thách khuôn mặt ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.FaceChallengeToken','U') IS NULL
CREATE TABLE dbo.FaceChallengeToken (
    TokenID                      VARCHAR(64)        NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    CaLamViecID                  INT                NOT NULL,  -- [MIGRATION-ONLY]
    Action                       VARCHAR(10)        NOT NULL CONSTRAINT DF_FaceChallengeToken_Action DEFAULT ('checkin'),  -- [MIGRATION-ONLY]
    Challenges                   NVARCHAR(200)      NOT NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_FaceChallengeToken_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    ExpiresAt                    DATETIME           NOT NULL,  -- [MIGRATION-ONLY]
    UsedAt                       DATETIME           NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_FaceChallengeToken PRIMARY KEY (TokenID)
);
GO

-- ---------- GhepKeo — Ghép kèo ----------
IF OBJECT_ID('dbo.GhepKeo','U') IS NULL
CREATE TABLE dbo.GhepKeo (
    KeoID                        INT                IDENTITY(1,1) NOT NULL,
    DatSanID                     INT                NULL,
    AccountID_NguoiTao           INT                NULL,
    MonTheThaoID                 INT                NULL,
    MoTa                         NVARCHAR(MAX)      NULL,
    TrinhDo                      NVARCHAR(50)       NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_GhepKeo_TrangThai DEFAULT (N'Đang tìm'),
    SoNguoiCanTim                INT                NULL,  -- [MIGRATION-ONLY]
    HinhThucDuyet                NVARCHAR(20)       NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_GhepKeo_CreatedAt DEFAULT (SYSDATETIME()),  -- [MIGRATION-ONLY]
    TeamIDNguoiTao               INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_GhepKeo PRIMARY KEY (KeoID)
);
GO

-- ---------- HoaDon — Hóa đơn ----------
IF OBJECT_ID('dbo.HoaDon','U') IS NULL
CREATE TABLE dbo.HoaDon (
    HoaDonID                     INT                IDENTITY(1,1) NOT NULL,
    DatSanID                     INT                NULL,
    AccountID_KhachHang          INT                NULL,
    AccountID_NhanVien           INT                NULL,
    NgayLap                      DATETIME           NULL CONSTRAINT DF_HoaDon_NgayLap DEFAULT (getdate()),
    TongTienSan                  DECIMAL(18,2)      NULL CONSTRAINT DF_HoaDon_TongTienSan DEFAULT ((0)),
    TongTienDichVu               DECIMAL(18,2)      NULL CONSTRAINT DF_HoaDon_TongTienDichVu DEFAULT ((0)),
    PhiGuiXe                     DECIMAL(18,2)      NULL CONSTRAINT DF_HoaDon_PhiGuiXe DEFAULT ((0)),
    KhuyenMaiID                  INT                NULL,
    GiamGia                      DECIMAL(18,2)      NULL CONSTRAINT DF_HoaDon_GiamGia DEFAULT ((0)),
    TongThanhToan                FLOAT              NULL,
    PhuongThucThanhToan          NVARCHAR(50)       NULL,
    TrangThaiThanhToan           NVARCHAR(50)       NULL,
    IsDeleted                    BIT                NULL CONSTRAINT DF_HoaDon_IsDeleted DEFAULT ((0)),
    GhiChu                       NVARCHAR(500)      NULL,
    LoaiHoaDon                   NVARCHAR(50)       NULL CONSTRAINT DF_HoaDon_LoaiHoaDon DEFAULT (N'MAIN'),
    ParentHoaDonID               INT                NULL,
    PaymentReference             NVARCHAR(50)       NULL,
    CONSTRAINT PK_HoaDon PRIMARY KEY (HoaDonID)
);
GO

-- ---------- HoanTien — Hoàn tiền ----------
IF OBJECT_ID('dbo.HoanTien','U') IS NULL
CREATE TABLE dbo.HoanTien (
    HoanTienID                   INT                IDENTITY(1,1) NOT NULL,
    HoaDonID                     INT                NOT NULL,
    AccountID                    INT                NOT NULL,
    SoTienHoan                   NUMERIC(38,2)      NULL,
    LyDo                         NVARCHAR(255)      NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_HoanTien_TrangThai DEFAULT (N'Chờ xử lý'),
    ThoiGianYeuCau               DATETIME           NULL CONSTRAINT DF_HoanTien_ThoiGianYeuCau DEFAULT (getdate()),
    ThoiGianHoan                 DATETIME           NULL,
    DatSanID                     INT                NULL,
    NguoiDuyetID                 INT                NULL,
    GhiChu                       NVARCHAR(255)      NULL,
    SoTienDaThanhToan            DECIMAL(18,2)      NULL,
    SoTienDeNghiHoan             DECIMAL(18,2)      NULL,
    SoTienDuocDuyet              DECIMAL(18,2)      NULL,
    CoSoID                       INT                NULL,
    QrNhanTienPath               NVARCHAR(500)      NULL,
    GhiChuKhachHang              NVARCHAR(500)      NULL,
    LyDoTuChoi                   NVARCHAR(500)      NULL,
    ApprovedAt                   DATETIME2          NULL,
    CompletedAt                  DATETIME2          NULL,
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_HoanTien_UpdatedAt DEFAULT (sysdatetime()),
    AccountID_NguoiXuLy          INT                NULL,
    GhiChuXuLy                   NVARCHAR(500)      NULL,
    MaGiaoDichHoan               NVARCHAR(100)      NULL,
    ThoiGianXuLy                 DATETIME           NULL,
    NganHangNhan                 NVARCHAR(100)      NULL,
    SoTaiKhoanNhan               NVARCHAR(30)       NULL,
    ChuTaiKhoanNhan              NVARCHAR(100)      NULL,
    CONSTRAINT PK_HoanTien PRIMARY KEY (HoanTienID)
);
GO

-- ---------- KhuyenMai — Khuyến mãi ----------
IF OBJECT_ID('dbo.KhuyenMai','U') IS NULL
CREATE TABLE dbo.KhuyenMai (
    KhuyenMaiID                  INT                IDENTITY(1,1) NOT NULL,
    MaCode                       VARCHAR(50)        NOT NULL,
    MoTa                         NVARCHAR(255)      NULL,
    LoaiGiam                     NVARCHAR(20)       NOT NULL,
    GiaTriGiam                   FLOAT              NULL,
    NgayBatDau                   DATE               NOT NULL,
    NgayKetThuc                  DATE               NOT NULL,
    SoLanToiDa                   INT                NULL,
    SoLanDaDung                  INT                NULL CONSTRAINT DF_KhuyenMai_SoLanDaDung DEFAULT ((0)),
    CoSoID                       INT                NULL,
    TrangThai                    NVARCHAR(20)       NULL CONSTRAINT DF_KhuyenMai_TrangThai DEFAULT (N'Hoạt động'),
    IsDeleted                    BIT                NULL CONSTRAINT DF_KhuyenMai_IsDeleted DEFAULT ((0)),
    GiaTriToiThieu               DECIMAL(18,2)      NULL CONSTRAINT DF_KhuyenMai_GiaTriToiThieu DEFAULT ((0)),
    GiamToiDa                    DECIMAL(18,2)      NULL CONSTRAINT DF_KhuyenMai_GiamToiDa DEFAULT ((0)),
    HienThiCongKhai              BIT                NOT NULL CONSTRAINT DF_KhuyenMai_HienThiCongKhai DEFAULT ((1)),
    CONSTRAINT PK_KhuyenMai PRIMARY KEY (KhuyenMaiID)
);
GO

-- ---------- KhuyenMaiHinhAnh — Hình ảnh khuyến mãi ----------
IF OBJECT_ID('dbo.KhuyenMaiHinhAnh','U') IS NULL
CREATE TABLE dbo.KhuyenMaiHinhAnh (
    HinhAnhID                    INT                IDENTITY(1,1) NOT NULL,
    KhuyenMaiID                  INT                NOT NULL,
    DuongDan                     NVARCHAR(500)      NOT NULL,
    TenFileGoc                   NVARCHAR(255)      NULL,
    MimeType                     NVARCHAR(100)      NULL,
    DungLuong                    BIGINT             NULL,
    ChieuRong                    INT                NULL,
    ChieuCao                     INT                NULL,
    ThuTu                        INT                NOT NULL CONSTRAINT DF_KhuyenMaiHinhAnh_ThuTu DEFAULT ((0)),
    LaAnhBia                     BIT                NOT NULL CONSTRAINT DF_KhuyenMaiHinhAnh_LaAnhBia DEFAULT ((0)),
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_KhuyenMaiHinhAnh_CreatedAt DEFAULT (sysdatetime()),
    UpdatedAt                    DATETIME2          NULL,
    CONSTRAINT PK_KhuyenMaiHinhAnh PRIMARY KEY (HinhAnhID)
);
GO

-- ---------- KyLuong — Kỳ lương ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.KyLuong','U') IS NULL
CREATE TABLE dbo.KyLuong (
    KyLuongID                    INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    CoSoID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    TenKy                        NVARCHAR(100)      NOT NULL,  -- [MIGRATION-ONLY]
    NgayBatDau                   DATE               NOT NULL,  -- [MIGRATION-ONLY]
    NgayKetThuc                  DATE               NOT NULL,  -- [MIGRATION-ONLY]
    NgayPhatLuong                DATE               NOT NULL,  -- [MIGRATION-ONLY]
    TrangThai                    VARCHAR(20)        NOT NULL CONSTRAINT DF_KyLuong_TrangThai DEFAULT ('Draft'),  -- [MIGRATION-ONLY]
    CreatedBy                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_KyLuong_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_KyLuong PRIMARY KEY (KyLuongID)
);
GO

-- ---------- LichDatSan — Lịch đặt sân ----------
IF OBJECT_ID('dbo.LichDatSan','U') IS NULL
CREATE TABLE dbo.LichDatSan (
    DatSanID                     INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NULL,
    SanID                        INT                NULL,
    NgayDat                      DATE               NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    ApDungGiaCoDen               BIT                NULL CONSTRAINT DF_LichDatSan_ApDungGiaCoDen DEFAULT ((0)),
    TongTienDuKien               NUMERIC(38,2)      NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_LichDatSan_TrangThai DEFAULT (N'Chờ xác nhận'),
    GhiChu                       NVARCHAR(255)      NULL,
    NguonDatSan                  NVARCHAR(50)       NULL,
    IsDeleted                    BIT                NULL CONSTRAINT DF_LichDatSan_IsDeleted DEFAULT ((0)),
    CreatedTime                  DATETIME           NULL CONSTRAINT DF_LichDatSan_CreatedTime DEFAULT (getdate()),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    actual_start_time            TIME               NULL,
    TimeMode                     NVARCHAR(30)       NULL,
    ReservedDurationMinutes      INT                NULL,
    actual_end_time              TIME               NULL,
    EarlyCheckoutReason          NVARCHAR(255)      NULL,
    EarlyCheckoutDiscount        DECIMAL(18,2)      NULL,
    HoldExpiresAt                DATETIME2          NULL,
    DepositAmount                DECIMAL(18,2)      NULL,
    PaymentMethodConfirmed       NVARCHAR(50)       NULL,
    TransactionCode              NVARCHAR(100)      NULL,
    ConfirmedAt                  DATETIME2          NULL,
    ConfirmedBy                  INT                NULL,
    ConfirmSource                NVARCHAR(20)       NULL,
    NoShowAt                     DATETIME2          NULL,
    ActualStartAt                DATETIME2          NULL,
    ActualEndAt                  DATETIME2          NULL,
    PricingFinalizedAt           DATETIME2          NULL,
    CancelType                   NVARCHAR(20)       NULL,
    CancelReason                 NVARCHAR(255)      NULL,
    CancelledAt                  DATETIME2          NULL,
    CancelledBy                  INT                NULL,
    RequiresRefundReview         BIT                NOT NULL CONSTRAINT DF_LichDatSan_RequiresRefundReview DEFAULT ((0)),
    PayosOrderCode               BIGINT             NULL,
    PayosPaymentLinkId           VARCHAR(255)       NULL,
    PayosQrPayload               NVARCHAR(MAX)      NULL,
    PayosCheckoutUrl             NVARCHAR(1024)     NULL,
    PayosBin                     VARCHAR(20)        NULL,
    PayosAccountNumber           VARCHAR(64)        NULL,
    PayosAccountName             NVARCHAR(255)      NULL,
    PayosAmount                  DECIMAL(18,2)      NULL,
    PayosDescription             NVARCHAR(255)      NULL,
    PayosExpiresAt               DATETIME2          NULL,
    CONSTRAINT PK_LichDatSan PRIMARY KEY (DatSanID)
);
GO

-- ---------- LichDatSan_DichVu — Dịch vụ đặt trước ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.LichDatSan_DichVu','U') IS NULL
CREATE TABLE dbo.LichDatSan_DichVu (
    Id                           INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    DatSanID                     INT                NOT NULL,  -- [MIGRATION-ONLY]
    SanPhamID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    Quantity                     INT                NOT NULL,  -- [MIGRATION-ONLY]
    UnitPrice                    DECIMAL(18,2)      NOT NULL,  -- [MIGRATION-ONLY]
    TotalPrice                   DECIMAL(18,2)      NOT NULL,  -- [MIGRATION-ONLY]
    Status                       NVARCHAR(50)       NOT NULL CONSTRAINT DF_LichDatSan_DichVu_Status DEFAULT (N),  -- [MIGRATION-ONLY]
    Note                         NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_LichDatSan_DichVu_CreatedAt DEFAULT (SYSDATETIME()),  -- [MIGRATION-ONLY]
    DeliveredAt                  DATETIME2          NULL,  -- [MIGRATION-ONLY]
    DeliveredBy                  INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_LichDatSan_DichVu PRIMARY KEY (Id)
);
GO

-- ---------- LichSuELO — Lịch sử điểm ELO ----------
IF OBJECT_ID('dbo.LichSuELO','U') IS NULL
CREATE TABLE dbo.LichSuELO (
    LichSuELOID                  INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NOT NULL,
    DatSanID                     INT                NULL,
    DiemTruoc                    INT                NOT NULL,
    DiemSau                      INT                NOT NULL,
    ThayDoi                      INT                NOT NULL,
    LyDo                         NVARCHAR(255)      NULL,
    ThoiGian                     DATETIME           NULL CONSTRAINT DF_LichSuELO_ThoiGian DEFAULT (getdate()),
    CONSTRAINT PK_LichSuELO PRIMARY KEY (LichSuELOID)
);
GO

-- ---------- LichSuKhuyenMai — Lịch sử dùng khuyến mãi ----------
IF OBJECT_ID('dbo.LichSuKhuyenMai','U') IS NULL
CREATE TABLE dbo.LichSuKhuyenMai (
    HistoryID                    INT                IDENTITY(1,1) NOT NULL,
    KhuyenMaiID                  INT                NOT NULL,
    AccountID                    INT                NOT NULL,
    DatSanID                     INT                NULL,
    DiscountAmount               DECIMAL(18,2)      NOT NULL CONSTRAINT DF_LichSuKhuyenMai_DiscountAmount DEFAULT ((0)),
    UsedAt                       DATETIME           NOT NULL CONSTRAINT DF_LichSuKhuyenMai_UsedAt DEFAULT (getdate()),
    CONSTRAINT PK_LichSuKhuyenMai PRIMARY KEY (HistoryID)
);
GO

-- ---------- LichXeRaVao — Lịch xe ra vào ----------
IF OBJECT_ID('dbo.LichXeRaVao','U') IS NULL
CREATE TABLE dbo.LichXeRaVao (
    LichXeID                     INT                IDENTITY(1,1) NOT NULL,
    TheID                        INT                NULL,
    DatSanID                     INT                NULL,
    BienSoXe                     VARCHAR(20)        NULL,
    KieuGuiXe                    NVARCHAR(20)       NULL,
    GioVao                       DATETIME           NULL CONSTRAINT DF_LichXeRaVao_GioVao DEFAULT (getdate()),
    GioRa                        DATETIME           NULL,
    PhiGuiXe                     DECIMAL(18,2)      NULL CONSTRAINT DF_LichXeRaVao_PhiGuiXe DEFAULT ((0)),
    AccountID_NhanVien           INT                NULL,
    CONSTRAINT PK_LichXeRaVao PRIMARY KEY (LichXeID)
);
GO

-- ---------- LoaiSan — Loại sân ----------
IF OBJECT_ID('dbo.LoaiSan','U') IS NULL
CREATE TABLE dbo.LoaiSan (
    LoaiSanID                    INT                IDENTITY(1,1) NOT NULL,
    MonTheThaoID                 INT                NOT NULL,
    TenLoai                      NVARCHAR(50)       NOT NULL,
    GiaKhongDen                  FLOAT              NULL,
    GiaCoDen                     DECIMAL(18,2)      NULL,
    GioBatDauLenDen              TIME               NULL CONSTRAINT DF_LoaiSan_GioBatDauLenDen DEFAULT ('17:30:00'),
    CoSoID                       INT                NULL,
    GioKetThucLenDen             TIME               NULL,
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_LoaiSan_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    CONSTRAINT PK_LoaiSan PRIMARY KEY (LoaiSanID)
);
GO

-- ---------- LoaiSan_KhungGioDen_Backup — Sao lưu khung giờ đèn ----------
IF OBJECT_ID('dbo.LoaiSan_KhungGioDen_Backup','U') IS NULL
CREATE TABLE dbo.LoaiSan_KhungGioDen_Backup (
    KhungGioDenID                INT                NOT NULL,
    LoaiSanID                    INT                NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    IsDeleted                    BIT                NOT NULL,
    DeletedAt                    DATETIME2          NULL,
    DeletedBy                    INT                NULL,
    CreatedAt                    DATETIME2          NOT NULL,
    UpdatedAt                    DATETIME2          NULL,
    -- KHÔNG có PRIMARY KEY trong nguồn dữ liệu
);
GO

-- ---------- MaQR — Mã QR chia tiền (cũ) ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.MaQR','U') IS NULL
CREATE TABLE dbo.MaQR (
    MaQRID                       INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    ChiaHoaDonID                 INT                NOT NULL,  -- [MIGRATION-ONLY]
    NoiDungQR                    NVARCHAR(500)      NOT NULL,  -- [MIGRATION-ONLY]
    NgayTao                      DATETIME           NULL CONSTRAINT DF_MaQR_NgayTao DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    NgayHetHan                   DATETIME           NULL,  -- [MIGRATION-ONLY]
    DaQuet                       BIT                NULL CONSTRAINT DF_MaQR_DaQuet DEFAULT (0),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_MaQR PRIMARY KEY (MaQRID)
);
GO

-- ---------- MonTheThao — Môn thể thao ----------
IF OBJECT_ID('dbo.MonTheThao','U') IS NULL
CREATE TABLE dbo.MonTheThao (
    MonTheThaoID                 INT                IDENTITY(1,1) NOT NULL,
    TenMon                       NVARCHAR(50)       NOT NULL,
    CONSTRAINT PK_MonTheThao PRIMARY KEY (MonTheThaoID)
);
GO

-- ---------- MonTheThaoYeuThich — Môn thể thao yêu thích ----------
IF OBJECT_ID('dbo.MonTheThaoYeuThich','U') IS NULL
CREATE TABLE dbo.MonTheThaoYeuThich (
    AccountID                    INT                NOT NULL,
    MonTheThaoID                 INT                NOT NULL,
    NgayThêm                     DATETIME           NULL CONSTRAINT DF_MonTheThaoYeuThich_NgayThêm DEFAULT (getdate()),
    CONSTRAINT PK_MonTheThaoYeuThich PRIMARY KEY (AccountID, MonTheThaoID)
);
GO

-- ---------- NhatKyChat — Nhật ký chat ----------
IF OBJECT_ID('dbo.NhatKyChat','U') IS NULL
CREATE TABLE dbo.NhatKyChat (
    NhatKyChatID                 INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NULL,
    Kenh                         NVARCHAR(20)       NOT NULL,
    TurnSo                       INT                NOT NULL,
    VaiTro                       NVARCHAR(10)       NOT NULL,
    NoiDung                      NVARCHAR(MAX)      NOT NULL,
    TrangThaiBot                 NVARCHAR(50)       NULL,
    ThoiGian                     DATETIME           NULL CONSTRAINT DF_NhatKyChat_ThoiGian DEFAULT (getdate()),
    CONSTRAINT PK_NhatKyChat PRIMARY KEY (NhatKyChatID)
);
GO

-- ---------- NhatKySOSGui — Nhật ký gửi SOS ----------
IF OBJECT_ID('dbo.NhatKySOSGui','U') IS NULL
CREATE TABLE dbo.NhatKySOSGui (
    NhatKySOSGuiID               INT                IDENTITY(1,1) NOT NULL,
    YeuCauSOSID                  INT                NOT NULL,
    AccountID_NhanGui            INT                NOT NULL,
    ThoiGianGui                  DATETIME           NULL CONSTRAINT DF_NhatKySOSGui_ThoiGianGui DEFAULT (getdate()),
    DaXem                        BIT                NULL CONSTRAINT DF_NhatKySOSGui_DaXem DEFAULT ((0)),
    PhanHoi                      NVARCHAR(50)       NULL,
    CONSTRAINT PK_NhatKySOSGui PRIMARY KEY (NhatKySOSGuiID)
);
GO

-- ---------- NhomChiaTien — Nhóm chia hóa đơn ----------
IF OBJECT_ID('dbo.NhomChiaTien','U') IS NULL
CREATE TABLE dbo.NhomChiaTien (
    NhomChiaTienID               INT                IDENTITY(1,1) NOT NULL,
    HoaDonID                     INT                NOT NULL,
    DatSanID                     INT                NOT NULL,
    CreatedByAccountID           INT                NOT NULL,
    SplitType                    NVARCHAR(20)       NOT NULL,
    TongTien                     DECIMAL(18,2)      NOT NULL,
    TrangThai                    NVARCHAR(20)       NOT NULL CONSTRAINT DF_NhomChiaTien_TrangThai DEFAULT (N'DRAFT'),
    ExpiresAt                    DATETIME           NULL,
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_NhomChiaTien_CreatedAt DEFAULT (getdate()),
    UpdatedAt                    DATETIME           NOT NULL CONSTRAINT DF_NhomChiaTien_UpdatedAt DEFAULT (getdate()),
    CONSTRAINT PK_NhomChiaTien PRIMARY KEY (NhomChiaTienID)
);
GO

-- ---------- NhomChiaTienChiTiet — Phần chia của từng người ----------
IF OBJECT_ID('dbo.NhomChiaTienChiTiet','U') IS NULL
CREATE TABLE dbo.NhomChiaTienChiTiet (
    ChiTietID                    INT                IDENTITY(1,1) NOT NULL,
    NhomChiaTienID               INT                NOT NULL,
    AccountID                    INT                NULL,
    DisplayName                  NVARCHAR(100)      NOT NULL,
    ShareToken                   CHAR(43)           NOT NULL,
    SoTien                       DECIMAL(18,2)      NOT NULL,
    TrangThai                    NVARCHAR(20)       NOT NULL CONSTRAINT DF_NhomChiaTienChiTiet_TrangThai DEFAULT (N'PENDING'),
    PaymentMethod                NVARCHAR(30)       NULL,
    PaymentTransactionID         NVARCHAR(100)      NULL,
    PayerAccountID               INT                NULL,
    PaidAt                       DATETIME           NULL,
    ConfirmedByStaffID           INT                NULL,
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_NhomChiaTienChiTiet_CreatedAt DEFAULT (getdate()),
    UpdatedAt                    DATETIME           NOT NULL CONSTRAINT DF_NhomChiaTienChiTiet_UpdatedAt DEFAULT (getdate()),
    CONSTRAINT PK_NhomChiaTienChiTiet PRIMARY KEY (ChiTietID)
);
GO

-- ---------- PayOSPaymentAttempt — Lượt thanh toán PayOS ----------
IF OBJECT_ID('dbo.PayOSPaymentAttempt','U') IS NULL
CREATE TABLE dbo.PayOSPaymentAttempt (
    AttemptID                    BIGINT             IDENTITY(1,1) NOT NULL,
    HoaDonID                     INT                NOT NULL,
    DatSanID                     INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    OrderCode                    BIGINT             NOT NULL,
    PaymentLinkID                NVARCHAR(100)      NULL,
    CheckoutUrl                  NVARCHAR(1000)     NULL,
    QrCode                       NVARCHAR(MAX)      NULL,
    Status                       NVARCHAR(30)       NOT NULL,
    Amount                       DECIMAL(18,2)      NOT NULL,
    Description                  NVARCHAR(100)      NOT NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_PayOSPaymentAttempt_CreatedAt DEFAULT (sysdatetime()),
    PaidAt                       DATETIME2          NULL,
    CancelledAt                  DATETIME2          NULL,
    LastCheckedAt                DATETIME2          NULL,
    FailureReason                NVARCHAR(500)      NULL,
    CONSTRAINT PK_PayOSPaymentAttempt PRIMARY KEY (AttemptID)
);
GO

-- ---------- QRRequest — Yêu cầu từ QR ----------
IF OBJECT_ID('dbo.QRRequest','U') IS NULL
CREATE TABLE dbo.QRRequest (
    RequestID                    INT                IDENTITY(1,1) NOT NULL,
    SanID                        INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    GuestToken                   VARCHAR(64)        NOT NULL,
    CustomerID                   INT                NULL,
    RequestType                  VARCHAR(20)        NOT NULL,
    ItemsJson                    NVARCHAR(MAX)      NULL,
    Note                         NVARCHAR(255)      NULL,
    Status                       VARCHAR(20)        NOT NULL CONSTRAINT DF_QRRequest_Status DEFAULT ('NEW'),
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_QRRequest_CreatedAt DEFAULT (getdate()),
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_QRRequest_UpdatedAt DEFAULT (getdate()),
    HandledByStaffID             INT                NULL,
    CONSTRAINT PK_QRRequest PRIMARY KEY (RequestID)
);
GO

-- ---------- RacketStringingConfig — Cấu hình căng vợt ----------
IF OBJECT_ID('dbo.RacketStringingConfig','U') IS NULL
CREATE TABLE dbo.RacketStringingConfig (
    ConfigID                     INT                IDENTITY(1,1) NOT NULL,
    ServiceID                    INT                NOT NULL,
    RacketTypes                  NVARCHAR(300)      NULL,
    StringingPrice               DECIMAL(12,2)      NOT NULL CONSTRAINT DF_RacketStringingConfig_StringingPrice DEFAULT ((0)),
    MinTension                   DECIMAL(5,2)       NOT NULL,
    MaxTension                   DECIMAL(5,2)       NOT NULL,
    TensionUnit                  NVARCHAR(5)        NOT NULL CONSTRAINT DF_RacketStringingConfig_TensionUnit DEFAULT (N'kg'),
    AllowCustomerString          BIT                NOT NULL CONSTRAINT DF_RacketStringingConfig_AllowCustomerString DEFAULT ((1)),
    SellsString                  BIT                NOT NULL CONSTRAINT DF_RacketStringingConfig_SellsString DEFAULT ((1)),
    AvgCompletionMinutes         INT                NOT NULL CONSTRAINT DF_RacketStringingConfig_AvgCompletionMinutes DEFAULT ((60)),
    MaxRacketsPerOrder           INT                NOT NULL CONSTRAINT DF_RacketStringingConfig_MaxRacketsPerOrder DEFAULT ((5)),
    OldRacketPolicy              NVARCHAR(500)      NULL,
    StringBreakPolicy            NVARCHAR(500)      NULL,
    CONSTRAINT PK_RacketStringingConfig PRIMARY KEY (ConfigID)
);
GO

-- ---------- RacketStringingOrderDetail — Chi tiết đơn căng vợt ----------
IF OBJECT_ID('dbo.RacketStringingOrderDetail','U') IS NULL
CREATE TABLE dbo.RacketStringingOrderDetail (
    DetailID                     INT                IDENTITY(1,1) NOT NULL,
    OrderID                      INT                NOT NULL,
    RacketType                   NVARCHAR(50)       NULL,
    RacketBrand                  NVARCHAR(100)      NULL,
    RacketModel                  NVARCHAR(100)      NULL,
    MaterialID                   INT                NULL,
    CustomerBringsString         BIT                NOT NULL CONSTRAINT DF_RacketStringingOrderDetail_CustomerBringsString DEFAULT ((0)),
    TensionValue                 DECIMAL(5,2)       NOT NULL,
    TensionUnit                  NVARCHAR(5)        NOT NULL CONSTRAINT DF_RacketStringingOrderDetail_TensionUnit DEFAULT (N'kg'),
    StringColor                  NVARCHAR(50)       NULL,
    Quantity                     INT                NOT NULL CONSTRAINT DF_RacketStringingOrderDetail_Quantity DEFAULT ((1)),
    TechnicalNote                NVARCHAR(500)      NULL,
    CONSTRAINT PK_RacketStringingOrderDetail PRIMARY KEY (DetailID)
);
GO

-- ---------- Roles — Vai trò ----------
IF OBJECT_ID('dbo.Roles','U') IS NULL
CREATE TABLE dbo.Roles (
    RoleID                       INT                IDENTITY(1,1) NOT NULL,
    RoleName                     NVARCHAR(50)       NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleID)
);
GO

-- ---------- San — Sân ----------
IF OBJECT_ID('dbo.San','U') IS NULL
CREATE TABLE dbo.San (
    SanID                        INT                IDENTITY(1,1) NOT NULL,
    TenSan                       NVARCHAR(50)       NOT NULL,
    LoaiSanID                    INT                NULL,
    CoSoID                       INT                NOT NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_San_TrangThai DEFAULT (N'Sẵn sàng'),
    MoTa                         NVARCHAR(MAX)      NULL,
    HinhAnh                      NVARCHAR(500)      NULL,
    IsDeleted                    BIT                NULL CONSTRAINT DF_San_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    CONSTRAINT PK_San PRIMARY KEY (SanID)
);
GO

-- ---------- SanPham_DichVu — Sản phẩm & dịch vụ ----------
IF OBJECT_ID('dbo.SanPham_DichVu','U') IS NULL
CREATE TABLE dbo.SanPham_DichVu (
    SanPhamID                    INT                IDENTITY(1,1) NOT NULL,
    DanhMucID                    INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    TenSanPham                   NVARCHAR(100)      NOT NULL,
    DonGia                       FLOAT              NULL,
    DonViTinh                    NVARCHAR(20)       NULL,
    SoLuongTon                   INT                NULL CONSTRAINT DF_SanPham_DichVu_SoLuongTon DEFAULT ((0)),
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_SanPham_DichVu_TrangThai DEFAULT (N'Đang kinh doanh'),
    SkuCode                      NVARCHAR(50)       NULL,
    GiaNhap                      FLOAT              NULL,
    MoTa                         NVARCHAR(255)      NULL,
    IsDeleted                    BIT                NULL CONSTRAINT DF_SanPham_DichVu_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    HinhAnh                      NVARCHAR(500)      NULL,
    CONSTRAINT PK_SanPham_DichVu PRIMARY KEY (SanPhamID)
);
GO

-- ---------- SanQR — Mã QR sân ----------
IF OBJECT_ID('dbo.SanQR','U') IS NULL
CREATE TABLE dbo.SanQR (
    SanQRID                      INT                IDENTITY(1,1) NOT NULL,
    SanID                        INT                NOT NULL,
    Token                        UNIQUEIDENTIFIER   NOT NULL CONSTRAINT DF_SanQR_Token DEFAULT (newid()),
    TrangThai                    NVARCHAR(20)       NOT NULL CONSTRAINT DF_SanQR_TrangThai DEFAULT (N'ACTIVE'),
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_SanQR_CreatedAt DEFAULT (sysutcdatetime()),
    CreatedBy                    INT                NULL,
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_SanQR_UpdatedAt DEFAULT (sysutcdatetime()),
    UpdatedBy                    INT                NULL,
    RegenerateCount              INT                NOT NULL CONSTRAINT DF_SanQR_RegenerateCount DEFAULT ((0)),
    ShortCode                    NVARCHAR(12)       NULL,
    CONSTRAINT PK_SanQR PRIMARY KEY (SanQRID)
);
GO

-- ---------- SanQRTokenHistory — Lịch sử token QR ----------
IF OBJECT_ID('dbo.SanQRTokenHistory','U') IS NULL
CREATE TABLE dbo.SanQRTokenHistory (
    HistoryID                    INT                IDENTITY(1,1) NOT NULL,
    SanQRID                      INT                NOT NULL,
    SanID                        INT                NOT NULL,
    Token                        UNIQUEIDENTIFIER   NULL,
    TrangThai                    NVARCHAR(20)       NOT NULL CONSTRAINT DF_SanQRTokenHistory_TrangThai DEFAULT (N'ISSUED'),
    IssuedAt                     DATETIME2          NOT NULL CONSTRAINT DF_SanQRTokenHistory_IssuedAt DEFAULT (sysutcdatetime()),
    RevokedAt                    DATETIME2          NULL,
    RevokedBy                    INT                NULL,
    RevokeReason                 NVARCHAR(200)      NULL,
    TokenHash                    NVARCHAR(64)       NULL,
    ShortCode                    NVARCHAR(12)       NULL,
    CONSTRAINT PK_SanQRTokenHistory PRIMARY KEY (HistoryID)
);
GO

-- ---------- ServiceMaterial — Vật tư dịch vụ ----------
IF OBJECT_ID('dbo.ServiceMaterial','U') IS NULL
CREATE TABLE dbo.ServiceMaterial (
    MaterialID                   INT                IDENTITY(1,1) NOT NULL,
    CoSoID                       INT                NOT NULL,
    Name                         NVARCHAR(150)      NOT NULL,
    Brand                        NVARCHAR(100)      NULL,
    Code                         NVARCHAR(50)       NULL,
    Color                        NVARCHAR(50)       NULL,
    SportType                    NVARCHAR(50)       NULL,
    Price                        DECIMAL(12,2)      NOT NULL CONSTRAINT DF_ServiceMaterial_Price DEFAULT ((0)),
    ExtraFee                     DECIMAL(12,2)      NOT NULL CONSTRAINT DF_ServiceMaterial_ExtraFee DEFAULT ((0)),
    Status                       NVARCHAR(20)       NOT NULL CONSTRAINT DF_ServiceMaterial_Status DEFAULT (N'DANG_CO'),
    Description                  NVARCHAR(500)      NULL,
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_ServiceMaterial_IsDeleted DEFAULT ((0)),
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_ServiceMaterial_CreatedAt DEFAULT (sysutcdatetime()),
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_ServiceMaterial_UpdatedAt DEFAULT (sysutcdatetime()),
    CONSTRAINT PK_ServiceMaterial PRIMARY KEY (MaterialID)
);
GO

-- ---------- ServiceOrder — Đơn dịch vụ ----------
IF OBJECT_ID('dbo.ServiceOrder','U') IS NULL
CREATE TABLE dbo.ServiceOrder (
    OrderID                      INT                IDENTITY(1,1) NOT NULL,
    CustomerID                   INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    ServiceID                    INT                NOT NULL,
    BookingID                    INT                NULL,
    Status                       NVARCHAR(30)       NOT NULL CONSTRAINT DF_ServiceOrder_Status DEFAULT (N'PENDING_CONFIRMATION'),
    RequestedAt                  DATETIME2          NOT NULL CONSTRAINT DF_ServiceOrder_RequestedAt DEFAULT (sysutcdatetime()),
    AppointmentDate              DATE               NOT NULL,
    DropOffTime                  NVARCHAR(20)       NULL,
    ExpectedPickupTime           DATETIME2          NULL,
    ActualReceivedTime           DATETIME2          NULL,
    CompletedTime                DATETIME2          NULL,
    DeliveredTime                DATETIME2          NULL,
    CancelledTime                DATETIME2          NULL,
    CustomerNote                 NVARCHAR(500)      NULL,
    ManagerNote                  NVARCHAR(500)      NULL,
    EstimatedPrice               DECIMAL(12,2)      NOT NULL CONSTRAINT DF_ServiceOrder_EstimatedPrice DEFAULT ((0)),
    ConfirmedPrice               DECIMAL(12,2)      NULL,
    CancellationReason           NVARCHAR(500)      NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_ServiceOrder_CreatedAt DEFAULT (sysutcdatetime()),
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_ServiceOrder_UpdatedAt DEFAULT (sysutcdatetime()),
    CONSTRAINT PK_ServiceOrder PRIMARY KEY (OrderID)
);
GO

-- ---------- ServiceOrderStatusHistory — Lịch sử trạng thái đơn dịch vụ ----------
IF OBJECT_ID('dbo.ServiceOrderStatusHistory','U') IS NULL
CREATE TABLE dbo.ServiceOrderStatusHistory (
    HistoryID                    INT                IDENTITY(1,1) NOT NULL,
    OrderID                      INT                NOT NULL,
    FromStatus                   NVARCHAR(30)       NULL,
    ToStatus                     NVARCHAR(30)       NOT NULL,
    ChangedBy                    INT                NULL,
    ChangedAt                    DATETIME2          NOT NULL CONSTRAINT DF_ServiceOrderStatusHistory_ChangedAt DEFAULT (sysutcdatetime()),
    Note                         NVARCHAR(500)      NULL,
    CONSTRAINT PK_ServiceOrderStatusHistory PRIMARY KEY (HistoryID)
);
GO

-- ---------- SoftHold — Giữ chỗ tạm thời ----------
IF OBJECT_ID('dbo.SoftHold','U') IS NULL
CREATE TABLE dbo.SoftHold (
    SoftHoldID                   INT                NOT NULL,
    AccountID                    INT                NOT NULL,
    SanID                        INT                NOT NULL,
    NgayDat                      DATE               NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    CreatedTime                  DATETIME           NOT NULL CONSTRAINT DF_SoftHold_CreatedTime DEFAULT (getdate()),
    CONSTRAINT PK_SoftHold PRIMARY KEY (SoftHoldID)
);
GO

-- ---------- SportService — Dịch vụ thể thao ----------
IF OBJECT_ID('dbo.SportService','U') IS NULL
CREATE TABLE dbo.SportService (
    ServiceID                    INT                IDENTITY(1,1) NOT NULL,
    CoSoID                       INT                NOT NULL,
    ServiceType                  NVARCHAR(30)       NOT NULL,
    ServiceName                  NVARCHAR(150)      NOT NULL,
    SportType                    NVARCHAR(50)       NULL,
    Description                  NVARCHAR(1000)     NULL,
    BasePrice                    DECIMAL(12,2)      NOT NULL CONSTRAINT DF_SportService_BasePrice DEFAULT ((0)),
    Unit                         NVARCHAR(30)       NULL,
    EstimatedMinutes             INT                NOT NULL CONSTRAINT DF_SportService_EstimatedMinutes DEFAULT ((60)),
    MaxRequestsPerDay            INT                NULL,
    ReceiveTimeStart             TIME               NULL,
    ReceiveTimeEnd               TIME               NULL,
    ImageUrl                     NVARCHAR(300)      NULL,
    IsAcceptingRequests          BIT                NOT NULL CONSTRAINT DF_SportService_IsAcceptingRequests DEFAULT ((1)),
    Policy                       NVARCHAR(1000)     NULL,
    CustomerNote                 NVARCHAR(500)      NULL,
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_SportService_IsDeleted DEFAULT ((0)),
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_SportService_CreatedAt DEFAULT (sysutcdatetime()),
    UpdatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_SportService_UpdatedAt DEFAULT (sysutcdatetime()),
    CONSTRAINT PK_SportService PRIMARY KEY (ServiceID)
);
GO

-- ---------- SuCo — Sự cố ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.SuCo','U') IS NULL
CREATE TABLE dbo.SuCo (
    SuCoID                       INT                NULL,  -- [MIGRATION-ONLY]
    CoSoID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    SanID                        INT                NULL,  -- [MIGRATION-ONLY]
    BaoVeID                      INT                NOT NULL,  -- [MIGRATION-ONLY]
    LoaiSuCo                     ENUM               NOT NULL,  -- [MIGRATION-ONLY]
    MucDo                        ENUM               NOT NULL CONSTRAINT DF_SuCo_MucDo DEFAULT ('THAP'),  -- [MIGRATION-ONLY]
    MoTa                         TEXT               NOT NULL,  -- [MIGRATION-ONLY]
    AnhUrl                       VARCHAR(500)       NULL,  -- [MIGRATION-ONLY]
    TrangThai                    ENUM               NOT NULL CONSTRAINT DF_SuCo_TrangThai DEFAULT ('CHO_XU_LY'),  -- [MIGRATION-ONLY]
    GhiChuXuLy                   TEXT               NULL,  -- [MIGRATION-ONLY]
    ThoiGianTao                  DATETIME           NOT NULL CONSTRAINT DF_SuCo_ThoiGianTao DEFAULT (CURRENT_TIMESTAMP),  -- [MIGRATION-ONLY]
    ThoiGianXuLy                 DATETIME           NULL,  -- [MIGRATION-ONLY]
    XuLyBoi                      INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_SuCo PRIMARY KEY (SuCoID)
);
GO

-- Bỏ qua bảng hệ thống dbo.sysdiagrams (do SSMS sinh ra).

-- ---------- TeamInvitations — Lời mời vào đội ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.TeamInvitations','U') IS NULL
CREATE TABLE dbo.TeamInvitations (
    InvitationID                 INT                IDENTITY(1,1) NOT NULL,  -- [MIGRATION-ONLY]
    TeamID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    InvitedAccountID             INT                NOT NULL,  -- [MIGRATION-ONLY]
    InvitedByAccountID           INT                NOT NULL,  -- [MIGRATION-ONLY]
    ProposedRole                 VARCHAR(30)        NOT NULL CONSTRAINT DF_TeamInvitations_ProposedRole DEFAULT ('MEMBER'),  -- [MIGRATION-ONLY]
    Status                       VARCHAR(30)        NOT NULL CONSTRAINT DF_TeamInvitations_Status DEFAULT ('PENDING'),  -- [MIGRATION-ONLY]
    Message                      NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_TeamInvitations_CreatedAt DEFAULT (SYSUTCDATETIME(),  -- [MIGRATION-ONLY]
    ExpiresAt                    DATETIME2          NULL,  -- [MIGRATION-ONLY]
    RespondedAt                  DATETIME2          NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_TeamInvitations PRIMARY KEY (InvitationID)
);
GO

-- ---------- TeamJoinRequests — Yêu cầu xin vào đội ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.TeamJoinRequests','U') IS NULL
CREATE TABLE dbo.TeamJoinRequests (
    JoinRequestID                INT                IDENTITY(1,1) NOT NULL,  -- [MIGRATION-ONLY]
    TeamID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    RequesterAccountID           INT                NOT NULL,  -- [MIGRATION-ONLY]
    Message                      NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    Status                       VARCHAR(30)        NOT NULL CONSTRAINT DF_TeamJoinRequests_Status DEFAULT ('PENDING'),  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_TeamJoinRequests_CreatedAt DEFAULT (SYSUTCDATETIME(),  -- [MIGRATION-ONLY]
    ReviewedAt                   DATETIME2          NULL,  -- [MIGRATION-ONLY]
    ReviewedByAccountID          INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_TeamJoinRequests PRIMARY KEY (JoinRequestID)
);
GO

-- ---------- TeamMembers — Thành viên đội ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.TeamMembers','U') IS NULL
CREATE TABLE dbo.TeamMembers (
    TeamMemberID                 INT                IDENTITY(1,1) NOT NULL,  -- [MIGRATION-ONLY]
    TeamID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    MemberRole                   VARCHAR(30)        NOT NULL,  -- [MIGRATION-ONLY]
    MemberStatus                 VARCHAR(30)        NOT NULL CONSTRAINT DF_TeamMembers_MemberStatus DEFAULT ('ACTIVE'),  -- [MIGRATION-ONLY]
    JoinedAt                     DATETIME2          NOT NULL CONSTRAINT DF_TeamMembers_JoinedAt DEFAULT (SYSUTCDATETIME(),  -- [MIGRATION-ONLY]
    LeftAt                       DATETIME2          NULL,  -- [MIGRATION-ONLY]
    AddedBy                      INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_TeamMembers PRIMARY KEY (TeamMemberID)
);
GO

-- ---------- Teams — Đội nhóm ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.Teams','U') IS NULL
CREATE TABLE dbo.Teams (
    TeamID                       INT                IDENTITY(1,1) NOT NULL,  -- [MIGRATION-ONLY]
    TeamName                     NVARCHAR(50)       NOT NULL,  -- [MIGRATION-ONLY]
    Description                  NVARCHAR(225)      NULL,  -- [MIGRATION-ONLY]
    SportID                      INT                NOT NULL,  -- [MIGRATION-ONLY]
    CaptainAccountID             INT                NOT NULL,  -- [MIGRATION-ONLY]
    LocationText                 NVARCHAR(255)      NULL,  -- [MIGRATION-ONLY]
    AvatarPath                   NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    CoverImagePath               NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    MaxMembers                   INT                NOT NULL,  -- [MIGRATION-ONLY]
    Status                       VARCHAR(30)        NOT NULL CONSTRAINT DF_Teams_Status DEFAULT ('ACTIVE'),  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_Teams_CreatedAt DEFAULT (SYSUTCDATETIME(),  -- [MIGRATION-ONLY]
    UpdatedAt                    DATETIME2          NULL,  -- [MIGRATION-ONLY]
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_Teams_IsDeleted DEFAULT (0),  -- [MIGRATION-ONLY]
    DeletedAt                    DATETIME2          NULL,  -- [MIGRATION-ONLY]
    DeletedBy                    INT                NULL,  -- [MIGRATION-ONLY]
    CONSTRAINT PK_Teams PRIMARY KEY (TeamID)
);
GO

-- ---------- TheGiuXe — Thẻ giữ xe ----------
IF OBJECT_ID('dbo.TheGiuXe','U') IS NULL
CREATE TABLE dbo.TheGiuXe (
    TheID                        INT                IDENTITY(1,1) NOT NULL,
    CoSoID                       INT                NOT NULL,
    MaSoThe                      VARCHAR(20)        NOT NULL,
    LoaiXe                       NVARCHAR(20)       NULL,
    TrangThai                    NVARCHAR(20)       NULL CONSTRAINT DF_TheGiuXe_TrangThai DEFAULT (N'Trống'),
    SucChua                      INT                NULL,
    GiaVeTheoLuot                DECIMAL(18,2)      NULL CONSTRAINT DF_TheGiuXe_GiaVeTheoLuot DEFAULT ((0)),
    CONSTRAINT PK_TheGiuXe PRIMARY KEY (TheID)
);
GO

-- ---------- ThongBao — Thông báo ----------
IF OBJECT_ID('dbo.ThongBao','U') IS NULL
CREATE TABLE dbo.ThongBao (
    ThongBaoID                   INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NOT NULL,
    TieuDe                       NVARCHAR(200)      NOT NULL,
    NoiDung                      NVARCHAR(MAX)      NULL,
    LoaiThongBao                 NVARCHAR(50)       NULL,
    DaDoc                        BIT                NULL CONSTRAINT DF_ThongBao_DaDoc DEFAULT ((0)),
    ThoiGianGui                  DATETIME           NULL CONSTRAINT DF_ThongBao_ThoiGianGui DEFAULT (getdate()),
    MaBanGhi                     INT                NULL,
    DuongDan                     VARCHAR(500)       NULL,
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_ThongBao_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    CONSTRAINT PK_ThongBao PRIMARY KEY (ThongBaoID)
);
GO

-- ---------- YeuCauNghi — Yêu cầu nghỉ phép ----------
IF OBJECT_ID('dbo.YeuCauNghi','U') IS NULL
CREATE TABLE dbo.YeuCauNghi (
    YeuCauNghiID                 INT                NOT NULL,
    AccountID                    INT                NOT NULL,
    CoSoID                       INT                NOT NULL,
    NgayNghi                     DATE               NOT NULL,
    LoaiNghi                     VARCHAR(50)        NOT NULL,
    LyDo                         NVARCHAR(500)      NULL,
    MucDoKhanCap                 BIT                NULL CONSTRAINT DF_YeuCauNghi_MucDoKhanCap DEFAULT ((0)),
    TrangThai                    VARCHAR(20)        NOT NULL CONSTRAINT DF_YeuCauNghi_TrangThai DEFAULT ('ChoDuyet'),
    GhiChuQuanLy                 NVARCHAR(500)      NULL,
    NgayXuLy                     DATETIME           NULL,
    XuLyBy                       INT                NULL,
    NgayGui                      DATETIME           NULL CONSTRAINT DF_YeuCauNghi_NgayGui DEFAULT (getdate()),
    CreatedAt                    DATETIME           NULL CONSTRAINT DF_YeuCauNghi_CreatedAt DEFAULT (getdate()),
    UpdatedAt                    DATETIME           NULL CONSTRAINT DF_YeuCauNghi_UpdatedAt DEFAULT (getdate()),
    QuanLyXuLy                   VARCHAR(255)       NULL,
    RoleName                     VARCHAR(255)       NULL,
    SoCaBiAnhHuong               INT                NULL,
    TenCoSo                      VARCHAR(255)       NULL,
    TenNhanVien                  VARCHAR(255)       NULL,
    username                     VARCHAR(255)       NULL,
    IsDeleted                    BIT                NOT NULL CONSTRAINT DF_YeuCauNghi_IsDeleted DEFAULT ((0)),
    DeletedAt                    DATETIME           NULL,
    DeletedBy                    INT                NULL,
    CONSTRAINT PK_YeuCauNghi PRIMARY KEY (YeuCauNghiID)
);
GO

-- ---------- YeuCauNghi_Audit — Nhật ký nghỉ phép ----------
IF OBJECT_ID('dbo.YeuCauNghi_Audit','U') IS NULL
CREATE TABLE dbo.YeuCauNghi_Audit (
    AuditID                      INT                NOT NULL,
    YeuCauNghiID                 INT                NOT NULL,
    ThaoTac                      VARCHAR(50)        NOT NULL,
    NguoiThucHien                INT                NOT NULL,
    ThoiGian                     DATETIME           NULL CONSTRAINT DF_YeuCauNghi_Audit_ThoiGian DEFAULT (getdate()),
    GiaTriCu                     NVARCHAR(MAX)      NULL,
    GiaTriMoi                    NVARCHAR(MAX)      NULL,
    CONSTRAINT PK_YeuCauNghi_Audit PRIMARY KEY (AuditID)
);
GO

-- ---------- YeuCauSOS — Yêu cầu SOS ----------
IF OBJECT_ID('dbo.YeuCauSOS','U') IS NULL
CREATE TABLE dbo.YeuCauSOS (
    YeuCauSOSID                  INT                IDENTITY(1,1) NOT NULL,
    AccountID_Tao                INT                NOT NULL,
    DatSanID                     INT                NULL,
    MonTheThaoID                 INT                NULL,
    SoNguoiCanTuyen              INT                NOT NULL,
    ViTriCanTuyen                NVARCHAR(100)      NULL,
    GhiChu                       NVARCHAR(MAX)      NULL,
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_YeuCauSOS_TrangThai DEFAULT (N'Đang tuyển'),
    ThoiGianTao                  DATETIME           NULL CONSTRAINT DF_YeuCauSOS_ThoiGianTao DEFAULT (getdate()),
    CONSTRAINT PK_YeuCauSOS PRIMARY KEY (YeuCauSOSID)
);
GO

-- ---------- YeuCauUngLuong — Yêu cầu ứng lương ----------
-- [MIGRATION-ONLY] Bảng chưa có trong snapshot DB 2026-08-02.
IF OBJECT_ID('dbo.YeuCauUngLuong','U') IS NULL
CREATE TABLE dbo.YeuCauUngLuong (
    YeuCauUngLuongID             INT                IDENTITY(1,1) NULL,  -- [MIGRATION-ONLY]
    AccountID                    INT                NOT NULL,  -- [MIGRATION-ONLY]
    CoSoID                       INT                NOT NULL,  -- [MIGRATION-ONLY]
    SoTienUng                    DECIMAL(18,0)      NOT NULL,  -- [MIGRATION-ONLY]
    LyDo                         NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    TrangThai                    VARCHAR(20)        NOT NULL CONSTRAINT DF_YeuCauUngLuong_TrangThai DEFAULT ('ChoDuyet'),  -- [MIGRATION-ONLY]
    GhiChuQuanLy                 NVARCHAR(500)      NULL,  -- [MIGRATION-ONLY]
    XuLyBy                       INT                NULL,  -- [MIGRATION-ONLY]
    NgayXuLy                     DATETIME           NULL,  -- [MIGRATION-ONLY]
    CreatedAt                    DATETIME           NOT NULL CONSTRAINT DF_YeuCauUngLuong_CreatedAt DEFAULT (GETDATE()),  -- [MIGRATION-ONLY]
    CONSTRAINT PK_YeuCauUngLuong PRIMARY KEY (YeuCauUngLuongID)
);
GO

-- ============================================================
-- UNIQUE constraints / unique indexes
-- ============================================================
CREATE UNIQUE INDEX UQ_Accounts_Email ON dbo.Accounts (Email);
CREATE UNIQUE INDEX UQ_Accounts_Facebook ON dbo.Accounts (FacebookID);
CREATE UNIQUE INDEX UQ_Accounts_FacebookID ON dbo.Accounts (FacebookID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ_Accounts_Google ON dbo.Accounts (GoogleID);
CREATE UNIQUE INDEX UQ_Accounts_GoogleID ON dbo.Accounts (GoogleID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ_Accounts_Username ON dbo.Accounts (Username);
CREATE UNIQUE INDEX UQ_BangLuong_Ky_Account ON dbo.BangLuong (KyLuongID, AccountID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ_CauHinhLuong_Account_CoSo ON dbo.CauHinhLuong (AccountID, CoSoID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UX_ChiTietGhepKeo_Active_Keo_Account ON dbo.ChiTietGhepKeo (KeoID, AccountIDNguoiThamGia);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ_CoSoCapability_CoSo_Type ON dbo.CoSoCapability (CoSoID, CapabilityType);
CREATE UNIQUE INDEX UX_CourtChargeSegment_InvoiceOrder ON dbo.CourtChargeSegment (HoaDonID, SegmentOrder);
CREATE UNIQUE INDEX UQ_ReputationHistory_Account_DatSan_Action ON dbo.CustomerReputationHistory (AccountID, DatSanID, ActionType);
CREATE UNIQUE INDEX UQ_DanhGia_DatSan_Account ON dbo.DanhGia (DatSanID, AccountID_NguoiDanhGia);
CREATE UNIQUE INDEX UX_HoaDon_OneMainPerBooking ON dbo.HoaDon (DatSanID);
CREATE UNIQUE INDEX UQ_KhuyenMai_MaCode ON dbo.KhuyenMai (MaCode);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ__KhuyenMa__152C7C5C7613DE24 ON dbo.KhuyenMai (MaCode);
CREATE UNIQUE INDEX UQ_KhuyenMaiHinhAnh_MotAnhBia ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID);
CREATE UNIQUE INDEX UX_NhomChiaTien_HoaDon_Active ON dbo.NhomChiaTien (HoaDonID);
CREATE UNIQUE INDEX UX_NhomChiaTienChiTiet_ShareToken ON dbo.NhomChiaTienChiTiet (ShareToken);
CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice ON dbo.PayOSPaymentAttempt (HoaDonID);
CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode ON dbo.PayOSPaymentAttempt (OrderCode);
CREATE UNIQUE INDEX UQ_RacketCfg_ServiceID ON dbo.RacketStringingConfig (ServiceID);
CREATE UNIQUE INDEX UQ_RSOD_OrderID ON dbo.RacketStringingOrderDetail (OrderID);
CREATE UNIQUE INDEX UQ_SanQR_SanID ON dbo.SanQR (SanID);
CREATE UNIQUE INDEX UQ_SanQR_ShortCode ON dbo.SanQR (ShortCode);
CREATE UNIQUE INDEX UQ_SanQR_Token ON dbo.SanQR (Token);
CREATE UNIQUE INDEX UQ_SanQRTokenHistory_Token ON dbo.SanQRTokenHistory (Token);
CREATE UNIQUE INDEX UX_TeamInvitations_Pending_Team_Account ON dbo.TeamInvitations (TeamID, InvitedAccountID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UX_TeamJoinRequests_Pending_Team_Account ON dbo.TeamJoinRequests (TeamID, RequesterAccountID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UX_TeamMembers_Active_Team_Account ON dbo.TeamMembers (TeamID, AccountID);  -- [MIGRATION-ONLY]
CREATE UNIQUE INDEX UQ_ThongBao_Account_Loai_MaBanGhi ON dbo.ThongBao (AccountID, LoaiThongBao, MaBanGhi);
GO

-- ============================================================
-- FOREIGN KEYS
-- ON DELETE/ON UPDATE: snapshot không chứa thông tin này; mặc định
-- SQL Server là NO ACTION. Không suy đoán CASCADE.
-- ============================================================
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Acc_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Acc_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID);
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_MonTheThaoYeuThich FOREIGN KEY (MonTheThaoYeuThichID) REFERENCES dbo.MonTheThao(MonTheThaoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.BangLuong ADD CONSTRAINT FK_BangLuong_AccountID FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.BangLuong ADD CONSTRAINT FK_BangLuong_KyLuongID FOREIGN KEY (KyLuongID) REFERENCES dbo.KyLuong(KyLuongID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.BookingExtension ADD CONSTRAINT FK_BookingExtension_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.BookingExtension ADD CONSTRAINT FK_BookingExtension_Operator FOREIGN KEY (OperatorAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.CaLamViec ADD CONSTRAINT FK_Ca_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec ADD CONSTRAINT FK_Ca_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CaLamViec_Audit ADD CONSTRAINT FK__CaLamViec__Nguoi__5CA1C101 FOREIGN KEY (NguoiThucHien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_Availability ADD CONSTRAINT FK__CaLamViec__Accou__4F47C5E3 FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_Availability ADD CONSTRAINT FK__CaLamViec__CoSoI__503BEA1C FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK__CaLamViec__Accou__55009F39 FOREIGN KEY (AccountID_Gui) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK__CaLamViec__Accou__55F4C372 FOREIGN KEY (AccountID_Nhan) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK__CaLamViec__CaLam__56E8E7AB FOREIGN KEY (CaLamViecID_Gui) REFERENCES dbo.CaLamViec(CaLamViecID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK__CaLamViec__CaLam__57DD0BE4 FOREIGN KEY (CaLamViecID_Nhan) REFERENCES dbo.CaLamViec(CaLamViecID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK__CaLamViec__Nguoi__58D1301D FOREIGN KEY (NguoiDuyet) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CauHinhLuong ADD CONSTRAINT FK_CauHinhLuong_AccountID FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.CauHinhLuong ADD CONSTRAINT FK_CauHinhLuong_CoSoID FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.ChiTietGhepKeo ADD CONSTRAINT FK_CTGK_Account FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ChiTietGhepKeo ADD CONSTRAINT FK_CTGK_Keo FOREIGN KEY (KeoID) REFERENCES dbo.GhepKeo(KeoID);
ALTER TABLE dbo.ChiTietGhepKeo ADD CONSTRAINT FK_ChiTietGhepKeo_TeamNguoiThamGia FOREIGN KEY (TeamIDNguoiThamGia) REFERENCES dbo.Teams(TeamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.ChiTietHoaDon ADD CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.ChiTietHoaDon ADD CONSTRAINT FK_CTHD_SP FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham_DichVu(SanPhamID);
ALTER TABLE dbo.ChiaHoaDon ADD CONSTRAINT FK_Chia_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.ChiaHoaDon ADD CONSTRAINT FK_Chia_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.CoSo ADD CONSTRAINT FK_CoSo_QuanLy FOREIGN KEY (AccountID_QuanLy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CoSoCapability ADD CONSTRAINT FK_CoSoCapability_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CoSoCapability ADD CONSTRAINT FK_CoSoCapability_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CoSoFaceConfig ADD CONSTRAINT FK_FaceConfig_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.CoSoNganHang ADD CONSTRAINT FK_CoSoNganHang_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT FK_CourtChargeSegment_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT FK_CourtChargeSegment_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_Actor FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.DanhGia ADD CONSTRAINT FK_DanhGia_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.DanhGia ADD CONSTRAINT FK_DanhGia_NguoiBiDanhGia FOREIGN KEY (AccountID_NguoiBiDanhGia) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.DanhGia ADD CONSTRAINT FK_DanhGia_NguoiDanhGia FOREIGN KEY (AccountID_NguoiDanhGia) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.FaceChallengeToken ADD CONSTRAINT FK_FaceToken_Accounts FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_Account FOREIGN KEY (AccountID_NguoiTao) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_TeamNguoiTao FOREIGN KEY (TeamIDNguoiTao) REFERENCES dbo.Teams(TeamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HD_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HD_Khach FOREIGN KEY (AccountID_KhachHang) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HD_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HD_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_Parent FOREIGN KEY (ParentHoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.KhuyenMai ADD CONSTRAINT FK_KM_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.KhuyenMaiHinhAnh ADD CONSTRAINT FK_KhuyenMaiHinhAnh_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.KyLuong ADD CONSTRAINT FK_KyLuong_CoSoID FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.KyLuong ADD CONSTRAINT FK_KyLuong_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_DatSan_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_DatSan_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_CancelledBy FOREIGN KEY (CancelledBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_ConfirmedBy FOREIGN KEY (ConfirmedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan_DichVu ADD CONSTRAINT FK_LDSDV_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.LichDatSan_DichVu ADD CONSTRAINT FK_LDSDV_DeliveredBy FOREIGN KEY (DeliveredBy) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.LichDatSan_DichVu ADD CONSTRAINT FK_LDSDV_SanPham FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham_DichVu(SanPhamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.LichSuELO ADD CONSTRAINT FK_LichSuELO_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichSuELO ADD CONSTRAINT FK_LichSuELO_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.LichSuKhuyenMai ADD CONSTRAINT FK_LichSuKM_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichSuKhuyenMai ADD CONSTRAINT FK_LichSuKM_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.LichXeRaVao ADD CONSTRAINT FK_Xe_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.LichXeRaVao ADD CONSTRAINT FK_Xe_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichXeRaVao ADD CONSTRAINT FK_Xe_The FOREIGN KEY (TheID) REFERENCES dbo.TheGiuXe(TheID);
ALTER TABLE dbo.LoaiSan ADD CONSTRAINT FK_LoaiSan_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.LoaiSan ADD CONSTRAINT FK_LoaiSan_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.MaQR ADD CONSTRAINT FK_QR_Chia FOREIGN KEY (ChiaHoaDonID) REFERENCES dbo.ChiaHoaDon(ChiaHoaDonID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.MonTheThaoYeuThich ADD CONSTRAINT FK_MTTYT_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.MonTheThaoYeuThich ADD CONSTRAINT FK_MTTYT_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.NhatKyChat ADD CONSTRAINT FK_Chat_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.NhatKySOSGui ADD CONSTRAINT FK_SOSGui_Account FOREIGN KEY (AccountID_NhanGui) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.NhatKySOSGui ADD CONSTRAINT FK_SOSGui_YeuCau FOREIGN KEY (YeuCauSOSID) REFERENCES dbo.YeuCauSOS(YeuCauSOSID);
ALTER TABLE dbo.NhomChiaTien ADD CONSTRAINT FK_NhomChiaTien_Creator FOREIGN KEY (CreatedByAccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.NhomChiaTien ADD CONSTRAINT FK_NhomChiaTien_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.NhomChiaTien ADD CONSTRAINT FK_NhomChiaTien_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT FK_NhomChiaTienChiTiet_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT FK_NhomChiaTienChiTiet_Nhom FOREIGN KEY (NhomChiaTienID) REFERENCES dbo.NhomChiaTien(NhomChiaTienID);
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT FK_NhomChiaTienChiTiet_Payer FOREIGN KEY (PayerAccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT FK_NhomChiaTienChiTiet_Staff FOREIGN KEY (ConfirmedByStaffID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.QRRequest ADD CONSTRAINT FK_QRRequest_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.QRRequest ADD CONSTRAINT FK_QRRequest_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.RacketStringingConfig ADD CONSTRAINT FK_RacketCfg_Service FOREIGN KEY (ServiceID) REFERENCES dbo.SportService(ServiceID);
ALTER TABLE dbo.RacketStringingOrderDetail ADD CONSTRAINT FK_RSOD_Material FOREIGN KEY (MaterialID) REFERENCES dbo.ServiceMaterial(MaterialID);
ALTER TABLE dbo.RacketStringingOrderDetail ADD CONSTRAINT FK_RSOD_Order FOREIGN KEY (OrderID) REFERENCES dbo.ServiceOrder(OrderID);
ALTER TABLE dbo.San ADD CONSTRAINT FK_San_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.San ADD CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES dbo.LoaiSan(LoaiSanID);
ALTER TABLE dbo.SanPham_DichVu ADD CONSTRAINT FK_SP_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.SanPham_DichVu ADD CONSTRAINT FK_SP_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES dbo.DanhMucSanPham(DanhMucID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_RevokedBy FOREIGN KEY (RevokedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_SanQR FOREIGN KEY (SanQRID) REFERENCES dbo.SanQR(SanQRID);
ALTER TABLE dbo.ServiceMaterial ADD CONSTRAINT FK_ServiceMaterial_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT FK_ServiceOrder_Booking FOREIGN KEY (BookingID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT FK_ServiceOrder_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT FK_ServiceOrder_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT FK_ServiceOrder_Service FOREIGN KEY (ServiceID) REFERENCES dbo.SportService(ServiceID);
ALTER TABLE dbo.ServiceOrderStatusHistory ADD CONSTRAINT FK_SOSH_ChangedBy FOREIGN KEY (ChangedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ServiceOrderStatusHistory ADD CONSTRAINT FK_SOSH_Order FOREIGN KEY (OrderID) REFERENCES dbo.ServiceOrder(OrderID);
ALTER TABLE dbo.SoftHold ADD CONSTRAINT FK_SoftHold_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SoftHold ADD CONSTRAINT FK_SoftHold_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.SportService ADD CONSTRAINT FK_SportService_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.SuCo ADD CONSTRAINT fk_suco_baove FOREIGN KEY (BaoVeID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.SuCo ADD CONSTRAINT fk_suco_coso FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamInvitations ADD CONSTRAINT FK_TeamInvitations_Invited FOREIGN KEY (InvitedAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamInvitations ADD CONSTRAINT FK_TeamInvitations_InvitedBy FOREIGN KEY (InvitedByAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamInvitations ADD CONSTRAINT FK_TeamInvitations_Team FOREIGN KEY (TeamID) REFERENCES dbo.Teams(TeamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamJoinRequests ADD CONSTRAINT FK_TeamJoinRequests_Requester FOREIGN KEY (RequesterAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamJoinRequests ADD CONSTRAINT FK_TeamJoinRequests_Reviewer FOREIGN KEY (ReviewedByAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamJoinRequests ADD CONSTRAINT FK_TeamJoinRequests_Team FOREIGN KEY (TeamID) REFERENCES dbo.Teams(TeamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamMembers ADD CONSTRAINT FK_TeamMembers_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TeamMembers ADD CONSTRAINT FK_TeamMembers_Team FOREIGN KEY (TeamID) REFERENCES dbo.Teams(TeamID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.Teams ADD CONSTRAINT FK_Teams_Captain FOREIGN KEY (CaptainAccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.Teams ADD CONSTRAINT FK_Teams_Sport FOREIGN KEY (SportID) REFERENCES dbo.MonTheThao(MonTheThaoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.TheGiuXe ADD CONSTRAINT FK_TheGiuXe_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.ThongBao ADD CONSTRAINT FK_TB_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.YeuCauNghi ADD CONSTRAINT FK__YeuCauNgh__Accou__3E1D39E1 FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.YeuCauNghi ADD CONSTRAINT FK__YeuCauNgh__CoSoI__3F115E1A FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.YeuCauNghi ADD CONSTRAINT FK__YeuCauNgh__XuLyB__40058253 FOREIGN KEY (XuLyBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.YeuCauNghi_Audit ADD CONSTRAINT FK__YeuCauNgh__Nguoi__44CA3770 FOREIGN KEY (NguoiThucHien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.YeuCauNghi_Audit ADD CONSTRAINT FK__YeuCauNgh__YeuCa__43D61337 FOREIGN KEY (YeuCauNghiID) REFERENCES dbo.YeuCauNghi(YeuCauNghiID);
ALTER TABLE dbo.YeuCauSOS ADD CONSTRAINT FK_SOS_Account FOREIGN KEY (AccountID_Tao) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.YeuCauSOS ADD CONSTRAINT FK_SOS_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.YeuCauSOS ADD CONSTRAINT FK_SOS_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.YeuCauUngLuong ADD CONSTRAINT FK_YeuCauUngLuong_AccountID FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.YeuCauUngLuong ADD CONSTRAINT FK_YeuCauUngLuong_CoSoID FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);  -- [MIGRATION-ONLY]
ALTER TABLE dbo.YeuCauUngLuong ADD CONSTRAINT FK_YeuCauUngLuong_XuLyBy FOREIGN KEY (XuLyBy) REFERENCES dbo.Accounts(AccountID);  -- [MIGRATION-ONLY]
GO

-- ============================================================
-- CHECK constraints (nguồn: migration SQL; snapshot DB không dump CHECK)
-- ============================================================
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_CanNangKg CHECK (CanNangKg IS NULL OR CanNangKg BETWEEN 20 AND 300);
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_ChieuCaoCm CHECK (ChieuCaoCm IS NULL OR ChieuCaoCm BETWEEN 50 AND 260);
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_TanSuatChoi CHECK (TanSuatChoi IS NULL OR TanSuatChoi IN (N'1 lần/tuần', N'2-3 lần/tuần', N'4+ lần/tuần', N'Không cố định'));
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_TrinhDoChoi CHECK (TrinhDoChoi IS NULL OR TrinhDoChoi IN (N'Mới chơi', N'Cơ bản', N'Trung bình', N'Khá', N'Nâng cao'));
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_Amounts CHECK (HourlyRate >= 0 AND Amount >= 0);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_Duration CHECK (DurationMinutes > 0);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_RateType CHECK (RateType IN (N'WITHOUT_LIGHT', N'WITH_LIGHT'));
ALTER TABLE dbo.DanhGia ADD CONSTRAINT CK_DanhGia_SoSao CHECK (SoSao BETWEEN 1 AND 5);
ALTER TABLE dbo.LichDatSan_DichVu ADD CONSTRAINT CK_LDSDV_Quantity CHECK (Quantity > 0);
ALTER TABLE dbo.LichDatSan_DichVu ADD CONSTRAINT CK_LDSDV_Status CHECK (Status IN (N'Chờ chuẩn bị', N'Đã giao', N'Đã hủy'));
ALTER TABLE dbo.NhomChiaTien ADD CONSTRAINT CK_NhomChiaTien_SplitType CHECK (SplitType IN (N'EQUAL', N'CUSTOM', N'ITEMIZED'));
ALTER TABLE dbo.NhomChiaTien ADD CONSTRAINT CK_NhomChiaTien_TrangThai CHECK (TrangThai IN (N'DRAFT', N'ACTIVE', N'PARTIALLY_PAID', N'PAID', N'CANCELLED', N'EXPIRED'));
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT CK_NhomChiaTienChiTiet_SoTien CHECK (SoTien > 0);
ALTER TABLE dbo.NhomChiaTienChiTiet ADD CONSTRAINT CK_NhomChiaTienChiTiet_TrangThai CHECK (TrangThai IN (N'PENDING', N'PROCESSING', N'PAID', N'CANCELLED', N'EXPIRED'));
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT CK_PayOSPaymentAttempt_x CHECK CheckoutUrl     NVARCHAR(1000) NULL;
ALTER TABLE dbo.QRRequest ADD CONSTRAINT CK_QRRequest_Status CHECK (Status IN ('NEW','IN_PROGRESS','DONE','CANCELLED'));
ALTER TABLE dbo.QRRequest ADD CONSTRAINT CK_QRRequest_Type CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST'));
ALTER TABLE dbo.RacketStringingConfig ADD CONSTRAINT CK_RacketCfg_MaxRackets CHECK (MaxRacketsPerOrder > 0);
ALTER TABLE dbo.RacketStringingConfig ADD CONSTRAINT CK_RacketCfg_StringingPrice CHECK (StringingPrice >= 0);
ALTER TABLE dbo.RacketStringingConfig ADD CONSTRAINT CK_RacketCfg_Tension CHECK (MinTension > 0 AND MaxTension >= MinTension);
ALTER TABLE dbo.RacketStringingConfig ADD CONSTRAINT CK_RacketCfg_TensionUnit CHECK (TensionUnit IN (N'kg', N'lbs'));
ALTER TABLE dbo.RacketStringingOrderDetail ADD CONSTRAINT CK_RSOD_Quantity CHECK (Quantity > 0);
ALTER TABLE dbo.RacketStringingOrderDetail ADD CONSTRAINT CK_RSOD_Tension CHECK (TensionValue > 0);
ALTER TABLE dbo.RacketStringingOrderDetail ADD CONSTRAINT CK_RSOD_TensionUnit CHECK (TensionUnit IN (N'kg', N'lbs'));
ALTER TABLE dbo.ServiceMaterial ADD CONSTRAINT CK_ServiceMaterial_Price CHECK (Price >= 0 AND ExtraFee >= 0);
ALTER TABLE dbo.ServiceMaterial ADD CONSTRAINT CK_ServiceMaterial_Status CHECK (Status IN (N'DANG_CO', N'TAM_HET', N'NGUNG_SU_DUNG'));
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT CK_ServiceOrder_ConfirmedPrice CHECK (ConfirmedPrice IS NULL OR ConfirmedPrice >= 0);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT CK_ServiceOrder_EstPrice CHECK (EstimatedPrice >= 0);
ALTER TABLE dbo.ServiceOrder ADD CONSTRAINT CK_ServiceOrder_Status CHECK (Status IN (N'PENDING_CONFIRMATION', N'CONFIRMED', N'ITEM_RECEIVED', N'IN_PROGRESS', N'READY_FOR_PICKUP', N'COMPLETED', N'CANCELLED', N'REJECTED'));
ALTER TABLE dbo.SportService ADD CONSTRAINT CK_SportService_BasePrice CHECK (BasePrice >= 0);
ALTER TABLE dbo.SportService ADD CONSTRAINT CK_SportService_EstMinutes CHECK (EstimatedMinutes > 0);
ALTER TABLE dbo.SportService ADD CONSTRAINT CK_SportService_ServiceType CHECK (ServiceType IN (N'CANG_LUOI', N'THAY_QUAN_CAN', N'SUA_VOT', N'BAO_DUONG', N'HUAN_LUYEN_VIEN', N'KHAC'));
ALTER TABLE dbo.TeamInvitations ADD CONSTRAINT CK_TeamInvitations_Role CHECK (ProposedRole IN (N'CO_CAPTAIN', N'MEMBER'));
ALTER TABLE dbo.TeamInvitations ADD CONSTRAINT CK_TeamInvitations_Status CHECK (Status IN (N'PENDING', N'ACCEPTED', N'REJECTED', N'CANCELLED', N'EXPIRED'));
ALTER TABLE dbo.TeamJoinRequests ADD CONSTRAINT CK_TeamJoinRequests_Status CHECK (Status IN (N'PENDING', N'APPROVED', N'REJECTED', N'CANCELLED'));
ALTER TABLE dbo.TeamMembers ADD CONSTRAINT CK_TeamMembers_Role CHECK (MemberRole IN (N'CAPTAIN', N'CO_CAPTAIN', N'MEMBER'));
ALTER TABLE dbo.TeamMembers ADD CONSTRAINT CK_TeamMembers_Status CHECK (MemberStatus IN (N'ACTIVE', N'LEFT', N'REMOVED'));
ALTER TABLE dbo.Teams ADD CONSTRAINT CK_Teams_MaxMembers CHECK (MaxMembers BETWEEN 2 AND 30);
ALTER TABLE dbo.Teams ADD CONSTRAINT CK_Teams_Status CHECK (Status IN (N'ACTIVE', N'INACTIVE', N'DISBANDED', N'SUSPENDED'));
GO

-- ============================================================
-- INDEX quan trọng (non-unique)
-- ============================================================
CREATE INDEX IX_AuditLog_Actor ON dbo.AuditLog (ActorAccountID);
CREATE INDEX IX_AuditLog_CoSo ON dbo.AuditLog (CoSoID);
CREATE INDEX IX_AuditLog_CreatedAt ON dbo.AuditLog (CreatedAt);
CREATE INDEX IX_AuditLog_EntityType ON dbo.AuditLog (EntityType);
CREATE INDEX IX_CoSoCapability_CoSoID ON dbo.CoSoCapability (CoSoID);
CREATE INDEX IX_CoSoCapability_TrangThai ON dbo.CoSoCapability (TrangThai);
CREATE INDEX IX_ReputationHistory_Account ON dbo.CustomerReputationHistory (AccountID, CreatedAt);
CREATE INDEX IX_ReputationHistory_DatSan ON dbo.CustomerReputationHistory (DatSanID);
CREATE INDEX IX_GhepKeo_TrangThai_DatSan ON dbo.GhepKeo (TrangThai, DatSanID);
CREATE INDEX IX_HoaDon_Parent_Loai ON dbo.HoaDon (ParentHoaDonID, LoaiHoaDon);
CREATE INDEX IX_HoanTien_CoSoID ON dbo.HoanTien (CoSoID);
CREATE INDEX IX_HoanTien_DatSanID ON dbo.HoanTien (DatSanID);
CREATE INDEX IX_HoanTien_TrangThai ON dbo.HoanTien (TrangThai);
CREATE INDEX IX_KhuyenMaiHinhAnh_KhuyenMaiID ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID);
CREATE INDEX IX_KhuyenMaiHinhAnh_KhuyenMaiID_ThuTu ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID, ThuTu);
CREATE INDEX IX_KyLuong_CoSo ON dbo.KyLuong (CoSoID, NgayBatDau DESC);
CREATE INDEX IX_LichDatSan_PayosOrderCode ON dbo.LichDatSan (PayosOrderCode);
CREATE INDEX IX_LDSDV_DatSanID ON dbo.LichDatSan_DichVu (DatSanID);
CREATE INDEX IX_LichSuKM_Account_KM ON dbo.LichSuKhuyenMai (AccountID, KhuyenMaiID);
CREATE INDEX IX_NhomChiaTien_DatSan ON dbo.NhomChiaTien (DatSanID);
CREATE INDEX IX_NhomChiaTienChiTiet_Nhom ON dbo.NhomChiaTienChiTiet (NhomChiaTienID);
CREATE INDEX IX_PayOSPaymentAttempt_HoaDonID ON dbo.PayOSPaymentAttempt (HoaDonID);
CREATE INDEX IX_PayOSPaymentAttempt_PaymentLinkID ON dbo.PayOSPaymentAttempt (PaymentLinkID);
CREATE INDEX IX_QRRequest_CoSo_Status ON dbo.QRRequest (CoSoID, Status);
CREATE INDEX IX_QRRequest_GuestToken ON dbo.QRRequest (GuestToken);
CREATE INDEX IX_SanQR_TrangThai ON dbo.SanQR (TrangThai);
CREATE INDEX IX_SanQRTokenHistory_SanID ON dbo.SanQRTokenHistory (SanID);
CREATE INDEX IX_SanQRTokenHistory_SanQRID ON dbo.SanQRTokenHistory (SanQRID);
CREATE INDEX IX_SanQRTokenHistory_TokenHash ON dbo.SanQRTokenHistory (TokenHash);
CREATE INDEX IX_ServiceMaterial_CoSoID ON dbo.ServiceMaterial (CoSoID);
CREATE INDEX IX_ServiceOrder_BookingID ON dbo.ServiceOrder (BookingID);
CREATE INDEX IX_ServiceOrder_CoSoID ON dbo.ServiceOrder (CoSoID);
CREATE INDEX IX_ServiceOrder_CustomerID ON dbo.ServiceOrder (CustomerID);
CREATE INDEX IX_ServiceOrder_Status ON dbo.ServiceOrder (Status);
CREATE INDEX IX_SOSH_OrderID ON dbo.ServiceOrderStatusHistory (OrderID);
CREATE INDEX IX_SoftHold_San_Ngay ON dbo.SoftHold (SanID, NgayDat, CreatedTime);
CREATE INDEX IX_SportService_CoSoID ON dbo.SportService (CoSoID);
CREATE INDEX IX_SportService_ServiceType ON dbo.SportService (ServiceType);
CREATE INDEX IX_TeamInvitations_Invited ON dbo.TeamInvitations (InvitedAccountID, Status);
CREATE INDEX IX_TeamJoinRequests_Requester ON dbo.TeamJoinRequests (RequesterAccountID, Status);
CREATE INDEX IX_TeamMembers_Account ON dbo.TeamMembers (AccountID, MemberStatus);
CREATE INDEX IX_Teams_Captain ON dbo.Teams (CaptainAccountID);
CREATE INDEX IX_Teams_Sport ON dbo.Teams (SportID);
CREATE INDEX IX_Teams_Status ON dbo.Teams (Status);
CREATE INDEX IX_ThongBao_AccountID_ThoiGian ON dbo.ThongBao (DaDoc, IsDeleted, AccountID, ThoiGianGui);
CREATE INDEX IX_ThongBao_Unread ON dbo.ThongBao (AccountID, DaDoc);
CREATE INDEX idx_YeuCauNghi_AccountID ON dbo.YeuCauNghi (AccountID);
CREATE INDEX idx_YeuCauNghi_CoSoID_TrangThai ON dbo.YeuCauNghi (CoSoID, TrangThai);
CREATE INDEX idx_YeuCauNghi_NgayNghi ON dbo.YeuCauNghi (NgayNghi);
CREATE INDEX idx_YeuCauNghi_TrangThai ON dbo.YeuCauNghi (TrangThai);
CREATE INDEX idx_YeuCauNghiAudit_YeuCauNghiID ON dbo.YeuCauNghi_Audit (YeuCauNghiID);
CREATE INDEX IX_YeuCauUngLuong_Account ON dbo.YeuCauUngLuong (AccountID, CreatedAt DESC);
CREATE INDEX IX_YeuCauUngLuong_CoSo_TrangThai ON dbo.YeuCauUngLuong (CoSoID, TrangThai, CreatedAt DESC);
GO

-- ============================================================
-- GIỚI HẠN ĐÃ BIẾT
-- 1. Không kết nối được DB thật khi xuất (thiếu DB_URL/DB_USERNAME/DB_PASSWORD).
-- 2. Snapshot 2026-08-02 không chứa: tên constraint DEFAULT, định nghĩa CHECK,
--    ON DELETE/ON UPDATE, cờ IDENTITY. Các mục này lấy từ migration SQL,
--    phần nào không có căn cứ thì để trống thay vì đoán.
-- 3. dbo.SuCo trong sql/migration_guard_module.sql viết bằng cú pháp MySQL
--    (AUTO_INCREMENT, ENUM, TEXT, INDEX inline) — KHÔNG chạy được trên SQL Server.
--    Giữ nguyên kiểu gốc, không tự dịch sang kiểu SQL Server.
-- ============================================================