/* V-SPORT ERD — dữ liệu nguồn duy nhất (schema đúng, đầy đủ).
 * 35 thực thể logic, 21 nhóm màn hình. Toàn bộ đường quan hệ được suy ra
 * (derive) từ metadata FK (thamChieu) khai báo trong từng cột — không có
 * danh sách cạnh thủ công nào khác trong app.js.
 *
 * Mỗi cột:
 * {
 *   columnKey,     // tên cột vật lý
 *   tenHienThi,    // tên cột hiển thị (tiếng Việt có dấu)
 *   kieu,          // kiểu SQL hiển thị
 *   pk, fk, unique, nullable,  // cờ ràng buộc
 *   thamChieu,     // "TargetTableKey.TargetColumnKey" — chỉ khi fk === true
 *   ghiChuNgan,    // ghi chú ngắn tuỳ chọn
 *   vaiTro,        // nhãn vai trò khi có nhiều FK cùng trỏ tới 1 bảng
 *   fkLogic,       // true = khóa ngoại LOGIC (không vẽ đường nối thật)
 * }
 *
 * Mỗi thực thể:
 * { tableKey, tenVatLy, tenHienThi, ghiChu, cotChinh: [...], cotMoRong: [...] }
 */
(function (global) {
  'use strict';

  var ERD_ENTITIES = [
    // 7.1 ---------------------------------------------------------------
    {
      tableKey: 'Roles',
      tenVatLy: 'Roles',
      tenHienThi: 'VAI TRÒ',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'RoleID', tenHienThi: 'Mã vai trò', kieu: 'INT', pk: true },
        { columnKey: 'RoleName', tenHienThi: 'Tên vai trò', kieu: 'NVARCHAR(50)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.2 ---------------------------------------------------------------
    {
      tableKey: 'Accounts',
      tenVatLy: 'Accounts',
      tenHienThi: 'TÀI KHOẢN',
      ghiChu: 'Chỉ 4 vai trò chính thức: ADMIN, MANAGER, STAFF, CUSTOMER.',
      cotChinh: [
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', pk: true },
        { columnKey: 'RoleID', tenHienThi: 'Mã vai trò', kieu: 'INT', fk: true, thamChieu: 'Roles.RoleID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, nullable: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'FullName', tenHienThi: 'Họ và tên', kieu: 'NVARCHAR(255)' },
        { columnKey: 'Email', tenHienThi: 'Email', kieu: 'VARCHAR(100)', unique: true },
        { columnKey: 'PhoneNumber', tenHienThi: 'Số điện thoại', kieu: 'NVARCHAR(20)', unique: true, nullable: true },
        { columnKey: 'Password', tenHienThi: 'Mật khẩu đã băm', kieu: 'VARCHAR(255)' },
        { columnKey: 'AvatarUrl', tenHienThi: 'Ảnh đại diện', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'DiemUyTin', tenHienThi: 'Điểm uy tín', kieu: 'INT', ghiChuNgan: 'mặc định 100' }
      ],
      cotMoRong: [
        { columnKey: 'CoverImageUrl', tenHienThi: 'Ảnh bìa', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'DiemTrinhDo', tenHienThi: 'Điểm trình độ', kieu: 'INT' },
        { columnKey: 'NgaySinh', tenHienThi: 'Ngày sinh', kieu: 'DATE', nullable: true },
        { columnKey: 'GioiTinh', tenHienThi: 'Giới tính', kieu: 'NVARCHAR(10)', nullable: true }
      ]
    },

    // 7.3 ---------------------------------------------------------------
    {
      tableKey: 'MonTheThaoYeuThich',
      tenVatLy: 'MonTheThaoYeuThich',
      tenHienThi: 'MÔN THỂ THAO YÊU THÍCH',
      ghiChu: 'Bảng nối N-N giữa Tài khoản và Môn thể thao.',
      cotChinh: [
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', pk: true, fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Mã môn thể thao', kieu: 'INT', pk: true, fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'NgayThem', tenHienThi: 'Ngày thêm', kieu: 'DATETIME' }
      ],
      cotMoRong: []
    },

    // 7.4 ---------------------------------------------------------------
    {
      tableKey: 'CoSo',
      tenVatLy: 'CoSo',
      tenHienThi: 'CƠ SỞ',
      ghiChu: 'HinhAnh lưu mảng JSON đường dẫn, tối đa 10 ảnh. ViDo/KinhDo dùng cho bản đồ và tìm cơ sở gần nhất.',
      cotChinh: [
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', pk: true },
        { columnKey: 'AccountID_QuanLy', tenHienThi: 'Mã quản lý', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Quản lý cơ sở' },
        { columnKey: 'TenCoSo', tenHienThi: 'Tên cơ sở', kieu: 'NVARCHAR(255)' },
        { columnKey: 'DiaChi', tenHienThi: 'Địa chỉ', kieu: 'NVARCHAR(500)' },
        { columnKey: 'GioMoCua', tenHienThi: 'Giờ mở cửa', kieu: 'TIME' },
        { columnKey: 'GioDongCua', tenHienThi: 'Giờ đóng cửa', kieu: 'TIME' },
        { columnKey: 'HinhAnh', tenHienThi: 'Danh sách hình ảnh', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'JSON đường dẫn ảnh, tối đa 10 ảnh' },
        { columnKey: 'ViDo', tenHienThi: 'Vĩ độ', kieu: 'DECIMAL(12,9)', nullable: true },
        { columnKey: 'KinhDo', tenHienThi: 'Kinh độ', kieu: 'DECIMAL(12,9)', nullable: true },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.5 ---------------------------------------------------------------
    {
      tableKey: 'MonTheThao',
      tenVatLy: 'MonTheThao',
      tenHienThi: 'MÔN THỂ THAO',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'MonTheThaoID', tenHienThi: 'Mã môn thể thao', kieu: 'INT', pk: true },
        { columnKey: 'TenMon', tenHienThi: 'Tên môn', kieu: 'NVARCHAR(50)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.6 ---------------------------------------------------------------
    {
      tableKey: 'LoaiSan',
      tenVatLy: 'LoaiSan',
      tenHienThi: 'LOẠI SÂN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'LoaiSanID', tenHienThi: 'Mã loại sân', kieu: 'INT', pk: true },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Mã môn thể thao', kieu: 'INT', fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'TenLoai', tenHienThi: 'Tên loại sân', kieu: 'NVARCHAR(100)' },
        { columnKey: 'GiaKhongDen', tenHienThi: 'Giá không đèn', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'GiaCoDen', tenHienThi: 'Giá có đèn', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'GioBatDauLenDen', tenHienThi: 'Giờ bắt đầu có đèn', kieu: 'TIME', nullable: true },
        { columnKey: 'GioKetThucLenDen', tenHienThi: 'Giờ kết thúc có đèn', kieu: 'TIME', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.7 ---------------------------------------------------------------
    {
      tableKey: 'San',
      tenVatLy: 'San',
      tenHienThi: 'SÂN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', pk: true },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'LoaiSanID', tenHienThi: 'Mã loại sân', kieu: 'INT', fk: true, thamChieu: 'LoaiSan.LoaiSanID' },
        { columnKey: 'TenSan', tenHienThi: 'Tên sân', kieu: 'NVARCHAR(100)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' },
        { columnKey: 'HinhAnh', tenHienThi: 'Hình ảnh', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'đường dẫn ảnh' }
      ],
      cotMoRong: []
    },

    // 7.8 ---------------------------------------------------------------
    {
      tableKey: 'SoftHold',
      tenVatLy: 'SoftHold',
      tenHienThi: 'GIỮ CHỖ TẠM',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'HoldID', tenHienThi: 'Mã giữ chỗ', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'NgayDat', tenHienThi: 'Ngày đặt', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Giờ bắt đầu', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'Giờ kết thúc', kieu: 'TIME' },
        { columnKey: 'ExpiresAt', tenHienThi: 'Hết hạn lúc', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.9 ---------------------------------------------------------------
    {
      tableKey: 'LichDatSan',
      tenVatLy: 'LichDatSan',
      tenHienThi: 'LỊCH ĐẶT SÂN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Mã khách hàng', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'NgayDat', tenHienThi: 'Ngày đặt', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Giờ bắt đầu', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'Giờ kết thúc', kieu: 'TIME' },
        { columnKey: 'TongTienDuKien', tenHienThi: 'Tổng tiền dự kiến', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' },
        { columnKey: 'ActualStartAt', tenHienThi: 'Bắt đầu thực tế', kieu: 'DATETIME2', nullable: true },
        { columnKey: 'ActualEndAt', tenHienThi: 'Kết thúc thực tế', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: [
        { columnKey: 'BookingSource', tenHienThi: 'Nguồn đặt sân', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CancelType', tenHienThi: 'Loại hủy', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CancelReason', tenHienThi: 'Lý do hủy', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'ConfirmedBy', tenHienThi: 'Người xác nhận', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người xác nhận' },
        { columnKey: 'CancelledBy', tenHienThi: 'Người hủy', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người hủy' }
      ]
    },

    // 7.10 --------------------------------------------------------------
    {
      tableKey: 'BookingExtension',
      tenVatLy: 'BookingExtension',
      tenHienThi: 'LỊCH SỬ GIA HẠN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'ExtensionID', tenHienThi: 'Mã gia hạn', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'NewGioKetThucDateTime', tenHienThi: 'Kết thúc mới', kieu: 'DATETIME2' },
        { columnKey: 'AdditionalAmount', tenHienThi: 'Phí phát sinh', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'OperatorAccountID', tenHienThi: 'Nhân viên thao tác', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người thao tác' },
        { columnKey: 'CreatedAt', tenHienThi: 'Thời gian tạo', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.11 --------------------------------------------------------------
    {
      tableKey: 'DanhMucSanPham',
      tenVatLy: 'DanhMucSanPham',
      tenHienThi: 'DANH MỤC SẢN PHẨM',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'DanhMucID', tenHienThi: 'Mã danh mục', kieu: 'INT', pk: true },
        { columnKey: 'TenDanhMuc', tenHienThi: 'Tên danh mục', kieu: 'NVARCHAR(100)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.12 --------------------------------------------------------------
    {
      tableKey: 'SanPham_DichVu',
      tenVatLy: 'SanPham_DichVu',
      tenHienThi: 'SẢN PHẨM DỊCH VỤ',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'SanPhamID', tenHienThi: 'Mã sản phẩm', kieu: 'INT', pk: true },
        { columnKey: 'DanhMucID', tenHienThi: 'Mã danh mục', kieu: 'INT', fk: true, thamChieu: 'DanhMucSanPham.DanhMucID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'TenSanPham', tenHienThi: 'Tên sản phẩm', kieu: 'NVARCHAR(200)' },
        { columnKey: 'DonGia', tenHienThi: 'Đơn giá', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'SoLuongTon', tenHienThi: 'Số lượng tồn', kieu: 'INT' },
        { columnKey: 'HinhAnh', tenHienThi: 'Hình ảnh', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'đường dẫn ảnh' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.13 --------------------------------------------------------------
    {
      tableKey: 'LichDatSan_DichVu',
      tenVatLy: 'LichDatSan_DichVu',
      tenHienThi: 'DỊCH VỤ ĐẶT KÈM',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'Id', tenHienThi: 'Mã chi tiết', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'SanPhamID', tenHienThi: 'Mã sản phẩm', kieu: 'INT', fk: true, thamChieu: 'SanPham_DichVu.SanPhamID' },
        { columnKey: 'Quantity', tenHienThi: 'Số lượng', kieu: 'INT' },
        { columnKey: 'UnitPrice', tenHienThi: 'Đơn giá', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TotalPrice', tenHienThi: 'Thành tiền', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Status', tenHienThi: 'Trạng thái giao', kieu: 'NVARCHAR(50)' },
        { columnKey: 'DeliveredBy', tenHienThi: 'Nhân viên giao', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Nhân viên giao' }
      ],
      cotMoRong: []
    },

    // 7.14 --------------------------------------------------------------
    {
      tableKey: 'HoaDon',
      tenVatLy: 'HoaDon',
      tenHienThi: 'HÓA ĐƠN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Mã khuyến mãi', kieu: 'INT', fk: true, nullable: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'ParentHoaDonID', tenHienThi: 'Hóa đơn cha', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID', ghiChuNgan: 'tự tham chiếu' },
        { columnKey: 'TongTienSan', tenHienThi: 'Tiền sân', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TongTienDichVu', tenHienThi: 'Tiền dịch vụ', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'GiamGia', tenHienThi: 'Giảm giá', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TongThanhToan', tenHienThi: 'Tổng thanh toán', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'PhuongThucThanhToan', tenHienThi: 'Phương thức', kieu: 'NVARCHAR(50)' },
        { columnKey: 'TrangThaiThanhToan', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.15 --------------------------------------------------------------
    {
      tableKey: 'ChiTietHoaDon',
      tenVatLy: 'ChiTietHoaDon',
      tenHienThi: 'CHI TIẾT HÓA ĐƠN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'ChiTietID', tenHienThi: 'Mã chi tiết', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'SanPhamID', tenHienThi: 'Mã sản phẩm', kieu: 'INT', fk: true, thamChieu: 'SanPham_DichVu.SanPhamID' },
        { columnKey: 'SoLuong', tenHienThi: 'Số lượng', kieu: 'INT' },
        { columnKey: 'DonGiaTaiThoiDiemBan', tenHienThi: 'Đơn giá bán', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'ThanhTien', tenHienThi: 'Thành tiền', kieu: 'DECIMAL(18,2)' }
      ],
      cotMoRong: []
    },

    // 7.16 --------------------------------------------------------------
    {
      tableKey: 'CourtChargeSegment',
      tenVatLy: 'CourtChargeSegment',
      tenHienThi: 'PHÂN ĐOẠN TÍNH GIÁ',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'SegmentID', tenHienThi: 'Mã phân đoạn', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'StartAt', tenHienThi: 'Bắt đầu', kieu: 'DATETIME2' },
        { columnKey: 'EndAt', tenHienThi: 'Kết thúc', kieu: 'DATETIME2' },
        { columnKey: 'RateType', tenHienThi: 'Loại giá', kieu: 'NVARCHAR(30)', ghiChuNgan: 'có đèn/không đèn' },
        { columnKey: 'HourlyRate', tenHienThi: 'Đơn giá giờ', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Amount', tenHienThi: 'Thành tiền', kieu: 'DECIMAL(18,2)' }
      ],
      cotMoRong: []
    },

    // 7.17 --------------------------------------------------------------
    {
      tableKey: 'PayOSPaymentAttempt',
      tenVatLy: 'PayOSPaymentAttempt',
      tenHienThi: 'GIAO DỊCH PAYOS',
      ghiChu: 'QrCode là payload/nội dung QR thanh toán trả về từ PayOS, không phải file ảnh, không liên kết SanQR.',
      cotChinh: [
        { columnKey: 'AttemptID', tenHienThi: 'Mã giao dịch', kieu: 'BIGINT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'OrderCode', tenHienThi: 'Mã đơn PayOS', kieu: 'BIGINT', unique: true },
        { columnKey: 'QrCode', tenHienThi: 'Payload QR', kieu: 'NVARCHAR(MAX)', nullable: true },
        { columnKey: 'Amount', tenHienThi: 'Số tiền', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Status', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(30)' },
        { columnKey: 'PaidAt', tenHienThi: 'Thanh toán lúc', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.18 --------------------------------------------------------------
    {
      tableKey: 'KhuyenMai',
      tenVatLy: 'KhuyenMai',
      tenHienThi: 'KHUYẾN MÃI',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Mã khuyến mãi', kieu: 'INT', pk: true },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, nullable: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'MaCode', tenHienThi: 'Mã code', kieu: 'VARCHAR(50)', unique: true },
        { columnKey: 'LoaiGiam', tenHienThi: 'Loại giảm', kieu: 'NVARCHAR(50)' },
        { columnKey: 'GiaTriGiam', tenHienThi: 'Giá trị giảm', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'NgayBatDau', tenHienThi: 'Ngày bắt đầu', kieu: 'DATE' },
        { columnKey: 'NgayKetThuc', tenHienThi: 'Ngày kết thúc', kieu: 'DATE' },
        { columnKey: 'GiaTriToiThieu', tenHienThi: 'Giá trị tối thiểu', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'GiamToiDa', tenHienThi: 'Giảm tối đa', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'HienThiCongKhai', tenHienThi: 'Hiển thị công khai', kieu: 'BIT' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.19 --------------------------------------------------------------
    {
      tableKey: 'KhuyenMaiHinhAnh',
      tenVatLy: 'KhuyenMaiHinhAnh',
      tenHienThi: 'HÌNH ẢNH KHUYẾN MÃI',
      ghiChu: 'Tối đa 5 ảnh/khuyến mãi, đúng tối đa 1 ảnh bìa/khuyến mãi.',
      cotChinh: [
        { columnKey: 'HinhAnhID', tenHienThi: 'Mã hình ảnh', kieu: 'INT', pk: true },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Mã khuyến mãi', kieu: 'INT', fk: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'DuongDan', tenHienThi: 'Đường dẫn', kieu: 'NVARCHAR(500)' },
        { columnKey: 'ThuTu', tenHienThi: 'Thứ tự', kieu: 'INT' },
        { columnKey: 'LaAnhBia', tenHienThi: 'Là ảnh bìa', kieu: 'BIT', ghiChuNgan: 'tối đa một ảnh bìa/khuyến mãi' }
      ],
      cotMoRong: [
        { columnKey: 'OriginalFileName', tenHienThi: 'Tên file gốc', kieu: 'NVARCHAR(255)', nullable: true },
        { columnKey: 'MimeType', tenHienThi: 'MIME type', kieu: 'NVARCHAR(100)', nullable: true },
        { columnKey: 'FileSize', tenHienThi: 'Dung lượng', kieu: 'BIGINT', nullable: true },
        { columnKey: 'Width', tenHienThi: 'Chiều rộng', kieu: 'INT', nullable: true },
        { columnKey: 'Height', tenHienThi: 'Chiều cao', kieu: 'INT', nullable: true }
      ]
    },

    // 7.20 --------------------------------------------------------------
    {
      tableKey: 'LichSuKhuyenMai',
      tenVatLy: 'LichSuKhuyenMai',
      tenHienThi: 'LỊCH SỬ DÙNG KHUYẾN MÃI',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'LichSuKhuyenMaiID', tenHienThi: 'Mã lịch sử', kieu: 'INT', pk: true },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Mã khuyến mãi', kieu: 'INT', fk: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'ThoiGianSuDung', tenHienThi: 'Thời gian sử dụng', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.21 --------------------------------------------------------------
    {
      tableKey: 'HoanTien',
      tenVatLy: 'HoanTien',
      tenHienThi: 'HOÀN TIỀN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'HoanTienID', tenHienThi: 'Mã hoàn tiền', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'AccountID', tenHienThi: 'Mã khách hàng', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Khách hàng' },
        { columnKey: 'SoTienDeNghiHoan', tenHienThi: 'Số tiền đề nghị', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'SoTienDuocDuyet', tenHienThi: 'Số tiền được duyệt', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'QrNhanTienPath', tenHienThi: 'Ảnh QR nhận tiền', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'đường dẫn ảnh QR ngân hàng do khách tải lên' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' },
        { columnKey: 'NguoiDuyetID', tenHienThi: 'Người duyệt', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người duyệt' }
      ],
      cotMoRong: []
    },

    // 7.22 --------------------------------------------------------------
    {
      tableKey: 'SanQR',
      tenVatLy: 'SanQR',
      tenHienThi: 'MÃ QR SÂN',
      ghiChu: 'Ảnh QR được sinh động từ Token/ShortCode, không lưu file ảnh QR trong bảng.',
      cotChinh: [
        { columnKey: 'SanQRID', tenHienThi: 'Mã QR', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'San.SanID' },
        { columnKey: 'Token', tenHienThi: 'Token bảo mật', kieu: 'UNIQUEIDENTIFIER', unique: true },
        { columnKey: 'ShortCode', tenHienThi: 'Mã nhập tay', kieu: 'NVARCHAR(12)', unique: true },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(20)' }
      ],
      cotMoRong: []
    },

    // 7.23 --------------------------------------------------------------
    {
      tableKey: 'SanQRTokenHistory',
      tenVatLy: 'SanQRTokenHistory',
      tenHienThi: 'LỊCH SỬ MÃ QR',
      ghiChu: 'Không hiển thị token plaintext cũ.',
      cotChinh: [
        { columnKey: 'HistoryID', tenHienThi: 'Mã lịch sử', kieu: 'INT', pk: true },
        { columnKey: 'SanQRID', tenHienThi: 'Mã QR', kieu: 'INT', fk: true, thamChieu: 'SanQR.SanQRID' },
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'TokenHash', tenHienThi: 'Hash token', kieu: 'NVARCHAR(64)', unique: true },
        { columnKey: 'ShortCode', tenHienThi: 'Mã nhập tay cũ', kieu: 'NVARCHAR(12)', nullable: true },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(20)' },
        { columnKey: 'RevokedAt', tenHienThi: 'Thu hồi lúc', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.24 --------------------------------------------------------------
    {
      tableKey: 'QRRequest',
      tenVatLy: 'QRRequest',
      tenHienThi: 'YÊU CẦU QR SÂN',
      ghiChu: 'Yêu cầu gọi nhân viên hoặc đặt món/dịch vụ được gửi sau khi khách quét QR.',
      cotChinh: [
        { columnKey: 'RequestID', tenHienThi: 'Mã yêu cầu', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'CustomerID', tenHienThi: 'Mã khách hàng', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Khách hàng' },
        { columnKey: 'RequestType', tenHienThi: 'Loại yêu cầu', kieu: 'VARCHAR(20)', ghiChuNgan: 'gọi nhân viên/đặt món/dịch vụ' },
        { columnKey: 'ItemsJson', tenHienThi: 'Danh sách món', kieu: 'NVARCHAR(MAX)', nullable: true, ghiChuNgan: 'JSON' },
        { columnKey: 'Note', tenHienThi: 'Ghi chú', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'Status', tenHienThi: 'Trạng thái', kieu: 'VARCHAR(20)' },
        { columnKey: 'HandledByStaffID', tenHienThi: 'Nhân viên xử lý', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Nhân viên xử lý' }
      ],
      cotMoRong: []
    },

    // 7.25 --------------------------------------------------------------
    {
      tableKey: 'CaLamViec',
      tenVatLy: 'CaLamViec',
      tenHienThi: 'CA LÀM VIỆC',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'CaLamViecID', tenHienThi: 'Mã ca làm', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Mã nhân viên', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'NgayLam', tenHienThi: 'Ngày làm', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Giờ bắt đầu', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'Giờ kết thúc', kieu: 'TIME' }
      ],
      cotMoRong: []
    },

    // 7.26 --------------------------------------------------------------
    {
      tableKey: 'YeuCauNghi',
      tenVatLy: 'YeuCauNghi',
      tenHienThi: 'YÊU CẦU NGHỈ',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'YeuCauNghiID', tenHienThi: 'Mã yêu cầu nghỉ', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Mã nhân viên', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'NgayNghi', tenHienThi: 'Ngày nghỉ', kieu: 'DATE' },
        { columnKey: 'LoaiNghi', tenHienThi: 'Loại nghỉ', kieu: 'NVARCHAR(50)' },
        { columnKey: 'LyDo', tenHienThi: 'Lý do', kieu: 'NVARCHAR(MAX)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' },
        { columnKey: 'XuLyBy', tenHienThi: 'Người xử lý', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người xử lý' }
      ],
      cotMoRong: []
    },

    // 7.27 --------------------------------------------------------------
    {
      tableKey: 'DanhGia',
      tenVatLy: 'DanhGia',
      tenHienThi: 'ĐÁNH GIÁ',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'DanhGiaID', tenHienThi: 'Mã đánh giá', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'AccountID_NguoiDanhGia', tenHienThi: 'Người đánh giá', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người đánh giá' },
        { columnKey: 'AccountID_NguoiBiDanhGia', tenHienThi: 'Người được đánh giá', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người được đánh giá' },
        { columnKey: 'SoSao', tenHienThi: 'Số sao', kieu: 'INT', ghiChuNgan: '1–5' },
        { columnKey: 'BinhLuan', tenHienThi: 'Bình luận', kieu: 'NVARCHAR(MAX)', nullable: true },
        { columnKey: 'NgayDanhGia', tenHienThi: 'Ngày đánh giá', kieu: 'DATETIME' }
      ],
      cotMoRong: []
    },

    // 7.28 --------------------------------------------------------------
    {
      tableKey: 'CustomerReputationHistory',
      tenVatLy: 'CustomerReputationHistory',
      tenHienThi: 'LỊCH SỬ ĐIỂM UY TÍN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'ReputationHistoryID', tenHienThi: 'Mã lịch sử', kieu: 'BIGINT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'ActionType', tenHienThi: 'Loại thay đổi', kieu: 'NVARCHAR(30)' },
        { columnKey: 'ScoreDelta', tenHienThi: 'Điểm thay đổi', kieu: 'INT' },
        { columnKey: 'ScoreBefore', tenHienThi: 'Điểm trước', kieu: 'INT' },
        { columnKey: 'ScoreAfter', tenHienThi: 'Điểm sau', kieu: 'INT' },
        { columnKey: 'Reason', tenHienThi: 'Lý do', kieu: 'NVARCHAR(500)' }
      ],
      cotMoRong: []
    },

    // 7.29 --------------------------------------------------------------
    {
      tableKey: 'GhepKeo',
      tenVatLy: 'GhepKeo',
      tenHienThi: 'GHÉP KÈO',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'KeoID', tenHienThi: 'Mã kèo', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'AccountID_NguoiTao', tenHienThi: 'Người tạo', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người tạo' },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Mã môn thể thao', kieu: 'INT', fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'TrinhDo', tenHienThi: 'Trình độ', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'SoNguoiCanTim', tenHienThi: 'Số người cần tìm', kieu: 'INT' },
        { columnKey: 'HinhThucDuyet', tenHienThi: 'Hình thức duyệt', kieu: 'NVARCHAR(20)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.30 --------------------------------------------------------------
    {
      tableKey: 'ChiTietGhepKeo',
      tenVatLy: 'ChiTietGhepKeo',
      tenHienThi: 'CHI TIẾT GHÉP KÈO',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'ChiTietKeoID', tenHienThi: 'Mã tham gia', kieu: 'INT', pk: true },
        { columnKey: 'KeoID', tenHienThi: 'Mã kèo', kieu: 'INT', fk: true, thamChieu: 'GhepKeo.KeoID' },
        { columnKey: 'AccountID_NguoiThamGia', tenHienThi: 'Người tham gia', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người tham gia' },
        { columnKey: 'TrangThaiThamGia', tenHienThi: 'Trạng thái tham gia', kieu: 'NVARCHAR(50)' },
        { columnKey: 'ViTriThamGia', tenHienThi: 'Vị trí tham gia', kieu: 'NVARCHAR(100)', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.31 --------------------------------------------------------------
    {
      tableKey: 'NhomChiaTien',
      tenVatLy: 'NhomChiaTien',
      tenHienThi: 'NHÓM CHIA TIỀN',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'NhomChiaTienID', tenHienThi: 'Mã nhóm chia', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CreatedByAccountID', tenHienThi: 'Người tạo', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Người tạo' },
        { columnKey: 'SplitType', tenHienThi: 'Hình thức chia', kieu: 'NVARCHAR(20)' },
        { columnKey: 'TongTien', tenHienThi: 'Tổng tiền', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(20)' },
        { columnKey: 'ExpiresAt', tenHienThi: 'Hết hạn lúc', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.32 --------------------------------------------------------------
    {
      tableKey: 'NhomChiaTienChiTiet',
      tenVatLy: 'NhomChiaTienChiTiet',
      tenHienThi: 'CHI TIẾT CHIA TIỀN',
      ghiChu: 'QR sinh từ ShareToken, không dùng bảng MaQR cũ.',
      cotChinh: [
        { columnKey: 'ChiTietID', tenHienThi: 'Mã phần tiền', kieu: 'INT', pk: true },
        { columnKey: 'NhomChiaTienID', tenHienThi: 'Mã nhóm chia', kieu: 'INT', fk: true, thamChieu: 'NhomChiaTien.NhomChiaTienID' },
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'DisplayName', tenHienThi: 'Tên người trả', kieu: 'NVARCHAR(100)' },
        { columnKey: 'ShareToken', tenHienThi: 'Token chia sẻ', kieu: 'CHAR(43)', unique: true },
        { columnKey: 'SoTien', tenHienThi: 'Số tiền', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Trạng thái', kieu: 'NVARCHAR(50)' },
        { columnKey: 'PaidAt', tenHienThi: 'Thanh toán lúc', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.33 --------------------------------------------------------------
    {
      tableKey: 'ThongBao',
      tenVatLy: 'ThongBao',
      tenHienThi: 'THÔNG BÁO',
      ghiChu: '',
      cotChinh: [
        { columnKey: 'ThongBaoID', tenHienThi: 'Mã thông báo', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'TieuDe', tenHienThi: 'Tiêu đề', kieu: 'NVARCHAR(200)' },
        { columnKey: 'NoiDung', tenHienThi: 'Nội dung', kieu: 'NVARCHAR(MAX)' },
        { columnKey: 'LoaiThongBao', tenHienThi: 'Loại thông báo', kieu: 'NVARCHAR(50)' },
        { columnKey: 'DaDoc', tenHienThi: 'Đã đọc', kieu: 'BIT' },
        { columnKey: 'ThoiGianGui', tenHienThi: 'Thời gian gửi', kieu: 'DATETIME' },
        { columnKey: 'DuongDan', tenHienThi: 'Đường dẫn', kieu: 'NVARCHAR(500)', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.34 --------------------------------------------------------------
    {
      tableKey: 'AuditLog',
      tenVatLy: 'AuditLog',
      tenHienThi: 'NHẬT KÝ HỆ THỐNG',
      ghiChu: 'ActorAccountID/CoSoID là khóa ngoại LOGIC — không vẽ đường nối thật tới hàng loạt bảng.',
      cotChinh: [
        { columnKey: 'AuditLogID', tenHienThi: 'Mã nhật ký', kieu: 'BIGINT', pk: true },
        { columnKey: 'ActorAccountID', tenHienThi: 'Người thực hiện', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'FK logic → Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Mã cơ sở', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'FK logic → CoSo.CoSoID' },
        { columnKey: 'Action', tenHienThi: 'Hành động', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityType', tenHienThi: 'Loại đối tượng', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityID', tenHienThi: 'Mã đối tượng', kieu: 'NVARCHAR(50)' },
        { columnKey: 'IpAddress', tenHienThi: 'Địa chỉ IP', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CreatedAt', tenHienThi: 'Thời gian', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.35 --------------------------------------------------------------
    {
      tableKey: 'AdminTrash',
      tenVatLy: 'AdminTrash',
      tenHienThi: 'THÙNG RÁC',
      ghiChu: 'DeletedBy/RestoredBy là khóa ngoại LOGIC — không vẽ đường nối thật tới các bảng nghiệp vụ.',
      cotChinh: [
        { columnKey: 'TrashID', tenHienThi: 'Mã bản ghi xóa', kieu: 'INT', pk: true },
        { columnKey: 'EntityType', tenHienThi: 'Loại đối tượng', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityID', tenHienThi: 'Mã đối tượng', kieu: 'INT', ghiChuNgan: 'tham chiếu logic' },
        { columnKey: 'DisplayName', tenHienThi: 'Tên hiển thị', kieu: 'NVARCHAR(255)', nullable: true },
        { columnKey: 'DeletedBy', tenHienThi: 'Người xóa', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'FK logic → Accounts.AccountID' },
        { columnKey: 'DeletedAt', tenHienThi: 'Thời gian xóa', kieu: 'DATETIME2' },
        { columnKey: 'IsRestored', tenHienThi: 'Đã khôi phục', kieu: 'BIT' },
        { columnKey: 'RestoredBy', tenHienThi: 'Người khôi phục', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'FK logic → Accounts.AccountID' }
      ],
      cotMoRong: []
    }
  ];

  // -----------------------------------------------------------------
  // 21 nhóm màn hình. Mỗi nhóm tối đa 3 bảng (trừ "Cơ sở và định vị").
  // layout: vị trí mặc định {x,y} góc trên-trái của từng card trong nhóm.
  // -----------------------------------------------------------------
  var CANVAS = { w: 1600, h: 900 };
  var CANVAS_TALL = { w: 1600, h: 1000 };

  function layout2(a, b) {
    var l = {};
    l[a] = { x: 200, y: 100 };
    l[b] = { x: 940, y: 100 };
    return l;
  }

  function layout3(a, b, c) {
    var l = {};
    l[a] = { x: 60, y: 120 };
    l[b] = { x: 620, y: 120 };
    l[c] = { x: 1180, y: 120 };
    return l;
  }

  var ERD_VIEWS = [
    {
      id: 'phan-quyen-va-ho-so',
      code: '01',
      title: 'Phân quyền và hồ sơ',
      entities: ['Roles', 'Accounts', 'MonTheThaoYeuThich'],
      canvas: CANVAS_TALL,
      layout: layout3('Roles', 'Accounts', 'MonTheThaoYeuThich')
    },
    {
      id: 'co-so-va-dinh-vi',
      code: '02',
      title: 'Cơ sở và định vị',
      entities: ['Accounts', 'CoSo'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'CoSo')
    },
    {
      id: 'mon-the-thao-va-san',
      code: '03',
      title: 'Môn thể thao và sân',
      entities: ['MonTheThao', 'LoaiSan', 'San'],
      canvas: CANVAS,
      layout: layout3('MonTheThao', 'LoaiSan', 'San')
    },
    {
      id: 'dat-san',
      code: '04',
      title: 'Đặt sân',
      entities: ['Accounts', 'San', 'LichDatSan'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'San', 'LichDatSan')
    },
    {
      id: 'giu-cho-tam',
      code: '05',
      title: 'Giữ chỗ tạm',
      entities: ['Accounts', 'San', 'SoftHold'],
      canvas: CANVAS,
      layout: layout3('Accounts', 'San', 'SoftHold')
    },
    {
      id: 'gia-han-ca-choi',
      code: '06',
      title: 'Gia hạn ca chơi',
      entities: ['LichDatSan', 'BookingExtension', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'BookingExtension', 'Accounts')
    },
    {
      id: 'kho-san-pham-dich-vu',
      code: '07',
      title: 'Kho sản phẩm dịch vụ',
      entities: ['CoSo', 'DanhMucSanPham', 'SanPham_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'DanhMucSanPham', 'SanPham_DichVu')
    },
    {
      id: 'dich-vu-dat-kem',
      code: '08',
      title: 'Dịch vụ đặt kèm',
      entities: ['LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu')
    },
    {
      id: 'hoa-don',
      code: '09',
      title: 'Hóa đơn',
      entities: ['LichDatSan', 'HoaDon', 'ChiTietHoaDon'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'HoaDon', 'ChiTietHoaDon')
    },
    {
      id: 'tinh-gia-san',
      code: '10',
      title: 'Tính giá sân',
      entities: ['HoaDon', 'LichDatSan', 'CourtChargeSegment'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'LichDatSan', 'CourtChargeSegment')
    },
    {
      id: 'thanh-toan-payos',
      code: '11',
      title: 'Thanh toán PayOS',
      entities: ['CoSo', 'HoaDon', 'PayOSPaymentAttempt'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'HoaDon', 'PayOSPaymentAttempt')
    },
    {
      id: 'khuyen-mai-va-hinh-anh',
      code: '12',
      title: 'Khuyến mãi và hình ảnh',
      entities: ['KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai'],
      canvas: CANVAS_TALL,
      layout: layout3('KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai')
    },
    {
      id: 'hoan-tien-va-qr-nhan-tien',
      code: '13',
      title: 'Hoàn tiền và QR nhận tiền',
      entities: ['HoaDon', 'HoanTien', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'HoanTien', 'Accounts')
    },
    {
      id: 'ma-qr-bao-mat-cua-san',
      code: '14',
      title: 'Mã QR bảo mật của sân',
      entities: ['San', 'SanQR', 'SanQRTokenHistory'],
      canvas: CANVAS,
      layout: layout3('San', 'SanQR', 'SanQRTokenHistory')
    },
    {
      id: 'yeu-cau-sau-khi-quet-qr',
      code: '15',
      title: 'Yêu cầu sau khi quét QR',
      entities: ['San', 'QRRequest', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('San', 'QRRequest', 'Accounts')
    },
    {
      id: 'ca-lam-va-nghi-phep',
      code: '16',
      title: 'Ca làm và nghỉ phép',
      entities: ['Accounts', 'CaLamViec', 'YeuCauNghi'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'CaLamViec', 'YeuCauNghi')
    },
    {
      id: 'danh-gia-va-diem-uy-tin',
      code: '17',
      title: 'Đánh giá và điểm uy tín',
      entities: ['LichDatSan', 'DanhGia', 'CustomerReputationHistory'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'DanhGia', 'CustomerReputationHistory')
    },
    {
      id: 'ghep-keo',
      code: '18',
      title: 'Ghép kèo',
      entities: ['Accounts', 'GhepKeo', 'ChiTietGhepKeo'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'GhepKeo', 'ChiTietGhepKeo')
    },
    {
      id: 'chia-tien-hoa-don',
      code: '19',
      title: 'Chia tiền hóa đơn',
      entities: ['HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet')
    },
    {
      id: 'thong-bao',
      code: '20',
      title: 'Thông báo',
      entities: ['Accounts', 'ThongBao'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'ThongBao')
    },
    {
      id: 'kiem-toan-va-khoi-phuc',
      code: '21',
      title: 'Kiểm toán và khôi phục',
      entities: ['Accounts', 'AuditLog', 'AdminTrash'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'AuditLog', 'AdminTrash')
    }
  ];

  global.ERD_ENTITIES = ERD_ENTITIES;
  global.ERD_VIEWS = ERD_VIEWS;
})(window);
