-- sql/create_audit_log.sql
IF OBJECT_ID('AuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE AuditLog (
        AuditLogID    BIGINT IDENTITY(1,1) PRIMARY KEY,
        ActorAccountID INT NULL,           -- NULL nếu tài khoản đã bị xóa
        ActorName      NVARCHAR(255) NOT NULL,
        ActorRole      INT NOT NULL,       -- 1=Admin, 2=Manager
        CoSoID         INT NULL,           -- NULL nếu Admin-global action
        Action         NVARCHAR(100) NOT NULL,  -- CREATE, UPDATE, DELETE, RESTORE, PERMANENT_DELETE, LOGIN, etc.
        EntityType     NVARCHAR(100) NOT NULL,  -- TaiKhoan, San, LoaiSan, SanPham, CoSo, CaLamViec, YeuCauNghi
        EntityID       NVARCHAR(50) NULL,  -- ID của entity bị tác động (string để linh hoạt)
        EntityName     NVARCHAR(500) NULL, -- Tên hiển thị của entity (để log đọc được ngay cả sau khi entity bị xóa)
        Details        NVARCHAR(MAX) NULL, -- Mô tả chi tiết (ví dụ: "Đổi tên từ 'Sân A' sang 'Sân B'")
        IpAddress      NVARCHAR(50) NULL,
        CreatedAt      DATETIME2 NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX IX_AuditLog_Actor      ON AuditLog (ActorAccountID);
    CREATE INDEX IX_AuditLog_CoSo       ON AuditLog (CoSoID);
    CREATE INDEX IX_AuditLog_CreatedAt  ON AuditLog (CreatedAt DESC);
    CREATE INDEX IX_AuditLog_EntityType ON AuditLog (EntityType);
END
