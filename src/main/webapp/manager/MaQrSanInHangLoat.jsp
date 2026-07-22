<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>In hàng loạt mã QR | V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  body { background:#f8f9ff; }
  .qr-grid { display:grid; gap: 10mm; }
  .qr-grid.layout-1 { grid-template-columns: 1fr; }
  .qr-grid.layout-2 { grid-template-columns: 1fr 1fr; }
  .qr-grid.layout-4 { grid-template-columns: 1fr 1fr; }

  .print-card {
    background:#fff; border:1px solid #e5e7eb; border-radius:12px; padding: 16px; text-align:center;
    page-break-inside: avoid;
  }
  .print-card img { width:160px; height:160px; object-fit:contain; margin: 8px auto; }
  .print-card .short-code { font-family: monospace; font-size: 15px; font-weight:700; }
  .print-card .facility { font-weight:800; font-size:13px; }
  .print-card .court { font-size: 12px; color:#52525b; }
  .print-card .instruction { font-size: 10px; color:#71717a; margin-top:6px; }

  .layout-4 .print-card { page-break-after: auto; }
  .layout-4 .qr-grid > *:nth-child(4n) { page-break-after: always; }
  .layout-2 .qr-grid > *:nth-child(2n) { page-break-after: always; }
  .layout-1 .qr-grid > * { page-break-after: always; }

  @media print {
    .no-print { display:none !important; }
    body { margin:0; background:#fff; }
  }
</style>
</head>
<body class="min-h-screen py-8 px-4">

  <div class="no-print max-w-3xl mx-auto mb-5 flex items-center justify-between gap-2">
    <button type="button" onclick="window.close()" class="h-10 px-4 rounded-lg border border-zinc-200 bg-white text-zinc-600 font-semibold text-sm hover:bg-zinc-50">&larr; Quay lại</button>
    <div class="flex items-center gap-2">
      <span class="text-sm text-zinc-500">${items.size()} mã QR</span>
      <button type="button" onclick="window.print()" class="h-10 px-5 rounded-lg bg-purple-600 text-white font-semibold text-sm hover:bg-purple-700">In tất cả</button>
    </div>
  </div>

  <c:if test="${empty items}">
    <div class="no-print max-w-md mx-auto p-4 rounded-xl border border-amber-200 bg-amber-50 text-amber-800 text-sm text-center">
      Không có sân hợp lệ nào để in (sân không thuộc cơ sở của bạn hoặc chưa có mã QR).
    </div>
  </c:if>

  <div class="qr-grid layout-${layout} max-w-3xl mx-auto">
    <c:forEach var="item" items="${items}">
      <div class="print-card">
        <div class="facility">${coSo.tenCoSo}</div>
        <div class="court">${item[0].tenSan}<c:if test="${not empty item[2]}"> · ${item[2]}</c:if></div>
        <img src="${pageContext.request.contextPath}/manager/ma-qr-san-anh?sanId=${item[0].sanID}&mode=download" alt="Mã QR sân">
        <div class="short-code">${item[1].shortCode}</div>
        <div class="instruction">Quét mã để gọi nhân viên, yêu cầu dịch vụ hoặc thanh toán tại sân.</div>
      </div>
    </c:forEach>
  </div>

</body>
</html>
