# V-SPORT — Tổng quan hệ thống

> Cập nhật: 2026-08-10 | Nhánh: `main`

---

## 1. Giới thiệu

**V-SPORT** là hệ thống quản lý và đặt sân thể thao trực tuyến, hỗ trợ nhiều vai trò người dùng, tích hợp thanh toán QR (PayOS/VietQR), ghép đội.

---

## 2. Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Backend | Java Servlet (Jakarta EE), Hibernate ORM 6.4, JPA 3.1 |
| View | JSP + JSTL 3.0 (server-side rendering) |
| Database | MySQL 8.x (primary) / MSSQL (legacy support) |
| Connection Pool | HikariCP 5.1 |
| Security | BCrypt (mật khẩu), Session-based (web) |
| Email | Jakarta Mail (OTP, thông báo) |
| Thanh toán | PayOS (QR động), VietQR (tĩnh) |
| Ảnh | Cloudinary |
| Build | Maven, deploy trên Tomcat (context `/Backend_java`) |
| Design | Be Vietnam Pro font, CSS custom tokens `--vs-*` |

---

## 3. Vai trò người dùng (Roles)

| Vai trò | Mô tả | Khu vực URL |
|---|---|---|
| **Admin** | Quản trị toàn hệ thống | `/admin/*` |
| **Owner** | Chủ cơ sở, đăng ký chi nhánh | `/ownerLanding`, `/owner-register` |
| **Manager** | Quản lý chi nhánh cụ thể | `/manager/*` |
| **Staff** | Nhân viên chi nhánh | `/staff/*` |
| **Customer** | Khách hàng đặt sân | `/customer/*` |

---

## 4. Chức năng theo vai trò

### 4.1 Admin (`/admin/*`)

| Trang | Servlet | Chức năng |
|---|---|---|
| `Dashboard.jsp` | `AdminDashboardServlet` | Tổng quan hệ thống |
| `TongQuan.jsp` | — | Thống kê tổng hợp |
| `QuanLyOwner.jsp` | `AdminOwnerServlet` | Duyệt / quản lý Owner |
| `QuanLyChiNhanh.jsp` | `QuanLyChiNhanhServlet` | Quản lý chi nhánh |
| `NhanSu.jsp` | `QuanLyNguoiDungServlet` | Quản lý người dùng |
| `HoaDon.jsp` | — | Lịch sử hóa đơn toàn hệ thống |
| `LichDatSan.jsp` | — | Lịch đặt sân toàn hệ thống |
| `KhuyenMai.jsp` | — | Khuyến mãi hệ thống |
| `KhoDichVu.jsp` | — | Kho dịch vụ |
| `AuditLog.jsp` | `AuditLogAdminServlet` | Nhật ký thao tác |
| `ThungRacAdmin.jsp` | `AdminTrashServlet` | Thùng rác (xóa mềm) |
| `HoTro.jsp` | — | Hỗ trợ khách hàng |
| PayOS Config | `PayOSConfigAdminServlet` | Cấu hình cổng thanh toán PayOS |

---

### 4.2 Manager (`/manager/*`)

| Trang | Servlet | Chức năng |
|---|---|---|
| `Dashboard.jsp` | `DashboardServlet` | Dashboard chi nhánh |
| `QuanLySan.jsp` | `QuanLySanManagerServlet` | Quản lý sân (CRUD) |
| `QuanLyDatSan.jsp` | `QuanLyDatSanServlet` | Quản lý lịch đặt sân |
| `QuanLyHoaDon.jsp` | `HoaDonManagerServlet` | Hóa đơn chi nhánh |
| `NhanSu.jsp` | `NhanSuManagerServlet` | Quản lý nhân viên |
| `CaLamViec.jsp` | `QuanLyCaLamManagerServlet` | Ca làm việc nhân viên |
| `KhuyenMai.jsp` | `KhuyenMaiManagerServlet` | Khuyến mãi chi nhánh |
| `KhoDichVu.jsp` | `KhoDichVuManagerServlet` | Kho sản phẩm/dịch vụ |
| `KhachHang.jsp` | `CustomerManagerServlet` | Danh sách khách hàng |
| `HoanTien.jsp` | `HoanTienManagerServlet` | Quản lý hoàn tiền |
| `MaQrSan.jsp` | `SanQRManagerServlet` | QR code sân |
| `MaQrSanIn.jsp` | `SanQRPrintServlet` | In QR code đơn lẻ |
| `MaQrSanInHangLoat.jsp` | — | In QR hàng loạt |
| `AuditLog.jsp` | `AuditLogManagerServlet` | Nhật ký chi nhánh |
| `ThungRac.jsp` | `ThungRacManagerServlet` | Thùng rác chi nhánh |
| `YeuCauDichVu.jsp` | — | Yêu cầu dịch vụ từ sân |

