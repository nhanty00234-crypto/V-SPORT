# 15 — Kế hoạch bố cục ERD theo nhóm

Mỗi ảnh nên có 2–5 bảng (tối đa 6 nếu bảng ít cột). Bảng trung tâm đặt giữa,
bảng lịch sử / chi tiết đặt hai bên để hạn chế đường nối cắt nhau.

## ERD 01 — Tài khoản & Phân quyền

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: Accounts, Roles, MonTheThaoYeuThich và MonTheThao. Nhóm này quản lý tài khoản của mọi vai trò trong hệ thống, phân quyền theo vai trò và môn thể thao yêu thích của khách hàng.
- **Danh sách bảng**: `Accounts`, `MonTheThaoYeuThich`, `Roles`
- **Bảng trung tâm**: `Accounts`
- **Bên trái**: `MonTheThaoYeuThich`
- **Bên phải**: `Roles`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `Accounts.RoleID` → `Roles.RoleID` (1–N, tùy chọn)
  - `MonTheThaoYeuThich.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: `MonTheThaoYeuThich`
- **Quan hệ sang nhóm khác**: `Accounts`→`CoSo`, `Accounts`→`MonTheThao`, `BangLuong`→`Accounts`, `BookingExtension`→`Accounts`, `CaLamViec_Audit`→`Accounts`, `CaLamViec_Availability`→`Accounts`, `CaLamViec_SwapRequest`→`Accounts`, `CaLamViec`→`Accounts`, `CauHinhLuong`→`Accounts`, `ChiTietGhepKeo`→`Accounts`, `ChiaHoaDon`→`Accounts`, `CoSoCapability`→`Accounts`, `CoSo`→`Accounts`, `CustomerReputationHistory`→`Accounts`, `DanhGia`→`Accounts`, `FaceChallengeToken`→`Accounts`, `GhepKeo`→`Accounts`, `HoaDon`→`Accounts`, `HoanTien`→`Accounts`, `KyLuong`→`Accounts`, `LichDatSan_DichVu`→`Accounts`, `LichDatSan`→`Accounts`, `LichSuELO`→`Accounts`, `LichSuKhuyenMai`→`Accounts`, `LichXeRaVao`→`Accounts`, `MonTheThaoYeuThich`→`MonTheThao`, `NhatKyChat`→`Accounts`, `NhatKySOSGui`→`Accounts`, `NhomChiaTienChiTiet`→`Accounts`, `NhomChiaTien`→`Accounts`, `SanQRTokenHistory`→`Accounts`, `SanQR`→`Accounts`, `ServiceOrderStatusHistory`→`Accounts`, `ServiceOrder`→`Accounts`, `SoftHold`→`Accounts`, `SuCo`→`Accounts`, `TeamInvitations`→`Accounts`, `TeamJoinRequests`→`Accounts`, `TeamMembers`→`Accounts`, `Teams`→`Accounts`, `ThongBao`→`Accounts`, `YeuCauNghi_Audit`→`Accounts`, `YeuCauNghi`→`Accounts`, `YeuCauSOS`→`Accounts`, `YeuCauUngLuong`→`Accounts`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `Accounts` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 02 — Nhật ký hệ thống & Thùng rác

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: AuditLog, AdminTrash và Accounts. Nhóm này lưu nhật ký mọi thao tác quan trọng và danh sách bản ghi đã xóa mềm để quản trị viên có thể tra cứu, khôi phục hoặc xóa vĩnh viễn.
- **Danh sách bảng**: `AuditLog`, `AdminTrash`, `Accounts`
- **Bảng trung tâm**: `AuditLog`
- **Bên trái**: `AdminTrash`
- **Bên phải**: `Accounts`
- **Trên / dưới**: `Accounts`
- **Đường nối phải thể hiện** (0 cạnh trong nhóm):
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 0 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `AuditLog` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 03 — Môn thể thao

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: MonTheThao, MonTheThaoYeuThich và LoaiSan. Nhóm này là danh mục nền tảng phân loại môn thể thao, được loại sân, ghép kèo và hồ sơ khách hàng cùng tham chiếu.
- **Danh sách bảng**: `MonTheThao`, `LoaiSan`
- **Bảng trung tâm**: `MonTheThao`
- **Bên trái**: `LoaiSan`
- **Bên phải**: —
- **Trên / dưới**: `LoaiSan`
- **Đường nối phải thể hiện** (1 cạnh trong nhóm):
  - `LoaiSan.MonTheThaoID` → `MonTheThao.MonTheThaoID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 1 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `Accounts`→`MonTheThao`, `GhepKeo`→`MonTheThao`, `MonTheThaoYeuThich`→`MonTheThao`, `Teams`→`MonTheThao`, `YeuCauSOS`→`MonTheThao`
