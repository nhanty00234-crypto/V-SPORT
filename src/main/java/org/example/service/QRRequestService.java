package org.example.service;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.example.dao.LichDatSanDichVuDAO;
import org.example.dao.QRRequestDAO;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.LichDatSanDichVuDAOImpl;
import org.example.dao.impl.QRRequestDAOImpl;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.dto.qr.QRRequestDTO;
import org.example.model.QRRequest;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.model.SanQR;
import org.example.service.manager.SanQRService;
import org.example.util.DBUtil;
import org.example.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.sql.Connection;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class QRRequestService {

    /** Khoảng thời gian chặn gửi trùng cùng loại yêu cầu, cùng QR, còn đang chờ. */
    private static final int DUPLICATE_WINDOW_SECONDS = 20;

    public enum ErrorCode { NOT_FOUND, FORBIDDEN, INVALID_TRANSITION, DUPLICATE, SYSTEM }

    public static class Result {
        public final boolean success;
        public final ErrorCode errorCode;
        public final String message;
        public final QRRequestDTO data;

        private Result(boolean success, ErrorCode errorCode, String message, QRRequestDTO data) {
            this.success = success; this.errorCode = errorCode; this.message = message; this.data = data;
        }

        public static Result ok(QRRequestDTO data) { return new Result(true, null, null, data); }
        public static Result fail(ErrorCode code, String message) { return new Result(false, code, message, null); }
    }

    private final QRRequestDAO dao = new QRRequestDAOImpl();
    private final SanQRService sanQRService = new SanQRService();
    private final LichDatSanDichVuDAO lichDatSanDichVuDAO = new LichDatSanDichVuDAOImpl();
    private final SanPhamDichVuDAO sanPhamDichVuDAO = new SanPhamDichVuDAOImpl();
    private final Gson gson = new Gson();

    public Result createRequest(int sanId, String guestToken, Integer customerId,
                                 String requestType, String itemsJson, String note) {
        if (guestToken == null || guestToken.isBlank()) {
            return Result.fail(ErrorCode.FORBIDDEN, "Thiếu định danh phiên.");
        }
        EntityManager em = JPAUtil.getEntityManager();
        San san;
        try {
            san = em.find(San.class, sanId);
        } finally {
            em.close();
        }
        if (san == null || san.isDeleted()) {
            return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy sân.");
        }
        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || !sanQR.isActive()) {
            return Result.fail(ErrorCode.FORBIDDEN, "Mã QR của sân này không còn hiệu lực.");
        }

        if (isDuplicateRecent(guestToken, sanId, requestType)) {
            return Result.fail(ErrorCode.DUPLICATE,
                "Yêu cầu của bạn đã được gửi trước đó. Vui lòng chờ nhân viên tiếp nhận.");
        }

        QRRequest request = new QRRequest();
        request.setSanId(sanId);
        request.setCoSoId(san.getCoSoID());
        request.setGuestToken(guestToken);
        request.setCustomerId(customerId);
        request.setRequestType(requestType);
        request.setItemsJson(itemsJson);
        request.setNote(note);
        request.setStatus(QRRequest.STATUS_NEW);
        QRRequest saved = dao.save(request);
        return Result.ok(toDTO(saved, san.getTenSan()));
    }

    /**
     * Chặn spam: cùng guestToken + sân + loại yêu cầu, nếu còn NEW/IN_PROGRESS
     * và được tạo trong {@link #DUPLICATE_WINDOW_SECONDS} giây gần nhất thì coi là trùng.
     */
    private boolean isDuplicateRecent(String guestToken, int sanId, String requestType) {
        List<QRRequest> existing = dao.findByGuestTokenAndSan(guestToken, sanId);
        LocalDateTime now = LocalDateTime.now();
        for (QRRequest r : existing) {
            if (!requestType.equals(r.getRequestType())) continue;
            if (!QRRequest.STATUS_NEW.equals(r.getStatus()) && !QRRequest.STATUS_IN_PROGRESS.equals(r.getStatus())) continue;
            if (QRRequest.STATUS_IN_PROGRESS.equals(r.getStatus())) return true;
            if (r.getCreatedAt() != null && Duration.between(r.getCreatedAt(), now).getSeconds() < DUPLICATE_WINDOW_SECONDS) {
                return true;
            }
        }
        return false;
    }

    public List<QRRequestDTO> listByGuestToken(String guestToken, int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        String tenSan;
        try {
            San san = em.find(San.class, sanId);
            tenSan = san != null ? san.getTenSan() : "";
        } finally {
            em.close();
        }
        return dao.findByGuestTokenAndSan(guestToken, sanId).stream()
            .map(r -> toDTO(r, tenSan))
            .collect(Collectors.toList());
    }

    public List<QRRequestDTO> listByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return dao.findByCoSoAndStatus(coSoId, status).stream()
                .map(r -> {
                    San san = em.find(San.class, r.getSanId());
                    return toDTO(r, san != null ? san.getTenSan() : "");
                })
                .collect(Collectors.toList());
        } finally {
            em.close();
        }
    }

    public Result updateStatus(int requestId, int staffCoSoId, Integer staffAccountId, String newStatus) {
        EntityManager em = JPAUtil.getEntityManager();
        jakarta.persistence.EntityTransaction tx = em.getTransaction();
        QRRequest saved;
        try {
            tx.begin();
            QRRequest req = em.find(QRRequest.class, requestId, jakarta.persistence.LockModeType.PESSIMISTIC_WRITE);
            if (req == null) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy yêu cầu.");
            }
            if (req.getCoSoId() != staffCoSoId) {
                tx.rollback();
                return Result.fail(ErrorCode.FORBIDDEN, "Yêu cầu không thuộc cơ sở của bạn.");
            }
            if (!isValidTransition(req.getStatus(), newStatus)) {
                String fromStatus = req.getStatus();
                tx.rollback();
                return Result.fail(ErrorCode.INVALID_TRANSITION,
                    "Không thể chuyển từ " + fromStatus + " sang " + newStatus + ".");
            }
            if (QRRequest.STATUS_DONE.equals(newStatus) && QRRequest.TYPE_ORDER_ITEM.equals(req.getRequestType())) {
                try {
                    fulfillOrderItems(req, staffAccountId, staffCoSoId);
                } catch (RuntimeException e) {
                    tx.rollback();
                    return Result.fail(ErrorCode.SYSTEM, e.getMessage() != null ? e.getMessage()
                        : "Không thể xác nhận đơn hàng và trừ tồn kho.");
                }
            }
            req.setStatus(newStatus);
            req.setHandledByStaffId(staffAccountId);
            tx.commit();
            saved = req;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }

        EntityManager readEm = JPAUtil.getEntityManager();
        String tenSan;
        try {
            San san = readEm.find(San.class, saved.getSanId());
            tenSan = san != null ? san.getTenSan() : "";
        } finally {
            readEm.close();
        }
        return Result.ok(toDTO(saved, tenSan));
    }

    /**
     * Khi Staff xác nhận hoàn thành 1 yêu cầu ORDER_ITEM: gắn từng món vào phiên sân đang
     * "Đang sử dụng" của SanID này (LichDatSan_DichVu), rồi tái sử dụng nguyên logic
     * LichDatSanDichVuDAOImpl.updateStatus(..., "Đã giao", ...) đã có sẵn để trừ tồn kho
     * và tạo hóa đơn SPLIT — không cài lại logic hóa đơn/tồn kho ở đây.
     * Giá lấy lại từ DB (SanPham_DichVu.DonGia), không tin ItemsJson do khách gửi.
     */
    private void fulfillOrderItems(QRRequest req, Integer staffAccountId, int staffCoSoId) {
        if (req.getItemsJson() == null || req.getItemsJson().isBlank()) {
            throw new IllegalStateException("Yêu cầu không có sản phẩm để xác nhận.");
        }
        Integer datSanId;
        try {
            datSanId = lichDatSanDichVuDAO.findActiveDatSanIdBySan(req.getSanId());
        } catch (java.sql.SQLException e) {
            throw new IllegalStateException("Lỗi hệ thống khi tra cứu phiên sân.", e);
        }
        if (datSanId == null) {
            throw new IllegalStateException("Sân hiện không có phiên sử dụng đang diễn ra, không thể xác nhận đơn hàng.");
        }

        Type listType = new TypeToken<List<Map<String, Object>>>() {}.getType();
        List<Map<String, Object>> items;
        try {
            items = gson.fromJson(req.getItemsJson(), listType);
        } catch (RuntimeException e) {
            throw new IllegalStateException("Dữ liệu sản phẩm không hợp lệ.");
        }
        if (items == null || items.isEmpty()) {
            throw new IllegalStateException("Yêu cầu không có sản phẩm để xác nhận.");
        }

        for (Map<String, Object> item : items) {
            int sanPhamId = ((Number) item.get("sanPhamId")).intValue();
            int soLuong = ((Number) item.get("soLuong")).intValue();
            if (soLuong <= 0) continue;

            SanPham_DichVu sp = sanPhamDichVuDAO.findById(sanPhamId);
            if (sp == null || sp.getCoSoID() != staffCoSoId) {
                throw new IllegalStateException("Sản phẩm #" + sanPhamId + " không thuộc cơ sở này.");
            }
            BigDecimal unitPrice = BigDecimal.valueOf(sp.getDonGia());
            BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(soLuong));

            int lineId;
            try (Connection conn = DBUtil.getConnection()) {
                conn.setAutoCommit(true);
                lineId = lichDatSanDichVuDAO.insertPreOrderReturningId(conn, datSanId, sanPhamId, soLuong, unitPrice, totalPrice);
            } catch (java.sql.SQLException e) {
                throw new IllegalStateException("Không thể tạo dòng dịch vụ cho \"" + sp.getTenSanPham() + "\".", e);
            }

            boolean ok;
            try {
                ok = lichDatSanDichVuDAO.updateStatus(lineId, "Đã giao", staffAccountId, staffCoSoId);
            } catch (java.sql.SQLException e) {
                throw new IllegalStateException("Không đủ tồn kho cho \"" + sp.getTenSanPham() + "\".", e);
            }
            if (!ok) {
                throw new IllegalStateException("Không thể giao \"" + sp.getTenSanPham() + "\" (có thể đã bị xử lý trước đó).");
            }
        }
    }

    public long countNewByCoSo(int coSoId) {
        return dao.countByCoSoAndStatus(coSoId, QRRequest.STATUS_NEW);
    }

    private boolean isValidTransition(String from, String to) {
        if (QRRequest.STATUS_CANCELLED.equals(to)) {
            return !QRRequest.STATUS_DONE.equals(from) && !QRRequest.STATUS_CANCELLED.equals(from);
        }
        if (QRRequest.STATUS_NEW.equals(from) && QRRequest.STATUS_IN_PROGRESS.equals(to)) return true;
        if (QRRequest.STATUS_IN_PROGRESS.equals(from) && QRRequest.STATUS_DONE.equals(to)) return true;
        return false;
    }

    private QRRequestDTO toDTO(QRRequest r, String tenSan) {
        return new QRRequestDTO(r.getRequestId(), r.getSanId(), tenSan, r.getRequestType(),
            r.getItemsJson(), r.getNote(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt());
    }
}
