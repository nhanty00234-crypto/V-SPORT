# 18 — Delta chức năng mới / thay đổi gần đây

Mốc so sánh: snapshot database thật ngày **2026-08-02** (`docs/erd/schema-full.json`).
Mọi mục "chưa xác minh" nghĩa là **có trong migration SQL + source code nhưng KHÔNG có
trong snapshot DB**, không phải là bảng/cột tưởng tượng.

---

## 1. Lương, phụ cấp & ứng lương  — **MỚI**

- **Migration**: `sql/migration_salary.sql`
- **Bảng mới**: `CauHinhLuong`, `KyLuong`, `BangLuong`, `YeuCauUngLuong`
- **Cột mới trên bảng cũ**: `Accounts.QrImagePath NVARCHAR(500) NULL` (ảnh QR nhận lương)
- **FK mới** (9): `CauHinhLuong.AccountID→Accounts`, `CauHinhLuong.CoSoID→CoSo`,
  `KyLuong.CoSoID→CoSo`, `KyLuong.CreatedBy→Accounts`, `BangLuong.KyLuongID→KyLuong`,
  `BangLuong.AccountID→Accounts`, `YeuCauUngLuong.AccountID→Accounts`,
  `YeuCauUngLuong.CoSoID→CoSo`, `YeuCauUngLuong.XuLyBy→Accounts`
- **Constraint mới**: `UQ_CauHinhLuong_Account_CoSo (AccountID, CoSoID)`,
  `UQ_BangLuong_Ky_Account (KyLuongID, AccountID)`,
  index `IX_KyLuong_CoSo`, `IX_YeuCauUngLuong_CoSo_TrangThai`, `IX_YeuCauUngLuong_Account`
- **Source code đang dùng**: `dao/CauHinhLuongDAO`, `dao/KyLuongDAO`, `dao/BangLuongDAO`,
  `dao/YeuCauUngLuongDAO` (+ `impl/`), `service/manager/LuongService`,
  `service/manager/UngLuongService`, `controller/manager/LuongManagerServlet`,
  `controller/manager/api/LuongManagerApiServlet`, `controller/staff/LuongStaffServlet`,
  `controller/guard/LuongGuardServlet`
- **Trạng thái**: **đang phát triển** — code hoàn chỉnh (commit `3f6f0f0`→`fd832e3`,
  Phase 1–6), schema chưa xác minh trên DB thật.

> Lưu ý nghiệp vụ: `BangLuong` không có cột `NgayPhatLuong`/`HoTen`/`QrImagePath` — model
> `BangLuong.java` có các field này nhưng chúng đến từ JOIN sang `KyLuong` và `Accounts`,
> không phải cột vật lý.

---

## 2. Điểm danh bằng khuôn mặt (face attendance) — **MỚI**

- **Migration**: `src/main/resources/migration_face_attendance.sql`
  (không nằm trong thư mục `sql/` như các migration khác — xem mục 19)
- **Bảng mới**: `CoSoFaceConfig` (PK = `CoSoID`, quan hệ **1–1** với `CoSo`),
  `FaceChallengeToken` (PK = `TokenID VARCHAR(64)`)
- **Cột mới trên `Accounts`**: `FaceDescriptor NVARCHAR(MAX)`, `FaceImagePath NVARCHAR(500)`,
  `FaceEnrolledAt DATETIME`
- **Cột mới trên `CaLamViec`**: `FaceVerified BIT NOT NULL DEFAULT 0`,
  `FaceCheckInImage NVARCHAR(500)`, `FaceConfidence FLOAT`,
  `FaceLivenessPassed BIT NOT NULL DEFAULT 0`, `FaceCheckOutImage NVARCHAR(500)`,
  `FaceCheckOutConfidence FLOAT`
- **FK mới**: `FK_FaceConfig_CoSo (CoSoFaceConfig.CoSoID → CoSo)`,
  `FK_FaceToken_Accounts (FaceChallengeToken.AccountID → Accounts)`
- **Source code đang dùng**: `dao/CoSoFaceConfigDAO`, `dao/FaceChallengeTokenDAO`,
  `controller/face/FaceChallengeServlet`, `controller/face/FaceCheckInServlet`,
  `controller/face/FaceEnrollServlet`, `controller/manager/FaceSettingsServlet`,
  `model/FaceAttendanceLog` (DTO read-only, **không phải bảng**)
