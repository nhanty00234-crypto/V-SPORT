package org.example.service;

import org.example.dao.YeuCauNghiDAO;
import org.example.dao.impl.YeuCauNghiDAOImpl;
import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.ThongBaoDAO;
import org.example.dao.impl.ThongBaoDAOImpl;
import org.example.model.YeuCauNghi;
import org.example.model.ThongBao;

import java.time.LocalDate;
import java.util.List;

/**
 * Service layer cho YeuCauNghi
 * Xử lý business logic liên quan đến yêu cầu nghỉ phép
 */
public class YeuCauNghiService {
    private final YeuCauNghiDAO yeuCauNghiDAO;
    private final CaLamViecDAO caLamViecDAO;
    private final ThongBaoDAO thongBaoDAO;

    public YeuCauNghiService() {
        this.yeuCauNghiDAO = new YeuCauNghiDAOImpl();
        this.caLamViecDAO = new CaLamViecDAOImpl();
        this.thongBaoDAO = new ThongBaoDAOImpl();
    }

    public YeuCauNghiService(YeuCauNghiDAO yeuCauNghiDAO, CaLamViecDAO caLamViecDAO, ThongBaoDAO thongBaoDAO) {
        this.yeuCauNghiDAO = yeuCauNghiDAO;
        this.caLamViecDAO = caLamViecDAO;
        this.thongBaoDAO = thongBaoDAO;
    }

    /**
     * Tạo yêu cầu nghỉ mới
     */
    public boolean createYeuCauNghi(YeuCauNghi yeuCauNghi) {
        // Validation
        if (yeuCauNghi.getAccountID() <= 0) {
            throw new IllegalArgumentException("AccountID không hợp lệ");
        }
        if (yeuCauNghi.getCoSoID() <= 0) {
            throw new IllegalArgumentException("CoSoID không hợp lệ");
        }
        if (yeuCauNghi.getNgayNghi() == null) {
            throw new IllegalArgumentException("Ngày nghỉ không được để trống");
        }
        if (yeuCauNghi.getLoaiNghi() == null || yeuCauNghi.getLoaiNghi().isEmpty()) {
            throw new IllegalArgumentException("Loại nghỉ không được để trống");
        }
        if (yeuCauNghi.getLyDo() == null || yeuCauNghi.getLyDo().trim().isEmpty()) {
            throw new IllegalArgumentException("Lý do không được để trống");
        }

        // Kiểm tra ngày nghỉ không được trong quá khứ (trừ khi là hủy)
        LocalDate today = LocalDate.now();
        if (yeuCauNghi.getNgayNghi().isBefore(today) && !"DaHuy".equals(yeuCauNghi.getTrangThai())) {
            throw new IllegalArgumentException("Ngày nghỉ không được trong quá khứ");
        }

        // Kiểm tra xem đã có yêu cầu nghỉ vào ngày này chưa
        if (yeuCauNghiDAO.existsByAccountIDAndNgayNghi(yeuCauNghi.getAccountID(), yeuCauNghi.getNgayNghi())) {
            throw new IllegalArgumentException("Bạn đã có yêu cầu nghỉ vào ngày này rồi");
        }

        // Đặt trạng thái mặc định là "ChoDuyet"
        yeuCauNghi.setTrangThai("ChoDuyet");
        yeuCauNghi.setNgayGui(java.time.LocalDateTime.now());

        return yeuCauNghiDAO.insert(yeuCauNghi) > 0;
    }

    /**
     * Lấy yêu cầu nghỉ theo ID
     */
    public YeuCauNghi getYeuCauNghiById(int id) {
        return yeuCauNghiDAO.findById(id);
    }

    /**
     * Lấy tất cả yêu cầu nghỉ
     */
    public List<YeuCauNghi> getAllYeuCauNghi() {
        return yeuCauNghiDAO.findAll();
    }

    /**
     * Lấy tất cả yêu cầu nghỉ của một cơ sở (có thể lọc theo trạng thái)
     */
    public List<YeuCauNghi> getYeuCauNghiByCoSo(int coSoID, String trangThai) {
        if (coSoID <= 0) {
            throw new IllegalArgumentException("CoSoID không hợp lệ");
        }
        if (trangThai == null || trangThai.isEmpty()) {
            return yeuCauNghiDAO.findByCoSoID(coSoID);
        } else {
            return yeuCauNghiDAO.findByCoSoIDAndTrangThai(coSoID, trangThai);
        }
    }

    /**
     * Lấy danh sách yêu cầu nghỉ của một nhân viên
     */
    public List<YeuCauNghi> getYeuCauNghiByAccount(int accountID) {
        if (accountID <= 0) {
            throw new IllegalArgumentException("AccountID không hợp lệ");
        }
        return yeuCauNghiDAO.findByAccountID(accountID);
    }

    /**
     * Lấy danh sách yêu cầu nghỉ của một nhân viên theo trạng thái
     */
    public List<YeuCauNghi> getYeuCauNghiByAccountAndStatus(int accountID, String trangThai) {
        if (accountID <= 0) {
            throw new IllegalArgumentException("AccountID không hợp lệ");
        }
        if (trangThai == null || trangThai.isEmpty()) {
            return getYeuCauNghiByAccount(accountID);
        }
        return yeuCauNghiDAO.findByAccountIDAndTrangThai(accountID, trangThai);
    }

    /**
     * Lấy yêu cầu nghỉ sắp tới của một nhân viên
     */
    public List<YeuCauNghi> getUpcomingYeuCauNghiByAccount(int accountID) {
        if (accountID <= 0) {
            throw new IllegalArgumentException("AccountID không hợp lệ");
        }
        return yeuCauNghiDAO.findUpcomingByAccountID(accountID);
    }

