package org.example.dao.impl;

import org.example.dao.TeamDAO;
import org.example.dto.TeamDetailDTO;
import org.example.dto.TeamInvitationDTO;
import org.example.dto.TeamJoinRequestDTO;
import org.example.dto.TeamMemberDTO;
import org.example.dto.TeamSummaryDTO;
import org.example.model.Team;
import org.example.model.TeamInvitation;
import org.example.model.TeamJoinRequest;
import org.example.model.TeamMember;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TeamDAOImpl implements TeamDAO {

    // ============================ Create / read Team ============================

    @Override
    public int createTeamWithCaptain(Team team) throws Exception {
        String sqlTeam = "INSERT INTO dbo.teams (team_name, description, sport_id, captain_account_id, location_text, avatar_path, cover_image_path, max_members, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlMember = "INSERT INTO dbo.team_members (team_id, account_id, member_role, member_status) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int teamId;
                try (PreparedStatement ps = conn.prepareStatement(sqlTeam, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, team.getTeamName());
                    ps.setString(2, team.getDescription());
                    ps.setInt(3, team.getSportId());
                    ps.setInt(4, team.getCaptainAccountId());
                    ps.setString(5, team.getLocationText());
                    ps.setString(6, team.getAvatarPath());
                    ps.setString(7, team.getCoverImagePath());
                    ps.setInt(8, team.getMaxMembers());
                    ps.setString(9, Team.STATUS_ACTIVE);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            conn.rollback();
                            throw new IllegalStateException("Không thể tạo đội.");
                        }
                        teamId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlMember)) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, team.getCaptainAccountId());
                    ps.setString(3, TeamMember.ROLE_CAPTAIN);
                    ps.setString(4, TeamMember.STATUS_ACTIVE);
                    ps.executeUpdate();
                }
                conn.commit();
                return teamId;
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException ignored) {}
                throw ex;
            }
        }
    }

    @Override
    public Team getTeamById(int teamId) {
        String sql = "SELECT team_id, team_name, description, sport_id, captain_account_id, location_text, avatar_path, cover_image_path, " +
                "max_members, status, created_at, updated_at, is_deleted, deleted_at, deleted_by FROM dbo.teams WHERE team_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapTeam(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn Team ID " + teamId, e);
        }
        return null;
    }

    @Override
    public boolean isTeamNameTakenForCaptain(int captainAccountId, String teamName, Integer excludeTeamId) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM dbo.teams WHERE captain_account_id = ? AND LOWER(team_name) = LOWER(?) " +
                        "AND status = 'ACTIVE' AND (is_deleted = 0 OR is_deleted IS NULL)");
        if (excludeTeamId != null) sql.append(" AND TeamID <> ?");
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, captainAccountId);
            ps.setString(2, teamName);
            if (excludeTeamId != null) ps.setInt(3, excludeTeamId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra trùng tên đội", e);
        }
    }

    @Override
    public boolean updateTeam(Team team) {
        String sql = "UPDATE dbo.teams SET team_name = ?, description = ?, sport_id = ?, location_text = ?, max_members = ?, updated_at = SYSUTCDATETIME() " +
                "WHERE team_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, team.getTeamName());
            ps.setString(2, team.getDescription());
            ps.setInt(3, team.getSportId());
            ps.setString(4, team.getLocationText());
            ps.setInt(5, team.getMaxMembers());
            ps.setInt(6, team.getTeamId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật đội ID " + team.getTeamId(), e);
        }
    }

    @Override
    public boolean updateAvatarPath(int teamId, String avatarPath) {
        return updatePathColumn(teamId, "avatar_path", avatarPath);
    }

    @Override
    public boolean updateCoverImagePath(int teamId, String coverImagePath) {
        return updatePathColumn(teamId, "cover_image_path", coverImagePath);
    }

    private boolean updatePathColumn(int teamId, String column, String value) {
        String sql = "UPDATE dbo.teams SET " + column + " = ?, updated_at = SYSUTCDATETIME() WHERE team_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            ps.setInt(2, teamId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật " + column + " cho đội ID " + teamId, e);
        }
    }

    // ============================ Listing ============================

    @Override
    public List<TeamSummaryDTO> getMyTeams(int accountId) {
        String sql = "SELECT t.team_id, t.team_name, t.description, t.sport_id, mt.sport_name AS SportName, t.location_text, t.avatar_path, " +
                "t.max_members, t.status, tm.member_role, " +
                "(SELECT COUNT(*) FROM dbo.team_members x WHERE x.team_id = t.team_id AND x.member_status = 'ACTIVE') AS MemberCount " +
                "FROM dbo.teams t " +
                "JOIN dbo.team_members tm ON tm.team_id = t.team_id AND tm.account_id = ? AND tm.member_status = 'ACTIVE' " +
                "LEFT JOIN sports mt ON mt.sport_id = t.sport_id " +
                "WHERE (t.is_deleted = 0 OR t.is_deleted IS NULL) " +
                "ORDER BY t.created_at DESC";
        List<TeamSummaryDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamSummaryDTO dto = mapSummary(rs);
                    dto.setMyRole(rs.getString("member_role"));
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn danh sách đội của tôi", e);
        }
        return result;
    }

    @Override
    public List<TeamSummaryDTO> discoverTeams(int accountId, String keyword, Integer sportId, boolean onlyOpenSlots) {
        StringBuilder sql = new StringBuilder(
                "SELECT t.team_id, t.team_name, t.description, t.sport_id, mt.sport_name AS SportName, t.location_text, t.avatar_path, " +
                        "t.max_members, t.status, " +
                        "(SELECT COUNT(*) FROM dbo.team_members x WHERE x.team_id = t.team_id AND x.member_status = 'ACTIVE') AS MemberCount, " +
                        "CASE WHEN EXISTS (SELECT 1 FROM dbo.team_join_requests jr WHERE jr.team_id = t.team_id AND jr.requester_account_id = ? AND jr.status = 'PENDING') " +
                        "     THEN 1 ELSE 0 END AS HasPendingJoinRequest " +
                        "FROM dbo.teams t " +
                        "LEFT JOIN sports mt ON mt.sport_id = t.sport_id " +
                        "WHERE t.status = 'ACTIVE' AND (t.is_deleted = 0 OR t.is_deleted IS NULL) " +
                        "  AND NOT EXISTS (SELECT 1 FROM dbo.team_members tm WHERE tm.team_id = t.team_id AND tm.account_id = ? AND tm.member_status = 'ACTIVE')");
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        if (hasKeyword) {
            sql.append(" AND (LOWER(t.TeamName) LIKE ? ESCAPE '\\' OR LOWER(t.LocationText) LIKE ? ESCAPE '\\')");
        }
        if (sportId != null) {
            sql.append(" AND t.SportID = ?");
        }
        if (onlyOpenSlots) {
            sql.append(" AND (SELECT COUNT(*) FROM dbo.team_members x WHERE x.team_id = t.team_id AND x.member_status = 'ACTIVE') < t.max_members");
        }
        sql.append(" ORDER BY t.created_at DESC");

        List<TeamSummaryDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, accountId);
            ps.setInt(idx++, accountId);
            if (hasKeyword) {
                String escaped = keyword.trim().toLowerCase()
                        .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
                String pattern = "%" + escaped + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }
            if (sportId != null) {
                ps.setInt(idx++, sportId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamSummaryDTO dto = mapSummary(rs);
                    dto.setHasPendingJoinRequest(rs.getInt("HasPendingJoinRequest") == 1);
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tìm kiếm đội", e);
        }
        return result;
    }

    @Override
    public TeamDetailDTO getTeamDetail(int teamId, int viewerAccountId) {
        String sql = "SELECT t.team_id, t.team_name, t.description, t.sport_id, mt.sport_name AS SportName, t.location_text, t.avatar_path, " +
                "t.cover_image_path, t.max_members, t.status, t.created_at, t.captain_account_id, cap.full_name AS CaptainName, " +
                "(SELECT COUNT(*) FROM dbo.team_members x WHERE x.team_id = t.team_id AND x.member_status = 'ACTIVE') AS MemberCount, " +
                "viewer.member_role AS ViewerRole " +
                "FROM dbo.teams t " +
                "LEFT JOIN sports mt ON mt.sport_id = t.sport_id " +
                "LEFT JOIN accounts cap ON cap.account_id = t.captain_account_id " +
                "LEFT JOIN dbo.team_members viewer ON viewer.team_id = t.team_id AND viewer.account_id = ? AND viewer.member_status = 'ACTIVE' " +
                "WHERE t.team_id = ? AND (t.is_deleted = 0 OR t.is_deleted IS NULL)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, viewerAccountId);
            ps.setInt(2, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                TeamDetailDTO dto = new TeamDetailDTO();
                dto.setTeamId(rs.getInt("team_id"));
                dto.setTeamName(rs.getString("team_name"));
                dto.setDescription(rs.getString("description"));
                dto.setSportId(rs.getInt("sport_id"));
                dto.setSportName(rs.getString("SportName"));
                dto.setLocationText(rs.getString("location_text"));
                dto.setAvatarPath(rs.getString("avatar_path"));
                dto.setCoverImagePath(rs.getString("cover_image_path"));
                dto.setMaxMembers(rs.getInt("max_members"));
                dto.setStatus(rs.getString("status"));
                Timestamp createdAt = rs.getTimestamp("created_at");
                dto.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime().toString() : null);
                dto.setCaptainAccountId(rs.getInt("captain_account_id"));
                dto.setCaptainName(rs.getString("CaptainName"));
                dto.setMemberCount(rs.getInt("MemberCount"));
                String viewerRole = rs.getString("ViewerRole");
                dto.setMyRole(viewerRole);
                dto.setCaptain(TeamMember.ROLE_CAPTAIN.equals(viewerRole));
                dto.setCoCaptain(TeamMember.ROLE_CO_CAPTAIN.equals(viewerRole));
                dto.setMembers(getMembers(teamId));
                return dto;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn chi tiết đội ID " + teamId, e);
        }
    }

    // ============================ Membership ============================

    @Override
    public TeamMember getActiveMembership(int teamId, int accountId) {
        String sql = "SELECT team_member_id, team_id, account_id, member_role, member_status, joined_at, left_at, added_by " +
                "FROM dbo.team_members WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapMember(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra thành viên", e);
        }
        return null;
    }

    @Override
    public int countActiveMembers(int teamId) {
        String sql = "SELECT COUNT(*) FROM dbo.team_members WHERE team_id = ? AND member_status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi đếm thành viên đội ID " + teamId, e);
        }
    }

    @Override
    public List<TeamMemberDTO> getMembers(int teamId) {
        String sql = "SELECT tm.team_member_id, tm.account_id, a.full_name, a.avatar_url, tm.member_role, tm.member_status, tm.joined_at " +
                "FROM dbo.team_members tm JOIN accounts a ON a.account_id = tm.account_id " +
                "WHERE tm.team_id = ? AND tm.member_status = 'ACTIVE' " +
                "ORDER BY CASE tm.member_role WHEN 'CAPTAIN' THEN 0 WHEN 'CO_CAPTAIN' THEN 1 ELSE 2 END, tm.joined_at ASC";
        List<TeamMemberDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamMemberDTO dto = new TeamMemberDTO();
                    dto.setTeamMemberId(rs.getInt("team_member_id"));
                    dto.setAccountId(rs.getInt("account_id"));
                    dto.setFullName(rs.getString("full_name"));
                    dto.setAvatarUrl(rs.getString("avatar_url"));
                    dto.setMemberRole(rs.getString("member_role"));
                    dto.setMemberStatus(rs.getString("member_status"));
                    Timestamp joinedAt = rs.getTimestamp("joined_at");
                    dto.setJoinedAt(joinedAt != null ? joinedAt.toLocalDateTime().toString() : null);
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn danh sách thành viên đội ID " + teamId, e);
        }
        return result;
    }

    @Override
    public boolean updateMemberRole(int teamId, int accountId, String newRole) {
        String sql = "UPDATE dbo.team_members SET member_role = ? WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newRole);
            ps.setInt(2, teamId);
            ps.setInt(3, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi đổi vai trò thành viên", e);
        }
    }

    @Override
    public boolean deactivateMember(int teamId, int accountId, String newStatus) {
        String sql = "UPDATE dbo.team_members SET member_status = ?, left_at = SYSUTCDATETIME() " +
                "WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, teamId);
            ps.setInt(3, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi cập nhật trạng thái thành viên", e);
        }
    }

    @Override
    public boolean transferCaptain(int teamId, int fromAccountId, int toAccountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Khóa cả 2 hàng thành viên liên quan để tránh race condition khi chuyển quyền đồng thời.
                String sqlLock = "SELECT account_id, member_role FROM dbo.team_members WITH (UPDLOCK, ROWLOCK) " +
                        "WHERE team_id = ? AND account_id IN (?, ?) AND member_status = 'ACTIVE'";
                int found = 0;
                try (PreparedStatement ps = conn.prepareStatement(sqlLock)) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, fromAccountId);
                    ps.setInt(3, toAccountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) found++;
                    }
                }
                if (found < 2) {
                    conn.rollback();
                    throw new IllegalStateException("Không tìm thấy đủ 2 thành viên active để chuyển quyền.");
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_members SET member_role = ? WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setString(1, TeamMember.ROLE_MEMBER);
                    ps.setInt(2, teamId);
                    ps.setInt(3, fromAccountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_members SET member_role = ? WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setString(1, TeamMember.ROLE_CAPTAIN);
                    ps.setInt(2, teamId);
                    ps.setInt(3, toAccountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.teams SET captain_account_id = ?, updated_at = SYSUTCDATETIME() WHERE team_id = ?")) {
                    ps.setInt(1, toAccountId);
                    ps.setInt(2, teamId);
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
    public boolean disbandTeam(int teamId, int actorAccountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.teams SET status = ?, is_deleted = 1, deleted_at = SYSUTCDATETIME(), deleted_by = ?, updated_at = SYSUTCDATETIME() " +
                                "WHERE team_id = ? AND (is_deleted = 0 OR is_deleted IS NULL)")) {
                    ps.setString(1, Team.STATUS_DISBANDED);
                    ps.setInt(2, actorAccountId);
                    ps.setInt(3, teamId);
                    int updated = ps.executeUpdate();
                    if (updated == 0) {
                        conn.rollback();
                        return false;
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_members SET member_status = 'REMOVED', left_at = SYSUTCDATETIME() WHERE team_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setInt(1, teamId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_invitations SET status = 'CANCELLED', responded_at = SYSUTCDATETIME() WHERE team_id = ? AND status = 'PENDING'")) {
                    ps.setInt(1, teamId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_join_requests SET status = 'CANCELLED', reviewed_at = SYSUTCDATETIME(), reviewed_by_account_id = ? WHERE team_id = ? AND status = 'PENDING'")) {
                    ps.setInt(1, actorAccountId);
                    ps.setInt(2, teamId);
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

    // ============================ Invitations ============================

    @Override
    public int createInvitation(TeamInvitation invitation) {
        String sql = "INSERT INTO dbo.team_invitations (team_id, invited_account_id, invited_by_account_id, proposed_role, status, message, expires_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, invitation.getTeamId());
            ps.setInt(2, invitation.getInvitedAccountId());
            ps.setInt(3, invitation.getInvitedByAccountId());
            ps.setString(4, invitation.getProposedRole());
            ps.setString(5, TeamInvitation.STATUS_PENDING);
            ps.setString(6, invitation.getMessage());
            if (invitation.getExpiresAt() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(invitation.getExpiresAt()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tạo lời mời tham gia đội", e);
        }
    }

    @Override
    public boolean hasPendingInvitation(int teamId, int invitedAccountId) {
        String sql = "SELECT COUNT(*) FROM dbo.team_invitations WHERE team_id = ? AND invited_account_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            ps.setInt(2, invitedAccountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra lời mời đang chờ", e);
        }
    }

    @Override
    public List<TeamInvitationDTO> getPendingInvitationsForAccount(int accountId) {
        String sql = "SELECT inv.invitation_id, inv.team_id, t.team_name, t.avatar_path AS TeamAvatarPath, " +
                "inv.invited_by_account_id, a.full_name AS InvitedByName, inv.proposed_role, inv.status, inv.message, inv.created_at, inv.expires_at " +
                "FROM dbo.team_invitations inv " +
                "JOIN dbo.teams t ON t.team_id = inv.team_id " +
                "JOIN accounts a ON a.account_id = inv.invited_by_account_id " +
                "WHERE inv.invited_account_id = ? AND inv.status = 'PENDING' AND (t.is_deleted = 0 OR t.is_deleted IS NULL) " +
                "ORDER BY inv.created_at DESC";
        List<TeamInvitationDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamInvitationDTO dto = new TeamInvitationDTO();
                    dto.setInvitationId(rs.getInt("invitation_id"));
                    dto.setTeamId(rs.getInt("team_id"));
                    dto.setTeamName(rs.getString("team_name"));
                    dto.setTeamAvatarPath(rs.getString("TeamAvatarPath"));
                    dto.setInvitedByAccountId(rs.getInt("invited_by_account_id"));
                    dto.setInvitedByName(rs.getString("InvitedByName"));
                    dto.setProposedRole(rs.getString("proposed_role"));
                    dto.setStatus(rs.getString("status"));
                    dto.setMessage(rs.getString("message"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    dto.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime().toString() : null);
                    Timestamp expiresAt = rs.getTimestamp("expires_at");
                    dto.setExpiresAt(expiresAt != null ? expiresAt.toLocalDateTime().toString() : null);
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn lời mời đang chờ", e);
        }
        return result;
    }

    @Override
    public TeamInvitation getInvitationById(int invitationId) {
        String sql = "SELECT invitation_id, team_id, invited_account_id, invited_by_account_id, proposed_role, status, message, created_at, expires_at, responded_at " +
                "FROM dbo.team_invitations WHERE invitation_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invitationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapInvitation(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn lời mời ID " + invitationId, e);
        }
        return null;
    }

    @Override
    public boolean acceptInvitation(int invitationId, int accountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int teamId;
                String sqlLockInv = "SELECT team_id, invited_account_id, proposed_role, status FROM dbo.team_invitations WITH (UPDLOCK, ROWLOCK) WHERE invitation_id = ?";
                String proposedRole;
                try (PreparedStatement ps = conn.prepareStatement(sqlLockInv)) {
                    ps.setInt(1, invitationId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Lời mời không tồn tại."); }
                        if (rs.getInt("invited_account_id") != accountId) { conn.rollback(); throw new IllegalStateException("Lời mời này không dành cho bạn."); }
                        if (!TeamInvitation.STATUS_PENDING.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Lời mời đã được xử lý trước đó."); }
                        teamId = rs.getInt("team_id");
                        proposedRole = rs.getString("proposed_role");
                    }
                }

                // Khóa hàng Teams để kiểm tra MaxMembers dưới điều kiện đua (race-safe).
                int maxMembers;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT max_members, status FROM dbo.teams WITH (UPDLOCK, ROWLOCK) WHERE team_id = ?")) {
                    ps.setInt(1, teamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Đội không còn tồn tại."); }
                        if (!Team.STATUS_ACTIVE.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Đội hiện không hoạt động."); }
                        maxMembers = rs.getInt("max_members");
                    }
                }

                int currentCount;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM dbo.team_members WHERE team_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setInt(1, teamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        currentCount = rs.next() ? rs.getInt(1) : 0;
                    }
                }
                if (currentCount >= maxMembers) { conn.rollback(); throw new IllegalStateException("Đội đã đủ thành viên."); }

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM dbo.team_members WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, accountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) { conn.rollback(); throw new IllegalStateException("Bạn đã là thành viên của đội này."); }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO dbo.team_members (team_id, account_id, member_role, member_status, added_by) VALUES (?, ?, ?, 'ACTIVE', ?)")) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, accountId);
                    ps.setString(3, proposedRole != null ? proposedRole : TeamMember.ROLE_MEMBER);
                    ps.setInt(4, accountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_invitations SET status = 'ACCEPTED', responded_at = SYSUTCDATETIME() WHERE invitation_id = ?")) {
                    ps.setInt(1, invitationId);
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
    public boolean rejectInvitation(int invitationId, int accountId) {
        String sql = "UPDATE dbo.team_invitations SET status = 'REJECTED', responded_at = SYSUTCDATETIME() " +
                "WHERE invitation_id = ? AND invited_account_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invitationId);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi từ chối lời mời", e);
        }
    }

    @Override
    public boolean cancelInvitation(int invitationId, int teamId) {
        String sql = "UPDATE dbo.team_invitations SET status = 'CANCELLED', responded_at = SYSUTCDATETIME() " +
                "WHERE invitation_id = ? AND team_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invitationId);
            ps.setInt(2, teamId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi hủy lời mời", e);
        }
    }

    // ============================ Join requests ============================

    @Override
    public int createJoinRequest(TeamJoinRequest joinRequest) {
        String sql = "INSERT INTO dbo.team_join_requests (team_id, requester_account_id, message, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, joinRequest.getTeamId());
            ps.setInt(2, joinRequest.getRequesterAccountId());
            ps.setString(3, joinRequest.getMessage());
            ps.setString(4, TeamJoinRequest.STATUS_PENDING);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tạo yêu cầu tham gia đội", e);
        }
    }

    @Override
    public boolean hasPendingJoinRequest(int teamId, int accountId) {
        String sql = "SELECT COUNT(*) FROM dbo.team_join_requests WHERE team_id = ? AND requester_account_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi kiểm tra yêu cầu tham gia đang chờ", e);
        }
    }

    @Override
    public List<TeamJoinRequestDTO> getPendingJoinRequests(int teamId) {
        String sql = "SELECT jr.join_request_id, jr.team_id, jr.requester_account_id, a.full_name AS RequesterName, a.avatar_url AS RequesterAvatarUrl, " +
                "jr.message, jr.status, jr.created_at " +
                "FROM dbo.team_join_requests jr JOIN accounts a ON a.account_id = jr.requester_account_id " +
                "WHERE jr.team_id = ? AND jr.status = 'PENDING' ORDER BY jr.created_at ASC";
        List<TeamJoinRequestDTO> result = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, teamId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TeamJoinRequestDTO dto = new TeamJoinRequestDTO();
                    dto.setJoinRequestId(rs.getInt("join_request_id"));
                    dto.setTeamId(rs.getInt("team_id"));
                    dto.setRequesterAccountId(rs.getInt("requester_account_id"));
                    dto.setRequesterName(rs.getString("RequesterName"));
                    dto.setRequesterAvatarUrl(rs.getString("RequesterAvatarUrl"));
                    dto.setMessage(rs.getString("message"));
                    dto.setStatus(rs.getString("status"));
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    dto.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime().toString() : null);
                    result.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn yêu cầu tham gia đội ID " + teamId, e);
        }
        return result;
    }

    @Override
    public TeamJoinRequest getJoinRequestById(int joinRequestId) {
        String sql = "SELECT join_request_id, team_id, requester_account_id, message, status, created_at, reviewed_at, reviewed_by_account_id " +
                "FROM dbo.team_join_requests WHERE join_request_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, joinRequestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapJoinRequest(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn yêu cầu tham gia ID " + joinRequestId, e);
        }
        return null;
    }

    @Override
    public boolean approveJoinRequest(int joinRequestId, int reviewerAccountId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int teamId;
                int requesterAccountId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT team_id, requester_account_id, status FROM dbo.team_join_requests WITH (UPDLOCK, ROWLOCK) WHERE join_request_id = ?")) {
                    ps.setInt(1, joinRequestId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Yêu cầu tham gia không tồn tại."); }
                        if (!TeamJoinRequest.STATUS_PENDING.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Yêu cầu đã được xử lý trước đó."); }
                        teamId = rs.getInt("team_id");
                        requesterAccountId = rs.getInt("requester_account_id");
                    }
                }

                int maxMembers;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT max_members, status FROM dbo.teams WITH (UPDLOCK, ROWLOCK) WHERE team_id = ?")) {
                    ps.setInt(1, teamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); throw new IllegalStateException("Đội không còn tồn tại."); }
                        if (!Team.STATUS_ACTIVE.equals(rs.getString("status"))) { conn.rollback(); throw new IllegalStateException("Đội hiện không hoạt động."); }
                        maxMembers = rs.getInt("max_members");
                    }
                }
                int currentCount;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM dbo.team_members WHERE team_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setInt(1, teamId);
                    try (ResultSet rs = ps.executeQuery()) {
                        currentCount = rs.next() ? rs.getInt(1) : 0;
                    }
                }
                if (currentCount >= maxMembers) { conn.rollback(); throw new IllegalStateException("Đội đã đủ thành viên, không thể duyệt thêm."); }

                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT COUNT(*) FROM dbo.team_members WHERE team_id = ? AND account_id = ? AND member_status = 'ACTIVE'")) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, requesterAccountId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) { conn.rollback(); throw new IllegalStateException("Người này đã là thành viên của đội."); }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO dbo.team_members (team_id, account_id, member_role, member_status, added_by) VALUES (?, ?, 'MEMBER', 'ACTIVE', ?)")) {
                    ps.setInt(1, teamId);
                    ps.setInt(2, requesterAccountId);
                    ps.setInt(3, reviewerAccountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE dbo.team_join_requests SET status = 'APPROVED', reviewed_at = SYSUTCDATETIME(), reviewed_by_account_id = ? WHERE join_request_id = ?")) {
                    ps.setInt(1, reviewerAccountId);
                    ps.setInt(2, joinRequestId);
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
    public boolean rejectJoinRequest(int joinRequestId, int reviewerAccountId) {
        String sql = "UPDATE dbo.team_join_requests SET status = 'REJECTED', reviewed_at = SYSUTCDATETIME(), reviewed_by_account_id = ? " +
                "WHERE join_request_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewerAccountId);
            ps.setInt(2, joinRequestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi từ chối yêu cầu tham gia", e);
        }
    }

    @Override
    public boolean cancelJoinRequest(int joinRequestId, int requesterAccountId) {
        String sql = "UPDATE dbo.team_join_requests SET status = 'CANCELLED', reviewed_at = SYSUTCDATETIME() " +
                "WHERE join_request_id = ? AND requester_account_id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, joinRequestId);
            ps.setInt(2, requesterAccountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi hủy yêu cầu tham gia", e);
        }
    }

    // ============================ Mappers ============================

    private Team mapTeam(ResultSet rs) throws SQLException {
        Team t = new Team();
        t.setTeamId(rs.getInt("team_id"));
        t.setTeamName(rs.getString("team_name"));
        t.setDescription(rs.getString("description"));
        t.setSportId(rs.getInt("sport_id"));
        t.setCaptainAccountId(rs.getInt("captain_account_id"));
        t.setLocationText(rs.getString("location_text"));
        t.setAvatarPath(rs.getString("avatar_path"));
        t.setCoverImagePath(rs.getString("cover_image_path"));
        t.setMaxMembers(rs.getInt("max_members"));
        t.setStatus(rs.getString("status"));
        t.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
        t.setUpdatedAt(toLocalDateTime(rs.getTimestamp("updated_at")));
        t.setDeleted(rs.getBoolean("is_deleted"));
        t.setDeletedAt(toLocalDateTime(rs.getTimestamp("deleted_at")));
        int deletedBy = rs.getInt("deleted_by");
        t.setDeletedBy(rs.wasNull() ? null : deletedBy);
        return t;
    }

    private TeamSummaryDTO mapSummary(ResultSet rs) throws SQLException {
        TeamSummaryDTO dto = new TeamSummaryDTO();
        dto.setTeamId(rs.getInt("team_id"));
        dto.setTeamName(rs.getString("team_name"));
        dto.setDescription(rs.getString("description"));
        dto.setSportId(rs.getInt("sport_id"));
        dto.setSportName(rs.getString("SportName"));
        dto.setLocationText(rs.getString("location_text"));
        dto.setAvatarPath(rs.getString("avatar_path"));
        dto.setMemberCount(rs.getInt("MemberCount"));
        dto.setMaxMembers(rs.getInt("max_members"));
        dto.setStatus(rs.getString("status"));
        return dto;
    }

    private TeamMember mapMember(ResultSet rs) throws SQLException {
        TeamMember m = new TeamMember();
        m.setTeamMemberId(rs.getInt("team_member_id"));
        m.setTeamId(rs.getInt("team_id"));
        m.setAccountId(rs.getInt("account_id"));
        m.setMemberRole(rs.getString("member_role"));
        m.setMemberStatus(rs.getString("member_status"));
        m.setJoinedAt(toLocalDateTime(rs.getTimestamp("joined_at")));
        m.setLeftAt(toLocalDateTime(rs.getTimestamp("left_at")));
        int addedBy = rs.getInt("added_by");
        m.setAddedBy(rs.wasNull() ? null : addedBy);
        return m;
    }

    private TeamInvitation mapInvitation(ResultSet rs) throws SQLException {
        TeamInvitation inv = new TeamInvitation();
        inv.setInvitationId(rs.getInt("invitation_id"));
        inv.setTeamId(rs.getInt("team_id"));
        inv.setInvitedAccountId(rs.getInt("invited_account_id"));
        inv.setInvitedByAccountId(rs.getInt("invited_by_account_id"));
        inv.setProposedRole(rs.getString("proposed_role"));
        inv.setStatus(rs.getString("status"));
        inv.setMessage(rs.getString("message"));
        inv.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
        inv.setExpiresAt(toLocalDateTime(rs.getTimestamp("expires_at")));
        inv.setRespondedAt(toLocalDateTime(rs.getTimestamp("responded_at")));
        return inv;
    }

    private TeamJoinRequest mapJoinRequest(ResultSet rs) throws SQLException {
        TeamJoinRequest jr = new TeamJoinRequest();
        jr.setJoinRequestId(rs.getInt("join_request_id"));
        jr.setTeamId(rs.getInt("team_id"));
        jr.setRequesterAccountId(rs.getInt("requester_account_id"));
        jr.setMessage(rs.getString("message"));
        jr.setStatus(rs.getString("status"));
        jr.setCreatedAt(toLocalDateTime(rs.getTimestamp("created_at")));
        jr.setReviewedAt(toLocalDateTime(rs.getTimestamp("reviewed_at")));
        int reviewedBy = rs.getInt("reviewed_by_account_id");
        jr.setReviewedByAccountId(rs.wasNull() ? null : reviewedBy);
        return jr;
    }

    private LocalDateTime toLocalDateTime(Timestamp ts) {
        return ts != null ? ts.toLocalDateTime() : null;
    }
}