---

### 4.3 Staff (`/staff/*`)

| Trang | Servlet | Chức năng |
|---|---|---|
| `Dashboard.jsp` | — | Dashboard nhân viên |
| `CheckIn.jsp` | `CheckInServlet` | Check-in khách đến sân |
| `QuanLyDatSan.jsp` | — | Xem/xử lý đặt sân |
| `CaLamViec.jsp` | — | Lịch ca làm việc cá nhân |
| `YeuCauQR.jsp` | `YeuCauQRApiServlet` | Xử lý yêu cầu QR dịch vụ |
| `HoaDonPrint.jsp` | — | In hóa đơn |
| `HoanTien.jsp` | — | Yêu cầu hoàn tiền |

---

### 4.4 Customer (`/customer/*`)

#### Khám phá & Đặt sân

| Trang | URL | Chức năng |
|---|---|---|
| `index.jsp` | `/` | Trang chủ, tìm kiếm sân |
| `TimKiem.jsp` | `/customer/tim-kiem` | Tìm kiếm sân theo bộ lọc |
| `BanDo.jsp` | `/customer/ban-do` | Bản đồ cơ sở (Map) |
| `ChiTietSan.jsp` | `/customer/chi-tiet-san` | Chi tiết sân + đánh giá |
| `DatLichTrucQuan.jsp` | `/customer/dat-lich-truc-quan` | Đặt lịch trực quan (visual calendar) |
| `XacNhanDatSan.jsp` | `/customer/xac-nhan-dat-san` | Xác nhận đặt sân |
| `GioHang.jsp` | `/customer/gio-hang` | Giỏ hàng |

#### Thanh toán

| Trang | URL | Chức năng |
|---|---|---|
| `ThanhToanQR.jsp` | `/customer/thanh-toan-qr` | Thanh toán QR PayOS (embedded) |
| `QuetQR.jsp` | `/customer/quet-qr` | Quét QR sân để mua dịch vụ |

#### Quản lý tài khoản

| Trang | URL | Chức năng |
|---|---|---|
| `TaiKhoan.jsp` | `/customer/tai-khoan` | Trang tài khoản (hub) |
| `HoSo.jsp` | `/customer/ho-so` | Hồ sơ cá nhân (chỉnh sửa) |
| `DoiMatKhau.jsp` | `/customer/doi-mat-khau` | Đổi mật khẩu (trang riêng) |
| `CaiDatThongBao.jsp` | `/customer/notification-settings` | Cài đặt thông báo |
| `ThongBao.jsp` | `/customer/thong-bao` | Danh sách thông báo |
| `LichSuDatSan.jsp` | `/customer/lich-su-dat-san` | Lịch sử đặt sân |
| `HoanTienChiTiet.jsp` | `/customer/hoan-tien-chi-tiet` | Chi tiết hoàn tiền |
| `LichSuDiemUyTin.jsp` | `/customer/lich-su-diem-uy-tin` | Lịch sử điểm uy tín |
| `UuDai.jsp` | `/customer/uu-dai` | Khuyến mãi / ưu đãi |
| `DichVu.jsp` | `/customer/dich-vu` | Dịch vụ tại cơ sở |
| `DichVuCuaToi.jsp` | `/customer/dich-vu-cua-toi` | Dịch vụ đã mua |

#### Tính năng xã hội

| Trang | URL | Chức năng |
|---|---|---|
| `DoiNhom.jsp` | `/customer/doi-nhom` | Danh sách đội nhóm |
| `DoiNhomTao.jsp` | `/customer/doi-nhom-tao` | Tạo đội nhóm |
| `DoiNhomChiTiet.jsp` | `/customer/doi-nhom-chi-tiet` | Chi tiết đội + thành viên |
| `GhepKeo.jsp` | `/customer/ghep-keo` | Tìm đối / ghép kèo |

