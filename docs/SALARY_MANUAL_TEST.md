# Kiểm thử thủ công — Module tính lương

**Chuẩn bị**
1. Chạy `sql/migration_salary.sql` trên database (bắt buộc — `TaiKhoan` là JPA entity nên
   thiếu cột `Accounts.QrImagePath` sẽ làm hỏng mọi truy vấn tài khoản).
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

## 7. Điều hướng
- [ ] Sidebar manager, nhóm "Nhân sự" → có mục "Quản lý lương", tự mở khi đang ở trang lương.
- [ ] Sidebar staff, nhóm "Cá nhân" → có mục "Lương của tôi".
- [ ] Sidebar guard, nhóm "Công việc" → có mục "Lương của tôi".
