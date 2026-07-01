# Redesign form "Đặt Sân Nhanh" trong ChiTietSan.jsp

## Bối cảnh
Trang chi tiết sân (`customer/ChiTietSan.jsp`) có form đặt sân nhanh ở cột phải. Form hiện tại dùng 2 `<select>` dropdown cho giờ bắt đầu/kết thúc và các trường xếp chồng không phân nhóm rõ ràng, gây cảm giác dồn cục, khó quét mắt và khó thấy trực quan khung giờ trống/bận.

## Mục tiêu
Tổ chức lại bố cục form thành 3 nhóm rõ ràng có phân cấp thị giác, và thay 2 dropdown giờ bằng lưới chip giờ trực quan (chọn giờ bắt đầu/kết thúc bằng cách bấm chip), không thay đổi logic nghiệp vụ backend (soft-hold, overlap-check, submit).

## Phạm vi
- Chỉ sửa: `src/main/webapp/customer/ChiTietSan.jsp` (HTML/Tailwind + JS trong cùng file).
- Không đổi: servlet `DatSanServlet`, `GiuChoTamServlet`, DAO, cấu trúc dữ liệu `activeBookings`, tên field form (`sanId`, `ngayDat`, `gioBatDau`, `gioKetThuc`, `ghiChu`, `paymentMethod`) — để không phá vỡ submit/validation phía server.

## Thiết kế

### Nhóm 1 — Thời gian
- Giữ input `ngayDat` ở vị trí đầu, style hiện tại.
- Thay 2 `<select>` bằng lưới chip giờ (button 30 phút/ô, wrap nhiều dòng, khu vực có `max-height` + scroll nếu quá dài):
  - Trạng thái: **available** (trắng/viền nhạt, click được), **past** (xám, disabled), **booked** (đỏ nhạt, disabled).
  - Chọn giờ bắt đầu: click 1 chip → chip đó active (viền xanh đậm, nền xanh nhạt) là giờ bắt đầu; các chip từ đó tới slot bận/đóng cửa tiếp theo được đánh dấu "khả dụng làm giờ kết thúc".
  - Chọn giờ kết thúc: click chip thứ 2 (sau giờ bắt đầu) → tất cả chip nằm giữa 2 mốc tô nền xanh nhạt thể hiện khung đã chọn.
  - Bấm lại vào chip giờ bắt đầu đang chọn sẽ reset lựa chọn (bắt đầu lại từ đầu).
  - 2 input `<select name="gioBatDau">` / `<select name="gioKetThuc">` gốc vẫn tồn tại trong DOM ở dạng `hidden`/hoặc chuyển thành `<input type="hidden">` được set giá trị bằng JS khi user chọn chip — để submit form không đổi field name.
  - Dòng tóm tắt text ngay dưới lưới: "Bạn chọn: HH:MM - HH:MM (X tiếng Y phút)" — ẩn nếu chưa chọn đủ 2 mốc.
  - Bỏ khối "Lịch bận trong ngày" (`#timetable-block`) riêng biệt — thông tin bận đã thể hiện trực tiếp qua màu chip.

### Nhóm 2 — Ghi chú yêu cầu
- Giữ nguyên textarea `ghiChu`, thu gọn spacing để đồng bộ nhóm.

### Nhóm 3 — Thanh toán & Xác nhận
- Giữ 2 thẻ chọn phương thức thanh toán (`paymentMethod`) như hiện tại.
- Thêm dòng "Tạm tính" hiển thị `giá/giờ × số giờ đã chọn`, định dạng tiền VNĐ, cập nhật realtime khi chọn giờ. Giá lấy từ `loai.giaKhongDen` đã render sẵn trong trang (biến JS `pricePerHour`).
- Nút submit / link đăng nhập giữ nguyên logic hiện có.

### Phân tách thị giác giữa 3 nhóm
- Nhóm 1 & 2: nền `bg-slate-50/60`, bo góc `rounded-2xl`, padding, tiêu đề nhỏ uppercase kèm số thứ tự ("1. Chọn thời gian", "2. Ghi chú yêu cầu").
- Nhóm 3: nền trắng, viền trên `border-t` đậm hơn để tách biệt là bước cuối/quan trọng nhất.

## Thay đổi JS
- `applyTimeConstraints()`: build danh sách slot 30 phút (giữ nguyên nguồn dữ liệu `activeBookings`, `branchOpenTime/CloseTime`, `todayStr`) nhưng render ra chip (button) thay vì `<option>`.
- Thêm state 2 biến JS: `selectedStartMin`, `selectedEndMin` để track lựa chọn hiện tại qua chip.
- `renderTimeGrid()` (hàm mới): vẽ lại toàn bộ lưới chip dựa trên state hiện tại (available/past/booked/selected-range), gọi lại mỗi khi ngày đổi hoặc lựa chọn đổi.
- `onChipClick(minutes)` (hàm mới): xử lý logic chọn giờ bắt đầu/kết thúc/reset, set giá trị vào 2 hidden input `gioBatDau`/`gioKetThuc`, gọi `checkSchedule()` hiện có để giữ nguyên validate overlap + enable/disable nút submit + gọi soft-hold (nếu có hook sẵn không đổi).
- `checkSchedule()`: bỏ phần code cập nhật `#timetable-block`/`#timeline-slots` (đã xóa khối này khỏi HTML), giữ nguyên phần disable nút & overlap-warning.
- Thêm `updateEstimatedPrice()`: tính và render "Tạm tính" mỗi khi `selectedStartMin`/`selectedEndMin` thay đổi.

## Rủi ro & lưu ý
- Phải đảm bảo hidden input `gioBatDau`/`gioKetThuc` luôn có giá trị đúng format `HH:MM` trước khi submit, đúng như dropdown cũ, để không phá server-side parsing.
- Giữ nguyên `id`/`name` các field để JS `onDateChange`, integration với soft-hold (nếu file JS khác tham chiếu `document.getElementById('gioBatDau').value`) không bị vỡ — kiểm tra lại đoạn code liên quan soft-hold trong cùng file trước khi sửa.
- Không có thay đổi backend nên không cần rebuild logic server, chỉ cần build lại WAR để deploy xem kết quả.

## Ngoài phạm vi
- Không đổi phần gallery, mô tả sân, tiện ích, sân tương tự ở cột trái.
- Không đổi cơ chế Soft-Hold, PayOS, hay bất kỳ servlet nào.
