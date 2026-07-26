-- ============================================================
-- VERIFY: migration_notification_marketing_refund_review
-- ============================================================
SELECT 'Accounts.NhanThongBaoMarketing' AS check_item,
       CASE WHEN EXISTS (
           SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'dbo.Accounts') AND name = N'NhanThongBaoMarketing'
       ) THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.AccountID_NguoiXuLy' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'AccountID_NguoiXuLy')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.GhiChuXuLy' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'GhiChuXuLy')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.MaGiaoDichHoan' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'MaGiaoDichHoan')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.ThoiGianXuLy' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'ThoiGianXuLy')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.NganHangNhan' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'NganHangNhan')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.SoTaiKhoanNhan' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'SoTaiKhoanNhan')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'HoanTien.ChuTaiKhoanNhan' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'ChuTaiKhoanNhan')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'IX_HoanTien_TrangThai' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'IX_HoanTien_TrangThai')
       THEN 'OK' ELSE 'MISSING' END AS status;

SELECT 'UQ_DanhGia_DatSan_Account' AS check_item,
       CASE WHEN EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.DanhGia') AND name = N'UQ_DanhGia_DatSan_Account')
       THEN 'OK' ELSE 'MISSING' END AS status;
