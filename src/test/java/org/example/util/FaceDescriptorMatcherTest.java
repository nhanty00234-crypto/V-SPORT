package org.example.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class FaceDescriptorMatcherTest {

    /** Tạo descriptor 128 chiều với mọi phần tử bằng v. */
    private static double[] flat(double v) {
        double[] d = new double[128];
        java.util.Arrays.fill(d, v);
        return d;
    }

    private static String jsonOf(double... values) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < values.length; i++) {
            if (i > 0) sb.append(',');
            sb.append(values[i]);
        }
        return sb.append(']').toString();
    }

    @Test
    void parseDangCuMotMauPhangThanhMotMau() {
        String legacy = jsonOf(flat(0.1));
        double[][] samples = FaceDescriptorMatcher.parse(legacy);
        assertEquals(1, samples.length);
        assertEquals(128, samples[0].length);
        assertEquals(0.1, samples[0][0], 1e-9);
    }

    @Test
    void parseDangMoiNhieuMau() {
        String nested = "[" + jsonOf(flat(0.1)) + "," + jsonOf(flat(0.2)) + "]";
        double[][] samples = FaceDescriptorMatcher.parse(nested);
        assertEquals(2, samples.length);
        assertEquals(0.2, samples[1][0], 1e-9);
    }

    @Test
    void parseDauVaoHongTraVeRong() {
        assertEquals(0, FaceDescriptorMatcher.parse(null).length);
        assertEquals(0, FaceDescriptorMatcher.parse("").length);
        assertEquals(0, FaceDescriptorMatcher.parse("[]").length);
        assertEquals(0, FaceDescriptorMatcher.parse("khong-phai-json").length);
    }

    @Test
    void distanceTinhDungEuclidean() {
        double[] a = {0.0, 0.0, 0.0};
        double[] b = {3.0, 4.0, 0.0};
        assertEquals(5.0, FaceDescriptorMatcher.distance(a, b), 1e-9);
    }

    @Test
    void minDistanceLayMauGanNhat() {
        double[][] samples = { flat(0.0), flat(0.5) };
        double[] incoming = flat(0.5);
        assertEquals(0.0, FaceDescriptorMatcher.minDistance(samples, incoming), 1e-9);
    }

    @Test
    void minDistanceKhongCoMauTraVeMaxValue() {
        assertEquals(Double.MAX_VALUE,
                FaceDescriptorMatcher.minDistance(new double[0][], flat(0.1)), 0.0);
    }

    @Test
    void minDistanceBoQuaMauQuaNgan() {
        // Mẫu ngắn (3 chiều) khớp gần tuyệt đối với bất kỳ incoming nào nếu không bị loại,
        // nhưng phải bị bỏ qua để mẫu 128 chiều hợp lệ mới là mẫu quyết định.
        double[] mauNgan = { 0.1, 0.1, 0.1 };
        double[][] samples = { mauNgan, flat(0.5) };
        double[] incoming = flat(0.5);
        assertEquals(0.0, FaceDescriptorMatcher.minDistance(samples, incoming), 1e-9);
    }

    @Test
    void minDistanceChiCoMauQuaNganTraVeMaxValue() {
        double[][] samples = { { 0.1, 0.1, 0.1 }, {} };
        assertEquals(Double.MAX_VALUE,
                FaceDescriptorMatcher.minDistance(samples, flat(0.1)), 0.0);
    }

    @Test
    void toStorageJsonLuonSinhDangLong() {
        String json = FaceDescriptorMatcher.toStorageJson(new double[][]{ {1.0, 2.0} });
        assertTrue(json.startsWith("[["), "Phải là mảng lồng, nhận được: " + json);
        // Đọc lại ra đúng một mẫu
        assertEquals(1, FaceDescriptorMatcher.parse(json).length);
    }
}
