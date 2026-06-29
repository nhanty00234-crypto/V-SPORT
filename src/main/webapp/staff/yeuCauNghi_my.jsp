<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng ký nghỉ phép — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff; border:1px solid #ffedd5; border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:8px; font-size:11px; font-weight:600; }
  .badge-yellow { background:#fef3c7; color:#b45309; }
  .badge-green { background:#dcfce7; color:#15803d; }
  .badge-red { background:#fee2e2; color:#b91c1c; }
  .badge-zinc { background:#f4f4f5; color:#71717a; }
  
  @keyframes contentZoomIn {
    from { opacity: 0; transform: scale(0.97); }
    to { opacity: 1; transform: scale(1); }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
</style>
</head>
<body class="bg-orange-50/20 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/staff/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-orange-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-orange-50 text-orange-700">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-orange-900 tracking-tight">Đăng ký nghỉ phép</h1>
      <p class="text-xs text-orange-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">badge</span>Nhân viên · Cơ sở CS${sessionScope.user.coSoId}
      </p>
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <div class="flex items-center justify-between gap-4 mb-2">
    <div>
      <h2 class="text-lg font-bold text-orange-950 flex items-center gap-2">
        Yêu cầu nghỉ phép của tôi
        <span class="text-xs bg-orange-100 px-2 py-0.5 rounded-full font-semibold text-orange-750">${requests.size()} đơn</span>
      </h2>
      <p class="text-xs text-zinc-500">Gửi và theo dõi trạng thái các đơn xin nghỉ phép/nghỉ ốm</p>
    </div>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi?action=new" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-orange-600 text-white text-sm font-semibold hover:bg-orange-700 transition-all shadow-md shadow-orange-100">
      <span class="material-symbols-outlined text-[18px]">add</span>Tạo yêu cầu mới
    </a>
  </div>

  <!-- Alert Messages -->
  <c:if test="${not empty sessionScope.error}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
      <div class="flex-1">
        <span class="font-bold block text-red-750">Lỗi thực hiện</span>
        <span class="text-red-600/90 leading-normal block mt-0.5">${sessionScope.error}</span>
      </div>
      <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
      <% session.removeAttribute("error"); %>
    </div>
  </c:if>
  <c:if test="${not empty sessionScope.success}">
    <div class="p-4 bg-orange-50 border border-orange-100 rounded-xl text-orange-600 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
      <div class="flex-1">
        <span class="font-bold block text-orange-750">Thành công</span>
        <span class="text-orange-600/90 leading-normal block mt-0.5">${sessionScope.success}</span>
      </div>
      <button onclick="this.parentElement.remove()" class="text-orange-400 hover:text-orange-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
      <% session.removeAttribute("success"); %>
    </div>
  </c:if>

  <!-- Filter Status -->
  <div class="card p-4 bg-white flex flex-wrap items-center gap-3">
    <span class="text-xs font-semibold text-zinc-500 uppercase tracking-wider">Trạng thái:</span>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-orange-100 text-orange-700 hover:bg-orange-200 transition-colors">Tất cả</a>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi?status=ChoDuyet" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-yellow-50 text-yellow-750 hover:bg-yellow-100 transition-colors">Chờ duyệt</a>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi?status=DaDuyet" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-green-50 text-green-750 hover:bg-green-100 transition-colors">Đã duyệt</a>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi?status=TuChoi" class="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-red-50 text-red-750 hover:bg-red-100 transition-colors">Từ từ chối</a>
  </div>

  <!-- Table View -->
  <div class="card overflow-hidden bg-white">
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-orange-50/50 border-b border-orange-100">
          <tr>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">#</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Ngày nghỉ phép</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Loại nghỉ</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Lý do nghỉ</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Độ khẩn cấp</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Trạng thái</th>
            <th class="px-5 py-3.5 text-left font-semibold text-orange-900 text-xs">Ngày gửi đơn</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-orange-50/70">
          <c:forEach var="req" items="${requests}" varStatus="st">
            <tr class="hover:bg-orange-50/35 transition-colors">
              <td class="px-5 py-4 text-xs text-zinc-500">${st.index + 1}</td>
              <td class="px-5 py-4 text-xs font-bold text-orange-900">
                <fmt:formatDate value="${req.ngayNghi}" pattern="dd/MM/yyyy"/>
              </td>
              <td class="px-5 py-4 text-xs font-medium text-zinc-700">
                <c:choose>
                  <c:when test="${req.loaiNghi == 'FullDay'}">Cả ngày</c:when>
                  <c:when test="${req.loaiNghi == 'HalfDay_Morning'}">Buổi sáng</c:when>
                  <c:when test="${req.loaiNghi == 'HalfDay_Afternoon'}">Buổi chiều</c:when>
                  <c:otherwise>${req.loaiNghi}</c:otherwise>
                </c:choose>
              </td>
              <td class="px-5 py-4 text-xs text-zinc-600 max-w-[250px] truncate" title="${req.lyDo}">${req.lyDo}</td>
              <td class="px-5 py-4">
                <c:choose>
                  <c:when test="${req.mucDoKhanCap}">
                    <span class="inline-flex items-center gap-1 text-[10px] font-bold text-red-650 bg-red-50 px-2 py-0.5 rounded">
                      <span class="w-1.5 h-1.5 rounded-full bg-red-600 animate-pulse"></span>Khẩn cấp
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="text-[10px] text-zinc-400 font-medium">Bình thường</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="px-5 py-4">
                <span class="badge ${req.trangThai == 'ChoDuyet' ? 'badge-yellow' : (req.trangThai == 'DaDuyet' ? 'badge-green' : (req.trangThai == 'TuChoi' ? 'badge-red' : 'badge-zinc'))}">
                  <c:choose>
                    <c:when test="${req.trangThai == 'ChoDuyet'}">Chờ duyệt</c:when>
                    <c:when test="${req.trangThai == 'DaDuyet'}">Đã duyệt</c:when>
                    <c:when test="${req.trangThai == 'TuChoi'}">Từ chối</c:when>
                    <c:when test="${req.trangThai == 'DaHuy'}">Đã hủy</c:when>
                    <c:otherwise>${req.trangThai}</c:otherwise>
                  </c:choose>
                </span>
              </td>
              <td class="px-5 py-4 text-xs text-zinc-400">
                <fmt:formatDate value="${req.ngayGui}" pattern="dd/MM/yyyy HH:mm"/>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty requests}">
            <tr>
              <td colspan="7" class="px-5 py-12 text-center text-zinc-400 italic">
                Bạn chưa gửi yêu cầu nghỉ phép nào.
              </td>
            </tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', () => {
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
      document.getElementById('sidebar').classList.toggle('-translate-x-full');
    });
  }
});
</script>
</body>
</html>
