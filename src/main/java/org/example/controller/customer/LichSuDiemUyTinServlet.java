package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CustomerReputationHistoryDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CustomerReputationHistoryDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CustomerReputationHistory;
import org.example.model.TaiKhoan;
import org.example.service.reputation.ReputationLabel;
import org.example.util.Constants;

import java.io.IOException;
import java.util.List;

@WebServlet("/customer/lich-su-diem-uy-tin")
public class LichSuDiemUyTinServlet extends HttpServlet {

    private final CustomerReputationHistoryDAO reputationHistoryDAO = new CustomerReputationHistoryDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        // Fresh account details from DB for latest DiemUyTin
        TaiKhoan freshAccount = taiKhoanDAO.getAccountById(user.getAccountId());
        if (freshAccount == null) freshAccount = user;

        String actionFilter = req.getParameter("type");
        if (actionFilter == null || actionFilter.isBlank()) {
            actionFilter = "ALL";
        }

        List<CustomerReputationHistory> historyList = reputationHistoryDAO.getByAccountIdAndAction(freshAccount.getAccountId(), actionFilter);

        int currentScore = freshAccount.getDiemUyTin();
        String reputationLabel = ReputationLabel.of(currentScore);
        boolean canMatchmake = currentScore >= Constants.REPUTATION_MATCHMAKING_THRESHOLD;

        // Sync session so banner/other pages always reflect latest DB data
        session.setAttribute("user", freshAccount);

        req.setAttribute("account", freshAccount);
        req.setAttribute("historyList", historyList);
        req.setAttribute("currentScore", currentScore);
        req.setAttribute("reputationLabel", reputationLabel);
        req.setAttribute("canMatchmake", canMatchmake);
        req.setAttribute("actionFilter", actionFilter);
        req.setAttribute("pageTitle", "Lịch sử điểm uy tín & ELO");

        req.getRequestDispatcher("/customer/LichSuDiemUyTin.jsp").forward(req, resp);
    }
}
