-- Verify: HoanTien mở rộng cho Hoàn tiền Customer self-service
USE QuanLiSport;
GO

-- 1. Cấu trúc cột đầy đủ
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.HoanTien')
ORDER BY c.column_id;
GO

-- 2. Index (kỳ vọng: IX_HoanTien_TrangThai, IX_HoanTien_CoSoID)
SELECT i.name AS IndexName, i.is_unique
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID(N'dbo.HoanTien') AND i.name IS NOT NULL;
GO

-- 3. Phân bố giá trị TrangThai sau chuẩn hóa (kỳ vọng chỉ còn 7 mã: CHO_BO_SUNG_THONG_TIN,
--    CHO_XU_LY, DA_DUYET, DANG_HOAN_TIEN, DA_HOAN_TIEN, TU_CHOI, DA_HUY)
SELECT TrangThai, COUNT(*) AS SoLuong
FROM dbo.HoanTien
GROUP BY TrangThai;
GO

-- 4. Bản ghi thiếu CoSoID sau backfill (kỳ vọng: 0 dòng)
SELECT HoanTienID, HoaDonID FROM dbo.HoanTien WHERE CoSoID IS NULL;
GO
