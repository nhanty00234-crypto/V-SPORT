package org.example.controller.staff;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.model.CaLamViecAvailability;
import org.example.model.CaLamViecSwapRequest;
import org.example.model.CoSoFaceConfig;
import org.example.service.manager.CaLamService;
import org.example.dao.CaLamViecDAO;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
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
    private final CoSoFaceConfigDAO faceConfigDAO = new CoSoFaceConfigDAOImpl();

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

        CoSoFaceConfig faceConfig = user.getCoSoId() != null
            ? faceConfigDAO.findByCoSo(user.getCoSoId())
            : new CoSoFaceConfig();
        req.setAttribute("faceConfig", faceConfig);
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

        // Server-side faceRequired gate — block manual checkin/checkout if face attendance is mandatory
        CoSoFaceConfig faceConfigPost = user.getCoSoId() != null
            ? faceConfigDAO.findByCoSo(user.getCoSoId())
            : new CoSoFaceConfig();

        String action = req.getParameter("action");
        if (faceConfigPost.isFaceRequired() && ("checkIn".equals(action) || "checkOut".equals(action))) {
            session.setAttribute("error", "Điểm danh bằng khuôn mặt là bắt buộc. Vui lòng sử dụng tính năng nhận diện khuôn mặt.");
            resp.sendRedirect(req.getContextPath() + "/staff/ca-lam");
            return;
        }

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
            } else if ("confirmShift".equals(action) || "checkIn".equals(action) || "checkOut".equals(action)) {
                // Xác nhận lịch và điểm danh thủ công là quyền của Quản lý.
                // Nhân viên chỉ điểm danh qua nhận diện khuôn mặt (/face/checkin);
                // khi camera hỏng, quản lý tắt bắt buộc khuôn mặt và bấm hộ nhân viên.
                throw new IllegalArgumentException(
                        "Thao tác này do quản lý thực hiện. Vui lòng điểm danh bằng khuôn mặt "
                        + "hoặc liên hệ quản lý nếu camera gặp sự cố.");
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
            m.put("roleName", c.getRoleId() == 4 ? "Lễ tân" : "Bảo vệ");
            coworkersList.add(m);
        }
        data.put("coworkers", coworkersList);

        java.util.List<java.util.Map<String, Object>> availsList = new java.util.ArrayList<>();
        for (CaLamViecAvailability av : avails) {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("availabilityId", av.getAvailabilityId());
            m.put("ngay", av.getNgay() != null ? av.getNgay().toString() : "");
            m.put("gioBatDau", av.getGioBatDau() != null ? av.getGioBatDau().toString() : "");
            m.put("gioKetThuc", av.getGioKetThuc() != null ? av.getGioKetThuc().toString() : "");
            m.put("trangThai", av.getTrangThai());
            m.put("ghiChu", av.getGhiChu());
            m.put("duyetTrangThai", av.getDuyetTrangThai());
            m.put("phanHoi", av.getPhanHoi());
            availsList.add(m);
        }
        data.put("avails", availsList);

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
