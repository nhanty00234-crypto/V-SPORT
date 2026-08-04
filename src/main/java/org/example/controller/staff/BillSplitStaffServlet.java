package org.example.controller.staff;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.NhomChiaTien;
import org.example.model.NhomChiaTienChiTiet;
import org.example.model.TaiKhoan;
import org.example.service.billsplit.BillSplitService;
import org.example.util.Constants;
import org.example.util.DBUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

/**
 * Staff xác nhận 1 Share đã thanh toán TẠI SÂN (tiền mặt) — chỉ xác nhận được cho hóa đơn
 * thuộc cơ sở mình (mục 13 spec). Ghi actor (ConfirmedByStaffID) + thời gian (PaidAt).
 *
 * POST /staff/chia-tien-xac-nhan?shareId=X
 */
@WebServlet("/staff/chia-tien-xac-nhan")
public class BillSplitStaffServlet extends HttpServlet {

    private final BillSplitService billSplitService = new BillSplitService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan staff = requireStaff(req, resp);
        if (staff == null) return;

        int shareId = parseIntSafe(req.getParameter("shareId"), 0);
        if (shareId <= 0) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Thiếu shareId.");
            return;
        }

        NhomChiaTienChiTiet ct = billSplitService.getShareById(shareId);
        if (ct == null) {
            sendJsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phần chia tiền.");
            return;
        }

        NhomChiaTien nct = billSplitService.findById(ct.getNhomChiaTienId());
        if (nct == null) {
            sendJsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phiên chia tiền.");
            return;
        }
        Integer coSoId = findCoSoIdByDatSanId(nct.getDatSanId());
        if (coSoId == null || !coSoId.equals(staff.getCoSoId())) {
            sendJsonError(resp, HttpServletResponse.SC_FORBIDDEN, "Hóa đơn không thuộc cơ sở của bạn.");
            return;
        }

        BillSplitService.Result r = billSplitService.markSharePaid(shareId, Constants.PT_TIEN_MAT, null,
                ct.getAccountId(), staff.getAccountId());
        if (r.success) {
            writeJson(resp, Map.of("success", true, "message", "Đã xác nhận thanh toán tại sân cho " + ct.getDisplayName() + "."));
        } else {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            writeJson(resp, Map.of("success", false, "error", r.message));
        }
    }

    private Integer findCoSoIdByDatSanId(int datSanId) {
        String sql = "SELECT s.CoSoID FROM LichDatSan lds JOIN San s ON lds.SanID = s.SanID WHERE lds.DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException ignored) {
        }
        return null;
    }

    private TaiKhoan requireStaff(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            sendJsonError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập.");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_LE_TAN) {
            sendJsonError(resp, HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
            return null;
        }
        if (user.getCoSoId() == null || user.getCoSoId() <= 0) {
            sendJsonError(resp, HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa được gán cơ sở.");
            return null;
        }
        return user;
    }

    private static int parseIntSafe(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private void sendJsonError(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        writeJson(resp, Map.of("success", false, "error", message));
    }

    private void writeJson(HttpServletResponse resp, Object body) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(gson.toJson(body));
    }
}
