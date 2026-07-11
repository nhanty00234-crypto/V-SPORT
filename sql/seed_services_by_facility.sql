-- Seed: Dữ liệu dịch vụ/sản phẩm mẫu cho các Cơ Sở thật (Phase 8A)
-- Idempotent theo từng Cơ Sở: chỉ seed cho CoSoID nào ĐANG CHƯA có sản phẩm nào
-- trong SanPham_DichVu (an toàn khi chạy lại, không tạo trùng, không đụng dữ liệu
-- Cơ Sở đã tự quản lý qua /manager/kho-dich-vu).
-- CoSoID dùng dưới đây (6,7,8,9,10,11) được xác nhận là các Cơ Sở thật đang tồn tại
-- trong DB (đọc read-only từ bảng CoSo), KHÔNG phải giá trị bịa.

USE QuanLiSport;
GO

-- Đảm bảo có danh mục "Đồ uống" và "Thuê dụng cụ" (tận dụng nếu đã tồn tại, không tạo trùng)
IF NOT EXISTS (SELECT 1 FROM DanhMucSanPham WHERE TenDanhMuc = N'Đồ uống')
    INSERT INTO DanhMucSanPham (TenDanhMuc) VALUES (N'Đồ uống');
GO

IF NOT EXISTS (SELECT 1 FROM DanhMucSanPham WHERE TenDanhMuc = N'Thuê dụng cụ')
    INSERT INTO DanhMucSanPham (TenDanhMuc) VALUES (N'Thuê dụng cụ');
GO

IF NOT EXISTS (SELECT 1 FROM DanhMucSanPham WHERE TenDanhMuc = N'Phụ kiện thể thao')
    INSERT INTO DanhMucSanPham (TenDanhMuc) VALUES (N'Phụ kiện thể thao');
GO

DECLARE @DoUong INT = (SELECT TOP 1 DanhMucID FROM DanhMucSanPham WHERE TenDanhMuc = N'Đồ uống');
DECLARE @ThueDungCu INT = (SELECT TOP 1 DanhMucID FROM DanhMucSanPham WHERE TenDanhMuc = N'Thuê dụng cụ');
DECLARE @PhuKien INT = (SELECT TOP 1 DanhMucID FROM DanhMucSanPham WHERE TenDanhMuc = N'Phụ kiện thể thao');

-- Bảng tạm chứa CoSoID cần seed: chỉ những Cơ Sở thật hiện chưa có bất kỳ sản phẩm nào
DECLARE @TargetCoSo TABLE (CoSoID INT);
INSERT INTO @TargetCoSo (CoSoID)
SELECT c.CoSoID
FROM CoSo c
WHERE c.CoSoID IN (6, 7, 8, 9, 10, 11)
  AND NOT EXISTS (SELECT 1 FROM SanPham_DichVu sp WHERE sp.CoSoID = c.CoSoID);

-- Seed bộ dịch vụ mẫu chung cho mỗi Cơ Sở còn thiếu dữ liệu
INSERT INTO SanPham_DichVu (DanhMucID, CoSoID, TenSanPham, DonGia, DonViTinh, SoLuongTon, TrangThai)
SELECT @DoUong, t.CoSoID, N'Nước suối', 10000, N'chai', 100, N'Đang kinh doanh' FROM @TargetCoSo t
UNION ALL
SELECT @DoUong, t.CoSoID, N'Nước điện giải', 18000, N'chai', 60, N'Đang kinh doanh' FROM @TargetCoSo t
UNION ALL
SELECT @ThueDungCu, t.CoSoID, N'Thuê vợt', 30000, N'lượt', 20, N'Đang kinh doanh' FROM @TargetCoSo t
UNION ALL
SELECT @PhuKien, t.CoSoID, N'Khăn lạnh', 8000, N'cái', 80, N'Đang kinh doanh' FROM @TargetCoSo t
UNION ALL
SELECT @PhuKien, t.CoSoID, N'Băng cổ tay', 15000, N'cái', 40, N'Đang kinh doanh' FROM @TargetCoSo t
UNION ALL
SELECT @ThueDungCu, t.CoSoID, N'Bóng/cầu thêm', 20000, N'quả', 50, N'Đang kinh doanh' FROM @TargetCoSo t;

PRINT N'Đã seed dịch vụ mẫu cho ' + CAST((SELECT COUNT(*) FROM @TargetCoSo) AS NVARCHAR) + N' Cơ Sở chưa có dữ liệu dịch vụ.';
GO