- **Bảng chỉ hiển thị cột quan trọng**: `LoaiSan`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `MonTheThao` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LoaiSan) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 04 — Cơ sở thể thao

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: CoSo, CoSoCapability, CoSoNganHang và Accounts. Nhóm này quản lý từng cơ sở/chi nhánh, người quản lý phụ trách, các năng lực dịch vụ được duyệt và tài khoản ngân hàng nhận tiền.
- **Danh sách bảng**: `CoSo`, `CoSoCapability`, `CoSoNganHang`, `Accounts`
- **Bảng trung tâm**: `CoSo`
- **Bên trái**: `CoSoCapability`, `Accounts`
- **Bên phải**: `CoSoNganHang`
- **Trên / dưới**: `Accounts`
- **Đường nối phải thể hiện** (5 cạnh trong nhóm):
  - `Accounts.CoSoID` → `CoSo.CoSoID` (1–N, tùy chọn)
  - `CoSo.AccountID_QuanLy` → `Accounts.AccountID` (1–N, tùy chọn)
  - `CoSoCapability.ApprovedBy` → `Accounts.AccountID` (1–N, tùy chọn)
  - `CoSoCapability.CoSoID` → `CoSo.CoSoID` (1–N, bắt buộc)
  - `CoSoNganHang.CoSoID` → `CoSo.CoSoID` (1–1, bắt buộc)
- **Quan hệ 1–1**: `CoSoNganHang`→`CoSo`
- **Quan hệ 1–N**: 4 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `CaLamViec_Availability`→`CoSo`, `CaLamViec`→`CoSo`, `CauHinhLuong`→`CoSo`, `CoSoFaceConfig`→`CoSo`, `KhuyenMai`→`CoSo`, `KyLuong`→`CoSo`, `LoaiSan`→`CoSo`, `PayOSPaymentAttempt`→`CoSo`, `QRRequest`→`CoSo`, `SanPham_DichVu`→`CoSo`, `San`→`CoSo`, `ServiceMaterial`→`CoSo`, `ServiceOrder`→`CoSo`, `SportService`→`CoSo`, `SuCo`→`CoSo`, `TheGiuXe`→`CoSo`, `YeuCauNghi`→`CoSo`, `YeuCauUngLuong`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `CoSo` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 05 — Sân & Loại sân

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: San, LoaiSan, MonTheThao và LoaiSan_KhungGioDen_Backup. Nhóm này mô tả từng sân thi đấu thuộc cơ sở, loại sân theo môn thể thao cùng bảng giá và khung giờ bật đèn.
- **Danh sách bảng**: `San`, `LoaiSan`, `LoaiSan_KhungGioDen_Backup`, `MonTheThao`, `CoSo`
- **Bảng trung tâm**: `San`
- **Bên trái**: `LoaiSan`, `MonTheThao`
- **Bên phải**: `LoaiSan_KhungGioDen_Backup`, `CoSo`
- **Trên / dưới**: `MonTheThao`, `CoSo`
- **Đường nối phải thể hiện** (4 cạnh trong nhóm):
  - `LoaiSan.CoSoID` → `CoSo.CoSoID` (1–N, tùy chọn)
  - `LoaiSan.MonTheThaoID` → `MonTheThao.MonTheThaoID` (1–N, bắt buộc)
  - `San.CoSoID` → `CoSo.CoSoID` (1–N, bắt buộc)
  - `San.LoaiSanID` → `LoaiSan.LoaiSanID` (1–N, tùy chọn)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 4 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `LichDatSan`→`San`, `QRRequest`→`San`, `SanQRTokenHistory`→`San`, `SanQR`→`San`, `SoftHold`→`San`
