-- migration_soft_delete.sql
-- Chạy tay trên SQL Server. Idempotent: chạy lại không lỗi.

DECLARE @tables TABLE (TableName SYSNAME);
INSERT INTO @tables VALUES ('San'),('LoaiSan'),('SanPham_DichVu'),('CaLamViec'),
                           ('ThongBao'),('YeuCauNghi'),('LichDatSan'),('CoSo');

DECLARE @t SYSNAME, @sql NVARCHAR(MAX);
DECLARE cur CURSOR FOR SELECT TableName FROM @tables;
OPEN cur;
FETCH NEXT FROM cur INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH(@t, 'IsDeleted') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD IsDeleted BIT NOT NULL DEFAULT 0';
        EXEC sp_executesql @sql;
    END
    IF COL_LENGTH(@t, 'DeletedAt') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD DeletedAt DATETIME NULL';
        EXEC sp_executesql @sql;
    END
    IF COL_LENGTH(@t, 'DeletedBy') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD DeletedBy INT NULL';
        EXEC sp_executesql @sql;
    END
    FETCH NEXT FROM cur INTO @t;
END
CLOSE cur; DEALLOCATE cur;

-- Accounts đã có isDeleted, chỉ bổ sung 2 cột:
IF COL_LENGTH('Accounts', 'DeletedAt') IS NULL
    ALTER TABLE Accounts ADD DeletedAt DATETIME NULL;
IF COL_LENGTH('Accounts', 'DeletedBy') IS NULL
    ALTER TABLE Accounts ADD DeletedBy INT NULL;

-- Dữ liệu cũ: San từng "xóa mềm" bằng trạng thái Tạm đóng — KHÔNG tự chuyển
-- sang IsDeleted=1 vì Tạm đóng cũng là trạng thái nghiệp vụ hợp lệ. Giữ nguyên.
PRINT 'Migration soft-delete hoàn tất.';
