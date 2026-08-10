package org.example.dao.impl;

import org.example.dao.TeamMatchDAO;
import org.example.dto.TeamChallengeDTO;
import org.example.dto.TeamMatchSummaryDTO;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Xem javadoc TeamMatchDAO. Các hằng trạng thái dưới đây PHẢI khớp đúng
 * literal Vietnamese string mà GhepKeoDAOImpl đang dùng cho GhepKeo.TrangThai
 * / ChiTietGhepKeo.TrangThaiThamGia — không có CHECK constraint ở DB, so
 * khớp là bắt buộc để 2 domain (kèo cá nhân / kèo đội) đọc chung một cột.
 */
public class TeamMatchDAOImpl implements TeamMatchDAO {

    private static final String KEO_STATUS_OPEN = "Đang mở";
    private static final String KEO_STATUS_FULL = "Đã đủ người";
    private static final String KEO_STATUS_CANCELLED = "Đã hủy";

    private static final String P_STATUS_PENDING = "Chờ duyệt";
    private static final String P_STATUS_JOINED = "Đã tham gia";
    private static final String P_STATUS_REJECTED = "Đã từ chối";

    private static final String SELECT_SUMMARY_BASE =
            "SELECT g.match_id, g.creator_team_id, t.team_name AS TeamNameNguoiTao, g.booking_id, " +
                    "l.booking_date, l.start_time, l.end_time, s.court_name, c.facility_name, c.address, " +
                    "g.sport_id, mt.sport_name, g.skill_level, g.status, g.description AS Note, " +
                    "opp.team_id AS OpponentTeamId, opp.team_name AS OpponentTeamName, " +
                    "(SELECT COUNT(*) FROM match_participants p WHERE p.match_id = g.match_id AND p.participation_status = N'" + P_STATUS_PENDING + "') AS PendingChallengeCount " +
                    "FROM matches g " +
                    "JOIN teams t ON t.team_id = g.creator_team_id " +
                    "JOIN bookings l ON l.booking_id = g.booking_id " +
                    "JOIN courts s ON s.court_id = l.court_id " +
                    "JOIN facilities c ON c.facility_id = s.facility_id " +
                    "LEFT JOIN sports mt ON mt.sport_id = g.sport_id " +
                    "LEFT JOIN match_participants matched ON matched.match_id = g.match_id AND matched.participation_status = N'" + P_STATUS_JOINED + "' " +
                    "LEFT JOIN teams opp ON opp.team_id = matched.participant_team_id ";