---

### 4.5 Auth

| Trang | URL | Chức năng |
|---|---|---|
| `AuthDropdown.jsp` | `/auth/auth-dropdown` | Dropdown đăng nhập/đăng ký |
| `NhapMa.jsp` | `/auth/nhap-ma` | Nhập OTP xác thực |
| Đăng nhập | `/dang-nhap` | `DangNhapServlet` |
| Đăng ký | `/dang-ky` | `DangKyServlet` |
| Quên mật khẩu | `/quen-mat-khau` | `QuenMatKhauServlet` |
| Đăng xuất | `/dang-xuat` | `DangXuatServlet` |

---

## 5. Domain Models (Entities)

| Model | Mô tả |
|---|---|
| `TaiKhoan` | Tài khoản người dùng (mọi role) |
| `VaiTro` | Vai trò / phân quyền |
| `CoSo` | Cơ sở thể thao (chi nhánh) |
| `San` | Sân (thuộc CoSo) |
| `LoaiSan` | Loại sân (bóng đá, cầu lông...) |
| `Lichdatsan` | Lịch đặt sân |
| `DatSan` | Đặt sân (booking) |
| `HoaDon` | Hóa đơn |
| `ChiTietHoaDon` | Chi tiết dòng hóa đơn |
| `SanPham_DichVu` | Sản phẩm / dịch vụ tại sân |
| `LichDatSanDichVu` | Dịch vụ đính kèm booking |
| `KhuyenMai` | Khuyến mãi |
| `KhuyenMaiHinhAnh` | Ảnh khuyến mãi (Cloudinary) |
| `CaLamViec` | Ca làm việc nhân viên |
| `CaLamViecSwapRequest` | Yêu cầu đổi ca |
| `CheckIn` | Check-in khách |
| `SoftHold` | Giữ chỗ tạm (soft hold) |
| `GhepKeo` | Ghép kèo / tìm đối |
| `Team` | Đội nhóm |
| `TeamMember` / `TeamInvitation` / `TeamJoinRequest` | Thành viên, lời mời, yêu cầu gia nhập |
| `TeamMatch` | Trận đấu giữa các đội |
| `Hoantien` | Yêu cầu hoàn tiền |
| `SanQR` / `SanQRTokenHistory` | QR code sân |
| `QRRequest` | Yêu cầu dịch vụ qua QR |
| `NhomChiaTien` / `NhomChiaTienChiTiet` | Chia hóa đơn nhóm |
| `ThongBao` | Thông báo |
| `DanhGia` | Đánh giá cơ sở |
| `AuditLog` | Nhật ký thao tác |
| `AdminTrash` | Thùng rác (soft delete) |
| `CustomerReputationHistory` | Lịch sử điểm uy tín |
| `MonTheThao` / `MonTheThaoYeuThich` | Môn thể thao yêu thích |
| `CoSoCapability` | Capability / tính năng đặc biệt của cơ sở |
| `CoSoNganHang` | Tài khoản ngân hàng cơ sở (cho PayOS) |
| `PayOSConfigDAO` / `PayOSPaymentAttempt` | Cấu hình và lượt thanh toán PayOS |

---

## 6. Các Service nghiệp vụ chính

| Service | Mô tả |
|---|---|
| `BookingCreationService` | Tạo booking mới, kiểm tra xung đột |
| `BookingCancellationService` | Hủy booking, tính hoàn tiền |
| `CourtAvailabilityService` | Kiểm tra sân trống |
| `CourtPricingService` | Tính giá sân (peak/off-peak) |
| `CheckoutService` | Thanh toán (bank transfer / PayOS) |
| `PayOSPaymentService` | Tạo link thanh toán PayOS |
| `PayOSPaymentFinalizationService` | Xác nhận webhook PayOS |
| `BookingLifecycleService` | Vòng đời booking (expire, complete) |
| `BookingExtensionService` | Gia hạn check-in |
| `RefundService` | Xử lý hoàn tiền |
| `GhepKeoService` | Ghép kèo / tìm đối |
| `TeamService` / `TeamInvitationService` | Quản lý đội nhóm |
| `TeamMatchService` | Lịch thi đấu |
| `SanQRService` | Sinh và quản lý QR sân |
| `QRRequestService` | Yêu cầu dịch vụ qua QR |
| `BillSplitService` | Chia hóa đơn nhóm |
| `CustomerReputationService` | Điểm uy tín khách hàng |
| `KhuyenMaiService` | Logic khuyến mãi |
| `NotificationService` / `NotificationPreferenceService` | Gửi & cài đặt thông báo |
| `InvoiceViewService` | Xây dựng view hóa đơn |
| `AuditLogService` | Ghi nhật ký |
| `PasswordResetChallenge` | Quên mật khẩu (OTP + rate limit) |
| `CaLamService` / `NhanSuService` | Ca làm việc, nhân sự |

