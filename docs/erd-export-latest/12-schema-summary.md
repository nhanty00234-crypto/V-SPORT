# 12 — Tóm tắt schema V-SPORT

| Chỉ số | Số lượng |
|---|---|
| Tổng số bảng | 68 |
| — trong đó có trong snapshot DB thật (2026-08-02) | 53 |
| — chỉ có trong migration SQL / source | 15 |
| Tổng số cột | 791 |
| Tổng số PRIMARY KEY | 67 |
| Tổng số FOREIGN KEY vật lý | 137 |
| — FK xác minh trên DB thật | 103 |
| Tổng số UNIQUE (constraint + unique index, không tính PK) | 32 |
| Tổng số index (gồm PK) | 147 |
| Tổng số CHECK constraint | 39 |
| Bảng KHÔNG có PK | 1 |
| Bảng KHÔNG có quan hệ nào | 4 |
| Bảng legacy | 4 |
| Bảng có soft delete | 16 |
| Nhóm ERD đề xuất | 26 |

## Bảng không có PRIMARY KEY

- `LoaiSan_KhungGioDen_Backup`

## Bảng không tham gia quan hệ nào

- `AdminTrash`
- `AuditLog`
- `LoaiSan_KhungGioDen_Backup` (legacy)
- `sysdiagrams` (legacy)

## Bảng legacy

- `ChiaHoaDon` — Cơ chế chia hóa đơn đời cũ theo tên người, đã bị NhomChiaTien thay thế.
- `LoaiSan_KhungGioDen_Backup` — Bảng sao lưu dữ liệu khung giờ bật đèn của loại sân trước khi migration.
- `MaQR` — Mã QR thanh toán gắn với bản ghi chia hóa đơn đời cũ.
- `sysdiagrams` — Bảng hệ thống do SQL Server Management Studio tạo, không thuộc nghiệp vụ V-SPORT.

## Bảng có soft delete

`Accounts`, `AdminTrash`, `CaLamViec`, `CoSo`, `HoaDon`, `KhuyenMai`, `LichDatSan`, `LoaiSan`, `LoaiSan_KhungGioDen_Backup`, `San`, `SanPham_DichVu`, `ServiceMaterial`, `SportService`, `Teams`, `ThongBao`, `YeuCauNghi`

## Bảng mới nhất (chưa có trong snapshot DB 2026-08-02)

- `BangLuong` — Kết quả tính lương của một nhân viên trong một kỳ lương.
- `BookingExtension` — Yêu cầu gia hạn thời gian chơi của một lượt đặt sân.
- `CauHinhLuong` — Lương cơ bản, phụ cấp mỗi ca và hạn mức ứng của từng nhân viên tại một cơ sở.
- `ChiaHoaDon` — Cơ chế chia hóa đơn đời cũ theo tên người, đã bị NhomChiaTien thay thế.
- `CoSoFaceConfig` — Bật/tắt bắt buộc điểm danh khuôn mặt và ngưỡng tin cậy cho từng cơ sở (1-1 với cơ sở).
- `FaceChallengeToken` — Token một lần chứa chuỗi thử thách liveness cho một lần điểm danh.
- `KyLuong` — Kỳ tính lương theo cơ sở với ngày bắt đầu/kết thúc và ngày phát lương.
- `LichDatSan_DichVu` — Sản phẩm/dịch vụ khách đặt kèm trước cho một lượt đặt sân.
- `MaQR` — Mã QR thanh toán gắn với bản ghi chia hóa đơn đời cũ.
- `SuCo` — Báo cáo sự cố do bảo vệ ghi nhận tại cơ sở/sân, có quy trình xử lý.
- `TeamInvitations` — Lời mời do đội trưởng gửi cho tài khoản khác.
- `TeamJoinRequests` — Yêu cầu do người chơi gửi xin gia nhập một đội.
- `TeamMembers` — Bảng trung gian N-N giữa đội và tài khoản kèm vai trò trong đội.
- `Teams` — Đội/nhóm người chơi do khách hàng tạo và quản lý.
- `YeuCauUngLuong` — Đơn xin ứng lương của nhân viên, có quy trình duyệt.

## Module mới

- **Lương, phụ cấp & ứng lương** (`CauHinhLuong`, `KyLuong`, `BangLuong`, `YeuCauUngLuong`) — sql/migration_salary.sql
- **Điểm danh khuôn mặt** (`CoSoFaceConfig`, `FaceChallengeToken` + 3 cột trên Accounts, 6 cột trên CaLamViec) — src/main/resources/migration_face_attendance.sql
- **Bảo vệ / sự cố** (`SuCo` + `GioVaoThuc`, `GioRaThuc` trên CaLamViec) — sql/migration_guard_module.sql
- **Đội nhóm người chơi** (`Teams`, `TeamMembers`, `TeamInvitations`, `TeamJoinRequests`) — sql/migration_team_management.sql
- **Dịch vụ đặt trước theo lượt đặt sân** (`LichDatSan_DichVu`) — sql/migration_booking_service_preorder.sql
- **Gia hạn đặt sân** (`BookingExtension`) — sql/migration_booking_extension.sql

## Thay đổi lớn so với tài liệu ERD cũ (docs/erd, 2026-08-02)

- Tài liệu cũ có **53 bảng**; bộ xuất này có **68 bảng** (thêm 15 bảng từ migration chưa áp dụng).
- Thư mục `erd-input/` (xuất ngày 2026-08-03) đặt sai tên 3 bảng: `CaLamViecAudit`, `CaLamViecAvailability`, `CaLamViecSwapRequest`. Tên thật trong DB là `CaLamViec_Audit`, `CaLamViec_Availability`, `CaLamViec_SwapRequest`.
- `erd-input/` thiếu hoàn toàn 7 bảng: 4 bảng lương, 2 bảng face và `SuCo`.
- `erd-input/` liệt kê `LichDatSan_DichVu`, `ChiaHoaDon`, `MaQR`, `Teams*` như bảng thường; snapshot DB thật cho thấy các bảng này **không tồn tại**.

## Lỗi / điểm đáng nghi trong schema

Xem chi tiết ở `19-schema-conflicts-and-orphans.md`.
