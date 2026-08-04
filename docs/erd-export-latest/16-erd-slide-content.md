# 16 — Nội dung slide ERD (phần chữ bên trái)

ERD 1: Tài khoản & Phân quyền

Bao gồm các bảng:
- Accounts
- MonTheThaoYeuThich
- Roles

Mô tả:
Bao gồm các bảng: Accounts, Roles, MonTheThaoYeuThich và MonTheThao. Nhóm này quản lý tài khoản của mọi vai trò trong hệ thống, phân quyền theo vai trò và môn thể thao yêu thích của khách hàng.

Quan hệ chính:
- Vai trò 1–N Tài khoản.
- Tài khoản 1–N Môn thể thao yêu thích.
- MonTheThaoYeuThich là bảng trung gian giữa Accounts và MonTheThao.

---

ERD 2: Nhật ký hệ thống & Thùng rác

Bao gồm các bảng:
- AuditLog
- AdminTrash
- Accounts

Mô tả:
Bao gồm các bảng: AuditLog, AdminTrash và Accounts. Nhóm này lưu nhật ký mọi thao tác quan trọng và danh sách bản ghi đã xóa mềm để quản trị viên có thể tra cứu, khôi phục hoặc xóa vĩnh viễn.

Quan hệ chính:
- Nhóm này không có FK vật lý nội bộ.

---

ERD 3: Môn thể thao

Bao gồm các bảng:
- MonTheThao
- LoaiSan

Mô tả:
Bao gồm các bảng: MonTheThao, MonTheThaoYeuThich và LoaiSan. Nhóm này là danh mục nền tảng phân loại môn thể thao, được loại sân, ghép kèo và hồ sơ khách hàng cùng tham chiếu.

Quan hệ chính:
- Môn thể thao 1–N Loại sân.

---

ERD 4: Cơ sở thể thao

Bao gồm các bảng:
- CoSo
- CoSoCapability
- CoSoNganHang
- Accounts

Mô tả:
Bao gồm các bảng: CoSo, CoSoCapability, CoSoNganHang và Accounts. Nhóm này quản lý từng cơ sở/chi nhánh, người quản lý phụ trách, các năng lực dịch vụ được duyệt và tài khoản ngân hàng nhận tiền.

Quan hệ chính:
- Cơ sở thể thao 1–N Tài khoản.
- Tài khoản 1–N Cơ sở thể thao.
- Tài khoản 1–N Năng lực cơ sở.
- Cơ sở thể thao 1–N Năng lực cơ sở.
- Cơ sở thể thao 1–1 Tài khoản ngân hàng cơ sở.

---

ERD 5: Sân & Loại sân

Bao gồm các bảng:
- San
- LoaiSan
- LoaiSan_KhungGioDen_Backup
- MonTheThao
- CoSo

Mô tả:
Bao gồm các bảng: San, LoaiSan, MonTheThao và LoaiSan_KhungGioDen_Backup. Nhóm này mô tả từng sân thi đấu thuộc cơ sở, loại sân theo môn thể thao cùng bảng giá và khung giờ bật đèn.

Quan hệ chính:
- Cơ sở thể thao 1–N Loại sân.
- Môn thể thao 1–N Loại sân.
- Cơ sở thể thao 1–N Sân.
- Loại sân 1–N Sân.

---

ERD 6: Đặt sân & Giữ chỗ

Bao gồm các bảng:
- LichDatSan
- BookingExtension
- LichDatSan_DichVu
- SoftHold

Mô tả:
Bao gồm các bảng: LichDatSan, SoftHold, BookingExtension và LichDatSan_DichVu. Nhóm này là trung tâm nghiệp vụ đặt sân, từ giữ chỗ tạm thời khi khách thao tác đến gia hạn giờ chơi và dịch vụ đặt kèm.

Quan hệ chính:
- Lịch đặt sân 1–N Gia hạn đặt sân.
- Lịch đặt sân 1–N Dịch vụ đặt trước.

---

ERD 7: Check-in & Phiên sử dụng sân

Bao gồm các bảng:
- CourtChargeSegment
- LichDatSan
- HoaDon

Mô tả:
Bao gồm các bảng: CourtChargeSegment, LichDatSan và HoaDon. Nhóm này ghi lại phiên sử dụng sân thực tế và chia lượt chơi thành các đoạn giá có đèn hoặc không đèn để tính tiền khi kết thúc.

