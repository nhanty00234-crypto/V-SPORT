# Module Tính Lương Nhân Viên — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Manager cấu hình lương, tạo kỳ lương, tính lương tự động từ `CaLamViec`, phát lương qua VietQR; staff/guard xem bảng lương, khai báo tài khoản ngân hàng và gửi yêu cầu ứng lương.

**Architecture:** 4 bảng SQL mới (`CauHinhLuong`, `KyLuong`, `BangLuong`, `YeuCauUngLuong`) + 1 cột `QrImagePath` thêm vào `Accounts`. Truy cập DB bằng plain JDBC DAO qua `DBUtil.getConnection()` (theo pattern `CoSoNganHangDAOImpl`, KHÔNG dùng JPA). Logic tính tiền thuần tuý tách ra `util/LuongCalculator.java` để unit-test được không cần DB. Servlet `@WebServlet` annotation-only, JSP + JSTL, AJAX bằng `fetch` trả JSON qua Gson.

**Tech Stack:** Jakarta Servlet, JDBC (SQL Server, HikariCP qua `DBUtil`), Gson, JSTL, JUnit 5 + Mockito, VietQR image API (`img.vietqr.io`).

## Global Constraints

- **KHÔNG sửa** logic hiện có của: `CaLamViec*` (chỉ ĐỌC để đếm ca), `HoaDon*`, `HoanTien*`, PayOS, face-attendance. Module lương là module độc lập, chỉ đọc từ `CaLamViec` và `Accounts`.
- **CoSoID luôn lấy từ session** (`((TaiKhoan) session.getAttribute("user")).getCoSoId()`), KHÔNG BAO GIỜ tin request param. Mọi DAO query của manager phải có mệnh đề `AND CoSoID = ?`. Đây là nguyên tắc chống IDOR đã áp dụng cho toàn hệ thống.
- **AccountID của staff/guard luôn lấy từ session**, không tin param — staff chỉ được xem/sửa dữ liệu lương của chính mình.
- Role IDs (từ `org.example.util.Constants`): `ROLE_ADMIN=1`, `ROLE_MANAGER=2`, `ROLE_KHACH_HANG=3`, `ROLE_LE_TAN=4`, `ROLE_BAO_VE=5`. Nhân sự hưởng lương = `Constants.ALLOWED_SHIFT_ROLES` = `List.of(ROLE_LE_TAN, ROLE_BAO_VE)`.
- Trạng thái `CaLamViec` được tính lương: `'CheckedOut'` và `'Confirmed'` (theo spec §4). Ca `IsDeleted = 1` KHÔNG được tính.
- Tiền tệ dùng `java.math.BigDecimal`, cột SQL `DECIMAL(18,0)` (VND không có phần lẻ). KHÔNG dùng `double` cho tiền.
- Migration script đặt tại `sql/`, luôn bọc `IF NOT EXISTS` để chạy lại được nhiều lần (idempotent).
- Servlet mapping bằng `@WebServlet` annotation, KHÔNG sửa `web.xml`.
- Ảnh QR tĩnh của nhân viên là **dữ liệu nhạy cảm** (gắn tài khoản ngân hàng thật) — lưu ngoài webroot theo đúng cơ chế `RefundQrUploadPaths`, serve qua servlet có kiểm tra quyền, KHÔNG để trong `src/main/webapp`.
- Text hiển thị bằng tiếng Việt. Cột `NVARCHAR` phải đọc bằng `rs.getNString(...)` và ghi bằng `ps.setNString(...)`.
- Build kiểm tra bằng `mvn -o compile -DskipTests`; test bằng `mvn -o test -Dtest=<TenTest>`.

---

## File Structure

**Migration**
- Create: `sql/migration_salary.sql` — 4 bảng mới + cột `Accounts.QrImagePath`.

**Model (POJO thuần, không annotation JPA)**
- Create: `src/main/java/org/example/model/CauHinhLuong.java`
- Create: `src/main/java/org/example/model/KyLuong.java`
- Create: `src/main/java/org/example/model/BangLuong.java`
- Create: `src/main/java/org/example/model/YeuCauUngLuong.java`

**Util (thuần, unit-test được)**
- Create: `src/main/java/org/example/util/LuongCalculator.java` — công thức tính lương.
- Create: `src/main/java/org/example/util/VietQrUrl.java` — build URL ảnh VietQR động.
- Create: `src/main/java/org/example/util/StaffQrUploadPaths.java` — đường dẫn ảnh QR tĩnh của nhân viên.

**DAO**
- Create: `src/main/java/org/example/dao/CauHinhLuongDAO.java` + `impl/CauHinhLuongDAOImpl.java`
- Create: `src/main/java/org/example/dao/KyLuongDAO.java` + `impl/KyLuongDAOImpl.java`
- Create: `src/main/java/org/example/dao/BangLuongDAO.java` + `impl/BangLuongDAOImpl.java`
- Create: `src/main/java/org/example/dao/YeuCauUngLuongDAO.java` + `impl/YeuCauUngLuongDAOImpl.java`
- Modify: `src/main/java/org/example/dao/CaLamViecDAO.java` + `impl/CaLamViecDAOImpl.java` — thêm `countCaHoanThanh(...)`.
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java` + `impl/TaiKhoanDAOImpl.java` — thêm `updateQrImagePath(...)`, `updateBankInfo(...)`.
- Modify: `src/main/java/org/example/model/TaiKhoan.java` — thêm field `qrImagePath`.

**Service**
- Create: `src/main/java/org/example/service/manager/LuongService.java`
- Create: `src/main/java/org/example/service/manager/UngLuongService.java`

**Controller**
- Create: `src/main/java/org/example/controller/manager/LuongManagerServlet.java` — `/manager/luong`, `/manager/luong/cau-hinh`, `/manager/luong/phat`, `/manager/luong/ung-luong`
- Create: `src/main/java/org/example/controller/manager/api/LuongManagerApiServlet.java` — `/manager/api/luong/*`
- Create: `src/main/java/org/example/controller/staff/LuongStaffServlet.java` — `/staff/luong`
- Create: `src/main/java/org/example/controller/guard/LuongGuardServlet.java` — `/guard/luong`
- Create: `src/main/java/org/example/controller/NhanVienQrServeServlet.java` — `/nhan-vien/qr-image`

**JSP**
- Create: `src/main/webapp/manager/Luong.jsp` — tổng quan kỳ lương
- Create: `src/main/webapp/manager/CauHinhLuong.jsp`
- Create: `src/main/webapp/manager/PhatLuong.jsp`
- Create: `src/main/webapp/manager/DuyetUngLuong.jsp`
- Create: `src/main/webapp/staff/LuongCuaToi.jsp` — dùng chung cho cả guard qua `<jsp:include>`
- Modify: `src/main/webapp/manager/common/sidebar.jsp`, `staff/common/sidebar.jsp`, `guard/common/sidebar.jsp`

**Test**
- Create: `src/test/java/org/example/util/LuongCalculatorTest.java`
- Create: `src/test/java/org/example/util/VietQrUrlTest.java`
- Create: `src/test/java/org/example/service/UngLuongValidationTest.java`

---

## Phase 1 — Nền tảng: schema, model, util thuần

### Task 1: Migration SQL

**Files:**
- Create: `sql/migration_salary.sql`

**Interfaces:**
- Consumes: bảng có sẵn `Accounts(AccountID)`, `CoSo(CoSoID)`.
- Produces: 4 bảng + cột `Accounts.QrImagePath NVARCHAR(500) NULL` cho mọi task sau.

- [ ] **Step 1: Viết migration script**

```sql
-- sql/migration_salary.sql
-- Module tính lương nhân viên. Idempotent: chạy lại nhiều lần không lỗi.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CauHinhLuong')
BEGIN
  CREATE TABLE CauHinhLuong (
    CauHinhLuongID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID      INT NOT NULL REFERENCES Accounts(AccountID),
    CoSoID         INT NOT NULL REFERENCES CoSo(CoSoID),
    LuongCoBan     DECIMAL(18,0) NOT NULL DEFAULT 0,
    PhuCapMoiCa    DECIMAL(18,0) NOT NULL DEFAULT 0,
    HanMucUng      DECIMAL(18,0) NOT NULL DEFAULT 0,
    GhiChu         NVARCHAR(500) NULL,
    CreatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_CauHinhLuong_Account_CoSo UNIQUE (AccountID, CoSoID)
  );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'KyLuong')
BEGIN
  CREATE TABLE KyLuong (
    KyLuongID     INT IDENTITY(1,1) PRIMARY KEY,
    CoSoID        INT NOT NULL REFERENCES CoSo(CoSoID),
    TenKy         NVARCHAR(100) NOT NULL,
    NgayBatDau    DATE NOT NULL,
    NgayKetThuc   DATE NOT NULL,
    NgayPhatLuong DATE NOT NULL,
    TrangThai     VARCHAR(20) NOT NULL DEFAULT 'Draft',  -- Draft | DangTinh | DaPhat
    CreatedBy     INT NOT NULL REFERENCES Accounts(AccountID),
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE()
  );
  CREATE INDEX IX_KyLuong_CoSo ON KyLuong(CoSoID, NgayBatDau DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'BangLuong')
BEGIN
  CREATE TABLE BangLuong (
    BangLuongID   INT IDENTITY(1,1) PRIMARY KEY,
    KyLuongID     INT NOT NULL REFERENCES KyLuong(KyLuongID),
    AccountID     INT NOT NULL REFERENCES Accounts(AccountID),
    LuongCoBan    DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongPhuCap    DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongKhauTru   DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongLuongThuc DECIMAL(18,0) NOT NULL DEFAULT 0,
    SoCaLamViec   INT NOT NULL DEFAULT 0,
    TrangThai     VARCHAR(30) NOT NULL DEFAULT 'ChuaTinh',
    -- ChuaTinh | DaTinh | DaPhat | XacNhanDaChuyenKhoan
    GhiChu        NVARCHAR(500) NULL,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_BangLuong_Ky_Account UNIQUE (KyLuongID, AccountID)
  );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'YeuCauUngLuong')
BEGIN
  CREATE TABLE YeuCauUngLuong (
    YeuCauUngLuongID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID        INT NOT NULL REFERENCES Accounts(AccountID),
    CoSoID           INT NOT NULL REFERENCES CoSo(CoSoID),
    SoTienUng        DECIMAL(18,0) NOT NULL,
    LyDo             NVARCHAR(500) NULL,
    TrangThai        VARCHAR(20) NOT NULL DEFAULT 'ChoDuyet',
    -- ChoDuyet | DaDuyet | TuChoi | DaHuy
    GhiChuQuanLy     NVARCHAR(500) NULL,
    XuLyBy           INT NULL REFERENCES Accounts(AccountID),
    NgayXuLy         DATETIME NULL,
    CreatedAt        DATETIME NOT NULL DEFAULT GETDATE()
  );
  CREATE INDEX IX_YeuCauUngLuong_CoSo_TrangThai ON YeuCauUngLuong(CoSoID, TrangThai, CreatedAt DESC);
  CREATE INDEX IX_YeuCauUngLuong_Account ON YeuCauUngLuong(AccountID, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Accounts') AND name = 'QrImagePath')
BEGIN
  ALTER TABLE Accounts ADD QrImagePath NVARCHAR(500) NULL;
END;
```

- [ ] **Step 2: Kiểm tra cú pháp bằng mắt và commit**

Không có runner tự động cho migration trong repo (các `Run*MigrationTest.java` là script chạy tay). Chỉ cần đảm bảo script idempotent.

```bash
git add sql/migration_salary.sql
git commit -m "feat(luong): migration schema module tính lương"
```

---

### Task 2: `LuongCalculator` — công thức tính lương (TDD)

**Files:**
- Create: `src/main/java/org/example/util/LuongCalculator.java`
- Test: `src/test/java/org/example/util/LuongCalculatorTest.java`

**Interfaces:**
- Produces:
  - `static BigDecimal tongPhuCap(BigDecimal phuCapMoiCa, int soCaLamViec)`
  - `static BigDecimal tongLuongThuc(BigDecimal luongCoBan, BigDecimal tongPhuCap, BigDecimal tongKhauTru)`
  - `static BigDecimal chuanHoa(BigDecimal v)` — null → `ZERO`, làm tròn về số nguyên VND (`setScale(0, RoundingMode.HALF_UP)`).

- [ ] **Step 1: Viết test thất bại**

```java
package org.example.util;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Khoá lại công thức lương của spec §4:
 *   TongPhuCap    = PhuCapMoiCa × SoCaLamViec
 *   TongLuongThuc = LuongCoBan + TongPhuCap − TongKhauTru
 * Tiền VND: luôn là số nguyên, không âm.
 */
class LuongCalculatorTest {

    @Test
    void phuCap_nhanDungSoCa() {
        assertEquals(new BigDecimal("600000"),
                LuongCalculator.tongPhuCap(new BigDecimal("50000"), 12));
    }

    @Test
    void phuCap_khongCoCa_traVeZero() {
        assertEquals(BigDecimal.ZERO, LuongCalculator.tongPhuCap(new BigDecimal("50000"), 0));
    }

    @Test
    void phuCap_phuCapNull_traVeZero() {
        assertEquals(BigDecimal.ZERO, LuongCalculator.tongPhuCap(null, 12));
    }

    @Test
    void phuCap_soCaAm_bikhongChapNhan() {
        assertThrows(IllegalArgumentException.class,
                () -> LuongCalculator.tongPhuCap(new BigDecimal("50000"), -1));
    }

    @Test
    void luongThuc_congPhuCapTruKhauTru() {
        assertEquals(new BigDecimal("5600000"),
                LuongCalculator.tongLuongThuc(
                        new BigDecimal("5000000"), new BigDecimal("1000000"), new BigDecimal("400000")));
    }

    /** Ứng nhiều hơn lương: thực nhận kẹp về 0, KHÔNG trả số âm (manager không chuyển tiền âm). */
    @Test
    void luongThuc_khauTruVuotLuong_kepVeZero() {
        assertEquals(BigDecimal.ZERO,
                LuongCalculator.tongLuongThuc(
                        new BigDecimal("2000000"), BigDecimal.ZERO, new BigDecimal("3000000")));
    }

    @Test
    void luongThuc_thamSoNull_coiNhuZero() {
        assertEquals(new BigDecimal("1000000"),
                LuongCalculator.tongLuongThuc(new BigDecimal("1000000"), null, null));
    }

    /** VND không có phần lẻ — chuẩn hoá về số nguyên. */
    @Test
    void chuanHoa_lamTronVeSoNguyen() {
        assertEquals(new BigDecimal("1235"), LuongCalculator.chuanHoa(new BigDecimal("1234.6")));
        assertEquals(BigDecimal.ZERO, LuongCalculator.chuanHoa(null));
    }
}
```

- [ ] **Step 2: Chạy test để xác nhận FAIL**

```bash
mvn -o test -Dtest=LuongCalculatorTest
```

Kỳ vọng: FAIL — `cannot find symbol: class LuongCalculator`.

- [ ] **Step 3: Viết implementation tối thiểu**

```java
package org.example.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Công thức tính lương (spec §4). Thuần tuý, không chạm DB — mọi thay đổi về cách tính
 * tiền phải đi qua đây để test khoá lại được.
 */
public final class LuongCalculator {

    private LuongCalculator() {}

    /** VND không có phần lẻ: null → 0, số lẻ → làm tròn nửa lên. */
    public static BigDecimal chuanHoa(BigDecimal v) {
        if (v == null) return BigDecimal.ZERO;
        return v.setScale(0, RoundingMode.HALF_UP);
    }

    /** TongPhuCap = PhuCapMoiCa × SoCaLamViec. */
    public static BigDecimal tongPhuCap(BigDecimal phuCapMoiCa, int soCaLamViec) {
        if (soCaLamViec < 0) {
            throw new IllegalArgumentException("Số ca làm việc không thể âm: " + soCaLamViec);
        }
        return chuanHoa(chuanHoa(phuCapMoiCa).multiply(BigDecimal.valueOf(soCaLamViec)));
    }

    /**
     * TongLuongThuc = LuongCoBan + TongPhuCap − TongKhauTru, kẹp sàn tại 0.
     * Ứng vượt lương không tạo ra số tiền âm — phần vượt coi như treo sang kỳ sau (ngoài phạm vi).
     */
    public static BigDecimal tongLuongThuc(BigDecimal luongCoBan, BigDecimal tongPhuCap, BigDecimal tongKhauTru) {
        BigDecimal thuc = chuanHoa(luongCoBan)
                .add(chuanHoa(tongPhuCap))
                .subtract(chuanHoa(tongKhauTru));
        return thuc.signum() < 0 ? BigDecimal.ZERO : thuc;
    }
}
```

- [ ] **Step 4: Chạy test để xác nhận PASS**

```bash
mvn -o test -Dtest=LuongCalculatorTest
```

Kỳ vọng: PASS, 8 tests.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/LuongCalculator.java src/test/java/org/example/util/LuongCalculatorTest.java
git commit -m "feat(luong): LuongCalculator + test khoá công thức tính lương"
```

---

### Task 3: `VietQrUrl` — build URL ảnh QR động (TDD)

**Files:**
- Create: `src/main/java/org/example/util/VietQrUrl.java`
- Test: `src/test/java/org/example/util/VietQrUrlTest.java`

**Interfaces:**
- Produces: `static String compact2(String maNganHang, String soTaiKhoan, BigDecimal soTien, String noiDung, String tenChuTk)` — trả `null` nếu thiếu mã ngân hàng hoặc số tài khoản.

Định dạng theo đúng cách hệ thống đang dùng ở `CheckInServlet:701`:
`https://img.vietqr.io/image/{bank}-{accountNo}-compact2.png?amount=..&addInfo=..&accountName=..`

- [ ] **Step 1: Viết test thất bại**

```java
package org.example.util;

import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

class VietQrUrlTest {

    @Test
    void dungDinhDangCompact2VaEncodeThamSo() {
        String url = VietQrUrl.compact2("970436", "1234567890",
                new BigDecimal("5600000"), "Luong thang 7", "NGUYEN VAN A");

        assertTrue(url.startsWith("https://img.vietqr.io/image/970436-1234567890-compact2.png?"), url);
        assertTrue(url.contains("amount=5600000"), url);
        assertTrue(url.contains("addInfo=Luong+thang+7"), url);
        assertTrue(url.contains("accountName=NGUYEN+VAN+A"), url);
    }

    /** Chưa khai báo tài khoản ngân hàng → không dựng được QR, trả null để UI hiện cảnh báo. */
    @Test
    void thieuThongTinNganHang_traVeNull() {
        assertNull(VietQrUrl.compact2(null, "123", BigDecimal.TEN, "x", "A"));
        assertNull(VietQrUrl.compact2("970436", "  ", BigDecimal.TEN, "x", "A"));
    }

    /** Số tiền 0/null vẫn dựng QR được (QR không có sẵn số tiền), chỉ là không kèm amount. */
    @Test
    void soTienNull_khongKemAmount() {
        String url = VietQrUrl.compact2("970436", "123", null, "x", "A");
        assertNotNull(url);
        assertFalse(url.contains("amount="), url);
    }

    /** Ký tự có dấu trong nội dung/tên phải được URL-encode, không làm vỡ URL. */
    @Test
    void noiDungCoDau_duocEncode() {
        String url = VietQrUrl.compact2("970436", "123", BigDecimal.ONE, "Lương tháng 7", "Nguyễn Văn A");
        assertFalse(url.contains(" "), url);
        assertTrue(url.contains("addInfo=L%C6%B0%C6%A1ng"), url);
    }
}
```

