-- Verify: sql/migration_san_qr.sql
-- Kiểm tra bảng, cột, ràng buộc, index đã tạo đúng như thiết kế. Không sửa dữ liệu.

USE QuanLiSport;
GO

PRINT N'--- 1. Bảng SanQR tồn tại? ---';
SELECT CASE WHEN OBJECT_ID('dbo.SanQR', 'U') IS NOT NULL
            THEN N'OK: bảng tồn tại' ELSE N'FAIL: bảng KHÔNG tồn tại' END AS KetQua;
GO

PRINT N'--- 2. Bảng SanQRTokenHistory tồn tại? ---';
SELECT CASE WHEN OBJECT_ID('dbo.SanQRTokenHistory', 'U') IS NOT NULL
            THEN N'OK: bảng tồn tại' ELSE N'FAIL: bảng KHÔNG tồn tại' END AS KetQua;
GO

PRINT N'--- 3. Cột SanQR ---';
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.SanQR')
ORDER BY c.column_id;
GO

PRINT N'--- 4. Cột SanQRTokenHistory ---';
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.SanQRTokenHistory')
ORDER BY c.column_id;
GO

PRINT N'--- 5. Khóa ngoại SanQR ---';
SELECT fk.name AS ForeignKeyName,
       OBJECT_NAME(fk.parent_object_id) AS TableName,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('dbo.SanQR');
GO

PRINT N'--- 6. Khóa ngoại SanQRTokenHistory ---';
SELECT fk.name AS ForeignKeyName,
       OBJECT_NAME(fk.parent_object_id) AS TableName,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('dbo.SanQRTokenHistory');
GO

PRINT N'--- 7. Unique constraint SanQR.SanID (1 QR / 1 sân) ---';
SELECT i.name AS IndexName, i.is_unique, i.is_unique_constraint
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.SanQR') AND i.is_unique = 1;
GO

PRINT N'--- 8. Unique index Token (không được trùng token giữa các sân) ---';
SELECT i.name AS IndexName, i.is_unique
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.SanQR') AND i.name = 'UQ_SanQR_Token';
GO

PRINT N'--- 9. Unique index Token trong lịch sử (không cấp trùng token 2 lần) ---';
SELECT i.name AS IndexName, i.is_unique
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND i.name = 'UQ_SanQRTokenHistory_Token';
GO

PRINT N'--- 10. Không có sân nào có nhiều hơn 1 bản ghi SanQR (đảm bảo 1-1) ---';
SELECT SanID, COUNT(*) AS SoLuong
FROM dbo.SanQR
GROUP BY SanID
HAVING COUNT(*) > 1;
-- Kỳ vọng: 0 dòng trả về.
GO

PRINT N'--- 11. Không có token trùng nhau giữa các sân đang ACTIVE ---';
SELECT Token, COUNT(*) AS SoLuong
FROM dbo.SanQR
WHERE TrangThai = N'ACTIVE'
GROUP BY Token
HAVING COUNT(*) > 1;
-- Kỳ vọng: 0 dòng trả về (UNIQUEIDENTIFIER + unique index đã đảm bảo, đây là kiểm tra chéo).
GO

PRINT N'--- 12. Thống kê trạng thái hiện tại ---';
SELECT TrangThai, COUNT(*) AS SoLuong FROM dbo.SanQR GROUP BY TrangThai;
GO
