# Shift Management — Validation Enhancement Report

**Project:** V-SPORT  
**Module:** Quản lý Ca Làm Việc (Shift Management)  
**Date:** 2026-07-06  
**Status:** ✅ Implemented

---

## I. Tổng quan

Tài liệu này mô tả toàn bộ các validation rule đã được implement cho module Quản lý Ca Làm Việc, phân loại theo Priority và Section.

---

## II. Priority 1 — Core Validations

### P1-1: Template Validation
- **File:** `QuanLyCaLamManagerServlet.java` — `parseCaLamRequest()`
- **Rule:** Chỉ chấp nhận mẫu ca id=1 (Ca sáng) và id=2 (Ca chiều). Ca đêm (id=3) bị chặn.
- **Error:** `ValidationException("Mẫu ca đêm chưa được hỗ trợ.")`
- **HTTP:** 400

### P1-2: selectedDates Batch Validation
- **File:** `CaLamService.java` — `createShift()`
- **Rules:**
  - Danh sách ngày tạo ca (datesToSchedule) không được có ngày trùng lặp → `ValidationException`
  - Không được tạo ca trong ngày đã qua → `PAST_DATETIME` (xử lý trong engine per-date)
  - Giới hạn tối đa 90 ca trong một batch → `ValidationException`
- **Note:** Khi `repeatType=daily` hoặc `weekly`, service tự generate dates từ `ngayLam` đến `repeatUntil`.

### P1-3: Batch All-or-Nothing Transaction
- **File:** `CaLamService.java` — `createShift()`, `CaLamViecDAO`, `CaLamViecAuditDAO`
- **Rule:** Toàn bộ batch insert được bọc trong một JDBC transaction. Nếu bất kỳ ca nào lỗi, toàn bộ batch bị rollback.
- **Implementation:**
  - `CaLamViecDAO.addCaLamViecWithConnection(ca, conn)` — insert trong shared connection, trả về generated ID
  - `CaLamViecAuditDAO.insertWithConnection(audit, conn)` — audit log trong cùng transaction
  - Service: `conn.setAutoCommit(false)` → loop → `conn.commit()` / `conn.rollback()`
- **Notification:** Gửi sau khi commit (outside transaction, non-critical)

### P1-4: breakMinutes Validation
- **File:** `CaLamValidationEngine.java`
- **Rules:**
  - `breakMinutes < 0` → `BREAK_MINUTES` error
  - `breakMinutes >= totalDurationMinutes` → `BREAK_EXCEEDS_DURATION` error

### P1-5: totalWorkingHours (MIN 60 / MAX 720 phút net)
- **File:** `CaLamValidationEngine.java`, `Constants.java`
- **Rules:**
  - Net < 60 phút → `MIN_DURATION` error
  - Net > 720 phút → `MAX_DURATION_EXCEEDED` error
  - Net > 600 phút (10h) nhưng ≤ 720 → `MAX_DURATION` warning

### P1-6: Role Compatibility
- **File:** `CaLamValidationEngine.java`
- **Rule:** Nhân viên phải có RoleID thuộc `ALLOWED_SHIFT_ROLES` = [4 (LE_TAN), 5 (BAO_VE)] → `ROLE_INCOMPATIBLE` error

### P1-7: Note/XSS Sanitization
- **File:** `CaLamService.java` — `sanitizeText()`
- **Rule:** `ghiChu` và `customTimeReason` được HTML-escape (`&`, `<`, `>`, `"`, `'`) trước khi lưu DB.
- **Length:** ghiChu ≤ 255 ký tự (kiểm tra ở cả servlet và service)

---

## III. Priority 2 — Advanced Validations

### P2-1: Monthly 160h Limit
- **File:** `CaLamValidationEngine.java`, `Constants.java`
- **Constant:** `MONTHLY_HOUR_LIMIT_MINUTES = 9600` (160h)
- **Rule:** Tổng giờ net của tháng (không tính Cancelled) > 9600 phút → `MONTHLY_LIMIT` error
- **Scope:** Tất cả ca trong cùng tháng/năm với `ngayLam`