- [ ] **Step 2: Chạy test để xác nhận FAIL**

```bash
mvn -o test -Dtest=VietQrUrlTest
```

Kỳ vọng: FAIL — `cannot find symbol: class VietQrUrl`.

- [ ] **Step 3: Viết implementation**

```java
package org.example.util;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.math.RoundingMode;

/**
 * Dựng URL ảnh VietQR động (img.vietqr.io) — cùng định dạng compact2 mà luồng thu tiền
 * tại quầy (CheckInServlet) và hoàn tiền đang dùng, để app ngân hàng quét ra sẵn số tiền
 * và nội dung chuyển khoản.
 */
public final class VietQrUrl {

    private VietQrUrl() {}

    /**
     * @param maNganHang BIN/short code ngân hàng (cột Accounts.MaNganHang), bắt buộc.
     * @param soTaiKhoan số tài khoản (cột Accounts.SoTaiKhoan), bắt buộc.
     * @param soTien     số tiền; null hoặc ≤ 0 thì bỏ tham số amount.
     * @param noiDung    nội dung chuyển khoản, có thể null.
     * @param tenChuTk   tên chủ tài khoản hiển thị, có thể null.
     * @return URL ảnh PNG, hoặc null nếu chưa đủ thông tin ngân hàng.
     */
    public static String compact2(String maNganHang, String soTaiKhoan,
                                  BigDecimal soTien, String noiDung, String tenChuTk) {
        if (isBlank(maNganHang) || isBlank(soTaiKhoan)) return null;

        StringBuilder sb = new StringBuilder("https://img.vietqr.io/image/")
                .append(maNganHang.trim()).append('-')
                .append(soTaiKhoan.trim()).append("-compact2.png?");

        boolean first = true;
        if (soTien != null && soTien.signum() > 0) {
            sb.append("amount=").append(soTien.setScale(0, RoundingMode.HALF_UP).toPlainString());
            first = false;
        }
        if (!isBlank(noiDung)) {
            if (!first) sb.append('&');
            sb.append("addInfo=").append(enc(noiDung));
            first = false;
        }
        if (!isBlank(tenChuTk)) {
            if (!first) sb.append('&');
            sb.append("accountName=").append(enc(tenChuTk));
        }
        return sb.toString();
    }

    private static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }

    private static boolean isBlank(String v) {
        return v == null || v.isBlank();
    }
}
```

- [ ] **Step 4: Chạy test để xác nhận PASS**

```bash
mvn -o test -Dtest=VietQrUrlTest
```

Kỳ vọng: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/VietQrUrl.java src/test/java/org/example/util/VietQrUrlTest.java
git commit -m "feat(luong): VietQrUrl builder + test"
```

---

### Task 4: 4 model POJO

**Files:**
- Create: `src/main/java/org/example/model/CauHinhLuong.java`
- Create: `src/main/java/org/example/model/KyLuong.java`
- Create: `src/main/java/org/example/model/BangLuong.java`
- Create: `src/main/java/org/example/model/YeuCauUngLuong.java`

**Interfaces:**
- Consumes: schema từ Task 1.
- Produces: các POJO dưới đây, được mọi DAO/service/JSP sau dùng. Getter/setter chuẩn JavaBean để JSTL `${x.tenKy}` hoạt động.

- [ ] **Step 1: Tạo `CauHinhLuong.java`**

```java
package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Cấu hình lương của một nhân viên tại một cơ sở (bảng CauHinhLuong). */
public class CauHinhLuong {
    private int cauHinhLuongId;
    private int accountId;
    private int coSoId;
    private BigDecimal luongCoBan = BigDecimal.ZERO;
    private BigDecimal phuCapMoiCa = BigDecimal.ZERO;
    private BigDecimal hanMucUng = BigDecimal.ZERO;
    private String ghiChu;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Trường hiển thị, join từ Accounts — không có cột tương ứng trong CauHinhLuong.
    private String hoTen;
    private String tenVaiTro;

    public int getCauHinhLuongId() { return cauHinhLuongId; }
    public void setCauHinhLuongId(int v) { this.cauHinhLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public BigDecimal getLuongCoBan() { return luongCoBan; }
    public void setLuongCoBan(BigDecimal v) { this.luongCoBan = v; }
    public BigDecimal getPhuCapMoiCa() { return phuCapMoiCa; }
    public void setPhuCapMoiCa(BigDecimal v) { this.phuCapMoiCa = v; }
    public BigDecimal getHanMucUng() { return hanMucUng; }
    public void setHanMucUng(BigDecimal v) { this.hanMucUng = v; }
    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String v) { this.ghiChu = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime v) { this.updatedAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getTenVaiTro() { return tenVaiTro; }
    public void setTenVaiTro(String v) { this.tenVaiTro = v; }
}
```

- [ ] **Step 2: Tạo `KyLuong.java`**

```java
package org.example.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** Một kỳ tính lương của một cơ sở (bảng KyLuong). */
public class KyLuong {
    public static final String DRAFT    = "Draft";
    public static final String DANG_TINH = "DangTinh";
    public static final String DA_PHAT  = "DaPhat";

    private int kyLuongId;
    private int coSoId;
    private String tenKy;
    private LocalDate ngayBatDau;
    private LocalDate ngayKetThuc;
    private LocalDate ngayPhatLuong;
    private String trangThai = DRAFT;
    private int createdBy;
    private LocalDateTime createdAt;

    // Trường tổng hợp, tính khi load danh sách — không có cột trong KyLuong.
    private int soNhanVien;
    private java.math.BigDecimal tongChi = java.math.BigDecimal.ZERO;

    public int getKyLuongId() { return kyLuongId; }
    public void setKyLuongId(int v) { this.kyLuongId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public String getTenKy() { return tenKy; }
    public void setTenKy(String v) { this.tenKy = v; }
    public LocalDate getNgayBatDau() { return ngayBatDau; }
    public void setNgayBatDau(LocalDate v) { this.ngayBatDau = v; }
    public LocalDate getNgayKetThuc() { return ngayKetThuc; }
    public void setNgayKetThuc(LocalDate v) { this.ngayKetThuc = v; }
    public LocalDate getNgayPhatLuong() { return ngayPhatLuong; }
    public void setNgayPhatLuong(LocalDate v) { this.ngayPhatLuong = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int v) { this.createdBy = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public int getSoNhanVien() { return soNhanVien; }
    public void setSoNhanVien(int v) { this.soNhanVien = v; }
    public java.math.BigDecimal getTongChi() { return tongChi; }
    public void setTongChi(java.math.BigDecimal v) { this.tongChi = v; }

    /** Kỳ đã phát lương thì khoá, không cho tính lại. */
    public boolean isKhoa() { return DA_PHAT.equals(trangThai); }
}
```

- [ ] **Step 3: Tạo `BangLuong.java`**

```java
package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Dòng lương của một nhân viên trong một kỳ (bảng BangLuong). */
public class BangLuong {
    public static final String CHUA_TINH = "ChuaTinh";
    public static final String DA_TINH   = "DaTinh";
    public static final String DA_PHAT   = "DaPhat";
    public static final String DA_CHUYEN = "XacNhanDaChuyenKhoan";

    private int bangLuongId;
    private int kyLuongId;
    private int accountId;
    private BigDecimal luongCoBan = BigDecimal.ZERO;
    private BigDecimal tongPhuCap = BigDecimal.ZERO;
    private BigDecimal tongKhauTru = BigDecimal.ZERO;
    private BigDecimal tongLuongThuc = BigDecimal.ZERO;
    private int soCaLamViec;
    private String trangThai = CHUA_TINH;
    private String ghiChu;
    private LocalDateTime createdAt;

    // Trường hiển thị, join từ Accounts / KyLuong — không có cột trong BangLuong.
    private String hoTen;
    private String avatarUrl;
    private String maNganHang;
    private String soTaiKhoan;
    private String qrImagePath;
    private String tenKy;
    private java.time.LocalDate ngayPhatLuong;
    /** URL ảnh VietQR động, set ở service bằng VietQrUrl.compact2(...). */
    private String qrDongUrl;

    public int getBangLuongId() { return bangLuongId; }
    public void setBangLuongId(int v) { this.bangLuongId = v; }
    public int getKyLuongId() { return kyLuongId; }
    public void setKyLuongId(int v) { this.kyLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public BigDecimal getLuongCoBan() { return luongCoBan; }
    public void setLuongCoBan(BigDecimal v) { this.luongCoBan = v; }
    public BigDecimal getTongPhuCap() { return tongPhuCap; }
    public void setTongPhuCap(BigDecimal v) { this.tongPhuCap = v; }
    public BigDecimal getTongKhauTru() { return tongKhauTru; }
    public void setTongKhauTru(BigDecimal v) { this.tongKhauTru = v; }
    public BigDecimal getTongLuongThuc() { return tongLuongThuc; }
    public void setTongLuongThuc(BigDecimal v) { this.tongLuongThuc = v; }
    public int getSoCaLamViec() { return soCaLamViec; }
    public void setSoCaLamViec(int v) { this.soCaLamViec = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String v) { this.ghiChu = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String v) { this.avatarUrl = v; }
    public String getMaNganHang() { return maNganHang; }
    public void setMaNganHang(String v) { this.maNganHang = v; }
    public String getSoTaiKhoan() { return soTaiKhoan; }
    public void setSoTaiKhoan(String v) { this.soTaiKhoan = v; }
    public String getQrImagePath() { return qrImagePath; }
    public void setQrImagePath(String v) { this.qrImagePath = v; }
    public String getTenKy() { return tenKy; }
    public void setTenKy(String v) { this.tenKy = v; }
    public java.time.LocalDate getNgayPhatLuong() { return ngayPhatLuong; }
    public void setNgayPhatLuong(java.time.LocalDate v) { this.ngayPhatLuong = v; }
    public String getQrDongUrl() { return qrDongUrl; }
    public void setQrDongUrl(String v) { this.qrDongUrl = v; }

    public boolean isDaChuyenKhoan() { return DA_CHUYEN.equals(trangThai); }
}
```

- [ ] **Step 4: Tạo `YeuCauUngLuong.java`**

```java
package org.example.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Yêu cầu ứng lương của nhân viên (bảng YeuCauUngLuong). */
public class YeuCauUngLuong {
    public static final String CHO_DUYET = "ChoDuyet";
    public static final String DA_DUYET  = "DaDuyet";
    public static final String TU_CHOI   = "TuChoi";
    public static final String DA_HUY    = "DaHuy";

    private int yeuCauUngLuongId;
    private int accountId;
    private int coSoId;
    private BigDecimal soTienUng = BigDecimal.ZERO;
    private String lyDo;
    private String trangThai = CHO_DUYET;
    private String ghiChuQuanLy;
    private Integer xuLyBy;
    private LocalDateTime ngayXuLy;
    private LocalDateTime createdAt;

    // Trường hiển thị, join từ Accounts.
    private String hoTen;
    private String tenNguoiXuLy;

    public int getYeuCauUngLuongId() { return yeuCauUngLuongId; }
    public void setYeuCauUngLuongId(int v) { this.yeuCauUngLuongId = v; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int v) { this.accountId = v; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int v) { this.coSoId = v; }
    public BigDecimal getSoTienUng() { return soTienUng; }
    public void setSoTienUng(BigDecimal v) { this.soTienUng = v; }
    public String getLyDo() { return lyDo; }
    public void setLyDo(String v) { this.lyDo = v; }
    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String v) { this.trangThai = v; }
    public String getGhiChuQuanLy() { return ghiChuQuanLy; }
    public void setGhiChuQuanLy(String v) { this.ghiChuQuanLy = v; }
    public Integer getXuLyBy() { return xuLyBy; }
    public void setXuLyBy(Integer v) { this.xuLyBy = v; }
    public LocalDateTime getNgayXuLy() { return ngayXuLy; }
    public void setNgayXuLy(LocalDateTime v) { this.ngayXuLy = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
    public String getHoTen() { return hoTen; }
    public void setHoTen(String v) { this.hoTen = v; }
    public String getTenNguoiXuLy() { return tenNguoiXuLy; }
    public void setTenNguoiXuLy(String v) { this.tenNguoiXuLy = v; }

    /** Chỉ yêu cầu đang chờ duyệt mới được nhân viên tự huỷ hoặc manager xử lý. */
    public boolean isChoDuyet() { return CHO_DUYET.equals(trangThai); }
}
```

- [ ] **Step 5: Biên dịch và commit**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

```bash
git add src/main/java/org/example/model/CauHinhLuong.java src/main/java/org/example/model/KyLuong.java src/main/java/org/example/model/BangLuong.java src/main/java/org/example/model/YeuCauUngLuong.java
git commit -m "feat(luong): 4 model POJO cho module lương"
```

---

## Phase 2 — DAO layer

### Task 5: `CaLamViecDAO.countCaHoanThanh` — đếm ca để tính phụ cấp

**Files:**
- Modify: `src/main/java/org/example/dao/CaLamViecDAO.java` (thêm method vào interface)
- Modify: `src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java` (thêm implementation, JDBC theo pattern `getFaceAttendanceHistory`)

**Interfaces:**
- Consumes: bảng `CaLamViec` có sẵn (`AccountID`, `CoSoID`, `NgayLam`, `TrangThai`, `IsDeleted`).
- Produces: `int countCaHoanThanh(int accountId, int coSoId, LocalDate tuNgay, LocalDate denNgay) throws Exception`

- [ ] **Step 1: Thêm khai báo vào interface**

Mở `src/main/java/org/example/dao/CaLamViecDAO.java`, thêm vào cuối interface (trước dấu `}` cuối cùng):

```java
    /**
     * Đếm số ca ĐÃ HOÀN THÀNH của một nhân viên trong khoảng ngày, dùng để tính phụ cấp theo ca.
     * Chỉ tính trạng thái 'CheckedOut' và 'Confirmed'; bỏ qua ca đã xoá mềm.
     * Khoảng ngày là inclusive hai đầu.
     */
    int countCaHoanThanh(int accountId, int coSoId, java.time.LocalDate tuNgay, java.time.LocalDate denNgay) throws Exception;
```

- [ ] **Step 2: Thêm implementation**

Mở `src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java`, thêm method (đảm bảo đã có `import org.example.util.DBUtil;` và các import `java.sql.*` — nếu file dùng tên đầy đủ thì theo style sẵn có của file):

```java
    @Override
    public int countCaHoanThanh(int accountId, int coSoId, java.time.LocalDate tuNgay, java.time.LocalDate denNgay) throws Exception {
        String sql = "SELECT COUNT(*) FROM CaLamViec " +
                "WHERE AccountID = ? AND CoSoID = ? " +
                "  AND NgayLam BETWEEN ? AND ? " +
                "  AND TrangThai IN ('CheckedOut', 'Confirmed') " +
                "  AND (IsDeleted = 0 OR IsDeleted IS NULL)";
        try (java.sql.Connection c = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, coSoId);
            ps.setDate(3, java.sql.Date.valueOf(tuNgay));
            ps.setDate(4, java.sql.Date.valueOf(denNgay));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/CaLamViecDAO.java src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java
git commit -m "feat(luong): CaLamViecDAO.countCaHoanThanh cho tính phụ cấp theo ca"
```

---

### Task 6: `CauHinhLuongDAO`

**Files:**
- Create: `src/main/java/org/example/dao/CauHinhLuongDAO.java`
- Create: `src/main/java/org/example/dao/impl/CauHinhLuongDAOImpl.java`

**Interfaces:**
- Consumes: `model.CauHinhLuong` (Task 4), bảng `CauHinhLuong` (Task 1).
- Produces:
  - `CauHinhLuong findByAccount(int accountId, int coSoId) throws Exception`
  - `List<CauHinhLuong> listByCoSo(int coSoId) throws Exception` — join `Accounts` lấy `hoTen`, `tenVaiTro`; chỉ nhân sự role 4/5, chưa xoá.
  - `void upsert(CauHinhLuong ch) throws Exception`

- [ ] **Step 1: Tạo interface**

```java
package org.example.dao;

import org.example.model.CauHinhLuong;
import java.util.List;

public interface CauHinhLuongDAO {

    /** Cấu hình lương của một nhân viên tại một cơ sở; null nếu manager chưa cấu hình. */
    CauHinhLuong findByAccount(int accountId, int coSoId) throws Exception;

    /**
     * Danh sách nhân sự hưởng lương (RoleID 4 = lễ tân, 5 = bảo vệ) của cơ sở, kèm cấu hình
     * lương nếu đã có. Nhân viên chưa cấu hình vẫn xuất hiện với cauHinhLuongId = 0 và các
     * khoản tiền = 0, để manager thấy được ai còn thiếu cấu hình.
     */
    List<CauHinhLuong> listByCoSo(int coSoId) throws Exception;

    /** Tạo mới nếu chưa có, cập nhật nếu đã có (khoá theo UNIQUE(AccountID, CoSoID)). */
    void upsert(CauHinhLuong ch) throws Exception;
}
```

- [ ] **Step 2: Tạo implementation**

```java
package org.example.dao.impl;

import org.example.dao.CauHinhLuongDAO;
import org.example.model.CauHinhLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class CauHinhLuongDAOImpl implements CauHinhLuongDAO {

    @Override
    public CauHinhLuong findByAccount(int accountId, int coSoId) throws Exception {
        String sql = "SELECT CauHinhLuongID, AccountID, CoSoID, LuongCoBan, PhuCapMoiCa, HanMucUng, " +
                "GhiChu, CreatedAt, UpdatedAt FROM CauHinhLuong WHERE AccountID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public List<CauHinhLuong> listByCoSo(int coSoId) throws Exception {
        // LEFT JOIN để nhân viên chưa cấu hình vẫn hiển thị (manager cần thấy ai còn thiếu).
        String sql = "SELECT a.AccountID, a.FullName, a.RoleID, " +
                "       ISNULL(ch.CauHinhLuongID, 0) AS CauHinhLuongID, " +
                "       ISNULL(ch.LuongCoBan, 0)  AS LuongCoBan, " +
                "       ISNULL(ch.PhuCapMoiCa, 0) AS PhuCapMoiCa, " +
                "       ISNULL(ch.HanMucUng, 0)   AS HanMucUng, " +
                "       ch.GhiChu, ch.CreatedAt, ch.UpdatedAt " +
                "FROM Accounts a " +
                "LEFT JOIN CauHinhLuong ch ON ch.AccountID = a.AccountID AND ch.CoSoID = ? " +
                "WHERE a.CoSoID = ? AND a.RoleID IN (4, 5) " +
                "  AND (a.IsDeleted = 0 OR a.IsDeleted IS NULL) " +
                "ORDER BY a.RoleID, a.FullName";
        List<CauHinhLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CauHinhLuong ch = new CauHinhLuong();
                    ch.setCauHinhLuongId(rs.getInt("CauHinhLuongID"));
                    ch.setAccountId(rs.getInt("AccountID"));
                    ch.setCoSoId(coSoId);
                    ch.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
                    ch.setPhuCapMoiCa(rs.getBigDecimal("PhuCapMoiCa"));
                    ch.setHanMucUng(rs.getBigDecimal("HanMucUng"));
                    ch.setGhiChu(rs.getNString("GhiChu"));
                    ch.setCreatedAt(toLdt(rs.getTimestamp("CreatedAt")));
                    ch.setUpdatedAt(toLdt(rs.getTimestamp("UpdatedAt")));
                    ch.setHoTen(rs.getNString("FullName"));
                    ch.setTenVaiTro(rs.getInt("RoleID") == 5 ? "Bảo vệ" : "Lễ tân");
                    out.add(ch);
                }
            }
        }
        return out;
    }