- **Trạng thái**: **đang phát triển**, chưa xác minh trên DB thật.
- **Thiếu FK**: `FaceChallengeToken.CaLamViecID INT NOT NULL` **không có FK** sang
  `CaLamViec` dù bắt buộc → xem `10-inferred-relations.md`.

---

## 3. Bảo vệ & sự cố (GUARD module) — **MỚI**

- **Migration**: `sql/migration_guard_module.sql`
- **Bảng mới**: `SuCo`
- **Cột mới trên `CaLamViec`**: `GioVaoThuc DATETIME NULL`, `GioRaThuc DATETIME NULL`
- **FK mới**: `fk_suco_coso (SuCo.CoSoID → CoSo)`, `fk_suco_baove (SuCo.BaoVeID → Accounts)`
- **Source code đang dùng**: `dao/SuCoDAO` + `impl/SuCoDAOImpl`,
  `controller/guard/GuardBaoCaoSuCoServlet`, `controller/guard/GuardLichSuSuCoServlet`,
  `controller/guard/GuardDiemDanhServlet`, `controller/guard/GuardDashboardServlet`
- **Trạng thái**: **chưa xác minh — migration KHÔNG chạy được**. File viết bằng cú pháp
  **MySQL** (`AUTO_INCREMENT`, `ENUM(...)`, `TEXT`, `ADD COLUMN IF NOT EXISTS`,
  `INDEX ...` inline) trong khi hệ thống chạy SQL Server. `SuCoDAOImpl` lại dùng cú pháp
  SQL Server (`SELECT TOP (?)`, `GETDATE()`), nên bảng thật (nếu có) chắc chắn được tạo
  bằng đường khác. **Không suy đoán kiểu dữ liệu thật** — bộ xuất giữ nguyên `ENUM`/`TEXT`
  như file migration ghi.
- **Thiếu FK**: `SuCo.SanID`, `SuCo.XuLyBoi` không có FK.

---

## 4. Hoàn tiền — **đã có trên DB thật**

- **Migration**: `sql/migration_refund_workflows.sql`, `sql/migration_refund_customer_selfservice.sql`
- **Bảng**: `HoanTien` — **có trong snapshot DB**
- **FK vật lý xác minh**: `HoanTien.AccountID→Accounts`, `HoanTien.HoaDonID→HoaDon`
- **Index**: `IX_HoanTien_CoSoID`, `IX_HoanTien_DatSanID`, `IX_HoanTien_TrangThai`
- **Trạng thái**: **đang dùng**.
- **Điểm đáng chú ý**: `HoanTien.DatSanID` và `HoanTien.CoSoID` có index nhưng **không có
  FK vật lý** → quan hệ suy luận. Ngoài ra migration ghi
  `REFERENCES TaiKhoan(AccountID)` — `TaiKhoan` là **tên class Java**, tên bảng thật là
  `Accounts`.

---

## 5. Chia hóa đơn — **đã có trên DB thật**

- **Migration**: `sql/migration_group_bill_split.sql`
- **Bảng**: `NhomChiaTien`, `NhomChiaTienChiTiet` — **có trong snapshot DB**
- **FK vật lý xác minh** (7): `NhomChiaTien.DatSanID→LichDatSan`, `NhomChiaTien.HoaDonID→HoaDon`,
  `NhomChiaTien.CreatedByAccountID→Accounts`, `NhomChiaTienChiTiet.NhomChiaTienID→NhomChiaTien`,
  `NhomChiaTienChiTiet.AccountID→Accounts`, `NhomChiaTienChiTiet.PayerAccountID→Accounts`,
  `NhomChiaTienChiTiet.ConfirmedByStaffID→Accounts`
- **Constraint**: `UX_NhomChiaTien_HoaDon_Active` (unique lọc → 1 nhóm active/hóa đơn),
  `UX_NhomChiaTienChiTiet_ShareToken`, 4 CHECK trạng thái/số tiền
- **Trạng thái**: **đang dùng**. Cơ chế cũ `ChiaHoaDon` + `MaQR` (schema V4) **không tồn tại
  trên DB thật** → legacy.

---

## 6. Khuyến mãi — **đã có trên DB thật**

