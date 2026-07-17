package org.example.controller.customer.api;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/customer/facilities/map")
public class MapApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Double latitude = null;
        Double longitude = null;
        Double radiusKm = null;
        Integer sportId = null;
        boolean openNow = false;

        String latParam = req.getParameter("latitude");
        String lonParam = req.getParameter("longitude");
        String radiusParam = req.getParameter("radiusKm");
        String sportParam = req.getParameter("sportId");
        String openNowParam = req.getParameter("openNow");

        try {
            if (latParam != null && !latParam.trim().isEmpty()) {
                latitude = Double.parseDouble(latParam.trim());
                if (latitude < -90 || latitude > 90) {
                    sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Vĩ độ không hợp lệ. Phải nằm trong khoảng [-90, 90].");
                    return;
                }
            }
            if (lonParam != null && !lonParam.trim().isEmpty()) {
                longitude = Double.parseDouble(lonParam.trim());
                if (longitude < -180 || longitude > 180) {
                    sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Kinh độ không hợp lệ. Phải nằm trong khoảng [-180, 180].");
                    return;
                }
            }
            if (radiusParam != null && !radiusParam.trim().isEmpty()) {
                radiusKm = Double.parseDouble(radiusParam.trim());
                if (radiusKm <= 0) {
                    sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Bán kính tìm kiếm phải lớn hơn 0.");
                    return;
                }
            }
            if (sportParam != null && !sportParam.trim().isEmpty()) {
                sportId = Integer.parseInt(sportParam.trim());
            }
            if (openNowParam != null && !openNowParam.trim().isEmpty()) {
                openNow = Boolean.parseBoolean(openNowParam.trim());
            }
        } catch (NumberFormatException e) {
            sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Định dạng tham số truy vấn không hợp lệ.");
            return;
        }

        // Validate coordinate pairing
        if ((latitude != null && longitude == null) || (latitude == null && longitude != null)) {
            sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Cần cung cấp cả vĩ độ (latitude) và kinh độ (longitude).");
            return;
        }

        List<Map<String, Object>> facilitiesList = new java.util.ArrayList<>();
        String sql = "SELECT c.CoSoID, c.TenCoSo, c.DiaChi, c.ViDo, c.KinhDo, c.HinhAnh, c.GioMoCua, c.GioDongCua, c.LoaiHinhKinhDoanh, " +
                "       (SELECT MIN(ls.GiaKhongDen) FROM LoaiSan ls WHERE ls.CoSoID = c.CoSoID) AS MinPrice, " +
                "       (SELECT COUNT(*) FROM San s WHERE s.CoSoID = c.CoSoID AND s.TrangThai = N'Sẵn sàng' AND (s.IsDeleted = 0 OR s.IsDeleted IS NULL)) AS ReadyCourtCount " +
                "FROM CoSo c " +
                "WHERE (c.IsDeleted = 0 OR c.IsDeleted IS NULL) " +
                "  AND c.TrangThai = N'Đang hoạt động'";

        if (sportId != null) {
            sql += "  AND c.CoSoID IN (SELECT DISTINCT ls.CoSoID FROM LoaiSan ls WHERE ls.MonTheThaoID = ?)";
        }

        LocalTime nowTime = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toLocalTime();

        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (sportId != null) {
                ps.setInt(1, sportId);
            }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int coSoId = rs.getInt("CoSoID");
                    String tenCoSo = rs.getString("TenCoSo");
                    String diaChi = rs.getString("DiaChi");
                    java.math.BigDecimal viDo = rs.getBigDecimal("ViDo");
                    java.math.BigDecimal kinhDo = rs.getBigDecimal("KinhDo");
                    String hinhAnh = rs.getString("HinhAnh");
                    java.sql.Time gioMo = rs.getTime("GioMoCua");
                    java.sql.Time gioDong = rs.getTime("GioDongCua");
                    String loaiHinh = rs.getString("LoaiHinhKinhDoanh");
                    double minPrice = rs.getDouble("MinPrice");
                    int readyCourtCount = rs.getInt("ReadyCourtCount");

                    LocalTime openLocal = gioMo != null ? gioMo.toLocalTime() : null;
                    LocalTime closeLocal = gioDong != null ? gioDong.toLocalTime() : null;

                    // Filter by openNow
                    if (openNow) {
                        if (!isOpenNow(openLocal, closeLocal, nowTime)) {
                            continue;
                        }
                    }

                    double latVal = viDo != null ? viDo.doubleValue() : 0.0;
                    double lonVal = kinhDo != null ? kinhDo.doubleValue() : 0.0;

                    Double dist = null;
                    if (latitude != null && longitude != null) {
                        dist = calculateHaversineDistance(latitude, longitude, latVal, lonVal);
                        if (radiusKm != null && dist > radiusKm) {
                            continue;
                        }
                    }

                    Map<String, Object> fac = new HashMap<>();
                    fac.put("coSoId", coSoId);
                    fac.put("tenCoSo", tenCoSo);
                    fac.put("address", diaChi);
                    fac.put("latitude", latVal);
                    fac.put("longitude", lonVal);
                    fac.put("imageUrl", hinhAnh != null ? hinhAnh : "");
                    fac.put("openingTime", gioMo != null ? gioMo.toString().substring(0, 5) : "");
                    fac.put("closingTime", gioDong != null ? gioDong.toString().substring(0, 5) : "");
                    fac.put("readyCourtCount", readyCourtCount);
                    fac.put("minPrice", minPrice);
                    fac.put("distanceKm", dist != null ? Math.round(dist * 100.0) / 100.0 : null);

                    // Parse sports list
                    List<String> sportsList = new java.util.ArrayList<>();
                    if (loaiHinh != null && !loaiHinh.trim().isEmpty()) {
                        for (String s : loaiHinh.split(",")) {
                            sportsList.add(s.trim());
                        }
                    }
                    fac.put("sports", sportsList);

                    facilitiesList.add(fac);
                }
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json; charset=UTF-8");
            Map<String, Object> err = new HashMap<>();
            err.put("success", false);
            err.put("error", "Lỗi máy chủ nội bộ khi truy vấn bản đồ.");
            resp.getWriter().write(new com.google.gson.Gson().toJson(err));
            return;
        }

        // Sort by distance if coordinates provided
        if (latitude != null && longitude != null) {
            facilitiesList.sort((a, b) -> {
                Double d1 = (Double) a.get("distanceKm");
                Double d2 = (Double) b.get("distanceKm");
                if (d1 == null) return 1;
                if (d2 == null) return -1;
                return d1.compareTo(d2);
            });
        }

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(new com.google.gson.Gson().toJson(facilitiesList));
    }

    private void sendErrorResponse(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        resp.getWriter().write(new com.google.gson.Gson().toJson(error));
    }

    private double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth radius in km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private boolean isOpenNow(LocalTime open, LocalTime close, LocalTime now) {
        if (open == null || close == null) {
            return true;
        }
        if (open.isBefore(close)) {
            return !now.isBefore(open) && !now.isAfter(close);
        } else {
            return !now.isBefore(open) || !now.isAfter(close);
        }
    }
}
