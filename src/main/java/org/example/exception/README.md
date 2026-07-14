# Thư mục Exception - Lớp Ngoại Lệ Nghiệp Vụ (Business Exceptions)

Thư mục này chứa toàn bộ các lớp ngoại lệ tự định nghĩa (custom runtime exceptions) của ứng dụng V-SPORT.

## 1. Tại Sao Các Lớp Exception Lại Cực Kỳ Ngắn?
Các lớp ngoại lệ ở đây kế thừa trực tiếp từ `RuntimeException` và chỉ chứa duy nhất một constructor nhận vào thông báo lỗi (`message`) và truyền nó lên lớp cha thông qua `super(message)`.
- **Kế thừa RuntimeException (Unchecked Exceptions)**: Giúp giảm thiểu boilerplate code (không cần khai báo `throws` ở chữ ký phương thức), giúp code sạch hơn và dễ đọc hơn.
- **Tách biệt ngữ nghĩa**: Dù cấu trúc giống hệt nhau, việc định nghĩa các lớp riêng biệt như `ConflictException`, `NotFoundException`, `ForbiddenException`, `ValidationException` giúp phân biệt rõ ràng bản chất của lỗi để Controller xử lý hoặc trả về HTTP status phù hợp.

## 2. Ánh Xạ Trạng Thái HTTP (HTTP Status Mapping)
Các ngoại lệ này được ánh xạ tương ứng với các mã trạng thái HTTP tiêu chuẩn:

| Tên Exception | HTTP Status Code | Ý Nghĩa Sử Dụng | Ví Dụ |
| :--- | :--- | :--- | :--- |
| **[ValidationException](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/exception/ValidationException.java)** | `400 Bad Request` | Dữ liệu đầu vào sai định dạng hoặc vi phạm ràng buộc nghiệp vụ. | Nhập số điện thoại sai định dạng, ngày sinh ở tương lai. |
| **[ForbiddenException](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/exception/ForbiddenException.java)** | `403 Forbidden` | Người dùng đã đăng nhập nhưng không có quyền thao tác trên dữ liệu được yêu cầu. | Quản lý cơ sở A sửa thông tin nhân viên của cơ sở B. |
| **[NotFoundException](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/exception/NotFoundException.java)** | `404 Not Found` | Tài nguyên yêu cầu không tìm thấy trong hệ thống. | Tìm kiếm ca làm việc, nhân viên hoặc sân thi đấu với ID không tồn tại. |
| **[ConflictException](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/exception/ConflictException.java)** | `409 Conflict` | Xung đột về trạng thái dữ liệu tại thời điểm xử lý. | Trùng lịch ca làm việc, ca làm đã hoàn thành/hủy không cho phép sửa. |

## 3. Quy Tắc Sử Dụng Exceptions trong Dự Án
1. **Ném ở tầng Service / DAO**: Khi kiểm tra đầu vào hoặc phát hiện lỗi nghiệp vụ ở Service/DAO, ngay lập tức ném ra Exception phù hợp. Không xử lý catch tại đây.
   ```java
   if (conflict) {
       throw new ConflictException("Trùng lịch ca làm việc!");
   }
   ```
2. **Bắt ở tầng Controller (Servlet)**: Các Controller (hoặc sau này là Filter / ExceptionHandler) sẽ bắt các Exception này, log chi tiết lỗi, và trả về Response (JSON hoặc điều hướng trang lỗi) kèm HTTP Status tương ứng.
   ```java
   try {
       caLamService.updateShift(caId, request, managerCoSoId, actorId, reason);
   } catch (ConflictException e) {
       resp.setStatus(HttpServletResponse.SC_CONFLICT);
       resp.getWriter().write(toJsonError(e.getMessage()));
   } catch (ValidationException e) {
       resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
       resp.getWriter().write(toJsonError(e.getMessage()));
   }
   ```
