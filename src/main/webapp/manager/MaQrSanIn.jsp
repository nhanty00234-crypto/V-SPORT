<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>In mã QR — ${san.tenSan} | V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  body { background:#f8f9ff; }
  .print-card {
    width: 100mm; max-width: 100%; margin: 0 auto; background:#fff; border-radius:16px;
    padding: 24px; text-align:center; box-sizing:border-box;
  }
  .print-card img { width:220px; height:220px; object-fit:contain; margin: 12px auto; }
  .print-card .short-code { font-family: monospace; font-size: 18px; font-weight:700; letter-spacing: .05em; margin-top: 6px; }
  .print-card .facility { font-weight:800; font-size:16px; }
  .print-card .court { font-size: 14px; color:#52525b; }
  .print-card .instruction { font-size: 11.5px; color:#71717a; margin-top: 10px; }
  .print-card .warning { font-size: 10.5px; color:#b91c1c; margin-top: 10px; }

  @media print {
    .no-print { display:none !important; }
    body { margin:0; background:#fff; }
    .print-shell { box-shadow:none !important; border:none !important; padding:0 !important; }
  }
  @page { size: 100mm 150mm; margin: 4mm; }
</style>
</head>
<body class="min-h-screen py-8 px-4">

  <div class="no-print max-w-md mx-auto mb-5 flex items-center justify-between gap-2">
    <button type="button" onclick="window.close()" class="h-10 px-4 rounded-lg border border-zinc-200 bg-white text-zinc-600 font-semibold text-sm hover:bg-zinc-50">&larr; Quay lại</button>
    <button type="button" onclick="window.print()" class="h-10 px-5 rounded-lg bg-purple-600 text-white font-semibold text-sm hover:bg-purple-700">In mã QR</button>
  </div>

  <div class="print-shell max-w-md mx-auto bg-white rounded-2xl shadow-sm border border-purple-100 p-4">
    <div class="print-card">
      <div class="facility">${coSo.tenCoSo}</div>
      <div class="court">${san.tenSan}<c:if test="${not empty tenLoaiSan}"> · ${tenLoaiSan}</c:if></div>
      <img src="${pageContext.request.contextPath}/manager/ma-qr-san-anh?sanId=${san.sanID}&mode=download" alt="Mã QR sân">
      <div class="short-code">${sanQR.shortCode}</div>
      <div class="instruction">Quét mã để gọi nhân viên, yêu cầu dịch vụ hoặc thanh toán tại sân.<br>Không quét được? Nhập mã sân trong ứng dụng V-SPORT.</div>
      <div class="warning">Không chia sẻ ảnh mã QR bên ngoài khu vực sân.</div>
    </div>
  </div>

</body>
</html>
