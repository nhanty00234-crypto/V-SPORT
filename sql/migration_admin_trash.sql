-- migration_admin_trash.sql
-- Bảng thùng rác chung cho Admin. Idempotent: chạy lại không lỗi.
-- Không lưu dữ liệu nhạy cảm (mật khẩu, số thẻ...). Không hard-delete bảng này.

IF OBJECT_ID('AdminTrash', 'U') IS NULL
BEGIN
    CREATE TABLE AdminTrash (
        TrashID INT IDENTITY(1,1) PRIMARY KEY,
        EntityType NVARCHAR(100) NOT NULL,
        EntityID INT NOT NULL,
        DisplayName NVARCHAR(255) NULL,
        SourceTable NVARCHAR(100) NOT NULL,
        OldStatus NVARCHAR(100) NULL,
        DeletedBy INT NULL,
        DeletedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        Reason NVARCHAR(500) NULL,
        IsRestored BIT NOT NULL DEFAULT 0,
        RestoredBy INT NULL,
        RestoredAt DATETIME2 NULL
    );
END
GO
