package org.example.dao.impl;

import org.example.dao.GhepKeoDAO;
import org.example.model.GhepKeo;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JDBC impl cho GhepKeoDAO — dùng schema hiện có (GhepKeo, ChiTietGhepKeo) mà không cần migration bắt buộc.
 * Metadata phụ (số người cần tìm, hình thức duyệt) được encode trong cột MoTa dưới dạng
 * JSON prefix `[VS_META]{...}[/VS_META]` để tránh phụ thuộc vào cột mới.
 */
public class GhepKeoDAOImpl implements GhepKeoDAO {

    private static final Logger LOGGER = Logger.getLogger(GhepKeoDAOImpl.class.getName());

    // Trạng thái GhepKeo
    public static final String STATUS_OPEN = "Đang mở";
    public static final String STATUS_FULL = "Đã đủ người";
    public static final String STATUS_CANCELLED = "Đã hủy";
    public static final String STATUS_COMPLETED = "Đã hoàn thành";
    public static final String STATUS_CLOSED = "Đã đóng";

    // Trạng thái ChiTietGhepKeo
    public static final String P_STATUS_PENDING = "Chờ duyệt";
    public static final String P_STATUS_JOINED = "Đã tham gia";
    public static final String P_STATUS_REJECTED = "Đã từ chối";
    public static final String P_STATUS_LEFT = "Đã rời";

    private static final String META_PREFIX = "[VS_META]";
    private static final String META_SUFFIX = "[/VS_META]";

    // =========================================================================
    // Metadata encode/decode
    // =========================================================================

    /** Bọc metadata (soNguoiCanTim, hinhThucDuyet) + note thành chuỗi MoTa lưu DB. */
    public static String encodeMoTa(int soNguoiCanTim, String hinhThucDuyet, String note) {
        return encodeMoTa(soNguoiCanTim, hinhThucDuyet, note, 0);
    }

    /**
     * Bọc metadata (soNguoiCanTim, hinhThucDuyet, minReputation) + note thành chuỗi MoTa lưu DB.
     * minReputation = 0 nghĩa là không yêu cầu uy tín tối thiểu.
     */
    public static String encodeMoTa(int soNguoiCanTim, String hinhThucDuyet, String note, int minReputation) {
        String approve = (hinhThucDuyet == null || hinhThucDuyet.isBlank()) ? "auto" : hinhThucDuyet;
        String safeNote = note == null ? "" : note;
        int minRep = Math.max(0, Math.min(100, minReputation));
        String meta = "{\"cap\":" + soNguoiCanTim + ",\"approve\":\"" + jsonEscape(approve) + "\",\"minRep\":" + minRep + "}";
        return META_PREFIX + meta + META_SUFFIX + safeNote;
    }

