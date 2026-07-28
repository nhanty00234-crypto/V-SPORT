<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết yêu cầu hoàn tiền #${hoanTien.hoanTienId} | V-SPORT</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Poppins:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #059669;
            --primary-dark: #047857;
            --navy: #0f172a;
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
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #ffffff;
            padding: 40px 0 30px;
        }

        .refund-hero-breadcrumbs {
            font-size: 13px;
            color: #94a3b8;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .refund-hero-breadcrumbs a {
            color: #cbd5e1;
            text-decoration: none;
        }

        .refund-hero-title {
            font-family: 'Poppins', sans-serif;
            font-size: 26px;
            font-weight: 800;
            margin: 0 0 8px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .refund-container {
            max-width: 960px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .refund-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-top: -20px;
            margin-bottom: 40px;
        }

        @media (max-width: 768px) {
            .refund-grid {
                grid-template-columns: 1fr;
            }
        }

        .refund-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 20px -2px rgba(0,0,0,0.05);
            border: 1px solid var(--border);
            padding: 24px;
        }

        .card-header {
            font-size: 16px;
            font-weight: 800;
            color: var(--navy);
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px dashed #f1f5f9;
            font-size: 14px;
        }

        .info-label {
            color: var(--muted-text);
            font-weight: 500;
        }

        .info-value {
            font-weight: 700;
            color: var(--navy);
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
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 6px;
        }

        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 14px;
            outline: none;
            box-sizing: border-box;
            font-family: inherit;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.15);
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: var(--primary);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-weight: 800;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-submit:hover {
            background: var(--primary-dark);
        }

        .alert-urgent {
            background: #fffbeb;
            border: 1px solid #fde68a;
            color: #b45309;
            padding: 14px;
            border-radius: 12px;
            font-size: 13px;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<div class="refund-hero">
    <div class="refund-container">
        <div class="refund-hero-breadcrumbs">
            <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <a href="${pageContext.request.contextPath}/customer/hoan-tien">Hoàn tiền</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <span>Chi tiết #${hoanTien.hoanTienId}</span>
        </div>
        <h1 class="refund-hero-title">
            <i class="fas fa-file-invoice-dollar" style="color: #34d399;"></i>
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

    <div class="refund-grid">
        <!-- CỘT BÊN TRÁI: THÔNG TIN ĐƠN & SỐ TIỀN HOÀN -->
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

            <div class="info-row">
                <span class="info-label">Mã đặt sân</span>
                <span class="info-value">#${hoanTien.datSanId}</span>
            </div>

            <div class="info-row">
                <span class="info-label">Số tiền đã thực trả</span>
                <span class="info-value"><fmt:formatNumber value="${hoanTien.soTienDaThanhToan}" pattern="#,##0"/> đ</span>
            </div>

            <div class="info-row">
                <span class="info-label">Số tiền đề nghị hoàn</span>
                <span class="info-value" style="color: var(--primary); font-size: 16px;">
                    <fmt:formatNumber value="${hoanTien.soTienDeNghiHoan}" pattern="#,##0"/> đ
                </span>
            </div>

            <c:if test="${not empty hoanTien.soTienDuocDuyet}">
                <div class="info-row" style="background: #f0fdf4; padding: 10px; border-radius: 8px;">
                    <span class="info-label" style="color: #166534; font-weight: 700;">Số tiền thực tế được duyệt</span>
                    <span class="info-value" style="color: #15803d; font-size: 18px;">
                        <fmt:formatNumber value="${hoanTien.soTienDuocDuyet}" pattern="#,##0"/> đ
                    </span>
                </div>
            </c:if>

            <div class="info-row">
                <span class="info-label">Thời gian gửi yêu cầu</span>
                <span class="info-value" style="font-weight: 500; font-size: 13px;">
                    <fmt:formatDate value="${hoanTien.thoiGianYeuCau}" pattern="HH:mm dd/MM/yyyy"/>
                </span>
            </div>

            <c:if test="${not empty hoanTien.lyDo}">
                <div style="margin-top: 14px; padding-top: 10px; border-top: 1px dashed var(--border);">
                    <span class="info-label" style="display: block; margin-bottom: 4px;">Lý do hủy sân:</span>
                    <div style="font-size: 13px; color: #475569; font-style: italic; background: #f8fafc; padding: 10px; border-radius: 8px;">
                        "${fn:escapeXml(hoanTien.lyDo)}"
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty hoanTien.lyDoTuChoi}">
                <div style="margin-top: 14px; background: #fef2f2; border: 1px solid #fecaca; padding: 12px; border-radius: 10px; color: #991b1b;">
                    <strong style="display: block; font-size: 13px; margin-bottom: 4px;"><i class="fas fa-exclamation-triangle"></i> Lý do quản lý từ chối:</strong>
                    <div style="font-size: 13px;">${fn:escapeXml(hoanTien.lyDoTuChoi)}</div>
                </div>
            </c:if>

            <c:if test="${not empty hoanTien.maGiaoDichHoan}">
                <div style="margin-top: 14px; background: #eff6ff; border: 1px solid #bfdbfe; padding: 12px; border-radius: 10px; color: #1e40af;">
                    <strong style="display: block; font-size: 13px; margin-bottom: 4px;"><i class="fas fa-receipt"></i> Mã giao dịch ngân hàng:</strong>
                    <div style="font-size: 14px; font-weight: 700; font-family: monospace;">${fn:escapeXml(hoanTien.maGiaoDichHoan)}</div>
                </div>
            </c:if>
        </div>

        <!-- CỘT BÊN PHẢI: BỔ SUNG / CẬP NHẬT THÔNG TIN NGÂN HÀNG -->
        <div class="refund-card">
            <div class="card-header">
                <span><i class="fas fa-university" style="color: var(--primary);"></i> Thông tin ngân hàng nhận tiền</span>
            </div>

            <c:set var="isEditable" value="${hoanTien.trangThai == 'CHO_BO_SUNG_THONG_TIN' || hoanTien.trangThai == 'CHO_XU_LY'}" />

            <c:if test="${hoanTien.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">
                <div class="alert-urgent">
                    <i class="fas fa-exclamation-triangle" style="font-size: 18px; margin-top: 2px;"></i>
                    <div>
                        <strong>Yêu cầu cần bổ sung thông tin ngân hàng!</strong><br>
                        Vui lòng nhập chính xác Tên ngân hàng, Số tài khoản và Chủ tài khoản bên dưới để quản lý kiểm tra và hoàn tiền cho bạn.
                    </div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/customer/hoan-tien" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="update-bank">
                <input type="hidden" name="hoanTienId" value="${hoanTien.hoanTienId}">

                <div class="form-group">
                    <label for="nganHang">Tên ngân hàng <span style="color: #dc2626;">*</span></label>
                    <select name="nganHang" id="nganHang" class="form-control" <c:if test="${!isEditable}">disabled</c:if> required>
                        <option value="">-- Chọn ngân hàng --</option>
                        <option value="Vietcombank" ${hoanTien.nganHangNhan == 'Vietcombank' ? 'selected' : ''}>MB - MBBank / Quân Đội</option>
                        <option value="MBBank" ${hoanTien.nganHangNhan == 'MBBank' ? 'selected' : ''}>Vietcombank / VCB</option>
                        <option value="Techcombank" ${hoanTien.nganHangNhan == 'Techcombank' ? 'selected' : ''}>Techcombank / TCB</option>
                        <option value="VPBank" ${hoanTien.nganHangNhan == 'VPBank' ? 'selected' : ''}>VPBank</option>
                        <option value="ACB" ${hoanTien.nganHangNhan == 'ACB' ? 'selected' : ''}>ACB / Á Châu</option>
                        <option value="BIDV" ${hoanTien.nganHangNhan == 'BIDV' ? 'selected' : ''}>BIDV</option>
                        <option value="VietinBank" ${hoanTien.nganHangNhan == 'VietinBank' ? 'selected' : ''}>VietinBank</option>
                        <option value="TPBank" ${hoanTien.nganHangNhan == 'TPBank' ? 'selected' : ''}>TPBank</option>
                        <option value="Sacombank" ${hoanTien.nganHangNhan == 'Sacombank' ? 'selected' : ''}>Sacombank</option>
                        <option value="Agribank" ${hoanTien.nganHangNhan == 'Agribank' ? 'selected' : ''}>Agribank</option>
                        <option value="MoMo" ${hoanTien.nganHangNhan == 'MoMo' ? 'selected' : ''}>Ví MoMo</option>
                        <option value="Khac" ${not empty hoanTien.nganHangNhan && hoanTien.nganHangNhan != 'Vietcombank' && hoanTien.nganHangNhan != 'MBBank' && hoanTien.nganHangNhan != 'Techcombank' ? 'selected' : ''}>Ngân hàng khác</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="soTaiKhoan">Số tài khoản / Số ví <span style="color: #dc2626;">*</span></label>
                    <input type="text" name="soTaiKhoan" id="soTaiKhoan" class="form-control" value="${fn:escapeXml(hoanTien.soTaiKhoanNhan)}" placeholder="Ví dụ: 0987654321" <c:if test="${!isEditable}">readonly</c:if> required>
                </div>

                <div class="form-group">
                    <label for="chuTaiKhoan">Tên chủ tài khoản (Viết hoa không dấu) <span style="color: #dc2626;">*</span></label>
                    <input type="text" name="chuTaiKhoan" id="chuTaiKhoan" class="form-control" value="${fn:escapeXml(hoanTien.chuTaiKhoanNhan)}" placeholder="NGUYEN VAN A" style="text-transform: uppercase;" <c:if test="${!isEditable}">readonly</c:if> required>
                </div>

                <div class="form-group">
                    <label for="qrImage">Ảnh mã QR nhận tiền (Không bắt buộc)</label>
                    <c:if test="${not empty hoanTien.qrNhanTienPath}">
                        <div style="margin-bottom: 10px;">
                            <img src="${pageContext.request.contextPath}${hoanTien.qrNhanTienPath}" alt="QR Nhan Tien" style="max-width: 140px; border-radius: 10px; border: 1px solid var(--border);">
                        </div>
                    </c:if>
                    <c:if test="${isEditable}">
                        <input type="file" name="qrImage" id="qrImage" accept="image/jpeg,image/png,image/webp" class="form-control">
                        <small style="color: var(--muted-text); font-size: 11px;">Tối đa 5MB. Định dạng JPG, PNG, WEBP.</small>
                    </c:if>
                </div>

                <c:if test="${isEditable}">
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Lưu & Gửi thông tin ngân hàng
                    </button>
                </c:if>
            </form>
        </div>
    </div>
</div>

</body>
</html>
