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
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
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
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  
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

<!-- Modal Thêm Cơ Sở (3 bước: Thông tin → OTP → Cấu hình & Lưu) -->
<div id="modalThem" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeModalThem()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[560px] max-h-[92vh] flex flex-col">

    <!-- Header cố định -->
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100 shrink-0">
      <div class="flex items-center gap-3">
        <h3 class="text-base font-bold text-zinc-900">Thêm Cơ Sở mới</h3>
        <!-- Step bar -->
        <div class="flex items-center gap-1">
          <span id="sDot1" class="w-6 h-1.5 rounded-full bg-blue-600 transition-all"></span>
          <span id="sDot2" class="w-6 h-1.5 rounded-full bg-zinc-200 transition-all"></span>
          <span id="sDot3" class="w-6 h-1.5 rounded-full bg-zinc-200 transition-all"></span>
        </div>
        <span id="sLabel" class="text-xs text-zinc-400 font-medium">Bước 1 / 3</span>
      </div>
      <button onclick="closeModalThem()" class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-400">
        <span class="material-symbols-outlined text-[18px]">close</span>
      </button>
    </div>

    <!-- ══ BƯỚC 1: Thông tin cơ bản ══ -->
    <div id="aStep1" class="overflow-y-auto p-6 flex flex-col gap-4">
      <div id="adminAddError" class="hidden px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600 font-medium"></div>

      <div>
        <p class="text-sm font-semibold text-zinc-800 mb-1">Thông tin cơ bản</p>
        <p class="text-xs text-zinc-400">Nhập thông tin cơ sở. OTP sẽ được gửi đến email để xác minh.</p>
      </div>

      <!-- Tên cơ sở -->
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Tên Cơ Sở <span class="text-red-500">*</span></label>
        <input type="text" id="adminTenCoSo" placeholder="VD: V-Sport Vũng Tàu"
               class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
      </div>

      <!-- Email + SĐT -->
      <div class="grid grid-cols-2 gap-4">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Email liên hệ <span class="text-red-500">*</span></label>
          <input type="email" id="adminEmail" placeholder="email@example.com"
                 class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Số điện thoại <span class="text-red-500">*</span></label>
          <input type="tel" id="adminPhone" placeholder="0912 345 678"
                 class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
        </div>
      </div>

      <!-- Địa chỉ -->
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Địa chỉ <span class="text-red-500">*</span></label>
        <input type="text" id="adminDiaChi" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành"
               class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
      </div>

      <div class="flex justify-end gap-3 pt-3 border-t border-zinc-50">
        <button type="button" onclick="closeModalThem()" class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-bold text-zinc-600 hover:bg-zinc-50 transition-all">Hủy</button>
        <button type="button" onclick="adminSendOtp()" id="btnSendOtp"
                class="h-10 px-6 rounded-xl bg-blue-600 text-white text-sm font-bold hover:bg-blue-700 transition-all shadow-md shadow-blue-200 flex items-center gap-2">
          <span class="material-symbols-outlined text-[15px]">send</span> Tiếp tục — Xác thực Email
        </button>
      </div>
    </div>

    <!-- ══ BƯỚC 2: Xác thực OTP ══ -->
    <div id="aStep2" class="hidden p-6 flex flex-col gap-5">
      <div class="text-center">
        <div class="w-14 h-14 rounded-2xl bg-blue-50 flex items-center justify-center mx-auto mb-3">
          <span class="material-symbols-outlined text-blue-600 text-3xl">mark_email_read</span>
        </div>
        <h4 class="text-base font-bold text-zinc-900 mb-1">Xác thực Email</h4>
        <p class="text-sm text-zinc-500">Mã OTP 6 chữ số đã được gửi đến</p>
        <p class="text-sm font-semibold text-blue-600 mt-0.5" id="adminOtpEmailDisplay"></p>
      </div>

      <div class="flex justify-center gap-2">
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="0"/>
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="1"/>
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="2"/>
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="3"/>
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="4"/>
        <input type="text" maxlength="1" class="adm-otp w-11 h-12 text-center text-xl font-bold border-2 border-zinc-200 rounded-xl bg-white text-zinc-900 focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all" data-index="5"/>
      </div>

      <div id="adminOtpErr" class="hidden text-center text-sm text-red-500 font-medium -mt-2"></div>
      <p class="text-center text-xs text-zinc-400">Số lần nhập sai: <span id="adminOtpFails" class="font-bold text-red-500">0</span>/5</p>

      <button type="button" onclick="adminVerifyOtp()" id="btnVerifyOtp"
              class="w-full h-11 rounded-xl bg-zinc-900 text-white text-sm font-bold hover:bg-zinc-800 transition-all flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[15px]">verified</span> Xác thực OTP
      </button>
      <div class="flex items-center justify-between -mt-1">
        <button type="button" onclick="adminGoStep(1)" class="text-zinc-400 hover:text-zinc-700 text-sm flex items-center gap-1 bg-transparent border-none cursor-pointer">
          <span class="material-symbols-outlined text-sm">arrow_back</span> Quay lại
        </button>
        <button type="button" onclick="adminResendOtp()" id="btnResend"
                class="text-blue-500 hover:text-blue-700 text-sm disabled:opacity-40 bg-transparent border-none cursor-pointer" disabled>
          Gửi lại mã (<span id="admResendCd">60</span>s)
        </button>
      </div>
    </div>

    <!-- ══ BƯỚC 3: Cấu hình sân & Lưu ══ -->
    <div id="aStep3" class="hidden overflow-y-auto">
      <form id="formThemCoSo" action="${pageContext.request.contextPath}/admin/chi-nhanh/them" method="post" class="p-6 flex flex-col gap-4">
        <!-- hidden fields từ bước 1 -->
        <input type="hidden" name="tenCoSo"    id="hTenCoSo">
        <input type="hidden" name="email"       id="hEmail">
        <input type="hidden" name="soDienThoai" id="hPhone">
        <input type="hidden" name="diaChi"      id="hDiaChi">

        <div>
          <p class="text-sm font-semibold text-zinc-800 mb-0.5">Cấu hình cơ sở <span class="text-green-600 text-xs font-normal">✓ Email đã xác thực</span></p>
          <p class="text-xs text-zinc-400">Chọn môn thể thao, số sân và giờ hoạt động.</p>
        </div>

        <!-- Trạng thái -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Trạng thái <span class="text-red-500">*</span></label>
          <select name="trangThai" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
            <option value="Đang hoạt động">Đang hoạt động</option>
            <option value="Tạm nghỉ">Tạm nghỉ</option>
          </select>
        </div>

        <!-- Môn thể thao -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Môn thể thao cung cấp <span class="text-red-500">*</span></label>
          <div class="flex flex-col p-3 bg-zinc-50 rounded-xl border border-zinc-100 gap-0">
            <div class="flex items-center justify-between py-2 border-b border-zinc-200/60">
              <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 select-none">
                <input type="checkbox" name="loaiHinhKinhDoanh" value="Bóng đá" onchange="toggleSportCount(this,'soLuongSan_BongDa')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600">
                <span class="font-medium">Bóng đá</span>
              </label>
              <div class="flex items-center gap-2">
                <span class="text-xs text-zinc-500">Số sân:</span>
                <input type="number" id="soLuongSan_BongDa" name="soLuongSan_BongDa" value="1" min="1" disabled oninput="updateTotalCourts()"
                       class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400 focus:outline-none">
              </div>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-zinc-200/60">
              <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 select-none">
                <input type="checkbox" name="loaiHinhKinhDoanh" value="Cầu lông" onchange="toggleSportCount(this,'soLuongSan_CauLong')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600">
                <span class="font-medium">Cầu lông</span>
              </label>
              <div class="flex items-center gap-2">
                <span class="text-xs text-zinc-500">Số sân:</span>
                <input type="number" id="soLuongSan_CauLong" name="soLuongSan_CauLong" value="1" min="1" disabled oninput="updateTotalCourts()"
                       class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400 focus:outline-none">
              </div>
            </div>
            <div class="flex items-center justify-between py-2 border-b border-zinc-200/60">
              <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 select-none">
                <input type="checkbox" name="loaiHinhKinhDoanh" value="Tennis" onchange="toggleSportCount(this,'soLuongSan_Tennis')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600">
                <span class="font-medium">Tennis</span>
              </label>
              <div class="flex items-center gap-2">
                <span class="text-xs text-zinc-500">Số sân:</span>
                <input type="number" id="soLuongSan_Tennis" name="soLuongSan_Tennis" value="1" min="1" disabled oninput="updateTotalCourts()"
                       class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400 focus:outline-none">
              </div>
            </div>
            <div class="flex items-center justify-between py-2">
              <label class="flex items-center gap-2.5 text-sm text-zinc-600 cursor-pointer hover:text-zinc-900 select-none">
                <input type="checkbox" name="loaiHinhKinhDoanh" value="Pickleball" onchange="toggleSportCount(this,'soLuongSan_Pickleball')" class="sport-checkbox w-4 h-4 rounded border-zinc-300 text-blue-600">
                <span class="font-medium">Pickleball</span>
              </label>
              <div class="flex items-center gap-2">
                <span class="text-xs text-zinc-500">Số sân:</span>
                <input type="number" id="soLuongSan_Pickleball" name="soLuongSan_Pickleball" value="1" min="1" disabled oninput="updateTotalCourts()"
                       class="sport-count w-16 h-8 px-2 rounded-lg border border-zinc-200 text-sm font-semibold bg-white text-center disabled:bg-zinc-100 disabled:text-zinc-400 focus:outline-none">
              </div>
            </div>
          </div>
        </div>

        <!-- Giờ mở / đóng cửa -->
        <div class="grid grid-cols-2 gap-4">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Giờ mở cửa <span class="text-red-500">*</span></label>
            <input type="time" name="gioMoCua" required
                   class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-700">Giờ đóng cửa <span class="text-red-500">*</span></label>
            <input type="time" name="gioDongCua" required
                   class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
          </div>
        </div>

        <!-- Tổng số sân -->
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Tổng số lượng sân dự kiến</label>
          <input type="number" id="soLuongSanDuKienDisplay" readonly value="0"
                 class="w-full h-10 px-4 rounded-xl border border-zinc-200 text-sm font-bold text-zinc-500 bg-zinc-100 focus:outline-none select-none">
          <input type="hidden" name="soLuongSanDuKien" id="soLuongSanDuKien" value="0">
          <p class="text-[10px] text-zinc-400 italic">* Tự động tính từ số sân của các môn đã chọn.</p>
        </div>

        <!-- Buttons bước 3 -->
        <div class="flex justify-between gap-3 pt-3 border-t border-zinc-50">
          <button type="button" onclick="adminGoStep(1)"
                  class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-500 hover:bg-zinc-50 transition-all flex items-center gap-1">
            <span class="material-symbols-outlined text-sm">arrow_back</span> Quay lại
          </button>
          <div class="flex gap-3">
            <button type="button" onclick="closeModalThem()" class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-bold text-zinc-600 hover:bg-zinc-50 transition-all">Hủy</button>
            <button type="submit" onclick="return finalValidate()"
                    class="h-10 px-7 rounded-xl bg-zinc-900 text-white text-sm font-bold hover:bg-zinc-800 transition-all shadow-lg shadow-zinc-900/10 flex items-center gap-2">
              <span class="material-symbols-outlined text-[15px]">save</span> Lưu Cơ Sở
            </button>
          </div>
        </div>
      </form>
    </div>

  </div>
