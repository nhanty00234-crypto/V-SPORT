-- Verify: NhomChiaTien, NhomChiaTienChiTiet (Chia tiền nhóm)
USE QuanLiSport;
GO

-- 1. Cấu trúc cột NhomChiaTien
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.NhomChiaTien')
ORDER BY c.column_id;
GO

-- 2. Cấu trúc cột NhomChiaTienChiTiet
SELECT c.name AS ColumnName, t.name AS DataType, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.NhomChiaTienChiTiet')
ORDER BY c.column_id;
GO

-- 3. Index (kỳ vọng: UX_NhomChiaTien_HoaDon_Active filtered unique,
--    UX_NhomChiaTienChiTiet_ShareToken unique)
SELECT OBJECT_NAME(i.object_id) AS TableName, i.name AS IndexName, i.is_unique, i.filter_definition
FROM sys.indexes i
WHERE i.object_id IN (OBJECT_ID(N'dbo.NhomChiaTien'), OBJECT_ID(N'dbo.NhomChiaTienChiTiet'))
  AND i.name IS NOT NULL;
GO

-- 4. Foreign keys
SELECT fk.name AS FKName, OBJECT_NAME(fk.parent_object_id) AS TableName,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id IN (OBJECT_ID(N'dbo.NhomChiaTien'), OBJECT_ID(N'dbo.NhomChiaTienChiTiet'));
GO

-- 5. Check constraints
SELECT OBJECT_NAME(cc.parent_object_id) AS TableName, cc.name AS ConstraintName, cc.definition
FROM sys.check_constraints cc
WHERE cc.parent_object_id IN (OBJECT_ID(N'dbo.NhomChiaTien'), OBJECT_ID(N'dbo.NhomChiaTienChiTiet'));
GO
