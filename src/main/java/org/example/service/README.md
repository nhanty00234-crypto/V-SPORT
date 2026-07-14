# Thư mục Service - Lớp Xử Lý Nghiệp Vụ (Business Logic Layer)

Thư mục này chứa toàn bộ các lớp nghiệp vụ chính của ứng dụng V-SPORT.

## 1. Mục Đích & Vai Trò
- **Tập trung hóa nghiệp vụ**: Đảm bảo tất cả các quy tắc nghiệp vụ (validation, tính toán giá, kiểm tra trùng lịch, cập nhật trạng thái) được viết tập trung tại một nơi duy nhất.
- **Tách biệt mối quan tâm (Separation of Concerns)**: Các Controller (Servlet) chỉ làm nhiệm vụ điều hướng, phân tích request parameters và trả về response (HTML/JSON). Toàn bộ xử lý nghiệp vụ phức tạp và giao tiếp DB (thông qua DAO) được giao cho lớp Service.
- **Độc lập nền tảng**: Lớp Service không được giữ bất kỳ tham chiếu trực tiếp nào tới các đối tượng HTTP Servlet (`HttpServletRequest`, `HttpServletResponse`, `HttpSession`) trừ lớp ghi log hệ thống (`AuditLogService` cần IP/User Agent từ request).

## 2. Quy Tắc Hoạt Động & Phát Triển
1. **Không xử lý HTTP**: Ngoại trừ `AuditLogService`, các service khác không được import các package `jakarta.servlet.*` hay xử lý request/response trực tiếp.
2. **Quản lý Transaction**: Đối với các nghiệp vụ phức tạp đòi hỏi cập nhật nhiều bảng cùng lúc (như hoán đổi ca làm, duyệt nghỉ phép tự động xóa ca làm), cần truyền JDBC `Connection` từ Service xuống các hàm DAO tương ứng và quản lý commit/rollback tập trung tại Service.
3. **Ném Exception thay vì trả về null/false**: Khi dữ liệu đầu vào không hợp lệ hoặc vi phạm quy tắc kinh doanh, hãy ném các ngoại lệ nghiệp vụ tương ứng (`ValidationException`, `ConflictException`, `NotFoundException`, `ForbiddenException`) để Controller bắt và xử lý.

## 3. Từ Điển Tra Cứu Phương Thức (Method Dictionary)

### 3.1. [PayOSService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/PayOSService.java)
- `getInstance()`: Lấy thể hiện duy nhất (Singleton Instance) của dịch vụ PayOS.
- `createCheckoutUrl(...)`: Tạo đường dẫn thanh toán trực tuyến PayOS (trả về URL thanh toán).
- `createCheckoutSession(...)`: Tạo phiên thanh toán đầy đủ chứa thông tin QR Code tĩnh và thời hạn thanh toán.
- `verifyWebhook(...)`: Xác thực webhook nhận từ PayOS thông qua SDK kiểm tra chữ ký HMAC.

### 3.2. [YeuCauNghiService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/YeuCauNghiService.java)
- `createYeuCauNghi(...)`: Tạo đơn xin nghỉ phép mới kèm kiểm tra hạn mức (tối đa 4 ngày/tháng).
- `approveYeuCauNghi(...)`: Phê duyệt đơn xin nghỉ phép, tự động hủy ca làm của nhân viên đó trong ngày nghỉ và gửi thông báo.
- `rejectYeuCauNghi(...)`: Từ chối đơn xin nghỉ phép kèm theo lý do từ quản lý.
- `cancelYeuCauNghi(...)`: Nhân viên tự hủy đơn xin nghỉ phép khi đơn ở trạng thái chờ duyệt.
- `getUpcomingYeuCauNghiByAccount(...)` (`getUpcomingLeaves`): Lấy danh sách các đơn nghỉ phép sắp diễn ra trong tương lai của nhân viên.

