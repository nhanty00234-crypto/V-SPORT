package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.DanhGia;
import org.example.model.TaiKhoan;
import org.example.service.DanhGiaService;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/manager/danh-gia")
public class DanhGiaManagerServlet extends HttpServlet {

    private final DanhGiaService service = new DanhGiaService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/he-thong/dang-nhap");
            return;
        }

        int coSoId = user.getCoSoId() != null ? user.getCoSoId() : 0;

        int filterSoSao = 0;
        try { filterSoSao = Integer.parseInt(request.getParameter("soSao")); } catch (Exception ignored) {}
        if (filterSoSao < 0 || filterSoSao > 5) filterSoSao = 0;

        int page = 1;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
        if (page < 1) page = 1;

        String searchName = request.getParameter("q");
        if (searchName != null) searchName = searchName.trim();
        if (searchName != null && searchName.isEmpty()) searchName = null;

        LocalDate dateFrom = null;
        LocalDate dateTo   = null;
        try {
            String f = request.getParameter("dateFrom");
            if (f != null && !f.isEmpty()) dateFrom = LocalDate.parse(f);
        } catch (Exception ignored) {}
        try {
            String t = request.getParameter("dateTo");
            if (t != null && !t.isEmpty()) dateTo = LocalDate.parse(t);
        } catch (Exception ignored) {}

        List<DanhGia> dsDanhGia = service.getForManager(coSoId, filterSoSao, searchName, dateFrom, dateTo, page);
        double avgRaw = service.avgRating(coSoId);
        String avgRating = avgRaw > 0 ? String.format("%.1f", avgRaw) : "—";

        int totalReviews = service.getForManager(coSoId, 0, null, null, null, 1).size();
        boolean noFilter = filterSoSao == 0 && searchName == null && dateFrom == null && dateTo == null && page == 1;
        if (noFilter) totalReviews = dsDanhGia.size();

        request.setAttribute("dsDanhGia",    dsDanhGia);
        request.setAttribute("avgRating",    avgRating);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("filterSoSao",  filterSoSao);
        request.setAttribute("searchName",   searchName != null ? searchName : "");
        request.setAttribute("dateFrom",     dateFrom  != null ? dateFrom.toString()  : "");
        request.setAttribute("dateTo",       dateTo    != null ? dateTo.toString()    : "");
        request.setAttribute("currentPage",  page);
        request.setAttribute("hasMore",      dsDanhGia.size() == 20);
        request.getRequestDispatcher("/manager/DanhGia.jsp").forward(request, response);
    }
}
