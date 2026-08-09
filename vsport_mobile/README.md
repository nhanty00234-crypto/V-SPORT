# V-SPORT Mobile (Customer)

App Flutter dành riêng cho role **CUSTOMER**, gọi REST API `/api/v1/*` của backend Java hiện có
(Jakarta Servlet + Service + DAO + SQL Server). Không có database riêng, không mock — mọi dữ liệu
đều đi qua đúng Service/DAO mà bản Web JSP đang dùng.

## 1. Sinh phần platform (chỉ làm một lần)

Repo này chỉ chứa `lib/` và `pubspec.yaml`. Sinh các thư mục `android/`, `ios/`, ... bằng:

```bash
cd vsport_mobile && flutter create --project-name vsport_mobile --org vn.vsport .
```

Lệnh trên **không ghi đè** `lib/` và `pubspec.yaml` đã có.

## 2. Cài dependency

```bash
cd vsport_mobile && flutter pub get
```

## 3. Quyền cần khai báo

`android/app/src/main/AndroidManifest.xml` — thêm vào trong thẻ `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Backend dev chạy HTTP (không TLS) nên Android 9+ cần cho phép cleartext — thêm vào thẻ
`<application>`: `android:usesCleartextTraffic="true"` (chỉ dùng cho môi trường phát triển).

`ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key><string>Quét mã QR tại sân</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Tìm cơ sở gần bạn</string>
```

## 4. Trỏ tới backend

Mặc định (xem `lib/config/api_config.dart`):

| Môi trường chạy   | Base URL                                  |
|-------------------|-------------------------------------------|
| Android Emulator  | `http://10.0.2.2:8080/Backend_java`       |
| iOS Sim / Desktop | `http://localhost:8080/Backend_java`      |
| Máy thật          | phải chỉ định IP LAN của máy chạy Tomcat  |

Ghi đè khi chạy:

```bash
flutter run --dart-define=VSPORT_API_BASE=http://192.168.1.10:8080/Backend_java
```

## 5. Chạy

```bash
cd vsport_mobile && flutter run
```

## Cấu trúc

```
lib/
  config/api_config.dart          # base URL duy nhất
  storage/secure_storage_service.dart  # access/refresh token (Keychain / EncryptedSharedPreferences)
  services/
    api_client.dart               # HTTP + Bearer + tự refresh token + bóc envelope JSON
    auth_service.dart             # login / refresh / me / update profile / logout
    catalog_service.dart          # home, sports, facilities, courts, availability, promotions
    booking_service.dart          # quote, create, history, detail, cancel, payment
    qr_service.dart               # resolve QR + tạo yêu cầu dịch vụ
    notification_service.dart     # thông báo
  models/models.dart              # DTO ánh xạ 1-1 với backend
  screens/                        # splash, auth, home, facility, booking, qr, notifications, profile
  widgets/common.dart             # AsyncView, StatusChip, format tiền/ngày
```

Giao diện cố tình tối giản để tập trung kiểm thử luồng end-to-end; phần thiết kế sẽ làm lại sau.

## Luồng đã hỗ trợ

1. Splash (kiểm tra token) → Login → Home → chọn môn → tìm cơ sở → chi tiết cơ sở → chọn sân →
   chọn ngày/giờ (server trả lịch trống + giá) → đặt sân → chi tiết đơn → PayOS QR → thanh toán
   thành công → lịch sử cập nhật (Web V-SPORT nhìn thấy đúng đơn đó).
2. Quét QR tại sân → server resolve ra cơ sở/sân → "Gọi nhân viên" / gọi món / yêu cầu thanh toán
   → bản ghi vào `QRRequest` → màn hình Staff/Manager trên Web nhận được.