Quan hệ chính:
- Hóa đơn 1–N Đoạn tính tiền sân.
- Lịch đặt sân 1–N Đoạn tính tiền sân.
- Lịch đặt sân 1–1 Hóa đơn.
- Hóa đơn 1–N Hóa đơn.

---

ERD 8: Hóa đơn & Thanh toán

Bao gồm các bảng:
- HoaDon
- ChiTietHoaDon
- PayOSPaymentAttempt
- LichDatSan

Mô tả:
Bao gồm các bảng: HoaDon, ChiTietHoaDon, PayOSPaymentAttempt và LichDatSan. Nhóm này quản lý hóa đơn của lượt đặt sân, từng dòng sản phẩm trong hóa đơn và các lượt thanh toán qua cổng PayOS.

Quan hệ chính:
- Hóa đơn 1–N Chi tiết hóa đơn.
- Lịch đặt sân 1–1 Hóa đơn.
- Hóa đơn 1–N Hóa đơn.
- Hóa đơn 1–1 Lượt thanh toán PayOS.
- Lịch đặt sân 1–N Lượt thanh toán PayOS.
- ChiTietHoaDon là bảng trung gian giữa HoaDon và SanPham_DichVu.

---

ERD 9: Hoàn tiền

Bao gồm các bảng:
- HoanTien
- HoaDon
- Accounts

Mô tả:
Bao gồm các bảng: HoanTien, HoaDon và Accounts. Nhóm này quản lý yêu cầu hoàn tiền của khách sau khi hủy đặt sân, gồm số tiền, trạng thái duyệt và người xử lý.

Quan hệ chính:
- Tài khoản 1–N Hóa đơn.
- Tài khoản 1–N Hóa đơn.
- Hóa đơn 1–N Hóa đơn.
- Tài khoản 1–N Hoàn tiền.
- Hóa đơn 1–N Hoàn tiền.

---

ERD 10: Sản phẩm & Kho

Bao gồm các bảng:
- SanPham_DichVu
- DanhMucSanPham
- ServiceMaterial

Mô tả:
Bao gồm các bảng: SanPham_DichVu, DanhMucSanPham và ServiceMaterial. Nhóm này quản lý sản phẩm, đồ uống bán lẻ tại cơ sở theo danh mục và vật tư kho dùng cho các dịch vụ thể thao.

Quan hệ chính:
- Danh mục sản phẩm 1–N Sản phẩm & dịch vụ.

---

ERD 11: Dịch vụ thể thao

Bao gồm các bảng:
- ServiceOrder
- RacketStringingConfig
- RacketStringingOrderDetail
- ServiceOrderStatusHistory
- SportService

Mô tả:
Bao gồm các bảng: SportService, ServiceOrder, ServiceOrderStatusHistory, RacketStringingConfig và RacketStringingOrderDetail. Nhóm này quản lý dịch vụ chuyên biệt như căng vợt, sửa vợt và vòng đời trạng thái của từng đơn dịch vụ.

Quan hệ chính:
- Dịch vụ thể thao 1–1 Cấu hình căng vợt.
- Đơn dịch vụ 1–1 Chi tiết đơn căng vợt.
- Dịch vụ thể thao 1–N Đơn dịch vụ.
- Đơn dịch vụ 1–N Lịch sử trạng thái đơn dịch vụ.

---

ERD 12: Khuyến mãi

Bao gồm các bảng:
- KhuyenMai
- KhuyenMaiHinhAnh
- LichSuKhuyenMai

Mô tả:
Bao gồm các bảng: KhuyenMai, KhuyenMaiHinhAnh và LichSuKhuyenMai. Nhóm này quản lý chương trình khuyến mãi của từng cơ sở, hình ảnh minh họa và lịch sử mỗi lần khách sử dụng mã.

Quan hệ chính:
- Khuyến mãi 1–1 Hình ảnh khuyến mãi.
- Khuyến mãi 1–N Lịch sử dùng khuyến mãi.

---

ERD 13: Ghép kèo

Bao gồm các bảng:
- GhepKeo
- ChiTietGhepKeo
- LichDatSan
- MonTheThao

Mô tả:
Bao gồm các bảng: GhepKeo, ChiTietGhepKeo, LichDatSan và MonTheThao. Nhóm này cho phép khách đăng kèo từ một lượt đặt sân và quản lý danh sách người tham gia được duyệt tự động hoặc thủ công.

