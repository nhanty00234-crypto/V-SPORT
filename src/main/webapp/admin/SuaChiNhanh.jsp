<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sửa Cơ Sở — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; }
  
  /* Larger Number Input Arrows */
  input[type="number"]::-webkit-inner-spin-button, 
  input[type="number"]::-webkit-outer-spin-button { 
    opacity: 1;
    height: 30px;
    width: 30px;
    cursor: pointer;
  }

  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  main > section { animation: fadeUp .4s ease both; }
  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }

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
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Chỉnh sửa Cơ Sở</h1>
      <p class="text-xs text-zinc-500">Cập nhật thông tin chi tiết</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col items-center text-zinc-900">
  <section class="w-full max-w-[800px]">
    <div class="mb-6 flex items-center gap-2 text-xs font-medium text-zinc-500">
        <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="hover:text-zinc-900 transition-colors">Quản lý Cơ Sở</a>
        <span class="material-symbols-outlined text-[14px]">chevron_right</span>
        <span class="text-zinc-900 font-bold">${chiNhanh.tenCoSo}</span>
    </div>

    <div class="card p-8 shadow-sm">
      <form action="${pageContext.request.contextPath}/admin/chi-nhanh/sua" method="post" class="flex flex-col gap-6" onsubmit="return validateForm()">
        <input type="hidden" name="id" value="${chiNhanh.coSoID}">
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Tên Cơ Sở</label>
                <input type="text" name="tenCoSo" value="${chiNhanh.tenCoSo}" required class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
            </div>
            
            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Trạng thái</label>
                <select name="trangThai" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
                    <option value="Đang hoạt động" ${chiNhanh.trangThai == 'Đang hoạt động' ? 'selected' : ''}>Đang hoạt động</option>
                    <option value="Tạm nghỉ" ${chiNhanh.trangThai == 'Tạm nghỉ' ? 'selected' : ''}>Tạm nghỉ</option>
                </select>
            </div>

            <div class="flex flex-col gap-1.5 col-span-1 md:col-span-2">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Môn thể thao (Cung cấp tại Cơ Sở)</label>
                <div class="flex flex-col gap-3 p-4 bg-zinc-50 rounded-xl border border-zinc-100">
                    <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                        <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer select-none">
                            <input type="checkbox" name="loaiHinhKinhDoanh" value="Bóng đá" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Bóng đá') ? 'checked' : ''} 
                                   onchange="toggleSportCount(this, 'soLuongSan_BongDa')" 
                                   class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600"> 
                            <span class="font-medium">Bóng đá</span>
                        </label>
                        <div class="flex items-center gap-2">
                            <span class="text-xs text-zinc-500">Số sân:</span>
                            <input type="number" id="soLuongSan_BongDa" name="soLuongSan_BongDa" 
                                   value="${countBongDa > 0 ? countBongDa : (chiNhanh.loaiHinhKinhDoanh.contains('Bóng đá') ? 1 : 0)}" 
                                   min="1" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Bóng đá') ? '' : 'disabled'} 
                                   oninput="updateTotalCourts()" 
                                   class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                        </div>
                    </div>
                    
                    <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                        <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer select-none">
                            <input type="checkbox" name="loaiHinhKinhDoanh" value="Cầu lông" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Cầu lông') ? 'checked' : ''} 
                                   onchange="toggleSportCount(this, 'soLuongSan_CauLong')" 
                                   class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600"> 
                            <span class="font-medium">Cầu lông</span>
                        </label>
                        <div class="flex items-center gap-2">
                            <span class="text-xs text-zinc-500">Số sân:</span>
                            <input type="number" id="soLuongSan_CauLong" name="soLuongSan_CauLong" 
                                   value="${countCauLong > 0 ? countCauLong : (chiNhanh.loaiHinhKinhDoanh.contains('Cầu lông') ? 1 : 0)}" 
                                   min="1" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Cầu lông') ? '' : 'disabled'} 
                                   oninput="updateTotalCourts()" 
                                   class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                        </div>
                    </div>

                    <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                        <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer select-none">
                            <input type="checkbox" name="loaiHinhKinhDoanh" value="Tennis" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Tennis') ? 'checked' : ''} 
                                   onchange="toggleSportCount(this, 'soLuongSan_Tennis')" 
                                   class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600"> 
                            <span class="font-medium">Tennis</span>
                        </label>
                        <div class="flex items-center gap-2">
                            <span class="text-xs text-zinc-500">Số sân:</span>
                            <input type="number" id="soLuongSan_Tennis" name="soLuongSan_Tennis" 
                                   value="${countTennis > 0 ? countTennis : (chiNhanh.loaiHinhKinhDoanh.contains('Tennis') ? 1 : 0)}" 
                                   min="1" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Tennis') ? '' : 'disabled'} 
                                   oninput="updateTotalCourts()" 
                                   class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                        </div>
                    </div>

                    <div class="flex items-center justify-between gap-4 py-1.5 border-b border-zinc-200/60 last:border-b-0">
                        <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer select-none">
                            <input type="checkbox" name="loaiHinhKinhDoanh" value="Pickleball" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Pickleball') ? 'checked' : ''} 
                                   onchange="toggleSportCount(this, 'soLuongSan_Pickleball')" 
                                   class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600"> 
                            <span class="font-medium">Pickleball</span>
                        </label>
                        <div class="flex items-center gap-2">
                            <span class="text-xs text-zinc-500">Số sân:</span>
                            <input type="number" id="soLuongSan_Pickleball" name="soLuongSan_Pickleball" 
                                   value="${countPickleball > 0 ? countPickleball : (chiNhanh.loaiHinhKinhDoanh.contains('Pickleball') ? 1 : 0)}" 
                                   min="1" 
                                   ${chiNhanh.loaiHinhKinhDoanh.contains('Pickleball') ? '' : 'disabled'} 
                                   oninput="updateTotalCourts()" 
                                   class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm focus:border-zinc-400 focus:outline-none transition-all font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400">
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-1.5 col-span-1 md:col-span-2">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Địa chỉ</label>
                <input type="text" name="diaChi" value="${chiNhanh.diaChi}" required class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
            </div>

            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Số điện thoại</label>
                <input type="text" name="soDienThoai" value="${chiNhanh.soDienThoai}" required class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
            </div>

            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Tổng số lượng sân dự kiến</label>
                <input type="number" id="soLuongSanDuKienDisplay" readonly value="${chiNhanh.soLuongSanDuKien}" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:outline-none bg-zinc-100 font-black text-zinc-500 select-none">
                <input type="hidden" name="soLuongSanDuKien" id="soLuongSanDuKien" value="${chiNhanh.soLuongSanDuKien}">
            </div>

            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Giờ mở cửa</label>
                <input type="time" name="gioMoCua" value="${chiNhanh.gioMoCua}" required class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
            </div>

            <div class="flex flex-col gap-1.5">
                <label class="text-xs font-bold text-zinc-500 uppercase tracking-widest">Giờ đóng cửa</label>
                <input type="time" name="gioDongCua" value="${chiNhanh.gioDongCua}" required class="h-10 px-4 rounded-xl border border-zinc-200 text-sm focus:border-zinc-900 focus:outline-none transition-all font-medium">
            </div>
        </div>

        <div class="flex justify-end gap-3 mt-8 pt-6 border-t border-zinc-100">
            <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="h-10 px-6 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 flex items-center transition-all">Hủy</a>
            <button type="submit" class="h-10 px-8 rounded-xl bg-zinc-900 text-white text-sm font-semibold hover:bg-zinc-800 transition-all shadow-md">Cập nhật Cơ Sở</button>
        </div>
      </form>
    </div>
  </section>
</main>

<script>
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

    // Initialize counts on page load
    window.addEventListener('DOMContentLoaded', () => {
        updateTotalCourts();
    });
</script>

</body>
</html>
