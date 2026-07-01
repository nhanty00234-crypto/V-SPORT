package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CheckInDAO;
import org.example.dao.CheckInDAO.CheckInException;
import org.example.dao.CheckInDAO.PaymentRequiredException;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.SanDAO;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.model.San;
import org.example.model.TaiKhoan;
import java.util.List;

import java.io.IOException;

/**
 * Servlet Ä‘iá»u phá»‘i luá»“ng nghiá»‡p vá»¥ Má»Ÿ SÃ¢n vÃ  Check-in.
 * Tiáº¿p nháº­n yÃªu cáº§u, kiá»ƒm tra phÃ¢n quyá»n vÃ  báº¯t lá»—i chi tiáº¿t tá»«ng ká»‹ch báº£n nghiá»‡p vá»¥.
 */
@WebServlet("/staff/checkin")
public class CheckInServlet extends HttpServlet {

    private final CheckInDAO checkInDAO = new CheckInDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. PhÃ¢n quyá» n (Authorization): Kiá»ƒm tra Role qua Session
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            // Không phải Manager (Role 2) hoặc Staff/Receptionist (Role 4)
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            return;
        }

        String action = req.getParameter("action");
        if ("getInvoiceDetails".equals(action)) {
            handleGetInvoiceDetails(req, resp, user);
            return;
        }

        // Kiá»ƒm tra náº¿u lÃ  yÃªu cáº§u cáº­p nháº­t ngáº§m AJAX (Polling)
        String isAjax = req.getParameter("ajax");
        if ("true".equals(isAjax)) {
            resp.setContentType("application/json;charset=UTF-8");
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("danhSachSan", checkInDAO.getDanhSachSan());
            data.put("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay());
            
            resp.getWriter().write(new com.google.gson.Gson().toJson(data));
            return;
        }

        // 2. Láº¥y dá»¯ liá»‡u hiá»ƒn thá»‹ lÃªn Dashboard
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan());
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay());

        // 3. Forward tá»›i giao diá»‡n JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. PhÃ¢n quyá»n (Authorization)
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Báº¡n khÃ´ng cÃ³ quyá»n truy cáº­p chá»©c nÄƒng nÃ y!");
            return;
        }

        String action = req.getParameter("action");
        String successMsg = null;
        String errorMsg = null;

        try {
            if ("checkInPreBooked".equals(action)) {
                // Nháº­n thÃ´ng tin check-in khÃ¡ch Ä‘áº·t trÆ°á»›c
                String datSanIdStr = req.getParameter("datSanId");
                String daThuTienMatStr = req.getParameter("daThuTienMat");
                
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiáº¿u ID Ä‘Æ¡n Ä‘áº·t sÃ¢n.");
                }

                int datSanId = Integer.parseInt(datSanIdStr);
                boolean daThuTienMat = "true".equals(daThuTienMatStr);

                String lockKey = "checkin_lock_" + datSanId;
                if (session.getAttribute(lockKey) != null) {
                    throw new CheckInException("YÃªu cáº§u check-in cho Ä‘Æ¡n Ä‘áº·t sÃ¢n nÃ y Ä‘ang Ä‘Æ°á»£c xá»­ lÃ½, vui lÃ²ng khÃ´ng báº¥m láº¡i.");
                }
                session.setAttribute(lockKey, true);
                try {
                    // Gá»i DAO xá»­ lÃ½ nghiá»‡p vá»¥ check-in khÃ¡ch Ä‘áº·t trÆ°á»›c
                    // LuÃ´n kiá»ƒm tra tiá»n cá»c/thanh toÃ¡n (forcePaymentCheck = true)
                    checkInDAO.checkInKhachDatTruoc(datSanId, user.getAccountId(), true, daThuTienMat);
                } finally {
                    session.removeAttribute(lockKey);
                }
                successMsg = "Check-in thÃ nh cÃ´ng cho Ä‘Æ¡n Ä‘áº·t sÃ¢n #" + datSanId + "!";

            } else if ("checkInWalkIn".equals(action)) {
                // Nháº­n thÃ´ng tin má»Ÿ sÃ¢n cho khÃ¡ch vÃ£ng lai
                String sanIdStr = req.getParameter("sanId");
                String durationStr = req.getParameter("duration");
                String donGiaStr = req.getParameter("donGia");

                if (sanIdStr == null || durationStr == null || donGiaStr == null ||
                        sanIdStr.isEmpty() || durationStr.isEmpty() || donGiaStr.isEmpty()) {
                    throw new CheckInException("Vui lÃ²ng nháº­p Ä‘áº§y Ä‘á»§ thÃ´ng tin má»Ÿ sÃ¢n vÃ£ng lai.");
                }

                int sanId = Integer.parseInt(sanIdStr);
                int duration = Integer.parseInt(durationStr);
                double donGia = Double.parseDouble(donGiaStr);

                if (duration <= 0) {
                    throw new CheckInException("Thá»i gian chÆ¡i pháº£i lá»›n hÆ¡n 0 phÃºt.");
                }
                if (donGia < 0) {
                    throw new CheckInException("ÄÆ¡n giÃ¡ sÃ¢n khÃ´ng há»£p lá»‡.");
                }

                String lockKey = "walkin_lock_" + sanId;
                if (session.getAttribute(lockKey) != null) {
                    throw new CheckInException("YÃªu cáº§u má»Ÿ sÃ¢n cho sÃ¢n nÃ y Ä‘ang Ä‘Æ°á»£c xá»­ lÃ½, vui lÃ²ng khÃ´ng báº¥m láº¡i.");
                }
                session.setAttribute(lockKey, true);
                try {
                    // Gá»i DAO xá»­ lÃ½ má»Ÿ sÃ¢n khÃ¡ch vÃ£ng lai
                    checkInDAO.checkInKhachVangLai(sanId, duration, user.getAccountId(), donGia);
                } finally {
                    session.removeAttribute(lockKey);
                }
                successMsg = "ÄÃ£ má»Ÿ sÃ¢n thÃ nh cÃ´ng cho khÃ¡ch vÃ£ng lai!";
            } else if ("cancelNoShow".equals(action)) {
                // Há»§y Ä‘Æ¡n Ä‘áº·t sÃ¢n do khÃ¡ch bÃ¹ng
                String datSanIdStr = req.getParameter("datSanId");
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiáº¿u ID Ä‘Æ¡n Ä‘áº·t sÃ¢n Ä‘á»ƒ há»§y.");
                }
                int datSanId = Integer.parseInt(datSanIdStr);
                checkInDAO.huyLichKhachBung(datSanId, user.getAccountId());
                successMsg = "Ä Ã£ há»§y thÃ nh cÃ´ng Ä‘Æ¡n Ä‘áº·t sÃ¢n #" + datSanId + " (KhÃ¡ch bÃ¹ng)!";
            } else if ("addServices".equals(action)) {
                String datSanIdStr = req.getParameter("datSanId");
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiếu ID đơn đặt sân.");
                }
                int datSanId = Integer.parseInt(datSanIdStr);

                String[] spIdsStr = req.getParameterValues("productId");
                String[] qtysStr = req.getParameterValues("quantity");

                int[] productIds = new int[0];
                int[] quantities = new int[0];

                if (spIdsStr != null && qtysStr != null) {
                    int count = spIdsStr.length;
                    productIds = new int[count];
                    quantities = new int[count];
                    for (int i = 0; i < count; i++) {
                        productIds[i] = Integer.parseInt(spIdsStr[i]);
                        quantities[i] = Integer.parseInt(qtysStr[i]);
                    }
                }

                LichDatSanDAO lichDAO = new LichDatSanDAOImpl();
                lichDAO.updateDichVuDatSan(datSanId, productIds, quantities);
                successMsg = "Đã cập nhật dịch vụ thành công cho đơn đặt sân #" + datSanId + "!";
            } else if ("processPayment".equals(action)) {
                String datSanIdStr = req.getParameter("datSanId");
                String paymentMethod = req.getParameter("phuongThucThanhToan");
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiếu ID đơn đặt sân để thanh toán.");
                }
                if (paymentMethod == null || paymentMethod.isEmpty()) {
                    paymentMethod = "Tiền mặt";
                }
                int datSanId = Integer.parseInt(datSanIdStr);

                LichDatSanDAO lichDAO = new LichDatSanDAOImpl();
                lichDAO.thanhToanHoaDonDatSan(datSanId, user.getAccountId(), paymentMethod);
                successMsg = "Đã hoàn thành thanh toán hóa đơn cho đơn đặt sân #" + datSanId + "!";
            } else {
                throw new CheckInException("HÃ nh Ä‘á»™ng khÃ´ng há»£p lá»‡.");
            }
        } catch (PaymentRequiredException e) {
            // TrÆ°á» ng há»£p lá»—i yÃªu cáº§u thanh toÃ¡n/cá» c:
            // Ä Ã¡nh dáº¥u Ä‘á»ƒ hiá»ƒn thá»‹ há»™p thoáº¡i xÃ¡c nháº­n thu tiá» n máº·t cho Lá»… tÃ¢n
            errorMsg = e.getMessage();
            req.setAttribute("paymentRequired", true);
            req.setAttribute("datSanIdPending", req.getParameter("datSanId"));
        } catch (NumberFormatException e) {
            errorMsg = "Lá»—i Ä‘á»‹nh dáº¡ng dá»¯ liá»‡u Ä‘áº§u vÃ o.";
        } catch (CheckInException e) {
            // CÃ¡c ká»‹ch báº£n lá»—i nghiá»‡p vá»¥ (trÃ¹ng lá»‹ch, sÃ¢n báº­n, xung Ä‘á»™t ghi dá»¯ liá»‡u Ä‘á»“ng thá»i...)
            errorMsg = e.getMessage();
        } catch (Exception e) {
            errorMsg = "Lá»—i há»‡ thá»‘ng báº¥t ngá»: " + e.getMessage();
        }

        // Thiáº¿t láº­p thÃ´ng Ä‘iá»‡p thÃ´ng bÃ¡o
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
        }
        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
        }

        // Táº£i láº¡i dá»¯ liá»‡u lÃªn trang dashboard
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan());
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay());

        // Forward láº¡i trang JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }

    private void handleGetInvoiceDetails(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws ServletException, IOException {
        try {
            int datSanId = Integer.parseInt(req.getParameter("datSanId"));
            LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
            Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
            if (lich == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn đặt sân.");
                return;
            }

            SanDAO sanDAO = new SanDAOImpl();
            San san = sanDAO.getSanById(lich.getSanId());
            if (user.getRoleId() == 4 && san.getCoSoID() != user.getCoSoId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập đơn đặt sân thuộc cơ sở khác.");
                return;
            }

            int coSoId = san.getCoSoID();

            org.example.dao.SanPhamDichVuDAO spDao = new org.example.dao.impl.SanPhamDichVuDAOImpl();
            List<org.example.model.SanPham_DichVu> allSp = spDao.findByCoSo(coSoId);
            List<org.example.model.SanPham_DichVu> products = allSp.stream()
                .filter(sp -> "Đang kinh doanh".equals(sp.getTrangThai()))
                .collect(java.util.stream.Collectors.toList());

            org.example.dao.HoaDonDAO hdDao = new org.example.dao.impl.HoaDonDAOImpl();
            int hoaDonId = -1;
            double tongTienSan = lich.getTongTienDuKien() != null ? lich.getTongTienDuKien().doubleValue() : 0.0;
            double tongTienDichVu = 0.0;
            double tongThanhToan = tongTienSan;
            String trangThaiThanhToan = "Chưa thanh toán";

            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement("SELECT HoaDonID, TongTienSan, TongTienDichVu, TongThanhToan, TrangThaiThanhToan FROM HoaDon WHERE DatSanID = ?")) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hoaDonId = rs.getInt("HoaDonID");
                        tongTienSan = rs.getDouble("TongTienSan");
                        tongTienDichVu = rs.getDouble("TongTienDichVu");
                        tongThanhToan = rs.getDouble("TongThanhToan");
                        trangThaiThanhToan = rs.getString("TrangThaiThanhToan");
                    }
                }
            }

            List<org.example.model.ChiTietHoaDon> ordered = new java.util.ArrayList<>();
            if (hoaDonId != -1) {
                ordered = hdDao.getChiTietByHoaDonId(hoaDonId);
            }

            resp.setContentType("application/json;charset=UTF-8");
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("products", products);
            data.put("ordered", ordered);
            data.put("tongTienSan", tongTienSan);
            data.put("tongTienDichVu", tongTienDichVu);
            data.put("tongThanhToan", tongThanhToan);
            data.put("trangThaiThanhToan", trangThaiThanhToan);
            data.put("tenSan", san.getTenSan());
            data.put("ngayDat", lich.getNgayDat().toString());
            data.put("gioBatDau", lich.getGioBatDau().toString().substring(0, 5));
            data.put("gioKetThuc", lich.getGioKetThuc().toString().substring(0, 5));
            resp.getWriter().write(new com.google.gson.Gson().toJson(data));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