---

## 7. Bảo mật & Filter

| Filter | Mục đích |
|---|---|
| `FilterBaoMat` | Auth chung, redirect login |
| `FilterCustomerArea` | Giới hạn khu vực `/customer/*` |
| `FilterQuyenAdmin` | Chỉ admin |
| `FilterQuyenManager` | Chỉ manager |
| `FilterKhach` | Chỉ khách chưa đăng nhập |
| `FilterLuong` | Phân luồng theo role |
| `CsrfFilter` | CSRF protection |
| `EncodingAndCacheControlFilter` | UTF-8 + cache headers |
| `BookingRateLimitFilter` | Rate limit đặt sân |
| `ActiveFacilityFilter` | Chặn cơ sở không hoạt động |

---

## 8. Thanh toán (PayOS)

- **Flow**: Customer chọn sân → Tạo `PayOSCheckoutSession` → Redirect `ThanhToanQR.jsp` → Hiển thị QR nhúng → Webhook `PayOSWebhookServlet` xác nhận → Finalize booking
- `orderCode` = `DatSanID` (ID đặt sân)
- Mỗi cơ sở có cấu hình PayOS riêng (`CoSoNganHang` + `PayOSConfigDAO`)
- Hỗ trợ retry, cancel, kiểm tra trạng thái

---

## 9. QR Sân

- Manager tạo QR cho từng sân (`SanQR`)
- In đơn lẻ hoặc hàng loạt (PDF)
- Khách quét QR → `QuetQR.jsp` → chọn dịch vụ → tạo `QRRequest`
- Staff xử lý `QRRequest` qua `YeuCauQR.jsp`
- Token QR có lịch sử (`SanQRTokenHistory`), security qua `SanQRSecurityUtil`

---

## 10. Scheduler

| Scheduler | Mô tả |
|---|---|
| `BookingExpiryScheduler` | Tự động hết hạn booking chưa thanh toán |
| `BookingSchedulerListener` | Khởi động scheduler khi app start |

---

## 11. Design System

- Font: **Be Vietnam Pro** (web), Barlow Condensed (legacy, đang dọn)
- CSS tokens: `--vs-*` (màu, spacing) — định nghĩa trong `vsport-theme.jsp`
- Màu brand: **navy / blue / cyan** (web), **green** (trang hồ sơ `/customer/ho-so`)
- Bottom nav mobile: `bottom-nav.jsp`
- Account sidebar: `account-sidebar.jsp`

---

## 12. Cấu trúc thư mục nguồn

```
src/main/
├── java/org/example/
│   ├── controller/   # Servlets (admin, manager, staff, customer)
│   ├── dao/          # Data Access Objects + impl/
│   ├── dto/          # Data Transfer Objects
│   ├── filter/       # Servlet Filters
│   ├── model/        # JPA Entities
│   ├── scheduler/    # Background jobs
│   ├── service/      # Business logic
│   └── util/         # Tiện ích
└── webapp/
    ├── admin/        # JSP admin
    ├── auth/         # JSP auth
    ├── common/       # Shared partials (header, footer, head)
    ├── customer/     # JSP customer
    ├── manager/      # JSP manager
    └── staff/        # JSP staff
```

---

## 13. Biến môi trường cần thiết

| Biến | Dùng cho |
|---|---|
| DB credentials | Kết nối MySQL |
| Cloudinary keys | Upload ảnh |
| PayOS API keys | Thanh toán |
| SMTP config | Gửi email OTP |
