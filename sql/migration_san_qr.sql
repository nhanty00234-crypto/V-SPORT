-- Migration: Thêm bảng SanQR (QR-01 - Nền tảng mã QR bảo mật cho từng sân).
-- Mỗi sân có 1 bản ghi QR duy nhất, gắn 1-1 qua SanID. Token là UNIQUEIDENTIFIER
-- (NEWID()) - không đoán được, không dùng SanID tuần tự trong URL/QR in ra, tránh
-- một khách quét/dò được QR của sân khác. Khi Manager "tạo lại mã" (regenerate),
-- token cũ bị lưu vào lịch sử SanQRTokenHistory và đánh dấu REVOKED vĩnh viễn -
-- không tái sử dụng - để nếu ai chụp lại QR cũ trước khi bị thay, hệ thống từ chối
-- rõ ràng thay vì im lặng 404.
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên. Không xóa dữ liệu hiện có.

USE QuanLiSport;
GO

IF OBJECT_ID('dbo.SanQR', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SanQR (
        SanQRID       INT IDENTITY(1,1) PRIMARY KEY,
        SanID         INT NOT NULL,
        -- Token đang active dùng để resolve khi quét. NULL nghĩa là sân chưa từng
        -- được tạo QR (bản ghi chỉ tồn tại sau khi Manager bấm "Tạo mã" lần đầu).
        Token         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SanQR_Token DEFAULT NEWID(),
        -- ACTIVE (đang dùng được), DISABLED (Manager tắt tạm thời, token vẫn giữ
        -- nguyên để bật lại không cần regenerate), REVOKED (đã bị thay bằng token
        -- mới qua regenerate - vĩnh viễn không dùng lại, xem SanQRTokenHistory).
        TrangThai     NVARCHAR(20) NOT NULL CONSTRAINT DF_SanQR_TrangThai DEFAULT N'ACTIVE',
        CreatedAt     DATETIME2    NOT NULL CONSTRAINT DF_SanQR_CreatedAt DEFAULT SYSUTCDATETIME(),
        CreatedBy     INT NULL,
        -- Đổi mỗi lần regenerate/bật/tắt - dùng để phát hiện thay đổi đồng thời
        -- ở tầng ứng dụng (optimistic hint), lock thật sự vẫn dùng PESSIMISTIC_WRITE
        -- ở Service layer khi transition.
        UpdatedAt     DATETIME2    NOT NULL CONSTRAINT DF_SanQR_UpdatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedBy     INT NULL,
        -- Đếm số lần regenerate - phục vụ hiển thị lịch sử/debug, không phải khóa.
        RegenerateCount INT NOT NULL CONSTRAINT DF_SanQR_RegenerateCount DEFAULT 0,
        CONSTRAINT FK_SanQR_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID),
        CONSTRAINT FK_SanQR_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID),
        CONSTRAINT FK_SanQR_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Accounts(AccountID),
        -- Mỗi sân chỉ có duy nhất 1 bản ghi SanQR (1-1). Regenerate SỬA token trong
        -- cùng bản ghi này, không tạo dòng mới - lịch sử token cũ nằm ở bảng riêng.
        CONSTRAINT UQ_SanQR_SanID UNIQUE (SanID)
    );

    -- Token phải unique toàn hệ thống - đây là điều kiện an ninh cốt lõi: hai sân
    -- (thậm chí khác cơ sở) không bao giờ được trùng token, nếu không việc resolve
    -- QR có thể trỏ nhầm sân.
    CREATE UNIQUE INDEX UQ_SanQR_Token ON dbo.SanQR (Token);
    CREATE INDEX IX_SanQR_TrangThai ON dbo.SanQR (TrangThai);

    PRINT N'Đã tạo bảng SanQR.';
END
ELSE
    PRINT N'Bảng SanQR đã tồn tại, bỏ qua.';
GO

IF OBJECT_ID('dbo.SanQRTokenHistory', 'U') IS NULL
BEGIN
    -- Lưu MỌI token từng được cấp cho một sân (kể cả token đang active hiện tại,
    -- ghi lại tại thời điểm tạo/regenerate). Mục đích bảo mật: nếu một token REVOKED
    -- bị quét lại (QR giấy cũ chưa thu hồi vật lý), Service layer tra bảng này để
    -- trả lỗi rõ ràng "mã QR đã cũ, vui lòng lấy mã mới" thay vì lỗi chung chung
    -- "không tìm thấy" - giúp Staff/Manager phân biệt được QR giả và QR cũ.
    CREATE TABLE dbo.SanQRTokenHistory (
        HistoryID     INT IDENTITY(1,1) PRIMARY KEY,
        SanQRID       INT NOT NULL,
        SanID         INT NOT NULL,
        Token         UNIQUEIDENTIFIER NOT NULL,
        -- ISSUED (token này từng active), REVOKED (đã bị regenerate thay thế).
        TrangThai     NVARCHAR(20) NOT NULL CONSTRAINT DF_SanQRTokenHistory_TrangThai DEFAULT N'ISSUED',
        IssuedAt      DATETIME2 NOT NULL CONSTRAINT DF_SanQRTokenHistory_IssuedAt DEFAULT SYSUTCDATETIME(),
        RevokedAt     DATETIME2 NULL,
        RevokedBy     INT NULL,
        RevokeReason  NVARCHAR(200) NULL,
        CONSTRAINT FK_SanQRTokenHistory_SanQR FOREIGN KEY (SanQRID) REFERENCES dbo.SanQR(SanQRID),
        CONSTRAINT FK_SanQRTokenHistory_San FOREIGN KEY (SanID) REFERENCES dbo.San(SanID),
        CONSTRAINT FK_SanQRTokenHistory_RevokedBy FOREIGN KEY (RevokedBy) REFERENCES dbo.Accounts(AccountID)
    );

    CREATE UNIQUE INDEX UQ_SanQRTokenHistory_Token ON dbo.SanQRTokenHistory (Token);
    CREATE INDEX IX_SanQRTokenHistory_SanQRID ON dbo.SanQRTokenHistory (SanQRID);
    CREATE INDEX IX_SanQRTokenHistory_SanID ON dbo.SanQRTokenHistory (SanID);

    PRINT N'Đã tạo bảng SanQRTokenHistory.';
END
ELSE
    PRINT N'Bảng SanQRTokenHistory đã tồn tại, bỏ qua.';
GO

-- Rollback (thủ công, chỉ chạy nếu cần gỡ migration này và chưa có dữ liệu quan trọng):
--   DROP TABLE dbo.SanQRTokenHistory;
--   DROP TABLE dbo.SanQR;
