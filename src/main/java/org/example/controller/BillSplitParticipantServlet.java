package org.example.controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.NhomChiaTienChiTiet;
import org.example.model.TaiKhoan;
import org.example.service.billsplit.BillSplitService;
import org.example.service.billsplit.BillSplitViewBuilder;
import org.example.util.BillSplitShareStatus;
import org.example.util.Constants;

import java.io.IOException;
import java.util.Map;

/**
 * Participant (có thể chưa có tài khoản V-SPORT) xem và bắt đầu thanh toán 1 Share qua
 * ShareToken — không dùng ID tăng dần làm link công khai (mục 6/13 spec). Token đủ mạnh
 * (256-bit, ShareTokenGenerator), không log đầy đủ.
 *
 * GET  /chia-tien/thanh-toan?token=X   — xem chi tiết Share (chỉ field cần thiết, không lộ
 *                                         thông tin participant khác)
 * POST /chia-tien/thanh-toan?token=X&action=start-payment&method=TAI_SAN
 *                                       — đánh dấu Share chuyển PROCESSING, chờ Staff xác nhận
 *                                         tại sân (thanh toán PayOS riêng theo Share chưa được
 *                                         tích hợp ở giai đoạn này — xem ghi chú giới hạn).
 */
@WebServlet("/chia-tien/thanh-toan")
public class BillSplitParticipantServlet extends HttpServlet {

    private final BillSplitService billSplitService = new BillSplitService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        NhomChiaTienChiTiet ct = token != null ? billSplitService.getShareByToken(token) : null;
        if (ct == null) {
            sendJsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Liên kết thanh toán không hợp lệ hoặc đã hết hạn.");
            return;
        }
        // Participant chỉ xem đúng share của mình qua token - không trả thêm thông tin share khác
        // (không gọi buildOverview với includeTokens=true cho toàn bộ nhóm ở đây).
        Map<String, Object> shareView = BillSplitViewBuilder.buildShare(req.getContextPath(), ct, false);
        writeJson(resp, Map.of("success", true, "share", shareView));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String token = req.getParameter("token");
        String action = req.getParameter("action");
        NhomChiaTienChiTiet ct = token != null ? billSplitService.getShareByToken(token) : null;
        if (ct == null) {
            sendJsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Liên kết thanh toán không hợp lệ hoặc đã hết hạn.");
            return;
        }

        if (!"start-payment".equals(action)) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Hành động không hợp lệ.");
            return;
        }
        if (!BillSplitShareStatus.PAYABLE_FROM.contains(ct.getTrangThai())) {
            sendJsonError(resp, HttpServletResponse.SC_CONFLICT,
                    "Phần chia tiền này đã được xử lý (trạng thái: " + ct.getTrangThai() + ").");
            return;
        }

        String method = req.getParameter("method");
        if (Constants.PT_TIEN_MAT.equals(method) || "TAI_SAN".equalsIgnoreCase(method)) {
            // Thanh toán tại sân: chỉ đánh dấu ý định, Staff mới là bên xác nhận thật (chống giả mạo
            // đã trả tiền — participant không tự đánh dấu PAID được).
            Integer payerAccountId = currentAccountIdOrNull(req);
            boolean ok = markProcessing(ct, payerAccountId);
            if (!ok) {
                sendJsonError(resp, HttpServletResponse.SC_CONFLICT, "Không thể cập nhật — trạng thái đã thay đổi.");
                return;
            }
            writeJson(resp, Map.of("success", true,
                    "message", "Vui lòng đến cơ sở và thông báo nhân viên để xác nhận thanh toán."));
            return;
        }

        // PayOS riêng cho từng Share chưa được tích hợp ở giai đoạn này (xem ghi chú giới hạn báo cáo cuối).
        sendJsonError(resp, HttpServletResponse.SC_NOT_IMPLEMENTED,
                "Phương thức thanh toán online cho từng phần chưa khả dụng. Vui lòng chọn thanh toán tại sân.");
    }

    private boolean markProcessing(NhomChiaTienChiTiet ct, Integer payerAccountId) {
        return new org.example.dao.impl.NhomChiaTienChiTietDAOImpl().updateTrangThai(
                ct.getChiTietId(), ct.getTrangThai(), BillSplitShareStatus.PROCESSING,
                "TAI_SAN", null, payerAccountId, null);
    }

    private Integer currentAccountIdOrNull(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        return user != null ? user.getAccountId() : null;
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
