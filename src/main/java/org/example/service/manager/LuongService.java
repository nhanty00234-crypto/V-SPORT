package org.example.service.manager;

import org.example.dao.BangLuongDAO;
import org.example.dao.CaLamViecDAO;
import org.example.dao.CauHinhLuongDAO;
import org.example.dao.KyLuongDAO;
import org.example.dao.YeuCauUngLuongDAO;
import org.example.dao.impl.BangLuongDAOImpl;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.CauHinhLuongDAOImpl;
import org.example.dao.impl.KyLuongDAOImpl;
import org.example.dao.impl.YeuCauUngLuongDAOImpl;
import org.example.model.BangLuong;
import org.example.model.CauHinhLuong;
import org.example.model.KyLuong;
import org.example.util.LuongCalculator;
import org.example.util.VietQrUrl;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.List;

/**
 * Nghiệp vụ kỳ lương của manager. Mọi phương thức nhận coSoId lấy từ session — service
 * KHÔNG tự suy ra cơ sở từ id truyền vào, đó là lớp chặn IDOR.
 */
public class LuongService {

    private final CauHinhLuongDAO cauHinhDAO = new CauHinhLuongDAOImpl();
    private final KyLuongDAO kyDAO = new KyLuongDAOImpl();
    private final BangLuongDAO bangDAO = new BangLuongDAOImpl();
    private final YeuCauUngLuongDAO ungDAO = new YeuCauUngLuongDAOImpl();
    private final CaLamViecDAO caDAO = new CaLamViecDAOImpl();

    public List<CauHinhLuong> danhSachCauHinh(int coSoId) throws Exception {
        return cauHinhDAO.listByCoSo(coSoId);
    }

    public void luuCauHinh(CauHinhLuong ch) throws Exception {
        cauHinhDAO.upsert(ch);
    }

    public List<KyLuong> danhSachKy(int coSoId) throws Exception {
        return kyDAO.listByCoSo(coSoId);
    }

