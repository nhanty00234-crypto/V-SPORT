-- migration_avatar_url.sql
-- Thêm cột AvatarUrl vào bảng Accounts. Idempotent: chạy lại không lỗi.

IF COL_LENGTH('Accounts', 'AvatarUrl') IS NULL
    ALTER TABLE Accounts ADD AvatarUrl NVARCHAR(500) NULL;

PRINT 'Migration AvatarUrl hoàn tất.';
