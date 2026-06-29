<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý Cơ Sở — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow:0 8px 24px -8px rgba(0,0,0,.08); transform:translateY(-2px); }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-gray { background:#f4f4f5;color:#52525b; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  
  /* Larger Number Input Arrows */
  input[type="number"]::-webkit-inner-spin-button, 
  input[type="number"]::-webkit-outer-spin-button { 
    opacity: 1;
    height: 30px;
    width: 30px;
    cursor: pointer;
  }
  
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}
  
  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  main > section { animation: fadeUp .4s ease both; }
  
  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }

  @keyframes contentZoomIn {
    from {
      opacity: 0;
      transform: scale(0.97);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
</style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Cấu hình Cơ Sở</h1>
     
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  
  <section>
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
      <div class="flex items-center gap-4">
        <h2 class="text-lg font-bold text-zinc-900">Danh sách Cơ Sở <span class="text-xs bg-zinc-100 px-1.5 py-0.5 rounded font-medium text-zinc-600">${dsChiNhanh.size()}</span></h2>
      </div>
      <button onclick="document.getElementById('modalThem').classList.remove('hidden')" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-all shadow-md shadow-blue-200">
        <span class="material-symbols-outlined text-[18px]">add_location</span>Thêm Cơ Sở
      </button>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.error}">
      <div class="mb-4 p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3">
        <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
        <div>
          <span class="font-bold block text-red-700">Lỗi thao tác</span>
          <span class="text-red-600/95 leading-normal block mt-0.5">${sessionScope.error}</span>
        </div>
        <% session.removeAttribute("error"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.message}">
      <div class="mb-4 p-4 bg-green-50 border border-green-100 rounded-xl text-green-600 text-sm flex items-start gap-3">
        <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
        <div>
          <span class="font-bold block text-green-700">Thành công</span>
          <span class="text-green-600/95 leading-normal block mt-0.5">${sessionScope.message}</span>
        </div>
        <% session.removeAttribute("message"); %>
      </div>
    </c:if>

    <div class="card overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-zinc-50 border-b border-zinc-200">
          <tr>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Cơ Sở</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden md:table-cell">Địa chỉ</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden lg:table-cell">Liên hệ</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden lg:table-cell">Giờ hoạt động</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Trạng thái</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100">
          <c:forEach var="cn" items="${dsChiNhanh}">
            <tr class="hover:bg-zinc-50 transition-colors">
              <td class="px-4 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-xl bg-zinc-100 flex items-center justify-center shrink-0 border border-zinc-200 overflow-hidden">
                    <img src="${cn.hinhAnh != null ? cn.hinhAnh : 'https://placehold.co/100x100?text=V'}" class="w-full h-full object-cover">
                  </div>
                  <div>
                    <p class="font-bold text-zinc-900">${cn.tenCoSo}</p>
                    <p class="text-[11px] text-zinc-500">${cn.loaiHinhKinhDoanh}</p>
                  </div>
                </div>
              </td>
              <td class="px-4 py-4 text-zinc-600 text-xs hidden md:table-cell max-w-[200px] truncate">
                ${cn.diaChi}
              </td>
              <td class="px-4 py-4 text-zinc-600 text-xs hidden lg:table-cell">
                ${cn.soDienThoai}
              </td>
              <td class="px-4 py-4 text-zinc-500 text-[11px] hidden lg:table-cell">
                <div class="flex items-center gap-1.5">
                    <span class="material-symbols-outlined text-[14px]">schedule</span>
                    ${cn.gioMoCua} - ${cn.gioDongCua}
                </div>
              </td>
              <td class="px-4 py-4">
                <span class="badge ${cn.trangThai == 'Đang hoạt động' ? 'badge-green' : 'badge-red'}">${cn.trangThai}</span>
              </td>
              <td class="px-4 py-4 text-right">
                <div class="flex items-center justify-end gap-1.5">
                  <a href="${pageContext.request.contextPath}/admin/chi-nhanh/sua?id=${cn.coSoID}" class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-500 transition-colors">
                    <span class="material-symbols-outlined text-[18px]">edit</span>
                  </a>
                  <button onclick="if(confirm('Xóa Cơ Sở này?')) location.href='${pageContext.request.contextPath}/admin/chi-nhanh/xoa?id=${cn.coSoID}'" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors">
                    <span class="material-symbols-outlined text-[18px]">delete</span>
                  </button>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
      <div class="px-4 py-3 border-t border-zinc-100 flex items-center justify-between text-[11px] text-zinc-500 font-medium">
        <span>Hiển thị ${dsChiNhanh.size()} Cơ Sở</span>
        <div class="flex items-center gap-1">
          <button class="px-2 py-1 rounded hover:bg-zinc-100 disabled:opacity-40" disabled><span class="material-symbols-outlined text-[14px]">chevron_left</span></button>
          <button class="px-2.5 py-1 rounded bg-zinc-900 text-white font-bold">1</button>
          <button class="px-2 py-1 rounded hover:bg-zinc-100"><span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
        </div>
      </div>
    </div>
  </section>

</main>

<!-- Modal Thêm -->
<div id="modalThem" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="this.parentElement.classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[550px] animate__animated animate__zoomIn animate__faster">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <h3 class="text-base font-bold text-zinc-900">Thêm Cơ Sở mới</h3>
      <button onclick="document.getElementById('modalThem').classList.add('hidden')" class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-400"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>
    
    <form action="${pageContext.request.contextPath}/admin/chi-nhanh/them" method="post" class="p-6 flex flex-col gap-5" onsubmit="return validateForm()">
        <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Tên Cơ Sở</label>
            <input type="text" name="tenCoSo" required placeholder="Ví dụ: V-Sport Vũng Tàu" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
        </div>
        
        <div class="grid grid-cols-2 gap-4">
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-semibold text-zinc-700">Số điện thoại</label>
                <input type="text" name="soDienThoai" required class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
            </div>
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-semibold text-zinc-700">Trạng thái</label>
                <select name="trangThai" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
                    <option value="Đang hoạt động">Đang hoạt động</option>
                    <option value="Tạm nghỉ">Tạm nghỉ</option>
                </select>
            </div>
        </div>

        <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Môn thể thao (Cung cấp tại Cơ Sở)</label>
            <div class="flex flex-col gap-3 p-4 bg-zinc-50 rounded-xl border border-zinc-100">
                <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                    <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 transition-colors select-none">
                        <input type="checkbox" name="loaiHinhKinhDoanh" value="Bóng đá" onchange="toggleSportCount(this, 'soLuongSan_BongDa')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 transition-all"> 
                        <span class="font-medium">Bóng đá</span>
                    </label>
                    <div class="flex items-center gap-2">
                        <span class="text-xs text-zinc-500">Số sân:</span>
                        <input type="number" id="soLuongSan_BongDa" name="soLuongSan_BongDa" value="1" min="1" disabled oninput="updateTotalCourts()" class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                    </div>
                </div>
                <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                    <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 transition-colors select-none">
                        <input type="checkbox" name="loaiHinhKinhDoanh" value="Cầu lông" onchange="toggleSportCount(this, 'soLuongSan_CauLong')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 transition-all"> 
                        <span class="font-medium">Cầu lông</span>
                    </label>
                    <div class="flex items-center gap-2">
                        <span class="text-xs text-zinc-500">Số sân:</span>
                        <input type="number" id="soLuongSan_CauLong" name="soLuongSan_CauLong" value="1" min="1" disabled oninput="updateTotalCourts()" class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                    </div>
                </div>
                <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                    <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 transition-colors select-none">
                        <input type="checkbox" name="loaiHinhKinhDoanh" value="Tennis" onchange="toggleSportCount(this, 'soLuongSan_Tennis')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 transition-all"> 
                        <span class="font-medium">Tennis</span>
                    </label>
                    <div class="flex items-center gap-2">
                        <span class="text-xs text-zinc-500">Số sân:</span>
                        <input type="number" id="soLuongSan_Tennis" name="soLuongSan_Tennis" value="1" min="1" disabled oninput="updateTotalCourts()" class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                    </div>
                </div>
                <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                    <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 transition-colors select-none">
                        <input type="checkbox" name="loaiHinhKinhDoanh" value="Pickleball" onchange="toggleSportCount(this, 'soLuongSan_Pickleball')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600 focus:ring-blue-500 transition-all"> 
                        <span class="font-medium">Pickleball</span>
                    </label>
                    <div class="flex items-center gap-2">
                        <span class="text-xs text-zinc-500">Số sân:</span>
                        <input type="number" id="soLuongSan_Pickleball" name="soLuongSan_Pickleball" value="1" min="1" disabled oninput="updateTotalCourts()" class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                    </div>
                </div>
            </div>
        </div>

        <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Địa chỉ</label>
            <input type="text" name="diaChi" required class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
        </div>

        <div class="grid grid-cols-2 gap-4">
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-semibold text-zinc-700">Giờ mở cửa</label>
                <input type="time" name="gioMoCua" required class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
            </div>
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-semibold text-zinc-700">Giờ đóng cửa</label>
                <input type="time" name="gioDongCua" required class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-medium">
            </div>
        </div>

        <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Tổng số lượng sân dự kiến</label>
            <div class="relative">
                <input type="number" id="soLuongSanDuKienDisplay" readonly value="0" 
                       class="w-full h-12 px-4 rounded-xl border border-zinc-200 text-lg font-black text-zinc-500 bg-zinc-100 focus:outline-none select-none">
                <input type="hidden" name="soLuongSanDuKien" id="soLuongSanDuKien" value="0">
                <p class="text-[10px] text-zinc-400 mt-1 italic font-medium">* Tự động tính từ số lượng sân của các môn thể thao đã chọn.</p>
            </div>
        </div>

        <div class="flex justify-end gap-3 mt-4 pt-4 border-t border-zinc-50">
            <button type="button" onclick="document.getElementById('modalThem').classList.add('hidden')" class="h-11 px-6 rounded-xl border border-zinc-200 text-sm font-bold text-zinc-600 hover:bg-zinc-50 transition-all">Hủy</button>
            <button type="submit" class="h-11 px-8 rounded-xl bg-zinc-900 text-white text-sm font-bold hover:bg-zinc-800 transition-all shadow-lg shadow-zinc-900/10">Lưu Cơ Sở</button>
        </div>
    </form>
  </div>
</div>

<script>
    // Mobile menu toggle
    document.getElementById('mobileMenuBtn').addEventListener('click', () => {
        document.getElementById('sidebar').classList.toggle('-translate-x-full');
    });

    function toggleSportCount(checkbox, inputId) {
        const input = document.getElementById(inputId);
        if (checkbox.checked) {
            input.removeAttribute('disabled');
            if (parseInt(input.value) <= 0 || !input.value) {
                input.value = 1;
            }
        } else {
            input.setAttribute('disabled', 'true');
            input.value = 0;
        }
        updateTotalCourts();
    }

    function updateTotalCourts() {
        let total = 0;
        const countInputs = document.querySelectorAll('.sport-count');
        countInputs.forEach(input => {
            if (!input.hasAttribute('disabled')) {
                const val = parseInt(input.value) || 0;
                total += val;
            }
        });
        const display = document.getElementById('soLuongSanDuKienDisplay');
        const hidden = document.getElementById('soLuongSanDuKien');
        if (display) display.value = total;
        if (hidden) hidden.value = total;
    }

    function validateForm() {
        updateTotalCourts();
        const total = parseInt(document.getElementById('soLuongSanDuKien').value) || 0;
        if (total <= 0) {
            alert('Vui lòng chọn ít nhất một môn thể thao và nhập số lượng sân lớn hơn 0.');
            return false;
        }
        return true;
    }
</script>

</body>
</html>
