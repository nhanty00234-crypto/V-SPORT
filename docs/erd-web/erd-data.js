/* V-SPORT ERD — single source of truth (correct schema, complete).
 * 35 logical entities, 21 screen groups. All relationship lines are derived
 * from FK metadata (thamChieu) declared in each column — no manual edge list
 * exists anywhere in app.js.
 *
 * Each column:
 * {
 *   columnKey,     // physical column name
 *   tenHienThi,    // display name (English)
 *   kieu,          // SQL type
 *   pk, fk, unique, nullable,
 *   thamChieu,     // "TargetTableKey.TargetColumnKey" — only when fk === true
 *   ghiChuNgan,    // optional short note
 *   vaiTro,        // role label when multiple FKs point to same table
 *   fkLogic,       // true = LOGICAL FK (no connector drawn)
 * }
 *
 * Each entity:
 * { tableKey, tenVatLy, tenHienThi, ghiChu, cotChinh: [...], cotMoRong: [...] }
 */
(function (global) {
  'use strict';

  var ERD_ENTITIES = [
    // 7.1 ---------------------------------------------------------------
    {
      tableKey: 'Roles',
      tenVatLy: 'Roles',
      tenHienThi: 'ROLES',
      ghiChu: 'Mục đích: Định nghĩa các vai trò hệ thống được gán cho tài khoản người dùng.',
      cotChinh: [
        { columnKey: 'RoleID', tenHienThi: 'Role ID', kieu: 'INT', pk: true },
        { columnKey: 'RoleName', tenHienThi: 'Role Name', kieu: 'NVARCHAR(50)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.2 ---------------------------------------------------------------
    {
      tableKey: 'Accounts',
      tenVatLy: 'Accounts',
      tenHienThi: 'ACCOUNTS',
      ghiChu: 'Mục đích: Lưu thông tin đăng nhập, hồ sơ, cơ sở được phân công và điểm uy tín của người dùng.',
      cotChinh: [
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', pk: true },
        { columnKey: 'RoleID', tenHienThi: 'Role ID', kieu: 'INT', fk: true, thamChieu: 'Roles.RoleID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'FullName', tenHienThi: 'Full Name', kieu: 'NVARCHAR(255)' },
        { columnKey: 'Email', tenHienThi: 'Email', kieu: 'VARCHAR(100)', unique: true },
        { columnKey: 'PhoneNumber', tenHienThi: 'Phone Number', kieu: 'NVARCHAR(20)', unique: true, nullable: true },
        { columnKey: 'Password', tenHienThi: 'Password Hash', kieu: 'VARCHAR(255)' },
        { columnKey: 'AvatarUrl', tenHienThi: 'Avatar URL', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'DiemUyTin', tenHienThi: 'Reputation Score', kieu: 'INT', ghiChuNgan: 'default 100' }
      ],
      cotMoRong: [
        { columnKey: 'CoverImageUrl', tenHienThi: 'Cover Image', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'DiemTrinhDo', tenHienThi: 'Skill Score', kieu: 'INT' },
        { columnKey: 'NgaySinh', tenHienThi: 'Date of Birth', kieu: 'DATE', nullable: true },
        { columnKey: 'GioiTinh', tenHienThi: 'Gender', kieu: 'NVARCHAR(10)', nullable: true }
      ]
    },

    // 7.3 ---------------------------------------------------------------
    {
      tableKey: 'MonTheThaoYeuThich',
      tenVatLy: 'MonTheThaoYeuThich',
      tenHienThi: 'FAVORITE SPORTS',
      ghiChu: 'Mục đích: Liên kết từng tài khoản khách hàng với các môn thể thao yêu thích của họ.',
      cotChinh: [
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', pk: true, fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Sport ID', kieu: 'INT', pk: true, fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'NgayThem', tenHienThi: 'Added At', kieu: 'DATETIME' }
      ],
      cotMoRong: []
    },

    // 7.4 ---------------------------------------------------------------
    {
      tableKey: 'CoSo',
      tenVatLy: 'CoSo',
      tenHienThi: 'FACILITIES',
      ghiChu: 'Mục đích: Lưu thông tin cơ sở, thư viện ảnh, giờ hoạt động và tọa độ bản đồ.',
      cotChinh: [
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', pk: true },
        { columnKey: 'AccountID_QuanLy', tenHienThi: 'Manager Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Facility Manager' },
        { columnKey: 'TenCoSo', tenHienThi: 'Facility Name', kieu: 'NVARCHAR(255)' },
        { columnKey: 'DiaChi', tenHienThi: 'Address', kieu: 'NVARCHAR(500)' },
        { columnKey: 'GioMoCua', tenHienThi: 'Opening Time', kieu: 'TIME' },
        { columnKey: 'GioDongCua', tenHienThi: 'Closing Time', kieu: 'TIME' },
        { columnKey: 'HinhAnh', tenHienThi: 'Image Gallery', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'JSON array of paths, max 10 images' },
        { columnKey: 'ViDo', tenHienThi: 'Latitude', kieu: 'DECIMAL(12,9)', nullable: true },
        { columnKey: 'KinhDo', tenHienThi: 'Longitude', kieu: 'DECIMAL(12,9)', nullable: true },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.5 ---------------------------------------------------------------
    {
      tableKey: 'MonTheThao',
      tenVatLy: 'MonTheThao',
      tenHienThi: 'SPORTS',
      ghiChu: 'Mục đích: Lưu danh sách các môn thể thao được hỗ trợ trong hệ thống đặt sân.',
      cotChinh: [
        { columnKey: 'MonTheThaoID', tenHienThi: 'Sport ID', kieu: 'INT', pk: true },
        { columnKey: 'TenMon', tenHienThi: 'Sport Name', kieu: 'NVARCHAR(50)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.6 ---------------------------------------------------------------
    {
      tableKey: 'LoaiSan',
      tenVatLy: 'LoaiSan',
      tenHienThi: 'COURT TYPES',
      ghiChu: 'Mục đích: Định nghĩa các loại sân, môn thể thao, khung giờ bật đèn và giá thuê theo giờ.',
      cotChinh: [
        { columnKey: 'LoaiSanID', tenHienThi: 'Court Type ID', kieu: 'INT', pk: true },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Sport ID', kieu: 'INT', fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'TenLoai', tenHienThi: 'Court Type Name', kieu: 'NVARCHAR(100)' },
        { columnKey: 'GiaKhongDen', tenHienThi: 'Unlit Hourly Rate', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'GiaCoDen', tenHienThi: 'Lit Hourly Rate', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'GioBatDauLenDen', tenHienThi: 'Lighting Start Time', kieu: 'TIME', nullable: true },
        { columnKey: 'GioKetThucLenDen', tenHienThi: 'Lighting End Time', kieu: 'TIME', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.7 ---------------------------------------------------------------
    {
      tableKey: 'San',
      tenVatLy: 'San',
      tenHienThi: 'COURTS',
      ghiChu: 'Mục đích: Lưu thông tin từng sân cụ thể có tại mỗi cơ sở.',
      cotChinh: [
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', pk: true },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'LoaiSanID', tenHienThi: 'Court Type ID', kieu: 'INT', fk: true, thamChieu: 'LoaiSan.LoaiSanID' },
        { columnKey: 'TenSan', tenHienThi: 'Court Name', kieu: 'NVARCHAR(100)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'HinhAnh', tenHienThi: 'Image URL', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'image path' }
      ],
      cotMoRong: []
    },

    // 7.8 ---------------------------------------------------------------
    {
      tableKey: 'SoftHold',
      tenVatLy: 'SoftHold',
      tenHienThi: 'SOFT HOLDS',
      ghiChu: 'Mục đích: Tạm giữ khung giờ sân trong khi khách hàng hoàn tất quy trình đặt sân.',
      cotChinh: [
        { columnKey: 'HoldID', tenHienThi: 'Hold ID', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'NgayDat', tenHienThi: 'Booking Date', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Start Time', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'End Time', kieu: 'TIME' },
        { columnKey: 'ExpiresAt', tenHienThi: 'Expires At', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.9 ---------------------------------------------------------------
    {
      tableKey: 'LichDatSan',
      tenVatLy: 'LichDatSan',
      tenHienThi: 'BOOKINGS',
      ghiChu: 'Mục đích: Lưu thông tin đặt sân và thời gian sử dụng dự kiến lẫn thực tế.',
      cotChinh: [
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Customer Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Customer' },
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'NgayDat', tenHienThi: 'Booking Date', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Start Time', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'End Time', kieu: 'TIME' },
        { columnKey: 'TongTienDuKien', tenHienThi: 'Estimated Total', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'ActualStartAt', tenHienThi: 'Actual Start At', kieu: 'DATETIME2', nullable: true },
        { columnKey: 'ActualEndAt', tenHienThi: 'Actual End At', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: [
        { columnKey: 'BookingSource', tenHienThi: 'Booking Source', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CancelType', tenHienThi: 'Cancellation Type', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CancelReason', tenHienThi: 'Cancellation Reason', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'ConfirmedBy', tenHienThi: 'Confirmed By Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Confirmed By' },
        { columnKey: 'CancelledBy', tenHienThi: 'Cancelled By Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Cancelled By' }
      ]
    },

    // 7.10 --------------------------------------------------------------
    {
      tableKey: 'BookingExtension',
      tenVatLy: 'BookingExtension',
      tenHienThi: 'BOOKING EXTENSIONS',
      ghiChu: 'Mục đích: Ghi nhận các yêu cầu gia hạn đặt sân được duyệt và phí phát sinh thêm.',
      cotChinh: [
        { columnKey: 'ExtensionID', tenHienThi: 'Extension ID', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'NewGioKetThucDateTime', tenHienThi: 'New End DateTime', kieu: 'DATETIME2' },
        { columnKey: 'AdditionalAmount', tenHienThi: 'Additional Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'OperatorAccountID', tenHienThi: 'Operator Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Operator' },
        { columnKey: 'CreatedAt', tenHienThi: 'Created At', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.11 --------------------------------------------------------------
    {
      tableKey: 'DanhMucSanPham',
      tenVatLy: 'DanhMucSanPham',
      tenHienThi: 'PRODUCT CATEGORIES',
      ghiChu: 'Mục đích: Phân nhóm các sản phẩm và dịch vụ được bán tại cơ sở.',
      cotChinh: [
        { columnKey: 'DanhMucID', tenHienThi: 'Category ID', kieu: 'INT', pk: true },
        { columnKey: 'TenDanhMuc', tenHienThi: 'Category Name', kieu: 'NVARCHAR(100)', unique: true }
      ],
      cotMoRong: []
    },

    // 7.12 --------------------------------------------------------------
    {
      tableKey: 'SanPham_DichVu',
      tenVatLy: 'SanPham_DichVu',
      tenHienThi: 'PRODUCTS & SERVICES',
      ghiChu: 'Mục đích: Lưu sản phẩm, dịch vụ, số lượng tồn kho, giá cả và hình ảnh của cơ sở.',
      cotChinh: [
        { columnKey: 'SanPhamID', tenHienThi: 'Product ID', kieu: 'INT', pk: true },
        { columnKey: 'DanhMucID', tenHienThi: 'Category ID', kieu: 'INT', fk: true, thamChieu: 'DanhMucSanPham.DanhMucID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'TenSanPham', tenHienThi: 'Product Name', kieu: 'NVARCHAR(200)' },
        { columnKey: 'DonGia', tenHienThi: 'Unit Price', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'SoLuongTon', tenHienThi: 'Stock Quantity', kieu: 'INT' },
        { columnKey: 'HinhAnh', tenHienThi: 'Image URL', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'image path' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.13 --------------------------------------------------------------
    {
      tableKey: 'LichDatSan_DichVu',
      tenVatLy: 'LichDatSan_DichVu',
      tenHienThi: 'BOOKING SERVICES',
      ghiChu: 'Mục đích: Ghi nhận các sản phẩm hoặc dịch vụ được thêm vào một lịch đặt sân.',
      cotChinh: [
        { columnKey: 'Id', tenHienThi: 'Detail ID', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'SanPhamID', tenHienThi: 'Product ID', kieu: 'INT', fk: true, thamChieu: 'SanPham_DichVu.SanPhamID' },
        { columnKey: 'Quantity', tenHienThi: 'Quantity', kieu: 'INT' },
        { columnKey: 'UnitPrice', tenHienThi: 'Unit Price', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TotalPrice', tenHienThi: 'Line Total', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Status', tenHienThi: 'Delivery Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'DeliveredBy', tenHienThi: 'Delivered By Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Handling Staff' }
      ],
      cotMoRong: []
    },

    // 7.14 --------------------------------------------------------------
    {
      tableKey: 'HoaDon',
      tenVatLy: 'HoaDon',
      tenHienThi: 'INVOICES',
      ghiChu: 'Mục đích: Lưu tóm tắt tài chính và trạng thái thanh toán của một lịch đặt sân.',
      cotChinh: [
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Promotion ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'ParentHoaDonID', tenHienThi: 'Parent Invoice ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID', ghiChuNgan: 'self-reference' },
        { columnKey: 'TongTienSan', tenHienThi: 'Court Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TongTienDichVu', tenHienThi: 'Service Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'GiamGia', tenHienThi: 'Discount Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TongThanhToan', tenHienThi: 'Total Payable', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'PhuongThucThanhToan', tenHienThi: 'Payment Method', kieu: 'NVARCHAR(50)' },
        { columnKey: 'TrangThaiThanhToan', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.15 --------------------------------------------------------------
    {
      tableKey: 'ChiTietHoaDon',
      tenVatLy: 'ChiTietHoaDon',
      tenHienThi: 'INVOICE ITEMS',
      ghiChu: 'Mục đích: Lưu từng dòng sản phẩm và dịch vụ có trong hóa đơn.',
      cotChinh: [
        { columnKey: 'ChiTietID', tenHienThi: 'Detail ID', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'SanPhamID', tenHienThi: 'Product ID', kieu: 'INT', fk: true, thamChieu: 'SanPham_DichVu.SanPhamID' },
        { columnKey: 'SoLuong', tenHienThi: 'Quantity', kieu: 'INT' },
        { columnKey: 'DonGiaTaiThoiDiemBan', tenHienThi: 'Sale Unit Price', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'ThanhTien', tenHienThi: 'Line Total', kieu: 'DECIMAL(18,2)' }
      ],
      cotMoRong: []
    },

    // 7.16 --------------------------------------------------------------
    {
      tableKey: 'CourtChargeSegment',
      tenVatLy: 'CourtChargeSegment',
      tenHienThi: 'COURT CHARGE SEGMENTS',
      ghiChu: 'Mục đích: Chia thời gian sử dụng sân thành các đoạn với giá thuê theo giờ khác nhau.',
      cotChinh: [
        { columnKey: 'SegmentID', tenHienThi: 'Segment ID', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'StartAt', tenHienThi: 'Start At', kieu: 'DATETIME2' },
        { columnKey: 'EndAt', tenHienThi: 'End At', kieu: 'DATETIME2' },
        { columnKey: 'RateType', tenHienThi: 'Rate Type', kieu: 'NVARCHAR(30)', ghiChuNgan: 'lit / unlit' },
        { columnKey: 'HourlyRate', tenHienThi: 'Hourly Rate', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Amount', tenHienThi: 'Line Total', kieu: 'DECIMAL(18,2)' }
      ],
      cotMoRong: []
    },

    // 7.17 --------------------------------------------------------------
    {
      tableKey: 'PayOSPaymentAttempt',
      tenVatLy: 'PayOSPaymentAttempt',
      tenHienThi: 'PAYOS PAYMENT ATTEMPTS',
      ghiChu: 'Mục đích: Theo dõi các lệnh thanh toán PayOS, dữ liệu mã QR, số tiền và kết quả giao dịch.',
      cotChinh: [
        { columnKey: 'AttemptID', tenHienThi: 'Payment Attempt ID', kieu: 'BIGINT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'OrderCode', tenHienThi: 'PayOS Order Code', kieu: 'BIGINT', unique: true },
        { columnKey: 'QrCode', tenHienThi: 'QR Payload', kieu: 'NVARCHAR(MAX)', nullable: true },
        { columnKey: 'Amount', tenHienThi: 'Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'Status', tenHienThi: 'Status', kieu: 'NVARCHAR(30)' },
        { columnKey: 'PaidAt', tenHienThi: 'Paid At', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.18 --------------------------------------------------------------
    {
      tableKey: 'KhuyenMai',
      tenVatLy: 'KhuyenMai',
      tenHienThi: 'PROMOTIONS',
      ghiChu: 'Mục đích: Lưu quy tắc khuyến mãi, thời hạn hiệu lực, giới hạn sử dụng và phạm vi cơ sở.',
      cotChinh: [
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Promotion ID', kieu: 'INT', pk: true },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'MaCode', tenHienThi: 'Promotion Code', kieu: 'VARCHAR(50)', unique: true },
        { columnKey: 'LoaiGiam', tenHienThi: 'Discount Type', kieu: 'NVARCHAR(50)' },
        { columnKey: 'GiaTriGiam', tenHienThi: 'Discount Value', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'NgayBatDau', tenHienThi: 'Start Date', kieu: 'DATE' },
        { columnKey: 'NgayKetThuc', tenHienThi: 'End Date', kieu: 'DATE' },
        { columnKey: 'GiaTriToiThieu', tenHienThi: 'Minimum Order Value', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'GiamToiDa', tenHienThi: 'Maximum Discount', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'HienThiCongKhai', tenHienThi: 'Publicly Visible', kieu: 'BIT' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.19 --------------------------------------------------------------
    {
      tableKey: 'KhuyenMaiHinhAnh',
      tenVatLy: 'KhuyenMaiHinhAnh',
      tenHienThi: 'PROMOTION IMAGES',
      ghiChu: 'Mục đích: Lưu thư viện ảnh theo thứ tự và ảnh bìa của một chương trình khuyến mãi.',
      cotChinh: [
        { columnKey: 'HinhAnhID', tenHienThi: 'Image ID', kieu: 'INT', pk: true },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Promotion ID', kieu: 'INT', fk: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'DuongDan', tenHienThi: 'File Path', kieu: 'NVARCHAR(500)' },
        { columnKey: 'ThuTu', tenHienThi: 'Display Order', kieu: 'INT' },
        { columnKey: 'LaAnhBia', tenHienThi: 'Is Cover Image', kieu: 'BIT', ghiChuNgan: 'max one cover per promotion' }
      ],
      cotMoRong: [
        { columnKey: 'OriginalFileName', tenHienThi: 'Original File Name', kieu: 'NVARCHAR(255)', nullable: true },
        { columnKey: 'MimeType', tenHienThi: 'MIME Type', kieu: 'NVARCHAR(100)', nullable: true },
        { columnKey: 'FileSize', tenHienThi: 'File Size', kieu: 'BIGINT', nullable: true },
        { columnKey: 'Width', tenHienThi: 'Width', kieu: 'INT', nullable: true },
        { columnKey: 'Height', tenHienThi: 'Height', kieu: 'INT', nullable: true }
      ]
    },

    // 7.20 --------------------------------------------------------------
    {
      tableKey: 'LichSuKhuyenMai',
      tenVatLy: 'LichSuKhuyenMai',
      tenHienThi: 'PROMOTION USAGE HISTORY',
      ghiChu: 'Mục đích: Ghi nhận thời điểm tài khoản sử dụng khuyến mãi cho một hóa đơn.',
      cotChinh: [
        { columnKey: 'LichSuKhuyenMaiID', tenHienThi: 'History ID', kieu: 'INT', pk: true },
        { columnKey: 'KhuyenMaiID', tenHienThi: 'Promotion ID', kieu: 'INT', fk: true, thamChieu: 'KhuyenMai.KhuyenMaiID' },
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'ThoiGianSuDung', tenHienThi: 'Used At', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.21 --------------------------------------------------------------
    {
      tableKey: 'HoanTien',
      tenVatLy: 'HoanTien',
      tenHienThi: 'REFUNDS',
      ghiChu: 'Mục đích: Lưu yêu cầu hoàn tiền, kết quả phê duyệt và ảnh mã QR nhận tiền của khách hàng.',
      cotChinh: [
        { columnKey: 'HoanTienID', tenHienThi: 'Refund ID', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'AccountID', tenHienThi: 'Customer Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Customer' },
        { columnKey: 'SoTienDeNghiHoan', tenHienThi: 'Requested Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'SoTienDuocDuyet', tenHienThi: 'Approved Amount', kieu: 'DECIMAL(18,2)', nullable: true },
        { columnKey: 'QrNhanTienPath', tenHienThi: 'Receiving QR Image', kieu: 'NVARCHAR(500)', nullable: true, ghiChuNgan: 'bank QR image path uploaded by customer' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'NguoiDuyetID', tenHienThi: 'Approver Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Approver' }
      ],
      cotMoRong: []
    },

    // 7.22 --------------------------------------------------------------
    {
      tableKey: 'SanQR',
      tenVatLy: 'SanQR',
      tenHienThi: 'COURT QR CODES',
      ghiChu: 'Mục đích: Lưu token QR bảo mật đang hoạt động, gán một-một với từng sân.',
      cotChinh: [
        { columnKey: 'SanQRID', tenHienThi: 'QR ID', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', fk: true, unique: true, thamChieu: 'San.SanID' },
        { columnKey: 'Token', tenHienThi: 'Secure Token', kieu: 'UNIQUEIDENTIFIER', unique: true },
        { columnKey: 'ShortCode', tenHienThi: 'Manual Code', kieu: 'NVARCHAR(12)', unique: true },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(20)' }
      ],
      cotMoRong: []
    },

    // 7.23 --------------------------------------------------------------
    {
      tableKey: 'SanQRTokenHistory',
      tenVatLy: 'SanQRTokenHistory',
      tenHienThi: 'COURT QR TOKEN HISTORY',
      ghiChu: 'Mục đích: Lưu lịch sử các mã hash token QR đã bị thu hồi để kiểm tra bảo mật.',
      cotChinh: [
        { columnKey: 'HistoryID', tenHienThi: 'History ID', kieu: 'INT', pk: true },
        { columnKey: 'SanQRID', tenHienThi: 'QR ID', kieu: 'INT', fk: true, thamChieu: 'SanQR.SanQRID' },
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'TokenHash', tenHienThi: 'Token Hash', kieu: 'NVARCHAR(64)', unique: true },
        { columnKey: 'ShortCode', tenHienThi: 'Previous Manual Code', kieu: 'NVARCHAR(12)', nullable: true },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(20)' },
        { columnKey: 'RevokedAt', tenHienThi: 'Revoked At', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.24 --------------------------------------------------------------
    {
      tableKey: 'QRRequest',
      tenVatLy: 'QRRequest',
      tenHienThi: 'COURT QR REQUESTS',
      ghiChu: 'Mục đích: Lưu các yêu cầu gọi nhân viên, đặt sản phẩm hoặc dịch vụ được gửi sau khi quét mã QR sân.',
      cotChinh: [
        { columnKey: 'RequestID', tenHienThi: 'Request ID', kieu: 'INT', pk: true },
        { columnKey: 'SanID', tenHienThi: 'Court ID', kieu: 'INT', fk: true, thamChieu: 'San.SanID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'CustomerID', tenHienThi: 'Customer Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Customer' },
        { columnKey: 'RequestType', tenHienThi: 'Request Type', kieu: 'VARCHAR(20)', ghiChuNgan: 'call staff / order / service' },
        { columnKey: 'ItemsJson', tenHienThi: 'Requested Items', kieu: 'NVARCHAR(MAX)', nullable: true, ghiChuNgan: 'JSON' },
        { columnKey: 'Note', tenHienThi: 'Note', kieu: 'NVARCHAR(500)', nullable: true },
        { columnKey: 'Status', tenHienThi: 'Status', kieu: 'VARCHAR(20)' },
        { columnKey: 'HandledByStaffID', tenHienThi: 'Handling Staff Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Handling Staff' }
      ],
      cotMoRong: []
    },

    // 7.25 --------------------------------------------------------------
    {
      tableKey: 'CaLamViec',
      tenVatLy: 'CaLamViec',
      tenHienThi: 'WORK SHIFTS',
      ghiChu: 'Mục đích: Phân công nhân viên vào các ca làm việc theo lịch tại cơ sở.',
      cotChinh: [
        { columnKey: 'CaLamViecID', tenHienThi: 'Shift ID', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Staff Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'NgayLam', tenHienThi: 'Work Date', kieu: 'DATE' },
        { columnKey: 'GioBatDau', tenHienThi: 'Start Time', kieu: 'TIME' },
        { columnKey: 'GioKetThuc', tenHienThi: 'End Time', kieu: 'TIME' }
      ],
      cotMoRong: []
    },

    // 7.26 --------------------------------------------------------------
    {
      tableKey: 'YeuCauNghi',
      tenVatLy: 'YeuCauNghi',
      tenHienThi: 'LEAVE REQUESTS',
      ghiChu: 'Mục đích: Lưu các yêu cầu nghỉ phép của nhân viên và kết quả xử lý của quản lý.',
      cotChinh: [
        { columnKey: 'YeuCauNghiID', tenHienThi: 'Leave Request ID', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Staff Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: true, thamChieu: 'CoSo.CoSoID' },
        { columnKey: 'NgayNghi', tenHienThi: 'Leave Date', kieu: 'DATE' },
        { columnKey: 'LoaiNghi', tenHienThi: 'Leave Type', kieu: 'NVARCHAR(50)' },
        { columnKey: 'LyDo', tenHienThi: 'Reason', kieu: 'NVARCHAR(MAX)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'XuLyBy', tenHienThi: 'Processed By Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Handling Staff' }
      ],
      cotMoRong: []
    },

    // 7.27 --------------------------------------------------------------
    {
      tableKey: 'DanhGia',
      tenVatLy: 'DanhGia',
      tenHienThi: 'REVIEWS',
      ghiChu: 'Mục đích: Lưu đánh giá sao và bình luận sau khi hoàn tất buổi đặt sân.',
      cotChinh: [
        { columnKey: 'DanhGiaID', tenHienThi: 'Review ID', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, unique: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'AccountID_NguoiDanhGia', tenHienThi: 'Reviewer Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Reviewer' },
        { columnKey: 'AccountID_NguoiBiDanhGia', tenHienThi: 'Reviewed Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Reviewed' },
        { columnKey: 'SoSao', tenHienThi: 'Rating', kieu: 'INT', ghiChuNgan: '1–5' },
        { columnKey: 'BinhLuan', tenHienThi: 'Comment', kieu: 'NVARCHAR(MAX)', nullable: true },
        { columnKey: 'NgayDanhGia', tenHienThi: 'Reviewed At', kieu: 'DATETIME' }
      ],
      cotMoRong: []
    },

    // 7.28 --------------------------------------------------------------
    {
      tableKey: 'CustomerReputationHistory',
      tenVatLy: 'CustomerReputationHistory',
      tenHienThi: 'REPUTATION HISTORY',
      ghiChu: 'Mục đích: Ghi lại mọi thay đổi điểm uy tín của khách hàng.',
      cotChinh: [
        { columnKey: 'ReputationHistoryID', tenHienThi: 'History ID', kieu: 'BIGINT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'ActionType', tenHienThi: 'Action Type', kieu: 'NVARCHAR(30)' },
        { columnKey: 'ScoreDelta', tenHienThi: 'Score Delta', kieu: 'INT' },
        { columnKey: 'ScoreBefore', tenHienThi: 'Score Before', kieu: 'INT' },
        { columnKey: 'ScoreAfter', tenHienThi: 'Score After', kieu: 'INT' },
        { columnKey: 'Reason', tenHienThi: 'Reason', kieu: 'NVARCHAR(500)' }
      ],
      cotMoRong: []
    },

    // 7.29 --------------------------------------------------------------
    {
      tableKey: 'GhepKeo',
      tenVatLy: 'GhepKeo',
      tenHienThi: 'MATCHMAKING POSTS',
      ghiChu: 'Mục đích: Lưu các bài đăng tìm người ghép kèo gắn với lịch đặt sân và môn thể thao.',
      cotChinh: [
        { columnKey: 'KeoID', tenHienThi: 'Matchmaking Post ID', kieu: 'INT', pk: true },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, unique: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'AccountID_NguoiTao', tenHienThi: 'Creator Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Creator' },
        { columnKey: 'MonTheThaoID', tenHienThi: 'Sport ID', kieu: 'INT', fk: true, thamChieu: 'MonTheThao.MonTheThaoID' },
        { columnKey: 'TrinhDo', tenHienThi: 'Skill Level', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'SoNguoiCanTim', tenHienThi: 'Required Players', kieu: 'INT' },
        { columnKey: 'HinhThucDuyet', tenHienThi: 'Approval Mode', kieu: 'NVARCHAR(20)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' }
      ],
      cotMoRong: []
    },

    // 7.30 --------------------------------------------------------------
    {
      tableKey: 'ChiTietGhepKeo',
      tenVatLy: 'ChiTietGhepKeo',
      tenHienThi: 'MATCHMAKING PARTICIPANTS',
      ghiChu: 'Mục đích: Lưu danh sách người tham gia và trạng thái phê duyệt cho từng bài đăng ghép kèo.',
      cotChinh: [
        { columnKey: 'ChiTietKeoID', tenHienThi: 'Participant ID', kieu: 'INT', pk: true },
        { columnKey: 'KeoID', tenHienThi: 'Matchmaking Post ID', kieu: 'INT', fk: true, thamChieu: 'GhepKeo.KeoID' },
        { columnKey: 'AccountID_NguoiThamGia', tenHienThi: 'Participant Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Participant' },
        { columnKey: 'TrangThaiThamGia', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'ViTriThamGia', tenHienThi: 'Playing Position', kieu: 'NVARCHAR(100)', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.31 --------------------------------------------------------------
    {
      tableKey: 'NhomChiaTien',
      tenVatLy: 'NhomChiaTien',
      tenHienThi: 'BILL SPLIT GROUPS',
      ghiChu: 'Mục đích: Định nghĩa cách chia hóa đơn cho nhiều người cùng thanh toán.',
      cotChinh: [
        { columnKey: 'NhomChiaTienID', tenHienThi: 'Split Group ID', kieu: 'INT', pk: true },
        { columnKey: 'HoaDonID', tenHienThi: 'Invoice ID', kieu: 'INT', fk: true, thamChieu: 'HoaDon.HoaDonID' },
        { columnKey: 'DatSanID', tenHienThi: 'Booking ID', kieu: 'INT', fk: true, thamChieu: 'LichDatSan.DatSanID' },
        { columnKey: 'CreatedByAccountID', tenHienThi: 'Creator Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID', vaiTro: 'Creator' },
        { columnKey: 'SplitType', tenHienThi: 'Split Type', kieu: 'NVARCHAR(20)' },
        { columnKey: 'TongTien', tenHienThi: 'Total Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(20)' },
        { columnKey: 'ExpiresAt', tenHienThi: 'Expires At', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.32 --------------------------------------------------------------
    {
      tableKey: 'NhomChiaTienChiTiet',
      tenVatLy: 'NhomChiaTienChiTiet',
      tenHienThi: 'BILL SPLIT MEMBERS',
      ghiChu: 'Mục đích: Lưu phần tiền, token chia sẻ, số tiền và trạng thái thanh toán của từng người.',
      cotChinh: [
        { columnKey: 'ChiTietID', tenHienThi: 'Split Member ID', kieu: 'INT', pk: true },
        { columnKey: 'NhomChiaTienID', tenHienThi: 'Split Group ID', kieu: 'INT', fk: true, thamChieu: 'NhomChiaTien.NhomChiaTienID' },
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', fk: true, nullable: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'DisplayName', tenHienThi: 'Payer Name', kieu: 'NVARCHAR(100)' },
        { columnKey: 'ShareToken', tenHienThi: 'Share Token', kieu: 'CHAR(43)', unique: true },
        { columnKey: 'SoTien', tenHienThi: 'Amount', kieu: 'DECIMAL(18,2)' },
        { columnKey: 'TrangThai', tenHienThi: 'Status', kieu: 'NVARCHAR(50)' },
        { columnKey: 'PaidAt', tenHienThi: 'Paid At', kieu: 'DATETIME2', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.33 --------------------------------------------------------------
    {
      tableKey: 'ThongBao',
      tenVatLy: 'ThongBao',
      tenHienThi: 'NOTIFICATIONS',
      ghiChu: 'Mục đích: Lưu các thông báo được hệ thống tạo ra cho tài khoản người dùng.',
      cotChinh: [
        { columnKey: 'ThongBaoID', tenHienThi: 'Notification ID', kieu: 'INT', pk: true },
        { columnKey: 'AccountID', tenHienThi: 'Account ID', kieu: 'INT', fk: true, thamChieu: 'Accounts.AccountID' },
        { columnKey: 'TieuDe', tenHienThi: 'Title', kieu: 'NVARCHAR(200)' },
        { columnKey: 'NoiDung', tenHienThi: 'Content', kieu: 'NVARCHAR(MAX)' },
        { columnKey: 'LoaiThongBao', tenHienThi: 'Notification Type', kieu: 'NVARCHAR(50)' },
        { columnKey: 'DaDoc', tenHienThi: 'Is Read', kieu: 'BIT' },
        { columnKey: 'ThoiGianGui', tenHienThi: 'Sent At', kieu: 'DATETIME' },
        { columnKey: 'DuongDan', tenHienThi: 'File Path', kieu: 'NVARCHAR(500)', nullable: true }
      ],
      cotMoRong: []
    },

    // 7.34 --------------------------------------------------------------
    {
      tableKey: 'AuditLog',
      tenVatLy: 'AuditLog',
      tenHienThi: 'AUDIT LOGS',
      ghiChu: 'Mục đích: Ghi lại các hành động quan trọng trong hệ thống phục vụ quản trị và truy vết.',
      cotChinh: [
        { columnKey: 'AuditLogID', tenHienThi: 'Audit Log ID', kieu: 'BIGINT', pk: true },
        { columnKey: 'ActorAccountID', tenHienThi: 'Actor Account ID', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'logical FK → Accounts.AccountID' },
        { columnKey: 'CoSoID', tenHienThi: 'Facility ID', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'logical FK → CoSo.CoSoID' },
        { columnKey: 'Action', tenHienThi: 'Action', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityType', tenHienThi: 'Entity Type', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityID', tenHienThi: 'Entity ID', kieu: 'NVARCHAR(50)' },
        { columnKey: 'IpAddress', tenHienThi: 'IP Address', kieu: 'NVARCHAR(50)', nullable: true },
        { columnKey: 'CreatedAt', tenHienThi: 'Event Time', kieu: 'DATETIME2' }
      ],
      cotMoRong: []
    },

    // 7.35 --------------------------------------------------------------
    {
      tableKey: 'AdminTrash',
      tenVatLy: 'AdminTrash',
      tenHienThi: 'ADMIN TRASH',
      ghiChu: 'Mục đích: Lưu tham chiếu các bản ghi đã xóa có thể xem lại hoặc khôi phục.',
      cotChinh: [
        { columnKey: 'TrashID', tenHienThi: 'Trash ID', kieu: 'INT', pk: true },
        { columnKey: 'EntityType', tenHienThi: 'Entity Type', kieu: 'NVARCHAR(100)' },
        { columnKey: 'EntityID', tenHienThi: 'Entity ID', kieu: 'INT', ghiChuNgan: 'logical reference' },
        { columnKey: 'DisplayName', tenHienThi: 'Display Name', kieu: 'NVARCHAR(255)', nullable: true },
        { columnKey: 'DeletedBy', tenHienThi: 'Deleted By Account ID', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'logical FK → Accounts.AccountID' },
        { columnKey: 'DeletedAt', tenHienThi: 'Deleted At', kieu: 'DATETIME2' },
        { columnKey: 'IsRestored', tenHienThi: 'Is Restored', kieu: 'BIT' },
        { columnKey: 'RestoredBy', tenHienThi: 'Restored By Account ID', kieu: 'INT', fk: false, fkLogic: true, nullable: true, thamChieu: '', ghiChuNgan: 'logical FK → Accounts.AccountID' }
      ],
      cotMoRong: []
    }
  ];

  // -----------------------------------------------------------------
  // 21 screen groups. Each group max 3 tables (except "Facilities and Geolocation").
  // layout: default top-left position {x,y} of each card in the group.
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
      id: 'roles-and-profiles',
      code: '01',
      title: 'Vai trò và Hồ sơ',
      entities: ['Roles', 'Accounts', 'MonTheThaoYeuThich'],
      canvas: CANVAS_TALL,
      layout: layout3('Roles', 'Accounts', 'MonTheThaoYeuThich')
    },
    {
      id: 'facilities-and-geolocation',
      code: '02',
      title: 'Cơ sở và Vị trí địa lý',
      entities: ['Accounts', 'CoSo'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'CoSo')
    },
    {
      id: 'sports-and-courts',
      code: '03',
      title: 'Môn thể thao và Sân',
      entities: ['MonTheThao', 'LoaiSan', 'San'],
      canvas: CANVAS,
      layout: layout3('MonTheThao', 'LoaiSan', 'San')
    },
    {
      id: 'court-bookings',
      code: '04',
      title: 'Đặt sân',
      entities: ['Accounts', 'San', 'LichDatSan'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'San', 'LichDatSan')
    },
    {
      id: 'temporary-holds',
      code: '05',
      title: 'Giữ sân tạm thời',
      entities: ['Accounts', 'San', 'SoftHold'],
      canvas: CANVAS,
      layout: layout3('Accounts', 'San', 'SoftHold')
    },
    {
      id: 'booking-extensions',
      code: '06',
      title: 'Gia hạn đặt sân',
      entities: ['LichDatSan', 'BookingExtension', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'BookingExtension', 'Accounts')
    },
    {
      id: 'products-services-inventory',
      code: '07',
      title: 'Kho sản phẩm và Dịch vụ',
      entities: ['CoSo', 'DanhMucSanPham', 'SanPham_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'DanhMucSanPham', 'SanPham_DichVu')
    },
    {
      id: 'booking-services',
      code: '08',
      title: 'Dịch vụ kèm đặt sân',
      entities: ['LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu')
    },
    {
      id: 'invoices',
      code: '09',
      title: 'Hóa đơn',
      entities: ['LichDatSan', 'HoaDon', 'ChiTietHoaDon'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'HoaDon', 'ChiTietHoaDon')
    },
    {
      id: 'court-pricing',
      code: '10',
      title: 'Định giá sân',
      entities: ['HoaDon', 'LichDatSan', 'CourtChargeSegment'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'LichDatSan', 'CourtChargeSegment')
    },
    {
      id: 'payos-payments',
      code: '11',
      title: 'Thanh toán PayOS',
      entities: ['CoSo', 'HoaDon', 'PayOSPaymentAttempt'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'HoaDon', 'PayOSPaymentAttempt')
    },
    {
      id: 'promotions-and-images',
      code: '12',
      title: 'Khuyến mãi và Hình ảnh',
      entities: ['KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai'],
      canvas: CANVAS_TALL,
      layout: layout3('KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai')
    },
    {
      id: 'refunds-and-receiving-qr',
      code: '13',
      title: 'Hoàn tiền và QR nhận tiền',
      entities: ['HoaDon', 'HoanTien', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'HoanTien', 'Accounts')
    },
    {
      id: 'secure-court-qr-codes',
      code: '14',
      title: 'Mã QR bảo mật sân',
      entities: ['San', 'SanQR', 'SanQRTokenHistory'],
      canvas: CANVAS,
      layout: layout3('San', 'SanQR', 'SanQRTokenHistory')
    },
    {
      id: 'requests-after-qr-scan',
      code: '15',
      title: 'Yêu cầu sau quét QR',
      entities: ['San', 'QRRequest', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('San', 'QRRequest', 'Accounts')
    },
    {
      id: 'work-shifts-and-leave-requests',
      code: '16',
      title: 'Ca làm việc và Nghỉ phép',
      entities: ['Accounts', 'CaLamViec', 'YeuCauNghi'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'CaLamViec', 'YeuCauNghi')
    },
    {
      id: 'reviews-and-reputation',
      code: '17',
      title: 'Đánh giá và Uy tín',
      entities: ['LichDatSan', 'DanhGia', 'CustomerReputationHistory'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'DanhGia', 'CustomerReputationHistory')
    },
    {
      id: 'matchmaking',
      code: '18',
      title: 'Ghép kèo',
      entities: ['Accounts', 'GhepKeo', 'ChiTietGhepKeo'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'GhepKeo', 'ChiTietGhepKeo')
    },
    {
      id: 'bill-splitting',
      code: '19',
      title: 'Chia tiền hóa đơn',
      entities: ['HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet')
    },
    {
      id: 'notifications',
      code: '20',
      title: 'Thông báo',
      entities: ['Accounts', 'ThongBao'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'ThongBao')
    },
    {
      id: 'audit-and-recovery',
      code: '21',
      title: 'Kiểm tra và Khôi phục',
      entities: ['Accounts', 'AuditLog', 'AdminTrash'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'AuditLog', 'AdminTrash')
    }
  ];

  global.ERD_ENTITIES = ERD_ENTITIES;
  global.ERD_VIEWS = ERD_VIEWS;
})(window);