    @Override
    public void upsert(CauHinhLuong ch) throws Exception {
        // MERGE tránh race giữa 2 tab manager cùng lưu một nhân viên (UNIQUE sẽ ném lỗi nếu
        // dùng SELECT-rồi-INSERT).
        String sql = "MERGE CauHinhLuong AS t " +
                "USING (SELECT ? AS AccountID, ? AS CoSoID) AS s " +
                "  ON t.AccountID = s.AccountID AND t.CoSoID = s.CoSoID " +
                "WHEN MATCHED THEN UPDATE SET " +
                "  LuongCoBan = ?, PhuCapMoiCa = ?, HanMucUng = ?, GhiChu = ?, UpdatedAt = GETDATE() " +
                "WHEN NOT MATCHED THEN INSERT (AccountID, CoSoID, LuongCoBan, PhuCapMoiCa, HanMucUng, GhiChu) " +
                "  VALUES (?, ?, ?, ?, ?, ?);";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, ch.getAccountId());
            ps.setInt(2, ch.getCoSoId());
            ps.setBigDecimal(3, nz(ch.getLuongCoBan()));
            ps.setBigDecimal(4, nz(ch.getPhuCapMoiCa()));
            ps.setBigDecimal(5, nz(ch.getHanMucUng()));
            ps.setNString(6, ch.getGhiChu());
            ps.setInt(7, ch.getAccountId());
            ps.setInt(8, ch.getCoSoId());
            ps.setBigDecimal(9, nz(ch.getLuongCoBan()));
            ps.setBigDecimal(10, nz(ch.getPhuCapMoiCa()));
            ps.setBigDecimal(11, nz(ch.getHanMucUng()));
            ps.setNString(12, ch.getGhiChu());
            ps.executeUpdate();
        }
    }

    private static CauHinhLuong map(ResultSet rs) throws Exception {
        CauHinhLuong ch = new CauHinhLuong();
        ch.setCauHinhLuongId(rs.getInt("CauHinhLuongID"));
        ch.setAccountId(rs.getInt("AccountID"));
        ch.setCoSoId(rs.getInt("CoSoID"));
        ch.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
        ch.setPhuCapMoiCa(rs.getBigDecimal("PhuCapMoiCa"));
        ch.setHanMucUng(rs.getBigDecimal("HanMucUng"));
        ch.setGhiChu(rs.getNString("GhiChu"));
        ch.setCreatedAt(toLdt(rs.getTimestamp("CreatedAt")));
        ch.setUpdatedAt(toLdt(rs.getTimestamp("UpdatedAt")));
        return ch;
    }

    private static java.time.LocalDateTime toLdt(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }

    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/CauHinhLuongDAO.java src/main/java/org/example/dao/impl/CauHinhLuongDAOImpl.java
git commit -m "feat(luong): CauHinhLuongDAO"
```

---

### Task 7: `KyLuongDAO`

**Files:**
- Create: `src/main/java/org/example/dao/KyLuongDAO.java`
- Create: `src/main/java/org/example/dao/impl/KyLuongDAOImpl.java`

**Interfaces:**
- Consumes: `model.KyLuong` (Task 4).
- Produces:
  - `int insert(KyLuong ky) throws Exception` — trả về `KyLuongID` vừa sinh.
  - `KyLuong findById(int kyLuongId, int coSoId) throws Exception` — luôn kèm `coSoId` để chống IDOR; null nếu không thuộc cơ sở.
  - `List<KyLuong> listByCoSo(int coSoId) throws Exception` — kèm `soNhanVien`, `tongChi` tổng hợp từ `BangLuong`.
  - `void updateTrangThai(int kyLuongId, int coSoId, String trangThai) throws Exception`
  - `KyLuong findKyPhatLuongHomNay(int coSoId, LocalDate homNay) throws Exception` — null nếu hôm nay không phải ngày phát lương của kỳ nào.

- [ ] **Step 1: Tạo interface**

```java
package org.example.dao;

import org.example.model.KyLuong;
import java.time.LocalDate;
import java.util.List;

public interface KyLuongDAO {

    /** Tạo kỳ lương mới, trả về KyLuongID vừa sinh. */
    int insert(KyLuong ky) throws Exception;

    /** Lấy kỳ lương THUỘC cơ sở này; trả null nếu id không tồn tại hoặc thuộc cơ sở khác (chống IDOR). */
    KyLuong findById(int kyLuongId, int coSoId) throws Exception;

    /** Danh sách kỳ lương của cơ sở, mới nhất trước, kèm số nhân viên và tổng chi đã tính. */
    List<KyLuong> listByCoSo(int coSoId) throws Exception;

    /** Đổi trạng thái kỳ (Draft | DangTinh | DaPhat). Chỉ tác động nếu kỳ thuộc cơ sở. */
    void updateTrangThai(int kyLuongId, int coSoId, String trangThai) throws Exception;

    /** Kỳ có NgayPhatLuong đúng bằng homNay, dùng để bật banner nhắc phát lương. Null nếu không có. */
    KyLuong findKyPhatLuongHomNay(int coSoId, LocalDate homNay) throws Exception;
}
```

- [ ] **Step 2: Tạo implementation**

```java
package org.example.dao.impl;

