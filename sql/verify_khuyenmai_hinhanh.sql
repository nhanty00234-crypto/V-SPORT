-- Verify: bảng KhuyenMaiHinhAnh, index, FK và cột HienThiCongKhai
USE QuanLiSport;
GO

-- 1. Cấu trúc cột
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.KhuyenMaiHinhAnh')
ORDER BY c.column_id;
GO

-- 2. Index (kỳ vọng: IX_KhuyenMaiHinhAnh_KhuyenMaiID, IX_KhuyenMaiHinhAnh_KhuyenMaiID_ThuTu,
--    UQ_KhuyenMaiHinhAnh_MotAnhBia filtered unique trên LaAnhBia=1)
SELECT i.name AS IndexName, i.is_unique, i.filter_definition
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID(N'dbo.KhuyenMaiHinhAnh') AND i.name IS NOT NULL;
GO

-- 3. Foreign key
SELECT fk.name AS FKName, OBJECT_NAME(fk.parent_object_id) AS TableName,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID(N'dbo.KhuyenMaiHinhAnh');
GO

-- 4. Cột HienThiCongKhai trên KhuyenMai
SELECT c.name, t.name AS DataType, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.KhuyenMai') AND c.name = N'HienThiCongKhai';
GO

-- 5. Kiểm tra ràng buộc "1 ảnh bìa / khuyến mãi" thực sự có hiệu lực: nếu migration đúng,
--    câu lệnh dưới đây (chèn ảnh bìa thứ 2 cho cùng KhuyenMaiID=@Test) PHẢI báo lỗi vi phạm
--    unique index UQ_KhuyenMaiHinhAnh_MotAnhBia. Chỉ chạy thủ công khi cần kiểm chứng, không
--    chạy trong pipeline tự động vì mục đích là gây lỗi có kiểm soát.
-- DECLARE @Test INT = (SELECT TOP 1 KhuyenMaiID FROM KhuyenMai);
-- INSERT INTO KhuyenMaiHinhAnh (KhuyenMaiID, DuongDan, LaAnhBia) VALUES (@Test, N'/tmp/a.jpg', 1);
-- INSERT INTO KhuyenMaiHinhAnh (KhuyenMaiID, DuongDan, LaAnhBia) VALUES (@Test, N'/tmp/b.jpg', 1); -- kỳ vọng lỗi
-- DELETE FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = @Test AND DuongDan IN (N'/tmp/a.jpg', N'/tmp/b.jpg');