    /**
     * Lấy danh sách yêu cầu chờ duyệt của một cơ sở
     */
    public List<YeuCauNghi> getPendingYeuCauNghiByCoSo(int coSoID) {
        if (coSoID <= 0) {
            throw new IllegalArgumentException("CoSoID không hợp lệ");
        }
        return yeuCauNghiDAO.findByCoSoIDAndTrangThai(coSoID, "ChoDuyet");
    }

    /**
     * Đếm số lượng yêu cầu chờ duyệt của một cơ sở
     */
    public int countPendingYeuCauNghiByCoSo(int coSoID) {
        if (coSoID <= 0) {
            throw new IllegalArgumentException("CoSoID không hợp lệ");
        }
        return yeuCauNghiDAO.countPendingByCoSoID(coSoID);
    }

    /**
     * Phê duyệt yêu cầu nghỉ
     * - Cập nhật trạng thái thành "DaDuyet"
     * - Ghi chú xử lý
     * - Ghi log audit (đã có trigger)
     * - Tự động xóa ca làm của nhân viên vào ngày nghỉ
     * - Gửi thông báo cho nhân viên
     */
    public boolean approveYeuCauNghi(int yeuCauNghiID, int quanLyID, String ghiChuQuanLy) {
        if (quanLyID <= 0) {
            throw new IllegalArgumentException("Quản lý ID không hợp lệ");
        }

        YeuCauNghi ycn = yeuCauNghiDAO.findById(yeuCauNghiID);
        if (ycn == null) {
            throw new IllegalArgumentException("Yêu cầu nghỉ không tồn tại");
        }

        if (!"ChoDuyet".equals(ycn.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu đã được xử lý trước đó");
        }

        // Cập nhật trạng thái
        ycn.setTrangThai("DaDuyet");
        ycn.setGhiChuQuanLy(ghiChuQuanLy);
        ycn.setNgayXuLy(java.time.LocalDateTime.now());
        ycn.setXuLyBy(quanLyID);

        boolean success = yeuCauNghiDAO.update(ycn);

        if (success) {
            // Tự động xóa ca làm của nhân viên vào ngày nghỉ (nếu có)
            caLamViecDAO.deleteByAccountIDAndNgayLam(ycn.getAccountID(), ycn.getNgayNghi());

            // Gửi thông báo cho nhân viên
            String tieuDe = "Yêu cầu nghỉ của bạn đã được phê duyệt";
            String noiDung = String.format("Yêu cầu nghỉ %s ngày %s đã được quản lý phê duyệt.",
                                          ycn.getLoaiNghi(), ycn.getNgayNghi().toString());
            ThongBao thongBao = new ThongBao(ycn.getAccountID(), tieuDe, noiDung, "YeuCauNghi");
            thongBaoDAO.insert(thongBao);
        }

        return success;
    }

    /**
     * Từ chối yêu cầu nghỉ
     */
    public boolean rejectYeuCauNghi(int yeuCauNghiID, int quanLyID, String ghiChuQuanLy) {
        if (quanLyID <= 0) {
            throw new IllegalArgumentException("Quản lý ID không hợp lệ");
        }

        YeuCauNghi ycn = yeuCauNghiDAO.findById(yeuCauNghiID);
        if (ycn == null) {
            throw new IllegalArgumentException("Yêu cầu nghỉ không tồn tại");
        }

        if (!"ChoDuyet".equals(ycn.getTrangThai())) {
            throw new IllegalArgumentException("Yêu cầu đã được xử lý trước đó");
        }

        ycn.setTrangThai("TuChoi");
        ycn.setGhiChuQuanLy(ghiChuQuanLy);
        ycn.setNgayXuLy(java.time.LocalDateTime.now());
        ycn.setXuLyBy(quanLyID);

        boolean success = yeuCauNghiDAO.update(ycn);

        if (success) {
            // Gửi thông báo cho nhân viên
            String tieuDe = "Yêu cầu nghỉ của bạn đã bị từ chối";
            String noiDung = String.format("Yêu cầu nghỉ %s ngày %s đã bị quản lý từ chối. Lý do: %s",
                                          ycn.getLoaiNghi(), ycn.getNgayNghi().toString(),
                                          ghiChuQuanLy != null ? ghiChuQuanLy : "Không có lý do");
            ThongBao thongBao = new ThongBao(ycn.getAccountID(), tieuDe, noiDung, "YeuCauNghi");
            thongBaoDAO.insert(thongBao);
        }

        return success;
    }

    /**
     * Hủy yêu cầu nghỉ (chỉ nhân viên tạo mới được hủy khi trạng thái là "ChoDuyet")
     */
    public boolean cancelYeuCauNghi(int yeuCauNghiID, int accountID) {
        YeuCauNghi ycn = yeuCauNghiDAO.findById(yeuCauNghiID);
        if (ycn == null) {
            throw new IllegalArgumentException("Yêu cầu nghỉ không tồn tại");
        }

        if (ycn.getAccountID() != accountID) {
            throw new IllegalArgumentException("Bạn không có quyền hủy yêu cầu này");
        }

        if (!"ChoDuyet".equals(ycn.getTrangThai())) {
            throw new IllegalArgumentException("Chỉ có thể hủy yêu cầu đang chờ duyệt");
        }

        ycn.setTrangThai("DaHuy");
        return yeuCauNghiDAO.update(ycn);
    }

    /**
     * Kiểm tra xem một nhân viên đã có yêu cầu nghỉ vào ngày nhất định chưa
     */
    public boolean hasYeuCauNghiOnDate(int accountID, LocalDate ngayNghi) {
        return yeuCauNghiDAO.existsByAccountIDAndNgayNghi(accountID, ngayNghi);
    }
}
