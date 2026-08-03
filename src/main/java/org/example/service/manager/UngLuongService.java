package org.example.service.manager;

import org.example.dao.CauHinhLuongDAO;
import org.example.dao.YeuCauUngLuongDAO;
import org.example.dao.impl.CauHinhLuongDAOImpl;
import org.example.dao.impl.YeuCauUngLuongDAOImpl;
import org.example.model.CauHinhLuong;
import org.example.model.YeuCauUngLuong;
import org.example.util.LuongCalculator;

import java.math.BigDecimal;
import java.util.List;

/** Nghiệp vụ ứng lương: nhân viên gửi yêu cầu, manager duyệt/từ chối. */
public class UngLuongService {

    private final YeuCauUngLuongDAO ungDAO = new YeuCauUngLuongDAOImpl();
    private final CauHinhLuongDAO cauHinhDAO = new CauHinhLuongDAOImpl();

    /**
     * Nhân viên gửi yêu cầu ứng. accountId/coSoId PHẢI lấy từ session.
     *
     * @throws IllegalArgumentException nếu vi phạm hạn mức — message hiển thị thẳng cho nhân viên.
     */
    public int guiYeuCau(int accountId, int coSoId, BigDecimal soTien, String lyDo) throws Exception {
        CauHinhLuong ch = cauHinhDAO.findByAccount(accountId, coSoId);
        BigDecimal hanMuc = ch == null ? BigDecimal.ZERO : ch.getHanMucUng();
        BigDecimal daUng = ungDAO.tongDaDuyetChuaKhauTru(accountId);

        String loi = UngLuongValidator.kiemTra(soTien, hanMuc, daUng);
        if (loi != null) {
            throw new IllegalArgumentException(loi);
        }

        YeuCauUngLuong yc = new YeuCauUngLuong();
        yc.setAccountId(accountId);
        yc.setCoSoId(coSoId);
        yc.setSoTienUng(LuongCalculator.chuanHoa(soTien));
        yc.setLyDo(lyDo);
        yc.setTrangThai(YeuCauUngLuong.CHO_DUYET);
        return ungDAO.insert(yc);
    }

    public List<YeuCauUngLuong> lichSuCuaToi(int accountId) throws Exception {
        return ungDAO.listByAccount(accountId);
    }

    /** Hạn mức còn ứng được, hiển thị trên form để nhân viên biết trước khi nhập. Không âm. */
    public BigDecimal hanMucConLai(int accountId, int coSoId) throws Exception {
        CauHinhLuong ch = cauHinhDAO.findByAccount(accountId, coSoId);
        BigDecimal hanMuc = LuongCalculator.chuanHoa(ch == null ? null : ch.getHanMucUng());
        BigDecimal daUng = LuongCalculator.chuanHoa(ungDAO.tongDaDuyetChuaKhauTru(accountId));
        BigDecimal conLai = hanMuc.subtract(daUng);
        return conLai.signum() < 0 ? BigDecimal.ZERO : conLai;
    }

    public List<YeuCauUngLuong> danhSachChoManager(int coSoId, String trangThai) throws Exception {
        return ungDAO.listByCoSo(coSoId, trangThai);
    }

    /** false nếu yêu cầu không thuộc cơ sở hoặc đã được xử lý trước đó. */
    public boolean duyet(int id, int coSoId, int managerId, String ghiChu) throws Exception {
        return ungDAO.xuLy(id, coSoId, YeuCauUngLuong.DA_DUYET, ghiChu, managerId);
    }

    public boolean tuChoi(int id, int coSoId, int managerId, String ghiChu) throws Exception {
        return ungDAO.xuLy(id, coSoId, YeuCauUngLuong.TU_CHOI, ghiChu, managerId);
    }

    /** Nhân viên tự huỷ yêu cầu của chính mình; false nếu không phải chủ sở hữu hoặc đã xử lý. */
    public boolean huy(int id, int accountId) throws Exception {
        return ungDAO.huyBoiNhanVien(id, accountId);
    }
}
