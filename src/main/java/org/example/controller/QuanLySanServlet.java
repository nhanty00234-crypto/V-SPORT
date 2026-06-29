package org.example.controller;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.CoSo;
import org.example.model.LoaiSan;
import org.example.model.San;
import org.example.util.JPAUtil;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/quan-ly-san")
public class QuanLySanServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(QuanLySanServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            // Lấy danh sách sân
            List<San> dsSan = em.createQuery("SELECT s FROM San s", San.class).getResultList();

            // Lấy danh sách loại sân, Cơ Sở và môn thể thao để dùng cho form thêm/sửa
            List<LoaiSan> dsLoaiSan = em.createQuery("SELECT l FROM LoaiSan l", LoaiSan.class).getResultList();
            List<CoSo> dsCoSo = em.createQuery("SELECT c FROM CoSo c", CoSo.class).getResultList();
            List<org.example.model.MonTheThao> dsMonTheThao = em
                    .createQuery("SELECT m FROM MonTheThao m", org.example.model.MonTheThao.class).getResultList();

            request.setAttribute("dsSan", dsSan);
            request.setAttribute("dsLoaiSan", dsLoaiSan);
            request.setAttribute("dsCoSo", dsCoSo);
            request.setAttribute("dsMonTheThao", dsMonTheThao);

            request.getRequestDispatcher("/admin/QuanLySan.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();

        jakarta.servlet.http.HttpSession session = request.getSession();
        org.example.model.TaiKhoan user = (org.example.model.TaiKhoan) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/dangnhap");
            em.close();
            return;
        }

        int userRoleId = user.getRoleId();
        Integer userCoSoID = user.getCoSoId();

        try {
            if ("add".equals(action)) {
                trans.begin();
                San san = new San();
                updateSanFromRequest(san, request);

                // Validation
                if (san.getTenSan() == null || san.getTenSan().trim().isEmpty()) {
                    throw new IllegalArgumentException("Tên sân không được để trống.");
                }
                // Branch Isolation
                if (userRoleId != 1) {
                    if (userCoSoID == null || san.getCoSoID() != userCoSoID.intValue()) {
                        throw new IllegalAccessException("Bạn chỉ có quyền thêm sân cho Cơ Sở của mình.");
                    }
                }

                em.persist(san);
                trans.commit();
                session.setAttribute("message", "Thêm sân thành công!");
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("sanID"));
                trans.begin();
                San san = em.find(San.class, id);
                if (san != null) {
                    // Branch Isolation (Check current state)
                    if (userRoleId != 1) {
                        if (userCoSoID == null || san.getCoSoID() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không có quyền chỉnh sửa sân của Cơ Sở khác.");
                        }
                    }

                    updateSanFromRequest(san, request);

                    // Validation & Branch Isolation (Check new state)
                    if (san.getTenSan() == null || san.getTenSan().trim().isEmpty()) {
                        throw new IllegalArgumentException("Tên sân không được để trống.");
                    }
                    if (userRoleId != 1) {
                        if (userCoSoID == null || san.getCoSoID() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không thể di chuyển sân sang Cơ Sở khác.");
                        }
                    }

                    em.merge(san);
                    trans.commit();
                    session.setAttribute("message", "Cập nhật sân thành công!");
                } else {
                    trans.rollback();
                }
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("sanID"));
                trans.begin();
                San san = em.find(San.class, id);
                if (san != null) {
                    // Branch Isolation
                    if (userRoleId != 1) {
                        if (userCoSoID == null || san.getCoSoID() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không có quyền xóa sân của Cơ Sở khác.");
                        }
                    }
                    // Logical Delete: Set status to Tạm đóng instead of hard deleting
                    san.setTrangThai("Tạm đóng");
                    em.merge(san);
                    trans.commit();
                    session.setAttribute("message", "Đã chuyển trạng thái sân sang Tạm đóng (Xóa mềm).");
                } else {
                    trans.rollback();
                }
            } else if ("updateStatus".equals(action)) {
                int id = Integer.parseInt(request.getParameter("sanID"));
                String newStatus = request.getParameter("trangThai");
                trans.begin();
                San san = em.find(San.class, id);
                if (san != null) {
                    // Branch Isolation
                    if (userRoleId != 1) {
                        if (userCoSoID == null || san.getCoSoID() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không có quyền chỉnh sửa sân của Cơ Sở khác.");
                        }
                    }
                    san.setTrangThai(newStatus);
                    em.merge(san);
                    trans.commit();
                    session.setAttribute("message", "Đã cập nhật trạng thái sân thành công!");
                } else {
                    trans.rollback();
                }
            } else if ("addType".equals(action)) {
                trans.begin();
                LoaiSan ls = new LoaiSan();
                updateLoaiSanFromRequest(ls, request);

                // Validation
                if (ls.getTenLoai() == null || ls.getTenLoai().trim().isEmpty()) {
                    throw new IllegalArgumentException("Tên loại sân không được để trống.");
                }
                if (ls.getGiaKhongDen() < 0 || ls.getGiaCoDen() < 0) {
                    throw new IllegalArgumentException("Giá sân không được nhỏ hơn 0.");
                }
                // Branch Isolation
                if (userRoleId != 1) {
                    if (userCoSoID == null || ls.getCoSoID() == null
                            || ls.getCoSoID().intValue() != userCoSoID.intValue()) {
                        throw new IllegalAccessException("Bạn chỉ có quyền cấu hình loại sân cho Cơ Sở của mình.");
                    }
                }

                em.persist(ls);
                trans.commit();
                session.setAttribute("message", "Thêm cấu hình loại sân thành công!");
            } else if ("updateType".equals(action)) {
                int id = Integer.parseInt(request.getParameter("loaiSanID"));
                trans.begin();
                LoaiSan ls = em.find(LoaiSan.class, id);
                if (ls != null) {
                    // Branch Isolation (Check current state)
                    if (userRoleId != 1) {
                        if (userCoSoID == null || ls.getCoSoID() == null
                                || ls.getCoSoID().intValue() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không có quyền chỉnh sửa loại sân của Cơ Sở khác.");
                        }
                    }

                    updateLoaiSanFromRequest(ls, request);

                    // Validation & Branch Isolation (Check new state)
                    if (ls.getTenLoai() == null || ls.getTenLoai().trim().isEmpty()) {
                        throw new IllegalArgumentException("Tên loại sân không được để trống.");
                    }
                    if (ls.getGiaKhongDen() < 0 || ls.getGiaCoDen() < 0) {
                        throw new IllegalArgumentException("Giá sân không được nhỏ hơn 0.");
                    }
                    if (userRoleId != 1) {
                        if (userCoSoID == null || ls.getCoSoID() == null
                                || ls.getCoSoID().intValue() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không thể di chuyển cấu hình sang Cơ Sở khác.");
                        }
                    }

                    em.merge(ls);
                    trans.commit();
                    session.setAttribute("message", "Cập nhật loại sân thành công!");
                } else {
                    trans.rollback();
                }
            } else if ("deleteType".equals(action)) {
                int id = Integer.parseInt(request.getParameter("loaiSanID"));
                trans.begin();
                LoaiSan ls = em.find(LoaiSan.class, id);
                if (ls != null) {
                    // Branch Isolation
                    if (userRoleId != 1) {
                        if (userCoSoID == null || ls.getCoSoID() == null
                                || ls.getCoSoID().intValue() != userCoSoID.intValue()) {
                            throw new IllegalAccessException("Bạn không có quyền xóa loại sân của Cơ Sở khác.");
                        }
                    }

                    // Safe delete check: Check if any courts are using this type
                    Long courtCount = em
                            .createQuery("SELECT COUNT(s) FROM San s WHERE s.loaiSanID = :typeId", Long.class)
                            .setParameter("typeId", id)
                            .getSingleResult();
                    if (courtCount > 0) {
                        throw new IllegalStateException("Không thể xóa loại sân này vì đang có " + courtCount
                                + " sân liên kết với nó. Vui lòng cập nhật các sân đó trước.");
                    }

                    em.remove(ls);
                    trans.commit();
                    session.setAttribute("message", "Xóa cấu hình loại sân thành công!");
                } else {
                    trans.rollback();
                }
            }
        } catch (Exception e) {
            if (trans.isActive())
                trans.rollback();
            logger.error("Lỗi khi xử lý quản lý sân", e);
            session.setAttribute("error", "Lỗi: " + e.getMessage());
        } finally {
            em.close();
        }

        response.sendRedirect(request.getContextPath() + "/admin/quan-ly-san");
    }

    private void updateSanFromRequest(San san, HttpServletRequest request) {
        san.setTenSan(request.getParameter("tenSan"));
        san.setLoaiSanID(Integer.parseInt(request.getParameter("loaiSanID")));
        san.setCoSoID(Integer.parseInt(request.getParameter("coSoID")));
        san.setTrangThai(request.getParameter("trangThai"));
        san.setMoTa(request.getParameter("moTa"));
        san.setHinhAnh(request.getParameter("hinhAnh"));
    }

    private void updateLoaiSanFromRequest(LoaiSan ls, HttpServletRequest request) {
        ls.setTenLoai(request.getParameter("tenLoai"));
        ls.setMonTheThaoID(Integer.parseInt(request.getParameter("monTheThaoID")));
        ls.setGiaKhongDen(Double.parseDouble(request.getParameter("giaKhongDen")));
        ls.setGiaCoDen(Double.parseDouble(request.getParameter("giaCoDen")));
        String timeStr = request.getParameter("gioBatDauLenDen");
        if (timeStr != null && !timeStr.isEmpty()) {
            if (timeStr.length() == 5)
                timeStr += ":00"; // HH:mm -> HH:mm:ss
            ls.setGioBatDauLenDen(java.time.LocalTime.parse(timeStr));
        }
        String coSoIdStr = request.getParameter("coSoID");
        if (coSoIdStr != null && !coSoIdStr.isEmpty()) {
            ls.setCoSoID(Integer.parseInt(coSoIdStr));
        } else {
            ls.setCoSoID(null);
        }
    }
}
