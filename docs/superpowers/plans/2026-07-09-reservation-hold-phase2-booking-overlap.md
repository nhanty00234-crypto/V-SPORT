# Reservation Hold — Phase 2 (Booking Overlap-Check + Real HoldExpiresAt) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `DatSanServlet.handleDatSan` set a real `HoldExpiresAt` on `"Chờ thanh toán"` bookings and use it (instead of the `DATEDIFF`-from-`CreatedTime` heuristic) in the overlap-check, and make the overlap-check block `"Chờ xác nhận"` while no longer blocking `"Đã hoàn thành"` — per spec section 7 and this phase's explicit instructions.

**Architecture:** Two localized edits inside the existing lock → validate → overlap-check → insert transaction block of `handleDatSan` (`DatSanServlet.java:304-535`). No new methods, no new files besides one `Constants.java` addition. The locking pattern (`SELECT San WITH (UPDLOCK, ROWLOCK)`), the retry loop, and every other validation step are untouched.

**Tech Stack:** Java 17, JDBC (`PreparedStatement`), SQL Server (T-SQL).

## Global Constraints

- Do not rewrite `DatSanServlet` — touch only the overlap-check SQL block (`DatSanServlet.java:407-434`) and the insert block (`DatSanServlet.java:501-521`).
- Do not touch `CheckInDAO`, any JSP, the scheduler, or `confirmBookingPayment` — none of those exist yet / are out of scope for this phase.
- Do not rename or remove `Constants.TRANG_THAI_DAT_SAN_DANG_CHOI` ("Đang chơi") — it is unused elsewhere in the codebase but must be left exactly as-is.
- `HoldExpiresAt` is computed only via SQL Server `GETDATE()`/`DATEADD` server-side — never read from any request parameter.
- Blocking statuses in the overlap-check: `"Đã xác nhận"`, `"Đang sử dụng"`, `"Chờ xác nhận"`, and `"Chờ thanh toán"` only while `HoldExpiresAt > GETDATE()`. Non-blocking: `"Quá hạn"`, `"Đã hủy"`, `"Đã hoàn thành"`, and expired `"Chờ thanh toán"`.
- No hard-coded minute values — use `Constants.BOOKING_HOLD_MINUTES`.

---

### Task 1: Add `Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG`

**Files:**
- Modify: `src/main/java/org/example/util/Constants.java`

**Interfaces:**
- Produces: `Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG` (String = `"Đang sử dụng"`) — consumed by Task 2's overlap-check SQL.

- [ ] **Step 1: Add the constant next to the Phase 1 reservation-hold block**

In `src/main/java/org/example/util/Constants.java`, edit the `BOOKING (LichDatSan) STATUS` block (currently lines 16-25):

```java
    // ========== BOOKING (LichDatSan) STATUS ==========
    public static final String TRANG_THAI_DAT_SAN_CHO_XAC_NHAN = "Chờ xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_XAC_NHAN = "Đã xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_HUY = "Đã hủy";
    public static final String TRANG_THAI_DAT_SAN_DANG_CHOI = "Đang chơi";
    public static final String TRANG_THAI_DAT_SAN_DA_HOAN_THANH = "Đã hoàn thành";
    // Reservation-hold (docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md, mục 4)
    public static final String TRANG_THAI_DAT_SAN_CHO_THANH_TOAN = "Chờ thanh toán";
    public static final String TRANG_THAI_DAT_SAN_QUA_HAN = "Quá hạn";
    public static final String TRANG_THAI_DAT_SAN_KHONG_DEN = "Không đến";
    // Literal thực tế dùng trong CheckInDAO/CheckInServlet/LichDatSanDAOImpl khi booking đang được chơi.
    // KHÁC với TRANG_THAI_DAT_SAN_DANG_CHOI ("Đang chơi") ở trên — hằng số đó không được dùng ở đâu
    // trong code hiện tại, giữ nguyên không đổi/không xoá (rà soát toàn bộ codebase, 2026-07-09).
    public static final String TRANG_THAI_DAT_SAN_DANG_SU_DUNG = "Đang sử dụng";
```

Do **not** touch `TRANG_THAI_DAT_SAN_DANG_CHOI` — leave its line exactly as it is.

- [ ] **Step 2: Verify no duplicate constant name and no logic change to `DANG_CHOI`**

Run: `grep -n "TRANG_THAI_DAT_SAN_DANG_SU_DUNG\|TRANG_THAI_DAT_SAN_DANG_CHOI" src/main/java/org/example/util/Constants.java`
Expected: exactly 1 line for `TRANG_THAI_DAT_SAN_DANG_SU_DUNG` (`= "Đang sử dụng"`), exactly 1 line for `TRANG_THAI_DAT_SAN_DANG_CHOI` (`= "Đang chơi"`, unchanged).