    /**
     * Tạo kỳ lương mới. Ném IllegalArgumentException với thông báo tiếng Việt nếu khoảng
     * ngày không hợp lệ — servlet bắt và hiển thị lại cho manager.
     */
    public int taoKy(int coSoId, int managerId, String tenKy,
                     LocalDate batDau, LocalDate ketThuc, LocalDate ngayPhat) throws Exception {
        if (tenKy == null || tenKy.isBlank()) {
            throw new IllegalArgumentException("Tên kỳ lương không được để trống.");
        }
        if (batDau == null || ketThuc == null || ngayPhat == null) {
            throw new IllegalArgumentException("Vui lòng nhập đủ ngày bắt đầu, kết thúc và ngày phát lương.");
        }
        if (ketThuc.isBefore(batDau)) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu.");
        }
        if (ngayPhat.isBefore(ketThuc)) {
            throw new IllegalArgumentException("Ngày phát lương phải từ ngày kết thúc kỳ trở đi.");
        }
        KyLuong ky = new KyLuong();
        ky.setCoSoId(coSoId);
        ky.setTenKy(tenKy.trim());
        ky.setNgayBatDau(batDau);
        ky.setNgayKetThuc(ketThuc);
        ky.setNgayPhatLuong(ngayPhat);
        ky.setTrangThai(KyLuong.DRAFT);
        ky.setCreatedBy(managerId);
        return kyDAO.insert(ky);
    }

    /**
     * Tính lại toàn bộ bảng lương của kỳ theo công thức spec §4. Chạy lại được nhiều lần
     * (upsert), nhưng kỳ đã phát thì bị khoá để không sửa số tiền sau khi đã chuyển khoản.
     *
     * @return số nhân viên đã được tính
     */
    public int tinhLuongChoKy(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        if (ky.isKhoa()) {
            throw new IllegalStateException("Kỳ lương đã phát, không thể tính lại.");
        }

        List<CauHinhLuong> dsCauHinh = cauHinhDAO.listByCoSo(coSoId);
        int dem = 0;
        for (CauHinhLuong ch : dsCauHinh) {
            // Nhân viên chưa được cấu hình lương (cả 2 khoản = 0) thì bỏ qua, không tạo
            // dòng lương 0 đồng gây nhiễu trang phát lương.
            if (LuongCalculator.chuanHoa(ch.getLuongCoBan()).signum() == 0
                    && LuongCalculator.chuanHoa(ch.getPhuCapMoiCa()).signum() == 0) {
                continue;
            }

            int soCa = caDAO.countCaHoanThanh(ch.getAccountId(), coSoId, ky.getNgayBatDau(), ky.getNgayKetThuc());
            BigDecimal phuCap = LuongCalculator.tongPhuCap(ch.getPhuCapMoiCa(), soCa);
            BigDecimal khauTru = ungDAO.tongDaDuyetTrongKhoang(ch.getAccountId(), ky.getNgayBatDau(), ky.getNgayKetThuc());
            BigDecimal thucNhan = LuongCalculator.tongLuongThuc(ch.getLuongCoBan(), phuCap, khauTru);

            BangLuong bl = new BangLuong();
            bl.setKyLuongId(kyLuongId);
            bl.setAccountId(ch.getAccountId());
            bl.setLuongCoBan(LuongCalculator.chuanHoa(ch.getLuongCoBan()));
            bl.setTongPhuCap(phuCap);
            bl.setTongKhauTru(LuongCalculator.chuanHoa(khauTru));
            bl.setTongLuongThuc(thucNhan);
            bl.setSoCaLamViec(soCa);
            bl.setTrangThai(BangLuong.DA_TINH);
            bangDAO.upsert(bl);
            dem++;
        }

        kyDAO.updateTrangThai(kyLuongId, coSoId, KyLuong.DANG_TINH);
        return dem;
    }

    /** Bảng lương của kỳ, đã gắn sẵn URL VietQR động cho trang phát lương. */
    public List<BangLuong> bangLuongCuaKy(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        List<BangLuong> ds = bangDAO.listByKy(kyLuongId);
        for (BangLuong bl : ds) {
            bl.setTenKy(ky.getTenKy());
            bl.setNgayPhatLuong(ky.getNgayPhatLuong());
            bl.setQrDongUrl(VietQrUrl.compact2(
                    bl.getMaNganHang(), bl.getSoTaiKhoan(), bl.getTongLuongThuc(),
                    "Luong " + khongDau(ky.getTenKy()), bl.getHoTen()));
        }
        return ds;
    }

    /** Chốt phát lương: khoá kỳ và đánh dấu mọi dòng lương là đã phát. */
    public void chotPhatLuong(int kyLuongId, int coSoId) throws Exception {
        KyLuong ky = kyDAO.findById(kyLuongId, coSoId);
        if (ky == null) {
            throw new IllegalArgumentException("Kỳ lương không tồn tại.");
        }
        bangDAO.updateTrangThaiTheoKy(kyLuongId, BangLuong.DA_PHAT);
        kyDAO.updateTrangThai(kyLuongId, coSoId, KyLuong.DA_PHAT);
    }

    /** Manager bấm "Đã chuyển khoản" cho một nhân viên. false nếu dòng lương không thuộc cơ sở. */
    public boolean xacNhanDaChuyenKhoan(int bangLuongId, int coSoId) throws Exception {
        BangLuong bl = bangDAO.findById(bangLuongId, coSoId);
        if (bl == null) return false;
        bangDAO.updateTrangThai(bangLuongId, BangLuong.DA_CHUYEN);
        return true;
    }

    /** Kỳ đến hạn phát lương hôm nay, để hiển thị banner nhắc. Null nếu không có. */
    public KyLuong kyPhatLuongHomNay(int coSoId) throws Exception {
        return kyDAO.findKyPhatLuongHomNay(coSoId, LocalDate.now());
    }

    /** Lịch sử bảng lương của một nhân viên (dùng cho trang staff/guard). */
    public List<BangLuong> lichSuLuongCuaToi(int accountId) throws Exception {
        return bangDAO.listByAccount(accountId);
    }

    /**
     * Bỏ dấu tiếng Việt cho nội dung chuyển khoản — app ngân hàng thường từ chối hoặc
     * hiển thị sai ký tự có dấu trong trường nội dung.
     */
    private static String khongDau(String s) {
        if (s == null) return "";
        String norm = Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd').replace('Đ', 'D');
        return norm.replaceAll("[^A-Za-z0-9 ]", "").trim();
    }
}
