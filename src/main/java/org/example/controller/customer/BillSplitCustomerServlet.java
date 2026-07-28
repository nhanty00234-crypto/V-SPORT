package org.example.controller.customer;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.NhomChiaTien;
import org.example.model.TaiKhoan;
import org.example.service.billsplit.BillSplitService;
import org.example.service.billsplit.BillSplitViewBuilder;
import org.example.util.BillSplitType;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Chủ booking (Customer) tạo/xem/hủy BillSplit và thanh toán phần còn lại. Đây là nghiệp vụ
 * "Chia tiền nhóm" — KHÔNG liên quan tới "Tách hóa đơn dịch vụ" (Staff, /staff/split-bill).
 *
 * GET  /customer/chia-tien-nhom?datSanId=X   — danh sách BillSplit của 1 booking (JSON)
 * GET  /customer/chia-tien-nhom?id=X          — chi tiết 1 BillSplit kèm đầy đủ share/token (JSON)
 * POST /customer/chia-tien-nhom?action=create|cancel|pay-remaining
 */
@WebServlet("/customer/chia-tien-nhom")
public class BillSplitCustomerServlet extends HttpServlet {

    private final BillSplitService billSplitService = new BillSplitService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireCustomer(req, resp);
        if (user == null) return;

        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.isBlank()) {
            int billSplitId = parseIntSafe(idParam, 0);
            NhomChiaTien nct = billSplitId > 0 ? billSplitService.findByIdAndCreatedBy(billSplitId, user.getAccountId()) : null;
            if (nct == null) {
                sendJsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy phiên chia tiền.");
                return;
            }
            Map<String, Object> view = BillSplitViewBuilder.buildOverview(req.getContextPath(), nct,
                    billSplitService.getShares(billSplitId), true);
            writeJson(resp, Map.of("success", true, "billSplit", view));
            return;
        }

        String datSanIdParam = req.getParameter("datSanId");
        int datSanId = parseIntSafe(datSanIdParam, 0);
        if (datSanId <= 0) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số datSanId.");
            return;
        }
        List<NhomChiaTien> list = billSplitService.findByDatSanId(datSanId);
        List<Map<String, Object>> views = new ArrayList<>();
        for (NhomChiaTien nct : list) {
            if (nct.getCreatedByAccountId() != user.getAccountId()) continue; // chống IDOR - chỉ của mình
            views.add(BillSplitViewBuilder.buildOverview(req.getContextPath(), nct,
                    billSplitService.getShares(nct.getNhomChiaTienId()), true));
        }
        writeJson(resp, Map.of("success", true, "billSplits", views));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireCustomer(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        switch (action != null ? action : "") {
            case "create": {
                handleCreate(req, resp, user);
                return;
            }
            case "cancel": {
                int billSplitId = parseIntSafe(req.getParameter("billSplitId"), 0);
                BillSplitService.Result r = billSplitService.cancelSplit(billSplitId, user.getAccountId());
                writeResult(resp, r);
                return;
            }
            case "pay-remaining": {
                int billSplitId = parseIntSafe(req.getParameter("billSplitId"), 0);
                BillSplitService.Result r = billSplitService.createRemainingShare(billSplitId, user.getAccountId());
                writeResult(resp, r);
                return;
            }
            default:
                sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Hành động không hợp lệ.");
        }
    }

    /**
     * Body form-urlencoded:
     *   datSanId, splitType (EQUAL|CUSTOM),
     *   participants[i].displayName, participants[i].accountId (optional), participants[i].amount (CUSTOM only)
     * Không tin participants[].amount cho EQUAL — server tự tính lại toàn bộ.
     */
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        int datSanId = parseIntSafe(req.getParameter("datSanId"), 0);
        String splitType = req.getParameter("splitType");
        if (datSanId <= 0 || splitType == null) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Thiếu datSanId hoặc splitType.");
            return;
        }
        if (!BillSplitType.IMPLEMENTED.contains(splitType)) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST,
                    "Chỉ hỗ trợ chia đều (EQUAL) hoặc tùy chỉnh (CUSTOM) ở giai đoạn hiện tại.");
            return;
        }

        int count = parseIntSafe(req.getParameter("participantCount"), 0);
        if (count < 2 || count > 50) {
            sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Số người tham gia phải từ 2 đến 50.");
            return;
        }

        List<BillSplitService.ParticipantInput> participants = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            String displayName = req.getParameter("participants[" + i + "].displayName");
            String accountIdStr = req.getParameter("participants[" + i + "].accountId");
            String amountStr = req.getParameter("participants[" + i + "].amount");

            Integer accountId = null;
            if (accountIdStr != null && !accountIdStr.isBlank()) {
                accountId = parseIntSafe(accountIdStr, 0);
                if (accountId <= 0) accountId = null;
            }
            BigDecimal amount = null;
            if (BillSplitType.CUSTOM.equals(splitType)) {
                if (amountStr == null || amountStr.isBlank()) {
                    sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng nhập số tiền cho mỗi người.");
                    return;
                }
                try {
                    amount = new BigDecimal(amountStr.trim());
                } catch (NumberFormatException e) {
                    sendJsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Số tiền không hợp lệ.");
                    return;
                }
            }
            participants.add(new BillSplitService.ParticipantInput(accountId, displayName, amount));
        }

        BillSplitService.Result r = billSplitService.createSplit(datSanId, user.getAccountId(), splitType, participants);
        writeResult(resp, r);
    }

    private void writeResult(HttpServletResponse resp, BillSplitService.Result r) throws IOException {
        if (r.success) {
            writeJson(resp, Map.of("success", true, "message", r.message,
                    "billSplitId", r.billSplitId != null ? r.billSplitId : 0));
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJson(resp, Map.of("success", false, "error", r.message));
        }
    }

    private TaiKhoan requireCustomer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            sendJsonError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập.");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_KHACH_HANG) {
            sendJsonError(resp, HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập.");
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
