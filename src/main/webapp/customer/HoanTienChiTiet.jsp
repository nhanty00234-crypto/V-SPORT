<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/xtra-head.jsp" />
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết yêu cầu hoàn tiền #${hoanTien.hoanTienId} | V-SPORT</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Poppins:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        /* Dùng chung token thương hiệu từ xtra-head.jsp (--primary, --navy, ...) — không định nghĩa lại để tránh lệch màu với Giỏ hàng/Lịch sử đặt sân. */
        :root {
            --bg-light: #f8fafc;
            --card-bg: #ffffff;
            --border: #e2e8f0;
            --muted-text: #64748b;
        }

        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--bg-light);
            color: #334155;
            margin: 0;
            padding: 0;
        }

        .refund-hero {
            background: linear-gradient(135deg, #1b5e42 0%, #287A58 55%, #3aaa72 100%);
            color: #ffffff;
            padding: 20px 0 16px;
        }

        .refund-hero-title {
            font-family: 'Poppins', sans-serif;
            font-size: 26px;
            font-weight: 800;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ffffff;
        }

        .refund-back-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 8px;
            background: rgba(255,255,255,0.08);
            color: #ffffff;
            text-decoration: none;
            font-size: 14px;
            transition: background 0.2s;
        }

        .refund-back-btn:hover {
            background: rgba(255,255,255,0.16);
        }

        .refund-container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 0 24px;
        }

        .refund-card {
            background: #ffffff;
            border-radius: 14px;
            box-shadow: 0 4px 20px -2px rgba(0,0,0,0.05);
            border: 1px solid var(--border);
            padding: 20px 24px;
            margin-bottom: 20px;
        }

        .card-header {
            font-size: 14px;
            font-weight: 800;
            color: var(--navy);
            margin-bottom: 14px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Stat strip: financial info laid out horizontally, not stacked */
        .stat-strip {
            display: flex;
            flex-wrap: wrap;
            gap: 24px;
        }

        .stat-item {
            display: flex;
            flex-direction: column;
            gap: 3px;
            min-width: 110px;
        }

        .stat-item .info-label {
            font-size: 12px;
        }

        .stat-item .info-value {
            font-size: 15px;
        }

        .stat-item.stat-highlight .info-value {
            color: var(--primary);
            font-size: 18px;
        }

        .stat-item.stat-approved .info-value {
            color: #15803d;
        }

        .info-label {
            color: var(--muted-text);
            font-weight: 500;
        }

        .info-value {
            font-weight: 700;
            color: var(--navy);
        }

        /* Bank form: all fields laid out horizontally on one row */
        .bank-form-row {
            display: grid;
            grid-template-columns: 1.2fr 1fr 1.3fr auto;
            gap: 14px;
            align-items: end;
        }

        @media (max-width: 900px) {
            .bank-form-row {
                grid-template-columns: 1fr 1fr;
            }
        }
        @media (max-width: 560px) {
            .bank-form-row {
                grid-template-columns: 1fr;
            }
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 700;
        }
        .status-CHO_BO_SUNG_THONG_TIN { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .status-CHO_XU_LY { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .status-DA_DUYET { background: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; }
        .status-DANG_HOAN_TIEN { background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; }
        .status-DA_HOAN_TIEN { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-TU_CHOI { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        .form-group {
            margin-bottom: 10px;
        }

        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 4px;
        }

        .form-control {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 13px;
            outline: none;
            box-sizing: border-box;
            font-family: inherit;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.15);
        }

        .btn-submit {
            padding: 11px 20px;
            background: var(--primary);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-weight: 800;
            font-size: 13px;
            cursor: pointer;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            white-space: nowrap;
        }
        .btn-submit:hover {
            background: var(--primary-hover);
        }

        .js-hidden {
            display: none !important;
        }

        /* QR + hint shown compactly beside the bank fields, not stacked below */
        .vietqr-preview-row {
            display: flex;
            gap: 20px;
            align-items: center;
            grid-column: 1 / -1;
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 18px 20px;
        }

        .vietqr-preview-row .vietqr-thumb {
            flex: 0 0 auto;
        }

        .vietqr-preview-row .vietqr-copy {
            flex: 1 1 auto;
            font-size: 13px;
            line-height: 1.6;
            color: var(--muted-text);
        }

        .qr-upload-row {
            grid-column: 1 / -1;
            display: flex;
            align-items: center;
            gap: 14px;
            font-size: 12px;
            color: var(--muted-text);
        }

        .qr-upload-row .form-control {
            max-width: 260px;
        }

        .alert-urgent {
            background: #fffbeb;
            border: 1px solid #fde68a;
            color: #b45309;
            padding: 10px 14px;
            border-radius: 10px;
            font-size: 12px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>
</head>
<body>

<div class="refund-hero">
    <div class="refund-container">
        <h1 class="refund-hero-title">
            <a href="${pageContext.request.contextPath}/customer/gio-hang?tab=refund" class="refund-back-btn" aria-label="Quay lại danh sách hoàn tiền">
                <i class="fas fa-arrow-left"></i>
            </a>
            <i class="fas fa-file-invoice-dollar" style="color: var(--primary);"></i>
            Yêu cầu hoàn tiền #${hoanTien.hoanTienId}
        </h1>
    </div>
</div>

<div class="refund-container">
    <c:if test="${param.success == '1'}">
        <div style="background: #dcfce7; color: #15803d; padding: 14px 18px; border-radius: 12px; margin-top: -10px; margin-bottom: 20px; font-weight: 700; border: 1px solid #bbf7d0;">
            <i class="fas fa-check-circle"></i> Đã lưu thông tin tài khoản ngân hàng thành công! Đơn hàng của bạn đã sẵn sàng để ban quản lý xử lý.
        </div>
    </c:if>

    <c:set var="isEditable" value="${hoanTien.trangThai == 'CHO_BO_SUNG_THONG_TIN' || hoanTien.trangThai == 'CHO_XU_LY'}" />

    <!-- Thông tin hoàn tiền: dải số liệu ngang, một dòng -->
    <div class="refund-card">
        <div class="card-header">
            <span><i class="fas fa-info-circle" style="color: var(--primary);"></i> Thông tin hoàn tiền</span>
            <c:set var="stClass" value="status-${hoanTien.trangThai}" />
            <span class="status-badge ${stClass}">
                <c:choose>
                    <c:when test="${hoanTien.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">Chờ bổ sung thông tin</c:when>
                    <c:when test="${hoanTien.trangThai == 'CHO_XU_LY'}">Chờ xử lý</c:when>
                    <c:when test="${hoanTien.trangThai == 'DA_DUYET'}">Đã duyệt</c:when>
                    <c:when test="${hoanTien.trangThai == 'DANG_HOAN_TIEN'}">Đang chuyển khoản</c:when>
                    <c:when test="${hoanTien.trangThai == 'DA_HOAN_TIEN'}">Đã nhận tiền</c:when>
                    <c:when test="${hoanTien.trangThai == 'TU_CHOI'}">Từ chối</c:when>
                    <c:otherwise>${hoanTien.trangThai}</c:otherwise>
                </c:choose>
            </span>
        </div>

        <div class="stat-strip">
            <div class="stat-item">
                <span class="info-label">Mã đặt sân</span>
                <span class="info-value">#${hoanTien.datSanId}</span>
            </div>
            <div class="stat-item">
                <span class="info-label">Đã thực trả</span>
                <span class="info-value"><fmt:formatNumber value="${hoanTien.soTienDaThanhToan}" pattern="#,##0"/> đ</span>
            </div>
            <div class="stat-item stat-highlight">
                <span class="info-label">Đề nghị hoàn</span>
                <span class="info-value"><fmt:formatNumber value="${hoanTien.soTienDeNghiHoan}" pattern="#,##0"/> đ</span>
            </div>
            <c:if test="${not empty hoanTien.soTienDuocDuyet}">
                <div class="stat-item stat-approved">
                    <span class="info-label">Thực tế được duyệt</span>
                    <span class="info-value"><fmt:formatNumber value="${hoanTien.soTienDuocDuyet}" pattern="#,##0"/> đ</span>
                </div>
            </c:if>
            <div class="stat-item">
                <span class="info-label">Thời gian gửi</span>
                <span class="info-value" style="font-size:13px;"><fmt:formatDate value="${hoanTien.thoiGianYeuCau}" pattern="HH:mm dd/MM/yyyy"/></span>
            </div>
        </div>

        <c:if test="${not empty hoanTien.lyDo}">
            <div style="margin-top: 12px; padding-top: 10px; border-top: 1px dashed var(--border); font-size:13px; color:#475569;">
                <span class="info-label">Lý do hủy sân:</span> <em>"${fn:escapeXml(hoanTien.lyDo)}"</em>
            </div>
        </c:if>

        <c:if test="${not empty hoanTien.lyDoTuChoi}">
            <div style="margin-top: 10px; background: #fef2f2; border: 1px solid #fecaca; padding: 10px 14px; border-radius: 10px; color: #991b1b; font-size:13px;">
                <strong><i class="fas fa-exclamation-triangle"></i> Lý do quản lý từ chối:</strong> ${fn:escapeXml(hoanTien.lyDoTuChoi)}
            </div>
        </c:if>

        <c:if test="${not empty hoanTien.maGiaoDichHoan}">
            <div style="margin-top: 10px; background: #eff6ff; border: 1px solid #bfdbfe; padding: 10px 14px; border-radius: 10px; color: #1e40af; font-size:13px;">
                <strong><i class="fas fa-receipt"></i> Mã giao dịch ngân hàng:</strong>
                <span style="font-family: monospace; font-weight:700;">${fn:escapeXml(hoanTien.maGiaoDichHoan)}</span>
            </div>
        </c:if>
    </div>

    <!-- Thông tin ngân hàng nhận tiền: form một hàng ngang -->
    <div class="refund-card">
        <div class="card-header">
            <span><i class="fas fa-university" style="color: var(--primary);"></i> Thông tin ngân hàng nhận tiền</span>
        </div>

        <c:if test="${hoanTien.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">
            <div class="alert-urgent">
                <i class="fas fa-exclamation-triangle"></i>
                <span><strong>Cần bổ sung thông tin ngân hàng</strong> — nhập chính xác để quản lý kiểm tra và hoàn tiền cho bạn.</span>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/customer/hoan-tien" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="update-bank">
            <input type="hidden" name="hoanTienId" value="${hoanTien.hoanTienId}">

            <div class="bank-form-row">
                <div class="form-group">
                    <label for="nganHang">Tên ngân hàng <span style="color: #dc2626;">*</span></label>
                    <select name="nganHang" id="nganHang" class="form-control" data-bin="" <c:if test="${!isEditable}">disabled</c:if> required onchange="onBankFieldChange()">
                        <option value="">-- Chọn ngân hàng --</option>
                        <option value="Vietcombank" data-bin="970436" ${hoanTien.nganHangNhan == 'Vietcombank' ? 'selected' : ''}>Vietcombank / VCB</option>
                        <option value="MBBank" data-bin="970422" ${hoanTien.nganHangNhan == 'MBBank' ? 'selected' : ''}>MB - MBBank / Quân Đội</option>
                        <option value="Techcombank" data-bin="970407" ${hoanTien.nganHangNhan == 'Techcombank' ? 'selected' : ''}>Techcombank / TCB</option>
                        <option value="VPBank" data-bin="970432" ${hoanTien.nganHangNhan == 'VPBank' ? 'selected' : ''}>VPBank</option>
                        <option value="ACB" data-bin="970416" ${hoanTien.nganHangNhan == 'ACB' ? 'selected' : ''}>ACB / Á Châu</option>
                        <option value="BIDV" data-bin="970418" ${hoanTien.nganHangNhan == 'BIDV' ? 'selected' : ''}>BIDV</option>
                        <option value="VietinBank" data-bin="970415" ${hoanTien.nganHangNhan == 'VietinBank' ? 'selected' : ''}>VietinBank</option>
                        <option value="TPBank" data-bin="970423" ${hoanTien.nganHangNhan == 'TPBank' ? 'selected' : ''}>TPBank</option>
                        <option value="Sacombank" data-bin="970403" ${hoanTien.nganHangNhan == 'Sacombank' ? 'selected' : ''}>Sacombank</option>
                        <option value="Agribank" data-bin="970405" ${hoanTien.nganHangNhan == 'Agribank' ? 'selected' : ''}>Agribank</option>
                        <option value="Khac" ${not empty hoanTien.nganHangNhan && hoanTien.nganHangNhan != 'Vietcombank' && hoanTien.nganHangNhan != 'MBBank' && hoanTien.nganHangNhan != 'Techcombank' && hoanTien.nganHangNhan != 'VPBank' && hoanTien.nganHangNhan != 'ACB' && hoanTien.nganHangNhan != 'BIDV' && hoanTien.nganHangNhan != 'VietinBank' && hoanTien.nganHangNhan != 'TPBank' && hoanTien.nganHangNhan != 'Sacombank' && hoanTien.nganHangNhan != 'Agribank' ? 'selected' : ''}>Ngân hàng khác</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="soTaiKhoan">Số tài khoản <span style="color: #dc2626;">*</span></label>
                    <input type="text" name="soTaiKhoan" id="soTaiKhoan" class="form-control" value="${fn:escapeXml(hoanTien.soTaiKhoanNhan)}" placeholder="0987654321" <c:if test="${!isEditable}">readonly</c:if> required oninput="onBankFieldChange()">
                </div>

                <div class="form-group">
                    <label for="chuTaiKhoan">Chủ tài khoản <span style="color: #dc2626;">*</span></label>
                    <input type="text" name="chuTaiKhoan" id="chuTaiKhoan" class="form-control" value="${fn:escapeXml(hoanTien.chuTaiKhoanNhan)}" placeholder="NGUYEN VAN A" style="text-transform: uppercase;" <c:if test="${!isEditable}">readonly</c:if> required oninput="onBankFieldChange()">
                </div>

                <c:if test="${isEditable}">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Lưu &amp; gửi
                    </button>
                </c:if>

                <c:set var="hasBankInfoYet" value="${not empty hoanTien.nganHangNhan and not empty hoanTien.soTaiKhoanNhan}" />
                <div class="vietqr-preview-row ${hasBankInfoYet ? '' : 'js-hidden'}" id="vietQrPreviewGroup">
                    <div class="vietqr-thumb">
                        <img id="vietQrPreviewImg" src="" alt="VietQR" style="width:200px; height:200px; border-radius:10px; display:none;">
                        <div id="vietQrPreviewHint" style="font-size:12px; color:var(--muted-text); width:200px;">Chọn ngân hàng và số tài khoản để tạo QR.</div>
                    </div>
                    <span class="vietqr-copy">Mã QR VietQR tự tạo theo ngân hàng, số tài khoản và số tiền đề nghị hoàn — không cần tải ảnh lên. Hệ thống không xác minh tên chủ tài khoản, vui lòng nhập chính xác.</span>
                </div>

                <c:if test="${isEditable}">
                    <div class="qr-upload-row">
                        <label for="qrImage" style="margin:0; white-space:nowrap;">Hoặc tải QR khác lên:</label>
                        <input type="file" name="qrImage" id="qrImage" accept="image/jpeg,image/png,image/webp" class="form-control">
                        <span>Tối đa 5MB · JPG/PNG/WEBP</span>
                        <c:if test="${not empty hoanTien.qrNhanTienPath}">
                            <img src="${pageContext.request.contextPath}${hoanTien.qrNhanTienPath}" alt="QR đã tải" style="width:40px; height:40px; border-radius:6px; border:1px solid var(--border);">
                        </c:if>
                    </div>
                </c:if>
            </div>
        </form>
    </div>
</div>

<c:set var="refundAmountForQrEl" value="${empty hoanTien.soTienDeNghiHoan ? 0 : hoanTien.soTienDeNghiHoan}" />
<script>
    var refundAmountForQr = Number("${refundAmountForQrEl}");
    var refundIdForQr = Number("${hoanTien.hoanTienId}");

    function onBankFieldChange() {
        var bankSelect = document.getElementById('nganHang');
        var accountInput = document.getElementById('soTaiKhoan');
        var img = document.getElementById('vietQrPreviewImg');
        var hint = document.getElementById('vietQrPreviewHint');
        var group = document.getElementById('vietQrPreviewGroup');
        if (!bankSelect || !accountInput || !img || !hint || !group) return;

        var bin = bankSelect.options[bankSelect.selectedIndex] ? bankSelect.options[bankSelect.selectedIndex].getAttribute('data-bin') : '';
        var accountNo = accountInput.value.trim();

        group.classList.remove('js-hidden');

        if (!bin || !accountNo) {
            img.style.display = 'none';
            hint.style.display = 'block';
            hint.innerText = !bin && bankSelect.value
                ? 'Ngân hàng này chưa hỗ trợ tạo QR tự động — vui lòng tải ảnh QR thủ công bên dưới.'
                : 'Chọn ngân hàng và nhập số tài khoản để tạo mã QR.';
            return;
        }

        var addInfo = encodeURIComponent('Hoan tien don ' + refundIdForQr);
        var qrUrl = 'https://img.vietqr.io/image/' + bin + '-' + encodeURIComponent(accountNo) + '-compact2.png'
            + '?amount=' + Math.max(0, Math.round(refundAmountForQr))
            + '&addInfo=' + addInfo;

        img.src = qrUrl;
        img.style.display = 'inline-block';
        hint.style.display = 'none';
    }

    document.addEventListener('DOMContentLoaded', onBankFieldChange);
</script>

</body>
</html>