Quan hệ chính:
- Ghép kèo 1–N Người tham gia kèo.
- Lịch đặt sân 1–N Ghép kèo.
- Môn thể thao 1–N Ghép kèo.
- ChiTietGhepKeo là bảng trung gian giữa Accounts và GhepKeo.

---

ERD 14: Đội nhóm người chơi

Bao gồm các bảng:
- Teams
- TeamInvitations
- TeamJoinRequests
- TeamMembers

Mô tả:
Bao gồm các bảng: Teams, TeamMembers, TeamInvitations và TeamJoinRequests. Nhóm này quản lý đội do khách hàng lập, thành viên và vai trò trong đội, cùng hai luồng mời vào đội và xin gia nhập.

Quan hệ chính:
- Đội nhóm 1–N Thành viên đội.
- Đội nhóm 1–N Lời mời vào đội.
- Đội nhóm 1–N Yêu cầu xin vào đội.
- TeamMembers là bảng trung gian giữa Teams và Accounts.

---

ERD 15: Thông báo & Chat

Bao gồm các bảng:
- ThongBao
- NhatKyChat
- Accounts

Mô tả:
Bao gồm các bảng: ThongBao, NhatKyChat và Accounts. Nhóm này lưu thông báo hệ thống gửi tới từng tài khoản với cơ chế chống trùng, và lịch sử hội thoại với trợ lý chatbot.

Quan hệ chính:
- Tài khoản 1–N Nhật ký chat.
- Tài khoản 1–N Thông báo.

---

ERD 16: SOS

Bao gồm các bảng:
- YeuCauSOS
- NhatKySOSGui
- LichDatSan

Mô tả:
Bao gồm các bảng: YeuCauSOS, NhatKySOSGui và LichDatSan. Nhóm này xử lý yêu cầu khẩn tìm người chơi thay cho một lượt đặt sân và ghi nhật ký từng lượt gửi thông báo tới người nhận.

Quan hệ chính:
- Yêu cầu SOS 1–N Nhật ký gửi SOS.
- Lịch đặt sân 1–N Yêu cầu SOS.

---

ERD 17: Ca làm việc

Bao gồm các bảng:
- CaLamViec
- CaLamViec_Audit
- CaLamViec_Availability
- CaLamViec_SwapRequest

Mô tả:
Bao gồm các bảng: CaLamViec, CaLamViec_Audit, CaLamViec_Availability và CaLamViec_SwapRequest. Nhóm này quản lý lịch ca của nhân viên và bảo vệ, thời gian rảnh đăng ký, yêu cầu đổi ca và nhật ký thay đổi.

Quan hệ chính:
- Ca làm việc 1–N Yêu cầu đổi ca.
- Ca làm việc 1–N Yêu cầu đổi ca.

---

ERD 18: Nghỉ phép

Bao gồm các bảng:
- YeuCauNghi
- YeuCauNghi_Audit
- Accounts

Mô tả:
Bao gồm các bảng: YeuCauNghi, YeuCauNghi_Audit và Accounts. Nhóm này quản lý đơn xin nghỉ của nhân viên theo cơ sở, quy trình duyệt của quản lý và nhật ký mọi thao tác trên đơn.

Quan hệ chính:
- Tài khoản 1–N Yêu cầu nghỉ phép.
- Tài khoản 1–N Yêu cầu nghỉ phép.
- Tài khoản 1–N Nhật ký nghỉ phép.
- Yêu cầu nghỉ phép 1–N Nhật ký nghỉ phép.

---

ERD 19: Mã QR sân

Bao gồm các bảng:
- SanQR
- QRRequest
- SanQRTokenHistory
- San

Mô tả:
Bao gồm các bảng: SanQR, SanQRTokenHistory, QRRequest và San. Nhóm này quản lý mã QR gắn cho từng sân, lịch sử token đã cấp hoặc thu hồi và các yêu cầu khách gửi sau khi quét mã.

Quan hệ chính:
- Sân 1–N Yêu cầu từ QR.
- Sân 1–1 Mã QR sân.
- Sân 1–N Lịch sử token QR.
- Mã QR sân 1–N Lịch sử token QR.

---

ERD 20: Đánh giá, ELO & Uy tín