    private static String jsonEscape(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    /** Bóc metadata từ MoTa; đổ vào view. Nếu không có prefix → default cap=2, approve=auto, minRep=0. */
    public static void decodeMoTaInto(String moTa, GhepKeoView view) {
        view.soNguoiCanTim = 2;
        view.hinhThucDuyet = "auto";
        view.minReputation = 0;
        view.actualNote = moTa == null ? "" : moTa;
        if (moTa == null) return;
        int p1 = moTa.indexOf(META_PREFIX);
        int p2 = moTa.indexOf(META_SUFFIX);
        if (p1 == 0 && p2 > p1) {
            String json = moTa.substring(META_PREFIX.length(), p2);
            view.actualNote = moTa.substring(p2 + META_SUFFIX.length());
            // Parse tối giản — đọc cap, approve và minRep. Không dùng full JSON parser để giảm phụ thuộc.
            view.soNguoiCanTim = readIntField(json, "cap", 2);
            String approve = readStringField(json, "approve", "auto");
            if (!"auto".equalsIgnoreCase(approve) && !"manual".equalsIgnoreCase(approve)) approve = "auto";
            view.hinhThucDuyet = approve.toLowerCase();
            view.minReputation = Math.max(0, Math.min(100, readIntField(json, "minRep", 0)));
        }
    }

    private static int readIntField(String json, String field, int def) {
        String key = "\"" + field + "\":";
        int idx = json.indexOf(key);
        if (idx < 0) return def;
        int start = idx + key.length();
        StringBuilder sb = new StringBuilder();
        while (start < json.length() && (Character.isDigit(json.charAt(start)) || json.charAt(start) == '-')) {
            sb.append(json.charAt(start)); start++;
        }
        if (sb.length() == 0) return def;
        try { return Integer.parseInt(sb.toString()); } catch (NumberFormatException e) { return def; }
    }

    private static String readStringField(String json, String field, String def) {
        String key = "\"" + field + "\":\"";
        int idx = json.indexOf(key);
        if (idx < 0) return def;
        int start = idx + key.length();
        int end = json.indexOf('"', start);
        while (end > 0 && json.charAt(end - 1) == '\\') end = json.indexOf('"', end + 1);
        if (end <= start) return def;
        return json.substring(start, end).replace("\\\"", "\"").replace("\\\\", "\\");
    }

    // =========================================================================
    // CRUD
    // =========================================================================

    @Override
    public int create(GhepKeo keo) {
        String sql = "INSERT INTO matches(booking_id, creator_account_id, sport_id, description, skill_level, status) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, keo.getDatSanId());
            ps.setInt(2, keo.getAccountIdNguoiTao());
            if (keo.getMonTheThaoId() != null) ps.setInt(3, keo.getMonTheThaoId()); else ps.setNull(3, java.sql.Types.INTEGER);
            ps.setNString(4, keo.getMoTa() != null ? keo.getMoTa() : "");
            ps.setNString(5, keo.getTrinhDo() != null ? keo.getTrinhDo() : "");
            ps.setNString(6, keo.getTrangThai() != null ? keo.getTrangThai() : STATUS_OPEN);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "create GhepKeo failed", e);
        }
        return -1;
    }

    private static final String SELECT_VIEW_BASE =
            "SELECT g.match_id, g.booking_id, g.creator_account_id, g.sport_id, g.description, g.skill_level, g.status, " +
            "       tk.full_name AS TenNguoiTao, tk.reputation_score AS DiemUyTinNguoiTao, " +
            "       mtt.sport_name AS TenMonTheThao, " +
            "       l.booking_date, l.start_time, l.end_time, l.status AS TrangThaiBooking, " +
            "       s.court_id, s.court_name, s.facility_id, " +
            "       cs.facility_name, cs.address AS DiaChiCoSo, " +
            "       ls.type_name AS TenLoaiSan, " +
            "       (SELECT COUNT(*) FROM match_participants p WHERE p.match_id = g.match_id AND p.participation_status = N'" + P_STATUS_JOINED + "') AS SoNguoiThamGia " +
            "FROM matches g " +
            "LEFT JOIN accounts tk ON g.creator_account_id = tk.account_id " +
            "LEFT JOIN bookings l ON g.booking_id = l.booking_id " +
            "LEFT JOIN courts s ON l.court_id = s.court_id " +
            "LEFT JOIN facilities cs ON s.facility_id = cs.facility_id " +
            "LEFT JOIN court_types ls ON s.court_type_id = ls.court_type_id " +
            "LEFT JOIN sports mtt ON g.sport_id = mtt.sport_id ";

    private GhepKeoView mapView(ResultSet rs) throws SQLException {
        GhepKeoView v = new GhepKeoView();
        v.keoId = rs.getInt("match_id");
        v.datSanId = rs.getInt("booking_id");
        v.accountIdNguoiTao = rs.getInt("creator_account_id");
        Object monVal = rs.getObject("sport_id");
        v.monTheThaoId = monVal == null ? null : (int) monVal;
        v.tenMonTheThao = rs.getString("TenMonTheThao");
        v.moTa = rs.getString("description");
        v.trinhDo = rs.getString("skill_level");
        v.trangThai = rs.getString("status");
        v.tenNguoiTao = rs.getString("TenNguoiTao");
        Object dutVal = rs.getObject("DiemUyTinNguoiTao");
        v.diemUyTinNguoiTao = dutVal == null ? null : (int) dutVal;
        java.sql.Date ngay = rs.getDate("booking_date");
        v.ngayDat = ngay == null ? null : ngay.toLocalDate();
        java.sql.Time bd = rs.getTime("start_time");
        v.gioBatDau = bd == null ? null : bd.toString().substring(0, 5);
        java.sql.Time kt = rs.getTime("end_time");
        v.gioKetThuc = kt == null ? null : kt.toString().substring(0, 5);
        v.trangThaiBooking = rs.getString("TrangThaiBooking");
        v.sanId = rs.getInt("court_id");
        v.tenSan = rs.getString("court_name");
        v.coSoId = rs.getInt("facility_id");
        v.tenCoSo = rs.getString("facility_name");
        v.diaChiCoSo = rs.getString("DiaChiCoSo");
        v.tenLoaiSan = rs.getString("TenLoaiSan");
        v.soNguoiThamGia = rs.getInt("SoNguoiThamGia");
        decodeMoTaInto(v.moTa, v);
        return v;
    }

    @Override
    public GhepKeoView getViewById(int keoId) {
        String sql = SELECT_VIEW_BASE + " WHERE g.match_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapView(rs);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "getViewById failed keoId=" + keoId, e);
        }
        return null;
    }

    @Override
    public List<GhepKeoView> listOpenMatches(Integer coSoId, Integer monTheThaoId, LocalDate fromDate, LocalDate toDate) {
        StringBuilder sql = new StringBuilder(SELECT_VIEW_BASE);
        sql.append(" WHERE g.status = N'").append(STATUS_OPEN).append("' ");
        // Chỉ kèo có booking hợp lệ + đã được quản lý xác nhận + ngày chưa qua
        sql.append(" AND l.DatSanID IS NOT NULL AND l.TrangThai = N'Đã xác nhận' AND l.NgayDat >= CAST(GETDATE() AS DATE) ");
        List<Object> params = new ArrayList<>();
        if (coSoId != null) { sql.append(" AND s.CoSoID = ?"); params.add(coSoId); }
        if (monTheThaoId != null) { sql.append(" AND g.MonTheThaoID = ?"); params.add(monTheThaoId); }
        if (fromDate != null) { sql.append(" AND l.NgayDat >= ?"); params.add(Date.valueOf(fromDate)); }
        if (toDate != null) { sql.append(" AND l.NgayDat <= ?"); params.add(Date.valueOf(toDate)); }
        sql.append(" ORDER BY l.booking_date ASC, l.start_time ASC");

        List<GhepKeoView> out = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
                else if (p instanceof Date) ps.setDate(i + 1, (Date) p);
                else ps.setObject(i + 1, p);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    GhepKeoView v = mapView(rs);
                    // Loại bỏ kèo đã đủ người (server-side filter dựa trên soNguoiCanTim)
                    if (v.soNguoiThamGia < v.soNguoiCanTim) {
                        out.add(v);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "listOpenMatches failed", e);
        }
        return out;
    }

    @Override
    public List<GhepKeoView> listByCreator(int accountId) {
        String sql = SELECT_VIEW_BASE + " WHERE g.creator_account_id = ? ORDER BY g.match_id DESC";
        return runViewQuery(sql, ps -> ps.setInt(1, accountId));
    }

    @Override
    public List<GhepKeoView> listByParticipant(int accountId) {
        String sql = SELECT_VIEW_BASE +
                " WHERE g.match_id IN (SELECT p.match_id FROM match_participants p WHERE p.participant_account_id = ? AND p.participation_status <> N'" + P_STATUS_LEFT + "') " +
                " ORDER BY l.booking_date DESC";
        return runViewQuery(sql, ps -> ps.setInt(1, accountId));
    }

    private interface PsSetter { void set(PreparedStatement ps) throws SQLException; }
    private List<GhepKeoView> runViewQuery(String sql, PsSetter setter) {
        List<GhepKeoView> out = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.set(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapView(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "runViewQuery failed", e);
        }
        return out;
    }

    @Override
    public boolean updateStatusIfOwner(int keoId, String newStatus, int ownerAccountId) {
        String sql = "UPDATE matches SET status = ? WHERE match_id = ? AND creator_account_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, newStatus);
            ps.setInt(2, keoId);
            ps.setInt(3, ownerAccountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "updateStatusIfOwner failed keoId=" + keoId, e);
            return false;
        }
    }

    @Override
    public int addParticipant(int keoId, int accountId, String status, String position) throws Exception {
        // 1 transaction: lock (SELECT ... WITH UPDLOCK) → check trạng thái + capacity → insert
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Bước 1: khoá row GhepKeo để tránh race condition
                int capacity;
                int accepted;
                String trangThaiKeo;
                int accountIdOwner;
                String sqlLock = "SELECT g.creator_account_id, g.description, g.status, " +
                        "       (SELECT COUNT(*) FROM match_participants p WHERE p.match_id = g.match_id AND p.participation_status = N'" + P_STATUS_JOINED + "') AS Accepted " +
                        "FROM matches g WITH (UPDLOCK, ROWLOCK) WHERE g.match_id = ?";
                try (PreparedStatement psLock = conn.prepareStatement(sqlLock)) {
                    psLock.setInt(1, keoId);
                    try (ResultSet rs = psLock.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            throw new IllegalStateException("Kèo không tồn tại.");
                        }
                        accountIdOwner = rs.getInt("creator_account_id");
                        trangThaiKeo = rs.getString("status");
                        accepted = rs.getInt("Accepted");
                        String moTa = rs.getString("description");
                        GhepKeoView tmp = new GhepKeoView();
                        decodeMoTaInto(moTa, tmp);
                        capacity = tmp.soNguoiCanTim;
                    }
                }

                if (accountId == accountIdOwner) {
                    conn.rollback();
                    throw new IllegalStateException("Bạn là chủ kèo, không cần xin tham gia.");
                }
                if (!STATUS_OPEN.equals(trangThaiKeo)) {
                    conn.rollback();
                    throw new IllegalStateException("Kèo hiện không nhận thêm người.");
                }
                if (accepted >= capacity) {
                    conn.rollback();
                    throw new IllegalStateException("Kèo đã đủ người.");
                }

                // Bước 2: kiểm tra đã tồn tại participant active của account này chưa
                String sqlCheck = "SELECT participant_id, participation_status FROM match_participants " +
                        "WHERE match_id = ? AND participant_account_id = ? AND participation_status IN (N'" + P_STATUS_JOINED + "', N'" + P_STATUS_PENDING + "')";
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                    psCheck.setInt(1, keoId); psCheck.setInt(2, accountId);
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            int existingId = rs.getInt("participant_id");
                            conn.rollback();
                            throw new IllegalStateException("Bạn đã tham gia hoặc đang chờ duyệt kèo này (mã " + existingId + ").");
                        }
                    }
                }

                // Bước 3: insert
                String sqlIns = "INSERT INTO match_participants(match_id, participant_account_id, participation_status, participation_position) VALUES (?, ?, ?, ?)";
                int newId = -1;
                try (PreparedStatement psIns = conn.prepareStatement(sqlIns, Statement.RETURN_GENERATED_KEYS)) {
                    psIns.setInt(1, keoId);
                    psIns.setInt(2, accountId);
                    psIns.setNString(3, status != null ? status : P_STATUS_JOINED);
                    psIns.setNString(4, position != null ? position : "");
                    psIns.executeUpdate();
                    try (ResultSet rs = psIns.getGeneratedKeys()) {
                        if (rs.next()) newId = rs.getInt(1);
                    }
                }

                // Bước 4: nếu vừa đủ người → set TrangThai = "Đã đủ người"
                if (P_STATUS_JOINED.equals(status) && (accepted + 1) >= capacity) {
                    try (PreparedStatement psUp = conn.prepareStatement(
                            "UPDATE matches SET status = ? WHERE match_id = ? AND status = ?")) {
                        psUp.setNString(1, STATUS_FULL);
                        psUp.setInt(2, keoId);
                        psUp.setNString(3, STATUS_OPEN);
                        psUp.executeUpdate();
                    }
                }

                conn.commit();
                return newId;
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                throw ex;
            }
        }
    }

    @Override
    public boolean updateParticipantStatus(int chiTietKeoId, String newStatus, int actorAccountId, boolean actorIsOwner) {
        String sql;
        if (actorIsOwner) {
            // Chủ kèo có thể duyệt/từ chối bất kỳ participant của kèo mình
            sql = "UPDATE match_participants SET participation_status = ? " +
                  "WHERE participant_id = ? AND match_id IN (SELECT match_id FROM matches WHERE creator_account_id = ?)";
        } else {
            // Người chơi chỉ có thể tự đổi trạng thái của chính mình sang "Đã rời"
            sql = "UPDATE match_participants SET participation_status = ? WHERE participant_id = ? AND participant_account_id = ?";
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, newStatus);
            ps.setInt(2, chiTietKeoId);
            ps.setInt(3, actorAccountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "updateParticipantStatus failed", e);
            return false;
        }
    }

    /**
     * [FIX-1] Duyệt yêu cầu tham gia với kiểm tra capacity trong cùng 1 transaction.
     * Tránh tình trạng chủ kèo duyệt vượt số lượng cho phép.
     * Sau khi duyệt đủ người, tự động chuyển kèo sang "Đã đủ người".
     */
    @Override
    public boolean approveParticipantWithCapacityCheck(int chiTietKeoId, int ownerAccountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Bước 1: Lấy KeoID và kiểm tra chủ kèo
                int keoId;
                String currentParticipantStatus;
                String sqlGetPart = "SELECT ct.match_id, ct.participation_status " +
                        "FROM match_participants ct " +
                        "JOIN matches g WITH (UPDLOCK, ROWLOCK) ON ct.match_id = g.match_id " +
                        "WHERE ct.participant_id = ? AND g.creator_account_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlGetPart)) {
                    ps.setInt(1, chiTietKeoId);
                    ps.setInt(2, ownerAccountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            throw new IllegalStateException("Không tìm thấy yêu cầu hoặc bạn không phải chủ kèo.");
                        }
                        keoId = rs.getInt("match_id");
                        currentParticipantStatus = rs.getString("participation_status");
                    }
                }

                if (!P_STATUS_PENDING.equals(currentParticipantStatus)) {
                    conn.rollback();
                    throw new IllegalStateException("Yêu cầu này không còn ở trạng thái chờ duyệt.");
                }

                // Bước 2: Đọc capacity và số người đã tham gia từ kèo
                int capacity;
                int accepted;
                String sqlKeo = "SELECT g.description, " +
                        "(SELECT COUNT(*) FROM match_participants p WHERE p.match_id = g.match_id AND p.participation_status = N'" + P_STATUS_JOINED + "') AS Accepted " +
                        "FROM matches g WHERE g.match_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlKeo)) {
                    ps.setInt(1, keoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            throw new IllegalStateException("Kèo không tồn tại.");
                        }
                        GhepKeoView tmp = new GhepKeoView();
                        decodeMoTaInto(rs.getString("description"), tmp);
                        capacity = tmp.soNguoiCanTim;
                        accepted = rs.getInt("Accepted");
                    }
                }

                if (accepted >= capacity) {
                    conn.rollback();
                    throw new IllegalStateException("Kèo đã đủ người (" + capacity + "/" + capacity + "), không thể duyệt thêm.");
                }

                // Bước 3: Cập nhật trạng thái participant → Đã tham gia
                String sqlUpdate = "UPDATE match_participants SET participation_status = ? WHERE participant_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setNString(1, P_STATUS_JOINED);
                    ps.setInt(2, chiTietKeoId);
                    ps.executeUpdate();
                }

                // Bước 4: Nếu vừa đủ người → chuyển kèo sang "Đã đủ người"
                if ((accepted + 1) >= capacity) {
                    String sqlClose = "UPDATE matches SET status = ? WHERE match_id = ? AND status = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sqlClose)) {
                        ps.setNString(1, STATUS_FULL);
                        ps.setInt(2, keoId);
                        ps.setNString(3, STATUS_OPEN);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                throw ex;
            }
        }
    }

    /**
     * [FIX-2] Người chơi rời kèo. Sau khi rời, nếu kèo đang ở "Đã đủ người"
     * mà số thành viên thực tế giảm xuống dưới capacity, tự động mở lại thành "Đang mở".
     */
    @Override
    public boolean leaveParticipantWithReopen(int chiTietKeoId, int accountId) {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Bước 1: Lấy KeoID của participant này và kiểm tra chủ sở hữu
                int keoId;
                String sqlGetPart = "SELECT ct.match_id FROM match_participants ct " +
                        "WHERE ct.participant_id = ? AND ct.participant_account_id = ? " +
                        "AND ct.participation_status IN (N'" + P_STATUS_JOINED + "', N'" + P_STATUS_PENDING + "')";
                try (PreparedStatement ps = conn.prepareStatement(sqlGetPart)) {
                    ps.setInt(1, chiTietKeoId);
                    ps.setInt(2, accountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        keoId = rs.getInt("match_id");
                    }
                }

                // Bước 2: Cập nhật participant → Đã rời
                String sqlLeave = "UPDATE match_participants SET participation_status = ? WHERE participant_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlLeave)) {
                    ps.setNString(1, P_STATUS_LEFT);
                    ps.setInt(2, chiTietKeoId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }

                // Bước 3: Đọc trạng thái kèo + capacity + số người còn lại
                String sqlKeo = "SELECT g.status, g.description, " +
                        "(SELECT COUNT(*) FROM match_participants p WHERE p.match_id = g.match_id AND p.participation_status = N'" + P_STATUS_JOINED + "') AS Accepted " +
                        "FROM matches g WHERE g.match_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlKeo)) {
                    ps.setInt(1, keoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String keoStatus = rs.getString("status");
                            int accepted = rs.getInt("Accepted");
                            GhepKeoView tmp = new GhepKeoView();
                            decodeMoTaInto(rs.getString("description"), tmp);
                            int capacity = tmp.soNguoiCanTim;

                            // Bước 4: Nếu kèo đang "Đã đủ người" và giờ còn thiếu → mở lại
                            if (STATUS_FULL.equals(keoStatus) && accepted < capacity) {
                                String sqlReopen = "UPDATE matches SET status = ? WHERE match_id = ? AND status = ?";
                                try (PreparedStatement psRe = conn.prepareStatement(sqlReopen)) {
                                    psRe.setNString(1, STATUS_OPEN);
                                    psRe.setInt(2, keoId);
                                    psRe.setNString(3, STATUS_FULL);
                                    psRe.executeUpdate();
                                }
                            }
                        }
                    }
                }

                conn.commit();
                return true;
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                LOGGER.log(Level.WARNING, "leaveParticipantWithReopen failed chiTietKeoId=" + chiTietKeoId, ex);
                return false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "leaveParticipantWithReopen connection failed", e);
            return false;
        }
    }


    @Override
    public int countAcceptedParticipants(int keoId) {
        String sql = "SELECT COUNT(*) FROM match_participants WHERE match_id = ? AND participation_status = N'" + P_STATUS_JOINED + "'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "countAcceptedParticipants failed", e);
        }
        return 0;
    }

    @Override
    public List<ChiTietGhepKeoView> listParticipants(int keoId) {
        String sql = "SELECT p.participant_id, p.match_id, p.participant_account_id, p.participation_status, p.participation_position, " +
                "       tk.full_name AS TenNguoiChoi, tk.reputation_score AS reputation_score " +
                "FROM match_participants p LEFT JOIN accounts tk ON p.participant_account_id = tk.account_id " +
                "WHERE p.match_id = ? ORDER BY p.participant_id ASC";
        List<ChiTietGhepKeoView> out = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChiTietGhepKeoView v = new ChiTietGhepKeoView();
                    v.chiTietKeoId = rs.getInt("participant_id");
                    v.keoId = rs.getInt("match_id");
                    v.accountId = rs.getInt("participant_account_id");
                    v.trangThaiThamGia = rs.getString("participation_status");
                    v.viTriThamGia = rs.getString("participation_position");
                    v.tenNguoiChoi = rs.getString("TenNguoiChoi");
                    Object dut = rs.getObject("reputation_score");
                    v.diemUyTin = dut == null ? null : (int) dut;
                    out.add(v);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "listParticipants failed", e);
        }
        return out;
    }

    @Override
    public ChiTietGhepKeoView getActiveParticipant(int keoId, int accountId) {
        String sql = "SELECT p.participant_id, p.match_id, p.participant_account_id, p.participation_status, p.participation_position, " +
                "       tk.full_name AS TenNguoiChoi, tk.reputation_score AS reputation_score " +
                "FROM match_participants p LEFT JOIN accounts tk ON p.participant_account_id = tk.account_id " +
                "WHERE p.match_id = ? AND p.participant_account_id = ? AND p.participation_status IN (N'" + P_STATUS_PENDING + "', N'" + P_STATUS_JOINED + "') " +
                "ORDER BY p.participant_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId); ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ChiTietGhepKeoView v = new ChiTietGhepKeoView();
                    v.chiTietKeoId = rs.getInt("participant_id");
                    v.keoId = rs.getInt("match_id");
                    v.accountId = rs.getInt("participant_account_id");
                    v.trangThaiThamGia = rs.getString("participation_status");
                    v.viTriThamGia = rs.getString("participation_position");
                    v.tenNguoiChoi = rs.getString("TenNguoiChoi");
                    Object dut = rs.getObject("reputation_score");
                    v.diemUyTin = dut == null ? null : (int) dut;
                    return v;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "getActiveParticipant failed", e);
        }
        return null;
    }

    // =========================================================================
    // Notifications: người tham gia kèo của chủ kèo
    // =========================================================================

    /**
     * Trả về tối đa 30 bản ghi ChiTietGhepKeo mới nhất của các kèo do ownerAccountId tạo
     * (trạng thái "Chờ duyệt" hoặc "Đã tham gia"), dùng để hiển thị thông báo trên header.
     * Vì bảng ChiTietGhepKeo không có cột timestamp, ta dùng ChiTietKeoID tăng tự nhiên làm proxy thời gian.
     */
    @Override
    public List<NotificationItem> listJoinNotifications(int ownerAccountId) {
        // Lấy 30 ChiTietGhepKeo mới nhất của các kèo mà ownerAccountId là chủ,
        // trạng thái Chờ duyệt hoặc Đã tham gia (không lấy rời/từ chối).
        String sql =
            "SELECT TOP 30 ct.participant_id, ct.match_id, ct.participation_status, " +
            "       tk.full_name AS TenNguoiChoi " +
            "FROM match_participants ct " +
            "JOIN matches g ON ct.match_id = g.match_id " +
            "JOIN accounts tk ON ct.participant_account_id = tk.account_id " +
            "WHERE g.creator_account_id = ? " +
            "  AND ct.participation_status IN (N'" + P_STATUS_PENDING + "', N'" + P_STATUS_JOINED + "', N'" + P_STATUS_LEFT + "') " +
            "ORDER BY ct.participant_id DESC";
        List<NotificationItem> out = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ownerAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NotificationItem item = new NotificationItem();
                    item.id = rs.getInt("participant_id");
                    item.keoId = rs.getInt("match_id");
                    item.tenNguoiChoi = rs.getString("TenNguoiChoi");
                    item.trangThai = rs.getString("participation_status");
                    // Dùng ChiTietKeoID để tạo "thời gian giả" — client chỉ cần relative label
                    // Không có cột ngày giờ nên để null, frontend sẽ hiển thị "Vừa xong" hoặc bỏ qua
                    item.thoiGian = null;
                    out.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "listJoinNotifications failed ownerAccountId=" + ownerAccountId, e);
        }
        return out;
    }
}
