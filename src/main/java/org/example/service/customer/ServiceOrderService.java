package org.example.service.customer;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.*;
import org.example.util.Constants;
import org.example.util.JPAUtil;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Customer gửi yêu cầu dịch vụ (PHẦN 11/12/21). Đơn dịch vụ là thực thể độc lập,
 * không nhồi vào LichDatSan/GhiChu. Giá và trạng thái LUÔN được server tính lại,
 * không tin bất kỳ giá trị nào Customer gửi từ frontend.
 */
public class ServiceOrderService {

    private static final Logger logger = LogManager.getLogger(ServiceOrderService.class);

    public static class Result {
        public final boolean success;
        public final String errorMessage;
        public final ServiceOrder order;

        private Result(boolean success, String errorMessage, ServiceOrder order) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.order = order;
        }

        static Result ok(ServiceOrder o) { return new Result(true, null, o); }
        static Result fail(String message) { return new Result(false, message, null); }
    }

    /** Input thô từ form đặt dịch vụ - mọi field đều phải được server validate lại. */
    public static class OrderInput {
        public int serviceId;
        public Integer bookingId;
        public LocalDate appointmentDate;
        public String dropOffTime;
        public String customerNote;
        // Chi tiết căng lưới (chỉ áp dụng khi dịch vụ là CANG_LUOI)
        public String racketType;
        public String racketBrand;
        public String racketModel;
        public Integer materialId;
        public boolean customerBringsString;
        public Double tensionValue;
        public String tensionUnit;
        public String stringColor;
        public Integer quantity;
        public String technicalNote;
    }

    public Result createOrder(int customerId, OrderInput input) {
        if (input == null) return Result.fail("Thiếu dữ liệu yêu cầu.");
        if (input.appointmentDate == null) return Result.fail("Vui lòng chọn ngày mang vợt/dụng cụ đến.");
        if (input.appointmentDate.isBefore(LocalDate.now())) {
            return Result.fail("Ngày mang đến không được ở trong quá khứ.");
        }

        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            // Tải lại dịch vụ + cơ sở từ DB (không tin dữ liệu client) - PHẦN 21.
            SportService service = em.find(SportService.class, input.serviceId);
            if (service == null || service.isDeleted()) {
                tx.rollback();
                return Result.fail("Dịch vụ không tồn tại hoặc đã bị gỡ bỏ.");
            }
            if (!service.isAcceptingRequests()) {
                tx.rollback();
                return Result.fail("Dịch vụ hiện không nhận yêu cầu mới.");
            }

            CoSo coSo = em.find(CoSo.class, service.getCoSoID());
            if (coSo == null || !"Đang hoạt động".equals(coSo.getTrangThai())
                    || (coSo.isDeleted())) {
                tx.rollback();
                return Result.fail("Cơ sở hiện không hoạt động.");
            }

            long approvedCap = em.createQuery(
                    "SELECT COUNT(cc) FROM CoSoCapability cc WHERE cc.coSoId = :coSoId " +
                    "AND cc.capabilityType = :capType AND cc.trangThai = :approved", Long.class)
                    .setParameter("coSoId", coSo.getCoSoID())
                    .setParameter("capType", Constants.CAPABILITY_DICH_VU_THE_THAO)
                    .setParameter("approved", Constants.CAPABILITY_STATUS_APPROVED)
                    .getSingleResult();
            if (approvedCap == 0) {
                tx.rollback();
                return Result.fail("Cơ sở chưa được phê duyệt cung cấp dịch vụ thể thao.");
            }

            // Nếu có gắn booking, booking phải thuộc chính Customer này (PHẦN 20 constraint).
            if (input.bookingId != null) {
                Lichdatsan booking = em.find(Lichdatsan.class, input.bookingId);
                if (booking == null || booking.getAccountId() == null
                        || booking.getAccountId() != customerId) {
                    tx.rollback();
                    return Result.fail("Lịch đặt sân không hợp lệ.");
                }
            }

            double estimatedPrice;
            RacketStringingConfig config = null;
            ServiceMaterial material = null;

            if ("CANG_LUOI".equals(service.getServiceType())) {
                config = em.createQuery(
                        "SELECT c FROM RacketStringingConfig c WHERE c.serviceID = :sid",
                        RacketStringingConfig.class)
                        .setParameter("sid", service.getServiceID())
                        .getResultStream().findFirst().orElse(null);
                if (config == null) {
                    tx.rollback();
                    return Result.fail("Dịch vụ chưa được cấu hình đầy đủ.");
                }
                if (input.tensionValue == null || input.tensionValue < config.getMinTension()
                        || input.tensionValue > config.getMaxTension()) {
                    tx.rollback();
                    return Result.fail("Mức căng phải trong khoảng " + config.getMinTension()
                            + " - " + config.getMaxTension() + " " + config.getTensionUnit() + ".");
                }
                String unit = input.tensionUnit != null && !input.tensionUnit.trim().isEmpty()
                        ? input.tensionUnit.trim() : config.getTensionUnit();
                if (!unit.equals(config.getTensionUnit())) {
                    tx.rollback();
                    return Result.fail("Đơn vị mức căng không khớp với cấu hình dịch vụ.");
                }
                int qty = input.quantity != null ? input.quantity : 1;
                if (qty <= 0 || qty > config.getMaxRacketsPerOrder()) {
                    tx.rollback();
                    return Result.fail("Số lượng vợt phải từ 1 đến " + config.getMaxRacketsPerOrder() + ".");
                }
                if (!input.customerBringsString) {
                    if (!config.isSellsString()) {
                        tx.rollback();
                        return Result.fail("Cơ sở này chỉ nhận khách tự mang dây.");
                    }
                    if (input.materialId == null) {
                        tx.rollback();
                        return Result.fail("Vui lòng chọn loại dây hoặc chọn tự mang dây.");
                    }
                    material = em.find(ServiceMaterial.class, input.materialId);
                    if (material == null || material.getCoSoID() != coSo.getCoSoID() || material.isDeleted()
                            || "NGUNG_SU_DUNG".equals(material.getStatus())) {
                        tx.rollback();
                        return Result.fail("Loại dây đã chọn không còn khả dụng.");
                    }
                    if ("TAM_HET".equals(material.getStatus())) {
                        tx.rollback();
                        return Result.fail("Loại dây đã chọn tạm thời hết hàng.");
                    }
                } else if (!config.isAllowCustomerString()) {
                    tx.rollback();
                    return Result.fail("Dịch vụ này không nhận khách tự mang dây.");
                }

                double stringPrice = material != null ? (material.getPrice() + material.getExtraFee()) : 0;
                estimatedPrice = (config.getStringingPrice() + stringPrice) * qty;
            } else {
                int qty = input.quantity != null ? input.quantity : 1;
                if (qty <= 0) {
                    tx.rollback();
                    return Result.fail("Số lượng không hợp lệ.");
                }
                estimatedPrice = service.getBasePrice() * qty;
            }

            ServiceOrder order = new ServiceOrder();
            order.setCustomerID(customerId);
            order.setCoSoID(coSo.getCoSoID());
            order.setServiceID(service.getServiceID());
            order.setBookingID(input.bookingId);
            order.setStatus(ServiceOrder.PENDING_CONFIRMATION);
            order.setRequestedAt(LocalDateTime.now());
            order.setAppointmentDate(input.appointmentDate);
            order.setDropOffTime(trim(input.dropOffTime));
            order.setCustomerNote(trim(input.customerNote));
            order.setEstimatedPrice(estimatedPrice);
            order.setCreatedAt(LocalDateTime.now());
            order.setUpdatedAt(LocalDateTime.now());
            em.persist(order);
            em.flush();

            if ("CANG_LUOI".equals(service.getServiceType())) {
                RacketStringingOrderDetail detail = new RacketStringingOrderDetail();
                detail.setOrderID(order.getOrderID());
                detail.setRacketType(trim(input.racketType));
                detail.setRacketBrand(trim(input.racketBrand));
                detail.setRacketModel(trim(input.racketModel));
                detail.setMaterialID(material != null ? material.getMaterialID() : null);
                detail.setCustomerBringsString(input.customerBringsString);
                detail.setTensionValue(input.tensionValue);
                detail.setTensionUnit(config.getTensionUnit());
                detail.setStringColor(trim(input.stringColor));
                detail.setQuantity(input.quantity != null ? input.quantity : 1);
                detail.setTechnicalNote(trim(input.technicalNote));
                em.persist(detail);
            }

            ServiceOrderStatusHistory history = new ServiceOrderStatusHistory();
            history.setOrderID(order.getOrderID());
            history.setFromStatus(null);
            history.setToStatus(ServiceOrder.PENDING_CONFIRMATION);
            history.setChangedBy(customerId);
            history.setChangedAt(LocalDateTime.now());
            history.setNote("Customer gửi yêu cầu dịch vụ");
            em.persist(history);

            tx.commit();
            return Result.ok(order);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi tạo service order customerId={}: {}", customerId, e.getMessage(), e);
            return Result.fail("Lỗi hệ thống khi gửi yêu cầu dịch vụ.");
        } finally {
            em.close();
        }
    }

    private static String trim(String s) { return s == null ? null : (s.trim().isEmpty() ? null : s.trim()); }
}
