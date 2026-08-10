# V2 Schema Mapping — V1 (tiếng Việt) → V2 (tiếng Anh snake_case)

Tài liệu ánh xạ dùng khi migrate code Java từ `V_sport_script.sql` sang `V_sport_script_V2.sql`.

## Quy ước chung

| Khái niệm | V1 | V2 |
|---|---|---|
| Tên bảng | PascalCase tiếng Việt, số ít | snake_case tiếng Anh, **số nhiều** |
| Tên cột | PascalCase tiếng Việt | snake_case tiếng Anh |
| Khoá chính | `<Tên>ID` | `<tên_bảng_số_ít>_id` |
| Khoá ngoại | `<Bảng>ID` | `<bảng_số_ít>_id` |
| Ràng buộc | `PK_`, `FK_`, `DF_`, `CK_`, `UQ_`, `IX_` | `pk_`, `fk_`, `df_`, `ck_`, `uq_`, `ix_` |

### Cột lặp lại ở nhiều bảng (áp dụng toàn cục)

| V1 | V2 |
|---|---|
| `TrangThai` | `status` |
| `GhiChu` | `note` |
| `MoTa` | `description` |
| `HinhAnh` | `image_path` |
| `IsDeleted` | `is_deleted` |
| `DeletedAt` / `DeletedBy` | `deleted_at` / `deleted_by` |
| `CreatedAt` / `CreatedTime` | `created_at` |
| `UpdatedAt` | `updated_at` |
| `CoSoID` | `facility_id` |
| `SanID` | `court_id` |
| `DatSanID` | `booking_id` |
| `HoaDonID` | `invoice_id` |
| `AccountID` | `account_id` |
| `MonTheThaoID` | `sport_id` |
| `SanPhamID` | `product_id` |
| `KhuyenMaiID` | `promotion_id` |

---

## 1. Ánh xạ bảng (42 bảng)

| # | V1 | V2 | Ghi chú |
|---|---|---|---|
| 1 | `Roles` | `roles` | **Cấu trúc & ID giữ nguyên tuyệt đối** |
| 2 | `Accounts` | `accounts` | bỏ `DiemTrinhDo`, `NhanThongBaoSOS` |
| 3 | `MonTheThao` | `sports` | |
| 4 | `DanhMucSanPham` | `product_categories` | |
| 5 | `CoSo` | `facilities` | |
| 6 | `CoSoCapability` | `facility_capabilities` | |
| 7 | `CoSoNganHang` | `facility_bank_accounts` | |
| 8 | `LoaiSan` | `court_types` | |
| 9 | `San` | `courts` | |
| 10 | `SanQR` | `court_qr_codes` | |
| 11 | `SanQRTokenHistory` | `court_qr_token_history` | |
| 12 | `LichDatSan` | `bookings` | |
| 13 | `LichDatSan_DichVu` | `booking_services` | **KHÔI PHỤC** |
| 14 | `BookingExtension` | `booking_extensions` | |
| 15 | `SoftHold` | `soft_holds` | |
| 16 | `CourtChargeSegment` | `court_charge_segments` | |
| 17 | `CustomerReputationHistory` | `customer_reputation_history` | |
| 18 | `HoaDon` | `invoices` | |
| 19 | `ChiTietHoaDon` | `invoice_items` | |
| 20 | `HoanTien` | `refunds` | |
| 21 | `PayOSPaymentAttempt` | `payos_payment_attempts` | |
| 22 | `NhomChiaTien` | `bill_split_groups` | **KHÔI PHỤC** |
| 23 | `NhomChiaTienChiTiet` | `bill_split_shares` | **KHÔI PHỤC** |
| 24 | `SanPham_DichVu` | `products_services` | giữ nghĩa "sản phẩm & dịch vụ" |
| 25 | `KhuyenMai` | `promotions` | |
| 26 | `KhuyenMaiHinhAnh` | `promotion_images` | |
| 27 | `LichSuKhuyenMai` | `promotion_usages` | |
| 28 | `GhepKeo` | `matches` | |
| 29 | `ChiTietGhepKeo` | `match_participants` | |
| 30 | `MonTheThaoYeuThich` | `favorite_sports` | |
| 31 | `DanhGia` | `reviews` | **KHÔI PHỤC** |
| 32 | `Teams` | `teams` | **KHÔI PHỤC** |
| 33 | `TeamMembers` | `team_members` | **KHÔI PHỤC** |
| 34 | `TeamInvitations` | `team_invitations` | **KHÔI PHỤC** |
| 35 | `TeamJoinRequests` | `team_join_requests` | **KHÔI PHỤC** |
| 36 | `CaLamViec` | `work_shifts` | |
| 37 | `CaLamViec_Audit` | `work_shift_audits` | |
| 38 | `CaLamViec_SwapRequest` | `work_shift_swap_requests` | |
| 39 | `QRRequest` | `qr_requests` | **KHÔI PHỤC** |
| 40 | `ThongBao` | `notifications` | |
| 41 | `AuditLog` | `audit_logs` | |
| 42 | `AdminTrash` | `admin_trash` | |

