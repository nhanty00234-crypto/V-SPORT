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

        List<DanhGia> dsDanhGia = service.getForManager(coSoId, filterSoSao, searchName, page);
        double avgRaw = service.avgRating(coSoId);
        String avgRating = avgRaw > 0 ? String.format("%.1f", avgRaw) : "—";

        int totalReviews = service.getForManager(coSoId, 0, null, 1).size();
        if (filterSoSao == 0 && (searchName == null || searchName.isEmpty()) && page == 1) {
            totalReviews = dsDanhGia.size();
        }

        request.setAttribute("dsDanhGia", dsDanhGia);
        request.setAttribute("avgRating", avgRating);
        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("filterSoSao", filterSoSao);
        request.setAttribute("searchName", searchName != null ? searchName : "");
        request.setAttribute("currentPage", page);
        request.setAttribute("hasMore", dsDanhGia.size() == 20);
        request.getRequestDispatcher("/manager/DanhGia.jsp").forward(request, response);
    }
}