import org.example.dao.KyLuongDAO;
import org.example.model.KyLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class KyLuongDAOImpl implements KyLuongDAO {

    @Override
    public int insert(KyLuong ky) throws Exception {
        String sql = "INSERT INTO KyLuong (CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, TrangThai, CreatedBy) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ky.getCoSoId());
            ps.setNString(2, ky.getTenKy());
            ps.setDate(3, Date.valueOf(ky.getNgayBatDau()));
            ps.setDate(4, Date.valueOf(ky.getNgayKetThuc()));
            ps.setDate(5, Date.valueOf(ky.getNgayPhatLuong()));
            ps.setString(6, ky.getTrangThai() == null ? KyLuong.DRAFT : ky.getTrangThai());
            ps.setInt(7, ky.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    @Override
    public KyLuong findById(int kyLuongId, int coSoId) throws Exception {
        String sql = "SELECT KyLuongID, CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, " +
                "TrangThai, CreatedBy, CreatedAt FROM KyLuong WHERE KyLuongID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, kyLuongId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public List<KyLuong> listByCoSo(int coSoId) throws Exception {
        String sql = "SELECT k.KyLuongID, k.CoSoID, k.TenKy, k.NgayBatDau, k.NgayKetThuc, k.NgayPhatLuong, " +
                "       k.TrangThai, k.CreatedBy, k.CreatedAt, " +
                "       (SELECT COUNT(*) FROM BangLuong b WHERE b.KyLuongID = k.KyLuongID) AS SoNhanVien, " +
                "       (SELECT ISNULL(SUM(b.TongLuongThuc), 0) FROM BangLuong b WHERE b.KyLuongID = k.KyLuongID) AS TongChi " +
                "FROM KyLuong k WHERE k.CoSoID = ? ORDER BY k.NgayBatDau DESC, k.KyLuongID DESC";
        List<KyLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    KyLuong ky = map(rs);
                    ky.setSoNhanVien(rs.getInt("SoNhanVien"));
                    ky.setTongChi(rs.getBigDecimal("TongChi"));
                    out.add(ky);
                }
            }
        }
        return out;
    }

    @Override
    public void updateTrangThai(int kyLuongId, int coSoId, String trangThai) throws Exception {
        String sql = "UPDATE KyLuong SET TrangThai = ? WHERE KyLuongID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, kyLuongId);
            ps.setInt(3, coSoId);
            ps.executeUpdate();
        }
    }

    @Override
    public KyLuong findKyPhatLuongHomNay(int coSoId, LocalDate homNay) throws Exception {
        String sql = "SELECT TOP 1 KyLuongID, CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, " +
                "TrangThai, CreatedBy, CreatedAt FROM KyLuong " +
                "WHERE CoSoID = ? AND NgayPhatLuong = ? ORDER BY KyLuongID DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(homNay));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private static KyLuong map(ResultSet rs) throws SQLException {
        KyLuong ky = new KyLuong();
        ky.setKyLuongId(rs.getInt("KyLuongID"));
        ky.setCoSoId(rs.getInt("CoSoID"));
        ky.setTenKy(rs.getNString("TenKy"));
        ky.setNgayBatDau(rs.getDate("NgayBatDau").toLocalDate());
        ky.setNgayKetThuc(rs.getDate("NgayKetThuc").toLocalDate());
        ky.setNgayPhatLuong(rs.getDate("NgayPhatLuong").toLocalDate());
        ky.setTrangThai(rs.getString("TrangThai"));
        ky.setCreatedBy(rs.getInt("CreatedBy"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        ky.setCreatedAt(ts == null ? null : ts.toLocalDateTime());
        ky.setTongChi(BigDecimal.ZERO);
        return ky;
    }
}
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/KyLuongDAO.java src/main/java/org/example/dao/impl/KyLuongDAOImpl.java
git commit -m "feat(luong): KyLuongDAO"
```

---

### Task 8: `BangLuongDAO`

**Files:**
- Create: `src/main/java/org/example/dao/BangLuongDAO.java`
- Create: `src/main/java/org/example/dao/impl/BangLuongDAOImpl.java`

**Interfaces:**
- Consumes: `model.BangLuong` (Task 4), bảng `BangLuong`/`KyLuong`/`Accounts`.
- Produces:
  - `void upsert(BangLuong bl) throws Exception`
  - `List<BangLuong> listByKy(int kyLuongId) throws Exception` — join `Accounts` lấy `hoTen`, `avatarUrl`, `maNganHang`, `soTaiKhoan`, `qrImagePath`.
  - `BangLuong findById(int bangLuongId, int coSoId) throws Exception` — join `KyLuong` để lọc theo cơ sở (chống IDOR).
  - `void updateTrangThai(int bangLuongId, String trangThai) throws Exception`
  - `void updateTrangThaiTheoKy(int kyLuongId, String trangThai) throws Exception`
  - `List<BangLuong> listByAccount(int accountId) throws Exception` — lịch sử lương của nhân viên, kèm `tenKy`, `ngayPhatLuong`.

- [ ] **Step 1: Tạo interface**

```java
package org.example.dao;

import org.example.model.BangLuong;
import java.util.List;

public interface BangLuongDAO {

    /** Tạo mới hoặc ghi đè dòng lương của (kỳ, nhân viên). Dùng khi manager bấm "Tính lương". */
    void upsert(BangLuong bl) throws Exception;

    /** Toàn bộ dòng lương của một kỳ, kèm thông tin hiển thị và tài khoản ngân hàng của nhân viên. */
    List<BangLuong> listByKy(int kyLuongId) throws Exception;

    /** Một dòng lương, chỉ trả về nếu kỳ lương của nó thuộc coSoId (chống IDOR). */
    BangLuong findById(int bangLuongId, int coSoId) throws Exception;

    /** Đổi trạng thái một dòng lương (ví dụ khi manager xác nhận đã chuyển khoản). */
    void updateTrangThai(int bangLuongId, String trangThai) throws Exception;

    /** Đổi trạng thái toàn bộ dòng lương của một kỳ (khi manager chốt phát lương). */
    void updateTrangThaiTheoKy(int kyLuongId, String trangThai) throws Exception;

    /** Lịch sử bảng lương của một nhân viên qua các kỳ, mới nhất trước. */
    List<BangLuong> listByAccount(int accountId) throws Exception;
}
```

- [ ] **Step 2: Tạo implementation**

```java
package org.example.dao.impl;

import org.example.dao.BangLuongDAO;
import org.example.model.BangLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BangLuongDAOImpl implements BangLuongDAO {

    @Override
    public void upsert(BangLuong bl) throws Exception {
        // Tính lại kỳ đã tính trước đó phải ghi đè, không nhân bản dòng — khoá bởi
        // UNIQUE(KyLuongID, AccountID).
        String sql = "MERGE BangLuong AS t " +
                "USING (SELECT ? AS KyLuongID, ? AS AccountID) AS s " +
                "  ON t.KyLuongID = s.KyLuongID AND t.AccountID = s.AccountID " +
                "WHEN MATCHED THEN UPDATE SET " +
                "  LuongCoBan = ?, TongPhuCap = ?, TongKhauTru = ?, TongLuongThuc = ?, " +
                "  SoCaLamViec = ?, TrangThai = ?, GhiChu = ? " +
                "WHEN NOT MATCHED THEN INSERT " +
                "  (KyLuongID, AccountID, LuongCoBan, TongPhuCap, TongKhauTru, TongLuongThuc, SoCaLamViec, TrangThai, GhiChu) " +
                "  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bl.getKyLuongId());
            ps.setInt(2, bl.getAccountId());
            ps.setBigDecimal(3, nz(bl.getLuongCoBan()));
            ps.setBigDecimal(4, nz(bl.getTongPhuCap()));
            ps.setBigDecimal(5, nz(bl.getTongKhauTru()));
            ps.setBigDecimal(6, nz(bl.getTongLuongThuc()));
            ps.setInt(7, bl.getSoCaLamViec());
            ps.setString(8, bl.getTrangThai());
            ps.setNString(9, bl.getGhiChu());
            ps.setInt(10, bl.getKyLuongId());
            ps.setInt(11, bl.getAccountId());
            ps.setBigDecimal(12, nz(bl.getLuongCoBan()));
            ps.setBigDecimal(13, nz(bl.getTongPhuCap()));
            ps.setBigDecimal(14, nz(bl.getTongKhauTru()));
            ps.setBigDecimal(15, nz(bl.getTongLuongThuc()));
            ps.setInt(16, bl.getSoCaLamViec());
            ps.setString(17, bl.getTrangThai());
            ps.setNString(18, bl.getGhiChu());
            ps.executeUpdate();
        }
    }

    @Override
    public List<BangLuong> listByKy(int kyLuongId) throws Exception {
        String sql = "SELECT b.*, a.FullName, a.AvatarUrl, a.MaNganHang, a.SoTaiKhoan, a.QrImagePath " +
                "FROM BangLuong b JOIN Accounts a ON a.AccountID = b.AccountID " +
                "WHERE b.KyLuongID = ? ORDER BY a.FullName";
        List<BangLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, kyLuongId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapWithAccount(rs));
            }
        }
        return out;
    }

    @Override
    public BangLuong findById(int bangLuongId, int coSoId) throws Exception {
        // JOIN KyLuong để chắc chắn dòng lương này thuộc cơ sở của manager đang đăng nhập.
        String sql = "SELECT b.*, a.FullName, a.AvatarUrl, a.MaNganHang, a.SoTaiKhoan, a.QrImagePath " +
                "FROM BangLuong b " +
                "JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "JOIN Accounts a ON a.AccountID = b.AccountID " +
                "WHERE b.BangLuongID = ? AND k.CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bangLuongId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapWithAccount(rs) : null;
            }
        }
    }

    @Override
    public void updateTrangThai(int bangLuongId, String trangThai) throws Exception {
        String sql = "UPDATE BangLuong SET TrangThai = ? WHERE BangLuongID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, bangLuongId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateTrangThaiTheoKy(int kyLuongId, String trangThai) throws Exception {
        // Không ghi đè dòng đã xác nhận chuyển khoản — đó là trạng thái "tiến" hơn DaPhat.
        String sql = "UPDATE BangLuong SET TrangThai = ? WHERE KyLuongID = ? AND TrangThai <> ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, kyLuongId);
            ps.setString(3, BangLuong.DA_CHUYEN);
            ps.executeUpdate();
        }
    }

    @Override
    public List<BangLuong> listByAccount(int accountId) throws Exception {
        String sql = "SELECT b.*, k.TenKy, k.NgayPhatLuong " +
                "FROM BangLuong b JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "WHERE b.AccountID = ? ORDER BY k.NgayBatDau DESC, b.BangLuongID DESC";
        List<BangLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BangLuong bl = mapCore(rs);
                    bl.setTenKy(rs.getNString("TenKy"));
                    bl.setNgayPhatLuong(rs.getDate("NgayPhatLuong").toLocalDate());
                    out.add(bl);
                }
            }
        }
        return out;
    }

    private static BangLuong mapWithAccount(ResultSet rs) throws SQLException {
        BangLuong bl = mapCore(rs);
        bl.setHoTen(rs.getNString("FullName"));
        bl.setAvatarUrl(rs.getNString("AvatarUrl"));
        bl.setMaNganHang(rs.getString("MaNganHang"));
        bl.setSoTaiKhoan(rs.getString("SoTaiKhoan"));
        bl.setQrImagePath(rs.getNString("QrImagePath"));
        return bl;
    }

    private static BangLuong mapCore(ResultSet rs) throws SQLException {
        BangLuong bl = new BangLuong();
        bl.setBangLuongId(rs.getInt("BangLuongID"));
        bl.setKyLuongId(rs.getInt("KyLuongID"));
        bl.setAccountId(rs.getInt("AccountID"));
        bl.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
        bl.setTongPhuCap(rs.getBigDecimal("TongPhuCap"));
        bl.setTongKhauTru(rs.getBigDecimal("TongKhauTru"));
        bl.setTongLuongThuc(rs.getBigDecimal("TongLuongThuc"));
        bl.setSoCaLamViec(rs.getInt("SoCaLamViec"));
        bl.setTrangThai(rs.getString("TrangThai"));
        bl.setGhiChu(rs.getNString("GhiChu"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        bl.setCreatedAt(ts == null ? null : ts.toLocalDateTime());
        return bl;
    }

    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/BangLuongDAO.java src/main/java/org/example/dao/impl/BangLuongDAOImpl.java
git commit -m "feat(luong): BangLuongDAO"
```

---

### Task 9: `YeuCauUngLuongDAO`

**Files:**
- Create: `src/main/java/org/example/dao/YeuCauUngLuongDAO.java`
- Create: `src/main/java/org/example/dao/impl/YeuCauUngLuongDAOImpl.java`

**Interfaces:**
- Consumes: `model.YeuCauUngLuong` (Task 4).
- Produces:
  - `int insert(YeuCauUngLuong yc) throws Exception`
  - `List<YeuCauUngLuong> listByAccount(int accountId) throws Exception`
  - `List<YeuCauUngLuong> listByCoSo(int coSoId, String trangThai) throws Exception` — `trangThai` null = lấy tất cả.
  - `YeuCauUngLuong findById(int id, int coSoId) throws Exception`
  - `boolean xuLy(int id, int coSoId, String trangThaiMoi, String ghiChuQuanLy, int xuLyBy) throws Exception` — chỉ đổi được khi đang `ChoDuyet`; trả `false` nếu đã bị xử lý (chống double-approve khi bấm 2 lần).
  - `boolean huyBoiNhanVien(int id, int accountId) throws Exception` — chỉ chủ sở hữu, chỉ khi `ChoDuyet`.
  - `BigDecimal tongDaDuyetTrongKhoang(int accountId, LocalDate tuNgay, LocalDate denNgay) throws Exception`
  - `BigDecimal tongDaDuyetChuaKhauTru(int accountId) throws Exception` — dùng để validate hạn mức ứng còn lại.

- [ ] **Step 1: Tạo interface**

```java
package org.example.dao;

import org.example.model.YeuCauUngLuong;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface YeuCauUngLuongDAO {

    /** Tạo yêu cầu ứng lương mới (trạng thái ChoDuyet), trả về ID vừa sinh. */
    int insert(YeuCauUngLuong yc) throws Exception;

    /** Lịch sử yêu cầu ứng của một nhân viên, mới nhất trước. */
    List<YeuCauUngLuong> listByAccount(int accountId) throws Exception;

    /** Yêu cầu ứng của cả cơ sở; trangThai = null nghĩa là không lọc. */
    List<YeuCauUngLuong> listByCoSo(int coSoId, String trangThai) throws Exception;

    /** Một yêu cầu THUỘC cơ sở này; null nếu không tồn tại hoặc thuộc cơ sở khác. */
    YeuCauUngLuong findById(int id, int coSoId) throws Exception;

    /**
     * Manager duyệt/từ chối. Chỉ thành công khi yêu cầu còn ở trạng thái ChoDuyet —
     * trả false nếu đã bị xử lý trước đó (chống bấm duyệt hai lần).
     */
    boolean xuLy(int id, int coSoId, String trangThaiMoi, String ghiChuQuanLy, int xuLyBy) throws Exception;

    /** Nhân viên tự huỷ yêu cầu của chính mình khi còn ChoDuyet. */
    boolean huyBoiNhanVien(int id, int accountId) throws Exception;

    /** Tổng tiền đã DUYỆT trong khoảng ngày (inclusive) — chính là TongKhauTru của kỳ. */
    BigDecimal tongDaDuyetTrongKhoang(int accountId, LocalDate tuNgay, LocalDate denNgay) throws Exception;

    /** Tổng tiền đã duyệt nhưng CHƯA bị khấu trừ vào kỳ lương nào đã phát — dùng để kiểm hạn mức. */
    BigDecimal tongDaDuyetChuaKhauTru(int accountId) throws Exception;
}
```

- [ ] **Step 2: Tạo implementation**

```java
package org.example.dao.impl;

import org.example.dao.YeuCauUngLuongDAO;
import org.example.model.YeuCauUngLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class YeuCauUngLuongDAOImpl implements YeuCauUngLuongDAO {

    private static final String BASE_SELECT =
            "SELECT y.YeuCauUngLuongID, y.AccountID, y.CoSoID, y.SoTienUng, y.LyDo, y.TrangThai, " +
            "       y.GhiChuQuanLy, y.XuLyBy, y.NgayXuLy, y.CreatedAt, " +
            "       a.FullName AS HoTen, x.FullName AS TenNguoiXuLy " +
            "FROM YeuCauUngLuong y " +
            "JOIN Accounts a ON a.AccountID = y.AccountID " +
            "LEFT JOIN Accounts x ON x.AccountID = y.XuLyBy ";

    @Override
    public int insert(YeuCauUngLuong yc) throws Exception {
        String sql = "INSERT INTO YeuCauUngLuong (AccountID, CoSoID, SoTienUng, LyDo, TrangThai) " +
                "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, yc.getAccountId());
            ps.setInt(2, yc.getCoSoId());
            ps.setBigDecimal(3, yc.getSoTienUng());
            ps.setNString(4, yc.getLyDo());
            ps.setString(5, YeuCauUngLuong.CHO_DUYET);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    @Override
    public List<YeuCauUngLuong> listByAccount(int accountId) throws Exception {
        String sql = BASE_SELECT + "WHERE y.AccountID = ? ORDER BY y.CreatedAt DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return readAll(ps);
        }
    }

    @Override
    public List<YeuCauUngLuong> listByCoSo(int coSoId, String trangThai) throws Exception {
        String sql = BASE_SELECT + "WHERE y.CoSoID = ? " +
                (trangThai == null ? "" : "AND y.TrangThai = ? ") +
                "ORDER BY CASE WHEN y.TrangThai = 'ChoDuyet' THEN 0 ELSE 1 END, y.CreatedAt DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            if (trangThai != null) ps.setString(2, trangThai);
            return readAll(ps);
        }
    }

    @Override
    public YeuCauUngLuong findById(int id, int coSoId) throws Exception {
        String sql = BASE_SELECT + "WHERE y.YeuCauUngLuongID = ? AND y.CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public boolean xuLy(int id, int coSoId, String trangThaiMoi, String ghiChuQuanLy, int xuLyBy) throws Exception {
        // Điều kiện TrangThai = 'ChoDuyet' nằm TRONG câu UPDATE: nếu 2 request cùng bấm duyệt,
        // chỉ một request có rowsAffected = 1, request còn lại nhận 0 và báo lỗi.
        String sql = "UPDATE YeuCauUngLuong " +
                "SET TrangThai = ?, GhiChuQuanLy = ?, XuLyBy = ?, NgayXuLy = GETDATE() " +
                "WHERE YeuCauUngLuongID = ? AND CoSoID = ? AND TrangThai = 'ChoDuyet'";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThaiMoi);
            ps.setNString(2, ghiChuQuanLy);
            ps.setInt(3, xuLyBy);
            ps.setInt(4, id);
            ps.setInt(5, coSoId);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public boolean huyBoiNhanVien(int id, int accountId) throws Exception {
        String sql = "UPDATE YeuCauUngLuong SET TrangThai = 'DaHuy', NgayXuLy = GETDATE() " +
                "WHERE YeuCauUngLuongID = ? AND AccountID = ? AND TrangThai = 'ChoDuyet'";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, accountId);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public BigDecimal tongDaDuyetTrongKhoang(int accountId, LocalDate tuNgay, LocalDate denNgay) throws Exception {
        // CAST CreatedAt về DATE để so khoảng ngày inclusive cả ngày cuối kỳ.
        String sql = "SELECT ISNULL(SUM(SoTienUng), 0) FROM YeuCauUngLuong " +
                "WHERE AccountID = ? AND TrangThai = 'DaDuyet' " +
                "  AND CAST(CreatedAt AS DATE) BETWEEN ? AND ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(tuNgay));
            ps.setDate(3, Date.valueOf(denNgay));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    @Override
    public BigDecimal tongDaDuyetChuaKhauTru(int accountId) throws Exception {
        // "Chưa khấu trừ" = chưa rơi vào kỳ lương nào đã phát (KyLuong.TrangThai = 'DaPhat').
        String sql = "SELECT ISNULL(SUM(y.SoTienUng), 0) FROM YeuCauUngLuong y " +
                "WHERE y.AccountID = ? AND y.TrangThai IN ('ChoDuyet', 'DaDuyet') " +
                "  AND NOT EXISTS ( " +
                "    SELECT 1 FROM BangLuong b JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "    WHERE b.AccountID = y.AccountID AND k.TrangThai = 'DaPhat' " +
                "      AND CAST(y.CreatedAt AS DATE) BETWEEN k.NgayBatDau AND k.NgayKetThuc)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private static List<YeuCauUngLuong> readAll(PreparedStatement ps) throws SQLException {
        List<YeuCauUngLuong> out = new ArrayList<>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(map(rs));
        }
        return out;
    }

    private static YeuCauUngLuong map(ResultSet rs) throws SQLException {
        YeuCauUngLuong yc = new YeuCauUngLuong();
        yc.setYeuCauUngLuongId(rs.getInt("YeuCauUngLuongID"));
        yc.setAccountId(rs.getInt("AccountID"));
        yc.setCoSoId(rs.getInt("CoSoID"));
        yc.setSoTienUng(rs.getBigDecimal("SoTienUng"));
        yc.setLyDo(rs.getNString("LyDo"));
        yc.setTrangThai(rs.getString("TrangThai"));
        yc.setGhiChuQuanLy(rs.getNString("GhiChuQuanLy"));
        int xuLyBy = rs.getInt("XuLyBy");
        yc.setXuLyBy(rs.wasNull() ? null : xuLyBy);
        Timestamp nx = rs.getTimestamp("NgayXuLy");
        yc.setNgayXuLy(nx == null ? null : nx.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("CreatedAt");
        yc.setCreatedAt(ca == null ? null : ca.toLocalDateTime());
        yc.setHoTen(rs.getNString("HoTen"));
        yc.setTenNguoiXuLy(rs.getNString("TenNguoiXuLy"));
        return yc;
    }
}
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/YeuCauUngLuongDAO.java src/main/java/org/example/dao/impl/YeuCauUngLuongDAOImpl.java
git commit -m "feat(luong): YeuCauUngLuongDAO"
```

---

### Task 10: `TaiKhoan.qrImagePath` + cập nhật thông tin ngân hàng của nhân viên

**Files:**
- Modify: `src/main/java/org/example/model/TaiKhoan.java` — thêm field + getter/setter.
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java` — thêm 2 method.
- Modify: `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java` — implement bằng JDBC.

**Interfaces:**
- Consumes: cột `Accounts.QrImagePath` (Task 1).
- Produces:
  - `TaiKhoan.getQrImagePath()` / `setQrImagePath(String)`
  - `void updateBankInfo(int accountId, String maNganHang, String soTaiKhoan) throws Exception`
  - `void updateQrImagePath(int accountId, String qrImagePath) throws Exception`

- [ ] **Step 1: Thêm field vào `TaiKhoan`**

Trong `src/main/java/org/example/model/TaiKhoan.java`, ngay sau khai báo field `soTaiKhoan` (`@Column(name = "SoTaiKhoan")`), thêm:

```java
    @Column(name = "QrImagePath")
    private String qrImagePath;
```

Và thêm getter/setter cạnh `getSoTaiKhoan()`:

```java
    /** Đường dẫn tương đối tới ảnh QR ngân hàng tĩnh nhân viên tự upload, ví dụ "nhan-vien-qr/12/<uuid>.png". */
    public String getQrImagePath() {
        return qrImagePath;
    }

    public void setQrImagePath(String qrImagePath) {
        this.qrImagePath = qrImagePath;
    }
```

- [ ] **Step 2: Thêm 2 method vào interface `TaiKhoanDAO`**

Thêm vào cuối interface:

```java
    /** Nhân viên tự cập nhật ngân hàng nhận lương. Truyền null/blank để xoá thông tin. */
    void updateBankInfo(int accountId, String maNganHang, String soTaiKhoan) throws Exception;

    /** Lưu đường dẫn ảnh QR tĩnh của nhân viên; truyền null để gỡ ảnh. */
    void updateQrImagePath(int accountId, String qrImagePath) throws Exception;
```

- [ ] **Step 3: Implement trong `TaiKhoanDAOImpl`**

```java
    @Override
    public void updateBankInfo(int accountId, String maNganHang, String soTaiKhoan) throws Exception {
        String sql = "UPDATE Accounts SET MaNganHang = ?, SoTaiKhoan = ? WHERE AccountID = ?";
        try (java.sql.Connection c = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, blankToNull(maNganHang));
            ps.setString(2, blankToNull(soTaiKhoan));
            ps.setInt(3, accountId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateQrImagePath(int accountId, String qrImagePath) throws Exception {
        String sql = "UPDATE Accounts SET QrImagePath = ? WHERE AccountID = ?";
        try (java.sql.Connection c = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setNString(1, blankToNull(qrImagePath));
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }
    }

    /** Chuỗi rỗng trong cột ngân hàng dễ gây QR hỏng — lưu NULL cho rõ ràng. */
    private static String blankToNull(String v) {
        return (v == null || v.isBlank()) ? null : v.trim();
    }
```

- [ ] **Step 4: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/model/TaiKhoan.java src/main/java/org/example/dao/TaiKhoanDAO.java src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java
git commit -m "feat(luong): TaiKhoan.qrImagePath + cập nhật tài khoản ngân hàng nhân viên"
```

---

## Phase 3 — Service layer

### Task 11: `UngLuongValidator` — validate số tiền ứng (TDD)

**Files:**
- Create: `src/main/java/org/example/service/manager/UngLuongValidator.java`
- Test: `src/test/java/org/example/service/UngLuongValidationTest.java`

**Interfaces:**
- Consumes: không có (thuần).
- Produces: `static String kiemTra(BigDecimal soTienUng, BigDecimal hanMucUng, BigDecimal daUngChuaKhauTru)` — trả `null` nếu hợp lệ, ngược lại trả câu thông báo lỗi tiếng Việt để hiển thị thẳng cho nhân viên.

- [ ] **Step 1: Viết test thất bại**

```java
package org.example.service;

import org.example.service.manager.UngLuongValidator;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Quy tắc ứng lương (spec §6): số tiền ứng phải > 0 và tổng đã ứng chưa khấu trừ
 * cộng lần ứng này không được vượt HanMucUng trong cấu hình lương.
 */
class UngLuongValidationTest {

    @Test
    void trongHanMuc_hopLe() {
        assertNull(UngLuongValidator.kiemTra(
                new BigDecimal("500000"), new BigDecimal("2000000"), new BigDecimal("1000000")));
    }

    @Test
    void dungBangHanMuc_hopLe() {
        assertNull(UngLuongValidator.kiemTra(
                new BigDecimal("1000000"), new BigDecimal("2000000"), new BigDecimal("1000000")));
    }

    @Test
    void vuotHanMuc_baoLoi() {
        String loi = UngLuongValidator.kiemTra(
                new BigDecimal("1500000"), new BigDecimal("2000000"), new BigDecimal("1000000"));
        assertNotNull(loi);
        assertTrue(loi.contains("hạn mức"), loi);
    }

    @Test
    void soTienKhongDuong_baoLoi() {
        assertNotNull(UngLuongValidator.kiemTra(BigDecimal.ZERO, new BigDecimal("2000000"), BigDecimal.ZERO));
        assertNotNull(UngLuongValidator.kiemTra(new BigDecimal("-1"), new BigDecimal("2000000"), BigDecimal.ZERO));
        assertNotNull(UngLuongValidator.kiemTra(null, new BigDecimal("2000000"), BigDecimal.ZERO));
    }

    /** Manager chưa cấu hình hạn mức (= 0) thì nhân viên chưa được phép ứng. */
    @Test
    void hanMucChuaCauHinh_baoLoi() {
        String loi = UngLuongValidator.kiemTra(new BigDecimal("100000"), BigDecimal.ZERO, BigDecimal.ZERO);
        assertNotNull(loi);
        assertTrue(loi.contains("chưa được cấu hình"), loi);
    }

    @Test
    void hanMucNull_coiNhuChuaCauHinh() {
        assertNotNull(UngLuongValidator.kiemTra(new BigDecimal("100000"), null, BigDecimal.ZERO));
    }
}
```

- [ ] **Step 2: Chạy test để xác nhận FAIL**

```bash
mvn -o test -Dtest=UngLuongValidationTest
```

Kỳ vọng: FAIL — `cannot find symbol: class UngLuongValidator`.

- [ ] **Step 3: Viết implementation**

```java
package org.example.service.manager;

import org.example.util.LuongCalculator;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Quy tắc chấp nhận một yêu cầu ứng lương. Tách riêng khỏi service để test được
 * không cần DB — service chỉ có nhiệm vụ nạp số liệu rồi gọi vào đây.
 */
public final class UngLuongValidator {

    private UngLuongValidator() {}

    /**
     * @param soTienUng          số tiền nhân viên muốn ứng lần này
     * @param hanMucUng          CauHinhLuong.HanMucUng của nhân viên; 0/null = chưa cấu hình
     * @param daUngChuaKhauTru   tổng đã ứng (chờ duyệt + đã duyệt) chưa bị khấu trừ vào kỳ đã phát
     * @return null nếu hợp lệ; ngược lại là thông báo lỗi tiếng Việt hiển thị được cho nhân viên
     */
    public static String kiemTra(BigDecimal soTienUng, BigDecimal hanMucUng, BigDecimal daUngChuaKhauTru) {
        if (soTienUng == null || soTienUng.signum() <= 0) {
            return "Số tiền ứng phải lớn hơn 0.";
        }
        BigDecimal hanMuc = LuongCalculator.chuanHoa(hanMucUng);
        if (hanMuc.signum() <= 0) {
            return "Hạn mức ứng lương của bạn chưa được cấu hình. Vui lòng liên hệ quản lý.";
        }
        BigDecimal daUng = LuongCalculator.chuanHoa(daUngChuaKhauTru);
        BigDecimal conLai = hanMuc.subtract(daUng);
        if (LuongCalculator.chuanHoa(soTienUng).compareTo(conLai) > 0) {
            return "Số tiền vượt hạn mức ứng còn lại (" + dinhDang(conLai) + " đ).";
        }
        return null;
    }

    private static String dinhDang(BigDecimal v) {
        if (v.signum() < 0) v = BigDecimal.ZERO;
        return NumberFormat.getInstance(new Locale("vi", "VN")).format(v);
    }
}
```

- [ ] **Step 4: Chạy test để xác nhận PASS**

```bash
mvn -o test -Dtest=UngLuongValidationTest
```

Kỳ vọng: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/service/manager/UngLuongValidator.java src/test/java/org/example/service/UngLuongValidationTest.java
git commit -m "feat(luong): UngLuongValidator + test quy tắc hạn mức ứng"
```

---

### Task 12: `LuongService`

**Files:**
- Create: `src/main/java/org/example/service/manager/LuongService.java`

**Interfaces:**
- Consumes: `CauHinhLuongDAO`, `KyLuongDAO`, `BangLuongDAO`, `YeuCauUngLuongDAO`, `CaLamViecDAO.countCaHoanThanh`, `LuongCalculator`, `VietQrUrl`.
- Produces:
  - `List<CauHinhLuong> danhSachCauHinh(int coSoId)`
  - `void luuCauHinh(CauHinhLuong ch)`
  - `List<KyLuong> danhSachKy(int coSoId)`
  - `int taoKy(int coSoId, int managerId, String tenKy, LocalDate batDau, LocalDate ketThuc, LocalDate ngayPhat)`
  - `int tinhLuongChoKy(int kyLuongId, int coSoId)` — trả về số nhân viên đã tính.
  - `List<BangLuong> bangLuongCuaKy(int kyLuongId, int coSoId)` — có sẵn `qrDongUrl`.
  - `void chotPhatLuong(int kyLuongId, int coSoId)`
  - `boolean xacNhanDaChuyenKhoan(int bangLuongId, int coSoId)`
  - `KyLuong kyPhatLuongHomNay(int coSoId)`
  - `List<BangLuong> lichSuLuongCuaToi(int accountId)`

- [ ] **Step 1: Tạo service**

```java
package org.example.service.manager;

import org.example.dao.*;
import org.example.dao.impl.*;
import org.example.model.BangLuong;
import org.example.model.CauHinhLuong;
import org.example.model.KyLuong;
import org.example.util.LuongCalculator;
import org.example.util.VietQrUrl;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Nghiệp vụ kỳ lương của manager. Mọi phương thức nhận coSoId lấy từ session — service
 * KHÔNG tự suy ra cơ sở từ id truyền vào, đó là lớp chặn IDOR.
 */
public class LuongService {

    private final CauHinhLuongDAO cauHinhDAO = new CauHinhLuongDAOImpl();
    private final KyLuongDAO kyDAO = new KyLuongDAOImpl();
    private final BangLuongDAO bangDAO = new BangLuongDAOImpl();
    private final YeuCauUngLuongDAO ungDAO = new YeuCauUngLuongDAOImpl();
    private final CaLamViecDAO caDAO = new CaLamViecDAOImpl();

    public List<CauHinhLuong> danhSachCauHinh(int coSoId) throws Exception {
        return cauHinhDAO.listByCoSo(coSoId);
    }

    public void luuCauHinh(CauHinhLuong ch) throws Exception {
        cauHinhDAO.upsert(ch);
    }

    public List<KyLuong> danhSachKy(int coSoId) throws Exception {
        return kyDAO.listByCoSo(coSoId);
    }

    /**
     * Tạo kỳ lương mới. Ném IllegalArgumentException với thông báo tiếng Việt nếu khoảng
     * ngày không hợp lệ — servlet bắt và hiển thị lại cho manager.
     */
    public int taoKy(int coSoId, int managerId, String tenKy,
                     LocalDate batDau, LocalDate ketThuc, LocalDate ngayPhat) throws Exception {
        if (tenKy == null || tenKy.isBlank()) {
            throw new IllegalArgumentException("Tên kỳ lương không được để trống.");
        }
        if (batDau == null || ketThuc == null || ngayPhat == null) {
            throw new IllegalArgumentException("Vui lòng nhập đủ ngày bắt đầu, kết thúc và ngày phát lương.");
        }
        if (ketThuc.isBefore(batDau)) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
        }
        if (ngayPhat.isBefore(ketThuc)) {
            throw new IllegalArgumentException("Ngày phát lương phải từ ngày kết thúc kỳ trở đi.");
        }
        KyLuong ky = new KyLuong();
        ky.setCoSoId(coSoId);
        ky.setTenKy(tenKy.trim());
        ky.setNgayBatDau(batDau);
        ky.setNgayKetThuc(ketThuc);
        ky.setNgayPhatLuong(ngayPhat);
        ky.setTrangThai(KyLuong.DRAFT);
        ky.setCreatedBy(managerId);
        return kyDAO.insert(ky);
    }

    /**
     * Tính lại toàn bộ bảng lương của kỳ theo công thức spec §4. Chạy lại được nhiều lần
     * (upsert), nhưng kỳ đã phát thì bị khoá để không sửa số tiền sau khi đã chuyển khoản.
     *
     * @return số nhân viên đã được tính
     */
    public int tinhLuongChoKy(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        if (ky.isKhoa()) {
            throw new IllegalStateException("Kỳ lương đã phát, không thể tính lại.");
        }

        List<CauHinhLuong> dsCauHinh = cauHinhDAO.listByCoSo(coSoId);
        int dem = 0;
        for (CauHinhLuong ch : dsCauHinh) {
            // Nhân viên chưa được cấu hình lương (cả 3 khoản = 0) thì bỏ qua, không tạo
            // dòng lương 0 đồng gây nhiễu trang phát lương.
            if (LuongCalculator.chuanHoa(ch.getLuongCoBan()).signum() == 0
                    && LuongCalculator.chuanHoa(ch.getPhuCapMoiCa()).signum() == 0) {
                continue;
            }

            int soCa = caDAO.countCaHoanThanh(ch.getAccountId(), coSoId, ky.getNgayBatDau(), ky.getNgayKetThuc());
            BigDecimal phuCap = LuongCalculator.tongPhuCap(ch.getPhuCapMoiCa(), soCa);
            BigDecimal khauTru = ungDAO.tongDaDuyetTrongKhoang(ch.getAccountId(), ky.getNgayBatDau(), ky.getNgayKetThuc());
            BigDecimal thucNhan = LuongCalculator.tongLuongThuc(ch.getLuongCoBan(), phuCap, khauTru);

            BangLuong bl = new BangLuong();
            bl.setKyLuongId(kyLuongId);
            bl.setAccountId(ch.getAccountId());
            bl.setLuongCoBan(LuongCalculator.chuanHoa(ch.getLuongCoBan()));
            bl.setTongPhuCap(phuCap);
            bl.setTongKhauTru(LuongCalculator.chuanHoa(khauTru));
            bl.setTongLuongThuc(thucNhan);
            bl.setSoCaLamViec(soCa);
            bl.setTrangThai(BangLuong.DA_TINH);
            bangDAO.upsert(bl);
            dem++;
        }

        kyDAO.updateTrangThai(kyLuongId, coSoId, KyLuong.DANG_TINH);
        return dem;
    }

    /** Bảng lương của kỳ, đã gắn sẵn URL VietQR động cho trang phát lương. */
    public List<BangLuong> bangLuongCuaKy(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        List<BangLuong> ds = bangDAO.listByKy(kyLuongId);
        for (BangLuong bl : ds) {
            bl.setTenKy(ky.getTenKy());
            bl.setNgayPhatLuong(ky.getNgayPhatLuong());
            bl.setQrDongUrl(VietQrUrl.compact2(
                    bl.getMaNganHang(), bl.getSoTaiKhoan(), bl.getTongLuongThuc(),
                    "Luong " + khongDau(ky.getTenKy()), bl.getHoTen()));
        }
        return ds;
    }

    /** Chốt phát lương: khoá kỳ và đánh dấu mọi dòng lương là đã phát. */
    public void chotPhatLuong(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        bangDAO.updateTrangThaiTheoKy(kyLuongId, BangLuong.DA_PHAT);
        kyDAO.updateTrangThai(kyLuongId, coSoId, KyLuong.DA_PHAT);
    }

    /** Manager bấm "Đã chuyển khoản" cho một nhân viên. false nếu dòng lương không thuộc cơ sở. */
    public boolean xacNhanDaChuyenKhoan(int bangLuongId, int coSoId) throws Exception {
        BangLuong bl = bangDAO.findById(bangLuongId, coSoId);
        if (bl == null) return false;
        bangDAO.updateTrangThai(bangLuongId, BangLuong.DA_CHUYEN);
        return true;
    }

    /** Kỳ đến hạn phát lương hôm nay, để hiển thị banner nhắc. Null nếu không có. */
    public KyLuong kyPhatLuongHomNay(int coSoId) throws Exception {
        return kyDAO.findKyPhatLuongHomNay(coSoId, LocalDate.now());
    }

    /** Lịch sử bảng lương của một nhân viên (dùng cho trang staff/guard). */
    public List<BangLuong> lichSuLuongCuaToi(int accountId) throws Exception {
        return bangDAO.listByAccount(accountId);
    }

    /**
     * Bỏ dấu tiếng Việt cho nội dung chuyển khoản — app ngân hàng thường từ chối hoặc
     * hiển thị sai ký tự có dấu trong trường nội dung.
     */
    private static String khongDau(String s) {
        if (s == null) return "";
        String norm = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd').replace('Đ', 'D');
        return norm.replaceAll("[^A-Za-z0-9 ]", "").trim();
    }
}
```

- [ ] **Step 2: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/service/manager/LuongService.java
git commit -m "feat(luong): LuongService — tạo kỳ, tính lương, phát lương"
```

---

### Task 13: `UngLuongService`

**Files:**
- Create: `src/main/java/org/example/service/manager/UngLuongService.java`

**Interfaces:**
- Consumes: `YeuCauUngLuongDAO`, `CauHinhLuongDAO`, `UngLuongValidator`.
- Produces:
  - `int guiYeuCau(int accountId, int coSoId, BigDecimal soTien, String lyDo)` — ném `IllegalArgumentException` với message từ validator.
  - `List<YeuCauUngLuong> lichSuCuaToi(int accountId)`
  - `BigDecimal hanMucConLai(int accountId, int coSoId)`
  - `List<YeuCauUngLuong> danhSachChoManager(int coSoId, String trangThai)`
  - `boolean duyet(int id, int coSoId, int managerId, String ghiChu)`
  - `boolean tuChoi(int id, int coSoId, int managerId, String ghiChu)`
  - `boolean huy(int id, int accountId)`

- [ ] **Step 1: Tạo service**

```java
package org.example.service.manager;

import org.example.dao.CauHinhLuongDAO;
import org.example.dao.YeuCauUngLuongDAO;
import org.example.dao.impl.CauHinhLuongDAOImpl;
import org.example.dao.impl.YeuCauUngLuongDAOImpl;
import org.example.model.CauHinhLuong;
import org.example.model.YeuCauUngLuong;
import org.example.util.LuongCalculator;

import java.math.BigDecimal;
import java.util.List;

/** Nghiệp vụ ứng lương: nhân viên gửi yêu cầu, manager duyệt/từ chối. */
public class UngLuongService {

    private final YeuCauUngLuongDAO ungDAO = new YeuCauUngLuongDAOImpl();
    private final CauHinhLuongDAO cauHinhDAO = new CauHinhLuongDAOImpl();

    /**
     * Nhân viên gửi yêu cầu ứng. accountId/coSoId PHẢI lấy từ session.
     * @throws IllegalArgumentException nếu vi phạm hạn mức — message hiển thị thẳng cho nhân viên.
     */
    public int guiYeuCau(int accountId, int coSoId, BigDecimal soTien, String lyDo) throws Exception {
        CauHinhLuong ch = cauHinhDAO.findByAccount(accountId, coSoId);
        BigDecimal hanMuc = ch == null ? BigDecimal.ZERO : ch.getHanMucUng();
        BigDecimal daUng = ungDAO.tongDaDuyetChuaKhauTru(accountId);

        String loi = UngLuongValidator.kiemTra(soTien, hanMuc, daUng);
        if (loi != null) {
            throw new IllegalArgumentException(loi);
        }

        YeuCauUngLuong yc = new YeuCauUngLuong();
        yc.setAccountId(accountId);
        yc.setCoSoId(coSoId);
        yc.setSoTienUng(LuongCalculator.chuanHoa(soTien));
        yc.setLyDo(lyDo);
        yc.setTrangThai(YeuCauUngLuong.CHO_DUYET);
        return ungDAO.insert(yc);
    }

    public List<YeuCauUngLuong> lichSuCuaToi(int accountId) throws Exception {
        return ungDAO.listByAccount(accountId);
    }

    /** Hạn mức còn ứng được, hiển thị trên form để nhân viên biết trước khi nhập. Không âm. */
    public BigDecimal hanMucConLai(int accountId, int coSoId) throws Exception {
        CauHinhLuong ch = cauHinhDAO.findByAccount(accountId, coSoId);
        BigDecimal hanMuc = LuongCalculator.chuanHoa(ch == null ? null : ch.getHanMucUng());
        BigDecimal daUng = LuongCalculator.chuanHoa(ungDAO.tongDaDuyetChuaKhauTru(accountId));
        BigDecimal conLai = hanMuc.subtract(daUng);
        return conLai.signum() < 0 ? BigDecimal.ZERO : conLai;
    }

    public List<YeuCauUngLuong> danhSachChoManager(int coSoId, String trangThai) throws Exception {
        return ungDAO.listByCoSo(coSoId, trangThai);
    }

    /** false nếu yêu cầu không thuộc cơ sở hoặc đã được xử lý trước đó. */
    public boolean duyet(int id, int coSoId, int managerId, String ghiChu) throws Exception {
        return ungDAO.xuLy(id, coSoId, YeuCauUngLuong.DA_DUYET, ghiChu, managerId);
    }

    public boolean tuChoi(int id, int coSoId, int managerId, String ghiChu) throws Exception {
        return ungDAO.xuLy(id, coSoId, YeuCauUngLuong.TU_CHOI, ghiChu, managerId);
    }

    /** Nhân viên tự huỷ yêu cầu của chính mình; false nếu không phải chủ sở hữu hoặc đã xử lý. */
    public boolean huy(int id, int accountId) throws Exception {
        return ungDAO.huyBoiNhanVien(id, accountId);
    }
}
```

- [ ] **Step 2: Biên dịch và chạy toàn bộ test**

```bash
mvn -o test
```

Kỳ vọng: BUILD SUCCESS, không có test nào fail.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/service/manager/UngLuongService.java
git commit -m "feat(luong): UngLuongService — gửi/duyệt/từ chối/huỷ yêu cầu ứng lương"
```

---

## Phase 4 — Giao diện Manager

### Task 14: `LuongManagerServlet` — 4 trang manager

**Files:**
- Create: `src/main/java/org/example/controller/manager/LuongManagerServlet.java`

**Interfaces:**
- Consumes: `LuongService` (Task 12), `UngLuongService` (Task 13), `Constants.ROLE_MANAGER`.
- Produces: 4 URL và các request attribute mà JSP ở Task 15–18 đọc:
  - `GET /manager/luong` → `Luong.jsp`; attrs: `dsKy` (`List<KyLuong>`), `kyPhatHomNay` (`KyLuong`|null), `soUngChoDuyet` (int)
  - `GET /manager/luong/cau-hinh` → `CauHinhLuong.jsp`; attrs: `dsCauHinh` (`List<CauHinhLuong>`)
  - `POST /manager/luong/cau-hinh` → lưu rồi redirect về chính nó
  - `GET /manager/luong/phat?kyLuongId=N` → `PhatLuong.jsp`; attrs: `ky` (`KyLuong`), `dsBangLuong` (`List<BangLuong>`), `laNgayPhat` (boolean)
  - `POST /manager/luong` → action `tao-ky` | `tinh-luong` | `chot-phat`
  - `GET /manager/luong/ung-luong` → `DuyetUngLuong.jsp`; attrs: `dsYeuCau` (`List<YeuCauUngLuong>`), `locTrangThai` (String|null)

- [ ] **Step 1: Tạo servlet**

```java
package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.model.CauHinhLuong;
import org.example.model.KyLuong;
import org.example.model.TaiKhoan;
import org.example.model.YeuCauUngLuong;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Các trang quản lý lương của manager. Mọi thao tác đều lấy CoSoID từ session —
 * không bao giờ từ request param, nên manager không thể chạm dữ liệu cơ sở khác.
 */
@WebServlet({"/manager/luong", "/manager/luong/cau-hinh", "/manager/luong/phat", "/manager/luong/ung-luong"})
public class LuongManagerServlet extends HttpServlet {

    private final LuongService luongService = new LuongService();
    private final UngLuongService ungLuongService = new UngLuongService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/manager/luong/cau-hinh" -> {
                    req.setAttribute("dsCauHinh", luongService.danhSachCauHinh(coSoId));
                    req.getRequestDispatcher("/manager/CauHinhLuong.jsp").forward(req, resp);
                }
                case "/manager/luong/phat" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    KyLuong ky = null;
                    for (KyLuong k : luongService.danhSachKy(coSoId)) {
                        if (k.getKyLuongId() == kyLuongId) { ky = k; break; }
                    }
                    if (ky == null) {
                        req.getSession().setAttribute("flashError", "Kỳ lương không tồn tại.");
                        resp.sendRedirect(req.getContextPath() + "/manager/luong");
                        return;
                    }
                    req.setAttribute("ky", ky);
                    req.setAttribute("dsBangLuong", luongService.bangLuongCuaKy(kyLuongId, coSoId));
                    req.setAttribute("laNgayPhat", LocalDate.now().equals(ky.getNgayPhatLuong()));
                    req.getRequestDispatcher("/manager/PhatLuong.jsp").forward(req, resp);
                }
                case "/manager/luong/ung-luong" -> {
                    String loc = req.getParameter("trangThai");
                    if (loc != null && loc.isBlank()) loc = null;
                    req.setAttribute("dsYeuCau", ungLuongService.danhSachChoManager(coSoId, loc));
                    req.setAttribute("locTrangThai", loc);
                    req.getRequestDispatcher("/manager/DuyetUngLuong.jsp").forward(req, resp);
                }
                default -> {
                    req.setAttribute("dsKy", luongService.danhSachKy(coSoId));
                    req.setAttribute("kyPhatHomNay", luongService.kyPhatLuongHomNay(coSoId));
                    req.setAttribute("soUngChoDuyet",
                            ungLuongService.danhSachChoManager(coSoId, YeuCauUngLuong.CHO_DUYET).size());
                    req.getRequestDispatcher("/manager/Luong.jsp").forward(req, resp);
                }
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi tải trang lương", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();
        HttpSession session = req.getSession();

        try {
            if ("/manager/luong/cau-hinh".equals(req.getServletPath())) {
                luuCauHinh(req, coSoId);
                resp.sendRedirect(req.getContextPath() + "/manager/luong/cau-hinh");
                return;
            }

            String action = req.getParameter("action");
            switch (action == null ? "" : action) {
                case "tao-ky" -> {
                    int id = luongService.taoKy(coSoId, manager.getAccountId(),
                            req.getParameter("tenKy"),
                            parseDate(req.getParameter("ngayBatDau")),
                            parseDate(req.getParameter("ngayKetThuc")),
                            parseDate(req.getParameter("ngayPhatLuong")));
                    session.setAttribute("flashSuccess", "Đã tạo kỳ lương (mã #" + id + ").");
                }
                case "tinh-luong" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    int soNv = luongService.tinhLuongChoKy(kyLuongId, coSoId);
                    session.setAttribute("flashSuccess", "Đã tính lương cho " + soNv + " nhân viên.");
                }
                case "chot-phat" -> {
                    int kyLuongId = parseInt(req.getParameter("kyLuongId"), 0);
                    luongService.chotPhatLuong(kyLuongId, coSoId);
                    session.setAttribute("flashSuccess", "Đã chốt phát lương cho kỳ này.");
                }
                default -> session.setAttribute("flashError", "Hành động không hợp lệ.");
            }
        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý thao tác lương", e);
        }
        resp.sendRedirect(req.getContextPath() + "/manager/luong");
    }

    /** Lưu cấu hình lương cho MỘT nhân viên (form inline trên từng dòng bảng). */
    private void luuCauHinh(HttpServletRequest req, int coSoId) throws Exception {
        CauHinhLuong ch = new CauHinhLuong();
        ch.setAccountId(parseInt(req.getParameter("accountId"), 0));
        ch.setCoSoId(coSoId);
        ch.setLuongCoBan(parseTien(req.getParameter("luongCoBan")));
        ch.setPhuCapMoiCa(parseTien(req.getParameter("phuCapMoiCa")));
        ch.setHanMucUng(parseTien(req.getParameter("hanMucUng")));
        ch.setGhiChu(req.getParameter("ghiChu"));

        if (ch.getAccountId() <= 0) {
            req.getSession().setAttribute("flashError", "Thiếu thông tin nhân viên.");
            return;
        }
        // Chỉ cho lưu nếu nhân viên thật sự thuộc cơ sở của manager — listByCoSo là nguồn
        // sự thật duy nhất về "nhân viên của tôi".
        boolean thuocCoSo = luongService.danhSachCauHinh(coSoId).stream()
                .anyMatch(x -> x.getAccountId() == ch.getAccountId());
        if (!thuocCoSo) {
            req.getSession().setAttribute("flashError", "Không có quyền thao tác trên nhân viên này.");
            return;
        }

        luongService.luuCauHinh(ch);
        req.getSession().setAttribute("flashSuccess", "Đã lưu cấu hình lương.");
    }

    private static BigDecimal parseTien(String v) {
        if (v == null || v.isBlank()) return BigDecimal.ZERO;
        try {
            // Form có thể gửi "5.000.000" hoặc "5,000,000" — bỏ mọi ký tự phân cách.
            return new BigDecimal(v.replaceAll("[^0-9]", ""));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private static LocalDate parseDate(String v) {
        try {
            return LocalDate.parse(v);
        } catch (Exception e) {
            return null;
        }
    }

    private static int parseInt(String v, int fallback) {
        try {
            return Integer.parseInt(v);
        } catch (Exception e) {
            return fallback;
        }
    }

    private TaiKhoan getManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
```

- [ ] **Step 2: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/controller/manager/LuongManagerServlet.java
git commit -m "feat(luong): LuongManagerServlet — 4 trang quản lý lương"
```

---

### Task 15: `LuongManagerApiServlet` — API AJAX cho manager

**Files:**
- Create: `src/main/java/org/example/controller/manager/api/LuongManagerApiServlet.java`

**Interfaces:**
- Consumes: `LuongService`, `UngLuongService`.
- Produces: JSON `{"ok":true}` hoặc `{"ok":false,"error":"..."}` tại:
  - `POST /manager/api/luong/xac-nhan` — body form `bangLuongId`
  - `POST /manager/api/luong/duyet-ung` — body form `yeuCauId`, `hanhDong` (`duyet`|`tu-choi`), `ghiChu`

- [ ] **Step 1: Tạo servlet**

```java
package org.example.controller.manager.api;

import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.model.TaiKhoan;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * API AJAX của module lương. Trả JSON thuần; mọi thao tác ràng buộc theo CoSoID trong session.
 */
@WebServlet({"/manager/api/luong/xac-nhan", "/manager/api/luong/duyet-ung"})
public class LuongManagerApiServlet extends HttpServlet {

    private final LuongService luongService = new LuongService();
    private final UngLuongService ungLuongService = new UngLuongService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        TaiKhoan manager = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            write(resp, false, "Phiên đăng nhập đã hết hạn.");
            return;
        }
        int coSoId = manager.getCoSoId();

        try {
            if ("/manager/api/luong/xac-nhan".equals(req.getServletPath())) {
                int bangLuongId = Integer.parseInt(req.getParameter("bangLuongId"));
                boolean ok = luongService.xacNhanDaChuyenKhoan(bangLuongId, coSoId);
                if (ok) write(resp, true, null);
                else {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    write(resp, false, "Không có quyền thao tác trên bảng lương này.");
                }
                return;
            }

            int yeuCauId = Integer.parseInt(req.getParameter("yeuCauId"));
            String hanhDong = req.getParameter("hanhDong");
            String ghiChu = req.getParameter("ghiChu");
            boolean ok = "tu-choi".equals(hanhDong)
                    ? ungLuongService.tuChoi(yeuCauId, coSoId, manager.getAccountId(), ghiChu)
                    : ungLuongService.duyet(yeuCauId, coSoId, manager.getAccountId(), ghiChu);
            if (ok) write(resp, true, null);
            else {
                resp.setStatus(HttpServletResponse.SC_CONFLICT);
                write(resp, false, "Yêu cầu đã được xử lý trước đó hoặc không thuộc cơ sở của bạn.");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            write(resp, false, "Tham số không hợp lệ.");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            write(resp, false, "Lỗi hệ thống, vui lòng thử lại.");
        }
    }

    private static void write(HttpServletResponse resp, boolean ok, String error) throws IOException {
        JsonObject json = new JsonObject();
        json.addProperty("ok", ok);
        if (error != null) json.addProperty("error", error);
        try (PrintWriter out = resp.getWriter()) {
            out.print(json);
        }
    }
}
```

- [ ] **Step 2: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/controller/manager/api/LuongManagerApiServlet.java
git commit -m "feat(luong): API xác nhận chuyển khoản + duyệt ứng lương"
```

---

### Task 16: `Luong.jsp` — tổng quan kỳ lương

**Files:**
- Create: `src/main/webapp/manager/Luong.jsp`

**Interfaces:**
- Consumes: attrs từ Task 14 — `dsKy`, `kyPhatHomNay`, `soUngChoDuyet`; flash `sessionScope.flashSuccess` / `flashError`.
- Produces: form POST `/manager/luong` với `action=tao-ky` (`tenKy`, `ngayBatDau`, `ngayKetThuc`, `ngayPhatLuong`), `action=tinh-luong` và `action=chot-phat` (`kyLuongId`).

Ghi chú: `manager_head.jsp` tự chèn `_csrf` vào mọi form `method="post"` và tự gắn header `X-CSRF-Token` cho `fetch` POST — KHÔNG cần tự thêm.

- [ ] **Step 1: Tạo JSP**

```jsp
<%-- src/main/webapp/manager/Luong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Quản lý lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Quản lý lương" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <%-- Banner nhắc: hôm nay đúng ngày phát lương của một kỳ --%>
  <c:if test="${not empty kyPhatHomNay}">
    <div class="p-4 rounded-xl bg-amber-50 border border-amber-200 flex items-center justify-between gap-4">
      <div>
        <div class="font-bold text-amber-900">Hôm nay là ngày phát lương kỳ “${kyPhatHomNay.tenKy}”.</div>
        <div class="text-sm text-amber-800">Mở trang phát lương để chuyển khoản cho từng nhân viên.</div>
      </div>
      <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${kyPhatHomNay.kyLuongId}"
         class="px-4 py-2 rounded-lg bg-amber-500 text-white text-sm font-bold">Phát lương ngay</a>
    </div>
  </c:if>

  <div class="flex flex-wrap gap-3">
    <a href="${pageContext.request.contextPath}/manager/luong/cau-hinh"
       class="px-4 py-2 rounded-lg bg-white border border-violet-100 text-violet-700 text-sm font-bold">Cấu hình lương nhân viên</a>
    <a href="${pageContext.request.contextPath}/manager/luong/ung-luong"
       class="px-4 py-2 rounded-lg bg-white border border-violet-100 text-violet-700 text-sm font-bold">
      Yêu cầu ứng lương
      <c:if test="${soUngChoDuyet > 0}">
        <span class="ml-1 px-2 py-0.5 rounded-full bg-rose-500 text-white text-xs">${soUngChoDuyet}</span>
      </c:if>
    </a>
  </div>

  <%-- Tạo kỳ lương mới --%>
  <section class="bg-white border border-violet-100 rounded-2xl p-5">
    <h2 class="font-bold text-slate-800 mb-4">Tạo kỳ lương mới</h2>
    <form method="post" action="${pageContext.request.contextPath}/manager/luong"
          class="grid grid-cols-1 md:grid-cols-5 gap-3 items-end">
      <input type="hidden" name="action" value="tao-ky">
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Tên kỳ</span>
        <input name="tenKy" required placeholder="Tháng 8/2026"
               class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Từ ngày</span>
        <input type="date" name="ngayBatDau" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Đến ngày</span>
        <input type="date" name="ngayKetThuc" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Ngày phát lương</span>
        <input type="date" name="ngayPhatLuong" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <button class="h-10 px-4 rounded-lg bg-violet-600 text-white text-sm font-bold">Tạo kỳ</button>
    </form>
  </section>

  <%-- Danh sách kỳ lương --%>
  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <h2 class="font-bold text-slate-800 p-5 pb-3">Các kỳ lương</h2>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Kỳ</th>
          <th class="text-left px-5 py-3">Khoảng thời gian</th>
          <th class="text-left px-5 py-3">Ngày phát</th>
          <th class="text-right px-5 py-3">Số NV</th>
          <th class="text-right px-5 py-3">Tổng chi</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
          <th class="text-right px-5 py-3">Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="ky" items="${dsKy}">
          <tr class="border-t border-slate-100">
            <td class="px-5 py-3 font-semibold text-slate-800">${ky.tenKy}</td>
            <td class="px-5 py-3 text-slate-600">${ky.ngayBatDau} → ${ky.ngayKetThuc}</td>
            <td class="px-5 py-3 text-slate-600">${ky.ngayPhatLuong}</td>
            <td class="px-5 py-3 text-right">${ky.soNhanVien}</td>
            <td class="px-5 py-3 text-right font-bold text-slate-800">
              <fmt:formatNumber value="${ky.tongChi}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3">
              <c:choose>
                <c:when test="${ky.trangThai eq 'DaPhat'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã phát</span>
                </c:when>
                <c:when test="${ky.trangThai eq 'DangTinh'}">
                  <span class="px-2 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">Đã tính</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">Nháp</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td class="px-5 py-3">
              <div class="flex gap-2 justify-end">
                <c:if test="${ky.trangThai ne 'DaPhat'}">
                  <form method="post" action="${pageContext.request.contextPath}/manager/luong">
                    <input type="hidden" name="action" value="tinh-luong">
                    <input type="hidden" name="kyLuongId" value="${ky.kyLuongId}">
                    <button class="px-3 py-1.5 rounded-lg bg-violet-600 text-white text-xs font-bold">Tính lương</button>
                  </form>
                </c:if>
                <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${ky.kyLuongId}"
                   class="px-3 py-1.5 rounded-lg border border-violet-200 text-violet-700 text-xs font-bold">Xem / Phát</a>
              </div>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsKy}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Chưa có kỳ lương nào.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>
</body>
</html>
```

- [ ] **Step 2: Build WAR để chắc JSP không lỗi cú pháp taglib**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/manager/Luong.jsp
git commit -m "feat(luong): trang tổng quan kỳ lương của manager"
```

---

### Task 17: `CauHinhLuong.jsp` — cấu hình lương từng nhân viên

**Files:**
- Create: `src/main/webapp/manager/CauHinhLuong.jsp`

**Interfaces:**
- Consumes: attr `dsCauHinh` (`List<CauHinhLuong>` với `hoTen`, `tenVaiTro`, `accountId`, `luongCoBan`, `phuCapMoiCa`, `hanMucUng`, `ghiChu`).
- Produces: mỗi dòng là một form POST `/manager/luong/cau-hinh` với `accountId`, `luongCoBan`, `phuCapMoiCa`, `hanMucUng`, `ghiChu`.

- [ ] **Step 1: Tạo JSP**

```jsp
<%-- src/main/webapp/manager/CauHinhLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Cấu hình lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Cấu hình lương nhân viên" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <div class="p-5 pb-3">
      <h2 class="font-bold text-slate-800">Lương cơ bản, phụ cấp và hạn mức ứng</h2>
      <p class="text-sm text-slate-500">Nhân viên chưa có lương cơ bản và phụ cấp sẽ không được đưa vào bảng lương khi tính kỳ.</p>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Nhân viên</th>
          <th class="text-left px-5 py-3">Vai trò</th>
          <th class="text-right px-5 py-3">Lương cơ bản (đ)</th>
          <th class="text-right px-5 py-3">Phụ cấp / ca (đ)</th>
          <th class="text-right px-5 py-3">Hạn mức ứng (đ)</th>
          <th class="text-left px-5 py-3">Ghi chú</th>
          <th class="px-5 py-3"></th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="ch" items="${dsCauHinh}">
          <tr class="border-t border-slate-100">
            <form method="post" action="${pageContext.request.contextPath}/manager/luong/cau-hinh">
              <input type="hidden" name="accountId" value="${ch.accountId}">
              <td class="px-5 py-3 font-semibold text-slate-800">${ch.hoTen}</td>
              <td class="px-5 py-3 text-slate-600">${ch.tenVaiTro}</td>
              <td class="px-5 py-3">
                <input name="luongCoBan" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.luongCoBan}' type='number' maxFractionDigits='0'/>"
                       class="w-32 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="phuCapMoiCa" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.phuCapMoiCa}' type='number' maxFractionDigits='0'/>"
                       class="w-28 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="hanMucUng" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.hanMucUng}' type='number' maxFractionDigits='0'/>"
                       class="w-32 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="ghiChu" value="${ch.ghiChu}" maxlength="500"
                       class="w-48 h-9 px-2 rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3 text-right">
                <button class="px-3 py-1.5 rounded-lg bg-violet-600 text-white text-xs font-bold">Lưu</button>
              </td>
            </form>
          </tr>
        </c:forEach>
        <c:if test="${empty dsCauHinh}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Cơ sở chưa có nhân viên lễ tân / bảo vệ.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>