- **Migration**: `sql/migration_promotional_codes.sql`, `sql/migration_khuyenmai_hinhanh.sql`
- **Bảng**: `KhuyenMai`, `KhuyenMaiHinhAnh`, `LichSuKhuyenMai` — **đều có trong snapshot**
- **FK vật lý xác minh**: `KhuyenMai.CoSoID→CoSo`, `KhuyenMaiHinhAnh.KhuyenMaiID→KhuyenMai`,
  `LichSuKhuyenMai.KhuyenMaiID→KhuyenMai`, `LichSuKhuyenMai.AccountID→Accounts`,
  `HoaDon.KhuyenMaiID→KhuyenMai`
- **Constraint**: `UQ_KhuyenMaiHinhAnh_MotAnhBia` (unique lọc — chỉ 1 ảnh bìa/khuyến mãi),
  `UQ__KhuyenMa__…` trên `MaCode`
- **Trạng thái**: **đang dùng**. `LichSuKhuyenMai.DatSanID` không có FK → quan hệ suy luận.

---

## 7. ELO & điểm uy tín — **đã có trên DB thật**

- **Migration**: `sql/migration_customer_reputation_cancel_flow.sql`,
  `sql/migration_reputation_history_idempotency.sql`, `sql/migration_fix_accounts_reputation_columns.sql`
- **Bảng**: `LichSuELO`, `CustomerReputationHistory` — **có trong snapshot**
- **Cột trên `Accounts`**: `DiemUyTin`, `DiemTrinhDo`, `LateCancelCount`, `NoShowCount`,
  `CompletedBookingCount` — **có trong snapshot**
- **Constraint chống trùng**: `UQ_ReputationHistory_Account_DatSan_Action (AccountID, DatSanID, ActionType)`
- **Trạng thái**: **đang dùng**.

---

## 8. QR sân — **đã có trên DB thật**

- **Migration**: `sql/migration_san_qr.sql`, `sql/migration_san_qr_hardening.sql`, `sql/migration_qr_request.sql`
- **Bảng**: `SanQR`, `SanQRTokenHistory`, `QRRequest` — **có trong snapshot**
- **FK vật lý xác minh** (7): `SanQR.SanID→San`, `SanQR.CreatedBy/UpdatedBy→Accounts`,
  `SanQRTokenHistory.SanQRID→SanQR`, `SanQRTokenHistory.SanID→San`,
  `SanQRTokenHistory.RevokedBy→Accounts`, `QRRequest.CoSoID→CoSo`, `QRRequest.SanID→San`
- **Quan hệ 1–1**: `UQ_SanQR_SanID` khiến `SanQR` ↔ `San` là **1–1** (mỗi sân đúng 1 mã QR).
- **Trạng thái**: **đang dùng**.

---

## 9. Giữ xe — **đã có trên DB thật**

- **Bảng**: `TheGiuXe`, `LichXeRaVao` (schema V4) — **có trong snapshot**
- **FK vật lý xác minh**: `TheGiuXe.CoSoID→CoSo`, `LichXeRaVao.TheID→TheGiuXe`,
  `LichXeRaVao.DatSanID→LichDatSan`, `LichXeRaVao.AccountID_NhanVien→Accounts`
- **Trạng thái**: **đang dùng nhưng ít** — không tìm thấy migration mới nào cho module này.

---

## 10. Giữ chỗ tạm thời (SoftHold) — **đã có trên DB thật**

- **Migration**: `sql/migration_reservation_hold.sql` (chỉ thêm cột `HoldExpiresAt` vào
  `LichDatSan`); **CREATE TABLE của `SoftHold` không có trong bất kỳ file SQL nào của repo**.
- **Bảng**: `SoftHold` — **có trong snapshot DB** (đã tạo bằng đường ngoài repo)
- **FK vật lý xác minh**: `SoftHold.AccountID→Accounts`, `SoftHold.SanID→San`
- **Index**: `IX_SoftHold_San_Ngay (SanID, NgayDat, CreatedTime)`
- **Trạng thái**: **đang dùng** (`dao/impl/SoftHoldDAOImpl`, `sql/diagnose_and_repair_ghost_booking.sql`).

---

## 11. Thông báo — **đã có trên DB thật**

