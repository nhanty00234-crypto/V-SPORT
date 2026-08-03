# Design: Module Tính Lương Nhân Viên

**Ngày:** 2026-08-03  
**Trạng thái:** Approved  
**Phương án:** Module độc lập (Phương án 2)

---

## 1. Tổng quan

Module tính lương cho phép manager cấu hình, tính toán và phát lương nhân viên (staff + guard) theo từng kỳ. Nhân viên có thể xem bảng lương và gửi yêu cầu ứng lương. Ngày phát lương hiển thị QR bank động để manager chuyển khoản trực tiếp.

**Các tính năng chính:**
- Cấu hình lương cơ bản + phụ cấp/ca cho từng nhân viên
- Tạo kỳ lương theo tháng dương lịch hoặc kỳ tùy chỉnh
- Tính lương tự động từ `CaLamViec` (số ca hoàn thành trong kỳ)
- Ngày phát lương: danh sách nhân viên + QR bank + xác nhận đã chuyển
- Nhân viên gửi yêu cầu ứng lương → manager duyệt → trừ vào kỳ lương
- Staff/Guard upload QR bank + số tài khoản của mình

---

## 2. Database Schema

### 2.1 `CauHinhLuong`
Cấu hình lương cho từng nhân viên tại một chi nhánh.

```sql
CREATE TABLE CauHinhLuong (
  CauHinhLuongID  INT IDENTITY(1,1) PRIMARY KEY,
  AccountID       INT NOT NULL REFERENCES Accounts(AccountID),
  CoSoID          INT NOT NULL REFERENCES CoSo(CoSoID),
  LuongCoBan      DECIMAL(18,0) NOT NULL DEFAULT 0,
  PhuCapMoiCa     DECIMAL(18,0) NOT NULL DEFAULT 0,
  HanMucUng       DECIMAL(18,0) NOT NULL DEFAULT 0,
  GhiChu          NVARCHAR(500),
  CreatedAt       DATETIME DEFAULT GETDATE(),
  UpdatedAt       DATETIME DEFAULT GETDATE(),
  UNIQUE (AccountID, CoSoID)
);
```

### 2.2 `KyLuong`
Một kỳ tính lương (tháng hoặc tùy chỉnh) của một chi nhánh.

```sql
CREATE TABLE KyLuong (
  KyLuongID       INT IDENTITY(1,1) PRIMARY KEY,
  CoSoID          INT NOT NULL REFERENCES CoSo(CoSoID),
  TenKy           NVARCHAR(100) NOT NULL,
  NgayBatDau      DATE NOT NULL,
  NgayKetThuc     DATE NOT NULL,
  NgayPhatLuong   DATE NOT NULL,
  TrangThai       VARCHAR(20) NOT NULL DEFAULT 'Draft',
  -- Draft | DangTinh | DaPhat
  CreatedBy       INT NOT NULL REFERENCES Accounts(AccountID),
  CreatedAt       DATETIME DEFAULT GETDATE()
);
```

### 2.3 `BangLuong`
Bảng lương chi tiết từng nhân viên trong một kỳ.

```sql
CREATE TABLE BangLuong (
  BangLuongID     INT IDENTITY(1,1) PRIMARY KEY,
  KyLuongID       INT NOT NULL REFERENCES KyLuong(KyLuongID),
  AccountID       INT NOT NULL REFERENCES Accounts(AccountID),
  LuongCoBan      DECIMAL(18,0) NOT NULL DEFAULT 0,
  TongPhuCap      DECIMAL(18,0) NOT NULL DEFAULT 0,  -- PhuCapMoiCa × SoCaLamViec
  TongKhauTru     DECIMAL(18,0) NOT NULL DEFAULT 0,  -- tổng ứng lương đã duyệt trong kỳ
  TongLuongThuc   DECIMAL(18,0) NOT NULL DEFAULT 0,  -- LuongCoBan + TongPhuCap - TongKhauTru
  SoCaLamViec     INT NOT NULL DEFAULT 0,
  TrangThai       VARCHAR(30) NOT NULL DEFAULT 'ChuaTinh',
  -- ChuaTinh | DaTinh | DaPhat | XacNhanDaChuyenKhoan
  GhiChu          NVARCHAR(500),
  CreatedAt       DATETIME DEFAULT GETDATE(),
  UNIQUE (KyLuongID, AccountID)
);
```

### 2.4 `YeuCauUngLuong`
Yêu cầu ứng lương từ nhân viên, manager duyệt thủ công.

