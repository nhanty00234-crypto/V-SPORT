package org.example.controller.manager;

import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.DanhGia;
import org.example.model.TaiKhoan;
import org.example.util.JPAUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/manager/danh-gia")
public class DanhGiaManagerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getRoleId() != 2) {
            response.sendRedirect(request.getContextPath() + "/he-thong/dang-nhap");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<DanhGia> dsDanhGia = em.createQuery("SELECT d FROM DanhGia d ORDER BY d.ngayDanhGia DESC", DanhGia.class)
                    .setMaxResults(100)
                    .getResultList();

            double avgRating = 5.0;
            if (!dsDanhGia.isEmpty()) {
                double sum = 0;
                for (DanhGia d : dsDanhGia) {
                    sum += d.getSoSao();
                }
                avgRating = Math.round((sum / dsDanhGia.size()) * 10.0) / 10.0;
            }

            request.setAttribute("dsDanhGia", dsDanhGia);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("totalReviews", dsDanhGia.size());
            request.getRequestDispatcher("/manager/DanhGia.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }
}
