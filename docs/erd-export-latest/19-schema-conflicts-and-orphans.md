# 19 — Xung đột, bảng mồ côi và điểm đáng nghi trong schema

Chỉ **báo cáo**. Không sửa source code, không sửa database.

---

## 1. Migration KHÔNG chạy được trên SQL Server

**`sql/migration_guard_module.sql`** viết bằng cú pháp **MySQL** nhưng hệ thống dùng
Microsoft SQL Server:

| Dòng | Cú pháp MySQL | SQL Server không hỗ trợ |
|---|---|---|
| `ALTER TABLE CaLamViec ADD COLUMN IF NOT EXISTS …` | `ADD COLUMN`, `IF NOT EXISTS` | Phải là `ADD <col>` và bọc `IF NOT EXISTS(SELECT … sys.columns)` |
| `SuCoID INT AUTO_INCREMENT` | `AUTO_INCREMENT` | Phải là `IDENTITY(1,1)` |
| `LoaiSuCo ENUM('…')`, `MucDo ENUM(…)`, `TrangThai ENUM(…)` | `ENUM` | Không có kiểu ENUM; phải dùng `VARCHAR` + `CHECK` |
| `MoTa TEXT`, `GhiChuXuLy TEXT` | `TEXT` | Có nhưng đã deprecated; nên là `NVARCHAR(MAX)` |
| `ThoiGianTao DATETIME DEFAULT CURRENT_TIMESTAMP` | `CURRENT_TIMESTAMP` | Nên là `GETDATE()` |
| `INDEX idx_… (…)` bên trong `CREATE TABLE` | INDEX inline | Phải tách thành `CREATE INDEX` |

Trong khi đó `dao/impl/SuCoDAOImpl.java` lại viết SQL đúng chuẩn SQL Server
(`SELECT TOP (?)`, `GETDATE()`). ⇒ Bảng `SuCo` trên DB thật (nếu tồn tại) **chắc chắn
không được tạo bởi file migration này**, và kiểu dữ liệu thật của nó **chưa xác minh được**.
Bộ xuất giữ nguyên `ENUM`/`TEXT` theo file migration thay vì tự đoán.

---

## 2. Migration nằm sai chỗ

`migration_face_attendance.sql` nằm ở `src/main/resources/` thay vì `sql/` như 60 file
migration còn lại. File này sẽ bị đóng gói vào WAR khi build — không gây lỗi nhưng dễ bị
bỏ sót khi chạy migration.

---

## 3. Bảng có trong source/migration nhưng KHÔNG có trên DB thật (15 bảng)

`BangLuong`, `BookingExtension`, `CauHinhLuong`, `ChiaHoaDon`, `CoSoFaceConfig`,
`FaceChallengeToken`, `KyLuong`, `LichDatSan_DichVu`, `MaQR`, `SuCo`, `TeamInvitations`,
`TeamJoinRequests`, `TeamMembers`, `Teams`, `YeuCauUngLuong`

Trong đó `ChiaHoaDon` và `MaQR` là **legacy** (đã bị `NhomChiaTien`/`NhomChiaTienChiTiet`
thay thế); 13 bảng còn lại là module đang phát triển, migration chưa chạy.

## 4. Bảng có trên DB thật nhưng KHÔNG có `CREATE TABLE` trong repo (8 bảng)

`CaLamViec_Audit`, `CaLamViec_Availability`, `CaLamViec_SwapRequest`, `YeuCauNghi`,
`YeuCauNghi_Audit`, `SoftHold`, `LoaiSan_KhungGioDen_Backup`, `sysdiagrams`

Nghĩa là các bảng này được tạo trực tiếp trên DB (SSMS hoặc script đã bị xóa). Cấu trúc cột
trong bộ xuất lấy 100% từ snapshot DB thật nên chính xác, nhưng **không tái lập được**
tên constraint PK/DEFAULT/CHECK của chúng.

---

## 5. Cột có trong model Java nhưng KHÔNG có cột tương ứng

