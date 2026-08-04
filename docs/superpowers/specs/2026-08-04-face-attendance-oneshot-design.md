# Điểm danh khuôn mặt: đăng ký nhiều mẫu + điểm danh một chạm

Ngày: 2026-08-04

## Vấn đề

Nhân viên quét mặt nhiều lần mà không điểm danh được. Đọc code cho thấy hai nguyên nhân tách biệt:

1. **Challenge liveness chặn luồng.** `face-attendance.js:158` yêu cầu giữ tư thế (quay đầu / chớp mắt / mỉm cười) đủ số frame liên tiếp; tụt một frame là `_challengePassedFrames` reset về 0. Ảnh chụp màn hình của người dùng cho thấy độ khớp 51% với chú thích "Đã khớp (cần ≥ 13%)" — nhận diện đã đạt, thứ treo lại là challenge `QUAY ĐẦU PHẢI`.
2. **Chỉ một mẫu khuôn mặt mỗi người.** `FaceEnrollServlet.java:90` lưu đúng một descriptor. Đổi ánh sáng, đeo kính, hay lệch góc là khoảng cách Euclidean vọt lên khỏi ngưỡng.

Phụ trợ: `TinyFaceDetector` + tiny landmark (`face-attendance.js:142`) cho landmark thô, làm phép đo tư thế nhiễu; ngưỡng `ConfidenceMin` chỉ là một con số mà manager không thấy hệ quả khi chỉnh.

## Quyết định đã chốt

- Bỏ challenge ở luồng nhân viên/bảo vệ; chống gian lận chuyển sang **hậu kiểm bằng ảnh snapshot**.
- Đăng ký **nhiều mẫu** khuôn mặt bên manager.
- Thanh kéo ngưỡng đặt ở **FaceSettings, một ngưỡng cho mỗi cơ sở** (không phải ngưỡng riêng từng người).
- Giữ `TinyFaceDetector` — không đổi model, tránh làm nặng máy yếu.

## A. Đăng ký nhiều mẫu

**Lưu trữ.** Giữ nguyên cột `Accounts.FaceDescriptor NVARCHAR(MAX)`. Đổi nội dung từ `[128 số]` sang `[[128 số], [128 số], …]`. Không có migration DB.

**Tương thích ngược.** Khi đọc, kiểm tra phần tử đầu của mảng ngoài: nếu là số thì đây là dữ liệu cũ một mẫu, bọc lại thành `[[…]]`. Áp dụng ở cả server và client. Bản ghi cũ tiếp tục hoạt động không cần thao tác thủ công.

**Giao diện đăng ký (`NhanSu.jsp`).** Manager nạp 3–5 ảnh, mỗi ảnh từ webcam hoặc file, ở góc và ánh sáng khác nhau. Mỗi ảnh chạy `detectSingleFace(...).withFaceDescriptor()` và hiện thumbnail kèm trạng thái. Số mẫu tối thiểu để lưu là 1 (giữ đường lùi khi chỉ có một ảnh hồ sơ), khuyến nghị hiển thị trên giao diện là 3.

Hai cảnh báo khi thêm mẫu, so mẫu mới với các mẫu đã có:

- khoảng cách nhỏ nhất `< 0.2` → "Mẫu gần trùng mẫu đã có, hãy chụp ở góc hoặc ánh sáng khác". Cảnh báo, vẫn cho lưu.
- khoảng cách nhỏ nhất `> 0.6` → "Ảnh này có thể không phải cùng một người". Cảnh báo, vẫn cho lưu — quyết định thuộc về manager.

`FaceImagePath` tiếp tục lưu ảnh **đầu tiên** làm ảnh minh hoạ; không đổi cấu trúc thư mục ảnh.

**So khớp.** Khoảng cách của một khuôn mặt tới một tài khoản là **nhỏ nhất trong các mẫu**. Sửa ở cả `face-attendance.js:71` (client, để hiện % và quyết định bắt frame) và `FaceCheckInServlet.java:150` (server, để duyệt cuối cùng). Server vẫn là nơi phán quyết.

## B. Thanh kéo ngưỡng ở FaceSettings

Thay bốn radio cứng (`FaceSettings.jsp:424`) bằng `<input type="range" min="0.35" max="0.75" step="0.01">`, hiện đồng thời giá trị thô và phần trăm tương ứng, kèm nhãn vùng **Chặt / Cân bằng / Dễ**. Ghi vào `CoSoFaceConfig.ConfidenceMin` — không đổi schema.