### Bảng đã XOÁ khỏi V2

| Bảng | Lý do |
|---|---|
| `LichSuELO` | Hệ thống ELO — chỉ có model, 0 DAO/service/UI |
| `CaLamViec_Availability` | Đăng ký giờ rảnh — bỏ theo yêu cầu |

---

## 2. `Accounts` → `accounts`

| V1 | V2 |
|---|---|
| `AccountID` | `account_id` |
| `Username` | `username` |
| `Password` | `password_hash` |
| `FailedLoginCount` | `failed_login_count` |
| `IsLocked` | `is_locked` |
| `LastLogin` | `last_login_at` |
| `GoogleID` / `FacebookID` | `google_id` / `facebook_id` |
| `ZaloID` / `MessengerID` | `zalo_id` / `messenger_id` |
| `FullName` | `full_name` |
| `PhoneNumber` | `phone_number` |
| `Email` | `email` |
| `RoleID` | `role_id` |
| `CoSoID` | `facility_id` |
| `DiemUyTin` | `reputation_score` |
| `CompletedBookingCount` | `completed_booking_count` |
| `LateCancelCount` | `late_cancel_count` |
| `NoShowCount` | `no_show_count` |
| `MaNganHang` | `bank_code` |
| `SoTaiKhoan` | `bank_account_number` |
| `QrImagePath` | `qr_image_path` |
| `AvatarUrl` | `avatar_url` |
| `CoverImageUrl` | `cover_image_url` |
| `NgaySinh` | `date_of_birth` |
| `GioiTinh` | `gender` |
| `ChieuCaoCm` | `height_cm` |
| `CanNangKg` | `weight_kg` |
| `GhiChuDacBiet` | `special_note` |
| `ViTriSoTruong` | `preferred_position` |
| `ViTriYeuThich` | `favorite_positions` |
| `MonTheThaoYeuThichID` | `favorite_sport_id` |
| `TrinhDoChoi` | `skill_level` |
| `MucTieuChoi` | `play_goal` |
| `TanSuatChoi` | `play_frequency` |
| `NhanThongBaoMarketing` | `receive_marketing_notification` |
| `CreatedAt` | `created_at` |
| `IsDeleted` / `DeletedAt` / `DeletedBy` | `is_deleted` / `deleted_at` / `deleted_by` |
| ~~`DiemTrinhDo`~~ | **ĐÃ XOÁ** (ELO) |
| ~~`NhanThongBaoSOS`~~ | **ĐÃ XOÁ** (SOS) |

---

## 3. `LichDatSan` → `bookings`

⚠️ **Bẫy quan trọng:** V1 có 2 cặp cột thời gian thực tế dễ nhầm. Ánh xạ SAI sẽ cho giá trị đúng kiểu nhưng sai nghĩa.

