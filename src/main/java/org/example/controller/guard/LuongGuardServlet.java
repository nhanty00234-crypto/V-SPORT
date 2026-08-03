package org.example.controller.guard;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import org.example.controller.staff.LuongStaffServlet;
import org.example.util.Constants;

/**
 * "Lương của tôi" cho bảo vệ — nghiệp vụ giống hệt lễ tân, chỉ khác role được phép và URL.
 */
@WebServlet("/guard/luong")
@MultipartConfig(fileSizeThreshold = 1 << 16, maxFileSize = 3 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class LuongGuardServlet extends LuongStaffServlet {

    @Override
    protected int vaiTroChoPhep() {
        return Constants.ROLE_BAO_VE;
    }

    @Override
    protected String duongDan() {
        return "/guard/luong";
    }

    @Override
    protected void danhDauSidebar(jakarta.servlet.http.HttpServletRequest req) {
        req.setAttribute("guardPage", "luong");
    }
}
