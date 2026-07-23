package org.example.service;

import org.example.dao.QRRequestDAO;
import org.example.dao.impl.QRRequestDAOImpl;
import org.example.dto.qr.QRRequestDTO;
import org.example.model.QRRequest;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.service.manager.SanQRService;
import org.example.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.stream.Collectors;

public class QRRequestService {

    public enum ErrorCode { NOT_FOUND, FORBIDDEN, INVALID_TRANSITION, SYSTEM }

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
        QRRequest req = dao.findById(requestId);
        if (req == null) {
            return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy yêu cầu.");
        }
        if (req.getCoSoId() != staffCoSoId) {
            return Result.fail(ErrorCode.FORBIDDEN, "Yêu cầu không thuộc cơ sở của bạn.");
        }
        if (!isValidTransition(req.getStatus(), newStatus)) {
            return Result.fail(ErrorCode.INVALID_TRANSITION,
                "Không thể chuyển từ " + req.getStatus() + " sang " + newStatus + ".");
        }
        req.setStatus(newStatus);
        req.setHandledByStaffId(staffAccountId);
        QRRequest saved = dao.save(req);
        EntityManager em = JPAUtil.getEntityManager();
        String tenSan;
        try {
            San san = em.find(San.class, saved.getSanId());
            tenSan = san != null ? san.getTenSan() : "";
        } finally {
            em.close();
        }
        return Result.ok(toDTO(saved, tenSan));
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
