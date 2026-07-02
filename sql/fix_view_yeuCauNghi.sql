-- fix_view_yeuCauNghi.sql
-- Thêm bộ lọc IsDeleted = 0 vào view V_YeuCauNghi_ChiTiet
-- để các bản ghi đã soft-delete không hiển thị trong danh sách hoạt động.
-- Chạy tay trên SQL Server sau khi migration_soft_delete.sql đã được áp dụng.

IF OBJECT_ID('dbo.V_YeuCauNghi_ChiTiet', 'V') IS NOT NULL
    DROP VIEW dbo.V_YeuCauNghi_ChiTiet;
GO

CREATE VIEW dbo.V_YeuCauNghi_ChiTiet AS
SELECT
    ycn.YeuCauNghiID,
    ycn.AccountID,
    ycn.CoSoID,
    ycn.NgayNghi,
    ycn.LoaiNghi,
    ycn.LyDo,
    ycn.MucDoKhanCap,
    ycn.TrangThai,
    ycn.GhiChuQuanLy,
    ycn.NgayXuLy,
    ycn.XuLyBy,
    ycn.NgayGui,
    ycn.CreatedAt,
    ycn.UpdatedAt,
    ycn.IsDeleted,
    ycn.DeletedAt,
    ycn.DeletedBy,
    tk.FullName   AS TenNhanVien,
    tk.Username   AS username,
    cs.TenCoSo,
    r.RoleName,
    ql.FullName   AS QuanLyXuLy,
    -- Số ca làm việc bị ảnh hưởng (nếu có bảng CaLamViec liên quan)
    0             AS SoCaBiAnhHuong
FROM dbo.YeuCauNghi ycn
LEFT JOIN dbo.Accounts  tk ON ycn.AccountID = tk.AccountID
LEFT JOIN dbo.Roles      r ON tk.RoleID      = r.RoleID
LEFT JOIN dbo.CoSo      cs ON ycn.CoSoID    = cs.CoSoID
LEFT JOIN dbo.Accounts  ql ON ycn.XuLyBy    = ql.AccountID
WHERE ycn.IsDeleted = 0;
GO

PRINT 'View V_YeuCauNghi_ChiTiet recreated with IsDeleted = 0 filter.';
