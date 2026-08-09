-- ============================================================================
-- schema_baseline.sql — V-SPORT / V_SPORT (Microsoft SQL Server)
-- Script tạo mới toàn bộ cấu trúc database khớp với code hiện tại của dự án.
-- Không chứa INSERT, mật khẩu thật, API key, PayOS key hay dữ liệu cá nhân.
--
-- NGUỒN & PHƯƠNG PHÁP
--   Được dựng lại bằng cách đối chiếu từng bảng/cột trong docs/erd-export-latest/
--   (snapshot DB thật ngày 2026-08-02 + toàn bộ migration SQL) với source code
--   Java THỰC TẾ tại thời điểm viết script này (2026-08-09) — không chỉ chép lại
--   tài liệu cũ, vì 3 module (lương, điểm danh khuôn mặt, bảo vệ/sự cố) và tính
--   năng "Yêu cầu nghỉ phép" đã bị GỠ HOÀN TOÀN khỏi code kể từ ngày xuất tài liệu.
--
-- SO VỚI BẢN XUẤT docs/erd-export-latest/09-full-schema.sql, SCRIPT NÀY:
--   1. Bỏ 32 bảng, chia làm 3 đợt:
--      1a. 12 bảng không còn code nào tham chiếu (xác minh bằng grep toàn bộ
--      src/main/java, 0 kết quả — trừ chính model chết của nó nếu có):
--        - BangLuong, CauHinhLuong, KyLuong, YeuCauUngLuong   (module Lương — đã gỡ)
--        - CoSoFaceConfig, FaceChallengeToken                 (module điểm danh khuôn mặt — đã gỡ)
--        - SuCo                                               (module bảo vệ/sự cố — đã gỡ, migration gốc còn
--                                                                dùng cú pháp MySQL nên vốn không chạy được)
--        - YeuCauNghi, YeuCauNghi_Audit                        (module nghỉ phép — DAO/Servlet đã bị xóa)
--        - ChiaHoaDon, MaQR                                    (cơ chế chia hóa đơn đời cũ — đã bị
--                                                                NhomChiaTien/NhomChiaTienChiTiet thay thế)
--        - LoaiSan_KhungGioDen_Backup                          (bảng backup tạm, không PK, không code dùng)
--      (sysdiagrams — bảng hệ thống do SSMS tự sinh — cũng không có trong script này.)
--      1b. 10 bảng thuộc cụm "Dịch vụ giá trị gia tăng" — CÒN CODE ĐANG DÙNG,
--      nhưng chủ động cắt theo yêu cầu rút gọn schema (chấp nhận mất chức năng
--      tương ứng nếu chạy app trên DB dựng từ script này):
--        - TheGiuXe, LichXeRaVao                               (giữ xe)
--        - RacketStringingConfig, RacketStringingOrderDetail,
--          ServiceMaterial, ServiceOrder, ServiceOrderStatusHistory,
--          SportService                                        (dịch vụ căng vợt / vật tư thể thao)
--        - LichDatSan_DichVu                                   (dịch vụ đặt kèm theo lượt đặt sân)
--        - QRRequest                                           (gọi nhân viên / gọi món qua QR bàn)
--      1c. 10 bảng nữa — CÒN CODE ĐANG DÙNG, cắt theo yêu cầu rút gọn tiếp theo
--      (chấp nhận mất chức năng tương ứng):
--        - Teams, TeamMembers, TeamInvitations, TeamJoinRequests  (đội nhóm người chơi —
--          đồng thời bỏ luôn 2 cột GhepKeo.TeamIDNguoiTao / ChiTietGhepKeo.TeamIDNguoiThamGia
--          vì 2 cột này chỉ có ý nghĩa khi có bảng Teams; GhepKeo/ChiTietGhepKeo vẫn giữ)
--        - NhatKyChat                                          (nhật ký chat AI)
--        - YeuCauSOS, NhatKySOSGui                              (SOS tìm người chơi)
--        - DanhGia                                              (đánh giá sau khi chơi)
--        - NhomChiaTien, NhomChiaTienChiTiet                    (chia hóa đơn theo nhóm)
--   2. Bỏ các cột chết đi kèm module đã gỡ: Accounts.FaceDescriptor/FaceImagePath/
--      FaceEnrolledAt; CaLamViec.FaceVerified/FaceCheckInImage/FaceConfidence/
--      FaceLivenessPassed/FaceCheckOutImage/FaceCheckOutConfidence.
--      (CaLamViec.GioVaoThuc/GioRaThuc và Accounts.QrImagePath được GIỮ LẠI vì
--      vẫn đang được code khác — không thuộc module đã gỡ — đọc/ghi.)
--   3. Sửa lỗi cú pháp/đánh máy có sẵn trong bản xuất cũ:
--        - CaLamViec_Audit/CaLamViec_Availability/CaLamViec_SwapRequest/SoftHold:
--          bổ sung IDENTITY(1,1) cho khóa chính (bảng tạo ngoài repo nên bản xuất
--          cũ không xác định được cờ IDENTITY; xác minh code không insert thủ công
--          giá trị khóa chính nên an toàn khi thêm).
--        - ChiTietGhepKeo: sửa tên cột trong unique index lọc từ
--          "AccountIDNguoiThamGia" (không tồn tại, lỗi có sẵn trong
--          sql/migration_matchmaking_complete_flow.sql) thành đúng tên cột thật
--          "AccountID_NguoiThamGia", đồng thời thêm lại WHERE lọc theo trạng thái.
--        - PayOSPaymentAttempt: bỏ 1 CHECK constraint hỏng cú pháp trong bản xuất cũ
--          (trộn định nghĩa cột vào CHECK), không có tác dụng nghiệp vụ nào.
--        - MonTheThaoYeuThich: đổi tên cột "NgayThêm" (có dấu tiếng Việt, cột
--          duy nhất trong toàn bộ schema viết vậy) thành "NgayThem" — xác minh
--          không có DAO/Service nào tham chiếu cột này theo tên nên đổi an toàn,
--          và khớp tên field "NgayThem" đã dùng trong model Java.
--        - KhuyenMai.MaCode: gộp 2 unique index trùng nhau (khác tên nhưng cùng
--          cột) trong bản xuất cũ thành 1.
--        - Accounts: gộp 2 unique index trùng nhau cho GoogleID và cho FacebookID
--          thành 1 mỗi cột; chuyển toàn bộ 4 unique index (Username/Email/
--          GoogleID/FacebookID) sang FILTERED UNIQUE INDEX (WHERE ... IS NOT NULL)
--          vì các cột này NULL được và SQL Server chỉ cho phép 1 NULL trong một
--          unique index thường — không lọc sẽ chặn tài khoản thứ 2 trở đi không
--          có Google/Facebook.
--   4. Bổ sung FOREIGN KEY cho các cột được code dùng như khóa ngoại nhưng bản
--      xuất cũ ghi nhận là "quan hệ suy luận" (không có constraint vật lý):
--        - CaLamViec_Audit.CaLamViecID → CaLamViec (NOT NULL, có DAO xác nhận)
--        - AuditLog.CoSoID → CoSo; AuditLog.ActorAccountID → Accounts
--        - AdminTrash.DeletedBy / RestoredBy → Accounts
--        - HoanTien.DatSanID → LichDatSan; HoanTien.CoSoID → CoSo
--        - LichSuKhuyenMai.DatSanID → LichDatSan
--        - DeletedBy → Accounts trên toàn bộ 8 bảng có soft-delete còn dùng:
--          Accounts, CaLamViec, CoSo, LichDatSan, LoaiSan, San, SanPham_DichVu,
--          ThongBao.
--   5. Tối ưu kiểu dữ liệu để tiết kiệm dung lượng / đúng bản chất tiền tệ
--      (đã xác minh code đọc bằng getter kiểu số nguyên chung — rs.getDouble()/
--      getBigDecimal() — nên đổi FLOAT/NUMERIC sang DECIMAL không ảnh hưởng code):
--        - Accounts.Password: VARCHAR(MAX) → VARCHAR(72). Toàn bộ nơi tạo mật
--          khẩu đều dùng BCrypt.hashpw(..., BCrypt.gensalt(12)) → chuỗi hash
--          luôn đúng 60 ký tự, VARCHAR(72) đủ dư mà không cần MAX (kiểu LOB).
--        - ChiTietHoaDon.DonGiaTaiThoiDiemBan/ThanhTien: FLOAT → DECIMAL(18,2).
--        - HoaDon.TongThanhToan: FLOAT → DECIMAL(18,2).
--        - SanPham_DichVu.DonGia/GiaNhap: FLOAT → DECIMAL(18,2).
--        - KhuyenMai.GiaTriGiam: FLOAT → DECIMAL(18,2).
--        - LoaiSan.GiaKhongDen: FLOAT → DECIMAL(18,2) (khớp GiaCoDen cùng bảng).
--        - LichDatSan.TongTienDuKien, HoanTien.SoTienHoan: NUMERIC(38,2) (17 byte/
--          dòng) → DECIMAL(18,2) (9 byte/dòng) — không có nghiệp vụ nào cần số
--          tiền lớn hơn 999,999,999,999,999.99 VNĐ.
--   6. Các cột/bảng nghi vấn nhưng KHÔNG đổi (để không phá vỡ code hiện tại):
--        - LichDatSan.actual_start_time/actual_end_time (TIME, snake_case) và
--          LichDatSan.ActualStartAt/ActualEndAt (DATETIME2, PascalCase) trông
--          giống trùng lặp nhưng thực chất phục vụ 2 mục đích khác nhau và đều
--          đang được đọc/ghi: cặp TIME phục vụ hiển thị "giờ vào thực" theo giờ
--          trong ngày khi sân đang sử dụng (CheckInDAO), cặp DATETIME2 là mốc
--          thời gian đầy đủ dùng để tính hóa đơn/checkout (CheckoutService,
--          InvoiceViewService, BillSplitService, BookingExtensionService). Đổi
--          tên cột snake_case sẽ làm vỡ toàn bộ câu SQL hard-code trong DAO.
--   7. ON DELETE/ON UPDATE: giữ mặc định NO ACTION cho MỌI foreign key (kể cả
--      các FK mới bổ sung ở mục 4) — không suy đoán CASCADE.
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID(N'V_SPORT') IS NULL
BEGIN
    CREATE DATABASE V_SPORT;
