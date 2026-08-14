package org.example.service.customer;

import org.example.dao.CoSoDAO;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.CoSo;
import org.example.model.KhuyenMai;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Truy vấn danh mục công khai (môn thể thao / cơ sở / sân) cho Customer.
 *
 * Dùng CHUNG cho Web và Mobile: điều kiện lọc cơ sở đi qua {@link CoSoDAO#searchCoSo} — đúng
 * bộ điều kiện mà trang tìm kiếm Web (/customer/tim-kiem) đang dùng — nên hai nền tảng không
 * bao giờ trả ra danh sách cơ sở khác nhau.
 *
 * Các truy vấn tổng hợp (môn thể thao của cơ sở, giá thấp nhất, số sân sẵn sàng) được gom thành
 * MỘT câu lệnh cho toàn bộ danh sách để tránh N+1.
 */
public class CustomerCatalogService {

    public static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private final CoSoDAO coSoDAO = new CoSoDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();

    /** Số liệu tổng hợp của một cơ sở, tính sẵn theo lô. */
    public static class FacilityStats {
        public final Set<String> sportNames = new LinkedHashSet<>();
        public final Set<Integer> sportIds = new LinkedHashSet<>();
        public double minPrice = 0;
        public int readyCourtCount = 0;
    }

    public static class SportSummary {
        public int sportId;
        public String name;
        public int courtCount;
        public int facilityCount;
    }

    // ------------------------------------------------------------------
    // Môn thể thao
    // ------------------------------------------------------------------

    /**
     * Môn thể thao thực sự khả dụng: có ít nhất một sân chưa xóa thuộc một cơ sở đang vận hành.
     * Không trả môn "rỗng" để app không dẫn khách vào màn hình không có sân nào.
     */
    public List<SportSummary> listAvailableSports() {
        String sql = "SELECT mt.MonTheThaoID, mt.TenMon, "
                + "       COUNT(DISTINCT s.SanID)  AS CourtCount, "
                + "       COUNT(DISTINCT s.CoSoID) AS FacilityCount "
                + "FROM MonTheThao mt "
                + "JOIN LoaiSan ls ON ls.MonTheThaoID = mt.MonTheThaoID AND ISNULL(ls.IsDeleted, 0) = 0 "
                + "JOIN San s      ON s.LoaiSanID = ls.LoaiSanID AND ISNULL(s.IsDeleted, 0) = 0 "
                + "JOIN CoSo c     ON c.CoSoID = s.CoSoID AND ISNULL(c.IsDeleted, 0) = 0 "
                + "                AND c.TrangThai NOT IN (N'Chờ duyệt', N'Từ chối') "
                + "GROUP BY mt.MonTheThaoID, mt.TenMon "
                + "HAVING COUNT(DISTINCT s.SanID) > 0 "
                + "ORDER BY COUNT(DISTINCT s.SanID) DESC, mt.TenMon";
        List<SportSummary> out = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SportSummary s = new SportSummary();
                s.sportId = rs.getInt("MonTheThaoID");
                s.name = rs.getString("TenMon");
                s.courtCount = rs.getInt("CourtCount");
                s.facilityCount = rs.getInt("FacilityCount");
                out.add(s);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải danh sách môn thể thao.", e);
        }
        return out;
    }

    public List<MonTheThao> allSports() {
        return loaiSanDAO.getAllMonTheThao();
    }

    // ------------------------------------------------------------------
    // Cơ sở
    // ------------------------------------------------------------------

    /** Cùng bộ điều kiện với trang tìm kiếm Web. */
    public List<CoSo> searchFacilities(String keyword, Integer sportId) {
        return coSoDAO.searchCoSo(keyword, sportId);
    }

    public CoSo findFacility(int facilityId) {
        CoSo cs = coSoDAO.getCoSoById(facilityId);
        if (cs == null) return null;
        if (cs.isDeleted()) return null;
        if ("Chờ duyệt".equals(cs.getTrangThai()) || "Từ chối".equals(cs.getTrangThai())) return null;
        return cs;
    }

    /** Một truy vấn duy nhất cho toàn bộ danh sách cơ sở — không N+1. */
    public Map<Integer, FacilityStats> facilityStats(Collection<Integer> facilityIds) {
        Map<Integer, FacilityStats> result = new HashMap<>();
        if (facilityIds == null || facilityIds.isEmpty()) return result;

        String placeholders = String.join(",", java.util.Collections.nCopies(facilityIds.size(), "?"));
        String sql = "SELECT s.CoSoID, s.TrangThai AS SanTrangThai, mt.MonTheThaoID, mt.TenMon, ls.GiaKhongDen "
                + "FROM San s "
                + "JOIN LoaiSan ls   ON ls.LoaiSanID = s.LoaiSanID AND ISNULL(ls.IsDeleted, 0) = 0 "
                + "JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID "
                + "WHERE ISNULL(s.IsDeleted, 0) = 0 AND s.CoSoID IN (" + placeholders + ")";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Integer id : facilityIds) ps.setInt(i++, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int coSoId = rs.getInt("CoSoID");
                    FacilityStats st = result.computeIfAbsent(coSoId, k -> new FacilityStats());
                    st.sportNames.add(rs.getString("TenMon"));
                    st.sportIds.add(rs.getInt("MonTheThaoID"));
                    double gia = rs.getDouble("GiaKhongDen");
                    if (gia > 0 && (st.minPrice == 0 || gia < st.minPrice)) st.minPrice = gia;
                    if ("Sẵn sàng".equals(rs.getString("SanTrangThai"))) st.readyCourtCount++;
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải thông tin tổng hợp cơ sở.", e);
        }
        return result;
    }

    /** Khuyến mãi công khai còn hiệu lực, gom theo CoSoID (một truy vấn cho cả danh sách). */
    public Map<Integer, List<KhuyenMai>> publicPromotions(Collection<Integer> facilityIds) {
        Map<Integer, List<KhuyenMai>> byFacility = new LinkedHashMap<>();
        if (facilityIds == null || facilityIds.isEmpty()) return byFacility;
        for (KhuyenMai km : khuyenMaiDAO.findPublicActiveByCoSoIds(facilityIds, java.time.LocalDate.now(VN_ZONE))) {
            if (km.getCoSoID() == null) continue;
            byFacility.computeIfAbsent(km.getCoSoID(), k -> new ArrayList<>()).add(km);
        }
        return byFacility;
    }

    // ------------------------------------------------------------------
    // Sân
    // ------------------------------------------------------------------

    /**
     * Sân của một cơ sở mà Customer được phép đặt: chưa xóa, loại sân chưa xóa, không ở trạng thái
     * bảo trì/tạm đóng, và (nếu có sportId) đúng môn thể thao.
     */
    public List<San> listBookableCourts(int facilityId, Integer sportId) {
        Map<Integer, LoaiSan> courtTypes = courtTypeMap();
        List<San> out = new ArrayList<>();
        for (San s : sanDAO.getSansByCoSo(facilityId)) {
            LoaiSan ls = courtTypes.get(s.getLoaiSanID());
            if (ls == null) continue;                                  // loại sân đã xóa mềm
            if (sportId != null && ls.getMonTheThaoID() != sportId) continue;
            if (!"Sẵn sàng".equals(s.getTrangThai()) && !"Đang sử dụng".equals(s.getTrangThai())) continue;
            out.add(s);
        }
        out.sort(Comparator.comparing(San::getTenSan, Comparator.nullsLast(String::compareTo)));
        return out;
    }

    /** Map LoaiSanID -> LoaiSan (chỉ loại sân chưa xóa mềm). */
    public Map<Integer, LoaiSan> courtTypeMap() {
        Map<Integer, LoaiSan> map = new HashMap<>();
        for (LoaiSan ls : loaiSanDAO.getAllLoaiSan()) {
            map.put(ls.getLoaiSanID(), ls);
        }
        return map;
    }

    /** Map MonTheThaoID -> tên môn. */
    public Map<Integer, String> sportNameMap() {
        Map<Integer, String> map = new HashMap<>();
        for (MonTheThao m : loaiSanDAO.getAllMonTheThao()) {
            map.put(m.getMonTheThaoID(), m.getTenMon());
        }
        return map;
    }

    public San findCourt(int courtId) {
        San san = sanDAO.getSanById(courtId);
        if (san == null || san.isDeleted()) return null;
        return san;
    }

    /** Thông tin hiển thị của một sân kèm cơ sở — dùng để dựng BookingDto mà không N+1. */
    public static class CourtContext {
        public int courtId;
        public String courtName;
        public String courtImage;
        public int facilityId;
        public String facilityName;
        public String facilityAddress;
        public String facilityImage;
        public String sportName;
    }

    /** Một truy vấn duy nhất cho toàn bộ danh sách sân (dùng khi dựng lịch sử đặt sân). */
    public Map<Integer, CourtContext> courtContexts(Collection<Integer> courtIds) {
        Map<Integer, CourtContext> out = new HashMap<>();
        if (courtIds == null || courtIds.isEmpty()) return out;
        String placeholders = String.join(",", java.util.Collections.nCopies(courtIds.size(), "?"));
        String sql = "SELECT s.SanID, s.TenSan, s.HinhAnh AS SanHinhAnh, "
                + "       c.CoSoID, c.TenCoSo, c.DiaChi, c.HinhAnh AS CoSoHinhAnh, mt.TenMon "
                + "FROM San s "
                + "LEFT JOIN CoSo c        ON c.CoSoID = s.CoSoID "
                + "LEFT JOIN LoaiSan ls    ON ls.LoaiSanID = s.LoaiSanID "
                + "LEFT JOIN MonTheThao mt ON mt.MonTheThaoID = ls.MonTheThaoID "
                + "WHERE s.SanID IN (" + placeholders + ")";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Integer id : courtIds) ps.setInt(i++, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CourtContext ctx = new CourtContext();
                    ctx.courtId = rs.getInt("SanID");
                    ctx.courtName = rs.getString("TenSan");
                    ctx.courtImage = rs.getString("SanHinhAnh");
                    ctx.facilityId = rs.getInt("CoSoID");
                    ctx.facilityName = rs.getString("TenCoSo");
                    ctx.facilityAddress = rs.getString("DiaChi");
                    ctx.facilityImage = rs.getString("CoSoHinhAnh");
                    ctx.sportName = rs.getString("TenMon");
                    out.put(ctx.courtId, ctx);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải thông tin sân.", e);
        }
        return out;
    }

    // ------------------------------------------------------------------
    // Tiện ích giờ mở cửa
    // ------------------------------------------------------------------

    /**
     * Đang mở cửa tại thời điểm hiện tại (Asia/Ho_Chi_Minh), hỗ trợ ca qua đêm. Giữ đúng hành vi
     * của MapApiServlet: thiếu cấu hình giờ thì KHÔNG tự khẳng định là đang mở.
     */
    public static boolean isOpenNow(LocalTime open, LocalTime close) {
        if (open == null || close == null) return false;
        LocalTime now = ZonedDateTime.now(VN_ZONE).toLocalTime();
        if (open.equals(close)) return true;
        if (open.isBefore(close)) return !now.isBefore(open) && now.isBefore(close);
        return !now.isBefore(open) || now.isBefore(close);
    }

    /** Haversine — khoảng cách great-circle, km (cùng công thức với bản đồ Web). */
    public static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
