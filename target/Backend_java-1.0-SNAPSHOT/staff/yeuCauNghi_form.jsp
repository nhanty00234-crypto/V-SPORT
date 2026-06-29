<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng ký nghỉ phép mới — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff; border:1px solid #ffedd5; border-radius:16px; transition:box-shadow .2s, transform .2s; }
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
      <h1 class="text-sm font-bold text-orange-900 tracking-tight">Đăng ký nghỉ phép mới</h1>
      <p class="text-xs text-orange-550 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">badge</span>Nhân viên · Cơ sở CS${sessionScope.user.coSoId}
      </p>
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col items-center justify-center min-h-[calc(100vh-64px)]">
  <div class="w-full max-w-[560px] flex flex-col gap-4">
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi" class="flex items-center gap-1 text-xs font-semibold text-orange-700 hover:text-orange-900 transition-colors self-start">
      <span class="material-symbols-outlined text-[16px]">arrow_back</span>Quay lại danh sách
    </a>
    
    <div class="card p-6 bg-white shadow-xl shadow-orange-100/50">
      <div class="flex items-center gap-3 mb-6 pb-4 border-b border-orange-50">
        <div class="w-10 h-10 rounded-xl bg-orange-100 text-orange-700 flex items-center justify-center shadow-sm">
          <span class="material-symbols-outlined text-[22px]">assignment</span>
        </div>
        <div>
          <h2 class="text-base font-bold text-orange-955">Gửi yêu cầu nghỉ phép</h2>
          <p class="text-xs text-zinc-450">Tạo đơn xin nghỉ phép gửi lên quản lý cơ sở xét duyệt</p>
        </div>
      </div>
      
      <!-- Alert Messages -->
      <c:if test="${not empty sessionScope.error}">
        <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 mb-4">
          <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
          <div class="flex-1">
            <span class="font-bold block text-red-750">Lỗi thực hiện</span>
            <span class="text-red-600/90 leading-normal block mt-0.5">${sessionScope.error}</span>
          </div>
          <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
          <% session.removeAttribute("error"); %>
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/staff/yeu-cau-nghi" method="POST" class="flex flex-col gap-4">
        <!-- Date of Leave -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Ngày xin nghỉ <span class="text-red-500">*</span></label>
          <input type="date" name="ngayNghi" required id="ngayNghi"
                 class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none">
        </div>
        
        <!-- Leave Type -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Loại nghỉ <span class="text-red-500">*</span></label>
          <select name="loaiNghi" required
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white">
            <option value="FullDay">Cả ngày</option>
            <option value="HalfDay_Morning">Nửa ngày (Buổi sáng)</option>
            <option value="HalfDay_Afternoon">Nửa ngày (Buổi chiều)</option>
          </select>
        </div>
        
        <!-- Urgent Level -->
        <div class="flex items-center gap-3 py-1">
          <label class="relative flex items-center cursor-pointer">
            <input type="checkbox" name="mucDoKhanCap" value="true" class="sr-only peer">
            <div class="w-9 h-5 bg-zinc-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-zinc-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-red-500"></div>
            <span class="ml-3 text-xs font-bold text-red-655 flex items-center gap-1.5 select-none">
              Yêu cầu khẩn cấp <span class="text-[10px] text-zinc-400 font-medium">(Nghỉ ốm đột xuất, tai nạn...)</span>
            </span>
          </label>
        </div>

        <!-- Reason -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Lý do nghỉ phép <span class="text-red-500">*</span></label>
          <textarea name="lyDo" rows="4" required placeholder="Nhập lý do chi tiết để quản lý xem xét phê duyệt..."
                    class="p-3 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none resize-none"></textarea>
        </div>
        
        <div class="flex justify-end gap-3 mt-4 pt-4 border-t border-orange-50">
          <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi" 
             class="h-10 px-5 rounded-xl border border-orange-100 text-sm font-semibold hover:bg-orange-50 text-zinc-650 flex items-center justify-center transition-colors">Hủy</a>
          <button type="submit" 
                  class="h-10 px-6 rounded-xl bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold shadow-md shadow-orange-100 transition-colors">
            Gửi yêu cầu
          </button>
        </div>
      </form>
    </div>
  </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', () => {
  // Set default min date as today for leave registration
  const today = new Date().toISOString().split('T')[0];
  const dateInput = document.getElementById('ngayNghi');
  if (dateInput) {
    dateInput.min = today;
    dateInput.value = today;
  }

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