Bên cạnh slider là khung xem trước sống: manager chọn một nhân viên đã đăng ký mặt, bật webcam, và trong khi kéo slider thấy ngay phần trăm khớp theo thời gian thực cùng đèn ĐẠT / KHÔNG ĐẠT. Mục đích là biến con số trừu tượng thành hệ quả nhìn thấy được trước khi lưu.

Khung xem trước chỉ chạy trong trang cài đặt và không ghi bất kỳ log điểm danh nào.

## C. Luồng nhân viên và bảo vệ: một nút

`FaceChallengeServlet` trả `challenges: []`. Client gỡ nhánh xử lý `CHALLENGE_LABELS` và bộ đếm `_challengePassedFrames`.

Luồng: bấm **Điểm danh** → modal mở camera → vòng detect chạy tự động → gom frame có khoảng cách ≤ ngưỡng cơ sở; cần **3 frame liên tiếp đạt** để loại frame nhiễu → chọn frame có khoảng cách nhỏ nhất trong ba frame đó → chụp snapshot từ frame ấy → gửi lên server. Thực tế khoảng 1–2 giây.

Màn hình chỉ còn khung camera, vòng tiến trình, và chuỗi trạng thái "Đang nhận diện…" → "✓ Đã điểm danh". Con số phần trăm bị gỡ khỏi mắt nhân viên vì nó gây hiểu nhầm mà không giúp họ hành động; `FaceConfidence` vẫn được ghi xuống DB như cũ.

Sau **15 giây** không đạt: dừng vòng detect, hiện nút **Thử lại** kèm gợi ý cụ thể (đứng nơi đủ sáng, bỏ khẩu trang, tháo kính nếu lúc đăng ký không đeo). Các lối thoát hiện có (điểm danh thủ công / báo quản lý) giữ nguyên vị trí.

`FaceLivenessPassed` ghi `0` cho mọi bản ghi tạo bởi luồng này. Server không còn kiểm token challenge cho luồng này; token vẫn được cấp và dùng để chống phát lại (replay) như trước.

## D. Chống gian lận sau khi bỏ liveness

Rủi ro được chấp nhận có ý thức: **giơ ảnh in hoặc màn hình điện thoại ra camera sẽ qua được**.

Lớp phòng thủ thay thế là hậu kiểm. Bảng log trong FaceSettings đã lưu ảnh snapshot và `FaceConfidence` cho từng lần điểm danh; manager soi lại khi có nghi ngờ. Không xây thêm gì cho phần này.

Lưu ý về giới hạn của snapshot: ảnh và descriptor đều do client gửi lên (`/face/challenge` trả về chính descriptor đã đăng ký của người gọi, `/face/checkin` nhận descriptor và ảnh do client cung cấp). Một nhân viên rành devtools có thể tự soạn descriptor khớp cùng một ảnh JPEG bất kỳ trông giống người thật rồi POST thẳng, tức là điểm danh từ xa với ảnh không do camera thực chụp. Vấn đề này có từ trước nhánh này, nhưng nhánh này bỏ challenge tư thế từng đứng chắn trước nó. Vì vậy snapshot + confidence là công cụ **răn đe và hỗ trợ hậu kiểm**, không phải bằng chứng chống giả mạo — manager cần hiểu rõ giới hạn này khi soi log.

Nếu sau này cần siết, hướng đi là liveness ẩn — quan sát vi chuyển động và chớp mắt tự nhiên trong 2–3 giây mà không ra lệnh cho người dùng. Đó là thay đổi cục bộ bên trong `detectionLoop`, không phá kiến trúc mô tả ở đây.

## Phạm vi không đụng tới

- Không đổi model nhận diện (`TinyFaceDetector` giữ nguyên).
- Không thêm ngưỡng riêng theo từng nhân viên.
- Không đổi schema DB.
- Không đụng luồng chấm công thủ công hay tính lương.

## Kiểm thử

- Tài khoản có descriptor định dạng cũ (một mẫu) vẫn điểm danh được — xác nhận nhánh tương thích ngược.
- Đăng ký 3 mẫu rồi điểm danh ở điều kiện ánh sáng khác lúc đăng ký; so số lần thất bại với trước khi sửa.
- Kéo ngưỡng về `0.35` (chặt) và xác nhận cùng khuôn mặt đó bị từ chối, chứng minh slider thực sự có tác dụng.
- Che camera 15 giây và xác nhận trạng thái timeout kèm nút Thử lại.
- Xác nhận `FaceConfidence` và ảnh snapshot vẫn xuất hiện trong bảng log FaceSettings sau mỗi lần điểm danh.