Then run yourself (sandbox has no `mvn`): `mvn -q -pl . compile` → expect `BUILD SUCCESS`.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/util/Constants.java
git commit -m "Add TRANG_THAI_DAT_SAN_DANG_SU_DUNG constant for the actual in-use booking status literal"
```

---

### Task 2: Real `HoldExpiresAt` + corrected overlap-check in `DatSanServlet.handleDatSan`

**Files:**
- Modify: `src/main/java/org/example/controller/DatSanServlet.java:407-434` (overlap-check block)
- Modify: `src/main/java/org/example/controller/DatSanServlet.java:501-521` (insert block)
- Modify: `src/main/java/org/example/controller/DatSanServlet.java:541-547` (flash message — minor, uses the same constant so the "10 phút" text can never drift from the real hold duration)

**Interfaces:**
- Consumes: `Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN`, `Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN`, `Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG`, `Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN`, `Constants.BOOKING_HOLD_MINUTES` (all from Task 1 / Phase 1).
- Produces: nothing new consumed by other tasks — this is the terminal change for this phase. Later phases (payment confirm, auto-expire sweep) will read the `HoldExpiresAt` column this task starts populating.

- [ ] **Step 1: Replace the overlap-check block**

In `src/main/java/org/example/controller/DatSanServlet.java`, replace lines 407-434 (the `── 3d. Kiểm tra trùng lịch (Overlap check) ──` block):

```java
                    // ── 3d. Kiểm tra trùng lịch (Overlap check) ──
                    // Công thức overlap: NOT (KetThuc <= BatDau_Khac OR BatDau >= KetThuc_Khac)
                    // "Chờ xác nhận" (COD) chặn slot cho tới khi được duyệt/từ chối/tự hết hạn.
                    // "Chờ thanh toán" chỉ chặn khi còn hạn giữ chỗ thật (HoldExpiresAt), không còn
                    // dùng DATEDIFF(CreatedTime) giả nữa.
                    // "Đã hoàn thành"/"Quá hạn"/"Đã hủy" không chặn — booking cho NgayDat/GioBatDau
                    // trong quá khứ đã bị validate ở Bước 2b phía trên rồi nên không cần chặn lại ở đây.
                    String checkSql = "SELECT COUNT(*) FROM LichDatSan " +
                            "WHERE SanID = ? AND NgayDat = ? " +
                            "AND (TrangThai IN (N'" + org.example.util.Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN + "', " +
                            "N'" + org.example.util.Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG + "', " +
                            "N'" + org.example.util.Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN + "') " +
                            "     OR (TrangThai = N'" + org.example.util.Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN + "' AND HoldExpiresAt > GETDATE())) " +
                            "AND NOT (GioKetThuc <= CAST(? AS time) OR GioBatDau >= CAST(? AS time))";

                    boolean hasOverlap;
                    try (java.sql.PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                        checkPs.setInt(1, sanId);
                        checkPs.setDate(2, java.sql.Date.valueOf(ngayDat));
                        checkPs.setString(3, gioBatDau.toString()); // KetThuc <= BatDauNew => không overlap
                        checkPs.setString(4, gioKetThuc.toString()); // BatDau >= KetThucNew => không overlap
                        try (java.sql.ResultSet rs = checkPs.executeQuery()) {
                            hasOverlap = rs.next() && rs.getInt(1) > 0;
                        }
                    }

                    if (hasOverlap) {
                        conn.rollback();
                        session.setAttribute("error",
                                "Khung giờ " + gioBatDau.toString().substring(0, 5) + " - " +
                                        gioKetThuc.toString().substring(0, 5) +
                                        " đã có người đặt cho sân này. Vui lòng chọn khung giờ khác.");
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }
```

Note: the `hasOverlap` error-message text is left exactly as it was (this phase does not change user-facing copy).

- [ ] **Step 2: Verify the new overlap SQL by manual trace**

This sandbox cannot run the app against a real DB, so trace it by hand against 4 cases from the plan's Global Constraints:
1. Existing row `TrangThai='Đã xác nhận'`, overlapping time → `TrangThai IN (...)` matches → blocks. Correct (must block).
2. Existing row `TrangThai='Chờ thanh toán'`, `HoldExpiresAt` = 5 minutes in the future, overlapping time → second `OR` branch: `HoldExpiresAt > GETDATE()` is true → blocks. Correct (must block).
3. Existing row `TrangThai='Chờ thanh toán'`, `HoldExpiresAt` = 5 minutes in the past, overlapping time → second `OR` branch false, first `IN (...)` doesn't include `'Chờ thanh toán'` → no match → does not block. Correct (must NOT block).
4. Existing row `TrangThai='Đã hoàn thành'`, overlapping time → not in the `IN (...)` list, not `'Chờ thanh toán'` → no match → does not block. Correct (must NOT block, matches this phase's explicit requirement).

- [ ] **Step 3: Replace the insert block to compute `initialStatus` once and add `HoldExpiresAt`**

In the same file, replace lines 501-521 (the `── 3f. INSERT lịch đặt sân trong cùng transaction ──` block):

```java
                    // ── 3f. INSERT lịch đặt sân trong cùng transaction ──
                    boolean isOnlineDeposit = "payos".equalsIgnoreCase(paymentMethod);
                    String initialStatus = isOnlineDeposit
                            ? org.example.util.Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN
                            : org.example.util.Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN;
                    // HoldExpiresAt luôn tính bằng GETDATE() phía SQL Server, không bao giờ nhận từ
                    // frontend/request — Constants.BOOKING_HOLD_MINUTES là hằng số compile-time, không
                    // phải input người dùng, nên nối trực tiếp vào SQL an toàn (không có rủi ro injection).
                    String holdExpiresAtExpr = isOnlineDeposit
                            ? "DATEADD(MINUTE, " + org.example.util.Constants.BOOKING_HOLD_MINUTES + ", GETDATE())"
                            : "NULL";

                    String insertSql = "INSERT INTO LichDatSan " +
                            "(AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, " +
                            " ApDungGiaCoDen, TongTienDuKien, TrangThai, GhiChu, NguonDatSan, HoldExpiresAt) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " + holdExpiresAtExpr + ")";

                    try (java.sql.PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setInt(1, user.getAccountId());
                        insertPs.setInt(2, sanId);
                        insertPs.setDate(3, java.sql.Date.valueOf(ngayDat));
                        insertPs.setTime(4, java.sql.Time.valueOf(gioBatDau));
                        insertPs.setTime(5, java.sql.Time.valueOf(gioKetThuc));
                        insertPs.setBoolean(6, applyLights);
                        insertPs.setBigDecimal(7,
                                BigDecimal.valueOf(tongTien).setScale(0, java.math.RoundingMode.HALF_UP));
                        insertPs.setString(8, initialStatus);
                        insertPs.setString(9, ghiChu != null ? ghiChu.trim() : "");
                        insertPs.setString(10, "Web");
                        insertPs.executeUpdate();
                    }