    @Override
    public int createTeamMatch(int teamId, int captainAccountId, int datSanId, Integer monTheThaoId, String trinhDo, String note) throws Exception {
        String sql = "INSERT INTO matches (booking_id, AccountIDNguoiTao, sport_id, description, skill_level, status, creator_team_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, captainAccountId);
            if (monTheThaoId != null) ps.setInt(3, monTheThaoId); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, note);
            ps.setString(5, trinhDo);
            ps.setString(6, KEO_STATUS_OPEN);
            ps.setInt(7, teamId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (!rs.next()) throw new IllegalStateException("Không thể tạo kèo đội.");
                return rs.getInt(1);
            }
        }
    }

    @Override
    public List<TeamMatchSummaryDTO> listOpenTeamMatches(Integer sportId, Integer excludeTeamId) {
        StringBuilder sql = new StringBuilder(SELECT_SUMMARY_BASE);
        sql.append("WHERE g.creator_team_id IS NOT NULL AND g.status = N'").append(KEO_STATUS_OPEN).append("'");
        if (sportId != null) sql.append(" AND g.MonTheThaoID = ?");
        if (excludeTeamId != null) sql.append(" AND g.TeamIDNguoiTao <> ?");
        sql.append(" ORDER BY l.booking_date ASC, l.start_time ASC");

        List<TeamMatchSummaryDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            if (sportId != null) ps.setInt(idx++, sportId);
            if (excludeTeamId != null) ps.setInt(idx++, excludeTeamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.add(mapSummary(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn danh sách kèo đội đang mở", e);
        }
        return result;
    }

    @Override
    public List<TeamMatchSummaryDTO> listMyTeamMatches(int teamId) {
        String sql = SELECT_SUMMARY_BASE + "WHERE g.creator_team_id = ? ORDER BY g.match_id DESC";
        List<TeamMatchSummaryDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.add(mapSummary(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn kèo đội của đội ID " + teamId, e);
        }
        return result;
    }

    @Override
    public TeamMatchSummaryDTO getTeamMatchDetail(int keoId) {
        String sql = SELECT_SUMMARY_BASE + "WHERE g.match_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapSummary(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn kèo đội ID " + keoId, e);
        }
        return null;
    }

    @Override
    public int challengeTeamMatch(int keoId, int challengerTeamId, int captainAccountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int ownerTeamId;
                Integer sportId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT creator_team_id, sport_id, status FROM matches WITH (UPDLOCK, ROWLOCK) WHERE match_id = ?")) {
                    ps.setInt(1, keoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Kèo đội không tồn tại."); }
                        ownerTeamId = rs.getInt("creator_team_id");
                        if (rs.wasNull()) { conn.rollback(); throw new IllegalStateException("Đây không phải kèo đội."); }
                        int sid = rs.getInt("sport_id");
                        sportId = rs.wasNull() ? null : sid;
                        if (!KEO_STATUS_OPEN.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Kèo hiện không nhận thách đấu."); }
                    }
                }
                if (ownerTeamId == challengerTeamId) { conn.rollback(); throw new IllegalStateException("Đội không thể tự thách đấu chính mình."); }

                if (sportId != null) {
                    try (PreparedStatement ps = conn.prepareStatement("SELECT sport_id FROM teams WHERE team_id = ?")) {
                        ps.setInt(1, challengerTeamId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next() && rs.getInt("sport_id") != sportId) {
                                conn.rollback();
                                throw new IllegalStateException("Môn thể thao của đội bạn không khớp với kèo này.");
                            }
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM match_participants WHERE match_id = ? AND participant_team_id = ? AND participation_status IN (N'" + P_STATUS_PENDING + "', N'" + P_STATUS_JOINED + "')")) {
                    ps.setInt(1, keoId);
                    ps.setInt(2, challengerTeamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) { conn.rollback(); throw new IllegalStateException("Đội bạn đã gửi thách đấu cho kèo này rồi."); }
                    }
                }

                int newId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO match_participants (match_id, AccountIDNguoiThamGia, participation_status, participation_position, participant_team_id) VALUES (?, ?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, keoId);
                    ps.setInt(2, captainAccountId);
                    ps.setNString(3, P_STATUS_PENDING);
                    ps.setNString(4, "");
                    ps.setInt(5, challengerTeamId);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Không thể gửi thách đấu."); }
                        newId = rs.getInt(1);
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
    public List<TeamChallengeDTO> getPendingChallenges(int keoId) {
        String sql = "SELECT c.participant_id, c.match_id, c.participant_team_id, t.team_name, t.avatar_path, c.participation_status " +
                "FROM match_participants c JOIN teams t ON t.team_id = c.participant_team_id " +
                "WHERE c.match_id = ? AND c.participation_status = N'" + P_STATUS_PENDING + "' ORDER BY c.participant_id ASC";
        List<TeamChallengeDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, keoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamChallengeDTO dto = new TeamChallengeDTO();
                    dto.setChiTietKeoId(rs.getInt("participant_id"));
                    dto.setKeoId(rs.getInt("match_id"));
                    dto.setChallengerTeamId(rs.getInt("participant_team_id"));
                    dto.setChallengerTeamName(rs.getString("team_name"));
                    dto.setChallengerTeamAvatarPath(rs.getString("avatar_path"));
                    dto.setStatus(rs.getString("participation_status"));
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn thách đấu đang chờ cho kèo ID " + keoId, e);
        }
        return result;
    }

    @Override
    public boolean acceptChallenge(int chiTietKeoId, int ownerTeamId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int keoId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT match_id, participation_status FROM match_participants WITH (UPDLOCK, ROWLOCK) WHERE participant_id = ?")) {
                    ps.setInt(1, chiTietKeoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Thách đấu không tồn tại."); }
                        if (!P_STATUS_PENDING.equals(rs.getString("participation_status"))) { conn.rollback(); throw new IllegalStateException("Thách đấu đã được xử lý trước đó."); }
                        keoId = rs.getInt("match_id");
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT creator_team_id, status FROM matches WITH (UPDLOCK, ROWLOCK) WHERE match_id = ?")) {
                    ps.setInt(1, keoId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Kèo đội không tồn tại."); }
                        if (rs.getInt("creator_team_id") != ownerTeamId) { conn.rollback(); throw new IllegalStateException("Thách đấu này không thuộc kèo của đội bạn."); }
                        if (!KEO_STATUS_OPEN.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Kèo đã được xử lý (đã đủ đội hoặc đã hủy)."); }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE match_participants SET participation_status = ? WHERE participant_id = ?")) {
                    ps.setNString(1, P_STATUS_JOINED);
                    ps.setInt(2, chiTietKeoId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE match_participants SET participation_status = ? WHERE match_id = ? AND participant_id <> ? AND participation_status = ?")) {
                    ps.setNString(1, P_STATUS_REJECTED);
                    ps.setInt(2, keoId);
                    ps.setInt(3, chiTietKeoId);
                    ps.setNString(4, P_STATUS_PENDING);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE matches SET status = ? WHERE match_id = ?")) {
                    ps.setNString(1, KEO_STATUS_FULL);
                    ps.setInt(2, keoId);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                throw ex;
            }
        }
    }

    @Override
    public boolean rejectChallenge(int chiTietKeoId, int ownerTeamId) {
        String sql = "UPDATE c SET c.participation_status = ? " +
                "FROM match_participants c JOIN matches g ON g.match_id = c.match_id " +
                "WHERE c.participant_id = ? AND g.creator_team_id = ? AND c.participation_status = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, P_STATUS_REJECTED);
            ps.setInt(2, chiTietKeoId);
            ps.setInt(3, ownerTeamId);
            ps.setNString(4, P_STATUS_PENDING);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi từ chối thách đấu", e);
        }
    }

    @Override
    public boolean cancelTeamMatch(int keoId, int ownerTeamId) {
        String sql = "UPDATE matches SET status = ? WHERE match_id = ? AND creator_team_id = ? AND status = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, KEO_STATUS_CANCELLED);
            ps.setInt(2, keoId);
            ps.setInt(3, ownerTeamId);
            ps.setNString(4, KEO_STATUS_OPEN);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi hủy kèo đội", e);
        }
    }

    private TeamMatchSummaryDTO mapSummary(ResultSet rs) throws SQLException {
        TeamMatchSummaryDTO dto = new TeamMatchSummaryDTO();
        dto.setKeoId(rs.getInt("match_id"));
        dto.setTeamIdNguoiTao(rs.getInt("creator_team_id"));
        dto.setTeamNameNguoiTao(rs.getString("TeamNameNguoiTao"));
        dto.setDatSanId(rs.getInt("booking_id"));
        java.sql.Date ngayDat = rs.getDate("booking_date");
        dto.setNgayDat(ngayDat != null ? ngayDat.toLocalDate().toString() : null);
        java.sql.Time gioBatDau = rs.getTime("start_time");
        dto.setGioBatDau(gioBatDau != null ? gioBatDau.toLocalTime().toString().substring(0, 5) : null);
        java.sql.Time gioKetThuc = rs.getTime("end_time");
        dto.setGioKetThuc(gioKetThuc != null ? gioKetThuc.toLocalTime().toString().substring(0, 5) : null);
        dto.setTenSan(rs.getString("court_name"));
        dto.setTenCoSo(rs.getString("facility_name"));
        dto.setDiaChi(rs.getString("address"));
        int monTheThaoId = rs.getInt("sport_id");
        dto.setMonTheThaoId(rs.wasNull() ? null : monTheThaoId);
        dto.setTenMon(rs.getString("sport_name"));
        dto.setTrinhDo(rs.getString("skill_level"));
        dto.setTrangThai(rs.getString("status"));
        dto.setNote(rs.getString("Note"));
        int opponentTeamId = rs.getInt("OpponentTeamId");
        dto.setOpponentTeamId(rs.wasNull() ? null : opponentTeamId);
        dto.setOpponentTeamName(rs.getString("OpponentTeamName"));
        dto.setPendingChallengeCount(rs.getInt("PendingChallengeCount"));
        return dto;
    }
}
