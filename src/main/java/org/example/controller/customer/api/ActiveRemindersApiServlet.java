package org.example.controller.customer.api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CoSoDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.CoSo;
import org.example.model.Lichdatsan;
import org.example.model.San;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/customer/active-reminders")
public class ActiveRemindersApiServlet extends HttpServlet {

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final CoSoDAO coSoDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

        HttpSession session = req.getSession(false);
        TaiKhoan user = (session != null) ? (TaiKhoan) session.getAttribute("user") : null;

        if (user == null) {
            resp.getWriter().write("{\"loggedIn\":false,\"totalCount\":0,\"pendingPayments\":[],\"upcomingBookings\":[]}");
            return;
        }

        List<Lichdatsan> allLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());
        if (allLich == null || allLich.isEmpty()) {
            resp.getWriter().write("{\"loggedIn\":true,\"totalCount\":0,\"pendingPayments\":[],\"upcomingBookings\":[]}");
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        ZoneId zone = ZoneId.systemDefault();

        List<Lichdatsan> pendingPayments = new ArrayList<>();
        List<Lichdatsan> upcomingBookings = new ArrayList<>();

        for (Lichdatsan l : allLich) {
            String tt = l.getTrangThai();
            if (tt == null) continue;

            // 1. Tất cả đơn "Chờ thanh toán" (PayOS hoặc trả sau chưa hoàn tất)
            if ("Chờ thanh toán".equalsIgnoreCase(tt) || "Pending".equalsIgnoreCase(tt)) {
                pendingPayments.add(l);
            }

            // 2. Sắp tới giờ chơi (Đã xác nhận / Chờ xác nhận / Đã thanh toán)
            if ("Đã xác nhận".equalsIgnoreCase(tt) || "Chờ xác nhận".equalsIgnoreCase(tt) || "Đã thanh toán".equalsIgnoreCase(tt)) {
                if (l.getNgayDat() != null && l.getGioBatDau() != null) {
                    LocalDateTime startDt = LocalDateTime.of(l.getNgayDat(), l.getGioBatDau());
                    // Trong vòng 48h tới và chưa trôi qua quá 60 phút
                    if (startDt.isAfter(now.minusMinutes(60)) && startDt.isBefore(now.plusHours(48))) {
                        upcomingBookings.add(l);
                    }
                }
            }
        }

        int totalCount = pendingPayments.size() + upcomingBookings.size();

        StringBuilder sb = new StringBuilder();
        sb.append("{\"loggedIn\":true,");
        sb.append("\"totalCount\":").append(totalCount).append(",");

        // Build pendingPayments JSON Array
        sb.append("\"pendingPayments\":[");
        for (int i = 0; i < pendingPayments.size(); i++) {
            Lichdatsan p = pendingPayments.get(i);
            LocalDateTime expires = p.getHoldExpiresAt();
            if (expires == null && p.getCreatedTime() != null) {
                expires = p.getCreatedTime().plusMinutes(10);
            }
            long expiresEpochMs = (expires != null) ? expires.atZone(zone).toInstant().toEpochMilli() : 0;
            San s = sanDAO.getSanById(p.getSanId());
            CoSo c = (s != null) ? coSoDAO.getCoSoById(s.getCoSoID()) : null;

            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"datSanId\":").append(p.getDatSanId()).append(",")
              .append("\"tenSan\":\"").append(escapeJson(s != null ? s.getTenSan() : "")).append("\",")
              .append("\"tenCoSo\":\"").append(escapeJson(c != null ? c.getTenCoSo() : "")).append("\",")
              .append("\"ngayDat\":\"").append(p.getNgayDat()).append("\",")
              .append("\"gioBatDau\":\"").append(p.getGioBatDau()).append("\",")
              .append("\"gioKetThuc\":\"").append(p.getGioKetThuc()).append("\",")
              .append("\"tongTien\":").append(p.getTongTienDuKien() != null ? p.getTongTienDuKien() : 0).append(",")
              .append("\"expiresAtEpochMs\":").append(expiresEpochMs)
              .append("}");
        }
        sb.append("],");

        // Build upcomingBookings JSON Array
        sb.append("\"upcomingBookings\":[");
        for (int i = 0; i < upcomingBookings.size(); i++) {
            Lichdatsan u = upcomingBookings.get(i);
            LocalDateTime startDt = LocalDateTime.of(u.getNgayDat(), u.getGioBatDau());
            long startEpochMs = startDt.atZone(zone).toInstant().toEpochMilli();
            San s = sanDAO.getSanById(u.getSanId());
            CoSo c = (s != null) ? coSoDAO.getCoSoById(s.getCoSoID()) : null;

            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"datSanId\":").append(u.getDatSanId()).append(",")
              .append("\"tenSan\":\"").append(escapeJson(s != null ? s.getTenSan() : "")).append("\",")
              .append("\"tenCoSo\":\"").append(escapeJson(c != null ? c.getTenCoSo() : "")).append("\",")
              .append("\"ngayDat\":\"").append(u.getNgayDat()).append("\",")
              .append("\"gioBatDau\":\"").append(u.getGioBatDau()).append("\",")
              .append("\"gioKetThuc\":\"").append(u.getGioKetThuc()).append("\",")
              .append("\"startEpochMs\":").append(startEpochMs)
              .append("}");
        }
        sb.append("]");

        sb.append("}");
        resp.getWriter().write(sb.toString());
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "\\r")
                    .replace("\n", "\\n");
    }
}