### 3.3. [CaLamService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/manager/CaLamService.java)
- `createShift(...)`: Lập lịch ca làm việc mới cho nhân viên.
- `updateShift(...)`: Cập nhật thông tin ca làm việc (nhân sự, thời gian, lý do thay đổi).
- `deleteShift(...)` (`cancelShift`): Hủy/Xóa lịch ca làm việc của nhân viên.
- `cloneWeekShifts(...)`: Nhân bản toàn bộ ca làm việc của tuần trước sang tuần kế tiếp.
- `publishWeekShifts(...)`: Công bố lịch làm việc chính thức trong tuần để nhân viên có thể xem được.
- `autoScheduleShifts(...)`: Tự động phân bổ lịch làm việc dựa trên mức độ rảnh rỗi và vị trí của nhân sự.
- `approveSwapRequest(...)`: Phê duyệt yêu cầu đổi ca của nhân viên và hoán đổi vị trí nhân sự trong ca làm.
- `rejectSwapRequest(...)`: Từ chối yêu cầu đổi ca làm việc.

### 3.4. [NhanSuService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/manager/NhanSuService.java)
- `getStaffListByBranch(...)` (`getAvailableStaffForShift`): Lấy danh sách nhân viên đang làm việc của chi nhánh.
- `updateStaff(...)` (`lockNhanSu` / `unlockNhanSu`): Cập nhật thông tin hoặc Khóa/Mở khóa tài khoản nhân viên nhanh dựa trên trạng thái `isLocked`.

### 3.5. [SanService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/manager/SanService.java)
- `createSan(...)`: Thêm sân thi đấu mới thuộc chi nhánh quản lý.
- `updateSan(...)`: Chỉnh sửa thông tin tên, hình ảnh, loại sân của sân thi đấu.
- `updateSanStatus(...)` (`lockSan` / `unlockSan`): Khóa sân (Tạm đóng/Bảo trì) hoặc mở khóa sân (Sẵn sàng) sau khi kiểm tra điều kiện an toàn.
- `checkActiveBookingsForStatusChange(...)` (`checkActiveBookings`): Kiểm tra xem có ca đặt sân nào đang hoạt động trên sân thi đấu đó hay không.
- `updateLoaiSan(...)`: Cập nhật cấu hình bảng giá và giờ hoạt động của loại sân.

### 3.6. [BookingLifecycleService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/BookingLifecycleService.java)
- `runExpirySweep()`: Quét và tự động chuyển các đơn đặt sân quá hạn giữ chỗ thanh toán từ "Chờ thanh toán" sang "Quá hạn".

### 3.7. [AuditLogService](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/service/AuditLogService.java)
- `log(...)`: Lưu nhật ký thao tác nghiệp vụ quan trọng (Ai thực hiện, Thao tác gì, Thực thể nào chịu tác động, IP, User Agent).

## 4. Danh Sách Nghiệp Vụ Chưa Được Refactor (Đang Bị Đóng Băng)
Để tránh rủi ro phá vỡ hệ thống, các nghiệp vụ sau **tuyệt đối không được tự ý cấu trúc lại** trong giai đoạn dọn dẹp này:
1. **Nghiệp vụ đặt sân chính (`DatSanServlet`)**: Chứa logic kiểm tra đè giờ phức tạp, giao dịch chuyển tiền trực tiếp và kiểm tra trùng ca.
2. **Nghiệp vụ điểm danh check-in (`CheckInServlet`)**: Ràng buộc chặt chẽ với múi giờ thực tế, kiểm tra vị trí địa lý của nhân sự.
3. **Logic quản lý giao dịch và tự động lập lịch (`CaLamService` & `CaLamValidationEngine`)**: Thuật toán xếp lịch tự động có độ phức tạp cao, ảnh hưởng trực tiếp đến giờ làm của toàn bộ nhân viên.
4. **Cơ chế lan truyền ngoại lệ (Exception Propagation)**: Hiện tại chỉ được tích hợp thử nghiệm tại module Quản lý ca làm việc (`QuanLyCaLamManagerServlet`).
