# Full JSP → Next.js Migration Master Plan

> **For agentic workers:** Use superpowers:executing-plans to implement each phase task-by-task.
> Each phase is a self-contained sub-project with its own implementation plan.

**Goal:** Migrate toàn bộ ~58 trang JSP của V-Sport sang Next.js 14 App Router + Tailwind CSS,
giữ nguyên Java backend (chỉ bổ sung REST API endpoint dần dần).

**Architecture:**
- Frontend: Next.js 14 App Router tại `vsport_frontend/`
- Backend: Java Servlet giữ nguyên, thêm JSON endpoint song song với JSP
- Auth: Java session-based (`credentials: 'include'` trên mọi fetch call)
- Design tokens: `vs-navy` `vs-blue` `vs-cyan` `vs-slate` (Tailwind custom colors đã có)

**Tech Stack:** TypeScript · Next.js 14 · Tailwind CSS · Lucide React · Java Servlet · JPA

---

## Global Constraints

- Mọi fetch đến backend đều dùng `credentials: 'include'`
- Backend URL từ `process.env.NEXT_PUBLIC_BACKEND_URL` (default `http://localhost:8080/Backend_java`)
- Không dùng JWT — giữ session cookie Java
- Route group dùng Next.js App Router: `(public)`, `(customer)`, `(manager)`, `(staff)`, `(admin)`
- Tất cả component có `'use client'` khi cần state/effect, ngược lại dùng Server Component
- Test với Jest + React Testing Library (đã setup)

---

## Tổng quan Route Structure

```
vsport_frontend/app/
├── (public)/
│   ├── dang-nhap/page.tsx          # Login
│   ├── dang-ky/page.tsx            # Customer register
│   ├── quen-mat-khau/page.tsx      # Forgot password
│   ├── xac-thuc-otp/page.tsx       # OTP verification
│   ├── tim-kiem/page.tsx           # Search (public)
│   └── co-so/[id]/page.tsx         # Facility detail (public)
├── (customer)/
│   ├── layout.tsx                  # Customer layout + sidebar
│   ├── dat-san/[id]/page.tsx       # Book a court
│   ├── gio-hang/page.tsx           # Cart & checkout
│   ├── xac-nhan/page.tsx           # Booking confirmation
│   ├── thanh-toan/page.tsx         # PayOS QR payment
│   ├── account/
│   │   ├── tai-khoan/page.tsx      # Account overview
│   │   ├── ho-so/page.tsx          # Profile edit
│   │   ├── doi-mat-khau/page.tsx   # Change password
│   │   ├── lich-su/page.tsx        # Booking history
│   │   ├── thong-bao/page.tsx      # Notifications
│   │   ├── cai-dat/page.tsx        # Notification settings
│   │   ├── uu-dai/page.tsx         # My promotions
│   │   └── diem-uy-tin/page.tsx    # Reputation history
│   ├── doi-nhom/
│   │   ├── page.tsx                # Teams list
│   │   ├── tao/page.tsx            # Create team
│   │   └── [id]/page.tsx           # Team detail
│   ├── ghep-keo/page.tsx           # Matchmaking
│   ├── ban-do/page.tsx             # Map view
│   ├── quet-qr/page.tsx            # QR scanner
│   └── hoan-tien/[id]/page.tsx     # Refund detail
├── (manager)/
│   ├── layout.tsx                  # Manager sidebar layout
│   └── manager/
│       ├── dashboard/page.tsx
│       ├── quan-ly-san/page.tsx
│       ├── dat-san/page.tsx
│       ├── hoa-don/page.tsx
│       ├── khach-hang/page.tsx
│       ├── kho-dich-vu/page.tsx
│       ├── khuyen-mai/page.tsx
│       ├── nhan-su/page.tsx
│       ├── ca-lam-viec/page.tsx
│       ├── ma-qr-san/page.tsx
│       ├── hoan-tien/page.tsx
│       ├── thung-rac/page.tsx
│       └── audit-log/page.tsx
├── (staff)/
│   ├── layout.tsx                  # Staff sidebar layout
│   └── staff/
│       ├── dashboard/page.tsx
│       ├── check-in/page.tsx
│       ├── dat-san/page.tsx
│       ├── hoa-don/page.tsx
│       ├── hoan-tien/page.tsx
│       ├── ca-lam-viec/page.tsx
│       └── yeu-cau-qr/page.tsx
├── (admin)/
│   ├── layout.tsx                  # Admin sidebar layout
│   └── admin/
│       ├── dashboard/page.tsx
│       ├── quan-ly-owner/page.tsx
│       ├── nhan-su/page.tsx
│       ├── hoa-don/page.tsx
│       ├── lich-dat-san/page.tsx
│       ├── khuyen-mai/page.tsx
│       ├── kho-dich-vu/page.tsx
│       ├── ho-tro/page.tsx
│       ├── audit-log/page.tsx
│       ├── chi-nhanh/page.tsx
│       └── thung-rac/page.tsx
├── owner/page.tsx                  # (đã có) Owner landing
└── owner-register/                 # (đã có) Owner registration
```

