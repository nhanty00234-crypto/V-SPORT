package org.example.controller.api.v1.facility;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.BaseApiServlet;
import org.example.api.ImageUrls;
import org.example.dto.api.ApiDtos;
import org.example.model.LoaiSan;
import org.example.model.San;
import org.example.service.booking.CourtAvailabilityService;
import org.example.service.customer.CustomerCatalogService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Map;

/**
 * GET /api/v1/courts/{courtId}                       — chi tiết một sân
 * GET /api/v1/courts/{courtId}/availability?date=... — khung giờ còn trống + giá từng khung
 *
 * Giá và điều kiện trống đều do server tính bằng đúng service mà luồng đặt sân Web dùng.
 */
@WebServlet("/api/v1/courts/*")
public class CourtApiServlet extends BaseApiServlet {

    private final CustomerCatalogService catalogService = new CustomerCatalogService();
    private final CourtAvailabilityService availabilityService = new CourtAvailabilityService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            String[] seg = pathSegments(req);
            if (seg.length == 1) {
                courtDetail(req, resp, requireInt(seg[0], "courtId"));
            } else if (seg.length == 2 && "availability".equals(seg[1])) {
                availability(req, resp, requireInt(seg[0], "courtId"));
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    private void courtDetail(HttpServletRequest req, HttpServletResponse resp, int courtId) throws IOException {
        San s = catalogService.findCourt(courtId);
        if (s == null) throw notFound("Không tìm thấy sân.");
        Map<Integer, LoaiSan> types = catalogService.courtTypeMap();
        Map<Integer, String> sportNames = catalogService.sportNameMap();
        LoaiSan ls = types.get(s.getLoaiSanID());

        ApiDtos.CourtDto dto = new ApiDtos.CourtDto();
        dto.courtId = s.getSanID();
        dto.name = s.getTenSan();
        dto.facilityId = s.getCoSoID();
        dto.courtTypeId = s.getLoaiSanID();
        dto.status = s.getTrangThai();
        dto.image = ImageUrls.absolutize(req, s.getHinhAnh());
        dto.description = s.getMoTa();
        if (ls != null) {
            dto.courtTypeName = ls.getTenLoai();
            dto.sportId = ls.getMonTheThaoID();
            dto.sportName = sportNames.get(ls.getMonTheThaoID());
            dto.priceWithoutLight = BigDecimal.valueOf(ls.getGiaKhongDen());
            dto.priceWithLight = BigDecimal.valueOf(ls.getGiaCoDen());
            dto.lightingStart = fmt(ls.getGioBatDauLenDen());
            dto.lightingEnd = fmt(ls.getGioKetThucLenDen());
        }
        ok(resp, dto);
    }

    private void availability(HttpServletRequest req, HttpServletResponse resp, int courtId) throws IOException {
        String dateRaw = req.getParameter("date");
        LocalDate date;
        if (dateRaw == null || dateRaw.isBlank()) {
            date = LocalDate.now(CustomerCatalogService.VN_ZONE);
        } else {
            try {
                date = LocalDate.parse(dateRaw.trim());
            } catch (RuntimeException e) {
                throw badRequest("Tham số date phải theo định dạng yyyy-MM-dd.");
            }
        }
        Integer slotMinutes = optionalInt(req, "slotMinutes");

        CourtAvailabilityService.Availability av;
        try {
            av = slotMinutes != null
                    ? availabilityService.getAvailability(courtId, date, slotMinutes)
                    : availabilityService.getAvailability(courtId, date);
        } catch (CourtAvailabilityService.CourtNotFoundException e) {
            throw notFound(e.getMessage());
        }

        ApiDtos.AvailabilityDto dto = new ApiDtos.AvailabilityDto();
        dto.courtId = av.courtId;
        dto.courtName = av.courtName;
        dto.facilityId = av.facilityId;
        dto.date = av.date;
        dto.openTime = fmt(av.openTime);
        dto.closeTime = fmt(av.closeTime);
        dto.slotMinutes = av.slotMinutes;
        dto.slots = new ArrayList<>();
        for (CourtAvailabilityService.Slot s : av.slots) {
            ApiDtos.SlotDto sd = new ApiDtos.SlotDto();
            sd.startTime = s.startTime;
            sd.endTime = s.endTime;
            sd.available = s.available;
            sd.reason = s.reason;
            sd.price = s.price;
            dto.slots.add(sd);
        }
        ok(resp, dto);
    }

    private static String fmt(LocalTime t) {
        return t == null ? null : String.format("%02d:%02d", t.getHour(), t.getMinute());
    }
}
