package org.example.api;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

/**
 * Gson dùng chung cho toàn bộ REST API mobile (/api/v1/*).
 *
 * Quy ước date/time (mục XVIII của spec Mobile):
 *  - LocalDate  -> "yyyy-MM-dd"
 *  - LocalTime  -> "HH:mm"      (khung giờ đặt sân luôn theo giờ Việt Nam, không phải instant)
 *  - LocalDateTime -> "yyyy-MM-dd'T'HH:mm:ss"
 *  - java.util.Date (instant thật, VD ThoiGianGui) -> ISO-8601 có offset theo Asia/Ho_Chi_Minh
 * Không bao giờ trả UTC "trần" cho mobile để tránh lệch múi giờ khi hiển thị lịch đặt.
 */
public final class ApiJson {

    public static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATETIME_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private static final Gson GSON = new GsonBuilder()
            .serializeNulls()
            .registerTypeAdapter(LocalDate.class,
                    (JsonSerializer<LocalDate>) (src, t, ctx) -> new JsonPrimitive(src.toString()))
            .registerTypeAdapter(LocalTime.class,
                    (JsonSerializer<LocalTime>) (src, t, ctx) -> new JsonPrimitive(src.format(TIME_FMT)))
            .registerTypeAdapter(LocalDateTime.class,
                    (JsonSerializer<LocalDateTime>) (src, t, ctx) -> new JsonPrimitive(src.format(DATETIME_FMT)))
            .registerTypeAdapter(Date.class,
                    (JsonSerializer<Date>) (src, t, ctx) -> new JsonPrimitive(
                            src.toInstant().atZone(VN_ZONE).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME)))
            .create();

    private ApiJson() {}

    public static Gson gson() {
        return GSON;
    }

    public static String toJson(Object o) {
        return GSON.toJson(o);
    }

    public static <T> T fromJson(String json, Class<T> type) {
        return GSON.fromJson(json, type);
    }
}