</body>
</html>
```

- [ ] **Step 2: Build WAR**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/manager/CauHinhLuong.jsp
git commit -m "feat(luong): trang cấu hình lương nhân viên"
```

---

### Task 18: `PhatLuong.jsp` — trang phát lương + QR

**Files:**
- Create: `src/main/webapp/manager/PhatLuong.jsp`

**Interfaces:**
- Consumes: attrs `ky` (`KyLuong`), `dsBangLuong` (`List<BangLuong>` đã có `qrDongUrl`, `qrImagePath`), `laNgayPhat` (boolean).
- Produces: gọi `POST /manager/api/luong/xac-nhan` với `bangLuongId`; form `action=chot-phat`.

Ảnh QR tĩnh hiển thị qua `/nhan-vien/qr-image?accountId=N` (Task 21) — KHÔNG nhúng đường dẫn file thật ra HTML.

- [ ] **Step 1: Tạo JSP**

```jsp
<%-- src/main/webapp/manager/PhatLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Phát lương ${ky.tenKy} | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Phát lương" scope="page"/>
<c:set var="headerSubtitle" value="Kỳ ${ky.tenKy}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <c:if test="${laNgayPhat}">
    <div class="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 font-bold">
      Hôm nay (${ky.ngayPhatLuong}) là ngày phát lương của kỳ này.
    </div>
  </c:if>

  <div class="flex items-center justify-between gap-4 flex-wrap">
    <div class="text-sm text-slate-600">
      Kỳ ${ky.ngayBatDau} → ${ky.ngayKetThuc} · Trạng thái:
      <span class="font-bold text-slate-800">${ky.trangThai}</span>
    </div>
    <c:if test="${ky.trangThai ne 'DaPhat'}">
      <form method="post" action="${pageContext.request.contextPath}/manager/luong"
            onsubmit="return confirm('Chốt phát lương kỳ này? Sau khi chốt sẽ không tính lại được.');">
        <input type="hidden" name="action" value="chot-phat">
        <input type="hidden" name="kyLuongId" value="${ky.kyLuongId}">
        <button class="px-4 py-2 rounded-lg bg-emerald-600 text-white text-sm font-bold">Chốt phát lương</button>
      </form>
    </c:if>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
    <c:forEach var="bl" items="${dsBangLuong}">
      <div id="card-${bl.bangLuongId}"
           class="bg-white border rounded-2xl p-5 flex flex-col gap-3
                  ${bl.daChuyenKhoan ? 'border-emerald-300 bg-emerald-50/40' : 'border-violet-100'}">
        <div class="flex items-center justify-between gap-3">
          <div>
            <div class="font-bold text-slate-800">${bl.hoTen}</div>
            <div class="text-xs text-slate-500">${bl.soCaLamViec} ca làm việc</div>
          </div>
          <span id="badge-${bl.bangLuongId}"
                class="px-2 py-1 rounded-full text-xs font-bold
                       ${bl.daChuyenKhoan ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-600'}">
            ${bl.daChuyenKhoan ? 'Đã chuyển khoản' : 'Chưa chuyển'}
          </span>
        </div>

        <div class="text-2xl font-extrabold text-violet-700">
          <fmt:formatNumber value="${bl.tongLuongThuc}" type="number" maxFractionDigits="0"/> đ
        </div>
        <div class="text-xs text-slate-500">
          Cơ bản <fmt:formatNumber value="${bl.luongCoBan}" type="number" maxFractionDigits="0"/> đ
          · Phụ cấp <fmt:formatNumber value="${bl.tongPhuCap}" type="number" maxFractionDigits="0"/> đ
          · Đã ứng <fmt:formatNumber value="${bl.tongKhauTru}" type="number" maxFractionDigits="0"/> đ
        </div>

        <div class="flex gap-3 items-start">
          <c:choose>
            <c:when test="${not empty bl.qrDongUrl}">
              <img src="${bl.qrDongUrl}" alt="QR chuyển khoản" class="w-36 h-36 rounded-lg border border-slate-200">
            </c:when>
            <c:otherwise>
              <div class="w-36 h-36 rounded-lg border border-dashed border-rose-300 bg-rose-50 text-rose-600
                          text-xs p-3 flex items-center text-center">
                Nhân viên chưa khai báo tài khoản ngân hàng.
              </div>
            </c:otherwise>
          </c:choose>

          <c:if test="${not empty bl.qrImagePath}">
            <div class="text-center">
              <img src="${pageContext.request.contextPath}/nhan-vien/qr-image?accountId=${bl.accountId}"
                   alt="QR tĩnh của nhân viên" class="w-24 h-24 rounded-lg border border-slate-200">
              <div class="text-[10px] text-slate-400 mt-1">QR nhân viên tải lên</div>
            </div>
          </c:if>
        </div>

        <div class="text-xs text-slate-600">
          <div>Ngân hàng: <span class="font-semibold">${empty bl.maNganHang ? '—' : bl.maNganHang}</span></div>
          <div>Số TK: <span class="font-semibold">${empty bl.soTaiKhoan ? '—' : bl.soTaiKhoan}</span></div>
          <div>Chủ TK: <span class="font-semibold">${bl.hoTen}</span></div>
        </div>

        <c:if test="${not bl.daChuyenKhoan}">
          <button type="button" id="btn-${bl.bangLuongId}"
                  onclick="xacNhan(${bl.bangLuongId})"
                  class="mt-1 h-10 rounded-lg bg-violet-600 text-white text-sm font-bold">Đã chuyển khoản</button>
        </c:if>
      </div>
    </c:forEach>

    <c:if test="${empty dsBangLuong}">
      <div class="col-span-full p-8 text-center text-slate-400 bg-white border border-violet-100 rounded-2xl">
        Kỳ này chưa được tính lương. Về trang quản lý lương và bấm “Tính lương”.
      </div>
    </c:if>
  </div>
</main>

<script>
  var CTX = '${pageContext.request.contextPath}';

  async function xacNhan(bangLuongId) {
    var btn = document.getElementById('btn-' + bangLuongId);
    btn.disabled = true;
    try {
      var body = new URLSearchParams({ bangLuongId: String(bangLuongId) });
      // header X-CSRF-Token do manager_head.jsp tự gắn cho mọi fetch POST
      var res = await fetch(CTX + '/manager/api/luong/xac-nhan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body
      });
      var data = await res.json();
      if (!data.ok) {
        alert(data.error || 'Không thể xác nhận.');
        btn.disabled = false;
        return;
      }
      var card = document.getElementById('card-' + bangLuongId);
      card.classList.remove('border-violet-100');
      card.classList.add('border-emerald-300', 'bg-emerald-50/40');
      var badge = document.getElementById('badge-' + bangLuongId);
      badge.className = 'px-2 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700';
      badge.textContent = 'Đã chuyển khoản';
      btn.remove();
    } catch (e) {
      alert('Lỗi kết nối: ' + e.message);
      btn.disabled = false;
    }
  }
</script>
</body>
</html>
```

