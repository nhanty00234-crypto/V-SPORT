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
import org.example.model.TaiKhoan;

import java.io.IOException;

/**
 * Servlet điều phối luồng nghiệp vụ Mở Sân và Check-in.
 * Tiếp nhận yêu cầu, kiểm tra phân quyền và bắt lỗi chi tiết từng kịch bản nghiệp vụ.
 */
@WebServlet("/staff/checkin")
public class CheckInServlet extends HttpServlet {

    private final CheckInDAO checkInDAO = new CheckInDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Phân quyền (Authorization): Kiểm tra Role qua Session
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            // Không phải Manager (Role 2) hoặc Staff/Receptionist (Role 4)
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            return;
        }

        // Kiểm tra nếu là yêu cầu cập nhật ngầm AJAX (Polling)
        String isAjax = req.getParameter("ajax");
        if ("true".equals(isAjax)) {
            resp.setContentType("application/json;charset=UTF-8");
            StringBuilder json = new StringBuilder();
            json.append("{");
            
            // 1. Danh sách Sân
            json.append("\"danhSachSan\": [");
            java.util.List<org.example.model.San> dsSan = checkInDAO.getDanhSachSan();
            for (int i = 0; i < dsSan.size(); i++) {
                org.example.model.San s = dsSan.get(i);
                json.append("{");
                json.append("\"sanID\": ").append(s.getSanID()).append(",");
                json.append("\"tenSan\": \"").append(s.getTenSan().replace("\"", "\\\"")).append("\",");
                json.append("\"trangThai\": \"").append(s.getTrangThai().replace("\"", "\\\"")).append("\"");
                json.append("}");
                if (i < dsSan.size() - 1) json.append(",");
            }
            json.append("],");
            
            // 2. Danh sách Lịch đặt
            json.append("\"danhSachLich\": [");
            java.util.List<CheckInDAO.BookingViewDTO> dsLich = checkInDAO.getDanhSachLichCheckInHomNay();
            for (int i = 0; i < dsLich.size(); i++) {
                CheckInDAO.BookingViewDTO b = dsLich.get(i);
                json.append("{");
                json.append("\"datSanId\": ").append(b.getDatSanId()).append(",");
                json.append("\"sanId\": ").append(b.getSanId()).append(",");
                json.append("\"tenSan\": \"").append(b.getTenSan().replace("\"", "\\\"")).append("\",");
                json.append("\"tenKhachHang\": \"").append(b.getTenKhachHang().replace("\"", "\\\"")).append("\",");
                json.append("\"gioBatDau\": \"").append(b.getGioBatDau().toString()).append("\",");
                json.append("\"gioKetThuc\": \"").append(b.getGioKetThuc().toString()).append("\",");
                json.append("\"tongTien\": ").append(b.getTongTien()).append(",");
                json.append("\"nguonDatSan\": \"").append(b.getNguonDatSan().replace("\"", "\\\"")).append("\",");
                json.append("\"trangThai\": \"").append(b.getTrangThai().replace("\"", "\\\"")).append("\",");
                json.append("\"trangThaiThanhToan\": \"").append(b.getTrangThaiThanhToan().replace("\"", "\\\"")).append("\",");
                json.append("\"ghiChu\": \"").append(b.getGhiChu() != null ? b.getGhiChu().replace("\"", "\\\"") : "").append("\"");
                json.append("}");
                if (i < dsLich.size() - 1) json.append(",");
            }
            json.append("]");
            
            json.append("}");
            resp.getWriter().write(json.toString());
            return;
        }

        // 2. Lấy dữ liệu hiển thị lên Dashboard
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan());
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay());

        // 3. Forward tới giao diện JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Phân quyền (Authorization)
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
            return;
        }

        String action = req.getParameter("action");
        String successMsg = null;
        String errorMsg = null;

        try {
            if ("checkInPreBooked".equals(action)) {
                // Nhận thông tin check-in khách đặt trước
                String datSanIdStr = req.getParameter("datSanId");
                String daThuTienMatStr = req.getParameter("daThuTienMat");
                
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiếu ID đơn đặt sân.");
                }

                int datSanId = Integer.parseInt(datSanIdStr);
                boolean daThuTienMat = "true".equals(daThuTienMatStr);

                // Gọi DAO xử lý nghiệp vụ check-in khách đặt trước
                // Luôn kiểm tra tiền cọc/thanh toán (forcePaymentCheck = true)
                checkInDAO.checkInKhachDatTruoc(datSanId, user.getAccountId(), true, daThuTienMat);
                successMsg = "Check-in thành công cho đơn đặt sân #" + datSanId + "!";

            } else if ("checkInWalkIn".equals(action)) {
                // Nhận thông tin mở sân cho khách vãng lai
                String sanIdStr = req.getParameter("sanId");
                String durationStr = req.getParameter("duration");
                String donGiaStr = req.getParameter("donGia");

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

                // Gọi DAO xử lý mở sân khách vãng lai
                checkInDAO.checkInKhachVangLai(sanId, duration, user.getAccountId(), donGia);
                successMsg = "Đã mở sân thành công cho khách vãng lai!";
            } else if ("cancelNoShow".equals(action)) {
                // Hủy đơn đặt sân do khách bùng
                String datSanIdStr = req.getParameter("datSanId");
                if (datSanIdStr == null || datSanIdStr.isEmpty()) {
                    throw new CheckInException("Thiếu ID đơn đặt sân để hủy.");
                }
                int datSanId = Integer.parseInt(datSanIdStr);
                checkInDAO.huyLichKhachBung(datSanId, user.getAccountId());
                successMsg = "Đã hủy thành công đơn đặt sân #" + datSanId + " (Khách bùng)!";
            } else {
                throw new CheckInException("Hành động không hợp lệ.");
            }
        } catch (PaymentRequiredException e) {
            // Trường hợp lỗi yêu cầu thanh toán/cọc:
            // Đánh dấu để hiển thị hộp thoại xác nhận thu tiền mặt cho Lễ tân
            errorMsg = e.getMessage();
            req.setAttribute("paymentRequired", true);
            req.setAttribute("datSanIdPending", req.getParameter("datSanId"));
        } catch (NumberFormatException e) {
            errorMsg = "Lỗi định dạng dữ liệu đầu vào.";
        } catch (CheckInException e) {
            // Các kịch bản lỗi nghiệp vụ (trùng lịch, sân bận, xung đột ghi dữ liệu đồng thời...)
            errorMsg = e.getMessage();
        } catch (Exception e) {
            errorMsg = "Lỗi hệ thống bất ngờ: " + e.getMessage();
        }

        // Thiết lập thông điệp thông báo
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
        }
        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
        }

        // Tải lại dữ liệu lên trang dashboard
        req.setAttribute("danhSachSan", checkInDAO.getDanhSachSan());
        req.setAttribute("danhSachLich", checkInDAO.getDanhSachLichCheckInHomNay());

        // Forward lại trang JSP
        req.getRequestDispatcher("/staff/CheckIn.jsp").forward(req, resp);
    }
}
