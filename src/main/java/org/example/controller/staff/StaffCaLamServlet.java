package org.example.controller.staff;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.model.CaLamViecSwapRequest;
import org.example.service.manager.CaLamService;
import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.util.AttendanceWindow;
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
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || user.getRoleId() != Constants.ROLE_LE_TAN) {
            session.setAttribute("error", "Bạn không có quyền truy cập trang này.");
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String format = req.getParameter("format");
        if ("json".equals(format)) {
            try {
                int coSoId = user.getCoSoId();
                int accountId = user.getAccountId();

                // 1. Only THIS staff's own published shifts — ±4 weeks window for week navigation
                LocalDate windowStart = LocalDate.now().minusWeeks(4);
                LocalDate windowEnd = LocalDate.now().plusWeeks(8);
                List<CaLamViec> shifts = caLamViecDAO.getCaByAccountIDAndDateRange(accountId, windowStart, windowEnd)
                        .stream()
                        .filter(AttendanceWindow::visibleToStaff)
                        .collect(Collectors.toList());

                // 2. Coworkers list (for swap requests)
                List<TaiKhoan> coworkers = caLamService.getStaffAvailableForShift(coSoId).stream()
                        .filter(st -> st.getAccountId() != accountId)
                        .collect(Collectors.toList());

                // 3. Swap requests involving this staff
                List<CaLamViecSwapRequest> swaps = caLamService.getSwapRequestsForStaff(accountId);

                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(buildJsonResponse(shifts, coworkers, swaps));
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

        if (user == null || user.getRoleId() != Constants.ROLE_LE_TAN) {
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
                                      List<CaLamViecSwapRequest> swaps) {
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        
        java.util.List<java.util.Map<String, Object>> shiftsList = new java.util.ArrayList<>();
        for (CaLamViec s : shifts) {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("caLamViecId", s.getCaLamViecId());
            m.put("accountId", s.getAccountId());
            m.put("coSoId", s.getCoSoId());
            m.put("ngayLam", s.getNgayLam() != null ? s.getNgayLam().toString() : "");
            m.put("gioBatDau", s.getGioBatDau() != null ? s.getGioBatDau().toString() : "");
            m.put("gioKetThuc", s.getGioKetThuc() != null ? s.getGioKetThuc().toString() : "");
            m.put("isPublished", s.isPublished());
            m.put("tenCa", s.getTenCa());
            m.put("viTri", s.getViTri());
            m.put("trangThai", s.getTrangThai());
            m.put("gioNghi", s.getGioNghi());
            m.put("ghiChu", s.getGhiChu());
            m.put("gioVaoThuc", s.getGioVaoThuc() != null ? s.getGioVaoThuc().toString() : null);
            m.put("gioRaThuc", s.getGioRaThuc() != null ? s.getGioRaThuc().toString() : null);
            shiftsList.add(m);
        }
        data.put("shifts", shiftsList);

        java.util.List<java.util.Map<String, Object>> coworkersList = new java.util.ArrayList<>();
        for (TaiKhoan c : coworkers) {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("accountId", c.getAccountId());
            m.put("username", c.getUsername());
            m.put("fullName", c.getFullName() != null ? c.getFullName() : c.getUsername());
            m.put("roleName", "Lễ tân");
            coworkersList.add(m);
        }
        data.put("coworkers", coworkersList);

        // Đăng ký giờ rảnh đã bị gỡ khỏi schema V2 — giữ khoá rỗng để JS phía client không lỗi.
        data.put("avails", new java.util.ArrayList<>());

        java.util.List<java.util.Map<String, Object>> swapsList = new java.util.ArrayList<>();
        for (CaLamViecSwapRequest sw : swaps) {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("swapRequestId", sw.getSwapRequestId());
            m.put("accountIdGui", sw.getAccountIdGui());
            m.put("accountIdNhan", sw.getAccountIdNhan());
            m.put("tenNguoiGui", sw.getTenNguoiGui());
            m.put("tenNguoiNhan", sw.getTenNguoiNhan());
            m.put("caGuiInfo", sw.getCaGuiInfo());
            m.put("caNhanInfo", sw.getCaNhanInfo());
            m.put("trangThai", sw.getTrangThai());
            m.put("lyDo", sw.getLyDo());
            swapsList.add(m);
        }
        data.put("swaps", swapsList);

        return new com.google.gson.Gson().toJson(data);
    }
}