- [ ] **Step 2: Build WAR**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/manager/PhatLuong.jsp
git commit -m "feat(luong): trang phát lương với QR động và xác nhận chuyển khoản"
```

---

### Task 19: `DuyetUngLuong.jsp` — manager duyệt yêu cầu ứng

**Files:**
- Create: `src/main/webapp/manager/DuyetUngLuong.jsp`

**Interfaces:**
- Consumes: attrs `dsYeuCau` (`List<YeuCauUngLuong>`), `locTrangThai`.
- Produces: gọi `POST /manager/api/luong/duyet-ung` với `yeuCauId`, `hanhDong`, `ghiChu`.

- [ ] **Step 1: Tạo JSP**

```jsp
<%-- src/main/webapp/manager/DuyetUngLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Yêu cầu ứng lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Yêu cầu ứng lương" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <div class="flex gap-2 flex-wrap">
    <c:forEach var="tt" items="${['', 'ChoDuyet', 'DaDuyet', 'TuChoi', 'DaHuy']}">
      <c:set var="nhan" value="${tt eq '' ? 'Tất cả' : (tt eq 'ChoDuyet' ? 'Chờ duyệt' : (tt eq 'DaDuyet' ? 'Đã duyệt' : (tt eq 'TuChoi' ? 'Từ chối' : 'Đã huỷ')))}"/>
      <a href="${pageContext.request.contextPath}/manager/luong/ung-luong?trangThai=${tt}"
         class="px-3 py-1.5 rounded-lg text-xs font-bold border
                ${(empty locTrangThai and tt eq '') or locTrangThai eq tt
                   ? 'bg-violet-600 text-white border-violet-600' : 'bg-white text-slate-600 border-slate-200'}">${nhan}</a>
    </c:forEach>
  </div>

  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Nhân viên</th>
          <th class="text-right px-5 py-3">Số tiền</th>
          <th class="text-left px-5 py-3">Lý do</th>
          <th class="text-left px-5 py-3">Ngày gửi</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
          <th class="text-right px-5 py-3">Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="yc" items="${dsYeuCau}">
          <tr class="border-t border-slate-100" id="row-${yc.yeuCauUngLuongId}">
            <td class="px-5 py-3 font-semibold text-slate-800">${yc.hoTen}</td>
            <td class="px-5 py-3 text-right font-bold">
              <fmt:formatNumber value="${yc.soTienUng}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3 text-slate-600">${yc.lyDo}</td>
            <td class="px-5 py-3 text-slate-500">
              <fmt:formatDate value="${yc.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </td>
            <td class="px-5 py-3" id="tt-${yc.yeuCauUngLuongId}">
              <c:choose>
                <c:when test="${yc.trangThai eq 'DaDuyet'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã duyệt</span>
                </c:when>
                <c:when test="${yc.trangThai eq 'TuChoi'}">
                  <span class="px-2 py-1 rounded-full bg-rose-50 text-rose-700 text-xs font-bold">Từ chối</span>
                </c:when>
                <c:when test="${yc.trangThai eq 'DaHuy'}">
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-500 text-xs font-bold">Đã huỷ</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">Chờ duyệt</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td class="px-5 py-3 text-right">
              <c:if test="${yc.choDuyet}">
                <div class="flex gap-2 justify-end" id="act-${yc.yeuCauUngLuongId}">
                  <button type="button" onclick="xuLy(${yc.yeuCauUngLuongId}, 'duyet')"
                          class="px-3 py-1.5 rounded-lg bg-emerald-600 text-white text-xs font-bold">Duyệt</button>
                  <button type="button" onclick="xuLy(${yc.yeuCauUngLuongId}, 'tu-choi')"
                          class="px-3 py-1.5 rounded-lg bg-rose-600 text-white text-xs font-bold">Từ chối</button>
                </div>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsYeuCau}">
          <tr><td colspan="6" class="px-5 py-8 text-center text-slate-400">Không có yêu cầu nào.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>

