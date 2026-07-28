<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu hoàn tiền | V-SPORT</title>
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
            position: relative;
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
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .refund-card {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 20px -2px rgba(0,0,0,0.05);
            border: 1px solid var(--border);
            margin-top: -20px;
            margin-bottom: 40px;
            padding: 24px;
            position: relative;
            z-index: 10;
        }

        .alert-box {
            padding: 14px 18px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .alert-error { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        .refund-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            margin-top: 10px;
        }

        .refund-table th {
            background: #f8fafc;
            padding: 14px 16px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--muted-text);
            border-bottom: 1px solid var(--border);
            text-align: left;
        }

        .refund-table td {
            padding: 16px;
            font-size: 14px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }

        .refund-table tbody tr:hover {
            background-color: #f8fafc;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 50px;
            font-size: 12px;
            font-weight: 700;
        }
        .status-CHO_BO_SUNG_THONG_TIN { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .status-CHO_XU_LY { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .status-DA_DUYET { background: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; }
        .status-DANG_HOAN_TIEN { background: #e0e7ff; color: #3730a3; border: 1px solid #c7d2fe; }
        .status-DA_HOAN_TIEN { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-TU_CHOI { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }
        .status-DA_HUY { background: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }

        .btn-detail {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #f1f5f9;
            color: var(--navy);
            padding: 8px 16px;
            border-radius: 8px;
            font-weight: 700;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-detail:hover {
            background: var(--navy);
            color: #ffffff;
        }
        .btn-detail-urgent {
            background: #fef3c7;
            color: #b45309;
            border: 1px solid #fde68a;
        }
        .btn-detail-urgent:hover {
            background: #d97706;
            color: #ffffff;
        }

        .empty-state {
            text-align: center;
            padding: 50px 20px;
        }
        .empty-state i {
            font-size: 48px;
            color: #cbd5e1;
            margin-bottom: 16px;
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
            <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san">Lịch sử đặt sân</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <span>Theo dõi hoàn tiền</span>
        </div>
        <h1 class="refund-hero-title">
            <i class="fas fa-hand-holding-usd" style="color: #34d399;"></i>
            Yêu cầu hoàn tiền của tôi
        </h1>
    </div>
</div>

<div class="refund-container">
    <div class="refund-card">
        <c:if test="${param.success == '1'}">
            <div class="alert-box alert-success">
                <i class="fas fa-check-circle"></i> Cập nhật thông tin thành công! Yêu cầu của bạn đang được ban quản lý xử lý.
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert-box alert-error">
                <i class="fas fa-exclamation-circle"></i> ${fn:escapeXml(param.error)}
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty danhSachHoanTien}">
                <div class="empty-state">
                    <i class="fas fa-receipt"></i>
                    <h3 style="margin: 0 0 8px 0; font-size: 18px; color: var(--navy);">Chưa có yêu cầu hoàn tiền nào</h3>
                    <p style="color: var(--muted-text); font-size: 14px; margin: 0 0 20px 0;">Khi bạn hủy các đơn đặt sân đã thanh toán, các yêu cầu hoàn tiền sẽ xuất hiện tại đây.</p>
                    <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="btn-detail" style="background: var(--primary); color: #fff;">
                        <i class="fas fa-history"></i> Xem lịch sử đặt sân
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x: auto;">
                    <table class="refund-table">
                        <thead>
                            <tr>
                                <th>Mã yêu cầu</th>
                                <th>Mã booking</th>
                                <th>Số tiền đã trả</th>
                                <th>Đề nghị hoàn</th>
                                <th>Ngân hàng nhận</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="ht" items="${danhSachHoanTien}">
                                <tr>
                                    <td><strong>#${ht.hoanTienId}</strong></td>
                                    <td>#${ht.datSanId}</td>
                                    <td><fmt:formatNumber value="${ht.soTienDaThanhToan}" pattern="#,##0"/> đ</td>
                                    <td style="font-weight: 700; color: var(--primary);"><fmt:formatNumber value="${ht.soTienDeNghiHoan}" pattern="#,##0"/> đ</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty ht.nganHangNhan}">
                                                <div style="font-weight: 600; font-size: 13px;">${fn:escapeXml(ht.nganHangNhan)}</div>
                                                <div style="font-size: 12px; color: var(--muted-text);">${fn:escapeXml(ht.soTaiKhoanNhan)}</div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #d97706; font-size: 12px; font-weight: 600;"><i class="fas fa-exclamation-triangle"></i> Chưa nhập TK</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:set var="stClass" value="status-${ht.trangThai}" />
                                        <span class="status-badge ${stClass}">
                                            <c:choose>
                                                <c:when test="${ht.trangThai == 'CHO_BO_SUNG_THONG_TIN'}"><i class="fas fa-edit"></i> Bổ sung thông tin</c:when>
                                                <c:when test="${ht.trangThai == 'CHO_XU_LY'}"><i class="fas fa-clock"></i> Chờ xử lý</c:when>
                                                <c:when test="${ht.trangThai == 'DA_DUYET'}"><i class="fas fa-check"></i> Đã duyệt</c:when>
                                                <c:when test="${ht.trangThai == 'DANG_HOAN_TIEN'}"><i class="fas fa-spinner fa-spin"></i> Đang chuyển khoản</c:when>
                                                <c:when test="${ht.trangThai == 'DA_HOAN_TIEN'}"><i class="fas fa-check-circle"></i> Đã hoàn tiền</c:when>
                                                <c:when test="${ht.trangThai == 'TU_CHOI'}"><i class="fas fa-times-circle"></i> Từ chối</c:when>
                                                <c:otherwise>${ht.trangThai}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${ht.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">
                                                <a href="${pageContext.request.contextPath}/customer/hoan-tien?id=${ht.hoanTienId}" class="btn-detail btn-detail-urgent">
                                                    <i class="fas fa-edit"></i> Bổ sung ngay
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/customer/hoan-tien?id=${ht.hoanTienId}" class="btn-detail">
                                                    <i class="fas fa-eye"></i> Chi tiết
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>