---

## Phase 0 — Shared Infrastructure *(bắt buộc làm trước)*

**Mọi phase đều phụ thuộc Phase 0. Implement trước khi bắt đầu Phase 1.**

### Backend cần thêm (1 endpoint):

```java
// GET /api/v1/auth/me
// Trả JSON user từ session, hoặc 401 nếu chưa đăng nhập
// Thêm vào AuthApiServlet hoặc tạo WebSessionApiServlet mới
{
  "id": 1,
  "email": "user@example.com",
  "phone": "0901234567",
  "fullName": "Nguyễn Văn A",
  "role": "CUSTOMER",          // CUSTOMER | MANAGER | STAFF | ADMIN
  "avatarUrl": "..."
}
```

### Frontend cần tạo:

**`middleware.ts`** (root của vsport_frontend):
```ts
// Intercept tất cả route có tiền tố (customer)/(manager)/(staff)/(admin)
// Gọi GET /api/v1/auth/me với cookie
// → 401: redirect /dang-nhap?redirect=<current-url>
// → role không khớp: redirect về trang phù hợp với role
```

**`lib/api/auth.ts`**:
```ts
export async function getCurrentUser(): Promise<User | null>
export async function login(identifier: string, password: string, method: 'account'|'phone'): Promise<{success, user?, loi?}>
export async function logout(): Promise<void>
```

**`hooks/useCurrentUser.ts`** (Client Component hook):
```ts
// Gọi /api/v1/auth/me, cache trong SWR hoặc React state
export function useCurrentUser(): { user: User | null, loading: boolean }
```

**Shared layout components** (dùng lại cho tất cả portal):
- `components/shared/CustomerSidebar.tsx` — sidebar customer
- `components/shared/ManagerSidebar.tsx` — sidebar manager
- `components/shared/StaffSidebar.tsx` — sidebar staff
- `components/shared/AdminSidebar.tsx` — sidebar admin
- `components/shared/TopBar.tsx` — header với avatar + logout

---

## Phase 1 — Auth (4 trang)

**Nguồn JSP:** `auth/NhapMa.jsp` + auth dropdown
**Nguồn Servlet:** `DangNhapServlet`, `DangKyServlet`, `XacThucOTPServlet`, `QuenMatKhauServlet`

### Lợi thế: DangNhapServlet đã hỗ trợ AJAX!
Gửi `X-Requested-With: XMLHttpRequest` → servlet trả JSON `{success, loi}` + set session cookie.
**Không cần sửa backend cho login.**

### Routes & Components:

| Route Next.js | JSP nguồn | Servlet | Backend call |
|---------------|-----------|---------|--------------|
| `/dang-nhap` | `auth/AuthDropdown.jsp` | `POST /dangnhap` | POST + `X-Requested-With: XMLHttpRequest` |
| `/dang-ky` | — | `POST /dangky` | POST form data |
| `/quen-mat-khau` | — | `POST /quenmatkhau` | POST email |
| `/xac-thuc-otp` | `auth/NhapMa.jsp` | `POST /nhapma` | POST + code |