### P2-2: Min Rest 8h — ERROR
- **File:** `CaLamValidationEngine.java`, `Constants.java`
- **Constant:** `MIN_REST_MINUTES = 480` (8h)
- **Rules:**
  - Khoảng cách nghỉ với ca liền trước/sau < 480 phút → `REST_HOURS_CRITICAL` / `REST_HOURS_CRITICAL_AFTER` **error**
  - 480–720 phút → `REST_HOURS_BEFORE` / `REST_HOURS_AFTER` **warning**

### P2-3: Max 2 Shifts/Day
- **File:** `CaLamValidationEngine.java`, `Constants.java`
- **Constant:** `MAX_SHIFTS_PER_DAY = 2`
- **Rule:** Nhân viên không thể có quá 2 ca trong cùng một ngày → `MAX_SHIFTS_PER_DAY` error

### P2-4: Leave Conflicts
- **File:** `CaLamValidationEngine.java`
- **Rules:**
  - Nghỉ phép toàn ngày đã duyệt → `LEAVE_FULL_DAY` error
  - Nghỉ phép nửa ngày đã duyệt → `LEAVE_HALF_DAY` error
  - Nghỉ phép đang chờ duyệt → `LEAVE_PENDING` warning

### P2-5: Availability Placeholder
- **File:** `CaLamValidationEngine.java`
- **Status:** TODO stub — sẽ check `CaLamViecAvailabilityDAO.findByAccountAndDate()` và block nếu nhân viên đăng ký UNAVAILABLE.

---

## IV. Section IV — Facility/Branch Permission

- **File:** `CaLamService.java`, `BranchSecurityUtils.java`
- **Rule:** Manager chỉ được tạo/sửa ca cho cơ sở của mình. `BranchSecurityUtils.checkBranchAccess(targetCoSoId, managerCoSoId)` → `ForbiddenException` (HTTP 403)

---

## V. Section V — Concurrency & Transaction Safety

- **Batch create:** All-or-nothing JDBC transaction (xem P1-3)
- **Single create/update:** Dùng connection riêng của DAO (autocommit)
- **Conflict detection:** Engine query trước khi insert, nhưng race condition vẫn có thể xảy ra trong high-concurrency. TODO: Database-level UNIQUE constraint hoặc SELECT FOR UPDATE.

---

## VI. Section VI — HTTP Status Codes

| Situation | HTTP Status |
|---|---|
| Tạo ca thành công | 201 Created |
| Update/Delete/Publish thành công | 200 OK |
| ValidationException, IllegalArgumentException | 400 Bad Request |
| ForbiddenException (branch mismatch) | 403 Forbidden |
| NotFoundException (nhân viên/ca không tồn tại) | 404 Not Found |
| ConflictException (trùng ca) | 409 Conflict |
| Exception (lỗi hệ thống) | 500 Internal Server Error |

---

## VII. Section VII — Audit Log

Tất cả thao tác đều được ghi vào bảng `CaLamViec_Audit`:

| ThaoTac | Trigger |
|---|---|
| `INSERT` | Tạo ca mới (trong transaction) |
| `UPDATE` | Sửa ca |
| `CANCEL` | Hủy ca |
| `PUBLISH` | Công bố tuần |
| `CLONE` | Nhân bản tuần |
| `AUTO_SCHEDULE` | Tự động sắp lịch |
| `CONFIRM` | Nhân viên xác nhận |
| `CHECK_IN` | Chấm công vào |
| `CHECK_OUT` | Chấm công ra |
| `SWAP` | Đổi ca |

---

## VIII. Section VIII — Test Cases

**File:** `src/main/java/org/example/test/CaLamValidationTest.java`

