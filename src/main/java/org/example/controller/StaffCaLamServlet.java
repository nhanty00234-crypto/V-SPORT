package org.example.controller;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.model.CaLamViecAvailability;
import org.example.model.CaLamViecSwapRequest;
import org.example.service.manager.CaLamService;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/staff/ca-lam")
public class StaffCaLamServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(StaffCaLamServlet.class);
    private final CaLamService caLamService = new CaLamService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 4 && user.getRoleId() != 5)) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang này.");
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String format = req.getParameter("format");
        if ("json".equals(format)) {
            try {
                int coSoId = user.getCoSoId();
                int accountId = user.getAccountId();

                // 1. Only published shifts for the branch
                List<CaLamViec> shifts = caLamService.getShiftsByBranch(coSoId).stream()
                        .filter(s -> s.isPublished())
                        .collect(Collectors.toList());

                // 2. Coworkers list (for trading shifts)
                List<TaiKhoan> coworkers = caLamService.getStaffAvailableForShift(coSoId).stream()
                        .filter(st -> st.getAccountId() != accountId)
                        .collect(Collectors.toList());

                // 3. Current staff's registered availability (Removed)
                List<CaLamViecAvailability> avails = List.of();

                // 4. Swap requests involving this staff
                List<CaLamViecSwapRequest> swaps = caLamService.getSwapRequestsForStaff(accountId);

                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(buildJsonResponse(shifts, coworkers, avails, swaps));
            } catch (Exception e) {
                logger.error("Error loading staff shifts data: {}", e.getMessage(), e);
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            return;
        }

        req.getRequestDispatcher("/staff/CaLamViec.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 4 && user.getRoleId() != 5)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("requestSwap".equals(action)) {
                CaLamViecSwapRequest sr = new CaLamViecSwapRequest();
                sr.setAccountIdGui(user.getAccountId());
                sr.setCaLamViecIdGui(Integer.parseInt(req.getParameter("caLamViecIdGui")));
                sr.setAccountIdNhan(Integer.parseInt(req.getParameter("accountIdNhan")));
                
                String caNhanParam = req.getParameter("caLamViecIdNhan");
                if (caNhanParam != null && !caNhanParam.trim().isEmpty()) {
                    sr.setCaLamViecIdNhan(Integer.parseInt(caNhanParam));
                }
                
                sr.setLyDo(req.getParameter("lyDo"));
                caLamService.createSwapRequest(sr);
                session.setAttribute("message", "Đã gửi yêu cầu hoán đổi ca làm!");
            } else if ("respondSwap".equals(action)) {
                int swapId = Integer.parseInt(req.getParameter("id"));
                boolean accept = Boolean.parseBoolean(req.getParameter("accept"));
                caLamService.respondToSwapRequest(swapId, accept, user.getAccountId());
                session.setAttribute("message", accept ? "Đã đồng ý hoán đổi. Chờ quản lý phê duyệt." : "Đã từ chối hoán đổi.");
            } else if ("confirmShift".equals(action)) {
                int caLamViecId = Integer.parseInt(req.getParameter("caLamViecId"));
                caLamService.confirmShift(caLamViecId, user.getAccountId());
                session.setAttribute("message", "Đã xác nhận ca làm việc thành công!");
            } else if ("checkIn".equals(action)) {
                int caLamViecId = Integer.parseInt(req.getParameter("caLamViecId"));
                caLamService.checkInShift(caLamViecId, user.getAccountId());
                session.setAttribute("message", "Điểm danh ca làm thành công!");
            } else if ("checkOut".equals(action)) {
                int caLamViecId = Integer.parseInt(req.getParameter("caLamViecId"));
                caLamService.checkOutShift(caLamViecId, user.getAccountId());
                session.setAttribute("message", "Kết thúc ca làm thành công!");
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            logger.error("Error processing staff ca-lam request: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi xử lý yêu cầu.");
        }

        resp.sendRedirect(req.getContextPath() + "/staff/ca-lam");
    }

    private String buildJsonResponse(List<CaLamViec> shifts, List<TaiKhoan> coworkers,
                                      List<CaLamViecAvailability> avails, List<CaLamViecSwapRequest> swaps) {
        StringBuilder json = new StringBuilder();
        json.append("{\"shifts\":[");
        for (int i = 0; i < shifts.size(); i++) {
            CaLamViec s = shifts.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"caLamViecId\":").append(s.getCaLamViecId()).append(",");
            json.append("\"accountId\":").append(s.getAccountId()).append(",");
            json.append("\"coSoId\":").append(s.getCoSoId()).append(",");
            json.append("\"ngayLam\":\"").append(s.getNgayLam()).append("\",");
            json.append("\"gioBatDau\":\"").append(s.getGioBatDau()).append("\",");
            json.append("\"gioKetThuc\":\"").append(s.getGioKetThuc()).append("\",");
            json.append("\"isPublished\":").append(s.isPublished() ? "true" : "false").append(",");
            json.append("\"tenCa\":\"").append(escapeJson(s.getTenCa())).append("\",");
            json.append("\"viTri\":\"").append(escapeJson(s.getViTri())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(s.getTrangThai())).append("\",");
            json.append("\"gioNghi\":").append(s.getGioNghi()).append(",");
            json.append("\"ghiChu\":\"").append(escapeJson(s.getGhiChu())).append("\"");
            json.append("}");
        }
        json.append("],\"coworkers\":[");
        for (int i = 0; i < coworkers.size(); i++) {
            TaiKhoan c = coworkers.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"accountId\":").append(c.getAccountId()).append(",");
            json.append("\"username\":\"").append(escapeJson(c.getUsername())).append("\",");
            json.append("\"fullName\":\"").append(escapeJson(c.getFullName() != null ? c.getFullName() : c.getUsername())).append("\",");
            json.append("\"roleName\":\"").append(c.getRoleId() == 4 ? "Lễ tân" : "Bảo vệ").append("\"");
            json.append("}");
        }
        json.append("],\"avails\":[");
        for (int i = 0; i < avails.size(); i++) {
            CaLamViecAvailability av = avails.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"availabilityId\":").append(av.getAvailabilityId()).append(",");
            json.append("\"ngay\":\"").append(av.getNgay()).append("\",");
            json.append("\"gioBatDau\":\"").append(av.getGioBatDau()).append("\",");
            json.append("\"gioKetThuc\":\"").append(av.getGioKetThuc()).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(av.getTrangThai())).append("\",");
            json.append("\"ghiChu\":\"").append(escapeJson(av.getGhiChu())).append("\",");
            json.append("\"duyetTrangThai\":\"").append(escapeJson(av.getDuyetTrangThai())).append("\",");
            json.append("\"phanHoi\":\"").append(escapeJson(av.getPhanHoi())).append("\"");
            json.append("}");
        }
        json.append("],\"swaps\":[");
        for (int i = 0; i < swaps.size(); i++) {
            CaLamViecSwapRequest sw = swaps.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"swapRequestId\":").append(sw.getSwapRequestId()).append(",");
            json.append("\"accountIdGui\":").append(sw.getAccountIdGui()).append(",");
            json.append("\"accountIdNhan\":").append(sw.getAccountIdNhan()).append(",");
            json.append("\"tenNguoiGui\":\"").append(escapeJson(sw.getTenNguoiGui())).append("\",");
            json.append("\"tenNguoiNhan\":\"").append(escapeJson(sw.getTenNguoiNhan())).append("\",");
            json.append("\"caGuiInfo\":\"").append(escapeJson(sw.getCaGuiInfo())).append("\",");
            json.append("\"caNhanInfo\":\"").append(escapeJson(sw.getCaNhanInfo())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(sw.getTrangThai())).append("\",");
            json.append("\"lyDo\":\"").append(escapeJson(sw.getLyDo())).append("\"");
            json.append("}");
        }
        json.append("]}");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
