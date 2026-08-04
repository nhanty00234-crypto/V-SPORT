/* V-SPORT ERD (tinh gọn, tiếng Việt) — dữ liệu nguồn duy nhất.
 * 29 thực thể logic, 17 nhóm màn hình. Toàn bộ đường quan hệ được suy ra
 * (derive) từ metadata FK (thamChieu) khai báo trong từng cột — không có
 * danh sách cạnh thủ công nào khác trong app.js.
 *
 * Mỗi cột: { id, ten, kieu, pk, fk, unique, nullable, thamChieu }
 *   id        slug nội bộ không dấu, dùng làm khóa tra cứu trong JS.
 *   ten       tên cột hiển thị trên UI (tiếng Việt có dấu).
 *   kieu      kiểu SQL hiển thị (INT, NVARCHAR(n), DATE, ...).
 *   pk/fk/unique/nullable  cờ ràng buộc.
 *   thamChieu "slugBangDich.idCotDich" — chỉ có khi fk = true.
 */
(function (global) {
  'use strict';

  var ERD_ENTITIES = [
    // 5.1 ------------------------------------------------------------
    {
      slug: 'vai-tro',
      ten: 'VAI TRÒ',
      fields: [
        { id: 'ma_vai_tro', ten: 'Mã vai trò', kieu: 'INT', pk: true },
        { id: 'ten_vai_tro', ten: 'Tên vai trò', kieu: 'NVARCHAR(30)', unique: true }
      ]
    },
    // 5.2 ------------------------------------------------------------
    {
      slug: 'tai-khoan',
      ten: 'TÀI KHOẢN',
      fields: [
        { id: 'ma_tai_khoan', ten: 'Mã tài khoản', kieu: 'INT', pk: true },
        { id: 'ma_vai_tro', ten: 'Mã vai trò', kieu: 'INT', fk: true, thamChieu: 'vai-tro.ma_vai_tro' },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, nullable: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ho_ten', ten: 'Họ và tên', kieu: 'NVARCHAR(100)' },
        { id: 'email', ten: 'Email', kieu: 'VARCHAR(100)', unique: true },
        { id: 'so_dien_thoai', ten: 'Số điện thoại', kieu: 'VARCHAR(15)', unique: true, nullable: true },
        { id: 'mat_khau', ten: 'Mật khẩu', kieu: 'VARCHAR(255)' },
        { id: 'diem_uy_tin', ten: 'Điểm uy tín', kieu: 'INT' }
      ]
    },
    // 5.3 ------------------------------------------------------------
    {
      slug: 'co-so',
      ten: 'CƠ SỞ',
      fields: [
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', pk: true },
        { id: 'ten_co_so', ten: 'Tên cơ sở', kieu: 'NVARCHAR(100)' },
        { id: 'dia_chi', ten: 'Địa chỉ', kieu: 'NVARCHAR(255)' },
        { id: 'so_dien_thoai', ten: 'Số điện thoại', kieu: 'VARCHAR(15)', nullable: true },
        { id: 'gio_mo_cua', ten: 'Giờ mở cửa', kieu: 'TIME' },
        { id: 'gio_dong_cua', ten: 'Giờ đóng cửa', kieu: 'TIME' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.4 ------------------------------------------------------------
    {
      slug: 'mon-the-thao',
      ten: 'MÔN THỂ THAO',
      fields: [
        { id: 'ma_mon_the_thao', ten: 'Mã môn thể thao', kieu: 'INT', pk: true },
        { id: 'ten_mon_the_thao', ten: 'Tên môn thể thao', kieu: 'NVARCHAR(60)', unique: true }
      ]
    },
    // 5.5 ------------------------------------------------------------
    {
      slug: 'loai-san',
      ten: 'LOẠI SÂN',
      fields: [
        { id: 'ma_loai_san', ten: 'Mã loại sân', kieu: 'INT', pk: true },
        { id: 'ma_mon_the_thao', ten: 'Mã môn thể thao', kieu: 'INT', fk: true, thamChieu: 'mon-the-thao.ma_mon_the_thao' },
        { id: 'ten_loai_san', ten: 'Tên loại sân', kieu: 'NVARCHAR(100)' },
        { id: 'gia_khong_den', ten: 'Giá không đèn', kieu: 'DECIMAL(18,2)' },
        { id: 'gia_co_den', ten: 'Giá có đèn', kieu: 'DECIMAL(18,2)', nullable: true },
        { id: 'gio_bat_dau_co_den', ten: 'Giờ bắt đầu có đèn', kieu: 'TIME', nullable: true },
        { id: 'gio_ket_thuc_co_den', ten: 'Giờ kết thúc có đèn', kieu: 'TIME', nullable: true }
      ]
    },
    // 5.6 ------------------------------------------------------------
    {
      slug: 'san',
      ten: 'SÂN',
      fields: [
        { id: 'ma_san', ten: 'Mã sân', kieu: 'INT', pk: true },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ma_loai_san', ten: 'Mã loại sân', kieu: 'INT', fk: true, thamChieu: 'loai-san.ma_loai_san' },
        { id: 'ten_san', ten: 'Tên sân', kieu: 'NVARCHAR(100)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.7 ------------------------------------------------------------
    {
      slug: 'lich-dat-san',
      ten: 'LỊCH ĐẶT SÂN',
      fields: [
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', pk: true },
        { id: 'ma_khach_hang', ten: 'Mã khách hàng', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_san', ten: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'san.ma_san' },
        { id: 'bat_dau_du_kien', ten: 'Bắt đầu dự kiến', kieu: 'DATETIME2' },
        { id: 'ket_thuc_du_kien', ten: 'Kết thúc dự kiến', kieu: 'DATETIME2' },
        { id: 'bat_dau_thuc_te', ten: 'Bắt đầu thực tế', kieu: 'DATETIME2', nullable: true },
        { id: 'ket_thuc_thuc_te', ten: 'Kết thúc thực tế', kieu: 'DATETIME2', nullable: true },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.8 ------------------------------------------------------------
    {
      slug: 'giu-cho-tam-thoi',
      ten: 'GIỮ CHỖ TẠM THỜI',
      fields: [
        { id: 'ma_giu_cho', ten: 'Mã giữ chỗ', kieu: 'INT', pk: true },
        { id: 'ma_tai_khoan', ten: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_san', ten: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'san.ma_san' },
        { id: 'thoi_gian_bat_dau', ten: 'Thời gian bắt đầu', kieu: 'DATETIME2' },
        { id: 'thoi_gian_ket_thuc', ten: 'Thời gian kết thúc', kieu: 'DATETIME2' },
        { id: 'thoi_gian_het_han', ten: 'Thời gian hết hạn', kieu: 'DATETIME2' }
      ]
    },
    // 5.9 ------------------------------------------------------------
    {
      slug: 'danh-muc-san-pham',
      ten: 'DANH MỤC SẢN PHẨM',
      fields: [
        { id: 'ma_danh_muc', ten: 'Mã danh mục', kieu: 'INT', pk: true },
        { id: 'ten_danh_muc', ten: 'Tên danh mục', kieu: 'NVARCHAR(100)', unique: true }
      ]
    },
    // 5.10 -----------------------------------------------------------
    {
      slug: 'san-pham-dich-vu',
      ten: 'SẢN PHẨM DỊCH VỤ',
      fields: [
        { id: 'ma_san_pham', ten: 'Mã sản phẩm', kieu: 'INT', pk: true },
        { id: 'ma_danh_muc', ten: 'Mã danh mục', kieu: 'INT', fk: true, thamChieu: 'danh-muc-san-pham.ma_danh_muc' },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ten_san_pham', ten: 'Tên sản phẩm', kieu: 'NVARCHAR(150)' },
        { id: 'don_gia', ten: 'Đơn giá', kieu: 'DECIMAL(18,2)' },
        { id: 'so_luong_ton', ten: 'Số lượng tồn', kieu: 'INT' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.11 -----------------------------------------------------------
    {
      slug: 'dich-vu-dat-san',
      ten: 'DỊCH VỤ ĐẶT SÂN',
      fields: [
        { id: 'ma_dich_vu_dat', ten: 'Mã dịch vụ đặt', kieu: 'INT', pk: true },
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'lich-dat-san.ma_dat_san' },
        { id: 'ma_san_pham', ten: 'Mã sản phẩm', kieu: 'INT', fk: true, thamChieu: 'san-pham-dich-vu.ma_san_pham' },
        { id: 'so_luong', ten: 'Số lượng', kieu: 'INT' },
        { id: 'don_gia', ten: 'Đơn giá', kieu: 'DECIMAL(18,2)' },
        { id: 'trang_thai_giao', ten: 'Trạng thái giao', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.12 -----------------------------------------------------------
    {
      slug: 'hoa-don',
      ten: 'HÓA ĐƠN',
      fields: [
        { id: 'ma_hoa_don', ten: 'Mã hóa đơn', kieu: 'INT', pk: true },
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', fk: true, thamChieu: 'lich-dat-san.ma_dat_san' },
        { id: 'ma_khuyen_mai', ten: 'Mã khuyến mãi', kieu: 'INT', fk: true, nullable: true, thamChieu: 'khuyen-mai.ma_khuyen_mai' },
        { id: 'ma_hoa_don_cha', ten: 'Mã hóa đơn cha', kieu: 'INT', fk: true, nullable: true, thamChieu: 'hoa-don.ma_hoa_don' },
        { id: 'loai_hoa_don', ten: 'Loại hóa đơn', kieu: 'NVARCHAR(20)' },
        { id: 'tong_thanh_toan', ten: 'Tổng thanh toán', kieu: 'DECIMAL(18,2)' },
        { id: 'phuong_thuc_thanh_toan', ten: 'Phương thức thanh toán', kieu: 'NVARCHAR(30)' },
        { id: 'trang_thai_thanh_toan', ten: 'Trạng thái thanh toán', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.13 -----------------------------------------------------------
    {
      slug: 'chi-tiet-hoa-don',
      ten: 'CHI TIẾT HÓA ĐƠN',
      fields: [
        { id: 'ma_chi_tiet', ten: 'Mã chi tiết', kieu: 'INT', pk: true },
        { id: 'ma_hoa_don', ten: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'hoa-don.ma_hoa_don' },
        { id: 'ma_san_pham', ten: 'Mã sản phẩm', kieu: 'INT', fk: true, thamChieu: 'san-pham-dich-vu.ma_san_pham' },
        { id: 'so_luong', ten: 'Số lượng', kieu: 'INT' },
        { id: 'don_gia', ten: 'Đơn giá', kieu: 'DECIMAL(18,2)' },
        { id: 'thanh_tien', ten: 'Thành tiền', kieu: 'DECIMAL(18,2)' }
      ]
    },
    // 5.14 -----------------------------------------------------------
    {
      slug: 'giao-dich-payos',
      ten: 'GIAO DỊCH PAYOS',
      fields: [
        { id: 'ma_giao_dich', ten: 'Mã giao dịch', kieu: 'INT', pk: true },
        { id: 'ma_hoa_don', ten: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'hoa-don.ma_hoa_don' },
        { id: 'ma_don_hang_payos', ten: 'Mã đơn hàng PayOS', kieu: 'BIGINT', unique: true },
        { id: 'so_tien', ten: 'Số tiền', kieu: 'DECIMAL(18,2)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' },
        { id: 'thoi_gian_thanh_toan', ten: 'Thời gian thanh toán', kieu: 'DATETIME2', nullable: true }
      ]
    },
    // 5.15 -----------------------------------------------------------
    {
      slug: 'khuyen-mai',
      ten: 'KHUYẾN MÃI',
      fields: [
        { id: 'ma_khuyen_mai', ten: 'Mã khuyến mãi', kieu: 'INT', pk: true },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ma_giam_gia', ten: 'Mã giảm giá', kieu: 'VARCHAR(30)', unique: true },
        { id: 'loai_giam', ten: 'Loại giảm', kieu: 'NVARCHAR(20)' },
        { id: 'gia_tri_giam', ten: 'Giá trị giảm', kieu: 'DECIMAL(18,2)' },
        { id: 'ngay_bat_dau', ten: 'Ngày bắt đầu', kieu: 'DATETIME2' },
        { id: 'ngay_ket_thuc', ten: 'Ngày kết thúc', kieu: 'DATETIME2' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.16 -----------------------------------------------------------
    {
      slug: 'hoan-tien',
      ten: 'HOÀN TIỀN',
      fields: [
        { id: 'ma_hoan_tien', ten: 'Mã hoàn tiền', kieu: 'INT', pk: true },
        { id: 'ma_hoa_don', ten: 'Mã hóa đơn', kieu: 'INT', fk: true, thamChieu: 'hoa-don.ma_hoa_don' },
        { id: 'ma_khach_hang', ten: 'Mã khách hàng', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'so_tien_de_nghi', ten: 'Số tiền đề nghị', kieu: 'DECIMAL(18,2)' },
        { id: 'so_tien_duoc_duyet', ten: 'Số tiền được duyệt', kieu: 'DECIMAL(18,2)', nullable: true },
        { id: 'ly_do', ten: 'Lý do', kieu: 'NVARCHAR(500)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' },
        { id: 'ma_nguoi_duyet', ten: 'Mã người duyệt', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' }
      ]
    },
    // 5.17 -----------------------------------------------------------
    {
      slug: 'ma-qr-san',
      ten: 'MÃ QR SÂN',
      fields: [
        { id: 'ma_qr', ten: 'Mã QR', kieu: 'INT', pk: true },
        { id: 'ma_san', ten: 'Mã sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'san.ma_san' },
        { id: 'token', ten: 'Token', kieu: 'VARCHAR(100)', unique: true },
        { id: 'ma_rut_gon', ten: 'Mã rút gọn', kieu: 'VARCHAR(20)', unique: true },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.18 -----------------------------------------------------------
    {
      slug: 'yeu-cau-qr-san',
      ten: 'YÊU CẦU QR SÂN',
      fields: [
        { id: 'ma_yeu_cau', ten: 'Mã yêu cầu', kieu: 'INT', pk: true },
        { id: 'ma_san', ten: 'Mã sân', kieu: 'INT', fk: true, thamChieu: 'san.ma_san' },
        { id: 'ma_khach_hang', ten: 'Mã khách hàng', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'loai_yeu_cau', ten: 'Loại yêu cầu', kieu: 'NVARCHAR(30)' },
        { id: 'noi_dung_yeu_cau', ten: 'Nội dung yêu cầu', kieu: 'NVARCHAR(500)', nullable: true },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' },
        { id: 'ma_nhan_vien_xu_ly', ten: 'Mã nhân viên xử lý', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' }
      ]
    },
    // 5.19 -----------------------------------------------------------
    {
      slug: 'ca-lam-viec',
      ten: 'CA LÀM VIỆC',
      fields: [
        { id: 'ma_ca_lam', ten: 'Mã ca làm', kieu: 'INT', pk: true },
        { id: 'ma_nhan_vien', ten: 'Mã nhân viên', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ngay_lam', ten: 'Ngày làm', kieu: 'DATE' },
        { id: 'gio_bat_dau', ten: 'Giờ bắt đầu', kieu: 'TIME' },
        { id: 'gio_ket_thuc', ten: 'Giờ kết thúc', kieu: 'TIME' }
      ]
    },
    // 5.20 -----------------------------------------------------------
    {
      slug: 'yeu-cau-nghi',
      ten: 'YÊU CẦU NGHỈ',
      fields: [
        { id: 'ma_yeu_cau_nghi', ten: 'Mã yêu cầu nghỉ', kieu: 'INT', pk: true },
        { id: 'ma_nhan_vien', ten: 'Mã nhân viên', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'ngay_nghi', ten: 'Ngày nghỉ', kieu: 'DATE' },
        { id: 'loai_nghi', ten: 'Loại nghỉ', kieu: 'NVARCHAR(30)' },
        { id: 'ly_do', ten: 'Lý do', kieu: 'NVARCHAR(500)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' },
        { id: 'ma_nguoi_xu_ly', ten: 'Mã người xử lý', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' }
      ]
    },
    // 5.21 -----------------------------------------------------------
    {
      slug: 'danh-gia',
      ten: 'ĐÁNH GIÁ',
      fields: [
        { id: 'ma_danh_gia', ten: 'Mã đánh giá', kieu: 'INT', pk: true },
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'lich-dat-san.ma_dat_san' },
        { id: 'ma_nguoi_danh_gia', ten: 'Mã người đánh giá', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'so_sao', ten: 'Số sao', kieu: 'TINYINT' },
        { id: 'binh_luan', ten: 'Bình luận', kieu: 'NVARCHAR(1000)', nullable: true },
        { id: 'ngay_danh_gia', ten: 'Ngày đánh giá', kieu: 'DATETIME2' }
      ]
    },
    // 5.22 -----------------------------------------------------------
    {
      slug: 'lich-su-diem-uy-tin',
      ten: 'LỊCH SỬ ĐIỂM UY TÍN',
      fields: [
        { id: 'ma_lich_su', ten: 'Mã lịch sử', kieu: 'INT', pk: true },
        { id: 'ma_tai_khoan', ten: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', fk: true, nullable: true, thamChieu: 'lich-dat-san.ma_dat_san' },
        { id: 'loai_thay_doi', ten: 'Loại thay đổi', kieu: 'NVARCHAR(30)' },
        { id: 'so_diem_thay_doi', ten: 'Số điểm thay đổi', kieu: 'INT' },
        { id: 'diem_sau_thay_doi', ten: 'Điểm sau thay đổi', kieu: 'INT' },
        { id: 'ly_do', ten: 'Lý do', kieu: 'NVARCHAR(500)' }
      ]
    },
    // 5.23 -----------------------------------------------------------
    {
      slug: 'ghep-keo',
      ten: 'GHÉP KÈO',
      fields: [
        { id: 'ma_keo', ten: 'Mã kèo', kieu: 'INT', pk: true },
        { id: 'ma_dat_san', ten: 'Mã đặt sân', kieu: 'INT', fk: true, unique: true, thamChieu: 'lich-dat-san.ma_dat_san' },
        { id: 'ma_nguoi_tao', ten: 'Mã người tạo', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_mon_the_thao', ten: 'Mã môn thể thao', kieu: 'INT', fk: true, thamChieu: 'mon-the-thao.ma_mon_the_thao' },
        { id: 'trinh_do_yeu_cau', ten: 'Trình độ yêu cầu', kieu: 'NVARCHAR(30)', nullable: true },
        { id: 'so_nguoi_can_tim', ten: 'Số người cần tìm', kieu: 'INT' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.24 -----------------------------------------------------------
    {
      slug: 'thanh-vien-ghep-keo',
      ten: 'THÀNH VIÊN GHÉP KÈO',
      fields: [
        { id: 'ma_tham_gia', ten: 'Mã tham gia', kieu: 'INT', pk: true },
        { id: 'ma_keo', ten: 'Mã kèo', kieu: 'INT', fk: true, thamChieu: 'ghep-keo.ma_keo' },
        { id: 'ma_nguoi_tham_gia', ten: 'Mã người tham gia', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'trang_thai_tham_gia', ten: 'Trạng thái tham gia', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.25 -----------------------------------------------------------
    {
      slug: 'nhom-chia-tien',
      ten: 'NHÓM CHIA TIỀN',
      fields: [
        { id: 'ma_nhom_chia', ten: 'Mã nhóm chia', kieu: 'INT', pk: true },
        { id: 'ma_hoa_don', ten: 'Mã hóa đơn', kieu: 'INT', fk: true, unique: true, thamChieu: 'hoa-don.ma_hoa_don' },
        { id: 'ma_nguoi_tao', ten: 'Mã người tạo', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'hinh_thuc_chia', ten: 'Hình thức chia', kieu: 'NVARCHAR(20)' },
        { id: 'tong_tien', ten: 'Tổng tiền', kieu: 'DECIMAL(18,2)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.26 -----------------------------------------------------------
    {
      slug: 'chi-tiet-chia-tien',
      ten: 'CHI TIẾT CHIA TIỀN',
      fields: [
        { id: 'ma_chi_tiet_chia', ten: 'Mã chi tiết chia', kieu: 'INT', pk: true },
        { id: 'ma_nhom_chia', ten: 'Mã nhóm chia', kieu: 'INT', fk: true, thamChieu: 'nhom-chia-tien.ma_nhom_chia' },
        { id: 'ma_tai_khoan', ten: 'Mã tài khoản', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ten_nguoi_tra', ten: 'Tên người trả', kieu: 'NVARCHAR(100)' },
        { id: 'so_tien', ten: 'Số tiền', kieu: 'DECIMAL(18,2)' },
        { id: 'trang_thai', ten: 'Trạng thái', kieu: 'NVARCHAR(30)' }
      ]
    },
    // 5.27 -----------------------------------------------------------
    {
      slug: 'thong-bao',
      ten: 'THÔNG BÁO',
      fields: [
        { id: 'ma_thong_bao', ten: 'Mã thông báo', kieu: 'INT', pk: true },
        { id: 'ma_tai_khoan', ten: 'Mã tài khoản', kieu: 'INT', fk: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'tieu_de', ten: 'Tiêu đề', kieu: 'NVARCHAR(200)' },
        { id: 'loai_thong_bao', ten: 'Loại thông báo', kieu: 'NVARCHAR(30)' },
        { id: 'da_doc', ten: 'Đã đọc', kieu: 'BIT' },
        { id: 'thoi_gian_gui', ten: 'Thời gian gửi', kieu: 'DATETIME2' }
      ]
    },
    // 5.28 -----------------------------------------------------------
    {
      slug: 'nhat-ky-he-thong',
      ten: 'NHẬT KÝ HỆ THỐNG',
      fields: [
        { id: 'ma_nhat_ky', ten: 'Mã nhật ký', kieu: 'BIGINT', pk: true },
        { id: 'ma_nguoi_thuc_hien', ten: 'Mã người thực hiện', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'ma_co_so', ten: 'Mã cơ sở', kieu: 'INT', fk: true, nullable: true, thamChieu: 'co-so.ma_co_so' },
        { id: 'hanh_dong', ten: 'Hành động', kieu: 'NVARCHAR(100)' },
        { id: 'loai_doi_tuong', ten: 'Loại đối tượng', kieu: 'NVARCHAR(100)' },
        { id: 'dia_chi_ip', ten: 'Địa chỉ IP', kieu: 'VARCHAR(50)', nullable: true },
        { id: 'thoi_gian', ten: 'Thời gian', kieu: 'DATETIME2' }
      ]
    },
    // 5.29 -----------------------------------------------------------
    {
      slug: 'thung-rac',
      ten: 'THÙNG RÁC',
      fields: [
        { id: 'ma_ban_ghi_xoa', ten: 'Mã bản ghi xóa', kieu: 'INT', pk: true },
        { id: 'ma_nguoi_xoa', ten: 'Mã người xóa', kieu: 'INT', fk: true, nullable: true, thamChieu: 'tai-khoan.ma_tai_khoan' },
        { id: 'loai_doi_tuong', ten: 'Loại đối tượng', kieu: 'NVARCHAR(100)' },
        { id: 'ma_doi_tuong', ten: 'Mã đối tượng', kieu: 'INT' },
        { id: 'ten_hien_thi', ten: 'Tên hiển thị', kieu: 'NVARCHAR(255)', nullable: true },
        { id: 'thoi_gian_xoa', ten: 'Thời gian xóa', kieu: 'DATETIME2' },
        { id: 'da_khoi_phuc', ten: 'Đã khôi phục', kieu: 'BIT' }
      ]
    }
  ];

  // -----------------------------------------------------------------
  // 17 nhóm màn hình. Mỗi nhóm tối đa 3 bảng, canvas 16:9 (1600x900).
  // layout: vị trí mặc định {x,y} góc trên-trái của từng card trong nhóm.
  // -----------------------------------------------------------------
  var CANVAS = { w: 1600, h: 900 };

  function layout2(a, b) {
    var l = {};
    l[a] = { x: 220, y: 300 };
    l[b] = { x: 980, y: 300 };
    return l;
  }

  function layout3(a, b, c) {
    var l = {};
    l[a] = { x: 90, y: 160 };
    l[b] = { x: 660, y: 160 };
    l[c] = { x: 1230, y: 160 };
    return l;
  }

  var ERD_VIEWS = [
    {
      id: 'tai-khoan-phan-quyen',
      code: '01',
      title: 'Tài khoản và phân quyền',
      entities: ['vai-tro', 'tai-khoan'],
      canvas: CANVAS,
      layout: layout2('vai-tro', 'tai-khoan')
    },
    {
      id: 'co-so-mon-the-thao',
      code: '02',
      title: 'Cơ sở và môn thể thao',
      entities: ['co-so', 'mon-the-thao'],
      canvas: CANVAS,
      layout: layout2('co-so', 'mon-the-thao')
    },
    {
      id: 'loai-san-va-san',
      code: '03',
      title: 'Loại sân và sân',
      entities: ['mon-the-thao', 'loai-san', 'san'],
      canvas: CANVAS,
      layout: layout3('mon-the-thao', 'loai-san', 'san')
    },
    {
      id: 'dat-san',
      code: '04',
      title: 'Đặt sân',
      entities: ['tai-khoan', 'san', 'lich-dat-san'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'san', 'lich-dat-san')
    },
    {
      id: 'giu-cho-tam-thoi',
      code: '05',
      title: 'Giữ chỗ tạm thời',
      entities: ['tai-khoan', 'san', 'giu-cho-tam-thoi'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'san', 'giu-cho-tam-thoi')
    },
    {
      id: 'kho-san-pham-dich-vu',
      code: '06',
      title: 'Kho sản phẩm dịch vụ',
      entities: ['co-so', 'danh-muc-san-pham', 'san-pham-dich-vu'],
      canvas: CANVAS,
      layout: layout3('co-so', 'danh-muc-san-pham', 'san-pham-dich-vu')
    },
    {
      id: 'dich-vu-kem-lich-dat',
      code: '07',
      title: 'Dịch vụ kèm lịch đặt',
      entities: ['lich-dat-san', 'san-pham-dich-vu', 'dich-vu-dat-san'],
      canvas: CANVAS,
      layout: layout3('lich-dat-san', 'san-pham-dich-vu', 'dich-vu-dat-san')
    },
    {
      id: 'hoa-don',
      code: '08',
      title: 'Hóa đơn',
      entities: ['lich-dat-san', 'hoa-don', 'chi-tiet-hoa-don'],
      canvas: CANVAS,
      layout: layout3('lich-dat-san', 'hoa-don', 'chi-tiet-hoa-don')
    },
    {
      id: 'thanh-toan-payos',
      code: '09',
      title: 'Thanh toán PayOS',
      entities: ['hoa-don', 'giao-dich-payos'],
      canvas: CANVAS,
      layout: layout2('hoa-don', 'giao-dich-payos')
    },
    {
      id: 'ma-qr-tai-san',
      code: '10',
      title: 'Mã QR tại sân',
      entities: ['san', 'ma-qr-san', 'yeu-cau-qr-san'],
      canvas: CANVAS,
      layout: layout3('san', 'ma-qr-san', 'yeu-cau-qr-san')
    },
    {
      id: 'ca-lam-va-nghi-phep',
      code: '11',
      title: 'Ca làm và nghỉ phép',
      entities: ['tai-khoan', 'ca-lam-viec', 'yeu-cau-nghi'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'ca-lam-viec', 'yeu-cau-nghi')
    },
    {
      id: 'khuyen-mai-va-hoan-tien',
      code: '12',
      title: 'Khuyến mãi và hoàn tiền',
      entities: ['khuyen-mai', 'hoa-don', 'hoan-tien'],
      canvas: CANVAS,
      layout: layout3('khuyen-mai', 'hoa-don', 'hoan-tien')
    },
    {
      id: 'danh-gia-va-diem-uy-tin',
      code: '13',
      title: 'Đánh giá và điểm uy tín',
      entities: ['tai-khoan', 'danh-gia', 'lich-su-diem-uy-tin'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'danh-gia', 'lich-su-diem-uy-tin')
    },
    {
      id: 'ghep-keo',
      code: '14',
      title: 'Ghép kèo',
      entities: ['tai-khoan', 'ghep-keo', 'thanh-vien-ghep-keo'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'ghep-keo', 'thanh-vien-ghep-keo')
    },
    {
      id: 'chia-tien-hoa-don',
      code: '15',
      title: 'Chia tiền hóa đơn',
      entities: ['hoa-don', 'nhom-chia-tien', 'chi-tiet-chia-tien'],
      canvas: CANVAS,
      layout: layout3('hoa-don', 'nhom-chia-tien', 'chi-tiet-chia-tien')
    },
    {
      id: 'thong-bao',
      code: '16',
      title: 'Thông báo',
      entities: ['tai-khoan', 'thong-bao'],
      canvas: CANVAS,
      layout: layout2('tai-khoan', 'thong-bao')
    },
    {
      id: 'kiem-toan-va-khoi-phuc',
      code: '17',
      title: 'Kiểm toán và khôi phục',
      entities: ['tai-khoan', 'nhat-ky-he-thong', 'thung-rac'],
      canvas: CANVAS,
      layout: layout3('tai-khoan', 'nhat-ky-he-thong', 'thung-rac')
    }
  ];

  global.ERD_ENTITIES = ERD_ENTITIES;
  global.ERD_VIEWS = ERD_VIEWS;
})(window);