| Model | Field | Ghi chú |
|---|---|---|
| `TaiKhoan.java` | `passwordSalt` | Bảng `Accounts` **không có** cột `PasswordSalt`. Field chết (hệ thống dùng BCrypt, salt nằm trong chuỗi hash). |
| `Lichdatsan.java` | `actualStartTime`, `actualEndTime` | Bảng có cột `actual_start_time` / `actual_end_time` (**snake_case**) — DAO map thủ công, không phải field chết, nhưng đặt tên lệch chuẩn so với toàn bộ schema PascalCase. |
| `BangLuong.java` | `hoTen`, `avatarUrl`, `maNganHang`, `soTaiKhoan`, `qrImagePath`, `ngayPhatLuong`, `qrDongUrl` | Field JOIN từ `Accounts`/`KyLuong`, **không phải cột vật lý** — dễ nhầm khi vẽ ERD. |
| `KyLuong.java` | `soNhanVien`, `tongChi` | Giá trị tính toán (aggregate), không phải cột. |
| `CauHinhLuong.java`, `YeuCauUngLuong.java` | `hoTen` | Field JOIN. |
| `San.java` | 18 field `…Active`, `next…`, `giaCoDen`, `giaKhongDen`, `gioBatDauLenDen`… | Field JOIN từ `LoaiSan` và `LichDatSan` cho màn hình sơ đồ sân, **không phải cột của `San`**. |
| `AdminTrash.java` | `deletedByName`, `restored` | Field hiển thị. |
| `ServiceMaterial.java`, `SportService.java`, `Team.java` | `deleted`, `acceptingRequests` | Là getter/setter của cột `IsDeleted` / `IsAcceptingRequests` (đặt tên rút gọn kiểu boolean Java). |

## 6. Bảng có nhưng model không dùng / DAO tham chiếu bảng không tồn tại

- **`dao/impl/DatSanDAOImpl.java` truy vấn `SELECT COUNT(*) FROM DatSan`** — **không có bảng
  `DatSan`** trên DB thật (tên đúng là `LichDatSan`). Truy vấn này sẽ luôn ném SQLException
  (đang bị nuốt bằng `e.printStackTrace()`). `model/DatSan.java` cũng không ánh xạ tới bảng nào.
- `sql/migration_refund_workflows.sql` và `sql/migration_promotional_codes.sql` viết
  `REFERENCES TaiKhoan(AccountID)` — `TaiKhoan` là **tên class Java**, tên bảng thật là
  `Accounts`. Hai file này sẽ lỗi nếu chạy nguyên trạng.
- `LoaiSan_KhungGioDen_Backup` là bảng sao lưu tạm của một migration, không có PK, không có
  FK, không có code nào dùng → nên cân nhắc xóa.

---

## 7. Bảng không có PRIMARY KEY

- `LoaiSan_KhungGioDen_Backup` — bảng backup, chấp nhận được nhưng nên ghi chú.

## 8. Cột trông giống FK nhưng KHÔNG có constraint (21 cột)

Xem đầy đủ ở `10-inferred-relations.md`. Đáng chú ý nhất:

| Cột | Đáng lẽ trỏ tới | Vì sao nghiêm trọng |
|---|---|---|
| `FaceChallengeToken.CaLamViecID` (NOT NULL) | `CaLamViec` | Bắt buộc mà không có FK → token mồ côi khi ca bị xóa |
| `CaLamViec_Audit.CaLamViecID` | `CaLamViec` | Bảng nhật ký mất liên kết với ca |
| `HoanTien.DatSanID`, `HoanTien.CoSoID` | `LichDatSan`, `CoSo` | Có **index** nhưng không có FK — chứng tỏ được dùng để join thường xuyên |
| `LichSuKhuyenMai.DatSanID` | `LichDatSan` | Lịch sử dùng mã mất liên kết với lượt đặt |
| `AuditLog.CoSoID` | `CoSo` | Có index `IX_AuditLog_CoSo` nhưng không có FK |
| `SuCo.SanID`, `SuCo.XuLyBoi` | `San`, `Accounts` | Module mới, FK thiếu ngay từ migration |
| 12 cột `DeletedBy` (Accounts, AdminTrash, CaLamViec, CoSo, LichDatSan, LoaiSan, LoaiSan_KhungGioDen_Backup, San, SanPham_DichVu, Teams, ThongBao, YeuCauNghi) | `Accounts` | Toàn bộ hệ thống soft delete **không có FK nào** cho `DeletedBy` |