<script>
  var CTX = '${pageContext.request.contextPath}';

  async function xuLy(yeuCauId, hanhDong) {
    var ghiChu = prompt(hanhDong === 'duyet' ? 'Ghi chú khi duyệt (tuỳ chọn):' : 'Lý do từ chối:');
    if (ghiChu === null) return;
    var act = document.getElementById('act-' + yeuCauId);
    act.querySelectorAll('button').forEach(function (b) { b.disabled = true; });
    try {
      var res = await fetch(CTX + '/manager/api/luong/duyet-ung', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ yeuCauId: String(yeuCauId), hanhDong: hanhDong, ghiChu: ghiChu })
      });
      var data = await res.json();
      if (!data.ok) {
        alert(data.error || 'Không thể xử lý.');
        // Yêu cầu có thể đã bị xử lý ở tab khác — tải lại để thấy trạng thái thật.
        location.reload();
        return;
      }
      var duyet = hanhDong === 'duyet';
      document.getElementById('tt-' + yeuCauId).innerHTML =
        '<span class="px-2 py-1 rounded-full text-xs font-bold ' +
        (duyet ? 'bg-emerald-50 text-emerald-700">Đã duyệt' : 'bg-rose-50 text-rose-700">Từ chối') + '</span>';
      act.remove();
    } catch (e) {
      alert('Lỗi kết nối: ' + e.message);
      location.reload();
    }
  }
</script>
</body>
</html>
```

- [ ] **Step 2: Build WAR**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/manager/DuyetUngLuong.jsp
git commit -m "feat(luong): trang manager duyệt yêu cầu ứng lương"
```

---

## Phase 5 — Giao diện Staff / Guard

### Task 20: `StaffQrUploadPaths` — nơi lưu ảnh QR tĩnh của nhân viên

**Files:**
- Create: `src/main/java/org/example/util/StaffQrUploadPaths.java`

**Interfaces:**
- Consumes: biến môi trường `VSPORT_UPLOAD_DIR` / property `vsport.upload.dir` (đã dùng bởi `RefundQrUploadPaths`).
- Produces:
  - `static File baseDir()`
  - `static File nhanVienDir(int accountId)`
  - `static String relativePath(int accountId, String fileName)` — ví dụ `"nhan-vien-qr/12/<uuid>.png"`
  - `static File resolveSafely(String relativePath)` — null nếu phát hiện path traversal.

- [ ] **Step 1: Tạo util (sao chép nguyên cơ chế của `RefundQrUploadPaths`, đổi subfolder)**

```java
package org.example.util;

import java.io.File;
import java.nio.file.Path;

/**
 * Ảnh QR ngân hàng tĩnh do nhân viên tự upload — dữ liệu NHẠY CẢM (gắn tài khoản ngân hàng
 * thật). Lưu ngoài webroot/WAR bằng cùng cơ chế VSPORT_UPLOAD_DIR như RefundQrUploadPaths,
 * và PHẢI serve qua NhanVienQrServeServlet có kiểm tra quyền — không bao giờ qua route public.
 */
public final class StaffQrUploadPaths {

    private static final String ENV_VAR = "VSPORT_UPLOAD_DIR";
    private static final String PROP_KEY = "vsport.upload.dir";
    private static final String SUBFOLDER = "nhan-vien-qr";

    private StaffQrUploadPaths() {
    }

    public static File baseDir() {
        String configured = System.getenv(ENV_VAR);
        if (configured == null || configured.trim().isEmpty()) {
            configured = System.getProperty(PROP_KEY);
        }
        if (configured == null || configured.trim().isEmpty()) {
            configured = new File(System.getProperty("user.home"), "vsport-uploads").getAbsolutePath();
        }
        return new File(configured.trim());
    }

    /** Thư mục vật lý chứa ảnh QR của một nhân viên, chưa chắc đã tồn tại. */
    public static File nhanVienDir(int accountId) {
        return new File(new File(baseDir(), SUBFOLDER), String.valueOf(accountId));
    }

    /** Đường dẫn tương đối lưu vào cột Accounts.QrImagePath. */
    public static String relativePath(int accountId, String fileName) {
        return SUBFOLDER + "/" + accountId + "/" + fileName;
    }

    /** Quy đổi relativePath (đọc từ DB) thành File thật, chặn path traversal. Null nếu không hợp lệ. */
    public static File resolveSafely(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) return null;
        String normalized = relativePath.replace('\\', '/');
        if (normalized.contains("..")) return null;

        File root = new File(baseDir(), SUBFOLDER).getAbsoluteFile();
        File candidate = new File(baseDir(), normalized).getAbsoluteFile();

        Path rootPath = root.toPath().normalize();
        Path candidatePath = candidate.toPath().normalize();
        if (!candidatePath.startsWith(rootPath)) return null;
        return candidatePath.toFile();
    }
}
```

- [ ] **Step 2: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/util/StaffQrUploadPaths.java
git commit -m "feat(luong): StaffQrUploadPaths cho ảnh QR ngân hàng của nhân viên"
```

---

### Task 21: `NhanVienQrServeServlet` — stream ảnh QR có kiểm tra quyền

**Files:**
- Create: `src/main/java/org/example/controller/NhanVienQrServeServlet.java`

**Interfaces:**
- Consumes: `StaffQrUploadPaths.resolveSafely`, `TaiKhoanDAO.getAccountById`, `Constants`.
- Produces: `GET /nhan-vien/qr-image?accountId=N` → ảnh PNG/JPG/WEBP.
  - Nhân viên chỉ xem được ảnh của chính mình.
  - Manager xem được ảnh của nhân viên CÙNG cơ sở (dùng ở `PhatLuong.jsp`).
  - Mọi trường hợp khác: 403/404.

- [ ] **Step 1: Tạo servlet**

```java
package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import org.example.util.StaffQrUploadPaths;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Locale;

/**
 * Stream ảnh QR ngân hàng tĩnh của nhân viên. Dữ liệu nhạy cảm: mỗi request kiểm tra quyền,
 * không cache, không lộ đường dẫn filesystem.
 *
 * GET /nhan-vien/qr-image?accountId=X
 */
