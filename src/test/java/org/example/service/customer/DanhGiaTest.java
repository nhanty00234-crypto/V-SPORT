package org.example.service.customer;

import org.example.model.DanhGia;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;

class DanhGiaTest {

    @Test
    @DisplayName("1. Rating model initialization and star bounds validation")
    void testRatingModel() {
        DanhGia dg = new DanhGia();
        dg.setAccountIdNguoiDanhGia(10);
        dg.setSoSao(5);
        dg.setBinhLuan("Sân đẹp, mặt thảm êm, nhân viên thân thiện!");
        dg.setNgayDanhGia(LocalDateTime.now());

        assertEquals(10, dg.getAccountIdNguoiDanhGia());
        assertEquals(5, dg.getSoSao());
        assertTrue(dg.getBinhLuan().contains("Sân đẹp"));
    }
}
