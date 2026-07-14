# Cấu hình database khi chạy V-SPORT local

> [!CAUTION]
> **CẢNH BÁO BẢO MẬT QUAN TRỌNG:**
> 1. **KHÔNG** commit file `.env` cá nhân lên Git Repository. File này chứa mật khẩu thật và chỉ dùng để chạy local.
> 2. **KHÔNG** chụp ảnh màn hình các cấu hình chạy (Run Configuration) hoặc file `.env` có chứa mật khẩu thật để gửi lên các nhóm chat chung (Zalo, Messenger, Discord, v.v.). Nếu cần hỗ trợ kỹ thuật, hãy làm mờ hoặc che đi mật khẩu trước khi gửi.

## Vì sao cần cấu hình?

Sau các đợt tái cấu trúc và làm sạch mã nguồn (Clean code), dự án V-SPORT **tuyệt đối không lưu trữ thông tin tài khoản cơ sở dữ liệu (đặc biệt là mật khẩu) trực tiếp trong code**. 

Lớp kết nối CSDL [DBUtil.java](file:///d:/New%20folder/V-SPORT/src/main/java/org/example/util/DBUtil.java) sẽ đọc cấu hình động khi khởi chạy ứng dụng từ:
- **Biến môi trường (Environment variables)**: `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`
- **Hoặc Thuộc tính hệ thống JVM (System properties)**: `db.url`, `db.username`, `db.password`

Do đó, khi chạy ứng dụng local, bạn cần cấp các thông số cấu hình này cho Tomcat/JVM để tránh lỗi đăng nhập hoặc lỗi khởi tạo kết nối.

---

## Cách 1 — Sử dụng file `.env` và chạy qua `start_server.bat` (Khuyên dùng khi chạy ngoài)

Dự án đã hỗ trợ tự động nạp cấu hình từ file `.env` ở thư mục gốc khi chạy qua file script [start_server.bat](file:///d:/New%20folder/V-SPORT/start_server.bat).

1. Sao chép file `.env.example` thành `.env`:
   ```cmd
   copy .env.example .env
   ```
2. Mở file `.env` vừa tạo và điền mật khẩu cơ sở dữ liệu thật của bạn vào biến `DB_PASSWORD`:
   ```env
   DB_URL=jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;
   DB_USERNAME=sa
   DB_PASSWORD=mật_khẩu_cơ_sở_dữ_liệu_thật
   ```
3. Chạy file script:
   ```cmd
   start_server.bat
   ```
   *Lưu ý: File `.env` chứa mật khẩu cá nhân đã được cấu hình trong `.gitignore` nên sẽ không bị push lên Git.*

---

## Cách 2 — Cấu hình trực tiếp trong IntelliJ IDEA (SmartTomcat)

Nếu bạn khởi chạy Tomcat trực tiếp từ IntelliJ IDEA bằng plugin **SmartTomcat**, bạn cần cấu hình các tham số JVM System Properties hoặc Environment Variables trong cấu hình chạy:

### Option A: Dùng VM Options (System Properties)
1. Trên thanh công cụ IntelliJ, nhấn vào menu cấu hình chạy (Run Configuration) và chọn **Edit Configurations...**
2. Chọn cấu hình **SmartTomcat** tương ứng của dự án V-SPORT.
3. Tại trường **VM Options**, thêm chuỗi cấu hình sau (thay thế mật khẩu thật của bạn):
   ```bash
   -Ddb.url="jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;" -Ddb.username="sa" -Ddb.password="mật_khẩu_của_bạn"
   ```
4. Nhấn **Apply** và chạy dự án.

### Option B: Dùng Environment Variables
1. Trong cửa sổ **Edit Configurations...** của SmartTomcat.
2. Tìm mục **Environment variables** (nếu phiên bản SmartTomcat của bạn hỗ trợ).
3. Thêm các cặp key-value sau:
   - `DB_URL` = `jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;`
   - `DB_USERNAME` = `sa`
   - `DB_PASSWORD` = `mật_khẩu_của_bạn`
4. Lưu và khởi chạy Tomcat.

---

## Cách 3 — Chạy bằng PowerShell trước khi mở Tomcat thủ công

Nếu bạn chạy ứng dụng từ terminal PowerShell và gọi Tomcat thủ công, hãy thiết lập các biến môi trường tạm thời trước khi khởi động Tomcat:

```powershell
# Thiết lập biến môi trường trên phiên PowerShell hiện tại
$env:DB_URL="jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;"
$env:DB_USERNAME="sa"
$env:DB_PASSWORD="mật_khẩu_thật_của_bạn"

# Khởi động Tomcat thủ công từ Catalina
& "D:\BiKipVoCong\TaiNguyenIntelliji\apache-tomcat-10.1.54\bin\catalina.bat" start
```
Với Command Prompt (CMD) truyền thống:
```cmd
set DB_URL=jdbc:sqlserver://14.225.217.109:1433;databaseName=QuanLiSport;encrypt=true;trustServerCertificate=true;sendStringParametersAsUnicode=true;
set DB_USERNAME=sa
set DB_PASSWORD=mật_khẩu_thật_của_bạn
call catalina.bat start
```