Bao gồm các bảng:
- CustomerReputationHistory
- DanhGia
- LichSuELO
- Accounts

Mô tả:
Bao gồm các bảng: DanhGia, LichSuELO, CustomerReputationHistory và Accounts. Nhóm này lưu đánh giá sau trận giữa người chơi, biến động điểm trình độ ELO và điểm uy tín của khách hàng.

Quan hệ chính:
- Tài khoản 1–N Lịch sử điểm uy tín.
- Tài khoản 1–N Lịch sử điểm uy tín.
- Tài khoản 1–N Đánh giá.
- Tài khoản 1–N Đánh giá.
- Tài khoản 1–N Lịch sử điểm ELO.

---

ERD 21: Giữ xe

Bao gồm các bảng:
- TheGiuXe
- LichXeRaVao
- LichDatSan

Mô tả:
Bao gồm các bảng: TheGiuXe, LichXeRaVao và LichDatSan. Nhóm này quản lý thẻ giữ xe phát hành tại cơ sở và nhật ký từng lượt xe vào, ra bãi gắn với lượt đặt sân tương ứng.

Quan hệ chính:
- Lịch đặt sân 1–N Lịch xe ra vào.
- Thẻ giữ xe 1–N Lịch xe ra vào.

---

ERD 22: Chia hóa đơn

Bao gồm các bảng:
- NhomChiaTien
- ChiaHoaDon
- MaQR
- NhomChiaTienChiTiet

Mô tả:
Bao gồm các bảng: NhomChiaTien, NhomChiaTienChiTiet, ChiaHoaDon và MaQR. Nhóm này cho phép chia một hóa đơn cho nhiều người theo nhiều hình thức, kèm cơ chế chia hóa đơn đời cũ đã ngừng dùng.

Quan hệ chính:
- Nhóm chia hóa đơn 1–N Phần chia của từng người.
- Chia hóa đơn (cũ) 1–N Mã QR chia tiền (cũ).
- NhomChiaTienChiTiet là bảng trung gian giữa Accounts và NhomChiaTien.

---

ERD 23: Lương, Phụ cấp & Ứng lương

Bao gồm các bảng:
- KyLuong
- BangLuong
- CauHinhLuong
- YeuCauUngLuong

Mô tả:
Bao gồm các bảng: CauHinhLuong, KyLuong, BangLuong và YeuCauUngLuong. Nhóm này cấu hình lương cơ bản và phụ cấp mỗi ca cho nhân viên, tính bảng lương theo từng kỳ và xử lý đơn ứng lương.

Quan hệ chính:
- Kỳ lương 1–N Bảng lương.

---

ERD 24: Điểm danh khuôn mặt

Bao gồm các bảng:
- CoSoFaceConfig
- FaceChallengeToken
- CaLamViec
- Accounts

Mô tả:
Bao gồm các bảng: CoSoFaceConfig, FaceChallengeToken, CaLamViec và Accounts. Nhóm này bật bắt buộc điểm danh bằng khuôn mặt theo cơ sở, sinh token thử thách liveness và ghi kết quả vào ca làm việc.

Quan hệ chính:
- Tài khoản 1–N Ca làm việc.
- Tài khoản 1–N Token thử thách khuôn mặt.

---

ERD 25: Bảo vệ & Sự cố

Bao gồm các bảng:
- SuCo
- CoSo
- San
- Accounts

Mô tả:
Bao gồm các bảng: SuCo, CoSo, San và Accounts. Nhóm này cho bảo vệ báo cáo sự cố tại cơ sở hoặc sân cụ thể, phân loại mức độ và theo dõi quy trình xử lý của quản lý.

Quan hệ chính:
- Cơ sở thể thao 1–N Tài khoản.
- Tài khoản 1–N Cơ sở thể thao.
- Cơ sở thể thao 1–N Sân.
- Cơ sở thể thao 1–N Sự cố.
- Tài khoản 1–N Sự cố.

---

ERD 26: Bảng hệ thống

Bao gồm các bảng:
- sysdiagrams

Mô tả:
Bao gồm bảng: sysdiagrams. Đây là bảng do SQL Server Management Studio sinh ra để lưu sơ đồ, không thuộc nghiệp vụ V-SPORT và không cần vẽ trong ERD.

Quan hệ chính:
- Nhóm này không có FK vật lý nội bộ.

---
