package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.LichDatSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.model.San;
import org.example.model.TaiKhoan;
import org.example.model.CoSo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/customer/gio-hang", "/customer/api/cart-count"})
public class GioHangServlet extends HttpServlet {

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final org.example.dao.CoSoDAO coSoDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/customer/api/cart-count".equals(path)) {
            handleCartCount(req, resp);
            return;
        }

        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        
        if (user == null) {
            resp.sendRedirect(org.example.util.RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "")));
            return;
        }

        List<Lichdatsan> allLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());
        List<Lichdatsan> cartItems = new ArrayList<>();

        if (allLich != null) {
            for (Lichdatsan l : allLich) {
                if ("Chờ xác nhận".equals(l.getTrangThai()) || "Chờ thanh toán".equals(l.getTrangThai())) {
                    cartItems.add(l);
                }
            }
        }

        List<San> dsSan = sanDAO.getAllSan();
        List<CoSo> dsCoSo = coSoDAO.getAllCoSo();

        java.util.Map<Integer, org.example.model.CustomerReputationHistory> reputationByDatSanId = new java.util.HashMap<>();
        org.example.dao.CustomerReputationHistoryDAO reputationHistoryDAO = new org.example.dao.impl.CustomerReputationHistoryDAOImpl();
        for (org.example.model.CustomerReputationHistory h : reputationHistoryDAO.getByAccountId(user.getAccountId())) {
            if (h.getDatSanId() == null) continue;
            if (!org.example.util.Constants.REPUTATION_ACTION_LATE_CANCEL.equals(h.getActionType())
                    && !org.example.util.Constants.REPUTATION_ACTION_NO_SHOW.equals(h.getActionType())
                    && !org.example.util.Constants.REPUTATION_ACTION_EARLY_CANCEL.equals(h.getActionType())) {
                continue;
            }
            reputationByDatSanId.putIfAbsent(h.getDatSanId(), h);
        }

        org.example.dao.HoanTienDAO hoanTienDAO = new org.example.dao.impl.HoanTienDAOImpl();
        java.util.Map<Integer, org.example.model.Hoantien> mapHoanTien = hoanTienDAO.findActiveMapByAccountId(user.getAccountId());

        org.example.service.RefundService refundService = new org.example.service.RefundService();
        List<org.example.model.Hoantien> danhSachHoanTien = refundService.getByCustomer(user.getAccountId(), 1);

        req.setAttribute("cartItems", cartItems);
        req.setAttribute("dsLich", allLich != null ? allLich : new ArrayList<>());
        req.setAttribute("dsSan", dsSan);
        req.setAttribute("dsCoSo", dsCoSo);
        req.setAttribute("reputationByDatSanId", reputationByDatSanId);
        req.setAttribute("mapHoanTien", mapHoanTien);
        req.setAttribute("danhSachHoanTien", danhSachHoanTien);

        req.getRequestDispatcher("/customer/GioHang.jsp").forward(req, resp);
    }

    private void handleCartCount(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        TaiKhoan user = (session != null) ? (TaiKhoan) session.getAttribute("user") : null;
        
        int count = 0;
        if (user != null) {
            List<Lichdatsan> allLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());
            if (allLich != null) {
                for (Lichdatsan l : allLich) {
                    if ("Chờ xác nhận".equals(l.getTrangThai()) || "Chờ thanh toán".equals(l.getTrangThai())) {
                        count++;
                    }
                }
            }
        }
        
        resp.getWriter().write("{\"count\": " + count + "}");
    }
}
