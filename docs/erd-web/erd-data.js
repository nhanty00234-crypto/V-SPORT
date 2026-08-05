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
      ghiChu: 'Purpose: Defines the system roles assigned to user accounts.',
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
      ghiChu: 'Purpose: Stores user login, profile, facility assignment, and reputation information.',
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
      ghiChu: 'Purpose: Links each customer account to the sports they prefer.',
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
      ghiChu: 'Purpose: Stores facility details, image gallery, operating hours, and map coordinates.',
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
      ghiChu: 'Purpose: Stores the sports supported by the booking system.',
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
      ghiChu: 'Purpose: Defines court categories, supported sport, lighting periods, and hourly rates.',
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
      ghiChu: 'Purpose: Stores the individual courts available at each facility.',
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
      ghiChu: 'Purpose: Temporarily reserves a court slot while a customer completes a booking.',
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
      ghiChu: 'Purpose: Stores court reservations and their planned and actual usage times.',
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
      ghiChu: 'Purpose: Records approved booking extensions and additional charges.',
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
      ghiChu: 'Purpose: Groups products and services sold at facilities.',
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
      ghiChu: 'Purpose: Stores facility products, services, stock, prices, and images.',
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
      ghiChu: 'Purpose: Records products or services added to a court booking.',
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
      ghiChu: 'Purpose: Stores the financial summary and payment status of a booking.',
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
      ghiChu: 'Purpose: Stores product and service line items included in an invoice.',
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
      ghiChu: 'Purpose: Splits court usage into time segments with different hourly rates.',
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
      ghiChu: 'Purpose: Tracks PayOS payment orders, QR payloads, amounts, and outcomes.',
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
      ghiChu: 'Purpose: Stores promotion rules, validity periods, limits, and facility scope.',
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
      ghiChu: 'Purpose: Stores the ordered image gallery and cover image of a promotion.',
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
      ghiChu: 'Purpose: Records when an account uses a promotion for an invoice.',
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
      ghiChu: 'Purpose: Stores refund requests, approval results, and the customer\'s receiving QR image.',
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
      ghiChu: 'Purpose: Stores the active secure QR token assigned one-to-one to each court.',
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
      ghiChu: 'Purpose: Stores revoked QR token hashes for security and revocation checks.',
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
      ghiChu: 'Purpose: Stores staff, product, or service requests submitted after scanning a court QR code.',
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
      ghiChu: 'Purpose: Assigns staff members to scheduled working times at a facility.',
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
      ghiChu: 'Purpose: Stores staff leave requests and manager processing results.',
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
      ghiChu: 'Purpose: Stores post-booking ratings and comments.',
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
      ghiChu: 'Purpose: Records every change to a customer\'s reputation score.',
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
      ghiChu: 'Purpose: Stores player-finding posts linked to a booking and sport.',
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
      ghiChu: 'Purpose: Stores participants and approval status for each matchmaking post.',
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
      ghiChu: 'Purpose: Defines how an invoice is divided among multiple payers.',
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
      ghiChu: 'Purpose: Stores each payer\'s share, token, amount, and payment status.',
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
      ghiChu: 'Purpose: Stores notifications generated for user accounts by system workflows.',
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
      ghiChu: 'Purpose: Records important system actions for administration and traceability.',
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
      ghiChu: 'Purpose: Stores references to deleted records that can be reviewed or restored.',
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
      title: 'Roles and Profiles',
      entities: ['Roles', 'Accounts', 'MonTheThaoYeuThich'],
      canvas: CANVAS_TALL,
      layout: layout3('Roles', 'Accounts', 'MonTheThaoYeuThich')
    },
    {
      id: 'facilities-and-geolocation',
      code: '02',
      title: 'Facilities and Geolocation',
      entities: ['Accounts', 'CoSo'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'CoSo')
    },
    {
      id: 'sports-and-courts',
      code: '03',
      title: 'Sports and Courts',
      entities: ['MonTheThao', 'LoaiSan', 'San'],
      canvas: CANVAS,
      layout: layout3('MonTheThao', 'LoaiSan', 'San')
    },
    {
      id: 'court-bookings',
      code: '04',
      title: 'Court Bookings',
      entities: ['Accounts', 'San', 'LichDatSan'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'San', 'LichDatSan')
    },
    {
      id: 'temporary-holds',
      code: '05',
      title: 'Temporary Holds',
      entities: ['Accounts', 'San', 'SoftHold'],
      canvas: CANVAS,
      layout: layout3('Accounts', 'San', 'SoftHold')
    },
    {
      id: 'booking-extensions',
      code: '06',
      title: 'Booking Extensions',
      entities: ['LichDatSan', 'BookingExtension', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'BookingExtension', 'Accounts')
    },
    {
      id: 'products-services-inventory',
      code: '07',
      title: 'Products and Services Inventory',
      entities: ['CoSo', 'DanhMucSanPham', 'SanPham_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'DanhMucSanPham', 'SanPham_DichVu')
    },
    {
      id: 'booking-services',
      code: '08',
      title: 'Booking Services',
      entities: ['LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'SanPham_DichVu', 'LichDatSan_DichVu')
    },
    {
      id: 'invoices',
      code: '09',
      title: 'Invoices',
      entities: ['LichDatSan', 'HoaDon', 'ChiTietHoaDon'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'HoaDon', 'ChiTietHoaDon')
    },
    {
      id: 'court-pricing',
      code: '10',
      title: 'Court Pricing',
      entities: ['HoaDon', 'LichDatSan', 'CourtChargeSegment'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'LichDatSan', 'CourtChargeSegment')
    },
    {
      id: 'payos-payments',
      code: '11',
      title: 'PayOS Payments',
      entities: ['CoSo', 'HoaDon', 'PayOSPaymentAttempt'],
      canvas: CANVAS_TALL,
      layout: layout3('CoSo', 'HoaDon', 'PayOSPaymentAttempt')
    },
    {
      id: 'promotions-and-images',
      code: '12',
      title: 'Promotions and Images',
      entities: ['KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai'],
      canvas: CANVAS_TALL,
      layout: layout3('KhuyenMai', 'KhuyenMaiHinhAnh', 'LichSuKhuyenMai')
    },
    {
      id: 'refunds-and-receiving-qr',
      code: '13',
      title: 'Refunds and Receiving QR',
      entities: ['HoaDon', 'HoanTien', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'HoanTien', 'Accounts')
    },
    {
      id: 'secure-court-qr-codes',
      code: '14',
      title: 'Secure Court QR Codes',
      entities: ['San', 'SanQR', 'SanQRTokenHistory'],
      canvas: CANVAS,
      layout: layout3('San', 'SanQR', 'SanQRTokenHistory')
    },
    {
      id: 'requests-after-qr-scan',
      code: '15',
      title: 'Requests After QR Scan',
      entities: ['San', 'QRRequest', 'Accounts'],
      canvas: CANVAS_TALL,
      layout: layout3('San', 'QRRequest', 'Accounts')
    },
    {
      id: 'work-shifts-and-leave-requests',
      code: '16',
      title: 'Work Shifts and Leave Requests',
      entities: ['Accounts', 'CaLamViec', 'YeuCauNghi'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'CaLamViec', 'YeuCauNghi')
    },
    {
      id: 'reviews-and-reputation',
      code: '17',
      title: 'Reviews and Reputation',
      entities: ['LichDatSan', 'DanhGia', 'CustomerReputationHistory'],
      canvas: CANVAS_TALL,
      layout: layout3('LichDatSan', 'DanhGia', 'CustomerReputationHistory')
    },
    {
      id: 'matchmaking',
      code: '18',
      title: 'Matchmaking',
      entities: ['Accounts', 'GhepKeo', 'ChiTietGhepKeo'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'GhepKeo', 'ChiTietGhepKeo')
    },
    {
      id: 'bill-splitting',
      code: '19',
      title: 'Bill Splitting',
      entities: ['HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet'],
      canvas: CANVAS_TALL,
      layout: layout3('HoaDon', 'NhomChiaTien', 'NhomChiaTienChiTiet')
    },
    {
      id: 'notifications',
      code: '20',
      title: 'Notifications',
      entities: ['Accounts', 'ThongBao'],
      canvas: CANVAS_TALL,
      layout: layout2('Accounts', 'ThongBao')
    },
    {
      id: 'audit-and-recovery',
      code: '21',
      title: 'Audit and Recovery',
      entities: ['Accounts', 'AuditLog', 'AdminTrash'],
      canvas: CANVAS_TALL,
      layout: layout3('Accounts', 'AuditLog', 'AdminTrash')
    }
  ];

  global.ERD_ENTITIES = ERD_ENTITIES;
  global.ERD_VIEWS = ERD_VIEWS;
})(window);
