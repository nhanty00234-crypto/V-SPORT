package org.example.controller.manager;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dto.qr.SanQRManagerDTO;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.TaiKhoan;
import org.example.service.manager.SanQRService;
import org.example.service.manager.SanService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Trang + API Manager quản lý mã QR theo từng sân (QR-02). Không xử lý ảnh
 * (SanQRImageServlet) hay in (SanQRPrintServlet) - chỉ list/detail/action.
 *
 * TRUST BOUNDARY: coSoId/actorAccountId luôn lấy từ session ("user"), KHÔNG
 * BAO GIỜ đọc từ request.getParameter - xem javadoc lớp SanQRService.
 */
@WebServlet("/manager/ma-qr-san")
public class SanQRManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(SanQRManagerServlet.class);
    private static final Gson GSON = new Gson();

    private final SanService sanService;
    private final SanQRService sanQRService;

    public SanQRManagerServlet() {
        this.sanService = new SanService();
        this.sanQRService = new SanQRService();
    }

    public SanQRManagerServlet(SanService sanService, SanQRService sanQRService) {
        this.sanService = sanService;
        this.sanQRService = sanQRService;
    }

    private TaiKhoan requireManager(HttpServletRequest request, HttpServletResponse response, boolean isApi)
            throws IOException {
        HttpSession session = request.getSession();
        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER) {
            if (isApi) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(GSON.toJson(Map.of("success", false, "error", "Chưa đăng nhập.")));
            } else {
                response.sendRedirect(request.getContextPath() + "/dangnhap");
            }
            return null;
        }
        if (manager.getCoSoId() == null) {
            if (isApi) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(GSON.toJson(Map.of("success", false,
                        "error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.")));
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
            }
            return null;
        }
        return manager;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        boolean isApi = "1".equals(request.getParameter("ajax"));
        TaiKhoan manager = requireManager(request, response, isApi);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();

        try {
            List<SanQRManagerDTO> rows = buildRows(coSoId, request);

            if (isApi) {
                Map<String, Object> stats = buildStats(rows);
                Map<String, Object> body = new HashMap<>();
                body.put("success", true);
                body.put("items", rows);
                body.put("stats", stats);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(GSON.toJson(body));
                return;
            }

            request.setAttribute("dsQr", rows);
            request.setAttribute("stats", buildStats(rows));
            request.getRequestDispatcher("/manager/MaQrSan.jsp").forward(request, response);
        } catch (Exception e) {
            logger.error("Lỗi liệt kê QR sân coSoId={}: {}", coSoId, e.getMessage(), e);
            if (isApi) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write(GSON.toJson(Map.of("success", false, "error", "Lỗi hệ thống.")));
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống.");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        TaiKhoan manager = requireManager(request, response, true);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();
        int actorAccountId = manager.getAccountId();

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "create": {
                    int sanId = parseSanId(request);
                    SanQRService.Result r = sanQRService.getOrCreate(sanId, coSoId, actorAccountId);
                    writeResult(response, r);
                    return;
                }
                case "enable": {
                    int sanId = parseSanId(request);
                    SanQRService.Result r = sanQRService.enable(sanId, coSoId, actorAccountId);
                    writeResult(response, r);
                    return;
                }
                case "disable": {
                    int sanId = parseSanId(request);
                    SanQRService.Result r = sanQRService.disable(sanId, coSoId, actorAccountId);
                    writeResult(response, r);
                    return;
                }
                case "regenerate": {
                    int sanId = parseSanId(request);
                    SanQRService.Result r = sanQRService.regenerate(sanId, coSoId, actorAccountId);
                    writeResult(response, r);
                    return;
                }
                case "batchCreate": {
                    batchCreate(request, response, coSoId, actorAccountId);
                    return;
                }
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write(GSON.toJson(Map.of("success", false, "error", "Hành động không hợp lệ.")));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(GSON.toJson(Map.of("success", false, "error", "Tham số không hợp lệ.")));
        } catch (Exception e) {
            logger.error("Lỗi action={} coSoId={}: {}", action, coSoId, e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(GSON.toJson(Map.of("success", false, "error", "Lỗi hệ thống.")));
        }
    }

    private int parseSanId(HttpServletRequest request) {
        String raw = request.getParameter("sanId");
        if (raw == null) throw new NumberFormatException("sanId thiếu");
        return Integer.parseInt(raw.trim());
    }

    private void writeResult(HttpServletResponse response, SanQRService.Result r) throws IOException {
        if (r.success) {
            Map<String, Object> body = new HashMap<>();
            body.put("success", true);
            body.put("qrStatus", r.sanQR.getTrangThai());
            body.put("regenerateCount", r.sanQR.getRegenerateCount());
            body.put("maskedShortCode", SanQRManagerDTO.mask(r.sanQR.getShortCode()));
            response.getWriter().write(GSON.toJson(body));
            return;
        }
        int status;
        switch (r.errorCode) {
            case NOT_FOUND: status = HttpServletResponse.SC_NOT_FOUND; break;
            case FORBIDDEN: status = HttpServletResponse.SC_FORBIDDEN; break;
            case INVALID_TRANSITION:
            case CONFLICT: status = HttpServletResponse.SC_CONFLICT; break;
            default: status = HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        }
        response.setStatus(status);
        response.getWriter().write(GSON.toJson(Map.of("success", false, "error", r.errorMessage)));
    }

    /**
     * Chỉ tạo QR cho sân thuộc ĐÚNG cơ sở của Manager và CHƯA có QR - không
     * bao giờ regenerate QR đã tồn tại (batch create không phải batch
     * regenerate). Một sân lỗi không làm hỏng kết quả các sân khác (partial
     * success), lỗi được gom lại rồi trả về rõ ràng.
     */
    private void batchCreate(HttpServletRequest request, HttpServletResponse response,
                              int coSoId, int actorAccountId) throws IOException {
        List<San> allSans = sanService.getSansByCoSo(coSoId);
        List<Integer> sanIds = new ArrayList<>();
        for (San s : allSans) sanIds.add(s.getSanID());
        Map<Integer, SanQR> existing = sanQRService.findExistingBySanIds(sanIds);

        int created = 0, alreadyExisted = 0, failed = 0;
        List<String> errors = new ArrayList<>();
        for (San s : allSans) {
            if (existing.containsKey(s.getSanID())) {
                alreadyExisted++;
                continue;
            }
            SanQRService.Result r = sanQRService.getOrCreate(s.getSanID(), coSoId, actorAccountId);
            if (r.success) {
                created++;
            } else {
                failed++;
                errors.add(s.getTenSan() + ": " + r.errorMessage);
            }
        }

        Map<String, Object> body = new HashMap<>();
        body.put("success", true);
        body.put("totalSan", allSans.size());
        body.put("created", created);
        body.put("alreadyExisted", alreadyExisted);
        body.put("failed", failed);
        body.put("errors", errors);
        response.getWriter().write(GSON.toJson(body));
    }

    private List<SanQRManagerDTO> buildRows(int coSoId, HttpServletRequest request) {
        List<San> sans = sanService.getSansByCoSo(coSoId);
        List<LoaiSan> loaiSans = sanService.getLoaiSansByCoSo(coSoId);
        List<MonTheThao> monTheThaos = sanService.getRegisteredMonTheThao(coSoId);

        Map<Integer, LoaiSan> loaiSanMap = new HashMap<>();
        for (LoaiSan l : loaiSans) loaiSanMap.put(l.getLoaiSanID(), l);
        Map<Integer, String> monTenMap = new HashMap<>();
        for (MonTheThao m : monTheThaos) monTenMap.put(m.getMonTheThaoID(), m.getTenMon());

        List<Integer> sanIds = new ArrayList<>();
        for (San s : sans) sanIds.add(s.getSanID());
        Map<Integer, SanQR> qrMap = sanQRService.findExistingBySanIds(sanIds);

        List<SanQRManagerDTO> rows = new ArrayList<>();
        for (San s : sans) {
            LoaiSan loaiSan = loaiSanMap.get(s.getLoaiSanID());
            String tenLoaiSan = loaiSan != null ? loaiSan.getTenLoai() : null;
            String tenMon = loaiSan != null ? monTenMap.get(loaiSan.getMonTheThaoID()) : null;

            SanQR qr = qrMap.get(s.getSanID());
            SanQRManagerDTO.Builder b = SanQRManagerDTO.builder()
                    .sanId(s.getSanID())
                    .tenSan(s.getTenSan())
                    .tenLoaiSan(tenLoaiSan)
                    .tenMonTheThao(tenMon)
                    .trangThaiSan(s.getTrangThai());

            if (qr == null) {
                b.hasQr(false).qrStatus(null).qrStatusLabel("Chưa tạo")
                        .canCreate(true).canEnable(false).canDisable(false)
                        .canRegenerate(false).canPrint(false);
            } else {
                String status = qr.getTrangThai();
                b.hasQr(true)
                        .qrStatus(status)
                        .qrStatusLabel(statusLabel(status))
                        .maskedShortCode(SanQRManagerDTO.mask(qr.getShortCode()))
                        .createdAt(qr.getCreatedAt())
                        .updatedAt(qr.getUpdatedAt())
                        .regenerateCount(qr.getRegenerateCount())
                        .canCreate(false)
                        .canEnable(SanQR.DISABLED.equals(status))
                        .canDisable(SanQR.ACTIVE.equals(status))
                        .canRegenerate(!SanQR.REVOKED.equals(status))
                        .canPrint(!SanQR.REVOKED.equals(status));
            }
            rows.add(b.build());
        }
        return applyFilters(rows, request);
    }

    private List<SanQRManagerDTO> applyFilters(List<SanQRManagerDTO> rows, HttpServletRequest request) {
        String search = request.getParameter("search");
        String monTheThao = request.getParameter("monTheThao");
        String qrStatusFilter = request.getParameter("qrStatus");
        String sanStatusFilter = request.getParameter("sanStatus");

        List<SanQRManagerDTO> out = new ArrayList<>();
        for (SanQRManagerDTO r : rows) {
            if (search != null && !search.isBlank()
                    && (r.getTenSan() == null || !r.getTenSan().toLowerCase().contains(search.trim().toLowerCase()))) {
                continue;
            }
            if (monTheThao != null && !monTheThao.isBlank()
                    && (r.getTenMonTheThao() == null || !r.getTenMonTheThao().equalsIgnoreCase(monTheThao.trim()))) {
                continue;
            }
            if (qrStatusFilter != null && !qrStatusFilter.isBlank() && !"ALL".equalsIgnoreCase(qrStatusFilter)) {
                if ("NONE".equalsIgnoreCase(qrStatusFilter)) {
                    if (r.isHasQr()) continue;
                } else if (!qrStatusFilter.equalsIgnoreCase(r.getQrStatus())) {
                    continue;
                }
            }
            if (sanStatusFilter != null && !sanStatusFilter.isBlank() && !"ALL".equalsIgnoreCase(sanStatusFilter)
                    && !sanStatusFilter.equalsIgnoreCase(r.getTrangThaiSan())) {
                continue;
            }
            out.add(r);
        }
        return out;
    }

    private Map<String, Object> buildStats(List<SanQRManagerDTO> rows) {
        int total = rows.size();
        int active = 0, disabled = 0, none = 0;
        for (SanQRManagerDTO r : rows) {
            if (!r.isHasQr()) { none++; continue; }
            if (SanQR.ACTIVE.equals(r.getQrStatus())) active++;
            else if (SanQR.DISABLED.equals(r.getQrStatus())) disabled++;
        }
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", total);
        stats.put("active", active);
        stats.put("disabled", disabled);
        stats.put("none", none);
        return stats;
    }

    private String statusLabel(String status) {
        if (SanQR.ACTIVE.equals(status)) return "Đang hoạt động";
        if (SanQR.DISABLED.equals(status)) return "Đang tắt";
        if (SanQR.REVOKED.equals(status)) return "Đã vô hiệu hóa";
        return "Chưa tạo";
    }
}
