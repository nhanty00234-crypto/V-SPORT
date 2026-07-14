# Kế Hoạch Dọn Dẹp Service & Exception Sau Đánh Giá (Post-Evaluation Cleanup Roadmap)

Tài liệu này đề xuất lộ trình 6 giai đoạn (6 batches) nhằm tái cấu trúc triệt để lớp Service và cơ chế xử lý Exception sau khi giai đoạn đánh giá này hoàn tất và được trưởng nhóm thông qua.

---

## Giai Đoạn 1: Tách SQL Thô Ra Khỏi Lớp Service
- **Hiện trạng**: Một số service (`BookingLifecycleService.java`, `SanService.java`) đang trực tiếp thực thi các truy vấn SQL thô thông qua JDBC Connection và PreparedStatement.
- **Giải pháp**: 
  - Di chuyển toàn bộ các câu lệnh SQL thô này xuống các lớp DAO tương ứng (ví dụ: `LichDatSanDAOImpl`, `SanDAOImpl`).
  - Lớp Service chỉ gọi phương thức DAO để thực hiện nghiệp vụ, giữ lớp Service hoàn toàn độc lập với các chi tiết cài đặt SQL.

## Giai Đoạn 2: Chuẩn Hóa Cơ Chế Lan Truyền Ngoại Lệ (Exception Propagation)
- **Hiện trạng**: Chỉ có module Quản lý ca làm việc (`QuanLyCaLamManagerServlet`) đang sử dụng và bắt các Exception tùy chỉnh (`ConflictException`, `ValidationException`, v.v.). Các servlet khác vẫn đang dùng cơ chế trả về `boolean` hoặc chuỗi lỗi thủ công.
- **Giải pháp**:
  - Cấu trúc lại toàn bộ các Servlet khác (`DatSanServlet`, `CheckInServlet`, `YeuCauNghiManagerServlet`, v.v.) để sử dụng các ngoại lệ tùy chỉnh khi phát hiện lỗi nghiệp vụ.
  - Thiết kế một Exception Filter hoặc BaseServlet dùng chung để tự động bắt các exception này và map thành HTTP Status phù hợp, tránh trùng lặp code try-catch ở từng Servlet.

## Giai Đoạn 3: Quản Lý Giao Dịch (Transaction Management) Tập Trung
- **Hiện trạng**: Việc quản lý Transaction đang được làm thủ công bằng cách mở Connection trong `CaLamService` rồi truyền Connection đó xuống các hàm DAO.
- **Giải pháp**:
  - Chuyển đổi cơ chế quản lý Transaction sang Unit of Work hoặc tích hợp Spring `@Transactional` (nếu dự án chuyển hướng lên Spring Boot).
  - Đảm bảo DAO không nhận Connection từ ngoài mà lấy tự động thông qua Transaction Manager.

## Giai Đoạn 4: Đồng Nhất Các Lớp Validation
- **Hiện trạng**: Đang tồn tại song song cả `ValidationUtil` và `ValidationUtils` trong dự án dẫn đến trùng lặp mã nguồn và khó bảo trì.
- **Giải pháp**:
  - Gộp hai lớp này làm một helper duy nhất (`ValidationUtils`).
  - Chuẩn hóa các quy tắc kiểm định dữ liệu đầu vào (Email, số điện thoại, ngày tháng) trên toàn hệ thống.

## Giai Đoạn 5: Tách Biệt Hoàn Toàn DTO và Model
- **Hiện trạng**: Các service đang nhận/trả trực tiếp các thực thể Database Model (như `TaiKhoan`, `CaLamViec`, `San`).
- **Giải pháp**:
  - Áp dụng triệt để DTO (Data Transfer Object) cho toàn bộ API và đầu vào/đầu ra của lớp Service.
  - Tránh rò rỉ cấu trúc Database Model lên các Controller và giao diện người dùng.

## Giai Đoạn 6: Thiết Lập Scheduler / Background Thread Thực Sự
- **Hiện trạng**: Logic tự động quét hủy đơn đặt sân quá hạn (`BookingLifecycleService.runExpirySweep()`) đang được gọi kiểu "on-read" khi người dùng truy cập trang, do dự án chưa có công cụ chạy ngầm.
- **Giải pháp**:
  - Sử dụng Java `ScheduledExecutorService` hoặc tích hợp thư viện Quartz Scheduler để chạy ngầm định kỳ (ví dụ: mỗi 1 phút).
  - Tách biệt hoàn toàn việc quét dọn đơn hàng hết hạn khỏi luồng request của người dùng, nâng cao hiệu năng hệ thống.