```

- [ ] **Step 4: Use the same `isOnlineDeposit` flag in the flash-message branch (avoid re-deriving it, and stop hard-coding "10 phút")**

In the same file, replace lines 541-547:

```java
                    if (isOnlineDeposit) {
                        session.setAttribute("message",
                                "Đăng ký đặt sân thành công! Vui lòng tiến hành quét mã QR thanh toán trong vòng " +
                                        org.example.util.Constants.BOOKING_HOLD_MINUTES + " phút để giữ chỗ.");
                    } else {
                        session.setAttribute("message",
                                "Đặt sân thành công! Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.");
                    }
```

This replaces the old `"payos".equalsIgnoreCase(paymentMethod)` re-check with the `isOnlineDeposit` variable already computed in Step 3 — same behavior, one less duplicated string comparison.

- [ ] **Step 5: Verify compilation and re-check no leftover raw "Chờ thanh toán"/"Chờ xác nhận" ternary**

Run yourself: `mvn -q -pl . compile` → expect `BUILD SUCCESS`.

Manual substitute check in this sandbox:
```bash
grep -n '"payos".equalsIgnoreCase(paymentMethod)' src/main/java/org/example/controller/DatSanServlet.java
```
Expected: exactly 2 matches — the original parse/validation checks near the top of `handleDatSan` (input parsing at line ~240, enum validation at line ~251) which are untouched by this task, and the new `boolean isOnlineDeposit = ...` assignment from Step 3. There must be **no** remaining `"payos".equalsIgnoreCase(paymentMethod) ? "Chờ thanh toán" : "Chờ xác nhận"` ternary duplicating the check a 3rd/4th time.

```bash
grep -n 'HoldExpiresAt' src/main/java/org/example/controller/DatSanServlet.java
```
Expected: appears in the overlap-check SQL (Step 1) and the insert SQL + `holdExpiresAtExpr` (Step 3).

- [ ] **Step 6: Commit**

```bash
git add src/main/java/org/example/controller/DatSanServlet.java
git commit -m "Use real HoldExpiresAt for reservation holds and fix overlap-check blocking set

Overlap-check now blocks Đã xác nhận / Đang sử dụng / Chờ xác nhận, and
Chờ thanh toán only while HoldExpiresAt > GETDATE() (replacing the old
DATEDIFF(CreatedTime) heuristic). Đã hoàn thành no longer blocks (already
covered by the past-date/time validation earlier in the same method).
New online-deposit bookings get HoldExpiresAt = now + BOOKING_HOLD_MINUTES,
computed server-side only; COD bookings are unaffected."
```

---

## Self-Review Notes

- **Spec coverage**: Task 2 Step 1 implements spec section 7's overlap-check exactly (including the explicit "không chặn Đã hoàn thành" requirement from this phase's instructions, which sharpens the original spec text). Task 2 Steps 3-4 implement spec section 7's insert + "bất biến bắt buộc" (server-only `HoldExpiresAt`). Task 1 implements this phase's item 4 (Constants audit) without violating the explicit "don't touch `DANG_CHOI`" constraint.
- **Out of scope, confirmed not touched by any task**: `CheckInDAO`, JSP/UI, scheduler, `confirmBookingPayment`, `duyetLichDatSan`/`tuChoiLichDatSan`, audit logging (see phase report for why `CREATE_HOLD_BOOKING` was deferred rather than guessed at).
- **Placeholder scan**: no TBD/TODO; every step shows exact code.
- **Type consistency**: `isOnlineDeposit` is a `boolean` introduced once in Step 3 and reused identically in Step 4 — no re-derivation, no naming drift.
