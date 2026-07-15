package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CoSoDAO;
import org.example.dao.HoaDonDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.HoaDonDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.ChiTietHoaDon;
import org.example.model.CoSo;
import org.example.model.HoaDon;
import org.example.model.Lichdatsan;
import org.example.model.LoaiSan;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Route CHỈ ĐỌC để xem trước / in lại hóa đơn (bill 80mm).
 * Không tạo hóa đơn, không thanh toán, không trừ kho, không cập nhật trạng thái.
 */
@WebServlet("/staff/hoa-don/in")
public class HoaDonPrintServlet extends HttpServlet {

    private final HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();
    private final CoSoDAO coSoDAO = new CoSoDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final SanPhamDichVuDAO sanPhamDichVuDAO = new SanPhamDichVuDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Kiểm tra đăng nhập + role Staff (4) hoặc Manager (2)
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            return;
        }

        // 2. Parse HoaDonID an toàn
        String idStr = req.getParameter("id");
        int hoaDonId;
        try {
            if (idStr == null || idStr.isEmpty()) {
                throw new NumberFormatException("missing id");
            }
            hoaDonId = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã hóa đơn không hợp lệ.");
            return;
        }

        // 3. Load hóa đơn
        HoaDon hoaDon = hoaDonDAO.getHoaDonById(hoaDonId);
        if (hoaDon == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hóa đơn #" + hoaDonId + ".");
            return;
        }

        // 4. Load ca chơi / đơn đặt sân liên quan
        Lichdatsan lich = hoaDon.getDatSanId() != null ? lichDatSanDAO.getLichById(hoaDon.getDatSanId()) : null;
        if (lich == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Hóa đơn #" + hoaDonId + " không có dữ liệu ca chơi hợp lệ.");
            return;
        }

        // 5. Load sân, loại sân, cơ sở
        San san = lich.getSanId() != null ? sanDAO.getSanById(lich.getSanId()) : null;
        if (san == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy thông tin sân của hóa đơn #" + hoaDonId + ".");
            return;
        }
        LoaiSan loaiSan = loaiSanDAO.getLoaiSanById(san.getLoaiSanID());
        CoSo coSo = coSoDAO.getCoSoById(san.getCoSoID());

        // 6. Kiểm tra hóa đơn thuộc đúng cơ sở của người đăng nhập (chặn IDOR)
        if (san.getCoSoID() != user.getCoSoId()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền xem hóa đơn thuộc cơ sở khác.");
            return;
        }

        // 7. Load khách hàng (nếu có) và nhân viên thu ngân
        TaiKhoan khachHang = hoaDon.getAccountIdKhachHang() != null
                ? taiKhoanDAO.getAccountById(hoaDon.getAccountIdKhachHang()) : null;
        TaiKhoan nhanVien = hoaDon.getAccountIdNhanVien() != null
                ? taiKhoanDAO.getAccountById(hoaDon.getAccountIdNhanVien()) : null;

        // 8. Load chi tiết dịch vụ (giá/số lượng/thành tiền đã CHỐT tại thời điểm bán, không lấy lại giá hiện tại)
        List<ChiTietHoaDon> chiTietList = hoaDonDAO.getChiTietByHoaDonId(hoaDonId);
        List<DichVuLine> dichVuRows = new ArrayList<>();
        for (ChiTietHoaDon ct : chiTietList) {
            SanPham_DichVu sp = sanPhamDichVuDAO.findById(ct.getSanPhamID());
            String tenSp = sp != null ? sp.getTenSanPham() : ("Sản phẩm #" + ct.getSanPhamID() + " (đã ngừng kinh doanh)");
            dichVuRows.add(new DichVuLine(tenSp, ct.getSoLuong(), ct.getDonGiaTaiThoiDiemBan(), ct.getThanhTien()));
        }

        // 9. Nếu đây là hóa đơn MAIN, tìm các hóa đơn tách dịch vụ liên quan (nếu có) để hiển thị liên kết
        boolean isSplit = "SPLIT".equals(hoaDon.getLoaiHoaDon());
        List<Integer> splitHoaDonIds = (!isSplit) ? hoaDonDAO.getSplitHoaDonIdsByParent(hoaDonId) : List.of();

        // 10. Tính ngày/giờ bắt đầu-kết thúc thực tế (ưu tiên actual_*), xử lý ca chơi qua ngày.
        // Định dạng sẵn thành String ở đây vì java.time.LocalTime/LocalDate không tương thích trực tiếp
        // với thẻ <fmt:formatDate> của JSTL (chỉ nhận java.util.Date).
        LocalTime gioBatDau = lich.getActualStartTime() != null ? lich.getActualStartTime() : lich.getGioBatDau();
        LocalTime gioKetThuc = lich.getActualEndTime() != null ? lich.getActualEndTime() : lich.getGioKetThuc();
        LocalDate ngayBatDau = lich.getNgayDat();
        boolean quaNgay = gioBatDau != null && gioKetThuc != null && gioKetThuc.isBefore(gioBatDau);
        LocalDate ngayKetThuc = quaNgay && ngayBatDau != null ? ngayBatDau.plusDays(1) : ngayBatDau;

        long playedMinutes = 0;
        if (gioBatDau != null && gioKetThuc != null) {
            long startMin = gioBatDau.toSecondOfDay() / 60;
            long endMin = gioKetThuc.toSecondOfDay() / 60;
            playedMinutes = endMin - startMin;
            if (playedMinutes < 0) playedMinutes += 24 * 60;
        }
        String tongThoiGianChoi = "-";
        if (gioBatDau != null && gioKetThuc != null) {
            long hh = playedMinutes / 60;
            long mm = playedMinutes % 60;
            tongThoiGianChoi = (hh > 0 ? hh + " giờ " : "") + mm + " phút";
        }

        java.time.format.DateTimeFormatter hmFmt = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
        java.time.format.DateTimeFormatter dmyFmt = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String gioBatDauStr = gioBatDau != null ? gioBatDau.format(hmFmt) : "-";
        String gioKetThucStr = gioKetThuc != null ? gioKetThuc.format(hmFmt) : "-";
        String ngayBatDauStr = ngayBatDau != null ? ngayBatDau.format(dmyFmt) : "-";
        String ngayKetThucStr = ngayKetThuc != null ? ngayKetThuc.format(dmyFmt) : "-";

        // 11. Đơn giá sân hiển thị = tổng tiền sân ĐÃ CHỐT trên hóa đơn / số giờ chơi (không lấy giá LoaiSan hiện tại)
        String donGiaSanStr = "-";
        if (playedMinutes > 0) {
            double perHour = hoaDon.getTongTienSan() / (playedMinutes / 60.0);
            donGiaSanStr = Math.round(perHour) + " đ/giờ";
        }

        // 12. Đưa dữ liệu sang JSP (chỉ đọc, không có thao tác ghi nào ở trên)
        req.setAttribute("hoaDon", hoaDon);
        req.setAttribute("lich", lich);
        req.setAttribute("san", san);
        req.setAttribute("loaiSan", loaiSan);
        req.setAttribute("coSo", coSo);
        req.setAttribute("khachHang", khachHang);
        req.setAttribute("nhanVien", nhanVien);
        req.setAttribute("dichVuRows", dichVuRows);
        req.setAttribute("isSplit", isSplit);
        req.setAttribute("splitHoaDonIds", splitHoaDonIds);
        req.setAttribute("gioBatDauStr", gioBatDauStr);
        req.setAttribute("gioKetThucStr", gioKetThucStr);
        req.setAttribute("ngayBatDauStr", ngayBatDauStr);
        req.setAttribute("ngayKetThucStr", ngayKetThucStr);
        req.setAttribute("quaNgay", quaNgay);
        req.setAttribute("tongThoiGianChoi", tongThoiGianChoi);
        req.setAttribute("donGiaSanStr", donGiaSanStr);

        req.getRequestDispatcher("/staff/HoaDonPrint.jsp").forward(req, resp);
    }

    /** DTO 1 dòng dịch vụ trên bill - dùng giá/thành tiền đã chốt trong ChiTietHoaDon, không phải giá hiện tại. */
    public static class DichVuLine {
        private final String ten;
        private final int soLuong;
        private final double donGia;
        private final double thanhTien;

        public DichVuLine(String ten, int soLuong, double donGia, double thanhTien) {
            this.ten = ten;
            this.soLuong = soLuong;
            this.donGia = donGia;
            this.thanhTien = thanhTien;
        }

        public String getTen() { return ten; }
        public int getSoLuong() { return soLuong; }
        public double getDonGia() { return donGia; }
        public double getThanhTien() { return thanhTien; }
    }
}