### UI spec:
- Nền gradient dark navy (giống landing page owner)
- Card trắng giữa màn hình, rounded-2xl, shadow-lg
- Logo V-SPORT trên đầu card
- Form fields có icon lucide-react
- Error hiển thị inline (không toast)
- Login hỗ trợ cả email/username và số điện thoại (tab switch)

### Sau login: redirect theo role
```
CUSTOMER  → /tim-kiem
MANAGER   → /manager/dashboard
STAFF     → /staff/dashboard
ADMIN     → /admin/dashboard
```

### Files cần tạo:
```
components/auth/LoginCard.tsx
components/auth/RegisterCard.tsx
components/auth/OtpCard.tsx
components/auth/ForgotPasswordCard.tsx
app/(public)/dang-nhap/page.tsx
app/(public)/dang-ky/page.tsx
app/(public)/xac-thuc-otp/page.tsx
app/(public)/quen-mat-khau/page.tsx
lib/api/auth.ts
```

---

## Phase 2 — Customer Portal (21 trang)

### Backend cần thêm (JSON endpoints song song với JSP):

```
GET  /api/v1/customer/tim-kiem?q=&sportId=&openNow=   → list CoSo
GET  /api/v1/customer/co-so/:id                        → chi tiết CoSo + sân
GET  /api/v1/customer/dat-san/:facilityId/lich         → lịch đặt sân (slots)
POST /api/v1/customer/dat-san                          → tạo booking
GET  /api/v1/customer/gio-hang                         → danh sách giỏ hàng
POST /api/v1/customer/gio-hang/xoa/:id                 → xóa item
POST /api/v1/customer/gio-hang/thanh-toan              → checkout → tạo đơn
GET  /api/v1/customer/lich-su-dat-san                  → danh sách lịch sử
GET  /api/v1/customer/lich-su-dat-san/:id              → chi tiết booking
POST /api/v1/customer/huy-dat-san/:id                  → hủy booking
GET  /api/v1/customer/ho-so                            → profile data
PUT  /api/v1/customer/ho-so                            → cập nhật profile
PUT  /api/v1/customer/doi-mat-khau                     → đổi mật khẩu
GET  /api/v1/customer/thong-bao                        → danh sách thông báo
PUT  /api/v1/customer/thong-bao/:id/doc                → đánh dấu đã đọc
GET  /api/v1/customer/cai-dat-thong-bao                → settings thông báo
PUT  /api/v1/customer/cai-dat-thong-bao                → cập nhật settings
GET  /api/v1/customer/uu-dai                           → khuyến mãi của tôi
GET  /api/v1/customer/diem-uy-tin                      → lịch sử điểm uy tín
GET  /api/v1/customer/doi-nhom                         → danh sách đội nhóm
POST /api/v1/customer/doi-nhom                         → tạo đội
GET  /api/v1/customer/doi-nhom/:id                     → chi tiết đội
GET  /api/v1/customer/ghep-keo                         → danh sách kèo
GET  /api/v1/customer/ban-do                           → tọa độ cơ sở
POST /api/v1/customer/quet-qr                          → resolve QR code
GET  /api/v1/customer/hoan-tien/:id                    → chi tiết hoàn tiền
GET  /api/v1/customer/tai-khoan                        → overview tài khoản
```

### Trang theo nhóm:

**Nhóm tìm kiếm (Public):**
- `/tim-kiem` — search box, filter môn thể thao, list card CoSo
- `/co-so/[id]` — gallery, info, danh sách sân, đánh giá, CTA đặt sân

**Nhóm đặt sân (Auth):**
- `/dat-san/[id]` — calendar chọn ngày, grid chọn giờ, thêm dịch vụ
- `/gio-hang` — danh sách booking + tổng tiền + chọn khuyến mãi
- `/xac-nhan` — confirm thông tin trước thanh toán
- `/thanh-toan` — QR PayOS với countdown, auto-check status

