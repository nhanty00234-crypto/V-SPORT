package org.example.controller.staff;

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
import org.example.service.checkout.CheckoutResult;
import org.example.service.checkout.CheckoutService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import java.util.List;

import java.io.IOException;

/**
 * Servlet Ä‘iá»u phá»‘i luá»“ng nghiá»‡p vá»¥ Má»Ÿ SÃ¢n vÃ  Check-in.
 * Tiáº¿p nháº­n yÃªu cáº§u, kiá»ƒm tra phÃ¢n quyá»n vÃ  báº¯t lá»—i chi tiáº¿t tá»«ng ká»‹ch báº£n nghiá»‡p vá»¥.
 */
@WebServlet("/staff/checkin")
public class CheckInServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(CheckInServlet.class);

    private final CheckInDAO checkInDAO = new CheckInDAO();
    private final CheckoutService checkoutService = new CheckoutService();

    private boolean columnExists(java.sql.Connection conn, String tableName, String columnName) throws java.sql.SQLException {
        String sql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?";
        try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, tableName);
            ps.setNString(2, columnName);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private static final com.google.gson.Gson gson = new com.google.gson.GsonBuilder()
            .registerTypeAdapter(java.time.LocalDate.class, (com.google.gson.JsonSerializer<java.time.LocalDate>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .registerTypeAdapter(java.time.LocalTime.class, (com.google.gson.JsonSerializer<java.time.LocalTime>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .registerTypeAdapter(java.time.LocalDateTime.class, (com.google.gson.JsonSerializer<java.time.LocalDateTime>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. PhÃ¢n quyá» n (Authorization): Kiá»ƒm tra Role qua Session
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            // Không phải Manager (Role 2) hoặc Staff/Receptionist (Role 4)
            String action = req.getParameter("action");
            if (action != null || "true".equals(req.getParameter("ajax"))) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"error\":\"Phiên đăng nhập hết hạn hoặc bạn không có quyền truy cập.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            }
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
            data.put("danhSachSan", checkInDAO.getDanhSachSan(user.getCoSoId()));
            data.put("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay(user.getCoSoId()));
            
            resp.getWriter().write(gson.toJson(data));
            return;
        }

        // 2. Láº¥y dá»¯ liá»‡u hiá»ƒn thá»‹ lÃªn Dashboard
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan(user.getCoSoId()));
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay(user.getCoSoId()));

        // 3. Forward tá»›i giao diá»‡n JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        // 1. PhÃ¢n quyá»n (Authorization)
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");

        logger.info("CheckIn POST uri={}, contentType={}, contentLength={}, action={}, datSanId={}, roleId={}, coSoId={}, ajax={}",
                req.getRequestURI(), req.getContentType(), req.getContentLengthLong(), action, req.getParameter("datSanId"),
                user == null ? null : user.getRoleId(), user == null ? null : user.getCoSoId(),
                req.getHeader("X-Requested-With"));

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            if (isAjax(req, action)) {
                writeJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED,
                        errorJson("UNAUTHORIZED", "Phiên đăng nhập đã hết hạn."));
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            }
            return;
        }

        if (action == null || action.isBlank()) {
            if (isAjax(req, action)) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_ACTION", "Thiếu action."));
                return;
            }
        }

        if ("processPayment".equals(action)) {
            handleProcessPayment(req, resp, user);
            return;
        }
        if ("stopOpenSession".equals(action)) {
            handleStopOpenSession(req, resp, user);
            return;
        }
        if ("addServices".equals(action)) {
            handleAddServices(req, resp, user);
            return;
        }

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
                    // Gá» i DAO xá»­ lÃ½ nghiá»‡p vá»¥ check-in khÃ¡ch Ä‘áº·t trÆ°á»›c
                    // LuÃ´n kiá»ƒm tra tiá» n cá» c/thanh toÃ¡n (forcePaymentCheck = true)
                    checkInDAO.checkInKhachDatTruoc(datSanId, user.getAccountId(), true, daThuTienMat);
                } finally {
                    session.removeAttribute(lockKey);
                }
                successMsg = "Check-in thÃ nh cÃ´ng cho Ä‘Æ¡n Ä‘áº·t sÃ¢n #" + datSanId + "!";

            } else if ("checkInWalkIn".equals(action)) {
                // Nhận thông tin mở sân cho khách vãng lai
                String sanIdStr = req.getParameter("sanId");
                String durationStr = req.getParameter("duration");
                String donGiaStr = req.getParameter("donGia");
                String ghiChuOverride = req.getParameter("ghiChuOverride");
                String playMode = req.getParameter("playMode"); // "FIXED" or "OPEN"

                if (sanIdStr == null || durationStr == null || donGiaStr == null ||
                        sanIdStr.isEmpty() || durationStr.isEmpty() || donGiaStr.isEmpty()) {
                    throw new CheckInException("Vui lòng nhập đầy đủ thông tin mở sân vãng lai.");
                }

                int sanId = Integer.parseInt(sanIdStr);
                int duration = Integer.parseInt(durationStr);
                double donGia = Double.parseDouble(donGiaStr);

                if (duration <= 0) {
                    throw new CheckInException("Thời gian chơi phải lớn hơn 0 phút.");
                }
                if (donGia < 0) {
                    throw new CheckInException("Đơn giá sân không hợp lệ.");
                }

                // Backend validations
                SanDAO sanDAO = new SanDAOImpl();
                San targetSan = sanDAO.getSanById(sanId);
                if (targetSan == null) {
                    throw new CheckInException("Sân không tồn tại.");
                }
                if (targetSan.getCoSoID() != user.getCoSoId()) {
                    throw new CheckInException("Sân này không thuộc cơ sở của bạn.");
                }
                if (!"Sẵn sàng".equals(targetSan.getTrangThai())) {
                    throw new CheckInException("Sân không ở trạng thái Sẵn sàng để mở.");
                }

                // Get base price from LoaiSan
                org.example.dao.impl.LoaiSanDAOImpl loaiSanDAO = new org.example.dao.impl.LoaiSanDAOImpl();
                org.example.model.LoaiSan ls = loaiSanDAO.getLoaiSanById(targetSan.getLoaiSanID());
                double basePrice = 0.0;
                if (ls != null) {
                    basePrice = ls.getGiaKhongDen();
                    java.time.LocalTime nowTime = java.time.LocalTime.now();
                    if (org.example.service.manager.SanService.isLightingTime(
                            nowTime, ls.getGioBatDauLenDen(), ls.getGioKetThucLenDen())) {
                        basePrice = ls.getGiaCoDen();
                    }
                }

                // Price changes are not allowed for anyone in this feature. Always enforce the calculated base price.
                donGia = basePrice;

                String ghiChu = "Walk-in";
                if ("OPEN".equals(playMode)) {
                    ghiChu = "Walk-in [Không cố định] [duration: " + duration + "]";
                }
                if (ghiChuOverride != null && !ghiChuOverride.trim().isEmpty()) {
                    ghiChu += " [Ghi chú: " + ghiChuOverride.trim() + "]";
                }

                String lockKey = "walkin_lock_" + sanId;
                if (session.getAttribute(lockKey) != null) {
                    throw new CheckInException("Yêu cầu mở sân cho sân này đang được xử lý, vui lòng không bấm lại.");
                }
                session.setAttribute(lockKey, true);
                try {
                    checkInDAO.checkInKhachVangLai(sanId, duration, user.getAccountId(), donGia, ghiChu, playMode);
                } finally {
                    session.removeAttribute(lockKey);
                }
                successMsg = "Đã mở sân thành công cho khách vãng lai!";
            } else if ("cancelNoShow".equals(action)) {
                // Há»§y Ä‘Æ¡n Ä‘áº·t sÃ¢n do khÃ¡ch bÃ¹ng
                String datSanIdStr = req.getParameter("datSanId");
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiáº¿u ID Ä‘Æ¡n Ä‘áº·t sÃ¢n Ä‘á»ƒ há»§y.");
                }
                int datSanId = Integer.parseInt(datSanIdStr);
                checkInDAO.huyLichKhachBung(datSanId, user.getAccountId());
                successMsg = "Ä Ã£ há»§y thÃ nh cÃ´ng Ä‘Æ¡n Ä‘áº·t sÃ¢n #" + datSanId + " (KhÃ¡ch bÃ¹ng)!";
            } else if ("payInvoice".equals(action)) {
                String hoaDonIdStr = req.getParameter("hoaDonId");
                String paymentMethod = req.getParameter("phuongThucThanhToan");
                if (hoaDonIdStr == null || hoaDonIdStr.isEmpty()) {
                    throw new CheckInException("Thiếu ID hóa đơn cần thanh toán.");
                }
                if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                    paymentMethod = "Tiền mặt";
                }
                int hoaDonId = Integer.parseInt(hoaDonIdStr);
                checkInDAO.payInvoice(hoaDonId, user.getAccountId(), paymentMethod, user.getCoSoId());
                successMsg = "Đã thanh toán hóa đơn #" + hoaDonId + " thành công!";
            } else if ("applyEarlyCheckoutAdjustment".equals(action)) {
                if (user.getRoleId() != 1 && user.getRoleId() != 2) {
                    throw new CheckInException("Chỉ quản lý hoặc admin mới được thực hiện giảm trừ trả sân sớm.");
                }
                String datSanIdStr = req.getParameter("datSanId");
                String discountAmountStr = req.getParameter("earlyDiscount");
                String reason = req.getParameter("reason");

                if (datSanIdStr == null || discountAmountStr == null || reason == null ||
                        datSanIdStr.isEmpty() || discountAmountStr.isEmpty() || reason.trim().isEmpty()) {
                    throw new CheckInException("Vui lòng nhập đầy đủ thông tin giảm trừ.");
                }

                int datSanId = Integer.parseInt(datSanIdStr);
                double discountAmount = Double.parseDouble(discountAmountStr);

                checkInDAO.applyEarlyCheckoutAdjustment(datSanId, discountAmount, reason, user.getAccountId(), user.getCoSoId());
                
                // Write Audit Log
                org.example.service.AuditLogService.log(req, user, 
                    "EARLY_CHECKOUT_ADJUSTMENT", 
                    "LichDatSan", 
                    String.valueOf(datSanId), 
                    "Đơn đặt sân #" + datSanId, 
                    "Giảm trừ trả sân sớm: giảm " + discountAmount + "đ. Lý do: " + reason);

                successMsg = "Đã áp dụng giảm trừ trả sân sớm thành công!";
                req.setAttribute("autoOpenInvoiceDatSanId", datSanId);
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
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan(user.getCoSoId()));
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay(user.getCoSoId()));

        // Forward láº¡i trang JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }

    /**
     * Xử lý thanh toán hóa đơn (action=processPayment) và trả JSON {success, message, hoaDonId, printUrl}
     * để frontend điều hướng sang trang xem trước/in hóa đơn sau khi transaction đã commit thành công.
     * Idempotent: nếu hóa đơn đã ở trạng thái "Đã thanh toán" (double-click, reload), không xử lý tiền
     * lần hai mà chỉ trả về HoaDonID hiện có để in lại.
     */
    private void handleProcessPayment(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        logger.info("PAYMENT_REQUEST_RECEIVED datSanId={}", req.getParameter("datSanId"));
        try {
            String datSanIdStr = req.getParameter("datSanId");
            String paymentMethod = req.getParameter("phuongThucThanhToan");
            if (datSanIdStr == null || datSanIdStr.isBlank()) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_DAT_SAN_ID", "Thiếu ID đơn đặt sân để thanh toán."));
                return;
            }
            int datSanId = Integer.parseInt(datSanIdStr.trim());
            if (datSanId <= 0) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("INVALID_DAT_SAN_ID", "ID đơn đặt sân không hợp lệ."));
                return;
            }
            if (!"Tiền mặt".equals(paymentMethod) && !"Chuyển khoản".equals(paymentMethod)) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("INVALID_PAYMENT_METHOD", "Phương thức thanh toán không hợp lệ."));
                return;
            }
            logger.info("PAYMENT_VALIDATED datSanId={}, roleId={}, coSoId={}", datSanId, user.getRoleId(), user.getCoSoId());
            logger.info("PAYMENT_TRANSACTION_STARTED datSanId={}", datSanId);

            CheckoutResult result = checkoutService.pay(datSanId, user.getCoSoId(), user.getAccountId(), paymentMethod);
            int hoaDonId = result.hoaDonId();
            logger.info("PAYMENT_TRANSACTION_COMMITTED datSanId={}, hoaDonId={}", datSanId, hoaDonId);

            String printUrl = req.getContextPath() + "/staff/hoa-don/in?id=" + hoaDonId;

            com.google.gson.JsonObject json = new com.google.gson.JsonObject();
            json.addProperty("success", true);
            json.addProperty("message", result.alreadyPaid()
                    ? "Hóa đơn đã được thanh toán trước đó."
                    : "Đã hoàn thành thanh toán hóa đơn cho đơn đặt sân #" + datSanId + "!");
            json.addProperty("hoaDonId", hoaDonId);
            json.addProperty("printUrl", printUrl);
            logger.info("PAYMENT_PRINT_URL_CREATED datSanId={}, hoaDonId={}", datSanId, hoaDonId);
            writeJsonResponse(resp, HttpServletResponse.SC_OK, json);
            logger.info("PAYMENT_RESPONSE_SENT datSanId={}, hoaDonId={}", datSanId, hoaDonId);
        } catch (NumberFormatException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("INVALID_DAT_SAN_ID", "ID đơn đặt sân không hợp lệ."));
        } catch (SecurityException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN,
                    errorJson("FORBIDDEN", "Bạn không có quyền thanh toán hóa đơn này."));
        } catch (IllegalArgumentException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("VALIDATION_ERROR", e.getMessage()));
        } catch (IllegalStateException e) {
            logger.warn("PAYMENT_FAILED datSanId={}, reason={}", req.getParameter("datSanId"), e.getMessage());
            String code = e.getMessage() != null && e.getMessage().contains("SPLIT") ? "UNPAID_SPLIT_INVOICE" : "PAYMENT_CONFLICT";
            writeJsonResponse(resp, HttpServletResponse.SC_CONFLICT, errorJson(code, e.getMessage()));
        } catch (Exception e) {
            logger.error("PAYMENT_FAILED datSanId={}", req.getParameter("datSanId"), e);
            writeJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorJson("DATABASE_ERROR", "Không thể hoàn tất thanh toán. Dữ liệu đã được hoàn tác."));
        }
    }

    /**
     * Xử lý dừng ca chơi Không cố định (action=stopOpenSession): chốt ActualEndAt, tính tiền sân
     * theo CourtPricingService rồi trả JSON cho frontend mở modal Dịch vụ & Thanh toán.
     * Luôn trả JSON (kể cả khi lỗi) vì action này giờ chỉ được gọi qua fetch/AJAX.
     */
    private void handleStopOpenSession(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        String datSanIdStr = req.getParameter("datSanId");
        try {
            if (datSanIdStr == null || datSanIdStr.isBlank()) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_DAT_SAN_ID", "Thiếu ID đơn đặt sân để dừng."));
                return;
            }
            int datSanId = Integer.parseInt(datSanIdStr.trim());
            CheckoutResult result = checkoutService.finalizeSession(datSanId, user.getCoSoId());
            java.util.Map<String, Object> payload = new java.util.LinkedHashMap<>();
            payload.put("success", true);
            payload.put("datSanId", result.datSanId());
            payload.put("hoaDonId", result.hoaDonId());
            payload.put("actualEndAt", result.actualEndAt());
            payload.put("tongTienSan", result.tongTienSan());
            payload.put("tongTienDichVu", result.tongTienDichVu());
            payload.put("phiGuiXe", result.phiGuiXe());
            payload.put("giamGia", result.giamGia());
            payload.put("tongThanhToan", result.tongThanhToan());
            payload.put("segments", result.segments());
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setCharacterEncoding("UTF-8");
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write(gson.toJson(payload));
        } catch (NumberFormatException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("INVALID_DAT_SAN_ID", "ID đơn đặt sân không hợp lệ."));
        } catch (SecurityException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN,
                    errorJson("FORBIDDEN", "Ca chơi không thuộc cơ sở của bạn."));
        } catch (IllegalArgumentException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("VALIDATION_ERROR", e.getMessage()));
        } catch (IllegalStateException e) {
            logger.warn("STOP_SESSION_FAILED datSanId={}, reason={}", datSanIdStr, e.getMessage());
            writeJsonResponse(resp, HttpServletResponse.SC_CONFLICT,
                    errorJson("PAYMENT_CONFLICT", e.getMessage()));
        } catch (Exception e) {
            logger.error("STOP_SESSION_FAILED datSanId={}", datSanIdStr, e);
            writeJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorJson("INTERNAL_ERROR", "Không thể chốt giờ. Vui lòng thử lại."));
        }
    }

    /**
     * Xử lý thêm/cập nhật dịch vụ cho một ca chơi (action=addServices), luôn trả JSON.
     * Chỉ ghi nhận dịch vụ - không thanh toán, không hoàn thành booking, không đổi trạng thái sân.
     */
    private void handleAddServices(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        String datSanIdStr = req.getParameter("datSanId");
        try {
            if (datSanIdStr == null || datSanIdStr.isBlank()) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_DAT_SAN_ID", "Thiếu ID đơn đặt sân."));
                return;
            }
            int datSanId = Integer.parseInt(datSanIdStr.trim());

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

            String billMode = req.getParameter("billMode");
            com.google.gson.JsonObject json = new com.google.gson.JsonObject();
            json.addProperty("success", true);
            json.addProperty("billMode", billMode);
            json.addProperty("datSanId", datSanId);

            if ("SPLIT".equals(billMode)) {
                boolean payNow = "true".equals(req.getParameter("payNow"));
                String paymentMethod = req.getParameter("phuongThucThanhToan");
                if (payNow && (paymentMethod == null || paymentMethod.trim().isEmpty())) {
                    paymentMethod = "Tiền mặt";
                }
                int splitId = checkInDAO.addServicesSplitBill(datSanId, productIds, quantities,
                        payNow, paymentMethod, user.getAccountId(), user.getCoSoId());
                json.addProperty("splitId", splitId);
                json.addProperty("message", "Đã tạo hóa đơn tách dịch vụ #" + splitId
                        + (payNow ? " và thanh toán thành công!" : ". Hóa đơn đang chờ thanh toán."));
            } else {
                LichDatSanDAO lichDAO = new LichDatSanDAOImpl();
                lichDAO.updateDichVuDatSan(datSanId, productIds, quantities);
                json.addProperty("message", "Đã lưu dịch vụ.");
            }
            writeJsonResponse(resp, HttpServletResponse.SC_OK, json);
        } catch (NumberFormatException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("INVALID_DAT_SAN_ID", "ID đơn đặt sân không hợp lệ."));
        } catch (CheckInException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            logger.warn("ADD_SERVICES_FAILED datSanId={}, reason={}", datSanIdStr, e.getMessage());
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("VALIDATION_ERROR",
                            e.getMessage() != null ? e.getMessage() : "Không thể lưu dịch vụ. Vui lòng thử lại."));
        }
    }

    private boolean isAjax(HttpServletRequest req, String action) {
        String accept = req.getHeader("Accept");
        return "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                || (accept != null && accept.contains("application/json"))
                || "processPayment".equals(action);
    }

    private com.google.gson.JsonObject errorJson(String code, String message) {
        com.google.gson.JsonObject json = new com.google.gson.JsonObject();
        json.addProperty("success", false);
        json.addProperty("code", code);
        json.addProperty("message", message == null || message.isBlank() ? "Yêu cầu không thể xử lý." : message);
        return json;
    }

    private void writeJsonResponse(HttpServletResponse response, int status, com.google.gson.JsonObject body)
            throws IOException {
        if (!response.isCommitted()) {
            response.resetBuffer();
        }
        response.setStatus(status);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(body.toString());
        response.getWriter().flush();
    }

    private void handleGetInvoiceDetails(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws ServletException, IOException {
        try {
            int datSanId = Integer.parseInt(req.getParameter("datSanId"));
            LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
            Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
            if (lich == null) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"error\":\"Không tìm thấy đơn đặt sân.\"}");
                return;
            }

            SanDAO sanDAO = new SanDAOImpl();
            San san = sanDAO.getSanById(lich.getSanId());
            if (user.getRoleId() == 4 && san.getCoSoID() != user.getCoSoId()) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                resp.getWriter().write("{\"error\":\"Bạn không có quyền truy cập đơn đặt sân thuộc cơ sở khác.\"}");
                return;
            }

            int coSoId = san.getCoSoID();

            org.example.dao.SanPhamDichVuDAO spDao = new org.example.dao.impl.SanPhamDichVuDAOImpl();
            List<org.example.model.SanPham_DichVu> allSp = spDao.findByCoSo(coSoId);
            List<org.example.model.SanPham_DichVu> products = allSp.stream()
                .filter(sp -> !"Ngừng kinh doanh".equals(sp.getTrangThai()))
                .collect(java.util.stream.Collectors.toList());

            org.example.dao.HoaDonDAO hdDao = new org.example.dao.impl.HoaDonDAOImpl();
            int hoaDonId = -1;
            double tongTienSan = lich.getTongTienDuKien() != null ? lich.getTongTienDuKien().doubleValue() : 0.0;
            double tongTienDichVu = 0.0;
            double tongThanhToan = tongTienSan;
            double giamGia = 0.0;
            double phiGuiXe = 0.0;
            String trangThaiThanhToan = "Chưa thanh toán";

            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {
                boolean hasLoaiHoaDon = columnExists(conn, "HoaDon", "LoaiHoaDon");
                String invoiceSql = "SELECT HoaDonID, TongTienSan, TongTienDichVu, TongThanhToan, TrangThaiThanhToan, GiamGia, PhiGuiXe FROM HoaDon WHERE DatSanID = ?" +
                        (hasLoaiHoaDon ? " AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)" : "");
                try (java.sql.PreparedStatement ps = conn.prepareStatement(invoiceSql)) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hoaDonId = rs.getInt("HoaDonID");
                        tongTienSan = rs.getDouble("TongTienSan");
                        tongTienDichVu = rs.getDouble("TongTienDichVu");
                        tongThanhToan = rs.getDouble("TongThanhToan");
                        trangThaiThanhToan = rs.getString("TrangThaiThanhToan");
                        giamGia = rs.getDouble("GiamGia");
                        phiGuiXe = rs.getDouble("PhiGuiXe");
                    }
                }
                }
            } catch (java.sql.SQLException sqlEx) {
                // Fallback: LoaiHoaDon column may not exist yet
                try (java.sql.Connection conn2 = org.example.util.DBUtil.getConnection();
                     java.sql.PreparedStatement ps2 = conn2.prepareStatement("SELECT HoaDonID, TongTienSan, TongTienDichVu, TongThanhToan, TrangThaiThanhToan, GiamGia, PhiGuiXe FROM HoaDon WHERE DatSanID = ?")) {
                    ps2.setInt(1, datSanId);
                    try (java.sql.ResultSet rs2 = ps2.executeQuery()) {
                        if (rs2.next()) {
                            hoaDonId = rs2.getInt("HoaDonID");
                            tongTienSan = rs2.getDouble("TongTienSan");
                            tongTienDichVu = rs2.getDouble("TongTienDichVu");
                            tongThanhToan = rs2.getDouble("TongThanhToan");
                            trangThaiThanhToan = rs2.getString("TrangThaiThanhToan");
                            giamGia = rs2.getDouble("GiamGia");
                            phiGuiXe = rs2.getDouble("PhiGuiXe");
                        }
                    }
                }
            }

            // Tính toán đơn giá giờ và phụ thu quá giờ tại thời điểm xem modal (chỉ dành cho đơn Đang sử dụng)
            double donGiaGio = 0.0;
            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement(
                     "SELECT ls.GiaCoDen, ls.GiaKhongDen, lds.ApDungGiaCoDen " +
                     "FROM LichDatSan lds " +
                     "INNER JOIN San s ON lds.SanID = s.SanID " +
                     "INNER JOIN LoaiSan ls ON s.LoaiSanID = ls.LoaiSanID " +
                     "WHERE lds.DatSanID = ?")) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        boolean apDungGiaCoDen = rs.getBoolean("ApDungGiaCoDen");
                        donGiaGio = apDungGiaCoDen ? rs.getDouble("GiaCoDen") : rs.getDouble("GiaKhongDen");
                    }
                }
            }

            double phuThuQuaGio = 0.0;
            long minutesOver = 0;
            boolean isEarly = false;
            long minutesEarly = 0;

            if ("OPEN_ENDED".equals(lich.getTimeMode())) {
                if ("Đang sử dụng".equals(lich.getTrangThai())) {
                    java.time.LocalTime start = (lich.getActualStartTime() != null ? lich.getActualStartTime() : lich.getGioBatDau());
                    java.time.LocalTime end = java.time.LocalTime.now();
                    long elapsedMins = java.time.Duration.between(start, end).toMinutes();
                    if (elapsedMins < 0) {
                        elapsedMins += 24 * 60;
                    }
                    if (elapsedMins < 15) {
                        elapsedMins = 15;
                    }
                    tongTienSan = (elapsedMins / 60.0) * donGiaGio;
                }
            } else {
                // FIXED_DURATION or FIXED_BOOKING or fallback
                if ("Đang sử dụng".equals(lich.getTrangThai()) && lich.getNgayDat() != null && lich.getGioKetThuc() != null) {
                    java.time.LocalDateTime plannedEnd = java.time.LocalDateTime.of(lich.getNgayDat(), lich.getGioKetThuc());
                    java.time.LocalDateTime now = java.time.LocalDateTime.now();
                    if (now.isAfter(plannedEnd)) {
                        minutesOver = java.time.Duration.between(plannedEnd, now).toMinutes();
                        if (minutesOver > 10) { // Grace period: 10 mins
                            long overMinutes = minutesOver - 10;
                            phuThuQuaGio = overMinutes * (donGiaGio / 60.0);
                        }
                    } else if (now.isBefore(plannedEnd)) {
                        isEarly = true;
                        minutesEarly = java.time.Duration.between(now, plannedEnd).toMinutes();
                    }
                }
            }

            double phuThuNhanSom = 0.0;
            double finalTongTienSan = tongTienSan + phuThuQuaGio;
            double finalTongThanhToan = finalTongTienSan + tongTienDichVu;

            double proposedEarlyDiscount = 0.0;
            if (isEarly && minutesEarly > 0) {
                proposedEarlyDiscount = (minutesEarly / 60.0) * donGiaGio;
                proposedEarlyDiscount = Math.round(proposedEarlyDiscount / 1000.0) * 1000.0;
                if (proposedEarlyDiscount > finalTongTienSan) {
                    proposedEarlyDiscount = finalTongTienSan;
                }
            }

            List<org.example.model.ChiTietHoaDon> ordered = new java.util.ArrayList<>();
            if (hoaDonId != -1) {
                ordered = hdDao.getChiTietByHoaDonId(hoaDonId);
            }
            List<java.util.Map<String, Object>> orderedMaps = chiTietHoaDonToMaps(ordered);

            // Lấy danh sách split bills và chi tiết của chúng
            boolean mainBillPaid = "Đã thanh toán".equals(trangThaiThanhToan);
            java.util.List<java.util.Map<String, Object>> splitBills = new java.util.ArrayList<>();
            try (java.sql.Connection connSplit = org.example.util.DBUtil.getConnection()) {
                if (!columnExists(connSplit, "HoaDon", "LoaiHoaDon")) {
                    throw new java.sql.SQLException("HoaDon.LoaiHoaDon chưa tồn tại");
                }
                boolean hasGhiChu = columnExists(connSplit, "HoaDon", "GhiChu");
                String sqlSplits = "SELECT hd.HoaDonID, hd.TongThanhToan, hd.TrangThaiThanhToan, " +
                                   (hasGhiChu ? "hd.GhiChu" : "CAST(NULL AS NVARCHAR(500)) AS GhiChu") + ", hd.NgayLap " +
                                   "FROM HoaDon hd WHERE hd.DatSanID = ? AND hd.LoaiHoaDon = N'SPLIT' ORDER BY hd.NgayLap ASC";
                try (java.sql.PreparedStatement psSplit = connSplit.prepareStatement(sqlSplits)) {
                psSplit.setInt(1, datSanId);
                try (java.sql.ResultSet rsSplit = psSplit.executeQuery()) {
                    while (rsSplit.next()) {
                        java.util.Map<String, Object> sb = new java.util.HashMap<>();
                        int sbHdId = rsSplit.getInt("HoaDonID");
                        sb.put("hoaDonId", sbHdId);
                        sb.put("tongThanhToan", rsSplit.getDouble("TongThanhToan"));
                        sb.put("trangThai", rsSplit.getString("TrangThaiThanhToan"));
                        sb.put("ghiChu", rsSplit.getString("GhiChu"));
                        sb.put("ngayLap", rsSplit.getTimestamp("NgayLap") != null
                                ? rsSplit.getTimestamp("NgayLap").toString().substring(0, 16) : "");
                        sb.put("items", chiTietHoaDonToMaps(hdDao.getChiTietByHoaDonId(sbHdId)));
                        splitBills.add(sb);
                    }
                }
                }
            } catch (Exception ignored) {
                // Bảng HoaDon chưa có cột LoaiHoaDon → bỏ qua, splitBills = []
            }

            resp.setContentType("application/json;charset=UTF-8");
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("products", products);
            data.put("ordered", orderedMaps);
            data.put("donGiaGio", donGiaGio);
            data.put("minutesOver", minutesOver);
            data.put("phuThuQuaGio", phuThuQuaGio);
            data.put("phuThuNhanSom", phuThuNhanSom);
            data.put("tongTienSan", finalTongTienSan);
            data.put("tongTienDichVu", tongTienDichVu);
            data.put("tongThanhToan", finalTongThanhToan);
            data.put("trangThaiThanhToan", trangThaiThanhToan);
            data.put("mainBillPaid", mainBillPaid);
            data.put("mainHoaDonId", hoaDonId);
            data.put("splitBills", splitBills);
            data.put("tenSan", san.getTenSan());
            data.put("ngayDat", lich.getNgayDat() != null ? lich.getNgayDat().toString() : "");
            data.put("gioBatDau", lich.getGioBatDau() != null ? lich.getGioBatDau().toString().substring(0, 5) : "00:00");
            data.put("gioKetThuc", lich.getGioKetThuc() != null ? lich.getGioKetThuc().toString().substring(0, 5) : "00:00");
            data.put("timeMode", lich.getTimeMode());
            data.put("isEarly", isEarly);
            data.put("minutesEarly", minutesEarly);
            data.put("earlyCheckoutDiscount", lich.getEarlyCheckoutDiscount() != null ? lich.getEarlyCheckoutDiscount().doubleValue() : 0.0);
            data.put("earlyCheckoutReason", lich.getEarlyCheckoutReason() != null ? lich.getEarlyCheckoutReason() : "");
            data.put("proposedEarlyDiscount", proposedEarlyDiscount);
            data.put("giamGia", giamGia);
            data.put("phiGuiXe", phiGuiXe);
            data.put("bookingTrangThai", lich.getTrangThai());
            data.put("actualEndAt", lich.getActualEndAt() != null ? lich.getActualEndAt().toString() : null);
            resp.getWriter().write(gson.toJson(data));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setContentType("application/json;charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            java.util.Map<String, String> err = new java.util.HashMap<>();
            err.put("error", e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống");
            resp.getWriter().write(gson.toJson(err));
        }
    }

    /**
     * Chuyển ChiTietHoaDon (JPA entity với lazy relationships) sang plain map
     * để tránh LazyInitializationException khi Gson serialize.
     */
    private java.util.List<java.util.Map<String, Object>> chiTietHoaDonToMaps(List<org.example.model.ChiTietHoaDon> list) {
        java.util.List<java.util.Map<String, Object>> result = new java.util.ArrayList<>();
        for (org.example.model.ChiTietHoaDon ct : list) {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("ChiTietID", ct.getChiTietID());
            m.put("HoaDonID", ct.getHoaDonID());
            m.put("SanPhamID", ct.getSanPhamID());
            m.put("SoLuong", ct.getSoLuong());
            m.put("DonGiaTaiThoiDiemBan", ct.getDonGiaTaiThoiDiemBan());
            m.put("ThanhTien", ct.getThanhTien());
            result.add(m);
        }
        return result;
    }
}
