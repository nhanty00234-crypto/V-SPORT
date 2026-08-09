package org.example.controller.api.v1.facility;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.BaseApiServlet;
import org.example.dto.api.ApiDtos;
import org.example.service.customer.CustomerCatalogService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * GET /api/v1/sports — danh sách môn thể thao đang hoạt động và THỰC SỰ có sân.
 * Endpoint công khai (không cần token) để màn hình Splash/Home hiển thị được ngay.
 */
@WebServlet("/api/v1/sports")
public class SportApiServlet extends BaseApiServlet {

    private final CustomerCatalogService catalogService = new CustomerCatalogService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            List<ApiDtos.SportDto> out = new ArrayList<>();
            for (CustomerCatalogService.SportSummary s : catalogService.listAvailableSports()) {
                ApiDtos.SportDto dto = new ApiDtos.SportDto();
                dto.sportId = s.sportId;
                dto.name = s.name;
                dto.courtCount = s.courtCount;
                dto.facilityCount = s.facilityCount;
                out.add(dto);
            }
            ok(resp, out);
        });
    }
}