| V1 | V2 | Dùng ở đâu |
|---|---|---|
| `actual_start_time` (TIME) | `actual_start_time_of_day` | `CheckInDAO` — hiển thị giờ trong ngày |
| `actual_end_time` (TIME) | `actual_end_time_of_day` | `CheckInDAO` |
| `ActualStartAt` (DATETIME2) | `actual_started_at` | `CheckoutService`, `InvoiceViewService` |
| `ActualEndAt` (DATETIME2) | `actual_ended_at` | `BillSplitService`, `BookingExtensionService` |

| V1 | V2 |
|---|---|
| `DatSanID` | `booking_id` |
| `AccountID` | `account_id` |
| `SanID` | `court_id` |
| `NgayDat` | `booking_date` |
| `GioBatDau` / `GioKetThuc` | `start_time` / `end_time` |
| `ApDungGiaCoDen` | `apply_light_price` |
| `TongTienDuKien` | `estimated_total` |
| `TrangThai` | `status` |
| `NguonDatSan` | `booking_source` |
| `TimeMode` | `time_mode` |
| `ReservedDurationMinutes` | `reserved_duration_minutes` |
| `HoldExpiresAt` | `hold_expires_at` |
| `DepositAmount` | `deposit_amount` |
| `PaymentMethodConfirmed` | `payment_method_confirmed` |
| `TransactionCode` | `transaction_code` |
| `ConfirmedAt` / `ConfirmedBy` / `ConfirmSource` | `confirmed_at` / `confirmed_by` / `confirm_source` |
| `PricingFinalizedAt` | `pricing_finalized_at` |
| `EarlyCheckoutReason` / `EarlyCheckoutDiscount` | `early_checkout_reason` / `early_checkout_discount` |
| `NoShowAt` | `no_show_at` |
| `CancelType` / `CancelReason` / `CancelledAt` / `CancelledBy` | `cancel_type` / `cancel_reason` / `cancelled_at` / `cancelled_by` |
| `RequiresRefundReview` | `requires_refund_review` |
| `Payos*` (10 cột) | `payos_*` (snake_case tương ứng) |
| `CreatedTime` | `created_at` |

---

## 4. `HoaDon` → `invoices`

| V1 | V2 |
|---|---|
| `HoaDonID` | `invoice_id` |
| `DatSanID` | `booking_id` |
| `AccountID_KhachHang` | `customer_account_id` |
| `AccountID_NhanVien` | `staff_account_id` |
| `NgayLap` | `issued_at` |
| `TongTienSan` | `court_total` |
| `TongTienDichVu` | `service_total` |
| `PhiGuiXe` | `parking_fee` |
| `KhuyenMaiID` | `promotion_id` |
| `GiamGia` | `discount_amount` |
| `TongThanhToan` | `grand_total` |
| `PhuongThucThanhToan` | `payment_method` |
| `TrangThaiThanhToan` | `payment_status` |
| `LoaiHoaDon` | `invoice_type` |
| `ParentHoaDonID` | `parent_invoice_id` |
| `PaymentReference` | `payment_reference` |

`ChiTietHoaDon` → `invoice_items`: `ChiTietID`→`invoice_item_id`, `SoLuong`→`quantity`, `DonGiaTaiThoiDiemBan`→`unit_price_at_sale`, `ThanhTien`→`line_total`.

---

## 5. `CoSo` → `facilities`, `San` → `courts`, `LoaiSan` → `court_types`

| V1 | V2 |
|---|---|
| `CoSoID` / `TenCoSo` / `DiaChi` | `facility_id` / `facility_name` / `address` |
| `SoDienThoai` | `phone_number` |
| `GioMoCua` / `GioDongCua` | `opening_time` / `closing_time` |
| `LoaiHinhKinhDoanh` | `business_type` |
| `SoLuongSanDuKien` | `planned_court_count` |
| `AccountID_QuanLy` | `manager_account_id` |
| `PayOS_ClientID` / `PayOS_ApiKey` / `PayOS_ChecksumKey` | `payos_client_id` / `payos_api_key` / `payos_checksum_key` |
| `ViDo` / `KinhDo` | `latitude` / `longitude` |
| `SanID` / `TenSan` / `LoaiSanID` | `court_id` / `court_name` / `court_type_id` |
| `LoaiSanID` / `TenLoai` | `court_type_id` / `type_name` |
| `GiaKhongDen` / `GiaCoDen` | `price_without_light` / `price_with_light` |
| `GioBatDauLenDen` / `GioKetThucLenDen` | `light_start_time` / `light_end_time` |