END
GO

USE V_SPORT;
GO

-- ============================================================================
-- BẢNG
-- ============================================================================

-- ---------- Accounts — Tài khoản ----------
IF OBJECT_ID('dbo.Accounts','U') IS NULL
CREATE TABLE dbo.Accounts (
    AccountID                    INT                IDENTITY(1,1) NOT NULL,
    Username                     VARCHAR(50)        NULL,
    Password                     VARCHAR(72)        NOT NULL,
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
    CoverImageUrl                NVARCHAR(500)      NULL,
    ChieuCaoCm                   INT                NULL,
    CanNangKg                    INT                NULL,
    GhiChuDacBiet                NVARCHAR(500)      NULL,
    ViTriYeuThich                NVARCHAR(255)      NULL,
    MonTheThaoYeuThichID         INT                NULL,
    TrinhDoChoi                  VARCHAR(30)        NULL,
    MucTieuChoi                  NVARCHAR(255)      NULL,
    TanSuatChoi                  VARCHAR(30)        NULL,
    QrImagePath                  NVARCHAR(500)      NULL,
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

-- ---------- BookingExtension — Gia hạn đặt sân ----------
IF OBJECT_ID('dbo.BookingExtension','U') IS NULL
CREATE TABLE dbo.BookingExtension (
    ExtensionID                  INT                IDENTITY(1,1) NOT NULL,
    DatSanID                     INT                NOT NULL,
    OldGioKetThuc                TIME               NOT NULL,
    NewGioKetThuc                TIME               NOT NULL,
    OldGioKetThucDateTime        DATETIME2          NULL,
    NewGioKetThucDateTime        DATETIME2          NULL,
    AdditionalAmount              DECIMAL(18,2)      NOT NULL,
    OperatorAccountID            INT                NOT NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_BookingExtension_CreatedAt DEFAULT (GETDATE()),
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
    GioVaoThuc                   DATETIME           NULL,
    GioRaThuc                    DATETIME           NULL,
    CONSTRAINT PK_CaLamViec PRIMARY KEY (CaLamViecID)
);
GO

-- ---------- CaLamViec_Audit — Nhật ký ca làm việc ----------
IF OBJECT_ID('dbo.CaLamViec_Audit','U') IS NULL
CREATE TABLE dbo.CaLamViec_Audit (
    AuditID                      INT                IDENTITY(1,1) NOT NULL,
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
    AvailabilityID               INT                IDENTITY(1,1) NOT NULL,
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
    SwapRequestID                INT                IDENTITY(1,1) NOT NULL,
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

-- ---------- ChiTietGhepKeo — Người tham gia kèo ----------
IF OBJECT_ID('dbo.ChiTietGhepKeo','U') IS NULL
CREATE TABLE dbo.ChiTietGhepKeo (
    ChiTietKeoID                 INT                IDENTITY(1,1) NOT NULL,
    KeoID                        INT                NULL,
    AccountID_NguoiThamGia       INT                NULL,
    TrangThaiThamGia             NVARCHAR(50)       NULL CONSTRAINT DF_ChiTietGhepKeo_TrangThaiThamGia DEFAULT (N'Chờ duyệt'),
    ViTriThamGia                 NVARCHAR(50)       NULL,
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
    DonGiaTaiThoiDiemBan         DECIMAL(18,2)      NULL,
    ThanhTien                    DECIMAL(18,2)      NULL,
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

-- ---------- DanhMucSanPham — Danh mục sản phẩm ----------
IF OBJECT_ID('dbo.DanhMucSanPham','U') IS NULL
CREATE TABLE dbo.DanhMucSanPham (
    DanhMucID                    INT                IDENTITY(1,1) NOT NULL,
    TenDanhMuc                   NVARCHAR(100)      NOT NULL,
    CONSTRAINT PK_DanhMucSanPham PRIMARY KEY (DanhMucID)
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
    SoNguoiCanTim                INT                NULL,
    HinhThucDuyet                NVARCHAR(20)       NULL,
    CreatedAt                    DATETIME2          NOT NULL CONSTRAINT DF_GhepKeo_CreatedAt DEFAULT (SYSDATETIME()),
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
    TongThanhToan                DECIMAL(18,2)      NULL,
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
    SoTienHoan                   DECIMAL(18,2)      NULL,
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
    GiaTriGiam                   DECIMAL(18,2)      NULL,
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
    TongTienDuKien               DECIMAL(18,2)      NULL,
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

-- ---------- LoaiSan — Loại sân ----------
IF OBJECT_ID('dbo.LoaiSan','U') IS NULL
CREATE TABLE dbo.LoaiSan (
    LoaiSanID                    INT                IDENTITY(1,1) NOT NULL,
    MonTheThaoID                 INT                NOT NULL,
    TenLoai                      NVARCHAR(50)       NOT NULL,
    GiaKhongDen                  DECIMAL(18,2)      NULL,
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
    NgayThem                     DATETIME           NULL CONSTRAINT DF_MonTheThaoYeuThich_NgayThem DEFAULT (getdate()),
    CONSTRAINT PK_MonTheThaoYeuThich PRIMARY KEY (AccountID, MonTheThaoID)
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
    DonGia                       DECIMAL(18,2)      NULL,
    DonViTinh                    NVARCHAR(20)       NULL,
    SoLuongTon                   INT                NULL CONSTRAINT DF_SanPham_DichVu_SoLuongTon DEFAULT ((0)),
    TrangThai                    NVARCHAR(50)       NULL CONSTRAINT DF_SanPham_DichVu_TrangThai DEFAULT (N'Đang kinh doanh'),
    SkuCode                      NVARCHAR(50)       NULL,
    GiaNhap                      DECIMAL(18,2)      NULL,
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

-- ---------- SoftHold — Giữ chỗ tạm thời ----------
IF OBJECT_ID('dbo.SoftHold','U') IS NULL
CREATE TABLE dbo.SoftHold (
    SoftHoldID                   INT                IDENTITY(1,1) NOT NULL,
    AccountID                    INT                NOT NULL,
    SanID                        INT                NOT NULL,
    NgayDat                      DATE               NOT NULL,
    GioBatDau                    TIME               NOT NULL,
    GioKetThuc                   TIME               NOT NULL,
    CreatedTime                  DATETIME           NOT NULL CONSTRAINT DF_SoftHold_CreatedTime DEFAULT (getdate()),
    CONSTRAINT PK_SoftHold PRIMARY KEY (SoftHoldID)
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

-- ============================================================================
-- UNIQUE CONSTRAINTS / UNIQUE INDEXES
-- Accounts.Username/Email/GoogleID/FacebookID dùng FILTERED UNIQUE INDEX vì
-- các cột này NULL được — không lọc thì SQL Server chỉ cho phép 1 dòng NULL.
-- ============================================================================
CREATE UNIQUE INDEX UQ_Accounts_Username  ON dbo.Accounts (Username)  WHERE Username IS NOT NULL;
CREATE UNIQUE INDEX UQ_Accounts_Email     ON dbo.Accounts (Email)     WHERE Email IS NOT NULL;
CREATE UNIQUE INDEX UQ_Accounts_GoogleID  ON dbo.Accounts (GoogleID)  WHERE GoogleID IS NOT NULL;
CREATE UNIQUE INDEX UQ_Accounts_FacebookID ON dbo.Accounts (FacebookID) WHERE FacebookID IS NOT NULL;
CREATE UNIQUE INDEX UX_ChiTietGhepKeo_Active_Keo_Account ON dbo.ChiTietGhepKeo (KeoID, AccountID_NguoiThamGia) WHERE TrangThaiThamGia IN (N'Chờ duyệt', N'Đã tham gia');
CREATE UNIQUE INDEX UQ_CoSoCapability_CoSo_Type ON dbo.CoSoCapability (CoSoID, CapabilityType);
CREATE UNIQUE INDEX UX_CourtChargeSegment_InvoiceOrder ON dbo.CourtChargeSegment (HoaDonID, SegmentOrder);
CREATE UNIQUE INDEX UQ_ReputationHistory_Account_DatSan_Action ON dbo.CustomerReputationHistory (AccountID, DatSanID, ActionType);
CREATE UNIQUE INDEX UX_HoaDon_OneMainPerBooking ON dbo.HoaDon (DatSanID);
CREATE UNIQUE INDEX UQ_KhuyenMai_MaCode ON dbo.KhuyenMai (MaCode);
CREATE UNIQUE INDEX UQ_KhuyenMaiHinhAnh_MotAnhBia ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID);
CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice ON dbo.PayOSPaymentAttempt (HoaDonID);
CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode ON dbo.PayOSPaymentAttempt (OrderCode);
CREATE UNIQUE INDEX UQ_SanQR_SanID ON dbo.SanQR (SanID);
CREATE UNIQUE INDEX UQ_SanQR_ShortCode ON dbo.SanQR (ShortCode) WHERE ShortCode IS NOT NULL;
CREATE UNIQUE INDEX UQ_SanQR_Token ON dbo.SanQR (Token);
CREATE UNIQUE INDEX UQ_SanQRTokenHistory_Token ON dbo.SanQRTokenHistory (Token) WHERE Token IS NOT NULL;
CREATE UNIQUE INDEX UQ_ThongBao_Account_Loai_MaBanGhi ON dbo.ThongBao (AccountID, LoaiThongBao, MaBanGhi);
GO

-- ============================================================================
-- FOREIGN KEYS
-- ON DELETE/ON UPDATE: mặc định NO ACTION cho mọi FK, kể cả FK mới bổ sung.
-- ============================================================================
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_Role FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID);
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_MonTheThaoYeuThich FOREIGN KEY (MonTheThaoYeuThichID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.AdminTrash ADD CONSTRAINT FK_AdminTrash_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.AdminTrash ADD CONSTRAINT FK_AdminTrash_RestoredBy FOREIGN KEY (RestoredBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.AuditLog ADD CONSTRAINT FK_AuditLog_Actor FOREIGN KEY (ActorAccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.AuditLog ADD CONSTRAINT FK_AuditLog_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.BookingExtension ADD CONSTRAINT FK_BookingExtension_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.BookingExtension ADD CONSTRAINT FK_BookingExtension_Operator FOREIGN KEY (OperatorAccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec ADD CONSTRAINT FK_CaLamViec_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec ADD CONSTRAINT FK_CaLamViec_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CaLamViec ADD CONSTRAINT FK_CaLamViec_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_Audit ADD CONSTRAINT FK_CaLamViec_Audit_CaLamViec FOREIGN KEY (CaLamViecID) REFERENCES dbo.CaLamViec(CaLamViecID);
ALTER TABLE dbo.CaLamViec_Audit ADD CONSTRAINT FK_CaLamViec_Audit_NguoiThucHien FOREIGN KEY (NguoiThucHien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_Availability ADD CONSTRAINT FK_CaLamViec_Availability_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_Availability ADD CONSTRAINT FK_CaLamViec_Availability_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK_CaLamViec_SwapRequest_AccountGui FOREIGN KEY (AccountID_Gui) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK_CaLamViec_SwapRequest_AccountNhan FOREIGN KEY (AccountID_Nhan) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK_CaLamViec_SwapRequest_CaGui FOREIGN KEY (CaLamViecID_Gui) REFERENCES dbo.CaLamViec(CaLamViecID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK_CaLamViec_SwapRequest_CaNhan FOREIGN KEY (CaLamViecID_Nhan) REFERENCES dbo.CaLamViec(CaLamViecID);
ALTER TABLE dbo.CaLamViec_SwapRequest ADD CONSTRAINT FK_CaLamViec_SwapRequest_NguoiDuyet FOREIGN KEY (NguoiDuyet) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ChiTietGhepKeo ADD CONSTRAINT FK_ChiTietGhepKeo_Account FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ChiTietGhepKeo ADD CONSTRAINT FK_ChiTietGhepKeo_Keo FOREIGN KEY (KeoID) REFERENCES dbo.GhepKeo(KeoID);
ALTER TABLE dbo.ChiTietHoaDon ADD CONSTRAINT FK_ChiTietHoaDon_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.ChiTietHoaDon ADD CONSTRAINT FK_ChiTietHoaDon_SanPham FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham_DichVu(SanPhamID);
ALTER TABLE dbo.CoSo ADD CONSTRAINT FK_CoSo_QuanLy FOREIGN KEY (AccountID_QuanLy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CoSo ADD CONSTRAINT FK_CoSo_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CoSoCapability ADD CONSTRAINT FK_CoSoCapability_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CoSoCapability ADD CONSTRAINT FK_CoSoCapability_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CoSoNganHang ADD CONSTRAINT FK_CoSoNganHang_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT FK_CourtChargeSegment_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT FK_CourtChargeSegment_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_Actor FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.CustomerReputationHistory ADD CONSTRAINT FK_ReputationHistory_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_Account FOREIGN KEY (AccountID_NguoiTao) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.GhepKeo ADD CONSTRAINT FK_GhepKeo_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_Khach FOREIGN KEY (AccountID_KhachHang) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_Parent FOREIGN KEY (ParentHoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.KhuyenMai ADD CONSTRAINT FK_KhuyenMai_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.KhuyenMaiHinhAnh ADD CONSTRAINT FK_KhuyenMaiHinhAnh_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_CancelledBy FOREIGN KEY (CancelledBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_ConfirmedBy FOREIGN KEY (ConfirmedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichSuELO ADD CONSTRAINT FK_LichSuELO_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichSuELO ADD CONSTRAINT FK_LichSuELO_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.LichSuKhuyenMai ADD CONSTRAINT FK_LichSuKhuyenMai_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.LichSuKhuyenMai ADD CONSTRAINT FK_LichSuKhuyenMai_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID);
ALTER TABLE dbo.LichSuKhuyenMai ADD CONSTRAINT FK_LichSuKhuyenMai_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.LoaiSan ADD CONSTRAINT FK_LoaiSan_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.LoaiSan ADD CONSTRAINT FK_LoaiSan_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.LoaiSan ADD CONSTRAINT FK_LoaiSan_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.MonTheThaoYeuThich ADD CONSTRAINT FK_MonTheThaoYeuThich_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.MonTheThaoYeuThich ADD CONSTRAINT FK_MonTheThaoYeuThich_Mon FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
ALTER TABLE dbo.PayOSPaymentAttempt ADD CONSTRAINT FK_PayOSPaymentAttempt_LichDatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID);
ALTER TABLE dbo.San ADD CONSTRAINT FK_San_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.San ADD CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES dbo.LoaiSan(LoaiSanID);
ALTER TABLE dbo.San ADD CONSTRAINT FK_San_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanPham_DichVu ADD CONSTRAINT FK_SanPham_DichVu_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
ALTER TABLE dbo.SanPham_DichVu ADD CONSTRAINT FK_SanPham_DichVu_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES dbo.DanhMucSanPham(DanhMucID);
ALTER TABLE dbo.SanPham_DichVu ADD CONSTRAINT FK_SanPham_DichVu_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.SanQR ADD CONSTRAINT FK_SanQR_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_RevokedBy FOREIGN KEY (RevokedBy) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.SanQRTokenHistory ADD CONSTRAINT FK_SanQRTokenHistory_SanQR FOREIGN KEY (SanQRID) REFERENCES dbo.SanQR(SanQRID);
ALTER TABLE dbo.SoftHold ADD CONSTRAINT FK_SoftHold_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.SoftHold ADD CONSTRAINT FK_SoftHold_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID);
ALTER TABLE dbo.ThongBao ADD CONSTRAINT FK_ThongBao_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID);
ALTER TABLE dbo.ThongBao ADD CONSTRAINT FK_ThongBao_DeletedBy FOREIGN KEY (DeletedBy) REFERENCES dbo.Accounts(AccountID);
GO

-- ============================================================================
-- CHECK CONSTRAINTS
-- ============================================================================
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_CanNangKg CHECK (CanNangKg IS NULL OR CanNangKg BETWEEN 20 AND 300);
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_ChieuCaoCm CHECK (ChieuCaoCm IS NULL OR ChieuCaoCm BETWEEN 50 AND 260);
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_TanSuatChoi CHECK (TanSuatChoi IS NULL OR TanSuatChoi IN (N'1 lần/tuần', N'2-3 lần/tuần', N'4+ lần/tuần', N'Không cố định'));
ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_TrinhDoChoi CHECK (TrinhDoChoi IS NULL OR TrinhDoChoi IN (N'Mới chơi', N'Cơ bản', N'Trung bình', N'Khá', N'Nâng cao'));
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_Amounts CHECK (HourlyRate >= 0 AND Amount >= 0);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_Duration CHECK (DurationMinutes > 0);
ALTER TABLE dbo.CourtChargeSegment ADD CONSTRAINT CK_CourtChargeSegment_RateType CHECK (RateType IN (N'WITHOUT_LIGHT', N'WITH_LIGHT'));
GO

-- ============================================================================
-- INDEX (non-unique) — hỗ trợ các truy vấn thường gặp trong DAO/Service
-- ============================================================================
CREATE INDEX IX_AuditLog_Actor ON dbo.AuditLog (ActorAccountID);
CREATE INDEX IX_AuditLog_CoSo ON dbo.AuditLog (CoSoID);
CREATE INDEX IX_AuditLog_CreatedAt ON dbo.AuditLog (CreatedAt);
CREATE INDEX IX_AuditLog_EntityType ON dbo.AuditLog (EntityType);
CREATE INDEX IX_CaLamViec_Audit_CaLamViecID ON dbo.CaLamViec_Audit (CaLamViecID);
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
CREATE INDEX IX_LichDatSan_PayosOrderCode ON dbo.LichDatSan (PayosOrderCode);
CREATE INDEX IX_LichSuKhuyenMai_Account_KM ON dbo.LichSuKhuyenMai (AccountID, KhuyenMaiID);
CREATE INDEX IX_LichSuKhuyenMai_DatSan ON dbo.LichSuKhuyenMai (DatSanID);
CREATE INDEX IX_PayOSPaymentAttempt_HoaDonID ON dbo.PayOSPaymentAttempt (HoaDonID);
CREATE INDEX IX_PayOSPaymentAttempt_PaymentLinkID ON dbo.PayOSPaymentAttempt (PaymentLinkID);
CREATE INDEX IX_SanQR_TrangThai ON dbo.SanQR (TrangThai);
CREATE INDEX IX_SanQRTokenHistory_SanID ON dbo.SanQRTokenHistory (SanID);
CREATE INDEX IX_SanQRTokenHistory_SanQRID ON dbo.SanQRTokenHistory (SanQRID);
CREATE INDEX IX_SanQRTokenHistory_TokenHash ON dbo.SanQRTokenHistory (TokenHash);
CREATE INDEX IX_SoftHold_San_Ngay ON dbo.SoftHold (SanID, NgayDat, CreatedTime);
CREATE INDEX IX_ThongBao_AccountID_ThoiGian ON dbo.ThongBao (DaDoc, IsDeleted, AccountID, ThoiGianGui);
CREATE INDEX IX_ThongBao_Unread ON dbo.ThongBao (AccountID, DaDoc);
GO