**Nhóm tài khoản (Auth):**
- `/account/tai-khoan` — overview: thông tin cơ bản + quick stats
- `/account/ho-so` — form edit avatar, tên, ngày sinh, giới tính, môn ưa thích
- `/account/doi-mat-khau` — form đổi mật khẩu (đã có JSP riêng)
- `/account/lich-su` — table lịch sử với filter + pagination
- `/account/thong-bao` — list thông báo + mark read
- `/account/cai-dat` — toggles thông báo email/push
- `/account/uu-dai` — list voucher của tôi
- `/account/diem-uy-tin` — timeline lịch sử điểm

**Nhóm xã hội (Auth):**
- `/doi-nhom` — list đội của tôi
- `/doi-nhom/tao` — form tạo đội mới
- `/doi-nhom/[id]` — chi tiết đội + thành viên + lịch thi đấu
- `/ghep-keo` — list kèo đang mở + filter môn
- `/ban-do` — Google Maps + pins cơ sở

**Nhóm tiện ích (Auth):**
- `/quet-qr` — camera QR scan (dùng html5-qrcode hoặc @zxing/browser)
- `/hoan-tien/[id]` — chi tiết yêu cầu hoàn tiền + trạng thái

### Shared Customer Components:
```
components/customer/layout/CustomerNavbar.tsx    — top nav mobile + desktop
components/customer/layout/CustomerSidebar.tsx   — sidebar desktop
components/customer/layout/BottomNav.tsx         — mobile bottom tab bar
components/customer/CoSoCard.tsx                 — card cơ sở trong search
components/customer/BookingCalendar.tsx          — calendar chọn ngày
components/customer/TimeSlotGrid.tsx             — grid giờ đặt sân
components/customer/PaymentQR.tsx                — QR payment + countdown
components/customer/AccountSidebar.tsx           — sidebar tài khoản
```

---

## Phase 3 — Manager/Owner Dashboard (15 trang)

### Backend cần thêm (JSON endpoints):

```
GET  /api/v1/manager/dashboard                     → stats: doanh thu, đặt sân, sân hoạt động
GET  /api/v1/manager/quan-ly-san                   → danh sách sân + filter
POST /api/v1/manager/quan-ly-san                   → thêm sân mới
PUT  /api/v1/manager/quan-ly-san/:id               → sửa sân
DELETE /api/v1/manager/quan-ly-san/:id             → xóa sân
GET  /api/v1/manager/dat-san?date=&status=         → danh sách đặt sân
PUT  /api/v1/manager/dat-san/:id/trang-thai        → đổi trạng thái
GET  /api/v1/manager/hoa-don?page=&status=         → danh sách hóa đơn
GET  /api/v1/manager/khach-hang?page=&q=           → danh sách khách
GET  /api/v1/manager/kho-dich-vu                   → dịch vụ bán thêm
POST /api/v1/manager/kho-dich-vu                   → thêm dịch vụ
PUT  /api/v1/manager/kho-dich-vu/:id               → sửa dịch vụ
GET  /api/v1/manager/khuyen-mai                    → danh sách khuyến mãi
POST /api/v1/manager/khuyen-mai                    → tạo khuyến mãi
GET  /api/v1/manager/nhan-su                       → danh sách nhân sự
POST /api/v1/manager/nhan-su                       → thêm nhân viên
GET  /api/v1/manager/ca-lam-viec                   → danh sách ca làm
GET  /api/v1/manager/ma-qr-san                     → QR sân
GET  /api/v1/manager/hoan-tien                     → yêu cầu hoàn tiền
PUT  /api/v1/manager/hoan-tien/:id                 → duyệt/từ chối hoàn tiền
GET  /api/v1/manager/thung-rac                     → mục bị xóa
POST /api/v1/manager/thung-rac/:id/khoi-phuc       → khôi phục
GET  /api/v1/manager/audit-log?page=               → audit log
```