---

## 6. ⚠️ GIÁ TRỊ TIẾNG VIỆT — TUYỆT ĐỐI KHÔNG DỊCH

Đây là **dữ liệu**, không phải tên cột. Chúng được so sánh trực tiếp với hằng số trong
`src/main/java/org/example/util/Constants.java`. Dịch sang tiếng Anh = hỏng toàn bộ nghiệp vụ.

**Trạng thái đặt sân** (`bookings.status`):
`Chờ xác nhận`, `Đã xác nhận`, `Đã hủy`, `Đang chơi`, `Đang sử dụng`, `Đã hoàn thành`, `Chờ thanh toán`, `Quá hạn`, `Không đến`

**Trình độ chơi** (`accounts.skill_level`): `Mới chơi`, `Cơ bản`, `Trung bình`, `Khá`, `Nâng cao`

**Tần suất chơi** (`accounts.play_frequency`): `1 lần/tuần`, `2-3 lần/tuần`, `4+ lần/tuần`, `Không cố định`

**Trạng thái dịch vụ** (`booking_services.status`): `Chờ chuẩn bị`, `Đã giao`, `Đã hủy`

**Trạng thái tham gia kèo** (`match_participants.participation_status`): `Chờ duyệt`, `Đã tham gia`

**Khác**: `facilities.status` = `Hoạt động`; `courts.status` = `Sẵn sàng`;
`products_services.status` = `Đang kinh doanh`; `refunds.status` = `Chờ xử lý`;
`matches.status` = `Đang tìm`; `invoices.invoice_type` = `MAIN` / `SERVICE`

---

## 7. Sửa lỗi mang sang V2

| Vấn đề ở V1 | Cách xử lý ở V2 |
|---|---|
| `UX_HoaDon_OneMainPerBooking` mất mệnh đề `WHERE` → một lượt đặt sân không thể vừa có hoá đơn MAIN vừa có SERVICE | `uq_invoices_one_main_per_booking` khôi phục `WHERE booking_id IS NOT NULL AND invoice_type = N'MAIN'` (nguồn: `sql/migration_court_checkout.sql`) |
| `Roles` chỉ seed 1 dòng `Admin` → FK gãy với role 2/3/4 | Seed đủ 4 vai trò bằng `SET IDENTITY_INSERT` để ID khớp `Constants.java` |
| 9 bảng bị cắt nhầm dù code còn dùng | Khôi phục đầy đủ |

---

## 8. Lưu ý khi migrate code

1. **JPA**: mọi `@Column` trong `src/main/java/org/example/model/` đều đã có `name = "..."` tường minh → chỉ cần đổi **giá trị chuỗi**, giữ nguyên tên field Java. Không đụng `@Transient`, giữ `insertable=false, updatable=false`.
2. **JPQL** (`createQuery`, 27 file): tham chiếu *tên field Java*, **không cần sửa**. Nhưng `createNativeQuery` thì phải sửa.
3. **SQL thô** (92 file): phải sửa **đồng thời** câu SQL *và* nhãn `rs.getX("...")` tương ứng. Lệch nhau → `SQLServerException: invalid column name` lúc chạy, không phải lúc biên dịch.
4. **JSP EL** (94 file): không đổi vì tên field Java giữ nguyên.
5. **`persistence.xml`**: kiểm tra danh sách `<class>` sau khi xoá entity chết, tránh `ClassNotFoundException` lúc khởi động.
