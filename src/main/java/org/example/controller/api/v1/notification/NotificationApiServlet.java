package org.example.controller.api.v1.notification;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.dto.api.ApiDtos;
import org.example.model.TaiKhoan;
import org.example.model.ThongBao;
import org.example.service.NotificationService;

import java.io.IOException;
import java.util.ArrayList;

/**
 * GET  /api/v1/notifications/me          — danh sách thông báo của chính khách (phân trang)
 * POST /api/v1/notifications/{id}/read   — đánh dấu đã đọc (DAO tự kiểm tra owner, chống IDOR)
 * POST /api/v1/notifications/read-all    — đánh dấu tất cả đã đọc
 *
 * Đọc đúng bảng ThongBao mà backend hiện tại đang ghi (booking approved/rejected, payment success,
 * refund update, ...) qua {@link NotificationService} — không có kênh thông báo riêng cho mobile.
 */
@WebServlet("/api/v1/notifications/*")
public class NotificationApiServlet extends BaseApiServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 1 || !"me".equals(seg[0])) throw notFound("Endpoint không tồn tại.");

            int page = pageParam(req);
            int size = sizeParam(req);

            ApiDtos.NotificationListDto dto = new ApiDtos.NotificationListDto();
            dto.page = page;
            dto.size = size;
            dto.total = notificationService.countTotal(me.getAccountId());
            dto.unread = notificationService.countUnread(me.getAccountId());
            dto.items = new ArrayList<>();
            for (ThongBao tb : notificationService.getNotifications(me.getAccountId(), page, size)) {
                dto.items.add(ApiMappers.notification(tb));
            }
            ok(resp, dto);
        });
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length == 1 && "read-all".equals(seg[0])) {
                int updated = notificationService.markAllAsRead(me.getAccountId());
                ok(resp, "Đã đánh dấu tất cả là đã đọc.", updated);
            } else if (seg.length == 2 && "read".equals(seg[1])) {
                int id = requireInt(seg[0], "notificationId");
                if (!notificationService.markAsRead(id, me.getAccountId())) {
                    throw notFound("Không tìm thấy thông báo.");
                }
                ok(resp, "Đã đánh dấu đã đọc.", null);
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }
}