> Ngược lại, các cột `CreatedBy` / `UpdatedBy` / `ApprovedBy` / `ConfirmedBy` / `CancelledBy` /
> `RevokedBy` / `ChangedBy` / `XuLyBy` / `NguoiDuyet` / `NguoiThucHien` **đều đã có FK vật lý**
> — chỉ riêng `DeletedBy` bị bỏ sót một cách hệ thống.

---

## 9. Quan hệ vòng và tự tham chiếu (cần chú ý khi vẽ)

1. **`Accounts` ↔ `CoSo` — vòng 2 chiều**: `Accounts.CoSoID → CoSo.CoSoID` và
   `CoSo.AccountID_QuanLy → Accounts.AccountID`. Cả hai đều NULLable nên hợp lệ, nhưng khi
   vẽ ERD phải thể hiện **hai đường riêng biệt**, không gộp.
2. **`HoaDon.ParentHoaDonID → HoaDon.HoaDonID`** — tự tham chiếu (hóa đơn con của hóa đơn cha).
3. **`CaLamViec_SwapRequest`** có **4 FK** cùng lúc về 2 bảng: `CaLamViecID_Gui` và
   `CaLamViecID_Nhan` → `CaLamViec`; `AccountID_Gui`, `AccountID_Nhan`, `NguoiDuyet` → `Accounts`.
   Đây là chỗ dễ rối đường nối nhất trong toàn schema.
4. **`Accounts` là bảng cha của 57 FK** — nếu vẽ chung một ảnh sẽ thành mạng nhện. Bắt buộc
   dùng bảng tham chiếu rút gọn ở các nhóm khác (đã cấu hình trong `13-erd-groups.csv`).

## 10. Hai bảng có mục đích gần giống nhau

| Cặp | Nhận xét |
|---|---|
| `ChiaHoaDon` + `MaQR` **vs** `NhomChiaTien` + `NhomChiaTienChiTiet` | Cùng là "chia hóa đơn". Cặp đầu là bản V4 gốc (không tồn tại trên DB thật), cặp sau là bản đang dùng. |
| `SanPham_DichVu` **vs** `SportService` | `SanPham_DichVu` = hàng hóa/dịch vụ bán lẻ tại quầy; `SportService` = dịch vụ kỹ thuật (căng vợt…). Tên gần giống, dễ nhầm khi vẽ. |
| `LichDatSan_DichVu` **vs** `ServiceOrder` | Cả hai đều là "đặt dịch vụ", một gắn với lượt đặt sân, một là đơn độc lập. |
| `MonTheThaoYeuThich` (bảng N-N) **vs** `Accounts.MonTheThaoYeuThichID` (cột FK đơn) | Hai cơ chế song song cho cùng một nghiệp vụ. Cột `MonTheThaoYeuThichID` từ `migration_customer_profile.sql` chưa có trên DB thật. |
| `CaLamViec.TrangThai` **vs** `CaLamViec.GioVaoThuc/GioRaThuc` **vs** `CaLamViec.FaceVerified` | Ba nguồn thông tin điểm danh chồng lấn nhau. |

## 11. Đặt tên không nhất quán

- `LichDatSan.actual_start_time`, `LichDatSan.actual_end_time` — **snake_case** giữa một
  schema toàn PascalCase. Cùng bảng lại có `ActualStartAt`, `ActualEndAt` (PascalCase,
  DATETIME) → **4 cột thời gian thực tế** dễ nhầm lẫn, chưa rõ cột nào là nguồn đúng.
- `MonTheThaoYeuThich.NgayThêm` — **tên cột có dấu tiếng Việt** (`ê`). Chỉ có duy nhất một
  cột như vậy trong toàn bộ database; buộc phải bọc `[NgayThêm]` khi viết SQL.