### Trang:
| Route | JSP nguồn | Mô tả |
|-------|-----------|-------|
| `/manager/dashboard` | `manager/Dashboard.jsp` | Stats cards + biểu đồ doanh thu |
| `/manager/quan-ly-san` | `manager/QuanLySan.jsp` | CRUD sân + upload ảnh |
| `/manager/dat-san` | `manager/QuanLyDatSan.jsp` | Calendar view + list |
| `/manager/hoa-don` | `manager/QuanLyHoaDon.jsp` | Table hóa đơn + export |
| `/manager/khach-hang` | `manager/KhachHang.jsp` | Table khách + lịch sử |
| `/manager/kho-dich-vu` | `manager/KhoDichVu.jsp` | CRUD dịch vụ bán thêm |
| `/manager/khuyen-mai` | `manager/KhuyenMai.jsp` | CRUD khuyến mãi + upload ảnh |
| `/manager/nhan-su` | `manager/NhanSu.jsp` | CRUD nhân sự |
| `/manager/ca-lam-viec` | `manager/CaLamViec.jsp` | Lịch ca làm việc |
| `/manager/ma-qr-san` | `manager/MaQrSan.jsp` | QR code sân + in hàng loạt |
| `/manager/hoan-tien` | `manager/HoanTien.jsp` | Duyệt hoàn tiền |
| `/manager/thung-rac` | `manager/ThungRac.jsp` | Thùng rác + khôi phục |
| `/manager/audit-log` | `manager/AuditLog.jsp` | Lịch sử thao tác |

### Shared Manager Components:
```
components/manager/layout/ManagerSidebar.tsx
components/manager/layout/ManagerTopBar.tsx
components/manager/DashboardStatCard.tsx        — stat card với trend arrow
components/manager/RevenueChart.tsx             — biểu đồ doanh thu (Recharts)
components/manager/DataTable.tsx                — generic sortable/filterable table
components/manager/BookingCalendarView.tsx      — calendar view đặt sân
components/manager/CourtCard.tsx                — card sân trong quản lý
```

---

## Phase 4 — Staff Portal (7 trang)

### Backend cần thêm:

```
GET  /api/v1/staff/dashboard                       → stats ca hôm nay
GET  /api/v1/staff/check-in?date=                  → danh sách booking cần check-in
POST /api/v1/staff/check-in/:id                    → xác nhận check-in
GET  /api/v1/staff/dat-san                         → quản lý đặt sân của ca hôm nay
GET  /api/v1/staff/hoa-don/:id                     → chi tiết hóa đơn
GET  /api/v1/staff/hoan-tien                       → yêu cầu hoàn tiền
POST /api/v1/staff/hoan-tien/:id/xu-ly             → xử lý hoàn tiền
GET  /api/v1/staff/ca-lam-viec                     → lịch ca của tôi
GET  /api/v1/staff/yeu-cau-qr                      → danh sách yêu cầu QR dịch vụ
POST /api/v1/staff/yeu-cau-qr/:id/xu-ly            → duyệt/từ chối yêu cầu
```

### Trang:
| Route | JSP nguồn |
|-------|-----------|
| `/staff/dashboard` | `staff/Dashboard.jsp` |
| `/staff/check-in` | `staff/CheckIn.jsp` |
| `/staff/dat-san` | `staff/QuanLyDatSan.jsp` |
| `/staff/hoa-don` | `staff/HoaDonPrint.jsp` |
| `/staff/hoan-tien` | `staff/HoanTien.jsp` |
| `/staff/ca-lam-viec` | `staff/CaLamViec.jsp` |
| `/staff/yeu-cau-qr` | `staff/YeuCauQR.jsp` |

### Shared Staff Components:
```
components/staff/layout/StaffSidebar.tsx
components/staff/CheckInCard.tsx
components/staff/QrRequestCard.tsx
```

---

## Phase 5 — Admin Panel (12 trang)

### Backend cần thêm:

```
GET  /api/v1/admin/dashboard                      → system-wide stats
GET  /api/v1/admin/quan-ly-owner?status=          → danh sách owner đăng ký
PUT  /api/v1/admin/quan-ly-owner/:id/duyet        → duyệt owner
PUT  /api/v1/admin/quan-ly-owner/:id/tu-choi      → từ chối owner
GET  /api/v1/admin/nhan-su?role=                  → danh sách tất cả user
POST /api/v1/admin/nhan-su                        → tạo tài khoản
PUT  /api/v1/admin/nhan-su/:id                    → sửa tài khoản
GET  /api/v1/admin/hoa-don                        → tất cả hóa đơn hệ thống
GET  /api/v1/admin/lich-dat-san                   → tất cả đặt sân
GET  /api/v1/admin/khuyen-mai                     → khuyến mãi toàn hệ thống
GET  /api/v1/admin/kho-dich-vu                    → dịch vụ toàn hệ thống
GET  /api/v1/admin/ho-tro                         → ticket hỗ trợ
GET  /api/v1/admin/audit-log                      → toàn bộ audit log
GET  /api/v1/admin/chi-nhanh                      → cơ sở/chi nhánh
POST /api/v1/admin/chi-nhanh                      → thêm chi nhánh
GET  /api/v1/admin/thung-rac                      → thùng rác system
```

### Trang:
| Route | JSP nguồn |
|-------|-----------|
| `/admin/dashboard` | `admin/Dashboard.jsp` + `admin/TongQuan.jsp` |
| `/admin/quan-ly-owner` | `admin/QuanLyOwner.jsp` |
| `/admin/nhan-su` | `admin/NhanSu.jsp` |
| `/admin/hoa-don` | `admin/HoaDon.jsp` |
| `/admin/lich-dat-san` | `admin/LichDatSan.jsp` |
| `/admin/khuyen-mai` | `admin/KhuyenMai.jsp` |
| `/admin/kho-dich-vu` | `admin/KhoDichVu.jsp` |
| `/admin/ho-tro` | `admin/HoTro.jsp` |
| `/admin/audit-log` | `admin/AuditLog.jsp` |
| `/admin/chi-nhanh` | `admin/QuanLyChiNhanh.jsp` |
| `/admin/thung-rac` | `admin/ThungRacAdmin.jsp` |

### Shared Admin Components:
```
components/admin/layout/AdminSidebar.tsx
components/admin/layout/AdminTopBar.tsx
components/admin/OwnerApprovalCard.tsx          — card duyệt owner
components/admin/UserTable.tsx                  — bảng quản lý người dùng
components/admin/SystemStatsPanel.tsx           — panel stats toàn hệ thống
```

---

## Thứ tự thực hiện đề xuất

```
Tuần 1:   Phase 0 — Shared Infrastructure (middleware, auth hook, layouts)
Tuần 1-2: Phase 1 — Auth (Login, Register, OTP, Forgot Password)
Tuần 2-4: Phase 2 — Customer Portal (21 trang — chia nhỏ 3 sprint)
  Sprint 1: Public (TimKiem, ChiTietSan) + booking flow (DatSan, GioHang, XacNhan, ThanhToan)
  Sprint 2: Account (TaiKhoan, HoSo, DoiMatKhau, LichSu, ThongBao, CaiDat, UuDai, DiemUyTin)
  Sprint 3: Social (DoiNhom, GhepKeo, BanDo, QuetQR, HoanTien)
Tuần 4-5: Phase 3 — Manager Dashboard (15 trang — 2 sprint)
Tuần 5-6: Phase 4 — Staff Portal (7 trang — 1 sprint)
Tuần 6-7: Phase 5 — Admin Panel (12 trang — 2 sprint)
```

## Mỗi phase cần plan riêng

Trước khi implement từng phase, tạo file plan chi tiết:
- `docs/superpowers/plans/2026-08-12-phase0-shared-infra.md`
- `docs/superpowers/plans/2026-08-12-phase1-auth.md`
- `docs/superpowers/plans/2026-08-12-phase2-customer.md`
- `docs/superpowers/plans/2026-08-12-phase3-manager.md`
- `docs/superpowers/plans/2026-08-12-phase4-staff.md`
- `docs/superpowers/plans/2026-08-12-phase5-admin.md`