- **Bảng chỉ hiển thị cột quan trọng**: `MonTheThao`, `CoSo`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `San` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (MonTheThao, CoSo) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 06 — Đặt sân & Giữ chỗ

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: LichDatSan, SoftHold, BookingExtension và LichDatSan_DichVu. Nhóm này là trung tâm nghiệp vụ đặt sân, từ giữ chỗ tạm thời khi khách thao tác đến gia hạn giờ chơi và dịch vụ đặt kèm.
- **Danh sách bảng**: `LichDatSan`, `BookingExtension`, `LichDatSan_DichVu`, `SoftHold`
- **Bảng trung tâm**: `LichDatSan`
- **Bên trái**: `BookingExtension`, `SoftHold`
- **Bên phải**: `LichDatSan_DichVu`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `BookingExtension.DatSanID` → `LichDatSan.DatSanID` (1–N, bắt buộc)
  - `LichDatSan_DichVu.DatSanID` → `LichDatSan.DatSanID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `BookingExtension`→`Accounts`, `CourtChargeSegment`→`LichDatSan`, `CustomerReputationHistory`→`LichDatSan`, `DanhGia`→`LichDatSan`, `GhepKeo`→`LichDatSan`, `HoaDon`→`LichDatSan`, `LichDatSan_DichVu`→`Accounts`, `LichDatSan_DichVu`→`SanPham_DichVu`, `LichDatSan`→`Accounts`, `LichDatSan`→`San`, `LichSuELO`→`LichDatSan`, `LichXeRaVao`→`LichDatSan`, `NhomChiaTien`→`LichDatSan`, `PayOSPaymentAttempt`→`LichDatSan`, `ServiceOrder`→`LichDatSan`, `SoftHold`→`Accounts`, `SoftHold`→`San`, `YeuCauSOS`→`LichDatSan`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `LichDatSan` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 07 — Check-in & Phiên sử dụng sân

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: CourtChargeSegment, LichDatSan và HoaDon. Nhóm này ghi lại phiên sử dụng sân thực tế và chia lượt chơi thành các đoạn giá có đèn hoặc không đèn để tính tiền khi kết thúc.
- **Danh sách bảng**: `CourtChargeSegment`, `LichDatSan`, `HoaDon`
- **Bảng trung tâm**: `CourtChargeSegment`
- **Bên trái**: `LichDatSan`
- **Bên phải**: `HoaDon`
- **Trên / dưới**: `LichDatSan`, `HoaDon`
- **Đường nối phải thể hiện** (4 cạnh trong nhóm):
  - `CourtChargeSegment.HoaDonID` → `HoaDon.HoaDonID` (1–N, bắt buộc)
  - `CourtChargeSegment.DatSanID` → `LichDatSan.DatSanID` (1–N, bắt buộc)
  - `HoaDon.DatSanID` → `LichDatSan.DatSanID` (1–1, tùy chọn)
  - `HoaDon.ParentHoaDonID` → `HoaDon.HoaDonID` (1–N, tùy chọn)
- **Quan hệ 1–1**: `HoaDon`→`LichDatSan`
- **Quan hệ 1–N**: 3 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: `LichDatSan`, `HoaDon`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `CourtChargeSegment` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LichDatSan, HoaDon) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 08 — Hóa đơn & Thanh toán

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: HoaDon, ChiTietHoaDon, PayOSPaymentAttempt và LichDatSan. Nhóm này quản lý hóa đơn của lượt đặt sân, từng dòng sản phẩm trong hóa đơn và các lượt thanh toán qua cổng PayOS.
- **Danh sách bảng**: `HoaDon`, `ChiTietHoaDon`, `PayOSPaymentAttempt`, `LichDatSan`
- **Bảng trung tâm**: `HoaDon`
- **Bên trái**: `ChiTietHoaDon`, `LichDatSan`
- **Bên phải**: `PayOSPaymentAttempt`
- **Trên / dưới**: `LichDatSan`
- **Đường nối phải thể hiện** (5 cạnh trong nhóm):
  - `ChiTietHoaDon.HoaDonID` → `HoaDon.HoaDonID` (1–N, tùy chọn)
  - `HoaDon.DatSanID` → `LichDatSan.DatSanID` (1–1, tùy chọn)
  - `HoaDon.ParentHoaDonID` → `HoaDon.HoaDonID` (1–N, tùy chọn)
  - `PayOSPaymentAttempt.HoaDonID` → `HoaDon.HoaDonID` (1–1, bắt buộc)
  - `PayOSPaymentAttempt.DatSanID` → `LichDatSan.DatSanID` (1–N, bắt buộc)
- **Quan hệ 1–1**: `HoaDon`→`LichDatSan`, `PayOSPaymentAttempt`→`HoaDon`
- **Quan hệ 1–N**: 3 cạnh
- **Quan hệ N–N qua bảng trung gian**: `ChiTietHoaDon`
- **Quan hệ sang nhóm khác**: `ChiTietHoaDon`→`SanPham_DichVu`, `ChiaHoaDon`→`HoaDon`, `CourtChargeSegment`→`HoaDon`, `HoaDon`→`Accounts`, `HoaDon`→`KhuyenMai`, `HoanTien`→`HoaDon`, `NhomChiaTien`→`HoaDon`, `PayOSPaymentAttempt`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: `LichDatSan`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `HoaDon` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LichDatSan) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 09 — Hoàn tiền

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: HoanTien, HoaDon và Accounts. Nhóm này quản lý yêu cầu hoàn tiền của khách sau khi hủy đặt sân, gồm số tiền, trạng thái duyệt và người xử lý.
- **Danh sách bảng**: `HoanTien`, `HoaDon`, `Accounts`
- **Bảng trung tâm**: `HoanTien`
- **Bên trái**: `HoaDon`
- **Bên phải**: `Accounts`
- **Trên / dưới**: `HoaDon`, `Accounts`
- **Đường nối phải thể hiện** (5 cạnh trong nhóm):
  - `HoaDon.AccountID_KhachHang` → `Accounts.AccountID` (1–N, tùy chọn)
  - `HoaDon.AccountID_NhanVien` → `Accounts.AccountID` (1–N, tùy chọn)
  - `HoaDon.ParentHoaDonID` → `HoaDon.HoaDonID` (1–N, tùy chọn)
  - `HoanTien.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
  - `HoanTien.HoaDonID` → `HoaDon.HoaDonID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 5 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: `HoaDon`, `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `HoanTien` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (HoaDon, Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 10 — Sản phẩm & Kho

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: SanPham_DichVu, DanhMucSanPham và ServiceMaterial. Nhóm này quản lý sản phẩm, đồ uống bán lẻ tại cơ sở theo danh mục và vật tư kho dùng cho các dịch vụ thể thao.
- **Danh sách bảng**: `SanPham_DichVu`, `DanhMucSanPham`, `ServiceMaterial`
- **Bảng trung tâm**: `SanPham_DichVu`
- **Bên trái**: `DanhMucSanPham`
- **Bên phải**: `ServiceMaterial`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (1 cạnh trong nhóm):
  - `SanPham_DichVu.DanhMucID` → `DanhMucSanPham.DanhMucID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 1 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `ChiTietHoaDon`→`SanPham_DichVu`, `LichDatSan_DichVu`→`SanPham_DichVu`, `RacketStringingOrderDetail`→`ServiceMaterial`, `SanPham_DichVu`→`CoSo`, `ServiceMaterial`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `SanPham_DichVu` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 11 — Dịch vụ thể thao

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: SportService, ServiceOrder, ServiceOrderStatusHistory, RacketStringingConfig và RacketStringingOrderDetail. Nhóm này quản lý dịch vụ chuyên biệt như căng vợt, sửa vợt và vòng đời trạng thái của từng đơn dịch vụ.
- **Danh sách bảng**: `ServiceOrder`, `RacketStringingConfig`, `RacketStringingOrderDetail`, `ServiceOrderStatusHistory`, `SportService`
- **Bảng trung tâm**: `ServiceOrder`
- **Bên trái**: `RacketStringingConfig`, `ServiceOrderStatusHistory`
- **Bên phải**: `RacketStringingOrderDetail`, `SportService`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (4 cạnh trong nhóm):
  - `RacketStringingConfig.ServiceID` → `SportService.ServiceID` (1–1, bắt buộc)
  - `RacketStringingOrderDetail.OrderID` → `ServiceOrder.OrderID` (1–1, bắt buộc)
  - `ServiceOrder.ServiceID` → `SportService.ServiceID` (1–N, bắt buộc)
  - `ServiceOrderStatusHistory.OrderID` → `ServiceOrder.OrderID` (1–N, bắt buộc)
- **Quan hệ 1–1**: `RacketStringingConfig`→`SportService`, `RacketStringingOrderDetail`→`ServiceOrder`
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `RacketStringingOrderDetail`→`ServiceMaterial`, `ServiceOrderStatusHistory`→`Accounts`, `ServiceOrder`→`Accounts`, `ServiceOrder`→`CoSo`, `ServiceOrder`→`LichDatSan`, `SportService`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `ServiceOrder` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 12 — Khuyến mãi

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: KhuyenMai, KhuyenMaiHinhAnh và LichSuKhuyenMai. Nhóm này quản lý chương trình khuyến mãi của từng cơ sở, hình ảnh minh họa và lịch sử mỗi lần khách sử dụng mã.
- **Danh sách bảng**: `KhuyenMai`, `KhuyenMaiHinhAnh`, `LichSuKhuyenMai`
- **Bảng trung tâm**: `KhuyenMai`
- **Bên trái**: `KhuyenMaiHinhAnh`
- **Bên phải**: `LichSuKhuyenMai`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `KhuyenMaiHinhAnh.KhuyenMaiID` → `KhuyenMai.KhuyenMaiID` (1–1, bắt buộc)
  - `LichSuKhuyenMai.KhuyenMaiID` → `KhuyenMai.KhuyenMaiID` (1–N, bắt buộc)
- **Quan hệ 1–1**: `KhuyenMaiHinhAnh`→`KhuyenMai`
- **Quan hệ 1–N**: 1 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `HoaDon`→`KhuyenMai`, `KhuyenMai`→`CoSo`, `LichSuKhuyenMai`→`Accounts`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `KhuyenMai` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 13 — Ghép kèo

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: GhepKeo, ChiTietGhepKeo, LichDatSan và MonTheThao. Nhóm này cho phép khách đăng kèo từ một lượt đặt sân và quản lý danh sách người tham gia được duyệt tự động hoặc thủ công.
- **Danh sách bảng**: `GhepKeo`, `ChiTietGhepKeo`, `LichDatSan`, `MonTheThao`
- **Bảng trung tâm**: `GhepKeo`
- **Bên trái**: `ChiTietGhepKeo`, `MonTheThao`
- **Bên phải**: `LichDatSan`
- **Trên / dưới**: `LichDatSan`, `MonTheThao`
- **Đường nối phải thể hiện** (3 cạnh trong nhóm):
  - `ChiTietGhepKeo.KeoID` → `GhepKeo.KeoID` (1–N, tùy chọn)
  - `GhepKeo.DatSanID` → `LichDatSan.DatSanID` (1–N, tùy chọn)
  - `GhepKeo.MonTheThaoID` → `MonTheThao.MonTheThaoID` (1–N, tùy chọn)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 3 cạnh
- **Quan hệ N–N qua bảng trung gian**: `ChiTietGhepKeo`
- **Quan hệ sang nhóm khác**: `ChiTietGhepKeo`→`Accounts`, `ChiTietGhepKeo`→`Teams`, `GhepKeo`→`Accounts`, `GhepKeo`→`Teams`
- **Bảng chỉ hiển thị cột quan trọng**: `LichDatSan`, `MonTheThao`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `GhepKeo` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LichDatSan, MonTheThao) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 14 — Đội nhóm người chơi

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: Teams, TeamMembers, TeamInvitations và TeamJoinRequests. Nhóm này quản lý đội do khách hàng lập, thành viên và vai trò trong đội, cùng hai luồng mời vào đội và xin gia nhập.
- **Danh sách bảng**: `Teams`, `TeamInvitations`, `TeamJoinRequests`, `TeamMembers`
- **Bảng trung tâm**: `Teams`
- **Bên trái**: `TeamInvitations`, `TeamMembers`
- **Bên phải**: `TeamJoinRequests`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (3 cạnh trong nhóm):
  - `TeamMembers.TeamID` → `Teams.TeamID` (1–N, bắt buộc)
  - `TeamInvitations.TeamID` → `Teams.TeamID` (1–N, bắt buộc)
  - `TeamJoinRequests.TeamID` → `Teams.TeamID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 3 cạnh
- **Quan hệ N–N qua bảng trung gian**: `TeamMembers`
- **Quan hệ sang nhóm khác**: `ChiTietGhepKeo`→`Teams`, `GhepKeo`→`Teams`, `TeamInvitations`→`Accounts`, `TeamJoinRequests`→`Accounts`, `TeamMembers`→`Accounts`, `Teams`→`Accounts`, `Teams`→`MonTheThao`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `Teams` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 15 — Thông báo & Chat

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: ThongBao, NhatKyChat và Accounts. Nhóm này lưu thông báo hệ thống gửi tới từng tài khoản với cơ chế chống trùng, và lịch sử hội thoại với trợ lý chatbot.
- **Danh sách bảng**: `ThongBao`, `NhatKyChat`, `Accounts`
- **Bảng trung tâm**: `ThongBao`
- **Bên trái**: `NhatKyChat`
- **Bên phải**: `Accounts`
- **Trên / dưới**: `Accounts`
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `NhatKyChat.AccountID` → `Accounts.AccountID` (1–N, tùy chọn)
  - `ThongBao.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `ThongBao` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 16 — SOS

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: YeuCauSOS, NhatKySOSGui và LichDatSan. Nhóm này xử lý yêu cầu khẩn tìm người chơi thay cho một lượt đặt sân và ghi nhật ký từng lượt gửi thông báo tới người nhận.
- **Danh sách bảng**: `YeuCauSOS`, `NhatKySOSGui`, `LichDatSan`
- **Bảng trung tâm**: `YeuCauSOS`
- **Bên trái**: `NhatKySOSGui`
- **Bên phải**: `LichDatSan`
- **Trên / dưới**: `LichDatSan`
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `NhatKySOSGui.YeuCauSOSID` → `YeuCauSOS.YeuCauSOSID` (1–N, bắt buộc)
  - `YeuCauSOS.DatSanID` → `LichDatSan.DatSanID` (1–N, tùy chọn)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `NhatKySOSGui`→`Accounts`, `YeuCauSOS`→`Accounts`, `YeuCauSOS`→`MonTheThao`
- **Bảng chỉ hiển thị cột quan trọng**: `LichDatSan`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `YeuCauSOS` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LichDatSan) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 17 — Ca làm việc

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: CaLamViec, CaLamViec_Audit, CaLamViec_Availability và CaLamViec_SwapRequest. Nhóm này quản lý lịch ca của nhân viên và bảo vệ, thời gian rảnh đăng ký, yêu cầu đổi ca và nhật ký thay đổi.
- **Danh sách bảng**: `CaLamViec`, `CaLamViec_Audit`, `CaLamViec_Availability`, `CaLamViec_SwapRequest`
- **Bảng trung tâm**: `CaLamViec`
- **Bên trái**: `CaLamViec_Audit`, `CaLamViec_SwapRequest`
- **Bên phải**: `CaLamViec_Availability`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `CaLamViec_SwapRequest.CaLamViecID_Gui` → `CaLamViec.CaLamViecID` (1–N, bắt buộc)
  - `CaLamViec_SwapRequest.CaLamViecID_Nhan` → `CaLamViec.CaLamViecID` (1–N, tùy chọn)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `CaLamViec_Audit`→`Accounts`, `CaLamViec_Availability`→`Accounts`, `CaLamViec_Availability`→`CoSo`, `CaLamViec_SwapRequest`→`Accounts`, `CaLamViec`→`Accounts`, `CaLamViec`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `CaLamViec` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 18 — Nghỉ phép

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: YeuCauNghi, YeuCauNghi_Audit và Accounts. Nhóm này quản lý đơn xin nghỉ của nhân viên theo cơ sở, quy trình duyệt của quản lý và nhật ký mọi thao tác trên đơn.
- **Danh sách bảng**: `YeuCauNghi`, `YeuCauNghi_Audit`, `Accounts`
- **Bảng trung tâm**: `YeuCauNghi`
- **Bên trái**: `YeuCauNghi_Audit`
- **Bên phải**: `Accounts`
- **Trên / dưới**: `Accounts`
- **Đường nối phải thể hiện** (4 cạnh trong nhóm):
  - `YeuCauNghi.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
  - `YeuCauNghi.XuLyBy` → `Accounts.AccountID` (1–N, tùy chọn)
  - `YeuCauNghi_Audit.NguoiThucHien` → `Accounts.AccountID` (1–N, bắt buộc)
  - `YeuCauNghi_Audit.YeuCauNghiID` → `YeuCauNghi.YeuCauNghiID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 4 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `YeuCauNghi`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `YeuCauNghi` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 19 — Mã QR sân

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: SanQR, SanQRTokenHistory, QRRequest và San. Nhóm này quản lý mã QR gắn cho từng sân, lịch sử token đã cấp hoặc thu hồi và các yêu cầu khách gửi sau khi quét mã.
- **Danh sách bảng**: `SanQR`, `QRRequest`, `SanQRTokenHistory`, `San`
- **Bảng trung tâm**: `SanQR`
- **Bên trái**: `QRRequest`, `San`
- **Bên phải**: `SanQRTokenHistory`
- **Trên / dưới**: `San`
- **Đường nối phải thể hiện** (4 cạnh trong nhóm):
  - `QRRequest.SanID` → `San.SanID` (1–N, bắt buộc)
  - `SanQR.SanID` → `San.SanID` (1–1, bắt buộc)
  - `SanQRTokenHistory.SanID` → `San.SanID` (1–N, bắt buộc)
  - `SanQRTokenHistory.SanQRID` → `SanQR.SanQRID` (1–N, bắt buộc)
- **Quan hệ 1–1**: `SanQR`→`San`
- **Quan hệ 1–N**: 3 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `QRRequest`→`CoSo`, `SanQRTokenHistory`→`Accounts`, `SanQR`→`Accounts`
- **Bảng chỉ hiển thị cột quan trọng**: `San`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `SanQR` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (San) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 20 — Đánh giá, ELO & Uy tín

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: DanhGia, LichSuELO, CustomerReputationHistory và Accounts. Nhóm này lưu đánh giá sau trận giữa người chơi, biến động điểm trình độ ELO và điểm uy tín của khách hàng.
- **Danh sách bảng**: `CustomerReputationHistory`, `DanhGia`, `LichSuELO`, `Accounts`
- **Bảng trung tâm**: `Accounts`
- **Bên trái**: `DanhGia`, `Accounts`
- **Bên phải**: `LichSuELO`
- **Trên / dưới**: `Accounts`
- **Đường nối phải thể hiện** (5 cạnh trong nhóm):
  - `CustomerReputationHistory.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
  - `CustomerReputationHistory.CreatedBy` → `Accounts.AccountID` (1–N, tùy chọn)
  - `DanhGia.AccountID_NguoiBiDanhGia` → `Accounts.AccountID` (1–N, tùy chọn)
  - `DanhGia.AccountID_NguoiDanhGia` → `Accounts.AccountID` (1–N, tùy chọn)
  - `LichSuELO.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 5 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `CustomerReputationHistory`→`LichDatSan`, `DanhGia`→`LichDatSan`, `LichSuELO`→`LichDatSan`
- **Bảng chỉ hiển thị cột quan trọng**: `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `Accounts` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 21 — Giữ xe

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: TheGiuXe, LichXeRaVao và LichDatSan. Nhóm này quản lý thẻ giữ xe phát hành tại cơ sở và nhật ký từng lượt xe vào, ra bãi gắn với lượt đặt sân tương ứng.
- **Danh sách bảng**: `TheGiuXe`, `LichXeRaVao`, `LichDatSan`
- **Bảng trung tâm**: `TheGiuXe`
- **Bên trái**: `LichXeRaVao`
- **Bên phải**: `LichDatSan`
- **Trên / dưới**: `LichDatSan`
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `LichXeRaVao.DatSanID` → `LichDatSan.DatSanID` (1–N, tùy chọn)
  - `LichXeRaVao.TheID` → `TheGiuXe.TheID` (1–N, tùy chọn)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `LichXeRaVao`→`Accounts`, `TheGiuXe`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: `LichDatSan`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `TheGiuXe` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (LichDatSan) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 22 — Chia hóa đơn

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: NhomChiaTien, NhomChiaTienChiTiet, ChiaHoaDon và MaQR. Nhóm này cho phép chia một hóa đơn cho nhiều người theo nhiều hình thức, kèm cơ chế chia hóa đơn đời cũ đã ngừng dùng.
- **Danh sách bảng**: `NhomChiaTien`, `ChiaHoaDon`, `MaQR`, `NhomChiaTienChiTiet`
- **Bảng trung tâm**: `NhomChiaTien`
- **Bên trái**: `ChiaHoaDon`, `NhomChiaTienChiTiet`
- **Bên phải**: `MaQR`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `NhomChiaTienChiTiet.NhomChiaTienID` → `NhomChiaTien.NhomChiaTienID` (1–N, bắt buộc)
  - `MaQR.ChiaHoaDonID` → `ChiaHoaDon.ChiaHoaDonID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: `NhomChiaTienChiTiet`
- **Quan hệ sang nhóm khác**: `ChiaHoaDon`→`Accounts`, `ChiaHoaDon`→`HoaDon`, `NhomChiaTienChiTiet`→`Accounts`, `NhomChiaTien`→`Accounts`, `NhomChiaTien`→`HoaDon`, `NhomChiaTien`→`LichDatSan`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `NhomChiaTien` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 23 — Lương, Phụ cấp & Ứng lương

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: CauHinhLuong, KyLuong, BangLuong và YeuCauUngLuong. Nhóm này cấu hình lương cơ bản và phụ cấp mỗi ca cho nhân viên, tính bảng lương theo từng kỳ và xử lý đơn ứng lương.
- **Danh sách bảng**: `KyLuong`, `BangLuong`, `CauHinhLuong`, `YeuCauUngLuong`
- **Bảng trung tâm**: `KyLuong`
- **Bên trái**: `BangLuong`, `YeuCauUngLuong`
- **Bên phải**: `CauHinhLuong`
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (1 cạnh trong nhóm):
  - `BangLuong.KyLuongID` → `KyLuong.KyLuongID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 1 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `BangLuong`→`Accounts`, `CauHinhLuong`→`Accounts`, `CauHinhLuong`→`CoSo`, `KyLuong`→`Accounts`, `KyLuong`→`CoSo`, `YeuCauUngLuong`→`Accounts`, `YeuCauUngLuong`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `KyLuong` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 24 — Điểm danh khuôn mặt

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: CoSoFaceConfig, FaceChallengeToken, CaLamViec và Accounts. Nhóm này bật bắt buộc điểm danh bằng khuôn mặt theo cơ sở, sinh token thử thách liveness và ghi kết quả vào ca làm việc.
- **Danh sách bảng**: `CoSoFaceConfig`, `FaceChallengeToken`, `CaLamViec`, `Accounts`
- **Bảng trung tâm**: `CoSoFaceConfig`
- **Bên trái**: `FaceChallengeToken`, `Accounts`
- **Bên phải**: `CaLamViec`
- **Trên / dưới**: `CaLamViec`, `Accounts`
- **Đường nối phải thể hiện** (2 cạnh trong nhóm):
  - `CaLamViec.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
  - `FaceChallengeToken.AccountID` → `Accounts.AccountID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 2 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: `CoSoFaceConfig`→`CoSo`
- **Bảng chỉ hiển thị cột quan trọng**: `CaLamViec`, `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `CoSoFaceConfig` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (CaLamViec, Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 25 — Bảo vệ & Sự cố

- **Mục tiêu nghiệp vụ**: Bao gồm các bảng: SuCo, CoSo, San và Accounts. Nhóm này cho bảo vệ báo cáo sự cố tại cơ sở hoặc sân cụ thể, phân loại mức độ và theo dõi quy trình xử lý của quản lý.
- **Danh sách bảng**: `SuCo`, `CoSo`, `San`, `Accounts`
- **Bảng trung tâm**: `SuCo`
- **Bên trái**: `CoSo`, `Accounts`
- **Bên phải**: `San`
- **Trên / dưới**: `CoSo`, `San`, `Accounts`
- **Đường nối phải thể hiện** (5 cạnh trong nhóm):
  - `Accounts.CoSoID` → `CoSo.CoSoID` (1–N, tùy chọn)
  - `CoSo.AccountID_QuanLy` → `Accounts.AccountID` (1–N, tùy chọn)
  - `San.CoSoID` → `CoSo.CoSoID` (1–N, bắt buộc)
  - `SuCo.CoSoID` → `CoSo.CoSoID` (1–N, bắt buộc)
  - `SuCo.BaoVeID` → `Accounts.AccountID` (1–N, bắt buộc)
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 5 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: `CoSo`, `San`, `Accounts`
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `SuCo` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (CoSo, San, Accounts) đặt ở rìa và chỉ vẽ 1 đường nối.

## ERD 26 — Bảng hệ thống

- **Mục tiêu nghiệp vụ**: Bao gồm bảng: sysdiagrams. Đây là bảng do SQL Server Management Studio sinh ra để lưu sơ đồ, không thuộc nghiệp vụ V-SPORT và không cần vẽ trong ERD.
- **Danh sách bảng**: `sysdiagrams`
- **Bảng trung tâm**: `sysdiagrams`
- **Bên trái**: —
- **Bên phải**: —
- **Trên / dưới**: —
- **Đường nối phải thể hiện** (0 cạnh trong nhóm):
- **Quan hệ 1–1**: không có
- **Quan hệ 1–N**: 0 cạnh
- **Quan hệ N–N qua bảng trung gian**: không có
- **Quan hệ sang nhóm khác**: không có
- **Bảng chỉ hiển thị cột quan trọng**: —
- **Tách ảnh A/B?**: Không cần
- **Gợi ý tránh cắt nhau**: đặt `sysdiagrams` ở giữa, các bảng chỉ trỏ vào bảng trung tâm xếp vòng cung quanh nó; bảng tham chiếu rút gọn (không có) đặt ở rìa và chỉ vẽ 1 đường nối.