- FK do SQL Server tự đặt tên (`FK__CaLamViec__Accou__4F47C5E3`, `FK__YeuCauNgh__XuLyB__40058253`, …)
  — 13 FK dạng này, khó đọc trên sơ đồ. `04-foreign-keys.csv` có cột
  `SuggestedVietnameseLabel` để dùng làm nhãn thay thế.
- Tên constraint UNIQUE tự sinh: `UQ__KhuyenMa__152C7C5C7613DE24`.

## 12. Migration trùng lặp

- `sql/migration_fix_accounts_reputation_columns.sql` sửa lại các cột do
  `sql/migration_customer_reputation_cancel_flow.sql` tạo ra → hai migration cùng động vào
  `Accounts.LateCancelCount` / `NoShowCount` / `CompletedBookingCount`.
- `sql/repair_thongbao_unique_index.sql` tạo lại unique index mà
  `sql/migration_thongbao_table.sql` đã tạo.
- `sql/migration_san_qr_hardening.sql` bổ sung constraint cho bảng do
  `sql/migration_san_qr.sql` tạo.

Không phát hiện trường hợp hai migration tạo **cùng một constraint với tên trùng nhau** mà
không có guard `IF NOT EXISTS`.

---

## 13. Bảng không xếp được vào nhóm nghiệp vụ nào

- `sysdiagrams` — bảng hệ thống của SSMS. Đã đưa vào nhóm `G99` và **khuyến nghị không vẽ**
  trong bất kỳ ảnh ERD nào.
- `LoaiSan_KhungGioDen_Backup` — bảng backup; đã đặt tạm vào nhóm `G05` (Sân & Loại sân)
  và đánh dấu legacy.

---

## 14. Sai sót của bộ xuất cũ `erd-input/` (2026-08-03) — đã không dùng làm nguồn

1. Đặt sai tên 3 bảng: `CaLamViecAudit`, `CaLamViecAvailability`, `CaLamViecSwapRequest`.
   Tên thật trên DB: `CaLamViec_Audit`, `CaLamViec_Availability`, `CaLamViec_SwapRequest`.
2. Thiếu 7 bảng: `CauHinhLuong`, `KyLuong`, `BangLuong`, `YeuCauUngLuong`, `CoSoFaceConfig`,
   `FaceChallengeToken`, `SuCo`.
3. Bảng `CaLamViec` chỉ liệt kê 10 cột trong khi DB thật có **18 cột** (thiếu `Thu`,
   `IsPublished`, `TenCa`, `ViTri`, `TrangThai`, `GioNghi`, `IsCustomTime`, `CustomTimeReason`).
4. Sai độ dài kiểu dữ liệu: ghi `Accounts.FullName NVARCHAR(255)` và `AvatarUrl NVARCHAR(500)`
   trong khi DB thật là `NVARCHAR(100)` và `NVARCHAR(255)`.
5. Liệt kê `LichDatSan_DichVu`, `ChiaHoaDon`, `MaQR`, `Teams*` như bảng đang tồn tại mà không
   ghi rõ chúng không có trên DB thật.

---

## 15. Dữ liệu chưa đủ căn cứ trong chính bộ xuất này

| Mục | Tình trạng |
|---|---|
| `OnDelete` / `OnUpdate` của toàn bộ 137 FK | Ghi `NO ACTION` = **mặc định SQL Server**, không phải giá trị đọc từ DB |
| Tên constraint DEFAULT của các cột thuộc DB thật | Không có trong snapshot |
| CHECK constraint thực tế trên DB | Không có trong snapshot; 39 CHECK trong `07-…csv` đều lấy từ migration |
| Cờ IDENTITY của các bảng tạo ngoài repo (mục 4) | Không xác minh được |
| `EstimatedRowCount` | Không có (không kết nối được DB) |
| `IncludedColumns`, `FilterDefinition` của index thuộc DB thật | Snapshot chỉ dump cột khóa |
| Kiểu dữ liệu thật của bảng `SuCo` | Xem mục 1 |