@WebServlet("/nhan-vien/qr-image")
public class NhanVienQrServeServlet extends HttpServlet {

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int accountId;
        try {
            accountId = Integer.parseInt(req.getParameter("accountId"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        TaiKhoan target = taiKhoanDAO.getAccountById(accountId);
        if (target == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        boolean laChinhMinh = user.getAccountId() == accountId;
        boolean laManagerCungCoSo = user.getRoleId() == Constants.ROLE_MANAGER
                && user.getCoSoId() != null
                && user.getCoSoId().equals(target.getCoSoId());
        if (!laChinhMinh && !laManagerCungCoSo) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File file = StaffQrUploadPaths.resolveSafely(target.getQrImagePath());
        if (file == null || !file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = guessContentType(file.getName());
        if (contentType == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "private, no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        Files.copy(file.toPath(), resp.getOutputStream());
    }

    private static String guessContentType(String fileName) {
        String lower = fileName.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".webp")) return "image/webp";
        return null;
    }
}
```

- [ ] **Step 2: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/controller/NhanVienQrServeServlet.java
git commit -m "feat(luong): servlet stream ảnh QR nhân viên có kiểm tra quyền"
```

---

### Task 22: `LuongStaffServlet` + `LuongGuardServlet`

**Files:**
- Create: `src/main/java/org/example/controller/staff/LuongStaffServlet.java`
- Create: `src/main/java/org/example/controller/guard/LuongGuardServlet.java`

**Interfaces:**
- Consumes: `LuongService.lichSuLuongCuaToi`, `UngLuongService` (`lichSuCuaToi`, `hanMucConLai`, `guiYeuCau`, `huy`), `TaiKhoanDAO.updateBankInfo/updateQrImagePath`, `StaffQrUploadPaths`, `ImageInspector`.
- Produces: `GET /staff/luong` và `GET /guard/luong` → `/staff/LuongCuaToi.jsp`; attrs: `dsBangLuong`, `dsYeuCau`, `hanMucConLai`, `nhanVien` (`TaiKhoan` mới nhất từ DB, để hiện thông tin ngân hàng đã lưu).
  POST cùng URL, `action` = `gui-ung` | `huy-ung` | `luu-ngan-hang` | `upload-qr`.

Hai servlet dùng chung logic — đặt toàn bộ trong một lớp cơ sở để không nhân đôi code.

- [ ] **Step 1: Tạo `LuongStaffServlet` (chứa toàn bộ logic)**

```java
package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;
import org.example.util.ImageInspector;
import org.example.util.StaffQrUploadPaths;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.util.List;
import java.util.UUID;

/**
 * Trang "Lương của tôi" cho lễ tân. Guard dùng lại toàn bộ logic này qua LuongGuardServlet.
 * AccountID/CoSoID luôn lấy từ session — nhân viên không thể xem lương người khác.
 */
@WebServlet("/staff/luong")
@MultipartConfig(fileSizeThreshold = 1 << 16, maxFileSize = 3 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class LuongStaffServlet extends HttpServlet {

    /** Giới hạn ảnh QR: 3MB, tối thiểu 120×120 để còn quét được. */
    private static final int MAX_QR_BYTES = 3 * 1024 * 1024;
    private static final int MIN_QR_EDGE = 120;

    protected final LuongService luongService = new LuongService();
    protected final UngLuongService ungLuongService = new UngLuongService();
    protected final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    /** Role được phép vào trang này. Guard servlet override thành ROLE_BAO_VE. */
    protected int vaiTroChoPhep() {
        return Constants.ROLE_LE_TAN;
    }

    /** URL của chính trang này, dùng để redirect sau POST. */
    protected String duongDan() {
        return "/staff/luong";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan me = getNhanVien(req, resp);
        if (me == null) return;
        try {
            // Đọc lại từ DB: session có thể đang giữ bản cũ chưa có thông tin ngân hàng vừa lưu.
            TaiKhoan moiNhat = taiKhoanDAO.getAccountById(me.getAccountId());
            req.setAttribute("nhanVien", moiNhat == null ? me : moiNhat);
            req.setAttribute("dsBangLuong", luongService.lichSuLuongCuaToi(me.getAccountId()));
            req.setAttribute("dsYeuCau", ungLuongService.lichSuCuaToi(me.getAccountId()));
            req.setAttribute("hanMucConLai", ungLuongService.hanMucConLai(me.getAccountId(), me.getCoSoId()));
            req.getRequestDispatcher("/staff/LuongCuaToi.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Lỗi tải trang lương của tôi", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan me = getNhanVien(req, resp);
        if (me == null) return;
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "gui-ung" -> {
                    ungLuongService.guiYeuCau(me.getAccountId(), me.getCoSoId(),
                            parseTien(req.getParameter("soTienUng")), req.getParameter("lyDo"));
                    session.setAttribute("flashSuccess", "Đã gửi yêu cầu ứng lương, chờ quản lý duyệt.");
                }
                case "huy-ung" -> {
                    int id = Integer.parseInt(req.getParameter("yeuCauId"));
                    boolean ok = ungLuongService.huy(id, me.getAccountId());
                    session.setAttribute(ok ? "flashSuccess" : "flashError",
                            ok ? "Đã huỷ yêu cầu ứng lương."
                               : "Không thể huỷ — yêu cầu đã được xử lý.");
                }
                case "luu-ngan-hang" -> {
                    taiKhoanDAO.updateBankInfo(me.getAccountId(),
                            req.getParameter("maNganHang"), req.getParameter("soTaiKhoan"));
                    session.setAttribute("flashSuccess", "Đã cập nhật tài khoản ngân hàng nhận lương.");
                }
                case "upload-qr" -> uploadQr(req, me);
                default -> session.setAttribute("flashError", "Hành động không hợp lệ.");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý thao tác lương", e);
        }
        resp.sendRedirect(req.getContextPath() + duongDan());
    }

    /** Lưu ảnh QR tĩnh: kiểm tra magic bytes qua ImageInspector, ghi ra ngoài webroot. */
    private void uploadQr(HttpServletRequest req, TaiKhoan me) throws Exception {
        Part part = req.getPart("qrImage");
        if (part == null || part.getSize() <= 0) {
            req.getSession().setAttribute("flashError", "Vui lòng chọn ảnh QR.");
            return;
        }
        if (part.getSize() > MAX_QR_BYTES) {
            req.getSession().setAttribute("flashError", "Ảnh QR vượt quá 3MB.");
            return;
        }

        byte[] bytes;
        try (InputStream in = part.getInputStream()) {
            bytes = in.readAllBytes();
        }
        ImageInspector.Result kq = ImageInspector.inspect(bytes, MIN_QR_EDGE, MIN_QR_EDGE);
        if (!kq.valid) {
            req.getSession().setAttribute("flashError", kq.error);
            return;
        }

        File dir = StaffQrUploadPaths.nhanVienDir(me.getAccountId());
        Files.createDirectories(dir.toPath());
        String fileName = UUID.randomUUID() + kq.extension;
        Files.write(new File(dir, fileName).toPath(), bytes);

        // Xoá ảnh cũ để không tích rác trong thư mục upload.
        TaiKhoan hienTai = taiKhoanDAO.getAccountById(me.getAccountId());
        String cu = hienTai == null ? null : hienTai.getQrImagePath();
        taiKhoanDAO.updateQrImagePath(me.getAccountId(),
                StaffQrUploadPaths.relativePath(me.getAccountId(), fileName));
        if (cu != null && !cu.isBlank()) {
            File fileCu = StaffQrUploadPaths.resolveSafely(cu);
            if (fileCu != null && fileCu.isFile()) {
                Files.deleteIfExists(fileCu.toPath());
            }
        }
        req.getSession().setAttribute("flashSuccess", "Đã tải lên ảnh QR ngân hàng.");
    }

    private static BigDecimal parseTien(String v) {
        if (v == null || v.isBlank()) return BigDecimal.ZERO;
        try {
            return new BigDecimal(v.replaceAll("[^0-9]", ""));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    protected TaiKhoan getNhanVien(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != vaiTroChoPhep() || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
```

- [ ] **Step 2: Tạo `LuongGuardServlet` kế thừa**

```java
package org.example.controller.guard;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import org.example.controller.staff.LuongStaffServlet;
import org.example.util.Constants;

/**
 * "Lương của tôi" cho bảo vệ — nghiệp vụ giống hệt lễ tân, chỉ khác role được phép và URL.
 */
@WebServlet("/guard/luong")
@MultipartConfig(fileSizeThreshold = 1 << 16, maxFileSize = 3 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class LuongGuardServlet extends LuongStaffServlet {

    @Override
    protected int vaiTroChoPhep() {
        return Constants.ROLE_BAO_VE;
    }

    @Override
    protected String duongDan() {
        return "/guard/luong";
    }
}
```

- [ ] **Step 3: Biên dịch**

```bash
mvn -o compile -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/controller/staff/LuongStaffServlet.java src/main/java/org/example/controller/guard/LuongGuardServlet.java
git commit -m "feat(luong): trang Lương của tôi cho staff và guard"
```

---

### Task 23: `LuongCuaToi.jsp` — trang lương của nhân viên (dùng chung staff + guard)

**Files:**
- Create: `src/main/webapp/staff/LuongCuaToi.jsp`

**Interfaces:**
- Consumes: attrs `nhanVien`, `dsBangLuong`, `dsYeuCau`, `hanMucConLai` (Task 22).
- Produces: 4 form POST về `${luongUrl}` với `action` = `gui-ung` | `huy-ung` | `luu-ngan-hang` | `upload-qr`.

Vì guard và staff có `common/*` khác nhau, JSP tự chọn bộ include theo `roleId` trong session (4 = lễ tân, 5 = bảo vệ).

- [ ] **Step 1: Tạo JSP**

```jsp
<%-- src/main/webapp/staff/LuongCuaToi.jsp — dùng chung cho lễ tân (/staff/luong) và bảo vệ (/guard/luong) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="laBaoVe" value="${sessionScope.user.roleId eq 5}"/>
<c:set var="luongUrl" value="${laBaoVe ? '/guard/luong' : '/staff/luong'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Lương của tôi | V-SPORT</title>
  <c:choose>
    <c:when test="${laBaoVe}"><jsp:include page="/guard/common/guard_head.jsp"/></c:when>
    <c:otherwise><jsp:include page="/staff/common/staff_head.jsp"/></c:otherwise>
  </c:choose>
</head>
<body class="bg-[#fbfaff]">
<c:choose>
  <c:when test="${laBaoVe}"><jsp:include page="/guard/common/sidebar.jsp"/></c:when>
  <c:otherwise><jsp:include page="/staff/common/sidebar.jsp"/></c:otherwise>
</c:choose>
<c:set var="headerTitle" value="Lương của tôi" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<c:choose>
  <c:when test="${laBaoVe}"><jsp:include page="/guard/common/header.jsp"/></c:when>
  <c:otherwise><jsp:include page="/staff/common/header.jsp"/></c:otherwise>
</c:choose>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <%-- ── Bảng lương theo kỳ ── --%>
  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <h2 class="font-bold text-slate-800 p-5 pb-3">Bảng lương</h2>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Kỳ</th>
          <th class="text-right px-5 py-3">Số ca</th>
          <th class="text-right px-5 py-3">Lương cơ bản</th>
          <th class="text-right px-5 py-3">Phụ cấp</th>
          <th class="text-right px-5 py-3">Đã ứng</th>
          <th class="text-right px-5 py-3">Thực nhận</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="bl" items="${dsBangLuong}">
          <tr class="border-t border-slate-100">
            <td class="px-5 py-3 font-semibold text-slate-800">${bl.tenKy}</td>
            <td class="px-5 py-3 text-right">${bl.soCaLamViec}</td>
            <td class="px-5 py-3 text-right"><fmt:formatNumber value="${bl.luongCoBan}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right"><fmt:formatNumber value="${bl.tongPhuCap}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right text-rose-600">−<fmt:formatNumber value="${bl.tongKhauTru}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right font-extrabold text-violet-700">
              <fmt:formatNumber value="${bl.tongLuongThuc}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3">
              <c:choose>
                <c:when test="${bl.trangThai eq 'XacNhanDaChuyenKhoan'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã nhận</span>
                </c:when>
                <c:when test="${bl.trangThai eq 'DaPhat'}">
                  <span class="px-2 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">Đang chuyển</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">Đã tính</span>
                </c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsBangLuong}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Chưa có kỳ lương nào được tính cho bạn.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">

    <%-- ── Tài khoản ngân hàng nhận lương ── --%>
    <section class="bg-white border border-violet-100 rounded-2xl p-5 flex flex-col gap-4">
      <h2 class="font-bold text-slate-800">Tài khoản ngân hàng nhận lương</h2>
      <form method="post" action="${pageContext.request.contextPath}${luongUrl}" class="flex flex-col gap-3">
        <input type="hidden" name="action" value="luu-ngan-hang">
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Mã ngân hàng (BIN, ví dụ 970436 = Vietcombank)</span>
          <input name="maNganHang" value="${nhanVien.maNganHang}" maxlength="20"
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Số tài khoản</span>
          <input name="soTaiKhoan" value="${nhanVien.soTaiKhoan}" maxlength="30"
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <button class="h-10 rounded-lg bg-violet-600 text-white text-sm font-bold">Lưu thông tin ngân hàng</button>
      </form>

      <div class="border-t border-slate-100 pt-4">
        <div class="text-sm font-bold text-slate-700 mb-2">Ảnh QR ngân hàng (tuỳ chọn)</div>
        <c:if test="${not empty nhanVien.qrImagePath}">
          <img src="${pageContext.request.contextPath}/nhan-vien/qr-image?accountId=${nhanVien.accountId}"
               alt="QR ngân hàng của tôi" class="w-32 h-32 rounded-lg border border-slate-200 mb-3">
        </c:if>
        <form method="post" action="${pageContext.request.contextPath}${luongUrl}"
              enctype="multipart/form-data" class="flex flex-col gap-2">
          <input type="hidden" name="action" value="upload-qr">
          <input type="file" name="qrImage" accept="image/png,image/jpeg,image/webp" required class="text-sm">
          <p class="text-xs text-slate-400">JPG/PNG/WEBP, tối đa 3MB, tối thiểu 120×120.</p>
          <button class="h-10 rounded-lg bg-white border border-violet-200 text-violet-700 text-sm font-bold">Tải lên ảnh QR</button>
        </form>
      </div>
    </section>

    <%-- ── Ứng lương ── --%>
    <section class="bg-white border border-violet-100 rounded-2xl p-5 flex flex-col gap-4">
      <div>
        <h2 class="font-bold text-slate-800">Yêu cầu ứng lương</h2>
        <p class="text-sm text-slate-500">
          Hạn mức còn ứng được:
          <span class="font-bold text-violet-700">
            <fmt:formatNumber value="${hanMucConLai}" type="number" maxFractionDigits="0"/> đ
          </span>
        </p>
      </div>

      <form method="post" action="${pageContext.request.contextPath}${luongUrl}" class="flex flex-col gap-3">
        <input type="hidden" name="action" value="gui-ung">
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Số tiền muốn ứng (đ)</span>
          <input name="soTienUng" inputmode="numeric" required
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Lý do</span>
          <textarea name="lyDo" rows="2" maxlength="500"
                    class="w-full px-3 py-2 rounded-lg border border-slate-200"></textarea>
        </label>
        <button class="h-10 rounded-lg bg-violet-600 text-white text-sm font-bold">Gửi yêu cầu</button>
      </form>

      <div class="border-t border-slate-100 pt-4">
        <div class="text-sm font-bold text-slate-700 mb-2">Lịch sử yêu cầu</div>
        <div class="flex flex-col gap-2">
          <c:forEach var="yc" items="${dsYeuCau}">
            <div class="flex items-center justify-between gap-3 p-3 rounded-lg bg-slate-50 text-sm">
              <div>
                <div class="font-bold text-slate-800">
                  <fmt:formatNumber value="${yc.soTienUng}" type="number" maxFractionDigits="0"/> đ
                </div>
                <div class="text-xs text-slate-500">
                  <fmt:formatDate value="${yc.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                  <c:if test="${not empty yc.lyDo}"> · ${yc.lyDo}</c:if>
                </div>
                <c:if test="${not empty yc.ghiChuQuanLy}">
                  <div class="text-xs text-slate-500">Quản lý: ${yc.ghiChuQuanLy}</div>
                </c:if>
              </div>
              <div class="flex items-center gap-2">
                <c:choose>
                  <c:when test="${yc.trangThai eq 'DaDuyet'}">
                    <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã duyệt</span>
                  </c:when>
                  <c:when test="${yc.trangThai eq 'TuChoi'}">
                    <span class="px-2 py-1 rounded-full bg-rose-50 text-rose-700 text-xs font-bold">Từ chối</span>
                  </c:when>
                  <c:when test="${yc.trangThai eq 'DaHuy'}">
                    <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-500 text-xs font-bold">Đã huỷ</span>
                  </c:when>
                  <c:otherwise>
                    <span class="px-2 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">Chờ duyệt</span>
                  </c:otherwise>
                </c:choose>
                <c:if test="${yc.choDuyet}">
                  <form method="post" action="${pageContext.request.contextPath}${luongUrl}">
                    <input type="hidden" name="action" value="huy-ung">
                    <input type="hidden" name="yeuCauId" value="${yc.yeuCauUngLuongId}">
                    <button class="px-2 py-1 rounded-lg border border-slate-300 text-slate-600 text-xs font-bold">Huỷ</button>
                  </form>
                </c:if>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty dsYeuCau}">
            <div class="text-sm text-slate-400">Chưa có yêu cầu ứng lương nào.</div>
          </c:if>
        </div>
      </div>
    </section>
  </div>
</main>
</body>
</html>
```

- [ ] **Step 2: Build WAR**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/staff/LuongCuaToi.jsp
git commit -m "feat(luong): trang Lương của tôi (bảng lương, tài khoản NH, ứng lương)"
```

---

## Phase 6 — Điều hướng và kiểm thử thủ công

### Task 24: Thêm link sidebar cho 3 role

**Files:**
- Modify: `src/main/webapp/manager/common/sidebar.jsp`
- Modify: `src/main/webapp/staff/common/sidebar.jsp`
- Modify: `src/main/webapp/guard/common/sidebar.jsp`

**Interfaces:**
- Consumes: URL từ Task 14 và Task 22.
- Produces: 3 mục điều hướng mới, không đổi cấu trúc nhóm sẵn có.

- [ ] **Step 1: Manager — thêm mục "Quản lý lương"**

Trong `src/main/webapp/manager/common/sidebar.jsp`, ngay SAU khối `<a>` trỏ tới `/manager/face-settings` (khoảng dòng 481–484, trong nhóm nhân sự), chèn:

```jsp
        <a href="${pageContext.request.contextPath}/manager/luong"
          class="nav-link ${uri.contains('/manager/luong') ? 'active' : ''}">
          <span class="material-symbols-outlined">payments</span>
          <span>Quản lý lương</span>
        </a>
```

Đồng thời tìm biến `grp...` của nhóm chứa `/manager/nhan-su` và `/manager/ca-lam`, thêm `|| uri.contains('/manager/luong')` vào biểu thức `value` của nó để nhóm tự mở khi đang ở trang lương.

- [ ] **Step 2: Staff — thêm mục "Lương của tôi"**

Trong `src/main/webapp/staff/common/sidebar.jsp`, SAU khối `<a>` trỏ tới `/staff/yeu-cau-nghi` (nhóm "Cá nhân", khoảng dòng 232), chèn:

```jsp
        <a href="${pageContext.request.contextPath}/staff/luong"
          class="nav-link ${uri.contains('/staff/luong') ? 'active' : ''}">
          <span class="material-symbols-outlined">payments</span>
          <span>Lương của tôi</span>
        </a>
```

Và bổ sung `|| uri.contains('/staff/luong')` vào `<c:set var="grpCaNhan" ...>` (dòng 174).

- [ ] **Step 3: Guard — thêm mục "Lương của tôi"**

Trong `src/main/webapp/guard/common/sidebar.jsp`, SAU khối `<a>` trỏ tới `/guard/lich-su-su-co` (khoảng dòng 133), chèn:

```jsp
        <a href="${pageContext.request.contextPath}/guard/luong"
          class="nav-link ${uri.contains('/guard/luong') ? 'active' : ''}">
          <span class="material-symbols-outlined">payments</span>
          <span>Lương của tôi</span>
        </a>
```

- [ ] **Step 4: Build WAR**

```bash
mvn -o package -DskipTests
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 5: Commit**

```bash
git add src/main/webapp/manager/common/sidebar.jsp src/main/webapp/staff/common/sidebar.jsp src/main/webapp/guard/common/sidebar.jsp
git commit -m "feat(luong): link sidebar cho manager, staff và guard"
```

---

### Task 25: Tài liệu kiểm thử thủ công + chạy toàn bộ test

**Files:**
- Create: `docs/SALARY_MANUAL_TEST.md`

**Interfaces:**
- Consumes: toàn bộ các task trước.
- Produces: checklist kiểm thử để chạy tay trên môi trường local.

- [ ] **Step 1: Chạy toàn bộ test và build**

```bash
mvn -o clean package
```

Kỳ vọng: BUILD SUCCESS, `LuongCalculatorTest`, `VietQrUrlTest`, `UngLuongValidationTest` đều PASS.

- [ ] **Step 2: Viết tài liệu kiểm thử**

```markdown
# Kiểm thử thủ công — Module tính lương

**Chuẩn bị**
1. Chạy `sql/migration_salary.sql` trên database.
2. Đảm bảo cơ sở có ít nhất 2 nhân viên (1 lễ tân RoleID=4, 1 bảo vệ RoleID=5).
3. Tạo sẵn vài ca `CaLamViec` trạng thái `CheckedOut` trong tháng hiện tại cho các nhân viên đó.
4. Đặt biến môi trường `VSPORT_UPLOAD_DIR` (nếu không, ảnh QR lưu ở `~/vsport-uploads`).

## 1. Cấu hình lương (Manager)
- [ ] Vào `/manager/luong/cau-hinh` — thấy đủ lễ tân và bảo vệ của cơ sở mình, KHÔNG thấy nhân viên cơ sở khác.
- [ ] Nhập lương cơ bản 5.000.000, phụ cấp/ca 50.000, hạn mức ứng 2.000.000 → bấm Lưu → hiện flash thành công, tải lại trang thấy số đã lưu.

## 2. Tạo kỳ và tính lương (Manager)
- [ ] `/manager/luong` → tạo kỳ "Tháng 8/2026", 01/08 → 31/08, ngày phát 05/09 → tạo thành công.
- [ ] Tạo kỳ với ngày kết thúc TRƯỚC ngày bắt đầu → hiện lỗi "Ngày kết thúc phải sau ngày bắt đầu."
- [ ] Bấm "Tính lương" → flash báo số nhân viên đã tính; cột Số NV và Tổng chi cập nhật.
- [ ] Bấm "Tính lương" lần nữa → số dòng KHÔNG nhân đôi (upsert).

## 3. Ứng lương (Staff/Guard → Manager)
- [ ] Đăng nhập lễ tân → `/staff/luong` → thấy hạn mức còn ứng 2.000.000.
- [ ] Gửi yêu cầu ứng 3.000.000 → bị chặn với thông báo vượt hạn mức.
- [ ] Gửi yêu cầu ứng 500.000 → thành công, xuất hiện trong lịch sử với badge "Chờ duyệt".
- [ ] Bấm "Huỷ" trên yêu cầu đó → chuyển sang "Đã huỷ".
- [ ] Gửi lại 500.000 → Manager vào `/manager/luong/ung-luong` → bấm Duyệt → badge đổi sang "Đã duyệt" không cần tải lại trang.
- [ ] Bấm Duyệt lần nữa ở tab thứ hai → báo "Yêu cầu đã được xử lý trước đó" và tự tải lại.
- [ ] Manager tính lại lương kỳ chứa ngày gửi yêu cầu → cột "Đã ứng" của nhân viên đó = 500.000, thực nhận giảm tương ứng.

## 4. Tài khoản ngân hàng và QR (Staff)
- [ ] `/staff/luong` → nhập mã ngân hàng `970436`, số TK `1234567890` → lưu thành công.
- [ ] Tải lên ảnh QR PNG 300×300 → hiện ảnh xem trước.
- [ ] Tải lên file `.txt` đổi đuôi thành `.png` → bị từ chối với thông báo định dạng.
- [ ] Đăng nhập bằng nhân viên KHÁC, mở `/nhan-vien/qr-image?accountId=<id nhân viên đầu>` → nhận 403.

## 5. Phát lương (Manager)
- [ ] `/manager/luong/phat?kyLuongId=N` → mỗi nhân viên là một card, hiển thị số tiền thực nhận nổi bật.
- [ ] Nhân viên đã khai ngân hàng → thấy ảnh VietQR động; quét bằng app ngân hàng ra đúng số tiền và nội dung.
- [ ] Nhân viên CHƯA khai ngân hàng → thấy ô cảnh báo màu đỏ thay cho QR.
- [ ] Bấm "Đã chuyển khoản" → card chuyển xanh, badge đổi "Đã chuyển khoản", nút biến mất; tải lại trang vẫn giữ trạng thái.
- [ ] Bấm "Chốt phát lương" → kỳ chuyển trạng thái "Đã phát"; quay lại `/manager/luong` thì nút "Tính lương" của kỳ đó biến mất.
- [ ] Nhân viên vào `/staff/luong` → trạng thái kỳ hiển thị "Đang chuyển" hoặc "Đã nhận".

## 6. Phân quyền (bắt buộc)
- [ ] Đăng nhập manager cơ sở A, sửa `kyLuongId` trên URL `/manager/luong/phat` thành kỳ của cơ sở B → bị đẩy về `/manager/luong` với thông báo "Kỳ lương không tồn tại."
- [ ] Lễ tân mở `/manager/luong` → bị chuyển về trang đăng nhập.
- [ ] Bảo vệ mở `/staff/luong` → bị chuyển về trang đăng nhập (chỉ vào được `/guard/luong`).
```

- [ ] **Step 3: Commit**

```bash
git add docs/SALARY_MANUAL_TEST.md
git commit -m "docs(luong): checklist kiểm thử thủ công module tính lương"
```

---

## Đối chiếu với spec (self-review)

| Mục spec | Task phụ trách |
|---|---|
| §2.1 `CauHinhLuong` | Task 1, 4, 6 |
| §2.2 `KyLuong` | Task 1, 4, 7 |
| §2.3 `BangLuong` | Task 1, 4, 8 |
| §2.4 `YeuCauUngLuong` | Task 1, 4, 9 |
| §3 Controllers | Task 14, 15, 21, 22 |
| §3 Services | Task 11, 12, 13 |
| §3 Models | Task 4 |
| §4 Logic tính lương | Task 2 (công thức), Task 5 (đếm ca), Task 12 (ghép) |
| §5 Trang phát lương + QR động/tĩnh + xác nhận | Task 3, 18, 15, 21 |
| §6 `LuongCuaToi.jsp` (bảng lương + tài khoản NH + QR) | Task 22, 23 |
| §6 `YeuCauUngLuong.jsp` (form ứng, huỷ) | Gộp vào Task 23 — cùng trang, tránh 2 trang gần giống nhau |
| §6 cột `Accounts.QrImagePath` | Task 1, 10 |
| §7 Sidebar 3 role | Task 24 |

**Khác biệt có chủ ý so với spec:**
- Spec đề xuất `YeuCauUngLuong.jsp` riêng cho nhân viên; plan gộp form ứng lương vào `LuongCuaToi.jsp` vì cả hai đều là "màn hình lương cá nhân" và số liệu hạn mức phụ thuộc bảng lương — tách trang sẽ nhân đôi phần nạp dữ liệu mà không thêm giá trị.
- Spec ghi tài khoản ngân hàng POST lên `/account/update-profile`; plan dùng `POST /staff/luong` (`action=luu-ngan-hang`) để không phải sửa servlet dùng chung với customer — Global Constraints cấm đụng luồng hiện có.
- Thêm `UngLuongValidator` (không có trong spec) để quy tắc hạn mức được unit-test mà không cần DB.

---

## Bàn giao thực thi

Plan gồm **25 task** chia 6 phase. Mỗi phase kết thúc ở trạng thái build được và commit được.
