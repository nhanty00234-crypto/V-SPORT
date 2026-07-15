<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Hóa đơn #${hoaDon.hoaDonId} | V-SPORT</title>
    <jsp:include page="/staff/common/staff_head.jsp" />
    <style>
        body { background: #eef0f3; }

        .receipt {
            width: 80mm;
            max-width: 100%;
            margin: 0 auto;
            background: #ffffff;
            color: #000000;
            font-family: 'Courier New', 'Consolas', monospace;
            font-size: 12.5px;
            line-height: 1.5;
            padding: 14px 12px;
            box-sizing: border-box;
            word-break: break-word;
        }

        .receipt-row {
            display: flex;
            justify-content: space-between;
            gap: 8px;
        }

        .receipt-money {
            text-align: right;
            white-space: nowrap;
        }

        .receipt hr {
            border: none;
            border-top: 1px dashed #999;
            margin: 8px 0;
        }

        .receipt .center { text-align: center; }
        .receipt .bold { font-weight: 700; }
        .receipt .small { font-size: 10.5px; color: #444; }

        .receipt .total-row {
            font-size: 15px;
            font-weight: 800;
        }

        .receipt table.dv-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 4px;
        }
        .receipt table.dv-table th {
            text-align: left;
            font-size: 10.5px;
            font-weight: 700;
            border-bottom: 1px dashed #999;
            padding-bottom: 3px;
        }
        .receipt table.dv-table th.qty,
        .receipt table.dv-table th.money { text-align: right; }
        .receipt table.dv-table td {
            padding: 3px 0;
            vertical-align: top;
        }
        .receipt table.dv-table td.qty,
        .receipt table.dv-table td.money { text-align: right; white-space: nowrap; }

        @media print {
            .no-print { display: none !important; }
            body { margin: 0; background: #ffffff; }
            .receipt-shell { box-shadow: none !important; border: none !important; padding: 0 !important; }
            .receipt { width: 80mm; max-width: 80mm; border: none; box-shadow: none; }
        }

        @page { size: 80mm auto; margin: 3mm; }
    </style>
</head>
<body class="min-h-screen py-8 px-4">

    <div class="no-print max-w-[420px] mx-auto mb-4 flex items-center justify-between gap-2">
        <a href="${pageContext.request.contextPath}/staff/checkin"
           class="px-4 py-2.5 rounded-xl border border-zinc-200 bg-white text-zinc-600 font-bold text-sm hover:bg-zinc-50 transition-all">
            &larr; Quay lại Check-in
        </a>
        <div class="flex items-center gap-2">
            <button type="button" onclick="window.close()"
                    class="px-4 py-2.5 rounded-xl border border-zinc-200 bg-white text-zinc-500 font-bold text-sm hover:bg-zinc-50 transition-all">
                Đóng
            </button>
            <button type="button" onclick="window.print()"
                    class="px-5 py-2.5 rounded-xl bg-zinc-900 text-white font-bold text-sm hover:bg-zinc-800 transition-all flex items-center gap-1.5">
                <span class="material-symbols-outlined text-[18px]">print</span>
                In hóa đơn
            </button>
        </div>
    </div>

    <c:if test="${not empty splitHoaDonIds}">
        <div class="no-print max-w-[420px] mx-auto mb-4 p-3 rounded-xl border border-amber-200 bg-amber-50 text-amber-800 text-xs">
            Hóa đơn này còn có
            <c:forEach var="sid" items="${splitHoaDonIds}" varStatus="st">
                <a class="font-bold underline" target="_blank"
                   href="${pageContext.request.contextPath}/staff/hoa-don/in?id=${sid}">hóa đơn tách dịch vụ #${sid}</a><c:if test="${!st.last}">, </c:if>
            </c:forEach>
            — vui lòng in riêng nếu cần.
        </div>
    </c:if>

    <div class="receipt-shell max-w-[420px] mx-auto bg-white rounded-2xl shadow-lg border border-zinc-200 p-6">
        <div class="receipt">
            <!-- PHẦN ĐẦU -->
            <div class="center bold" style="font-size:15px;">V-SPORT</div>
            <div class="center bold">${coSo.tenCoSo}</div>
            <c:if test="${not empty coSo.diaChi}">
                <div class="center small">${coSo.diaChi}</div>
            </c:if>
            <c:if test="${not empty coSo.soDienThoai}">
                <div class="center small">ĐT: ${coSo.soDienThoai}</div>
            </c:if>
            <div class="center bold" style="margin-top:6px; font-size:13.5px;">
                <c:choose>
                    <c:when test="${isSplit}">HÓA ĐƠN DỊCH VỤ (TÁCH)</c:when>
                    <c:otherwise>HÓA ĐƠN THANH TOÁN</c:otherwise>
                </c:choose>
            </div>
            <hr/>

            <!-- THÔNG TIN HÓA ĐƠN -->
            <div class="receipt-row"><span>Mã hóa đơn:</span><span class="receipt-money bold">#${hoaDon.hoaDonId}</span></div>
            <c:if test="${isSplit && not empty hoaDon.parentHoaDonId}">
                <div class="receipt-row"><span>Tách từ HĐ:</span><span class="receipt-money">#${hoaDon.parentHoaDonId}</span></div>
            </c:if>
            <div class="receipt-row"><span>Ngày lập:</span><span class="receipt-money"><fmt:formatDate value="${hoaDon.ngayLap}" pattern="HH:mm dd/MM/yyyy"/></span></div>
            <div class="receipt-row"><span>Thu ngân:</span><span class="receipt-money">${not empty nhanVien.fullName ? nhanVien.fullName : '-'}</span></div>
            <div class="receipt-row"><span>PT thanh toán:</span><span class="receipt-money">${not empty hoaDon.phuongThucThanhToan ? hoaDon.phuongThucThanhToan : '-'}</span></div>
            <div class="receipt-row">
                <span>Trạng thái:</span>
                <span class="receipt-money bold">${hoaDon.trangThaiThanhToan}</span>
            </div>
            <hr/>

            <!-- THÔNG TIN CA CHƠI -->
            <div class="receipt-row"><span>Sân:</span><span class="receipt-money">${san.tenSan}</span></div>
            <div class="receipt-row"><span>Loại sân:</span><span class="receipt-money">${not empty loaiSan.tenLoai ? loaiSan.tenLoai : '-'}</span></div>
            <div class="receipt-row">
                <span>Khách:</span>
                <span class="receipt-money">${not empty khachHang.fullName ? khachHang.fullName : 'Khách vãng lai'}</span>
            </div>
            <div class="receipt-row">
                <span>Bắt đầu:</span>
                <span class="receipt-money">${gioBatDauStr} - ${ngayBatDauStr}</span>
            </div>
            <div class="receipt-row">
                <span>Kết thúc:</span>
                <span class="receipt-money">${gioKetThucStr} - ${ngayKetThucStr}<c:if test="${quaNgay}"> (hôm sau)</c:if></span>
            </div>
            <div class="receipt-row"><span>Tổng thời gian:</span><span class="receipt-money">${tongThoiGianChoi}</span></div>

            <c:if test="${!isSplit}">
                <div class="receipt-row"><span>Đơn giá sân:</span><span class="receipt-money">${donGiaSanStr}</span></div>
                <div class="receipt-row"><span>Thành tiền sân:</span><span class="receipt-money bold"><fmt:formatNumber value="${hoaDon.tongTienSan}" type="number" maxFractionDigits="0"/> đ</span></div>
            </c:if>
            <hr/>

            <!-- DỊCH VỤ -->
            <c:if test="${not empty dichVuRows}">
                <div class="bold small" style="margin-bottom:2px;">DỊCH VỤ ĐI KÈM</div>
                <table class="dv-table">
                    <thead>
                        <tr>
                            <th>Tên dịch vụ</th>
                            <th class="qty">SL</th>
                            <th class="money">Đơn giá</th>
                            <th class="money">T.Tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="dv" items="${dichVuRows}">
                            <tr>
                                <td>${dv.ten}</td>
                                <td class="qty">${dv.soLuong}</td>
                                <td class="money"><fmt:formatNumber value="${dv.donGia}" type="number" maxFractionDigits="0"/></td>
                                <td class="money"><fmt:formatNumber value="${dv.thanhTien}" type="number" maxFractionDigits="0"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <hr/>
            </c:if>

            <!-- TỔNG KẾT -->
            <c:if test="${!isSplit}">
                <div class="receipt-row"><span>Tiền sân:</span><span class="receipt-money"><fmt:formatNumber value="${hoaDon.tongTienSan}" type="number" maxFractionDigits="0"/> đ</span></div>
            </c:if>
            <div class="receipt-row"><span>Tiền dịch vụ:</span><span class="receipt-money"><fmt:formatNumber value="${hoaDon.tongTienDichVu}" type="number" maxFractionDigits="0"/> đ</span></div>
            <c:if test="${hoaDon.giamGia > 0}">
                <div class="receipt-row"><span>Giảm giá:</span><span class="receipt-money">-<fmt:formatNumber value="${hoaDon.giamGia}" type="number" maxFractionDigits="0"/> đ</span></div>
            </c:if>
            <c:if test="${hoaDon.phiGuiXe > 0}">
                <div class="receipt-row"><span>Phí gửi xe:</span><span class="receipt-money"><fmt:formatNumber value="${hoaDon.phiGuiXe}" type="number" maxFractionDigits="0"/> đ</span></div>
            </c:if>
            <hr/>
            <div class="receipt-row total-row"><span>TỔNG THANH TOÁN:</span><span class="receipt-money"><fmt:formatNumber value="${hoaDon.tongThanhToan}" type="number" maxFractionDigits="0"/> đ</span></div>

            <hr/>
            <!-- PHẦN CUỐI -->
            <div class="center small" style="margin-top:8px;">Cảm ơn quý khách đã sử dụng dịch vụ V-SPORT.</div>
        </div>
    </div>

</body>
</html>
