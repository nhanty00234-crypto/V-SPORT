# Demo luồng QR sân — V-SPORT

## 1. URL thật

Context path deploy thực tế là **`/Backend_java`** (lấy từ `artifactId` trong `pom.xml`, WAR chạy trong Tomcat/SmartTomcat là `Backend_java.war` — KHÔNG phải `/V-SPORT`, đó chỉ là tên thư mục project). Nếu bạn deploy bằng cách khác (đổi `finalName` trong `pom.xml`, hoặc đổi tên file WAR trước khi thả vào `webapps/`), context path sẽ đổi theo — luôn kiểm tra lại tên WAR/thư mục trong `webapps/` của Tomcat đang chạy để chắc chắn.

| Vai trò | URL |
|---|---|
| Manager tạo/in QR | `http://{IP-LAN}:8080/Backend_java/manager/ma-qr-san` |
| Manager xử lý yêu cầu | `http://{IP-LAN}:8080/Backend_java/manager/yeu-cau-dich-vu` |
| Staff xử lý yêu cầu | `http://{IP-LAN}:8080/Backend_java/staff/yeu-cau-qr` |
| Customer sau khi quét (tự sinh, không gõ tay) | `http://{IP-LAN}:8080/Backend_java/qr/{shortCode}` |

QR ảnh do `SanQRImageServlet` build URL bằng `request.getScheme()/getServerName()/getServerPort()` của chính request Manager đang dùng để mở trang — **không hardcode localhost**. Vì vậy chỉ cần Manager mở `/manager/ma-qr-san` bằng IP LAN (không phải `localhost`) là ảnh QR in ra sẽ chứa đúng IP LAN.

## 2. Lấy IP LAN trên Ubuntu

```bash
hostname -I
```

Lấy địa chỉ dạng `192.168.x.x`, dùng nó thay cho `localhost` khi mở trình duyệt trên **laptop** để vào trang Manager (`http://192.168.x.x:8080/V-SPORT/manager/ma-qr-san`) — như vậy QR sinh ra mới đúng IP LAN.

## 3. Kiểm tra firewall

```bash
sudo ufw status
sudo ufw allow 8080/tcp    # nếu ufw đang chặn
```

Đảm bảo Tomcat lắng nghe `0.0.0.0:8080` (mặc định của Tomcat đã vậy, không cần sửa `server.xml` trừ khi đã bị đổi).

## 4. Tài khoản role cần dùng

Chạy `sql/verify_qr_flow.sql` mục (3) để lấy `Username` thật của một Manager và một Staff (`RoleID` = Manager hoặc Lễ tân) có `CoSoID` khác NULL trong DB hiện tại — dùng đúng tài khoản đó để đăng nhập demo, không tự tạo tài khoản mới.

## 5. Sân / QR / sản phẩm dùng để demo

- Sân: chạy mục (1) trong `sql/verify_qr_flow.sql`, chọn 1 dòng có `QRTrangThai = 'ACTIVE'` và `SanTrangThai`/`CoSoTrangThai` đang hoạt động.
- Sản phẩm còn tồn kho: chạy mục (4), lọc `SoLuongTon > 0` và `TrangThai` khác "Ngừng kinh doanh".
- Nếu muốn demo cả nút "Thanh toán": sân đó cần có 1 dòng `LichDatSan.TrangThai = N'Đang sử dụng'` (mục 8) — tức khách đã được Staff check-in vào sân trước khi quét QR.

## 6. Kịch bản demo 3–5 phút

1. Laptop: đăng nhập Manager → `/manager/ma-qr-san` → in/hiện QR của sân demo.
2. Điện thoại (cùng Wi-Fi): quét QR → mở `QuetQR.jsp`, thấy đúng tên sân + cơ sở.
3. Bấm **Gọi nhân viên** → nhập ghi chú → gửi.
4. Laptop khác (hoặc tab khác): đăng nhập Staff cùng cơ sở → `/staff/yeu-cau-qr` → thấy request xuất hiện trong tab "Mới" (poll 8s).
5. Staff bấm **Bắt đầu xử lý** → điện thoại tự đổi badge sang "Đang xử lý" (poll 5s trên `TrangThaiYeuCau.jsp`).
6. Staff bấm **Hoàn thành** → điện thoại tự đổi "Hoàn thành".
7. Điện thoại quay lại `QuetQR.jsp` → bấm **Gọi món**, chọn 1-2 sản phẩm còn tồn kho → gửi.
8. Staff thấy đúng tên món + số lượng trong card, bấm **Bắt đầu xử lý** rồi **Hoàn thành** → hệ thống tự trừ tồn kho + tạo hóa đơn SPLIT (dùng lại đúng logic `LichDatSan_DichVu` sẵn có).
9. (Nếu sân đang có phiên "Đang sử dụng" và cơ sở đã cấu hình PayOS) điện thoại bấm **Thanh toán** → chuyển sang trang PayOS.

## 7. Nếu camera không quét được QR

`SanQRResolveServlet` map `@WebServlet({"/qr/*"})`, đọc `ShortCode` từ path. Có thể gõ tay short code (12 ký tự, lấy từ `sql/verify_qr_flow.sql` mục (1), cột `ShortCode`) vào thanh địa chỉ điện thoại:

```
http://{IP-LAN}:8080/V-SPORT/qr/{shortCode}
```

## 8. Giới hạn hiện tại (đã ghi rõ, không che giấu)

- Nút "Thanh toán" chỉ hoạt động khi sân có phiên `LichDatSan` đang "Đang sử dụng" **và** cơ sở đã cấu hình PayOS hợp lệ — nếu không, hệ thống trả thông báo lịch sự thay vì lỗi.
- Yêu cầu `SERVICE_REQUEST` (yêu cầu dịch vụ tự do, không phải sản phẩm có sẵn) hiện chỉ hiển thị cho Staff xử lý thủ công, chưa tự động nối vào hóa đơn (đúng bản chất — đây là yêu cầu mô tả tự do, không có SanPhamID để tính tiền).
