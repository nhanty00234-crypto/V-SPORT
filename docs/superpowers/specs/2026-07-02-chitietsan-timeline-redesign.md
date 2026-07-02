# ChiTietSan — Timeline Redesign

**Date:** 2026-07-02  
**Scope:** Phương án B — Horizontal timeline time picker + full-page layout improvements  
**File:** `src/main/webapp/customer/ChiTietSan.jsp`

---

## Problem

1. Time grid dùng 3-column chip, max-h 200px với `hide-scroll` → người dùng không biết còn slot bên dưới.
2. Cơ chế 2-click (click 1 = start, click 2 = end) không có hướng dẫn, khó đoán.
3. Hero chiếm 480px → booking widget bị đẩy xuống dưới fold trên laptop.
4. Mobile: booking widget nằm sau toàn bộ thông tin sân, người dùng phải scroll dài.

---

## Design Decisions

### 1. Horizontal timeline bar (thay chip grid)

- Thanh ngang hiển thị toàn bộ giờ mở cửa (ví dụ 06:00–23:00) trong một tầm nhìn.
- Màu segments: xanh nhạt = trống, đỏ nhạt = đã đặt, xám = giờ đã qua, xanh đậm = đang chọn.
- Tương tác:
  - **Click lần 1** vào vùng trống → đặt điểm bắt đầu (hiện marker + tooltip giờ).
  - **Click lần 2** → đặt điểm kết thúc, tô màu range.
  - Sau khi có cả start + end: hai **drag handles** (circle trắng viền xanh) xuất hiện ở hai đầu, kéo để điều chỉnh, snap về interval 30 phút.
  - Không cho click/drag vào vùng đã đặt hoặc giờ quá.
- Dưới bar: dòng tóm tắt `"10:00 – 12:00 · 2 tiếng"` + nút Xóa để reset.

### 2. Date navigation (thay input[type=date])

- Row `‹ [T4, 02/07/2026] ›` có background xanh nhạt.
- Nút ← disabled khi ngày hiện tại = hôm nay.
- Thay đổi ngày → reset selectedStart/End → re-render timeline.
- `<input type="hidden" name="ngayDat">` giữ cho form submit vẫn hoạt động.

### 3. Hero height

- Giảm từ `md:h-[480px]` → `md:h-[300px]` để booking widget hiển thị trong viewport mà không cần scroll.

### 4. Mobile ordering

- Booking widget: `order-1 lg:order-2` → hiển thị ngay sau hero trên mobile.
- Info col: `order-2 lg:order-1`.

### 5. Column widths

- Info: `lg:w-[62%]`, Booking: `lg:w-[38%]` (tăng nhẹ từ 1/3 để timeline có đủ chỗ).

---

## State Machine (Time Picker)

```
EMPTY
  → click available slot  → PENDING_START (start set, end=null)

PENDING_START
  → click slot > start     → COMPLETE (both set)
  → click slot ≤ start     → PENDING_START (move start)

COMPLETE
  → drag start handle      → COMPLETE (start updated, live)
  → drag end handle        → COMPLETE (end updated, live)
  → click bar              → PENDING_START (reset and new start)
  → click "Xóa"           → EMPTY
```

---

## Validation (giữ nguyên từ code cũ)

- Overlap check: `hasRangeConflict(selectedStartMin, selectedEndMin)` so sánh với `activeBookings[]`.
- Nếu có conflict → hiện `#overlap-warning`, disable submit.
- Submit button chỉ enabled khi: có user session + có start + có end + không conflict.

---

## Files Changed

| File | Loại thay đổi |
|------|--------------|
| `src/main/webapp/customer/ChiTietSan.jsp` | Rewrite layout + JS time picker |

Không thay đổi backend, servlet, DAO, hay bất kỳ file Java nào.
