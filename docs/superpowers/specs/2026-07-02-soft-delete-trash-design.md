# Thiết kế: Xóa mềm toàn hệ thống + Thùng rác (V-SPORT)

Ngày: 2026-07-02
Trạng thái: Đã được duyệt

## Mục tiêu

Chuyển tất cả chức năng xóa trong hệ thống sang xóa mềm, và thêm giao diện Thùng rác cho Manager để khôi phục hoặc xóa vĩnh viễn. Item trong thùng rác tự động bị xóa vĩnh viễn sau 30 ngày.

## Quyết định đã chốt

1. **Phạm vi**: mọi entity có chức năng xóa — `San`, `LoaiSan`, `SanPham_DichVu`, `CaLamViec`, `ThongBao`, `YeuCauNghi`, `LichDatSan`, `CoSo`, `Accounts` (nhân sự/người dùng). **Ngoại lệ**: `SoftHold` giữ xóa cứng (dữ liệu giữ chỗ tạm, tự hết hạn).
2. **Quyền**: Manager có trang thùng rác riêng theo cơ sở (`/manager/thung-rac`). `CoSo` và tài khoản do Admin xóa được khôi phục qua trang quản lý hiện có của Admin (không có trang thùng rác Admin riêng).
3. **Lưu trữ**: thêm cột `IsDeleted`, `DeletedAt`, `DeletedBy` vào từng bảng (không dùng bảng thùng rác tập trung).
4. **Giao diện**: một trang thùng rác duy nhất cho Manager, có tab/filter theo loại entity.
5. **Dọn rác**: job nền chạy mỗi 24h, xóa vĩnh viễn bản ghi có `DeletedAt` quá 30 ngày. Manager cũng có nút "Xóa vĩnh viễn" thủ công (kèm dialog xác nhận).

## 1. Database

Thêm vào các bảng `San`, `LoaiSan`, `SanPham_DichVu`, `CaLamViec`, `ThongBao`, `YeuCauNghi`, `LichDatSan`, `CoSo`:

```sql
IsDeleted BIT NOT NULL DEFAULT 0,
DeletedAt DATETIME NULL,
DeletedBy INT NULL  -- AccountID người xóa
```

- `Accounts` đã có `isDeleted` — chỉ thêm `DeletedAt`, `DeletedBy`.
- Migration script: `sql/migration_soft_delete.sql`, chạy tay trên SQL Server.
- `San`: bỏ cơ chế "xóa = trạng thái Tạm đóng". `Tạm đóng` trở về đúng nghĩa trạng thái nghiệp vụ; xóa dùng `IsDeleted`.

## 2. Model + DAO

- Mỗi entity thêm field `isDeleted` (boolean), `deletedAt` (LocalDateTime), `deletedBy` (Integer).
- Mỗi DAO của các entity trên:
  - `delete(id, actorId)` → `UPDATE ... SET IsDeleted=1, DeletedAt=GETDATE(), DeletedBy=?`
  - `restore(id)` → `SET IsDeleted=0, DeletedAt=NULL, DeletedBy=NULL`
  - `hardDelete(id)` → DELETE thật (dùng cho nút Xóa vĩnh viễn và job dọn rác)
  - `findDeletedByCoSo(coSoId)` → danh sách item trong thùng rác của cơ sở
- **Rà toàn bộ query SELECT hiện có** để thêm `AND IsDeleted = 0` (danh sách điểm sửa cụ thể sẽ nằm trong implementation plan).
- `CoSo` xóa mềm **không chạy cascade 16 bước** — chỉ đánh dấu `IsDeleted=1`; dữ liệu con giữ nguyên, tự ẩn vì các query lọc theo cơ sở hoạt động. Cascade cũ chỉ chạy khi xóa vĩnh viễn.

## 3. Quy tắc khôi phục

| Tình huống | Hành vi |
|---|---|
| Khôi phục LoaiSan/SanPham trùng tên với bản ghi đang hoạt động | Cho phép, hiển thị cảnh báo |
| Khôi phục San khi LoaiSan cha đang trong thùng rác | Chặn — báo "Hãy khôi phục loại sân trước" |
| Khôi phục CaLamViec/LichDatSan đã qua ngày | Cho phép (dữ liệu lịch sử) |
| Khôi phục nhân viên | Dùng cơ chế restore sẵn có (`isDeleted=0, isLocked=0`), gom vào trang thùng rác |
| Khôi phục CoSo (Admin) | `IsDeleted=0`, toàn bộ dữ liệu con trở lại nguyên vẹn |

## 4. Trang thùng rác Manager

- Servlet mới `ThungRacManagerServlet` route `/manager/thung-rac`; JSP `manager/ThungRac.jsp` theo style purple/Tailwind hiện có.
- Sidebar manager thêm mục "Thùng rác" (icon Material Symbols `delete`).
- Tab/filter theo loại: Sân, Loại sân, Sản phẩm/Dịch vụ, Ca làm, Thông báo, Đơn nghỉ, Booking, Nhân sự; kèm ô tìm kiếm theo tên.
- Mỗi dòng hiển thị: loại, tên item, người xóa, ngày xóa, đếm ngược "còn N ngày" trước khi tự hủy, nút **Khôi phục** và **Xóa vĩnh viễn** (có dialog xác nhận).
- Mọi thao tác POST xác thực `coSoId` của manager (dùng `BranchSecurityUtils` như các trang khác).

## 5. Job dọn rác tự động

- `TrashCleanupListener` (`@WebListener` implements `ServletContextListener`) khởi động `ScheduledExecutorService` chạy mỗi 24h.
- Tìm bản ghi `IsDeleted=1 AND DeletedAt < DATEADD(day, -30, GETDATE())` và gọi `hardDelete`, xóa con trước cha để tôn trọng FK. CoSo quá hạn → chạy cascade 16 bước cũ.
- Shutdown executor trong `contextDestroyed`.

## 6. Phía Admin

- `QuanLySanServlet` (admin xóa San) chuyển sang `IsDeleted`.
- Trang quản lý cơ sở của Admin: thêm filter "Đã xóa" + nút Khôi phục cho CoSo.
- Trang người dùng Admin: giữ nguyên restore/permanentDelete hiện có, đồng bộ thêm `DeletedAt/DeletedBy`.

## Kiểm thử

- Với mỗi entity: xóa → biến mất khỏi danh sách chính, xuất hiện trong thùng rác → khôi phục → trở lại danh sách chính.
- Chặn khôi phục San khi LoaiSan cha đã xóa.
- Xóa vĩnh viễn xóa thật khỏi DB.
- Manager cơ sở A không thấy/không thao tác được item thùng rác của cơ sở B.
- Job dọn rác: hạ mốc 30 ngày xuống vài phút để test, xác nhận bản ghi quá hạn bị xóa cứng.