- **Migration**: `sql/migration_thongbao_table.sql`, `sql/migration_notification_marketing_refund_review.sql`,
  `sql/repair_thongbao_unique_index.sql`
- **Bảng**: `ThongBao` — **có trong snapshot**; cột `Accounts.NhanThongBaoMarketing` cũng có.
- **Constraint chống trùng**: `UQ_ThongBao_Account_Loai_MaBanGhi (AccountID, LoaiThongBao, MaBanGhi)`
- **Index**: `IX_ThongBao_Unread`, `IX_ThongBao_AccountID_ThoiGian`
- **Trạng thái**: **đang dùng**.

---

## 12. Chat — **đã có trên DB thật**

- **Bảng**: `NhatKyChat` (schema V4), FK `NhatKyChat.AccountID→Accounts` — **đang dùng**
- Không có migration mới. Không có bảng phòng chat / tin nhắn giữa người dùng.

---

## 13. SOS — **đã có trên DB thật**

- **Bảng**: `YeuCauSOS`, `NhatKySOSGui` — **có trong snapshot**
- **FK vật lý xác minh**: `YeuCauSOS.AccountID_Tao→Accounts`, `YeuCauSOS.DatSanID→LichDatSan`,
  `YeuCauSOS.MonTheThaoID→MonTheThao`, `NhatKySOSGui.YeuCauSOSID→YeuCauSOS`,
  `NhatKySOSGui.AccountID_NhanGui→Accounts`
- **Trạng thái**: **đang dùng**.

---

## 14. Ca làm việc & nghỉ phép — **đã có trên DB thật**

- **Bảng**: `CaLamViec`, `CaLamViec_Audit`, `CaLamViec_Availability`, `CaLamViec_SwapRequest`,
  `YeuCauNghi`, `YeuCauNghi_Audit` — **đều có trong snapshot**
- **CREATE TABLE của 6 bảng này không có trong repo** (tạo ngoài repo hoặc bằng script đã xóa).
  Cấu trúc cột trong bộ xuất lấy 100% từ snapshot DB thật.
- **FK vật lý xác minh** (11), gồm quan hệ tự tham chiếu đôi của `CaLamViec_SwapRequest`
  (`CaLamViecID_Gui` và `CaLamViecID_Nhan` cùng trỏ về `CaLamViec`).
- **View**: `V_YeuCauNghi_ChiTiet` (`sql/fix_view_yeuCauNghi.sql`) — là VIEW, không phải bảng,
  nên không đưa vào ERD.
- **Trạng thái**: **đang dùng**. Cột mới `GioVaoThuc`/`GioRaThuc` + 6 cột Face **chưa xác minh**.

---

## 15. Các module khác chưa có trên DB thật

| Module | Bảng | Migration | Trạng thái |
|---|---|---|---|
| Đội nhóm người chơi | `Teams`, `TeamMembers`, `TeamInvitations`, `TeamJoinRequests` | `sql/migration_team_management.sql` | Chưa xác minh — cũng thêm `GhepKeo.TeamIDNguoiTao`, `ChiTietGhepKeo.TeamIDNguoiThamGia` |
| Dịch vụ đặt trước theo lượt đặt sân | `LichDatSan_DichVu` | `sql/migration_booking_service_preorder.sql` | Chưa xác minh |
| Gia hạn đặt sân | `BookingExtension` | `sql/migration_booking_extension.sql` | Chưa xác minh |
| Hồ sơ khách hàng mở rộng | 8 cột trên `Accounts` (`CoverImageUrl`, `ChieuCaoCm`, `CanNangKg`, `GhiChuDacBiet`, `ViTriYeuThich`, `MonTheThaoYeuThichID`, `TrinhDoChoi`, `MucTieuChoi`, `TanSuatChoi`) | `sql/migration_customer_profile.sql` | Chưa xác minh — nhưng UI `HoSo.jsp` đã dùng |
| Ghép kèo nâng cao | `GhepKeo.SoNguoiCanTim`, `HinhThucDuyet`, `CreatedAt` | `sql/migration_matchmaking_complete_flow.sql` | Chưa xác minh |
| Chia hóa đơn đời cũ | `ChiaHoaDon`, `MaQR` | `Tài nguyên/QuanLiSport_V4.sql` | **Legacy** — không tồn tại trên DB thật |
