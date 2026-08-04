package org.example.util;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;

/**
 * So khớp khuôn mặt với nhiều mẫu đã đăng ký.
 *
 * Cột Accounts.FaceDescriptor có hai định dạng cùng tồn tại:
 *   - cũ:  [0.1, 0.2, ...]              (đúng một mẫu 128 chiều)
 *   - mới: [[0.1, ...], [0.3, ...]]     (nhiều mẫu)
 * parse() nhận cả hai nên bản ghi cũ không cần migration.
 */
public final class FaceDescriptorMatcher {

    private static final Gson GSON = new Gson();
    private static final double[][] EMPTY = new double[0][];

    private FaceDescriptorMatcher() {}

    /** Đọc descriptor đã lưu thành danh sách mẫu. Dữ liệu hỏng trả mảng rỗng. */
    public static double[][] parse(String json) {
        if (json == null || json.trim().isEmpty()) return EMPTY;
        try {
            JsonArray outer = GSON.fromJson(json, JsonArray.class);
            if (outer == null || outer.size() == 0) return EMPTY;

            JsonElement first = outer.get(0);
            if (first.isJsonPrimitive()) {
                // Định dạng cũ: một mẫu phẳng
                return new double[][]{ GSON.fromJson(outer, double[].class) };
            }

            double[][] samples = new double[outer.size()][];
            for (int i = 0; i < outer.size(); i++) {
                samples[i] = GSON.fromJson(outer.get(i), double[].class);
            }
            return samples;
        } catch (Exception e) {
            return EMPTY;
        }
    }

    /** Khoảng cách Euclidean, so tới độ dài nhỏ hơn của hai vector. */
    public static double distance(double[] a, double[] b) {
        if (a == null || b == null) return Double.MAX_VALUE;
        double sum = 0;
        int len = Math.min(a.length, b.length);
        for (int i = 0; i < len; i++) {
            double diff = a[i] - b[i];
            sum += diff * diff;
        }
        return Math.sqrt(sum);
    }

    /** Độ dài tối thiểu của một mẫu hợp lệ (descriptor face-api chuẩn có 128 chiều). */
    private static final int MIN_SAMPLE_LENGTH = 128;

    /**
     * Khoảng cách tới mẫu gần nhất. Bỏ qua các mẫu ngắn hơn MIN_SAMPLE_LENGTH — mẫu quá ngắn
     * (dữ liệu hỏng, sửa tay trong DB) so trên min(a.length, b.length) sẽ khớp gần như bất kỳ ai.
     * Không còn mẫu hợp lệ nào (kể cả khi input rỗng) → Double.MAX_VALUE.
     */
    public static double minDistance(double[][] samples, double[] incoming) {
        if (samples == null || samples.length == 0) return Double.MAX_VALUE;
        double best = Double.MAX_VALUE;
        for (double[] sample : samples) {
            if (sample == null || sample.length < MIN_SAMPLE_LENGTH) continue;
            double d = distance(sample, incoming);
            if (d < best) best = d;
        }
        return best;
    }

    /** Serialize về dạng lồng để lưu DB — luôn ghi định dạng mới. */
    public static String toStorageJson(double[][] samples) {
        return GSON.toJson(samples == null ? EMPTY : samples);
    }
}
