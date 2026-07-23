<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quét mã sân - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:16px; }
        .card { background:#fff; border-radius:16px; padding:20px; box-shadow:0 1px 3px rgba(0,0,0,.08); margin-bottom:12px; }
        h1 { font-size:18px; margin:0 0 4px; }
        .sub { color:#71717a; font-size:13px; margin:0 0 16px; }
        .action-btn { display:flex; align-items:center; gap:12px; width:100%; padding:16px; border:none; border-radius:14px;
                      background:#7C3AED; color:#fff; font-weight:700; font-size:15px; margin-bottom:12px; cursor:pointer; }
        .action-btn:active { transform: scale(.98); }
        .error-box { color:#b91c1c; background:#fef2f2; border-radius:12px; padding:16px; }
    </style>
</head>
<body>
<c:choose>
    <c:when test="${resolveDto.resultCode == 'OK'}">
        <div class="card">
            <h1>${resolveDto.tenSan}</h1>
            <p class="sub">${resolveDto.tenCoSo}</p>
        </div>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=call'">📢 Gọi nhân viên</button>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=order'">🍔 Gọi món</button>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=service'">🛠️ Yêu cầu dịch vụ</button>
    </c:when>
    <c:otherwise>
        <div class="error-box">${resolveDto.message}</div>
    </c:otherwise>
</c:choose>
</body>
</html>