```sql
CREATE TABLE YeuCauUngLuong (
  YeuCauUngLuongID INT IDENTITY(1,1) PRIMARY KEY,
  AccountID        INT NOT NULL REFERENCES Accounts(AccountID),
  CoSoID           INT NOT NULL REFERENCES CoSo(CoSoID),
  SoTienUng        DECIMAL(18,0) NOT NULL,
  LyDo             NVARCHAR(500),
  TrangThai        VARCHAR(20) NOT NULL DEFAULT 'ChoDuyet',
  -- ChoDuyet | DaDuyet | TuChoi | DaHuy
  GhiChuQuanLy     NVARCHAR(500),
  XuLyBy           INT REFERENCES Accounts(AccountID),
  NgayXuLy         DATETIME,
  CreatedAt        DATETIME DEFAULT GETDATE()
);
```

---

## 3. Kiến trúc Backend

### Controllers

| File | URL Pattern | Mô tả |
|------|------------|-------|
| `controller/manager/LuongManagerServlet.java` | `/manager/luong` | Trang tổng quan kỳ lương |
| `controller/manager/LuongManagerServlet.java` | `/manager/luong/cau-hinh` | Cấu hình lương nhân viên |
| `controller/manager/LuongManagerServlet.java` | `/manager/luong/phat` | Trang phát lương |
| `controller/manager/api/LuongManagerApiServlet.java` | `/manager/api/luong/*` | API tính lương, xác nhận chuyển khoản, duyệt ứng |
| `controller/staff/LuongStaffServlet.java` | `/staff/luong` | Bảng lương + ứng lương (staff) |
| `controller/guard/LuongGuardServlet.java` | `/guard/luong` | Bảng lương + ứng lương (guard) |

### Services

| File | Trách nhiệm |
|------|-------------|
| `service/manager/LuongService.java` | CRUD KyLuong, tính BangLuong từ CaLamViec, cập nhật trạng thái |
| `service/manager/UngLuongService.java` | CRUD YeuCauUngLuong, duyệt/từ chối, cập nhật TongKhauTru |

### Models

- `model/CauHinhLuong.java`
- `model/KyLuong.java`
- `model/BangLuong.java`
- `model/YeuCauUngLuong.java`

---

## 4. Logic tính lương

Khi manager bấm "Tính lương" cho một kỳ:

```
Với mỗi nhân viên có CauHinhLuong tại CoSo:
  SoCaLamViec = COUNT(CaLamViec WHERE accountId = X
                      AND ngayLam BETWEEN KyLuong.NgayBatDau AND KyLuong.NgayKetThuc
                      AND trangThai IN ('CheckedOut', 'Confirmed'))
  TongPhuCap  = SoCaLamViec × PhuCapMoiCa
  TongKhauTru = SUM(YeuCauUngLuong.SoTienUng WHERE trangThai = 'DaDuyet'
                    AND createdAt BETWEEN NgayBatDau AND NgayKetThuc)
  TongLuongThuc = LuongCoBan + TongPhuCap - TongKhauTru
  → Upsert BangLuong
```

---

## 5. Trang phát lương (`PhatLuong.jsp`)

Khi `today == KyLuong.NgayPhatLuong`, banner nổi bật xuất hiện.

Mỗi nhân viên hiển thị dạng card:
- Tên, avatar, số tiền thực nhận (to, rõ)
- **QR động**: generate bằng VietQR API từ `soTaiKhoan` + `maNganHang` + `TongLuongThuc`
- **QR tĩnh**: ảnh nhân viên đã upload (nếu có), hiển thị bên cạnh làm backup
- Thông tin tài khoản dạng text: tên ngân hàng, số TK, tên chủ TK
- Nút **"Đã chuyển khoản"** → AJAX PUT `/manager/api/luong/xac-nhan?bangLuongId=X` → card xanh

---

## 6. Giao diện Staff/Guard

### `LuongCuaToi.jsp`
- **Tab Bảng lương**: bảng lịch sử kỳ — số ca, lương cơ bản, phụ cấp, đã ứng, **thực nhận**, trạng thái
- **Tab Tài khoản ngân hàng**: form sửa `maNganHang` + `soTaiKhoan` (POST lên `/account/update-profile`) + upload ảnh QR tĩnh

> Upload ảnh QR lưu vào column `QrImagePath NVARCHAR(500)` thêm vào bảng `Accounts`. Migration script thêm column này.

### `YeuCauUngLuong.jsp`
- Form nhập `SoTienUng` (validate ≤ `HanMucUng`) + `LyDo`
- Bảng lịch sử yêu cầu ứng với badge trạng thái
- Nhân viên có thể hủy yêu cầu đang ở trạng thái `ChoDuyet`

---

## 7. Sidebar links cần thêm

| Role | Label | URL |
|------|-------|-----|
| Manager | Quản lý lương | `/manager/luong` |
| Staff | Lương của tôi | `/staff/luong` |
| Guard | Lương của tôi | `/guard/luong` |

---

## 8. Ngoài phạm vi (không làm trong iteration này)

- Tự động tạo kỳ lương theo lịch (scheduler)
- Tích hợp PayOS để chuyển lương tự động
- Báo cáo lương theo năm / export Excel
- Thuế thu nhập cá nhân