| TC | Mô tả | Expected | Layer |
|---|---|---|---|
| TC_VALID_01 | Ca sáng 06:00-14:00 hợp lệ | PASS | Engine |
| TC_VALID_02 | Ca chiều 14:00-22:00 hợp lệ | PASS | Engine |
| TC_VALID_03 | Ngày trong quá khứ | `PAST_DATETIME` error | Engine |
| TC_VALID_04 | Ca dưới 60 phút | `MIN_DURATION` error | Engine |
| TC_VALID_05 | Ca vượt 720 phút | `MAX_DURATION_EXCEEDED` error | Engine |
| TC_VALID_06 | breakMinutes âm | `BREAK_MINUTES` error | Engine |
| TC_VALID_07 | breakMinutes >= tổng ca | `BREAK_EXCEEDS_DURATION` error | Engine |
| TC_VALID_08 | Ca 10.5h (cảnh báo) | `MAX_DURATION` warning | Engine |
| TC_VALID_09 | Ca hôm nay, giờ tương lai | Không có `PAST_DATETIME` | Engine |
| TC_VALID_10 | Role KHACH_HANG (id=3) | `ROLE_INCOMPATIBLE` error | Engine (cần DB) |
| TC_VALID_11 | Branch mismatch | `BRANCH_MISMATCH` error | Engine (cần DB) |
| TC_VALID_12 | Engine không crash với HTML | PASS | Engine |
| TC_VALID_13 | ghiChu > 255 ký tự | `ValidationException` | Service/Servlet |
| TC_VALID_14 | Ca đêm (template id=3) | `ValidationException` | Servlet |
| TC_VALID_15 | Đã có 2 ca trong ngày | `MAX_SHIFTS_PER_DAY` error | Engine (cần DB) |
| TC_VALID_16 | Giờ nghỉ < 8h | `REST_HOURS_CRITICAL` error | Engine (cần DB) |
| TC_VALID_17 | Giờ nghỉ 8-12h | `REST_HOURS_BEFORE` warning | Engine (cần DB) |
| TC_VALID_18 | Tổng giờ tuần > 48h | `WEEKLY_LIMIT_OVERTIME` error | Engine (cần DB) |
| TC_VALID_19 | Tổng giờ tháng > 160h | `MONTHLY_LIMIT` error | Engine (cần DB) |
| TC_VALID_20 | Trùng ca | `SHIFT_OVERLAP` error | Engine (cần DB) |
| TC_VALID_21 | Nghỉ phép toàn ngày | `LEAVE_FULL_DAY` error | Engine (cần DB) |
| TC_VALID_22 | Batch transaction rollback | Toàn batch không insert | Service |

**Chạy test:**
```bash
mvn exec:java -Dexec.mainClass=org.example.test.CaLamValidationTest
```

---

## IX. Constants Summary

```java
// src/main/java/org/example/util/Constants.java
MIN_SHIFT_MINUTES = 60        // Net tối thiểu 60 phút
MAX_SHIFT_MINUTES = 720       // Net tối đa 720 phút (12h)
MONTHLY_HOUR_LIMIT_MINUTES = 9600  // 160h/tháng
MAX_SHIFTS_PER_DAY = 2        // Tối đa 2 ca/ngày
MIN_REST_MINUTES = 480        // Nghỉ tối thiểu 8h giữa các ca
WARN_REST_MINUTES = 720       // Cảnh báo nếu nghỉ < 12h
```

---

## X. Files Changed

| File | Thay đổi |
|---|---|
| `util/Constants.java` | Thêm 6 shift limit constants |
| `util/CaLamValidationEngine.java` | Min/max duration, rest hours 8h error, max 2/day, monthly 160h, availability TODO |
| `service/manager/CaLamService.java` | Batch transaction, duplicate dates check, sanitizeText, clone/auto-schedule stubs |
| `controller/QuanLyCaLamManagerServlet.java` | ghiChu length check, Ca đêm block |
| `dao/CaLamViecDAO.java` | `addCaLamViecWithConnection()` interface method |
| `dao/impl/CaLamViecDAOImpl.java` | `addCaLamViecWithConnection()` with RETURN_GENERATED_KEYS |
| `dao/CaLamViecAuditDAO.java` | `insertWithConnection()` interface method |
| `dao/impl/CaLamViecAuditDAOImpl.java` | `insertWithConnection()` implementation |
| `test/CaLamValidationTest.java` | 22 test cases (mới) |
