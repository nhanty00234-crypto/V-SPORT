package org.example.service.customer;

import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.util.PromotionUploadPaths;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Dựng JSON ảnh khuyến mãi cho các API Customer (Home featuredPromotions, /customer/uu-dai,
 * tìm sân, FacilityDetailApiServlet.activePromotions, kết quả áp mã). Dùng chung một chỗ để
 * đảm bảo mọi nơi trả cùng một hình dạng {coverImageUrl, images:[{imageId,url,order,isCover}]}
 * và không bao giờ lộ filesystem path - chỉ publicUrl qua PromotionImageServeServlet.
 */
public final class PromotionImagePresenter {

    private PromotionImagePresenter() {
    }

    public static List<Map<String, Object>> imageDtoList(String contextPath, List<KhuyenMaiHinhAnh> images) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (images == null) return list;
        for (KhuyenMaiHinhAnh img : images) {
            Map<String, Object> dto = new LinkedHashMap<>();
            dto.put("imageId", img.getHinhAnhId());
            dto.put("url", PromotionUploadPaths.publicUrl(contextPath, img.getDuongDan()));
            dto.put("order", img.getThuTu());
            dto.put("isCover", img.isLaAnhBia());
            list.add(dto);
        }
        return list;
    }

    public static String coverImageUrl(String contextPath, List<KhuyenMaiHinhAnh> images) {
        if (images == null || images.isEmpty()) return null;
        for (KhuyenMaiHinhAnh img : images) {
            if (img.isLaAnhBia()) return PromotionUploadPaths.publicUrl(contextPath, img.getDuongDan());
        }
        return PromotionUploadPaths.publicUrl(contextPath, images.get(0).getDuongDan());
    }

    /** Gói đầy đủ thông tin khuyến mãi + ảnh cho Customer, dùng cho featured/uu-dai/facility detail. */
    public static Map<String, Object> toCustomerJson(String contextPath, KhuyenMai km, List<KhuyenMaiHinhAnh> images) {
        Map<String, Object> dto = new LinkedHashMap<>();
        dto.put("khuyenMaiId", km.getKhuyenMaiID());
        dto.put("maCode", km.getMaCode());
        dto.put("moTa", km.getMoTa());
        dto.put("loaiGiam", km.getLoaiGiam());
        dto.put("giaTriGiam", km.getGiaTriGiam());
        dto.put("ngayBatDau", km.getNgayBatDau() != null ? km.getNgayBatDau().toString() : null);
        dto.put("ngayKetThuc", km.getNgayKetThuc() != null ? km.getNgayKetThuc().toString() : null);
        dto.put("giaTriToiThieu", km.getGiaTriToiThieu());
        dto.put("giamToiDa", km.getGiamToiDa());
        dto.put("coSoId", km.getCoSoID());
        dto.put("coverImageUrl", images == null || images.isEmpty() ? null : coverImageUrl(contextPath, images));
        dto.put("images", imageDtoList(contextPath, images));
        return dto;
    }
}