</div>

<script>
    document.getElementById('mobileMenuBtn').addEventListener('click', () => {
        document.getElementById('sidebar').classList.toggle('-translate-x-full');
    });

    // ═══════════ STATE ═══════════
    let admOtpFails = 0, admResendCount = 0, admResendTimer = null;

    // ═══════════ STEP NAVIGATION ═══════════
    function adminGoStep(n) {
        document.getElementById('aStep1').classList.toggle('hidden', n !== 1);
        document.getElementById('aStep2').classList.toggle('hidden', n !== 2);
        document.getElementById('aStep3').classList.toggle('hidden', n !== 3);
        const dots = ['sDot1','sDot2','sDot3'];
        dots.forEach((id, i) => {
            const el = document.getElementById(id);
            el.className = 'w-6 h-1.5 rounded-full transition-all ' +
                (i < n - 1 ? 'bg-green-500' : i === n - 1 ? 'bg-blue-600' : 'bg-zinc-200');
        });
        document.getElementById('sLabel').textContent = 'Bước ' + n + ' / 3';
        if (n === 2) setTimeout(() => document.querySelector('.adm-otp[data-index="0"]').focus(), 100);
    }

    function closeModalThem() {
        document.getElementById('modalThem').classList.add('hidden');
        adminGoStep(1);
        document.getElementById('formThemCoSo').reset();
        document.getElementById('adminTenCoSo').value = '';
        document.getElementById('adminEmail').value = '';
        document.getElementById('adminPhone').value = '';
        document.getElementById('adminDiaChi').value = '';
        updateTotalCourts();
        admOtpFails = 0; admResendCount = 0;
        clearInterval(admResendTimer);
        document.getElementById('adminAddError').classList.add('hidden');
        document.getElementById('adminOtpErr').classList.add('hidden');
        document.querySelectorAll('.adm-otp').forEach(b => b.value = '');
        document.querySelectorAll('.sport-checkbox').forEach(c => {
            c.checked = false;
            const id = c.getAttribute('onchange').match(/'([^']+)'/)[1];
            const inp = document.getElementById(id);
            if (inp) { inp.setAttribute('disabled','true'); inp.value = 1; }
        });
    }

    function showAdminError(msg) {
        const el = document.getElementById('adminAddError');
        el.textContent = msg;
        el.classList.remove('hidden');
    }

    // ═══════════ BƯỚC 1 → GỬI OTP ═══════════
    function adminSendOtp() {
        document.getElementById('adminAddError').classList.add('hidden');
        const name  = document.getElementById('adminTenCoSo').value.trim();
        const email = document.getElementById('adminEmail').value.trim();
        const phone = document.getElementById('adminPhone').value.trim();
        const addr  = document.getElementById('adminDiaChi').value.trim();

        if (!name)  return showAdminError('Vui lòng nhập tên cơ sở.');
        if (!email) return showAdminError('Vui lòng nhập email liên hệ.');
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return showAdminError('Email không hợp lệ.');
        if (!phone) return showAdminError('Vui lòng nhập số điện thoại.');
        if (!addr)  return showAdminError('Vui lòng nhập địa chỉ.');

        const btn = document.getElementById('btnSendOtp');
        btn.disabled = true;
        btn.innerHTML = '<span class="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full mr-1"></span> Đang gửi OTP...';

        fetch('${pageContext.request.contextPath}/owner/send-otp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'email=' + encodeURIComponent(email)
        })
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[15px]">send</span> Tiếp tục — Xác thực Email';
            if (data.success) {
                admOtpFails = 0; admResendCount = 0;
                document.getElementById('adminOtpFails').textContent = '0';
                document.getElementById('adminOtpEmailDisplay').textContent = email;
                document.getElementById('adminOtpErr').classList.add('hidden');
                document.querySelectorAll('.adm-otp').forEach(b => b.value = '');
                adminGoStep(2);
                admStartCountdown();
            } else {
                showAdminError(data.message || 'Không thể gửi OTP. Thử lại.');
            }
        })
        .catch(() => {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[15px]">send</span> Tiếp tục — Xác thực Email';
            showAdminError('Lỗi kết nối. Vui lòng thử lại.');
        });
    }

    // ═══════════ OTP INPUTS ═══════════
    document.querySelectorAll('.adm-otp').forEach(box => {
        box.addEventListener('input', e => {
            const v = e.target.value.replace(/\D/g, '');
            e.target.value = v ? v[0] : '';
            if (v && +e.target.dataset.index < 5)
                document.querySelector('.adm-otp[data-index="' + (+e.target.dataset.index + 1) + '"]').focus();
        });
        box.addEventListener('keydown', e => {
            if (e.key === 'Backspace' && !e.target.value) {
                const p = document.querySelector('.adm-otp[data-index="' + (+e.target.dataset.index - 1) + '"]');
                if (p) { p.focus(); p.value = ''; }
            }
            if (e.key === 'Enter') adminVerifyOtp();
        });
        box.addEventListener('paste', e => {
            e.preventDefault();
            const d = (e.clipboardData||window.clipboardData).getData('text').replace(/\D/g,'').split('');
            document.querySelectorAll('.adm-otp').forEach((b,i) => b.value = d[i]||'');
            document.querySelector('.adm-otp[data-index="' + Math.min(d.length-1,5) + '"]').focus();
        });
    });

    // ═══════════ BƯỚC 2 → XÁC THỰC OTP ═══════════
    function adminVerifyOtp() {
        const err = document.getElementById('adminOtpErr');
        err.classList.add('hidden');
        let otp = '';
        document.querySelectorAll('.adm-otp').forEach(b => otp += b.value);
        if (otp.length < 6) { err.textContent = 'Vui lòng nhập đủ 6 chữ số.'; err.classList.remove('hidden'); return; }

        const email = document.getElementById('adminEmail').value.trim();
        const btn = document.getElementById('btnVerifyOtp');
        btn.disabled = true;
        btn.innerHTML = '<span class="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full mr-1"></span> Đang xác thực...';

        fetch('${pageContext.request.contextPath}/owner/verify-otp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'email=' + encodeURIComponent(email) + '&otp=' + encodeURIComponent(otp)
        })
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[15px]">verified</span> Xác thực OTP';
            if (data.success) {
                clearInterval(admResendTimer);
                // Copy bước 1 vào hidden fields của form
                document.getElementById('hTenCoSo').value = document.getElementById('adminTenCoSo').value.trim();
                document.getElementById('hEmail').value   = document.getElementById('adminEmail').value.trim();
                document.getElementById('hPhone').value   = document.getElementById('adminPhone').value.trim();
                document.getElementById('hDiaChi').value  = document.getElementById('adminDiaChi').value.trim();
                adminGoStep(3);
            } else {
                admOtpFails++;
                document.getElementById('adminOtpFails').textContent = admOtpFails;
                document.querySelectorAll('.adm-otp').forEach(b => b.value = '');
                document.querySelector('.adm-otp[data-index="0"]').focus();
                if (admOtpFails >= 5) {
                    err.textContent = 'Sai OTP quá 5 lần. Vui lòng thử lại từ đầu.';
                    err.classList.remove('hidden');
                    setTimeout(() => adminGoStep(1), 2000);
                    admOtpFails = 0;
                } else {
                    err.textContent = 'Mã OTP không đúng. Còn ' + (5 - admOtpFails) + ' lần thử.';
                    err.classList.remove('hidden');
                }
            }
        })
        .catch(() => {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[15px]">verified</span> Xác thực OTP';
            err.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
            err.classList.remove('hidden');
        });
    }

    // ═══════════ RESEND ═══════════
    function admStartCountdown() {
        let s = 60;
        const btn = document.getElementById('btnResend');
        const cd  = document.getElementById('admResendCd');
        btn.disabled = true;
        clearInterval(admResendTimer);
        admResendTimer = setInterval(() => {
            s--; cd.textContent = s;
            if (s <= 0) { clearInterval(admResendTimer); btn.disabled = false; }
        }, 1000);
    }

    function adminResendOtp() {
        if (++admResendCount >= 3) {
            document.getElementById('adminOtpErr').textContent = 'Đã gửi lại quá 3 lần. Vui lòng thử lại từ đầu.';
            document.getElementById('adminOtpErr').classList.remove('hidden');
            setTimeout(() => adminGoStep(1), 2000);
            return;
        }
        const email = document.getElementById('adminEmail').value.trim();
        fetch('${pageContext.request.contextPath}/owner/send-otp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'email=' + encodeURIComponent(email)
        }).then(r => r.json()).then(data => {
            if (data.success) {
                document.querySelectorAll('.adm-otp').forEach(b => b.value = '');
                admOtpFails = 0;
                document.getElementById('adminOtpFails').textContent = '0';
                document.querySelector('.adm-otp[data-index="0"]').focus();
                admStartCountdown();
            }
        });
    }

    // ═══════════ BƯỚC 3: VALIDATE & SUBMIT ═══════════
    function finalValidate() {
        updateTotalCourts();
        const total = parseInt(document.getElementById('soLuongSanDuKien').value) || 0;
        if (total <= 0) {
            alert('Vui lòng chọn ít nhất một môn thể thao và nhập số sân lớn hơn 0.');
            return false;
        }
        return true;
    }

    // ═══════════ SPORT HELPERS ═══════════
    function toggleSportCount(checkbox, inputId) {
        const input = document.getElementById(inputId);
        if (checkbox.checked) {
            input.removeAttribute('disabled');
            if (!parseInt(input.value)) input.value = 1;
        } else {
            input.setAttribute('disabled', 'true');
            input.value = 0;
        }
        updateTotalCourts();
    }

    function updateTotalCourts() {
        let total = 0;
        document.querySelectorAll('.sport-count').forEach(i => {
            if (!i.hasAttribute('disabled')) total += parseInt(i.value) || 0;
        });
        const d = document.getElementById('soLuongSanDuKienDisplay');
        const h = document.getElementById('soLuongSanDuKien');
        if (d) d.value = total;
        if (h) h.value = total;
    }
</script>

</body>
</html>
