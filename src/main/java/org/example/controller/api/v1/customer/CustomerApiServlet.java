package org.example.controller.api.v1.customer;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.dao.CustomerReputationHistoryDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CustomerReputationHistoryDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.model.CustomerReputationHistory;
import org.example.model.TaiKhoan;
import org.example.util.PhoneUtil;
import org.example.util.ValidationUtils;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * GET  /api/v1/customer/me                    — hồ sơ khách hàng đang đăng nhập
 * PUT  /api/v1/customer/me                    — cập nhật hồ sơ (chỉ các trường Web cũng cho sửa)
 * GET  /api/v1/customer/reputation            — điểm uy tín hiện tại
 * GET  /api/v1/customer/reputation/history    — lịch sử biến động điểm uy tín
 *
 * Account LUÔN lấy từ access token, không bao giờ từ tham số client.
 */
@WebServlet("/api/v1/customer/*")
public class CustomerApiServlet extends BaseApiServlet {

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CustomerReputationHistoryDAO reputationHistoryDAO = new CustomerReputationHistoryDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length == 1 && "me".equals(seg[0])) {
                ok(resp, ApiMappers.customer(req, me));
            } else if (seg.length == 1 && "reputation".equals(seg[0])) {
                ok(resp, ApiMappers.reputation(me));
            } else if (seg.length == 2 && "reputation".equals(seg[0]) && "history".equals(seg[1])) {
                List<ApiDtos.ReputationHistoryDto> items = new ArrayList<>();
                for (CustomerReputationHistory h : reputationHistoryDAO.getByAccountId(me.getAccountId())) {
                    items.add(ApiMappers.reputationHistory(h));
                }
                ok(resp, items);
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 1 || !"me".equals(seg[0])) {
                throw notFound("Endpoint không tồn tại.");
            }
            ApiDtos.UpdateProfileRequest body = readBody(req, ApiDtos.UpdateProfileRequest.class);

            if (body.fullName != null) {
                String name = body.fullName.trim();
                if (name.isEmpty() || name.length() > 100) {
                    throw badRequest("Họ tên phải từ 1 đến 100 ký tự.");
                }
                me.setFullName(name);
            }
            if (body.phone != null && !body.phone.isBlank()) {
                String normalized = PhoneUtil.normalizeVN(body.phone);
                if (normalized == null) {
                    throw badRequest("Số điện thoại không hợp lệ.");
                }
                me.setPhoneNumber(normalized);
            }
            if (body.gender != null && !body.gender.isBlank()) {
                String g = body.gender.trim();
                if (!"Nam".equals(g) && !"Nữ".equals(g) && !"Khác".equals(g)) {
                    throw badRequest("Giới tính chỉ nhận: Nam, Nữ, Khác.");
                }
                me.setGioiTinh(g);
            }
            if (body.dateOfBirth != null && !body.dateOfBirth.isBlank()) {
                LocalDate dob;
                try {
                    dob = LocalDate.parse(body.dateOfBirth.trim());
                } catch (RuntimeException e) {
                    throw badRequest("Ngày sinh phải theo định dạng yyyy-MM-dd.");
                }
                if (dob.isAfter(LocalDate.now())) {
                    throw badRequest("Ngày sinh không thể ở tương lai.");
                }
                me.setNgaySinh(java.sql.Date.valueOf(dob));
            }
            if (body.avatar != null && !body.avatar.isBlank()) {
                String url = body.avatar.trim();
                if (!url.startsWith("http://") && !url.startsWith("https://")) {
                    throw badRequest("Ảnh đại diện phải là URL http(s).");
                }
                me.setAvatarUrl(url);
            }

            // Tái sử dụng đúng DAO mà Web dùng — không có đường ghi tài khoản riêng cho mobile.
            if (!taiKhoanDAO.updateAccount(me)) {
                throw new ApiException(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "INTERNAL_ERROR",
                        "Không thể cập nhật hồ sơ. Vui lòng thử lại.");
            }
            TaiKhoan fresh = taiKhoanDAO.getAccountById(me.getAccountId());
            ok(resp, "Cập nhật hồ sơ thành công.", ApiMappers.customer(req, fresh != null ? fresh : me));
        });
    }
}
