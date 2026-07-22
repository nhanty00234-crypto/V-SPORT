package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.CoSo;
import org.example.model.LoaiSan;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.TaiKhoan;
import org.example.service.manager.SanQRService;
import org.example.service.manager.SanService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Trang in mã QR - một sân (GET /manager/ma-qr-san-in?sanId=) hoặc hàng loạt
 * (POST /manager/ma-qr-san-in-hang-loat, sanIds[]). Ownership kiểm tra lại
 * từng sanId phía server - Manager A đưa sanId của cơ sở B vào danh sách in
 * hàng loạt sẽ bị BỎ QUA (không lộ, không in), không phải lỗi 500 làm hỏng
 * toàn bộ phiên in các sân hợp lệ còn lại.
 */
public class SanQRPrintServlet {

    @WebServlet("/manager/ma-qr-san-in")
    public static class Single extends HttpServlet {
        private final SanService sanService = new SanService();
        private final SanQRService sanQRService = new SanQRService();

        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            HttpSession session = request.getSession();
            TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
            if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
                response.sendRedirect(request.getContextPath() + "/dangnhap");
                return;
            }

            int sanId;
            try {
                sanId = Integer.parseInt(request.getParameter("sanId"));
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }

            San san;
            try {
                san = sanService.getSanById(sanId, manager.getCoSoId());
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền in mã QR của sân này.");
                return;
            }

            SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
            if (sanQR == null || SanQR.REVOKED.equals(sanQR.getTrangThai())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sân chưa có mã QR hợp lệ để in.");
                return;
            }

            LoaiSan loaiSan = sanService.getLoaiSanById(san.getLoaiSanID());
            CoSo coSo = new org.example.dao.impl.CoSoDAOImpl().getCoSoById(san.getCoSoID());

            request.setAttribute("san", san);
            request.setAttribute("sanQR", sanQR);
            request.setAttribute("coSo", coSo);
            request.setAttribute("tenLoaiSan", loaiSan != null ? loaiSan.getTenLoai() : "");
            request.getRequestDispatcher("/manager/MaQrSanIn.jsp").forward(request, response);
        }
    }

    @WebServlet("/manager/ma-qr-san-in-hang-loat")
    public static class Batch extends HttpServlet {
        private final SanService sanService = new SanService();
        private final SanQRService sanQRService = new SanQRService();

        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            handle(request, response);
        }

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            handle(request, response);
        }

        private void handle(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
            HttpSession session = request.getSession();
            TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
            if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
                response.sendRedirect(request.getContextPath() + "/dangnhap");
                return;
            }
            int coSoId = manager.getCoSoId();

            String[] rawIds = request.getParameterValues("sanIds");
            String layout = request.getParameter("layout");
            if (layout == null || (!layout.equals("1") && !layout.equals("2") && !layout.equals("4"))) {
                layout = "1";
            }

            List<Object[]> printable = new ArrayList<>(); // [San, SanQR, tenLoaiSan]
            if (rawIds != null) {
                for (String raw : rawIds) {
                    int sanId;
                    try {
                        sanId = Integer.parseInt(raw.trim());
                    } catch (Exception e) {
                        continue;
                    }
                    San san;
                    try {
                        san = sanService.getSanById(sanId, coSoId);
                    } catch (Exception e) {
                        // Sân không thuộc cơ sở này (hoặc không tồn tại) - bỏ qua âm thầm, không lộ thông tin.
                        continue;
                    }
                    SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
                    if (sanQR == null || SanQR.REVOKED.equals(sanQR.getTrangThai())) continue;
                    LoaiSan loaiSan = sanService.getLoaiSanById(san.getLoaiSanID());
                    printable.add(new Object[]{san, sanQR, loaiSan != null ? loaiSan.getTenLoai() : ""});
                }
            }

            CoSo coSo = new org.example.dao.impl.CoSoDAOImpl().getCoSoById(coSoId);

            request.setAttribute("items", printable);
            request.setAttribute("coSo", coSo);
            request.setAttribute("layout", layout);
            request.getRequestDispatcher("/manager/MaQrSanInHangLoat.jsp").forward(request, response);
        }
    }
}
