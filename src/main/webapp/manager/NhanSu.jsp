<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý nhân sự cơ sở — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }

  /* Sub-navigation Tabs */
  .nav-link-tab {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 8px;
    background: #f4f4f5;
    color: #52525b;
    font-size: 13px;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
  }
  .nav-link-tab:hover {
    background: #e4e4e7;
    color: #18181b;
  }
  .nav-link-tab.active {
    background: #7c3aed;
    color: white;
    box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.3);
  }
  .nav-link-tab .material-symbols-outlined {
    font-size: 18px;
  }

  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-yellow { background:#fef3c7;color:#b45309; }
  .badge-blue { background:#dbeafe;color:#1d4ed8; }
  .badge-zinc { background:#f4f4f5;color:#71717a; }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(139,92,246,.4);} 50%{box-shadow:0 0 0 6px rgba(139,92,246,0);} }

  @keyframes contentZoomIn {
    from { opacity: 0; transform: scale(0.97); }
    to { opacity: 1; transform: scale(1); }
  }
  main { animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; transform-origin: center top; }

  /* Fade in up animation */
  @keyframes fadeInUp {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fade-in-up { animation: fadeInUp 0.3s ease-out forwards; }

  /* Scroll Animation Styles */
  .reveal-on-scroll {
    opacity: 0;
    transform: translateY(12px);
    transition: opacity 0.5s cubic-bezier(0.16, 1, 0.3, 1), transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  }
  .reveal-on-scroll.revealed {
    opacity: 1;
    transform: translateY(0);
  }
</style>
</head>
<body class="bg-violet-50/20 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-violet-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-violet-50 text-violet-700"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-violet-900 tracking-tight">Quản lý nhân sự cơ sở</h1>
      <p class="text-xs text-violet-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}</p>
    </div>
  </div>

  <div class="flex items-center gap-1.5">
    <button class="relative p-2 rounded-lg hover:bg-violet-50 text-violet-500">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-violet-600 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-violet-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <!-- Sub-navigation -->
  <div class="flex gap-2 mb-2">
    <button onclick="switchView('staff')" id="nav-staff" class="nav-link-tab active">
      <span class="material-symbols-outlined text-[16px]">people</span>
      Nhân viên
    </button>
    <button onclick="switchView('schedule')" id="nav-schedule" class="nav-link-tab">
      <span class="material-symbols-outlined text-[16px]">schedule</span>
      Quản lý ca làm
    </button>
    <button onclick="switchView('leave')" id="nav-leave" class="nav-link-tab">
      <span class="material-symbols-outlined text-[16px]">assignment</span>
      Yêu cầu nghỉ
    </button>
    <button onclick="switchView('swap')" id="nav-swap" class="nav-link-tab">
      <span class="material-symbols-outlined text-[16px]">swap_horiz</span>
      Yêu cầu đổi ca
    </button>
  </div>

  <!-- Staff Section (View 1) -->
  <div id="viewStaffSection">
    <div class="flex items-center justify-between gap-4 mb-2">
      <h2 class="text-lg font-bold text-violet-950">Danh sách nhân viên <span class="text-xs bg-violet-100 px-1.5 py-0.5 rounded font-semibold text-violet-700" id="staffCountDisplay">0</span></h2>
      <div class="flex gap-2">
        <button onclick="openTrashBinModal()" class="flex items-center justify-center gap-1.5 h-10 px-4 rounded-xl bg-zinc-100 hover:bg-zinc-200 text-zinc-700 text-sm font-semibold transition-all border border-zinc-200">
          <span class="material-symbols-outlined text-[18px]">delete</span>Thùng rác
        </button>
        <button onclick="openAddStaff()" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 transition-all shadow-md shadow-violet-100">
          <span class="material-symbols-outlined text-[18px]">person_add</span>Thêm nhân viên
        </button>
      </div>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.error}">
      <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
        <div>
          <span class="font-bold block text-red-700">Lỗi thao tác</span>
          <span class="text-red-600/95 leading-normal block mt-0.5">${sessionScope.error}</span>
        </div>
        <% session.removeAttribute("error"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.message}">
      <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
        <div>
          <span class="font-bold block text-violet-700">Thành công</span>
          <span class="text-violet-600/95 leading-normal block mt-0.5">${sessionScope.message}</span>
        </div>
        <% session.removeAttribute("message"); %>
      </div>
    </c:if>

    <div class="card overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-violet-50/50 border-b border-violet-100">
          <tr>
            <th class="px-4 py-3 text-left font-semibold text-violet-800 text-xs">Thành viên</th>
            <th class="px-4 py-3 text-left font-semibold text-violet-800 text-xs">Vai trò</th>
            <th class="px-4 py-3 text-left font-semibold text-violet-800 text-xs">Điện thoại</th>
            <th class="px-4 py-3 text-left font-semibold text-violet-800 text-xs">Trạng thái</th>
            <th class="px-4 py-3 text-right font-semibold text-violet-800 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-violet-50" id="staffBody"></tbody>
      </table>
    </div>
  </div>

  <!-- ==================== VIEW 2: QUẢN LÝ CA LÀM ==================== -->
  <div id="viewScheduleSection" class="hidden flex flex-col gap-4">
    <!-- Header -->
    <div class="flex items-center justify-between gap-4 mb-2">
      <div>
        <h2 class="text-lg font-bold text-violet-950 flex items-center gap-2">
          Phân công ca làm
          <span class="text-xs bg-violet-100 px-2 py-0.5 rounded-full font-semibold text-violet-700" id="shiftCountDisplay">0 ca</span>
        </h2>
        <p class="text-xs text-zinc-500">Xem và điều hành lịch làm việc của nhân sự tại chi nhánh</p>
      </div>
      <div class="flex items-center gap-3">
        <button onclick="switchView('leave')" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-all shadow-md shadow-blue-100">
          <span class="material-symbols-outlined text-[18px]">assignment</span>
          Quản lý yêu cầu nghỉ
        </button>
        <button onclick="resetForm()" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-violet-100 text-violet-700 text-sm font-semibold hover:bg-violet-200 transition-all">
          <span class="material-symbols-outlined text-[18px]">restart_alt</span>Đặt lại form
        </button>
      </div>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.error}">
      <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
        <div class="flex-1">
          <span class="font-bold block text-red-750">Lỗi thực hiện</span>
          <span class="text-red-600/90 leading-normal block mt-0.5">${sessionScope.error}</span>
        </div>
        <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
        <% session.removeAttribute("error"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.message}">
      <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
        <div class="flex-1">
          <span class="font-bold block text-violet-700">Thành công</span>
          <span class="text-violet-600/90 leading-normal block mt-0.5">${sessionScope.message}</span>
        </div>
        <button onclick="this.parentElement.remove()" class="text-violet-400 hover:text-violet-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
        <% session.removeAttribute("message"); %>
      </div>
    </c:if>

    <!-- Inline Shift Configuration Form -->
    <div class="card p-6 bg-white border border-violet-100 shadow-md">
      <div class="flex items-center justify-between border-b border-violet-100 pb-4 mb-5">
        <h3 id="formTitle" class="text-base font-bold text-violet-900 flex items-center gap-2">
          <span class="material-symbols-outlined text-violet-600 text-[22px]">calendar_month</span>
          Phân ca làm việc mới
        </h3>
        <div class="text-xs text-violet-500 font-semibold bg-violet-50 px-3 py-1 rounded-full border border-violet-100">
          Chi nhánh CS${sessionScope.user.coSoId}
        </div>
      </div>

      <form id="inlineScheduleShiftForm" onsubmit="handleInlineScheduleShiftSubmit(event)" class="flex flex-col gap-5">
        <input type="hidden" id="scheduleShiftEditId" value="">
        <input type="hidden" id="scheduleShiftBranch" value="${sessionScope.user.coSoId}">

        <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div class="flex flex-col gap-1.5 md:col-span-2">
            <label class="text-sm font-semibold text-violet-900">Chọn nhân viên <span class="text-red-500">*</span></label>
            <select id="scheduleShiftStaff" onchange="triggerRealtimeValidation()" required 
                    class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-violet-300">
              <option value="">-- Chọn nhân viên --</option>
            </select>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Tuần làm việc (Chọn ngày tham chiếu) <span class="text-red-500">*</span></label>
            <input type="date" id="scheduleShiftDate" onchange="updateWeekDays(); triggerRealtimeValidation();" required 
                   class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-violet-300">
          </div>
        </div>

        <div class="flex flex-col gap-2 p-4 bg-violet-50/30 border border-violet-100 rounded-xl">
          <div class="flex items-center justify-between">
            <label class="text-sm font-bold text-violet-900">Chọn các ngày làm việc trong tuần <span class="text-red-500">*</span></label>
            <div id="selectAllContainer" class="flex gap-3 text-xs">
              <button type="button" onclick="selectAllWeekDays(true)" class="text-violet-600 hover:text-violet-900 font-bold hover:underline">Chọn tất cả</button>
              <span class="text-violet-200">|</span>
              <button type="button" onclick="selectAllWeekDays(false)" class="text-violet-600 hover:text-violet-900 font-bold hover:underline">Bỏ chọn tất cả</button>
            </div>
          </div>
          <div id="weekDaysCheckboxes" class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-3 mt-1">
            <!-- Populated dynamically via JS -->
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-5">
          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Mẫu ca hệ thống <span class="text-red-500">*</span></label>
            <select id="scheduleShiftTemplate" onchange="applyShiftTemplate()" required 
                    class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-violet-300">
              <option value="Tùy chỉnh">-- Tự cấu hình giờ --</option>
              <option value="Ca sáng">Ca sáng (06:00 - 14:00)</option>
              <option value="Ca chiều">Ca chiều (14:00 - 22:00)</option>
              <option value="Ca đêm">Ca đêm (22:00 - 06:00)</option>
            </select>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Vai trò trong ca <span class="text-red-500">*</span></label>
            <select id="scheduleShiftViTri" required 
                    class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-violet-300">
              <option value="Lễ tân">Lễ tân</option>
              <option value="Bảo vệ">Bảo vệ</option>
              <option value="Kỹ thuật sân">Kỹ thuật sân</option>
              <option value="Khác">Khác</option>
            </select>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Giờ bắt đầu <span class="text-red-500">*</span></label>
            <input type="time" id="scheduleStartTime" onchange="triggerRealtimeValidation()" required 
                   class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-violet-300">
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Giờ kết thúc <span class="text-red-500">*</span></label>
            <input type="time" id="scheduleEndTime" onchange="triggerRealtimeValidation()" required 
                   class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-violet-300">
          </div>
        </div>

        <div id="scheduleShiftDurationDisplay" class="hidden"></div>
        <div id="scheduleShiftAlertBox" class="hidden"></div>

        <!-- Reason for change (mandatory if shift is published) -->
        <div id="scheduleReasonContainer" class="hidden flex flex-col gap-1.5 p-3.5 bg-red-50 border border-red-100 rounded-xl">
          <label class="text-sm font-bold text-red-900">Lý do thay đổi lịch (bắt buộc vì ca đã công bố) <span class="text-red-500">*</span></label>
          <input type="text" id="scheduleChangeReason" placeholder="Nhập lý do thay đổi lịch đã công bố..."
                 class="h-[42px] px-3.5 rounded-xl border border-red-200 text-sm focus:ring-2 focus:ring-red-500 focus:border-red-500 outline-none bg-white text-zinc-700">
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Giờ nghỉ (phút)</label>
            <input type="number" id="scheduleShiftGioNghi" onchange="triggerRealtimeValidation()" min="0" value="0" placeholder="Ví dụ: 30"
                   class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-violet-300">
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Trạng thái ca <span class="text-red-500">*</span></label>
            <select id="scheduleShiftTrangThai" required 
                    class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-violet-300">
              <option value="Published" selected>Hoạt động (Nhân viên thấy)</option>
              <option value="Draft">Nháp (Ẩn với nhân viên)</option>
            </select>
          </div>

          <div class="flex flex-col gap-1.5">
            <label class="text-sm font-semibold text-violet-900">Ghi chú / Phân công việc</label>
            <input type="text" id="scheduleNotes" placeholder="Ví dụ: Bàn giao lại sân số 2..."
                   class="h-[42px] px-3.5 rounded-xl border border-violet-200 text-sm focus:ring-2 focus:ring-violet-500 focus:border-violet-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-violet-300">
          </div>
        </div>

        <div class="flex items-center justify-end gap-3 pt-3 border-t border-violet-100">
          <button type="button" onclick="resetForm()" 
                  class="h-[42px] px-6 rounded-xl border border-zinc-200 bg-white text-sm font-semibold text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 transition-colors shadow-sm">
            Hủy / Đặt lại
          </button>
          <button type="submit" id="btnSubmitShift"
                  class="h-[42px] px-8 rounded-xl bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 focus:ring-2 focus:ring-violet-500 focus:ring-offset-2 shadow-md shadow-violet-200 transition-all flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed">
            Lưu ca làm việc
          </button>
        </div>
      </form>
    </div>

    <!-- Success Result Banner -->
    <div id="successResultBanner" class="hidden p-5 bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 rounded-2xl flex items-start gap-4 shadow-sm animate-fade-in-up mb-4">
      <div class="w-10 h-10 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center shrink-0 shadow-inner">
        <span class="material-symbols-outlined text-[22px]">check_circle</span>
      </div>
      <div class="flex-1">
        <h4 class="text-sm font-bold text-emerald-900">Phân ca thành công!</h4>
        <p id="successBannerText" class="text-sm text-emerald-800/90 leading-relaxed mt-1">
          Nhân viên đã được phân ca làm việc thành công.
        </p>
      </div>
      <button onclick="document.getElementById('successResultBanner').classList.add('hidden')" class="p-1 rounded-lg hover:bg-emerald-100 text-emerald-500 hover:text-emerald-800 transition-colors shrink-0">
        <span class="material-symbols-outlined text-[20px]">close</span>
      </button>
    </div>

    <!-- Filter Section -->
    <div class="card p-4 flex flex-col md:flex-row gap-3 items-center justify-between bg-white">
      <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
        <!-- Search Input -->
        <div class="relative w-full sm:w-[220px]">
          <span class="material-symbols-outlined absolute left-3 top-2.5 text-zinc-400 text-[18px]">search</span>
          <input type="text" id="scheduleSearchName" placeholder="Tìm tên nhân viên..." oninput="filterScheduleShifts()"
                 class="h-9 w-full pl-9 pr-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
        </div>

        <!-- Role Filter -->
        <select id="scheduleFilterRole" onchange="filterScheduleShifts()"
                class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none bg-white">
          <option value="">Tất cả vai trò</option>
          <option value="4">Lễ tân</option>
          <option value="5">Bảo vệ</option>
        </select>

        <!-- Date Option Filter -->
        <select id="scheduleFilterDateOpt" onchange="toggleScheduleDateInputs(); filterScheduleShifts();"
                class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none bg-white">
          <option value="all">Tất cả ngày</option>
          <option value="today">Hôm nay</option>
          <option value="tomorrow">Ngày mai</option>
          <option value="custom">Chọn khoảng ngày</option>
        </select>
      </div>

      <!-- Date Pickers -->
      <div id="scheduleDateInputs" class="hidden flex items-center gap-2 w-full md:w-auto">
        <div class="flex items-center gap-1.5 w-full sm:w-auto">
          <span class="text-xs text-zinc-500 whitespace-nowrap">Từ</span>
          <input type="date" id="scheduleFilterStartDate" onchange="filterScheduleShifts()"
                 class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none w-full sm:w-auto">
        </div>
        <div class="flex items-center gap-1.5 w-full sm:w-auto">
          <span class="text-xs text-zinc-500 whitespace-nowrap">đến</span>
          <input type="date" id="scheduleFilterEndDate" onchange="filterScheduleShifts()"
                 class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none w-full sm:w-auto">
        </div>
      </div>

      <!-- View Toggle -->
      <div class="flex items-center gap-2">
        <div class="flex bg-violet-50 rounded-lg p-1">
          <button id="viewTableBtn" onclick="switchScheduleView('table')" class="px-3 py-1.5 rounded text-sm font-medium bg-white text-violet-700 shadow-sm transition-all">
            <span class="material-symbols-outlined text-[16px] align-middle mr-1">table_view</span>Bảng
          </button>
          <button id="viewCalendarBtn" onclick="switchScheduleView('calendar')" class="px-3 py-1.5 rounded text-sm font-medium text-violet-600 hover:text-violet-700 transition-all">
            <span class="material-symbols-outlined text-[16px] align-middle mr-1">calendar_view_week</span>Lịch tuần
          </button>
        </div>
      </div>
    </div>

    <!-- ==================== TABLE VIEW ==================== -->
    <div id="tableView" class="card overflow-hidden bg-white">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-violet-50/50 border-b border-violet-100">
            <tr>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Nhân viên</th>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Vai trò</th>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Ngày làm</th>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Giờ làm việc</th>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Trạng thái</th>
              <th class="px-5 py-3.5 text-left font-semibold text-violet-900 text-xs">Ghi chú / Công việc</th>
              <th class="px-5 py-3.5 text-right font-semibold text-violet-900 text-xs">Thao tác</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-violet-50/70" id="scheduleShiftBody">
            <!-- Populated by JS -->
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div id="scheduleEmptyState" class="hidden flex flex-col items-center justify-center py-12 px-4 text-center">
        <span class="material-symbols-outlined text-[48px] text-violet-200 mb-2">event_busy</span>
        <p class="text-zinc-500 text-sm font-medium">Không tìm thấy ca làm việc nào phù hợp</p>
        <p class="text-zinc-400 text-xs mt-0.5">Hãy điền form phân ca ở trên để bắt đầu xếp lịch</p>
      </div>
    </div>

    <!-- ==================== CALENDAR VIEW ==================== -->
    <div id="calendarView" class="hidden flex flex-col gap-4">
      <!-- Week Navigation & Actions -->
      <div class="card p-4 bg-white flex flex-col md:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-3">
          <button onclick="changeWeek(-1)" class="flex items-center gap-1 px-2.5 py-1.5 rounded-lg border border-violet-100 hover:bg-violet-50 text-violet-700 transition-colors">
            <span class="material-symbols-outlined text-[18px]">chevron_left</span>
          </button>
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-bold text-violet-900" id="weekRangeDisplay">Tuần này</h3>
            <span id="weekPublishBadge" class="badge">Chưa công bố</span>
          </div>
          <button onclick="changeWeek(1)" class="flex items-center gap-1 px-2.5 py-1.5 rounded-lg border border-violet-100 hover:bg-violet-50 text-violet-700 transition-colors">
            <span class="material-symbols-outlined text-[18px]">chevron_right</span>
          </button>
        </div>
        
        <div class="flex items-center gap-2 w-full md:w-auto justify-end">
          <button onclick="clonePreviousWeek()" class="flex items-center justify-center gap-1.5 h-9 px-4 rounded-lg border border-violet-200 hover:bg-violet-50 text-violet-700 text-xs font-semibold transition-all">
            <span class="material-symbols-outlined text-[16px]">content_copy</span>Nhân bản tuần trước
          </button>
          <button onclick="publishCurrentWeek()" id="btnPublishWeek" class="flex items-center justify-center gap-1.5 h-9 px-4 rounded-lg bg-violet-600 hover:bg-violet-700 text-white text-xs font-semibold transition-all shadow shadow-violet-100">
            <span class="material-symbols-outlined text-[16px]">publish</span>Công bố lịch
          </button>
        </div>
      </div>

      <!-- Calendar Grid -->
      <div class="card overflow-hidden bg-white p-4">
        <div id="calendarGrid" class="grid gap-4">
          <!-- Populated by JS -->
        </div>
      </div>
    </div>
  </div>

  <!-- ==================== VIEW 3: YÊU CẦU NGHỈ ==================== -->
  <div id="viewLeaveSection" class="hidden">
    <!-- Header -->
    <div class="flex items-center justify-between gap-4 mb-3">
      <div>
        <h2 class="text-lg font-bold text-violet-950">Quản lý yêu cầu nghỉ</h2>
        <p class="text-xs text-zinc-500">Duyệt và quản lý yêu cầu nghỉ phép của nhân viên</p>
      </div>
      <button onclick="switchView('staff')" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-violet-100 text-violet-750 text-sm font-semibold hover:bg-violet-200 transition-all">
        <span class="material-symbols-outlined text-[18px]">arrow_back</span>
        Quay lại nhân viên
      </button>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-5 mb-5">
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Tất cả yêu cầu</span>
          <span class="text-2xl font-extrabold text-zinc-800" id="leaveTotalCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">assignment</span>
        </div>
      </div>
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Chờ duyệt</span>
          <span class="text-2xl font-extrabold text-amber-600" id="leavePendingCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">pending_actions</span>
        </div>
      </div>
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Đã duyệt</span>
          <span class="text-2xl font-extrabold text-emerald-600" id="leaveApprovedCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">check_circle</span>
        </div>
      </div>
    </div>

    <!-- Filter -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-4">
      <div class="flex items-center gap-2 bg-zinc-100 p-1 rounded-xl">
        <button onclick="filterLeaveRequests('all', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer">Tất cả</button>
        <button onclick="filterLeaveRequests('ChoDuyet', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Chờ duyệt</button>
        <button onclick="filterLeaveRequests('DaDuyet', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Đã duyệt</button>
        <button onclick="filterLeaveRequests('TuChoi', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Từ chối</button>
      </div>
    </div>

    <!-- Leave Requests Table -->
    <div class="card overflow-hidden">
      <table class="w-full text-left border-collapse text-xs">
        <thead>
          <tr class="bg-violet-50/50 text-violet-950 font-bold border-b border-violet-100">
            <th class="p-4 w-12 text-center">#</th>
            <th class="p-4">Nhân viên</th>
            <th class="p-4">Vai trò</th>
            <th class="p-4">Ngày nghỉ</th>
            <th class="p-4">Loại nghỉ</th>
            <th class="p-4">Lý do</th>
            <th class="p-4">Trạng thái</th>
            <th class="p-4">Ngày gửi</th>
            <th class="p-4 text-right pr-6">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-violet-50" id="leaveRequestBody">
          <!-- Populated by JS -->
        </tbody>
      </table>
      <!-- Empty State -->
      <div id="leaveEmptyState" class="hidden flex flex-col items-center justify-center py-12 px-4 text-center">
        <span class="material-symbols-outlined text-[48px] text-violet-200 mb-2">event_busy</span>
        <p class="text-zinc-500 text-sm font-medium">Chưa có yêu cầu nghỉ nào</p>
      </div>
    </div>
  </div>

  <!-- ==================== VIEW 4: YÊU CẦU ĐỔI CA ==================== -->
  <div id="viewSwapSection" class="hidden">
    <div class="flex items-center justify-between gap-4 mb-2">
      <div>
        <h2 class="text-lg font-bold text-violet-950">Quản lý yêu cầu đổi ca</h2>
        <p class="text-xs text-zinc-500">Duyệt và quản lý yêu cầu hoán đổi ca làm giữa các nhân viên</p>
      </div>
    </div>


    <!-- Filter -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-4">
      <div class="flex items-center gap-2 bg-zinc-100 p-1 rounded-xl">
        <button onclick="filterSwapRequests('all', this)" class="swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer">Tất cả</button>
        <button onclick="filterSwapRequests('ChoQuanLyDuyet', this)" class="swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Chờ quản lý duyệt</button>
        <button onclick="filterSwapRequests('ChoXacNhan', this)" class="swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Chờ xác nhận</button>
        <button onclick="filterSwapRequests('DaDuyet', this)" class="swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Đã duyệt</button>
        <button onclick="filterSwapRequests('TuChoi', this)" class="swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Từ chối</button>
      </div>
    </div>

    <!-- Swap Requests Table -->
    <div class="card overflow-hidden">
      <table class="w-full text-left border-collapse text-xs">
        <thead>
          <tr class="bg-violet-50/50 text-violet-950 font-bold border-b border-violet-100">
            <th class="p-4 w-12 text-center">#</th>
            <th class="p-4">Nhân viên gửi</th>
            <th class="p-4">Đổi với nhân viên</th>
            <th class="p-4">Chi tiết ca gửi</th>
            <th class="p-4">Chi tiết ca đổi</th>
            <th class="p-4">Lý do</th>
            <th class="p-4">Trạng thái</th>
            <th class="p-4 text-right pr-6">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-violet-50 text-xs" id="swapRequestBody">
          <!-- Populated by JS -->
        </tbody>
      </table>
      <!-- Empty State -->
      <div id="swapEmptyState" class="hidden flex flex-col items-center justify-center py-12 px-4 text-center">
        <span class="material-symbols-outlined text-[48px] text-violet-200 mb-2">swap_horiz</span>
        <p class="text-zinc-500 text-sm font-medium">Chưa có yêu cầu đổi ca nào</p>
      </div>
    </div>
  </div>
</main>

<!-- Shift Management Modal -->
<div id="shiftModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeShiftModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[520px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-violet-50">
      <h2 id="shiftModalTitle" class="text-base font-semibold text-violet-950">Quản lý ca làm</h2>
      <button onclick="closeShiftModal()" class="p-1.5 rounded-lg hover:bg-violet-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4">
      <!-- Staff Info -->
      <div class="mb-4 p-3 bg-violet-50 rounded-xl">
        <p class="text-sm font-semibold text-violet-900">Nhân viên: <span id="shiftStaffName">-</span></p>
        <p class="text-xs text-violet-600 mt-1">Thêm ca làm định kỳ theo thứ trong tuần</p>
      </div>

      <!-- Current Shifts List -->
      <div id="currentShiftsList" class="mb-4">
        <h3 class="text-sm font-semibold text-violet-900 mb-2">Ca làm hiện tại:</h3>
        <div id="shiftsContainer" class="space-y-2 max-h-40 overflow-y-auto"></div>
      </div>

      <!-- Add Shift Form -->
      <div class="border-t border-violet-100 pt-4">
        <h3 class="text-sm font-semibold text-violet-900 mb-3">Thêm ca mới</h3>
        <div class="grid grid-cols-2 gap-3 mb-3">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Thứ <span class="text-red-500">*</span></label>
            <select id="shiftThu" class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
              <option value="2">Thứ 2</option>
              <option value="3">Thứ 3</option>
              <option value="4">Thứ 4</option>
              <option value="5">Thứ 5</option>
              <option value="6">Thứ 6</option>
              <option value="7">Thứ 7</option>
              <option value="8">Chủ nhật</option>
            </select>
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Giờ bắt đầu <span class="text-red-500">*</span></label>
            <input type="time" id="shiftGioBatDau" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Giờ kết thúc <span class="text-red-500">*</span></label>
            <input type="time" id="shiftGioKetThuc" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Ghi chú</label>
            <input type="text" id="shiftGhiChu" placeholder="Ví dụ: Ca sáng" class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          </div>
        </div>
        <div id="shiftError" class="hidden mb-3 p-2 text-xs text-red-600 bg-red-50 rounded"></div>
        <button onclick="addShift()" class="w-full h-10 rounded-xl bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 transition-all shadow-md shadow-violet-100">
          Thêm ca làm
        </button>
      </div>
    </div>
  </div>
</div>

<!-- Staff Modal -->
<div id="staffModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeStaffModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-violet-50">
      <h2 id="staffModalTitle" class="text-base font-semibold text-violet-950">Thêm nhân viên</h2>
      <button onclick="closeStaffModal()" class="p-1.5 rounded-lg hover:bg-violet-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="staffForm" onsubmit="handleStaffSubmit(event)" class="px-6 py-4 flex flex-col gap-4">
      <input type="hidden" id="staffEditId" value="">
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-violet-900">Họ và tên <span class="text-red-500">*</span></label>
          <input type="text" id="staffName" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-violet-900">Tên đăng nhập <span class="text-red-500">*</span></label>
          <input type="text" id="staffUsername" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
        </div>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-violet-900">Vai trò <span class="text-red-500">*</span></label>
        <select id="staffRole" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          <option value="4">Lễ tân</option>
          <option value="5">Bảo vệ</option>
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-violet-900">Email <span class="text-red-500">*</span></label>
        <input type="email" id="staffEmail" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-violet-900">Điện thoại</label>
          <input type="tel" id="staffPhone" class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-violet-900">Mật khẩu <span class="text-red-500">*</span></label>
          <div class="relative flex items-center">
            <input type="password" id="staffPassword" placeholder="••••••••" required class="h-9 pl-3 pr-10 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none w-full">
            <button type="button" onclick="togglePasswordVisibility()" class="absolute right-3 text-zinc-400 hover:text-zinc-650 focus:outline-none flex items-center">
              <span id="passwordEyeIcon" class="material-symbols-outlined text-[18px]">visibility</span>
            </button>
          </div>
        </div>
      </div>

      <div class="flex justify-end gap-2 mt-3 pt-4 border-t border-violet-50">
        <button type="button" onclick="closeScheduleShiftModal()"
                class="h-9 px-4 rounded-lg border border-violet-100 text-sm font-semibold hover:bg-violet-50 text-zinc-650 transition-colors">Hủy</button>
        <button type="submit"
                class="h-9 px-5 rounded-lg bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 shadow shadow-violet-200 transition-colors">Lưu thông tin</button>
      </div>
    </form>
  </div>
</div>

<!-- Trash Bin Modal -->
<div id="trashBinModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeTrashBinModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[640px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-violet-50">
      <h2 class="text-base font-semibold text-violet-950 flex items-center gap-2">
        <span class="material-symbols-outlined text-[20px] text-zinc-500">delete</span>
        Thùng rác nhân viên
      </h2>
      <button onclick="closeTrashBinModal()" class="p-1.5 rounded-lg hover:bg-violet-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 max-h-[400px] overflow-y-auto">
      <table class="w-full text-sm">
        <thead class="bg-zinc-50 border-b border-zinc-100">
          <tr>
            <th class="px-3 py-2.5 text-left font-semibold text-zinc-700 text-xs">Thành viên</th>
            <th class="px-3 py-2.5 text-left font-semibold text-zinc-700 text-xs">Vai trò</th>
            <th class="px-3 py-2.5 text-left font-semibold text-zinc-700 text-xs">Điện thoại</th>
            <th class="px-3 py-2.5 class text-right font-semibold text-zinc-700 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody id="trashBinBody" class="divide-y divide-zinc-50">
          <!-- Populated by JS -->
        </tbody>
      </table>
      <div id="trashBinEmptyState" class="hidden flex flex-col items-center justify-center py-8 text-center">
        <span class="material-symbols-outlined text-[36px] text-zinc-350 mb-1">delete_outline</span>
        <p class="text-zinc-500 text-xs font-medium">Thùng rác trống</p>
      </div>
    </div>
  </div>
</div>

<script>
// Context path initialized server-side (avoids JSP EL conflicts inside JS template literals)
var _ctxPath = '<%=request.getContextPath()%>';
var currentSwapFilter = 'all';

function showNotification(type, message) {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'fixed top-4 right-4 z-[100] flex flex-col gap-2 max-w-sm w-full pointer-events-none';
        document.body.appendChild(container);
    }
    
    const toast = document.createElement('div');
    toast.className = `p-4 rounded-xl shadow-lg border text-sm flex items-start gap-3 animate-fade-in-up pointer-events-auto transition-all duration-300 transform translate-x-0`;
    
    let icon = 'info';
    let bgColor = 'bg-white';
    let borderColor = 'border-violet-100';
    let textColor = 'text-violet-900';
    let iconColor = 'text-violet-600';
    
    if (type === 'success') {
        icon = 'check_circle';
        bgColor = 'bg-green-50';
        borderColor = 'border-green-200';
        textColor = 'text-green-900';
        iconColor = 'text-green-600';
    } else if (type === 'error') {
        icon = 'error';
        bgColor = 'bg-red-50';
        borderColor = 'border-red-200';
        textColor = 'text-red-900';
        iconColor = 'text-red-600';
    }
    
    toast.className += ` ${bgColor} ${borderColor} ${textColor}`;
    
    toast.innerHTML = `
        <span class="material-symbols-outlined \${iconColor} shrink-0">\${icon}</span>
        <div class="flex-1">
            <span class="font-bold block">\${type === 'success' ? 'Thành công' : 'Thất bại'}</span>
            <span class="leading-normal block mt-0.5">\${message}</span>
        </div>
        <button onclick="this.parentElement.remove()" class="text-zinc-400 hover:text-zinc-700 shrink-0"><span class="material-symbols-outlined text-[18px]">close</span></button>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100px)';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

let staffList = [];

// Load staff list on page load
async function loadStaffList() {
    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su?action=list');
        if (response.ok) {
            staffList = await response.json();
            renderStaff();
        } else {
            console.error('Failed to load staff list');
        }
    } catch (error) {
        console.error('Error loading staff:', error);
    }
}

function renderStaff() {
    const staffBody = document.getElementById('staffBody');
    if (!staffBody) return;
    document.getElementById('staffCountDisplay').innerText = staffList.length;

    staffBody.innerHTML = staffList.map(s => `
        <tr class="hover:bg-violet-50/35 transition-colors">
            <td class="px-4 py-4">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-violet-100 text-violet-700 flex items-center justify-center shrink-0 font-bold text-xs">\${s.initial}</div>
                    <div>
                        <p class="font-bold text-violet-950">\${s.name}</p>
                        <p class="text-[10px] text-violet-400">\${s.username}</p>
                    </div>
                </div>
            </td>
            <td class="px-4 py-4 text-xs font-semibold text-violet-700">\${s.VaiTro}</td>
            <td class="px-4 py-4 text-xs text-zinc-500">\${s.phone}</td>
            <td class="px-4 py-4"><span class="badge \${s.status == 'Đang làm' ? 'badge-green' : 'badge-red'}">\${s.status}</span></td>
            <td class="px-4 py-4 text-right flex items-center justify-end gap-1.5">
                <button onclick="editStaff('\${s.id}')" title="Chỉnh sửa" class="p-1.5 rounded-lg hover:bg-violet-50 text-blue-650">
                    <span class="material-symbols-outlined text-[18px]">edit</span>
                </button>
                <button onclick="manageShifts('\${s.id}', '\${s.name}')" title="Quản lý ca làm" class="p-1.5 rounded-lg hover:bg-violet-50 text-violet-600">
                    <span class="material-symbols-outlined text-[18px]">schedule</span>
                </button>
                <button onclick="toggleLock('\${s.id}', \${s.status == 'Đang làm'})" title="\${s.status == 'Đang làm' ? 'Khóa' : 'Mở khóa'}" class="p-1.5 rounded-lg hover:bg-violet-50 \${s.status == 'Đang làm' ? 'text-amber-600' : 'text-green-650'}">
                    <span class="material-symbols-outlined text-[18px]">\${s.status == 'Đang làm' ? 'lock' : 'lock_open'}</span>
                </button>
                <button onclick="deleteStaff('\${s.id}')" title="Xóa" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500">
                    <span class="material-symbols-outlined text-[18px]">person_remove</span>
                </button>
            </td>
        </tr>
    `).join('');
}

// ==================== Shift Management ====================

let currentShiftStaffId = null;
let currentShifts = [];

function openShiftModal(staffId, staffName) {
    currentShiftStaffId = staffId;
    document.getElementById('shiftStaffName').textContent = staffName;
    document.getElementById('shiftModal').classList.remove('hidden');
    document.getElementById('shiftError').classList.add('hidden');

    // Reset form
    document.getElementById('shiftThu').value = '2';
    document.getElementById('shiftGioBatDau').value = '';
    document.getElementById('shiftGioKetThuc').value = '';
    document.getElementById('shiftGhiChu').value = '';

    loadShifts();
}

function closeShiftModal() {
    document.getElementById('shiftModal').classList.add('hidden');
    currentShiftStaffId = null;
}

async function loadShifts() {
    if (!currentShiftStaffId) return;

    try {
        // Load all shifts and filter by staffId on client side
        const response = await fetch(_ctxPath + '/manager/ca-lam?format=json');
        if (response.ok) {
            const data = await response.json();
            // Filter shifts for current staff
            currentShifts = data.shifts.filter(s => s.accountId == currentShiftStaffId);
            // Build full staff list
            staffListFull = data.staffs ? data.staffs.map(s => ({
                id: s.accountId,
                username: s.username,
                fullName: s.fullName || s.username,
                roleId: s.roleId,
                roleName: s.roleId == 4 ? 'Lễ tân' : (s.roleId == 5 ? 'Bảo vệ' : 'Nhân viên')
            })) : [];
            renderShifts();
        } else {
            console.error('Failed to load shifts');
            document.getElementById('shiftsContainer').innerHTML = '<p class="text-red-500 text-xs">Lỗi tải ca làm</p>';
        }
    } catch (error) {
        console.error('Error loading shifts:', error);
        document.getElementById('shiftsContainer').innerHTML = '<p class="text-red-500 text-xs">Lỗi kết nối</p>';
    }
}

function renderShifts() {
    const container = document.getElementById('shiftsContainer');
    if (currentShifts.length === 0) {
        container.innerHTML = '<p class="text-zinc-500 text-xs">Chưa có ca làm định kỳ</p>';
        return;
    }

    const thuNames = {2:'Thứ 2',3:'Thứ 3',4:'Thứ 4',5:'Thứ 5',6:'Thứ 6',7:'Thứ 7',8:'Chủ nhật'};

    container.innerHTML = currentShifts.map((shift, idx) => `
        <div class="flex items-center justify-between p-2 bg-violet-50 rounded-lg">
            <div>
                <span class="text-xs font-semibold text-violet-900">\${thuNames[shift.thu]}</span>
                <span class="text-xs text-violet-600 ml-2">\${shift.gioBatDau} - \${shift.gioKetThuc}</span>
                \${shift.ghiChu ? '<span class="text-xs text-zinc-500 block">' + shift.ghiChu + '</span>' : ''}
            </div>
            <button onclick="deleteShift(\${shift.thu})" class="p-1 rounded hover:bg-red-100 text-red-500">
                <span class="material-symbols-outlined text-[16px]">delete</span>
            </button>
        </div>
    `).join('');
}

async function addShift() {
    if (!currentShiftStaffId) return;

    const thu = document.getElementById('shiftThu').value;
    const gioBatDau = document.getElementById('shiftGioBatDau').value;
    const gioKetThuc = document.getElementById('shiftGioKetThuc').value;
    const ghiChu = document.getElementById('shiftGhiChu').value;
    const errorDiv = document.getElementById('shiftError');

    if (!gioBatDau || !gioKetThuc) {
        errorDiv.textContent = 'Vui lòng chọn giờ bắt đầu và kết thúc';
        errorDiv.classList.remove('hidden');
        return;
    }

    if (gioBatDau >= gioKetThuc) {
        errorDiv.textContent = 'Giờ kết thúc phải sau giờ bắt đầu';
        errorDiv.classList.remove('hidden');
        return;
    }

    try {
        const params = new URLSearchParams();
        params.append('action', 'addShift');
        params.append('accountId', currentShiftStaffId);
        params.append('thu', thu);
        params.append('gioBatDau', gioBatDau);
        params.append('gioKetThuc', gioKetThuc);
        params.append('ghiChu', ghiChu);

        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.redirected) {
            window.location.href = response.url;
            return;
        }

        if (response.ok) {
            closeShiftModal();
            loadShifts();
            // Reload page to show success
            setTimeout(() => window.location.reload(), 500);
        } else {
            errorDiv.textContent = 'Thêm ca thất bại';
            errorDiv.classList.remove('hidden');
        }
    } catch (error) {
        console.error('Error adding shift:', error);
        errorDiv.textContent = 'Lỗi kết nối';
        errorDiv.classList.remove('hidden');
    }
}

async function deleteShift(thu) {
    if (!confirm('Xóa ca làm thứ ' + thu + '?')) return;

    try {
        const params = new URLSearchParams();
        params.append('action', 'deleteShift');
        params.append('accountId', currentShiftStaffId);
        params.append('thu', thu);

        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.redirected) {
            window.location.href = response.url;
            return;
        }

        loadShifts();
        setTimeout(() => window.location.reload(), 500);
    } catch (error) {
        console.error('Error deleting shift:', error);
    }
}

function manageShifts(id, name) {
    openShiftModal(id, name);
}

// ==================== Staff CRUD ====================

function openAddStaff() {
    document.getElementById('staffForm').reset();
    document.getElementById('staffModalTitle').innerText = 'Thêm nhân viên mới';
    document.getElementById('staffEditId').value = '';
    document.getElementById('staffUsername').disabled = false;
    document.getElementById('staffPassword').required = true;
    document.getElementById('staffModal').classList.remove('hidden');
}

function editStaff(id) {
    const s = staffList.find(x => x.id == id);
    if (!s) return;
    document.getElementById('staffModalTitle').innerText = 'Chỉnh sửa tài khoản nhân viên';
    document.getElementById('staffEditId').value = s.id;
    document.getElementById('staffName').value = s.name;
    document.getElementById('staffUsername').value = s.username;
    document.getElementById('staffUsername').disabled = true;
    document.getElementById('staffEmail').value = s.email;
    document.getElementById('staffPhone').value = s.phone;
    document.getElementById('staffModal').classList.remove('hidden');
}

function closeStaffModal() { document.getElementById('staffModal').classList.add('hidden'); }

function togglePasswordVisibility() {
    const pwdInput = document.getElementById('staffPassword');
    const eyeIcon = document.getElementById('passwordEyeIcon');
    if (pwdInput && eyeIcon) {
        pwdInput.type = pwdInput.type === 'password' ? 'text' : 'password';
        eyeIcon.textContent = pwdInput.type === 'password' ? 'visibility' : 'visibility_off';
    }
}

async function handleStaffSubmit(e) {
    e.preventDefault();
    const editId = document.getElementById('staffEditId').value;
    const params = new URLSearchParams();
    params.append('action', editId ? 'update' : 'add');
    if (editId) {
        params.append('accountId', editId);
        params.append('isLocked', 'false'); // placeholder
    } else {
        params.append('username', document.getElementById('staffUsername').value);
    }
    params.append('fullName', document.getElementById('staffName').value);
    params.append('email', document.getElementById('staffEmail').value);
    params.append('phoneNumber', document.getElementById('staffPhone').value);
    params.append('roleId', document.getElementById('staffRole').value);
    params.append('password', document.getElementById('staffPassword').value);

    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.redirected) {
            window.location.href = response.url;
            return;
        }

        const result = await response.text();
        console.log('Submit result:', result);
        window.location.reload();
    } catch (error) {
        console.error('Error submitting staff:', error);
    }
}

async function deleteStaff(id) {
    if (confirm("Xóa nhân viên này? Nhân viên sẽ bị xóa mềm và đưa vào thùng rác.")) {
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', id);

        try {
            const response = await fetch(_ctxPath + '/manager/nhan-su', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: params
            });
            if (response.redirected) {
                window.location.href = response.url;
            } else {
                window.location.reload();
            }
        } catch (error) {
            console.error('Error deleting staff:', error);
        }
    }
}

function openTrashBinModal() {
    document.getElementById('trashBinModal').classList.remove('hidden');
    loadDeletedStaffList();
}

function closeTrashBinModal() {
    document.getElementById('trashBinModal').classList.add('hidden');
}

async function loadDeletedStaffList() {
    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su?action=deletedList');
        if (response.ok) {
            const list = await response.json();
            renderDeletedStaff(list);
        } else {
            console.error('Failed to load deleted staff list');
        }
    } catch (error) {
        console.error('Error loading deleted staff:', error);
    }
}

function renderDeletedStaff(list) {
    const body = document.getElementById('trashBinBody');
    const emptyState = document.getElementById('trashBinEmptyState');
    if (!body) return;

    if (list.length === 0) {
        body.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
    }
    emptyState.classList.add('hidden');

    body.innerHTML = list.map(s => `
        <tr class="hover:bg-zinc-50 transition-colors">
            <td class="px-3 py-3">
                <div class="flex items-center gap-3">
                    <div class="w-7 h-7 rounded-full bg-zinc-100 text-zinc-650 flex items-center justify-center font-bold text-xs shrink-0">\${s.initial}</div>
                    <div>
                        <p class="font-semibold text-zinc-800">\${s.name}</p>
                        <p class="text-[10px] text-zinc-400">\${s.username}</p>
                    </div>
                </div>
            </td>
            <td class="px-3 py-3 text-xs font-medium text-zinc-600">\${s.VaiTro}</td>
            <td class="px-3 py-3 text-xs text-zinc-500">\${s.phone}</td>
            <td class="px-3 py-3 text-right flex items-center justify-end gap-2">
                <button onclick="restoreStaff('\${s.id}')" title="Khôi phục" class="px-2.5 py-1 text-[11px] font-bold text-green-750 bg-green-50 hover:bg-green-100 rounded-lg transition-all">
                    Khôi phục
                </button>
                <button onclick="permanentDeleteStaff('\${s.id}')" title="Xác nhận xóa" class="px-2.5 py-1 text-[11px] font-bold text-red-700 bg-red-50 hover:bg-red-100 rounded-lg transition-all">
                    Xác nhận xóa
                </button>
            </td>
        </tr>
    `).join('');
}

async function restoreStaff(id) {
    if (!confirm("Bạn có chắc chắn muốn khôi phục nhân viên này?")) return;
    const params = new URLSearchParams();
    params.append('action', 'restore');
    params.append('id', id);

    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });
        if (response.redirected) {
            window.location.href = response.url;
        } else {
            window.location.reload();
        }
    } catch (error) {
        console.error('Error restoring staff:', error);
    }
}

async function permanentDeleteStaff(id) {
    if (!confirm("Bạn có chắc chắn muốn XÓA VĨNH VIỄN nhân viên này? Lịch sử ca làm việc và các dữ liệu liên quan sẽ bị xóa sạch và không thể khôi phục.")) return;
    const params = new URLSearchParams();
    params.append('action', 'permanentDelete');
    params.append('id', id);

    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });
        if (response.redirected) {
            window.location.href = response.url;
        } else {
            window.location.reload();
        }
    } catch (error) {
        console.error('Error permanently deleting staff:', error);
    }
}

async function toggleLock(id, currentlyActive) {
    if (!confirm(currentlyActive ? "Khóa nhân viên này?" : "Mở khóa nhân viên?")) return;

    const params = new URLSearchParams();
    params.append('action', 'update');
    params.append('accountId', id);
    params.append('isLocked', currentlyActive ? 'true' : 'false');

    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });
        if (response.redirected) {
            window.location.href = response.url;
        } else {
            window.location.reload();
        }
    } catch (error) {
        console.error('Error toggling lock:', error);
    }
}

// ==================== VIEW MANAGEMENT ====================

let currentView = 'staff'; // staff, schedule, leave, swap
let staffListFull = []; // Full staff list
let leaveRequests = []; // Leave requests data
let scheduleShifts = []; // Schedule shifts data
let scheduleAvails = []; // Availability slots
let scheduleSwaps = []; // Swap requests
let scheduleAudits = []; // Audit logs
let scheduleBranches = []; // Branches list
let currentManagerCoSoId = ${sessionScope.user.coSoId != null ? sessionScope.user.coSoId : 'null'};

function switchView(viewName) {
    currentView = viewName;

    // Update tab active states
    document.querySelectorAll('.nav-link-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    document.getElementById('nav-' + viewName).classList.add('active');

    // Hide all views
    document.getElementById('viewStaffSection').classList.add('hidden');
    document.getElementById('viewScheduleSection').classList.add('hidden');
    document.getElementById('viewLeaveSection').classList.add('hidden');
    document.getElementById('viewSwapSection').classList.add('hidden');

    // Show selected view
    if (viewName === 'staff') {
        document.getElementById('viewStaffSection').classList.remove('hidden');
    } else if (viewName === 'schedule') {
        document.getElementById('viewScheduleSection').classList.remove('hidden');
        // Load schedule data if not loaded
        if (scheduleShifts.length === 0) {
            loadScheduleData();
        } else {
            renderCalendar();
        }
    } else if (viewName === 'leave') {
        document.getElementById('viewLeaveSection').classList.remove('hidden');
        // Load leave requests if not loaded
        if (leaveRequests.length === 0) {
            loadLeaveRequests();
        }
    } else if (viewName === 'swap') {
        document.getElementById('viewSwapSection').classList.remove('hidden');
        if (scheduleShifts.length === 0) {
            loadScheduleData().then(() => renderSwapTable());
        } else {
            renderSwapTable();
        }
    }
}

// ==================== SCHEDULE VIEW (Quản lý ca làm) ====================

async function loadScheduleData() {
    try {
        // Load shifts and staffs via JSON endpoint
        const response = await fetch('${pageContext.request.contextPath}/manager/ca-lam?format=json');
        if (response.ok) {
            const data = await response.json();
            scheduleShifts = data.shifts || [];
            scheduleAvails = data.avails || [];
            scheduleSwaps = data.swaps || [];
            scheduleAudits = data.audits || [];
            scheduleBranches = data.branches || [];
            staffListFull = data.staffs ? data.staffs.map(s => ({
                id: s.accountId,
                username: s.username,
                fullName: s.fullName || s.username,
                roleId: s.roleId,
                roleName: s.roleId == 4 ? 'Lễ tân' : (s.roleId == 5 ? 'Bảo vệ' : 'Nhân viên')
            })) : [];
            renderScheduleTable();
            if (currentView === 'schedule') {
                renderCalendar();
            } else if (currentView === 'swap') {
                renderSwapTable();
            }
        } else {
            console.error('Failed to load schedule data');
            showNotification('error', 'Lỗi tải dữ liệu ca làm từ server.');
        }
    } catch (error) {
        console.error('Error loading schedule data:', error);
        showNotification('error', 'Lỗi kết nối mạng khi tải dữ liệu ca làm.');
    }
}

function renderScheduleTable() {
    // Filter similar to CaLamViec.jsp
    const filtered = [...scheduleShifts];
    renderScheduleTableBody(filtered);
}

function renderScheduleTableBody(list) {
    const tbody = document.getElementById('scheduleShiftBody');
    const emptyState = document.getElementById('scheduleEmptyState');
    document.getElementById('shiftCountDisplay').innerText = list.length + ' ca';

    if (list.length == 0) {
        tbody.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
    }
    emptyState.classList.add('hidden');

    // Sort by date desc, time desc
    list.sort((a, b) => {
        if (a.ngayLam !== b.ngayLam) {
            return b.ngayLam.localeCompare(a.ngayLam);
        }
        return b.gioBatDau.localeCompare(a.gioBatDau);
    });

    tbody.innerHTML = list.map(s => {
        const staff = staffListFull.find(st => st.id === s.accountId);
        const staffName = staff ? staff.fullName : 'Nhân viên không tồn tại';
        const staffUsername = staff ? staff.username : 'N/A';
        const initial = staffName.substring(0, 1).toUpperCase();
        const statusWork = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
        const statusSched = getTrangThaiBadge(s.trangThai);
        const dateFormatted = formatDate(s.ngayLam);
        const timeFrame = formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc);

        return `
            <tr class="hover:bg-violet-50/35 transition-colors">
                <td class="px-5 py-4">
                    <div class="flex items-center gap-3">
                        <div class="w-8.5 h-8.5 rounded-full bg-violet-100 text-violet-700 flex items-center justify-center shrink-0 font-bold text-xs">\${initial}</div>
                        <div>
                            <p class="font-bold text-violet-950 leading-tight">\${staffName}</p>
                            <p class="text-[10px] text-violet-400 mt-0.5">\${staffUsername}</p>
                        </div>
                    </div>
                </td>
                <td class="px-5 py-4 text-xs font-semibold text-violet-700">\${s.tenCa || 'Tùy chỉnh'} / \${s.viTri || 'Lễ tân'}</td>
                <td class="px-5 py-4 text-xs font-medium text-zinc-700">\${dateFormatted}</td>
                <td class="px-5 py-4 text-xs font-bold text-violet-900">
                    \${timeFrame}
                    \${s.gioNghi > 0 ? `<span class="text-[10px] text-red-500 block font-semibold">Nghỉ: \${s.gioNghi}m</span>` : ''}
                </td>
                <td class="px-5 py-4">
                    <div class="flex flex-col gap-1">
                        <span class="badge \${statusSched.cssClass}">\${statusSched.label}</span>
                        <span class="badge \${statusWork.cssClass}">\${statusWork.label}</span>
                    </div>
                </td>
                <td class="px-5 py-4 text-xs text-zinc-500 max-w-[200px] truncate" title="\${s.ghiChu || 'Không có ghi chú'}">\${s.ghiChu || '<span class="text-zinc-350 italic">Không có ghi chú</span>'}</td>
                <td class="px-5 py-4 text-right">
                    <div class="flex items-center justify-end gap-1">
                        <button onclick="editScheduleShift(\${s.caLamViecId})" title="Chỉnh sửa" class="p-1.5 rounded-lg hover:bg-violet-50 text-violet-600 transition-colors"><span class="material-symbols-outlined text-[18px]">edit</span></button>
                        <button onclick="deleteScheduleShift(\${s.caLamViecId})" title="Xóa" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500 transition-colors"><span class="material-symbols-outlined text-[18px]">delete</span></button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

// Schedule helpers
function formatDate(str) {
    if (!str) return '';
    const parts = str.split('-');
    if (parts.length !== 3) return str;
    return parts[2] + '/' + parts[1] + '/' + parts[0];
}

function formatTime(str) {
    if (!str) return '';
    const parts = str.split(':');
    if (parts.length < 2) return str;
    return parts[0] + ':' + parts[1];
}

function getShiftStatus(ngayLamStr, batDauStr, ketThucStr) {
    const now = new Date();
    const [y, m, d] = ngayLamStr.split('-').map(Number);
    const [sh, sm] = batDauStr.split(':').map(Number);
    const [eh, em] = ketThucStr.split(':').map(Number);
    
    const startDateTime = new Date(y, m - 1, d, sh, sm, 0);
    const endDateTime = new Date(y, m - 1, d, eh, em, 0);
    if (endDateTime < startDateTime) { endDateTime.setDate(endDateTime.getDate() + 1); }

    if (now < startDateTime) return { label: 'Sắp diễn ra', cssClass: 'badge-blue' };
    else if (now > endDateTime) return { label: 'Đã kết thúc', cssClass: 'badge-zinc' };
    else return { label: 'Đang diễn ra', cssClass: 'badge-green live-dot' };
}

function getTrangThaiBadge(trangThai) {
    if (trangThai === 'CheckedOut') return { label: 'Hoàn thành ca', cssClass: 'badge-zinc' };
    if (trangThai === 'CheckedIn') return { label: 'Đang làm việc', cssClass: 'badge-green live-dot' };
    if (trangThai === 'Confirmed') return { label: 'Đã xác nhận', cssClass: 'badge-green' };
    if (trangThai === 'Published') return { label: 'Chưa xác nhận', cssClass: 'badge-blue' };
    return { label: 'Nháp (Draft)', cssClass: 'badge-yellow' };
}

// ============================================
// AJAX & INLINE CONFIGURATION LOGIC (NhanSu.jsp)
// ============================================

function applyShiftTemplate() {
    const template = document.getElementById('scheduleShiftTemplate').value;
    const startInput = document.getElementById('scheduleStartTime');
    const endInput = document.getElementById('scheduleEndTime');
    const breakInput = document.getElementById('scheduleShiftGioNghi');

    if (template === 'Ca sáng') {
        startInput.value = '06:00';
        endInput.value = '14:00';
        breakInput.value = '0';
    } else if (template === 'Ca chiều') {
        startInput.value = '14:00';
        endInput.value = '22:00';
        breakInput.value = '0';
    } else if (template === 'Ca đêm') {
        startInput.value = '22:00';
        endInput.value = '06:00';
        breakInput.value = '0';
    }
    triggerRealtimeValidation();
}

// Generate Weekday Checkboxes dynamically based on scheduleShiftDate selection
function updateWeekDays() {
  const dateVal = document.getElementById('scheduleShiftDate').value;
  if (!dateVal) return;
  
  const d = new Date(dateVal);
  const day = d.getDay();
  // Get Monday of the selected date's week
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(d.setDate(diff));
  
  const container = document.getElementById('weekDaysCheckboxes');
  container.innerHTML = '';
  
  const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  const editId = document.getElementById('scheduleShiftEditId').value;
  
  for (let i = 0; i < 7; i++) {
    const current = new Date(monday);
    current.setDate(monday.getDate() + i);
    
    const year = current.getFullYear();
    const month = String(current.getMonth() + 1).padStart(2, '0');
    const dateNum = String(current.getDate()).padStart(2, '0');
    const dateStr = `\${year}-\${month}-\${dateNum}`;
    const displayDate = `\${dateNum}/\${month}`;
    
    const isToday = (dateStr === new Date().toISOString().split('T')[0]);
    
    let isChecked = true;
    let isDisabled = false;
    
    if (editId) {
      // In edit mode, check only the exact shift date
      isChecked = (dateStr === dateVal);
      isDisabled = !isChecked;
    }
    
    const checkboxId = `day_\${i}`;
    const wrapper = document.createElement('label');
    wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border cursor-pointer select-none transition-all text-center bg-white border-zinc-200 hover:border-violet-300 hover:bg-violet-50/10`;
    
    wrapper.innerHTML = `
      <span class="text-[10px] font-bold text-zinc-500 uppercase tracking-wide">\${dayNames[i]}</span>
      <span class="text-sm font-extrabold text-zinc-800 my-1">\${displayDate}</span>
      <input type="checkbox" id="\${checkboxId}" value="\${dateStr}" \${isChecked ? 'checked' : ''} \${isDisabled ? 'disabled' : ''} onchange="updateCheckboxStyles(); triggerRealtimeValidation();"
             class="w-4 h-4 text-violet-600 rounded border-zinc-300 focus:ring-violet-500 cursor-pointer mt-1">
    `;
    container.appendChild(wrapper);
  }
  updateCheckboxStyles();
}

function selectAllWeekDays(checked) {
  const editId = document.getElementById('scheduleShiftEditId').value;
  if (editId) return;
  const checkboxes = document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]');
  checkboxes.forEach(cb => {
    cb.checked = checked;
  });
  updateCheckboxStyles();
  triggerRealtimeValidation();
}

function updateCheckboxStyles() {
  const checkboxes = document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]');
  checkboxes.forEach(cb => {
    const wrapper = cb.closest('label');
    if (cb.checked) {
      wrapper.classList.remove('bg-white', 'border-zinc-200', 'hover:bg-violet-50/10');
      wrapper.classList.add('bg-violet-100/40', 'border-violet-500', 'ring-2', 'ring-violet-400');
    } else {
      const dateStr = cb.value;
      const isToday = (dateStr === new Date().toISOString().split('T')[0]);
      wrapper.classList.remove('bg-violet-100/40', 'border-violet-500', 'ring-2', 'ring-violet-400');
      if (isToday) {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-violet-300 ring-1 ring-violet-300 cursor-pointer select-none transition-all text-center bg-violet-50/50`;
      } else {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-zinc-200 hover:border-violet-300 hover:bg-violet-50/10 cursor-pointer select-none transition-all text-center bg-white`;
      }
    }
  });
}

function calculateDurationAndOvertime() {
    const staffId = document.getElementById('scheduleShiftStaff').value;
    const startVal = document.getElementById('scheduleStartTime').value;
    const endVal = document.getElementById('scheduleEndTime').value;
    const breakVal = parseInt(document.getElementById('scheduleShiftGioNghi').value) || 0;
    
    const displayDiv = document.getElementById('scheduleShiftDurationDisplay');
    
    if (!startVal || !endVal) {
        displayDiv.innerHTML = '';
        displayDiv.classList.add('hidden');
        return;
    }

    const start = new Date(`2000-01-01T\${startVal}:00`);
    let end = new Date(`2000-01-01T\${endVal}:00`);
    if (end < start) end.setDate(end.getDate() + 1); // Overnight shift
    
    const diffMs = end - start;
    const diffMins = Math.floor(diffMs / 60000);
    const workMins = diffMins - breakVal;
    
    if (workMins <= 0) {
        displayDiv.innerHTML = `<div class="p-3 bg-red-50 text-red-800 rounded-xl text-sm border border-red-200">Giờ làm việc không hợp lệ (thời gian nghỉ quá lớn hoặc nhập sai giờ).</div>`;
        displayDiv.classList.remove('hidden');
        return;
    }

    const workHours = (workMins / 60).toFixed(1);
    let html = `<div class="p-3 bg-emerald-50 text-emerald-800 rounded-xl text-sm border border-emerald-200 flex items-center justify-between">
                  <span><strong>Tổng giờ làm một ca:</strong> \${workHours} giờ</span>
                  <span class="text-xs opacity-70">(Đã trừ \${breakVal} phút nghỉ)</span>
                </div>`;

    if (staffId) {
        const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
        let datesToCalculate = checkedCheckboxes.map(cb => cb.value);
        if (datesToCalculate.length === 0) {
            const referenceDate = document.getElementById('scheduleShiftDate').value;
            if (referenceDate) datesToCalculate.push(referenceDate);
        }
        
        if (datesToCalculate.length > 0) {
            const months = [...new Set(datesToCalculate.map(d => d.substring(0, 7)))];
            
            months.forEach(month => {
                let existingMins = 0;
                const editId = document.getElementById('scheduleShiftEditId').value;
                
                scheduleShifts.forEach(s => {
                    if (s.accountId == staffId && s.ngayLam.startsWith(month) && s.caLamViecId != editId) {
                        const sStart = new Date(`2000-01-01T\${s.gioBatDau}`);
                        let sEnd = new Date(`2000-01-01T\${s.gioKetThuc}`);
                        if (sEnd < sStart) sEnd.setDate(sEnd.getDate() + 1);
                        
                        let sDiffMins = Math.floor((sEnd - sStart) / 60000) - (s.gioNghi || 0);
                        existingMins += sDiffMins;
                    }
                });

                const newShiftsCountInMonth = datesToCalculate.filter(d => d.startsWith(month)).length;
                const totalMonthMins = existingMins + (newShiftsCountInMonth * workMins);
                const totalMonthHours = (totalMonthMins / 60).toFixed(1);
                
                if (totalMonthHours > 160) {
                    html += `<div class="mt-2 p-3 bg-amber-50 text-amber-800 rounded-xl text-sm border border-amber-200 flex gap-2 items-start">
                               <span class="material-symbols-outlined text-[18px]">warning</span>
                               <div>
                                 <strong>Cảnh báo vượt giờ:</strong> Nhân viên này sẽ đạt <strong>\${totalMonthHours}h</strong> trong tháng \${month} (vượt mức 160h quy định).
                               </div>
                             </div>`;
                } else {
                    html += `<div class="mt-1 text-[11px] text-zinc-500 text-right">Luỹ kế tháng \${month}: \${totalMonthHours}h / 160h</div>`;
                }
            });
        }
    }
    
    displayDiv.innerHTML = html;
    displayDiv.classList.remove('hidden');
}

let validationTimeout = null;
function triggerRealtimeValidation() {
    calculateDurationAndOvertime();
    clearTimeout(validationTimeout);
    validationTimeout = setTimeout(runRealtimeValidation, 300);
}

async function runRealtimeValidation() {
    const staffId = document.getElementById('scheduleShiftStaff').value;
    const gioBatDau = document.getElementById('scheduleStartTime').value;
    const gioKetThuc = document.getElementById('scheduleEndTime').value;
    const gioNghi = document.getElementById('scheduleShiftGioNghi').value || '0';
    const editId = document.getElementById('scheduleShiftEditId').value;
    
    const alertBox = document.getElementById('scheduleShiftAlertBox');
    const submitBtn = document.getElementById('btnSubmitShift');
    
    if (!staffId || !gioBatDau || !gioKetThuc) {
        alertBox.classList.add('hidden');
        if (submitBtn) submitBtn.disabled = false;
        return;
    }

    const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
    let datesToValidate = checkedCheckboxes.map(cb => cb.value);
    
    if (datesToValidate.length === 0) {
        const referenceDate = document.getElementById('scheduleShiftDate').value;
        if (referenceDate) datesToValidate.push(referenceDate);
    }
    
    if (datesToValidate.length === 0) {
        alertBox.classList.add('hidden');
        if (submitBtn) submitBtn.disabled = false;
        return;
    }

    try {
        const validationPromises = datesToValidate.map(date => {
            const url = `\${_ctxPath}/manager/ca-lam?action=validate&accountId=\${staffId}&ngayLam=\${date}&gioBatDau=\${gioBatDau}&gioKetThuc=\${gioKetThuc}&gioNghi=\${gioNghi}` + (editId ? `&caLamViecId=\${editId}` : '');
            return fetch(url).then(res => res.json());
        });

        const results = await Promise.all(validationPromises);
        
        let allErrors = [];
        let allWarnings = [];
        
        results.forEach((res, idx) => {
            const dateStr = datesToValidate[idx];
            const dateFormatted = formatDate(dateStr);
            if (!res.valid) {
                res.errors.forEach(err => {
                    allErrors.push(`[Ngày \${dateFormatted}]: \${err}`);
                });
            }
            if (res.warnings && res.warnings.length > 0) {
                res.warnings.forEach(warn => {
                    allWarnings.push(`[Ngày \${dateFormatted}]: \${warn}`);
                });
            }
        });

        alertBox.innerHTML = '';
        
        if (allErrors.length > 0) {
            alertBox.className = 'p-3 rounded-xl text-xs flex flex-col gap-1.5 bg-red-50 border border-red-200 text-red-750 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[16px]">cancel</span> Lỗi xung đột ca (Chặn lưu):</div><ul class="list-disc pl-5 space-y-0.5">';
            allErrors.forEach(err => { html += `<li>\${err}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            if (submitBtn) submitBtn.disabled = true;
        } else if (allWarnings.length > 0) {
            alertBox.className = 'p-3 rounded-xl text-xs flex flex-col gap-1.5 bg-amber-50 border border-amber-200 text-amber-700 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[16px]">warning</span> Cảnh báo lưu ý:</div><ul class="list-disc pl-5 space-y-0.5">';
            allWarnings.forEach(warn => { html += `<li>\${warn}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            if (submitBtn) submitBtn.disabled = false;
        } else {
            alertBox.classList.add('hidden');
            if (submitBtn) submitBtn.disabled = false;
        }
    } catch (err) {
        console.error('Validation API failed:', err);
    }
}

function resetForm() {
    document.getElementById('inlineScheduleShiftForm').reset();
    document.getElementById('scheduleShiftEditId').value = '';
    document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-violet-600 text-[22px]">calendar_month</span> Phân ca làm việc mới`;
    
    // Set default values
    document.getElementById('scheduleShiftDate').value = new Date().toISOString().split('T')[0];
    document.getElementById('scheduleShiftTemplate').value = 'Tùy chỉnh';
    document.getElementById('scheduleShiftViTri').value = 'Lễ tân';
    document.getElementById('scheduleShiftTrangThai').value = 'Published';
    document.getElementById('scheduleShiftGioNghi').value = '0';
    document.getElementById('scheduleChangeReason').value = '';
    document.getElementById('scheduleReasonContainer').classList.add('hidden');
    
    document.getElementById('scheduleShiftDurationDisplay').innerHTML = '';
    document.getElementById('scheduleShiftDurationDisplay').classList.add('hidden');
    document.getElementById('scheduleShiftAlertBox').innerHTML = '';
    document.getElementById('scheduleShiftAlertBox').classList.add('hidden');
    
    const submitBtn = document.getElementById('btnSubmitShift');
    if (submitBtn) submitBtn.disabled = false;
    
    if (document.getElementById('selectAllContainer')) {
        document.getElementById('selectAllContainer').classList.remove('hidden');
    }
    
    populateScheduleStaffDropdown(null);
    updateWeekDays();
}

function openAddScheduleShift() {
    resetForm();
    document.getElementById('inlineScheduleShiftForm').scrollIntoView({ behavior: 'smooth', block: 'center' });
}

function editScheduleShift(id) {
  const s = scheduleShifts.find(x => x.caLamViecId === id);
  if (!s) return;

  document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-violet-600 text-[22px]">edit_calendar</span> Chỉnh sửa ca làm việc`;
  
  document.getElementById('scheduleShiftEditId').value = s.caLamViecId;
  document.getElementById('scheduleShiftDate').value = s.ngayLam;
  document.getElementById('scheduleStartTime').value = formatTime(s.gioBatDau);
  document.getElementById('scheduleEndTime').value = formatTime(s.gioKetThuc);
  document.getElementById('scheduleShiftTemplate').value = s.tenCa || 'Tùy chỉnh';
  document.getElementById('scheduleShiftViTri').value = s.viTri || 'Lễ tân';
  document.getElementById('scheduleShiftGioNghi').value = s.gioNghi || 0;
  document.getElementById('scheduleShiftTrangThai').value = s.trangThai || 'Draft';
  document.getElementById('scheduleNotes').value = s.ghiChu || '';
  
  const submitBtn = document.getElementById('btnSubmitShift');
  if (submitBtn) submitBtn.disabled = false;

  populateScheduleStaffDropdown(s.accountId);
  
  if (document.getElementById('selectAllContainer')) {
      document.getElementById('selectAllContainer').classList.add('hidden');
  }
  
  document.getElementById('scheduleChangeReason').value = '';
  if (s.trangThai === 'Published') {
      document.getElementById('scheduleReasonContainer').classList.remove('hidden');
  } else {
      document.getElementById('scheduleReasonContainer').classList.add('hidden');
  }
  
  // Update weekdays list and check ONLY the current shift's date
  updateWeekDays();
  
  // Scroll to form smoothly
  document.getElementById('inlineScheduleShiftForm').scrollIntoView({ behavior: 'smooth', block: 'center' });
  triggerRealtimeValidation();
}

async function deleteScheduleShift(id) {
    const s = scheduleShifts.find(x => x.caLamViecId === id);
    if (!s) return;
    
    let reason = "";
    if (s.trangThai === 'Published') {
        reason = prompt("Ca làm này đã được công bố. Vui lòng nhập lý do thay đổi/xóa ca (bắt buộc):");
        if (reason === null) return; // Cancelled
        reason = reason.trim();
        if (!reason) {
            alert("Lý do thay đổi là bắt buộc đối với ca làm đã công bố!");
            return;
        }
    } else {
        if (!confirm("Xóa ca làm việc này? Hành động này không thể hoàn tác.")) return;
    }

    const params = new URLSearchParams();
    params.append('action', 'delete');
    params.append('format', 'json');
    params.append('id', id);
    if (reason) {
        params.append('reason', reason);
    }

    try {
        const response = await fetch(_ctxPath + '/manager/ca-lam', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Xóa ca làm việc thành công!');
                await loadScheduleData();
            } else {
                showNotification('error', res.error || 'Lỗi khi xóa ca làm.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi xóa ca làm.');
        }
    } catch (error) {
        console.error('Error deleting shift:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

function populateScheduleStaffDropdown(selectedId) {
    const select = document.getElementById('scheduleShiftStaff');
    select.innerHTML = '<option value="">-- Chọn nhân viên --</option>';
    staffListFull.forEach(st => {
        const opt = document.createElement('option');
        opt.value = st.id;
        opt.textContent = `[\${st.roleName}] \${st.fullName} (\${st.username})`;
        if (selectedId && st.id === selectedId) {
            opt.selected = true;
        }
        select.appendChild(opt);
    });
}

function populateScheduleBranchDropdown(selectedId) {
    // Keep reference coSoId
    const select = document.getElementById('scheduleShiftBranch');
    if (!select) return;
    select.value = selectedId || currentManagerCoSoId || "${sessionScope.user.coSoId}";
}

// Convert date string yyyy-MM-dd to Vietnamese "thứ X ngày dd/MM/yyyy"
function getWeekdayAndDateStr(dateStr) {
  const [y, m, d] = dateStr.split('-').map(Number);
  const dateObj = new Date(y, m - 1, d);
  const dayIdx = dateObj.getDay();
  const dayNames = ['chủ Nhật', 'thứ Hai', 'thứ Ba', 'thứ Tư', 'thứ Năm', 'thứ Sáu', 'thứ Bảy'];
  const formattedDate = `\${String(d).padStart(2, '0')}/\${String(m).padStart(2, '0')}/\${y}`;
  return `\${dayNames[dayIdx]} ngày \${formattedDate}`;
}

// Display the required Success Result details banner
function showSuccessBanner(staffName, startTime, endTime, datesAndWeekdays) {
  const banner = document.getElementById('successResultBanner');
  const bannerText = document.getElementById('successBannerText');
  
  bannerText.innerHTML = `Nhân viên <strong>\${staffName}</strong> đã được phân ca làm từ <strong>\${startTime}</strong> tới <strong>\${endTime}</strong> ngày và thứ <strong>\${datesAndWeekdays}</strong> của nhân viên này làm việc.`;
  
  banner.classList.remove('hidden');
}

function scrollToCalendar() {
  switchScheduleView('calendar');
  setTimeout(() => {
    const target = document.getElementById('calendarView');
    if (target) {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }, 150);
}

async function handleInlineScheduleShiftSubmit(e) {
  e.preventDefault();
  
  const submitBtn = document.getElementById('btnSubmitShift');
  if (submitBtn.disabled) {
    alert("Đang có lỗi xung đột ca hoặc dữ liệu không hợp lệ. Vui lòng kiểm tra lại!");
    return;
  }
  
  const staffId = document.getElementById('scheduleShiftStaff').value;
  const startTime = document.getElementById('scheduleStartTime').value;
  const endTime = document.getElementById('scheduleEndTime').value;
  const editId = document.getElementById('scheduleShiftEditId').value;
  const coSoId = document.getElementById('scheduleShiftBranch').value;
  const ghiChu = document.getElementById('scheduleNotes').value;
  const tenCa = document.getElementById('scheduleShiftTemplate').value;
  const viTri = document.getElementById('scheduleShiftViTri').value;
  const trangThai = document.getElementById('scheduleShiftTrangThai').value;
  const gioNghi = document.getElementById('scheduleShiftGioNghi').value || '0';
  
  let reason = "";
  const reasonContainer = document.getElementById('scheduleReasonContainer');
  if (reasonContainer && !reasonContainer.classList.contains('hidden')) {
      reason = document.getElementById('scheduleChangeReason').value.trim();
      if (!reason) {
          alert("Vui lòng nhập lý do thay đổi lịch đã công bố!");
          document.getElementById('scheduleChangeReason').focus();
          return;
      }
  }
  
  if (!staffId) {
    alert("Vui lòng chọn nhân viên!");
    return;
  }
  if (!startTime || !endTime) {
    alert("Vui lòng nhập giờ bắt đầu và giờ kết thúc!");
    return;
  }
  
  const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
  
  if (!editId && checkedCheckboxes.length === 0) {
    alert("Vui lòng chọn ít nhất một ngày làm việc trong tuần!");
    return;
  }
  
  const originalBtnText = submitBtn.innerHTML;
  submitBtn.disabled = true;
  submitBtn.innerHTML = `
    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg> Đang lưu...
  `;
  
  try {
    const staffSelect = document.getElementById('scheduleShiftStaff');
    const staffName = staffSelect.options[staffSelect.selectedIndex].text.split('] ')[1] || staffSelect.options[staffSelect.selectedIndex].text;
    
    if (editId) {
      // Edit Mode (single day)
      const dateToSave = checkedCheckboxes.length > 0 ? checkedCheckboxes[0].value : document.getElementById('scheduleShiftDate').value;
      
      const params = new URLSearchParams();
      params.append('action', 'update');
      params.append('format', 'json');
      params.append('caLamViecId', editId);
      params.append('accountId', staffId);
      params.append('coSoId', coSoId);
      params.append('ngayLam', dateToSave);
      params.append('gioBatDau', startTime);
      params.append('gioKetThuc', endTime);
      params.append('tenCa', tenCa);
      params.append('viTri', viTri);
      params.append('trangThai', trangThai);
      params.append('gioNghi', gioNghi);
      params.append('ghiChu', ghiChu);
      if (reason) params.append('reason', reason);
      
      const response = await fetch(`\${_ctxPath}/manager/ca-lam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: params.toString()
      });
      
      if (response.ok) {
        const res = await response.json();
        if (res.success) {
          showNotification('success', 'Đã cập nhật ca làm việc thành công!');
          
          const weekdayAndDateStr = getWeekdayAndDateStr(dateToSave);
          showSuccessBanner(staffName, startTime, endTime, weekdayAndDateStr);
          
          await loadScheduleData();
          resetForm();
          scrollToCalendar();
        } else {
          showNotification('error', res.error || 'Cập nhật thất bại');
        }
      } else {
        showNotification('error', 'Lỗi kết nối máy chủ');
      }
    } else {
      // Add Mode (multiple days in parallel)
      const promises = checkedCheckboxes.map(cb => {
        const dateToSave = cb.value;
        const params = new URLSearchParams();
        params.append('action', 'add');
        params.append('format', 'json');
        params.append('accountId', staffId);
        params.append('coSoId', coSoId);
        params.append('ngayLam', dateToSave);
        params.append('gioBatDau', startTime);
        params.append('gioKetThuc', endTime);
        params.append('tenCa', tenCa);
        params.append('viTri', viTri);
        params.append('trangThai', trangThai);
        params.append('gioNghi', gioNghi);
        params.append('ghiChu', ghiChu);
        
        return fetch(`\${_ctxPath}/manager/ca-lam`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
          body: params.toString()
        }).then(res => res.json());
      });
      
      const results = await Promise.all(promises);
      
      const successes = results.filter(r => r.success);
      const errors = results.filter(r => !r.success);
      
      if (successes.length > 0) {
        showNotification('success', `Đã phân ca thành công cho \${successes.length} ngày!`);
        
        const dateStrings = checkedCheckboxes.map(cb => getWeekdayAndDateStr(cb.value));
        const datesFormattedText = dateStrings.join(', ');
        
        showSuccessBanner(staffName, startTime, endTime, datesFormattedText);
        
        await loadScheduleData();
        resetForm();
        scrollToCalendar();
      }
      
      if (errors.length > 0) {
        const errorMsgs = [...new Set(errors.map(e => e.error))].join('; ');
        showNotification('error', `Có \${errors.length} lỗi xảy ra: \${errorMsgs}`);
      }
    }
  } catch (err) {
    console.error(err);
    showNotification('error', 'Đã xảy ra lỗi trong quá trình xử lý');
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerHTML = originalBtnText;
  }
}


function switchScheduleView(viewMode) {
    const tableView = document.getElementById('tableView');
    const calendarView = document.getElementById('calendarView');
    const tableBtn = document.getElementById('viewTableBtn');
    const calendarBtn = document.getElementById('viewCalendarBtn');

    if (viewMode == 'table') {
        tableView.classList.remove('hidden');
        calendarView.classList.add('hidden');
        tableBtn.classList.add('bg-white', 'text-violet-700', 'shadow-sm');
        tableBtn.classList.remove('text-violet-600', 'hover:text-violet-700');
        calendarBtn.classList.remove('bg-white', 'text-violet-700', 'shadow-sm');
        calendarBtn.classList.add('text-violet-600', 'hover:text-violet-700');
    } else if (viewMode == 'calendar') {
        tableView.classList.add('hidden');
        calendarView.classList.remove('hidden');
        calendarBtn.classList.add('bg-white', 'text-violet-700', 'shadow-sm');
        calendarBtn.classList.remove('text-violet-600', 'hover:text-violet-700');
        tableBtn.classList.remove('bg-white', 'text-violet-700', 'shadow-sm');
        tableBtn.classList.add('text-violet-600', 'hover:text-violet-700');
        renderCalendar();
    }
}

function toggleScheduleDateInputs() {
    const opt = document.getElementById('scheduleFilterDateOpt').value;
    const container = document.getElementById('scheduleDateInputs');
    if (opt === 'custom') {
        container.classList.remove('hidden');
    } else {
        container.classList.add('hidden');
        document.getElementById('scheduleFilterStartDate').value = '';
        document.getElementById('scheduleFilterEndDate').value = '';
    }
}

function filterScheduleShifts() {
    const searchName = document.getElementById('scheduleSearchName').value.trim().toLowerCase();
    const filterRole = document.getElementById('scheduleFilterRole').value;
    const dateOpt = document.getElementById('scheduleFilterDateOpt').value;
    const startDate = document.getElementById('scheduleFilterStartDate').value;
    const endDate = document.getElementById('scheduleFilterEndDate').value;

    const todayStr = new Date().toISOString().split('T')[0];
    let tomorrowStr = '';
    {
        const tom = new Date();
        tom.setDate(tom.getDate() + 1);
        tomorrowStr = tom.toISOString().split('T')[0];
    }

    const filtered = scheduleShifts.filter(s => {
        const staff = staffListFull.find(st => st.id === s.accountId);
        const staffName = staff ? staff.fullName.toLowerCase() : '';
        const staffUsername = staff ? staff.username.toLowerCase() : '';
        const staffRole = staff ? String(staff.roleId) : '';

        if (searchName && !staffName.includes(searchName) && !staffUsername.includes(searchName)) {
            return false;
        }
        if (filterRole && staffRole !== filterRole) {
            return false;
        }
        if (dateOpt === 'today' && s.ngayLam !== todayStr) {
            return false;
        }
        if (dateOpt === 'tomorrow' && s.ngayLam !== tomorrowStr) {
            return false;
        }
        if (dateOpt === 'custom') {
            if (startDate && s.ngayLam < startDate) return false;
            if (endDate && s.ngayLam > endDate) return false;
        }
        return true;
    });

    renderScheduleTableBody(filtered);
}

// Helper: get Monday of the week
function getMonday(date) {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    return new Date(d.setDate(diff));
}

// Calendar functions
let currentWeekStart = getMonday(new Date());

function changeWeek(direction) {
    currentWeekStart.setDate(currentWeekStart.getDate() + (direction * 7));
    renderCalendar();
}

function renderCalendar() {
    const grid = document.getElementById('calendarGrid');
    const weekRangeDisplay = document.getElementById('weekRangeDisplay');

    const weekEnd = new Date(currentWeekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);

    const formatDateVN = (date) => date.getDate() + '/' + (date.getMonth() + 1);
    weekRangeDisplay.textContent = formatDateVN(currentWeekStart) + ' - ' + formatDateVN(weekEnd);

    const days = [];
    for (let i = 0; i < 7; i++) {
        const dayDate = new Date(currentWeekStart);
        dayDate.setDate(dayDate.getDate() + i);
        days.push(dayDate);
    }

    const shiftsByDate = {};
    days.forEach(day => {
        const dateStr = day.toISOString().split('T')[0];
        shiftsByDate[dateStr] = scheduleShifts.filter(s => s.ngayLam === dateStr);
    });

    // Update week publish status badge
    const weekShifts = [];
    days.forEach(day => {
        const dateStr = day.toISOString().split('T')[0];
        const dayShifts = shiftsByDate[dateStr] || [];
        weekShifts.push(...dayShifts);
    });

    const badge = document.getElementById('weekPublishBadge');
    if (badge) {
        if (weekShifts.length === 0) {
            badge.textContent = 'Chưa xếp lịch';
            badge.className = 'badge badge-zinc';
        } else {
            const allPublished = weekShifts.every(s => s.isPublished);
            if (allPublished) {
                badge.textContent = 'Đã công bố';
                badge.className = 'badge badge-green';
            } else {
                badge.textContent = 'Chưa công bố (Nháp)';
                badge.className = 'badge badge-yellow';
            }
        }
    }

    let html = '<div class="grid grid-cols-7 gap-4">';

    days.forEach(day => {
        const dateStr = day.toISOString().split('T')[0];
        const dayShifts = shiftsByDate[dateStr] || [];
        const dayName = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][day.getDay() === 0 ? 6 : day.getDay() - 1];
        const dateNum = day.getDate();
        const isToday = dateStr === new Date().toISOString().split('T')[0];

        html += `
            <div class="flex flex-col gap-2 min-h-[400px] border border-violet-50 rounded-xl p-3 bg-violet-50/5">
                <div class="text-center pb-2 border-b border-violet-50">
                    <p class="text-xs font-semibold text-violet-600 uppercase">\${dayName}</p>
                    <p class="text-lg font-bold \${isToday ? 'text-violet-600' : 'text-zinc-800'}">\${dateNum}</p>
                </div>
                <div class="flex flex-col gap-2 flex-1">
        `;

        if (dayShifts.length === 0) {
            html += `<div class="text-center text-zinc-400 text-xs italic py-4">Không có ca</div>`;
        } else {
            dayShifts.sort((a, b) => a.gioBatDau.localeCompare(b.gioBatDau));

            dayShifts.forEach(s => {
                const staff = staffListFull.find(st => st.id === s.accountId);
                if (!staff) return;

                const timeFrame = formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc);
                const status = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
                const schedStatus = getTrangThaiBadge(s.trangThai);

                let roleColor = '';
                let bgColor = '';
                if (staff.roleId === 4) {
                    roleColor = 'text-green-600';
                    bgColor = 'bg-green-50 border-green-200 hover:bg-green-100';
                } else if (staff.roleId === 5) {
                    roleColor = 'text-orange-600';
                    bgColor = 'bg-orange-50 border-orange-200 hover:bg-orange-100';
                } else {
                    roleColor = 'text-blue-600';
                    bgColor = 'bg-blue-50 border-blue-200 hover:bg-blue-100';
                }

                html += `
                    <div class="shift-block \${bgColor} border rounded-lg p-2 cursor-pointer transition-all shadow-sm"
                         onclick="editScheduleShift(\${s.caLamViecId})"
                         title="Nhấn để chỉnh sửa">
                        <div class="flex items-center justify-between mb-1">
                            <span class="text-[10px] font-bold \${roleColor}">\${s.tenCa || 'Tùy chỉnh'} · \${s.viTri || 'Lễ tân'}</span>
                            <span class="text-[9px] px-1 py-0.5 rounded \${schedStatus.cssClass}">\${schedStatus.label}</span>
                        </div>
                        <p class="text-xs font-bold text-zinc-700 mb-1">\${timeFrame}</p>
                        \${s.gioNghi > 0 ? `<p class="text-[9px] text-red-500 font-semibold mb-1">Nghỉ: \${s.gioNghi}m</p>` : ''}
                        <div class="flex items-center gap-2">
                            <div class="w-5 h-5 rounded-full bg-violet-100 text-violet-700 flex items-center justify-center text-[10px] font-bold">
                                \${staff.fullName.substring(0, 1).toUpperCase()}
                            </div>
                            <p class="text-xs text-zinc-650 truncate flex-1">\${staff.fullName}</p>
                        </div>
                    </div>
                `;
            });
        }

        // Render availability overlay
        const dayAvails = scheduleAvails.filter(av => av.ngay === dateStr);
        if (dayAvails.length > 0) {
            html += `
                <div class="mt-auto pt-2 border-t border-violet-100 flex flex-col gap-1">
                    <p class="text-[9px] font-bold text-violet-700 uppercase tracking-wider mb-1">Nguyện vọng</p>
            `;
            dayAvails.forEach(av => {
                const color = av.trangThai === 'Ranh' ? 'bg-green-500' : 'bg-red-500';
                const label = av.trangThai === 'Ranh' ? 'Rảnh' : 'Bận';
                const textClass = av.trangThai === 'Ranh' ? 'text-green-700' : 'text-red-700';
                const bgClass = av.trangThai === 'Ranh' ? 'bg-green-50/50' : 'bg-red-50/50';
                const timeStr = formatTime(av.gioBatDau) + '-' + formatTime(av.gioKetThuc);
                
                html += `
                    <div class="flex items-center gap-1 p-1 rounded \${bgClass} text-[9px] truncate" title="\${av.tenNhanVien}: \${label} (\${timeStr})">
                        <span class="w-1.5 h-1.5 rounded-full \${color} shrink-0"></span>
                        <span class="font-medium text-zinc-700 truncate flex-1">\${av.tenNhanVien}</span>
                        <span class="\${textClass} font-semibold shrink-0">\${label}</span>
                    </div>
                `;
            });
            html += `</div>`;
        }

        html += `
                </div>
            </div>
        `;
    });

    html += '</div>';
    grid.innerHTML = html;
}

async function clonePreviousWeek() {
    const toWeekStr = currentWeekStart.toISOString().split('T')[0];
    const prevWeek = new Date(currentWeekStart);
    prevWeek.setDate(prevWeek.getDate() - 7);
    const fromWeekStr = prevWeek.toISOString().split('T')[0];
    
    if (confirm("Bạn có chắc chắn muốn nhân bản lịch từ tuần trước (" + fromWeekStr + ") sang tuần này (" + toWeekStr + ") không?")) {
        const params = new URLSearchParams();
        params.append('action', 'cloneWeek');
        params.append('format', 'json');
        params.append('fromWeek', fromWeekStr);
        params.append('toWeek', toWeekStr);

        try {
            const response = await fetch(_ctxPath + '/manager/ca-lam', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: params
            });

            if (response.ok) {
                const res = await response.json();
                if (res.success) {
                    showNotification('success', res.message || 'Nhân bản lịch tuần thành công!');
                    await loadScheduleData();
                } else {
                    showNotification('error', res.error || 'Lỗi nhân bản lịch tuần.');
                }
            } else {
                showNotification('error', 'Lỗi máy chủ khi nhân bản lịch tuần.');
            }
        } catch (error) {
            console.error('Error cloning week:', error);
            showNotification('error', 'Lỗi kết nối mạng.');
        }
    }
}

async function publishCurrentWeek() {
    const weekStartStr = currentWeekStart.toISOString().split('T')[0];
    if (confirm("Công bố lịch làm việc cho tuần bắt đầu từ ngày " + weekStartStr + "? Nhân viên sẽ nhận được thông báo về ca làm việc của họ.")) {
        const params = new URLSearchParams();
        params.append('action', 'publishWeek');
        params.append('format', 'json');
        params.append('weekStart', weekStartStr);

        try {
            const response = await fetch(_ctxPath + '/manager/ca-lam', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: params
            });

            if (response.ok) {
                const res = await response.json();
                if (res.success) {
                    showNotification('success', res.message || 'Công bố lịch làm việc thành công!');
                    await loadScheduleData();
                } else {
                    showNotification('error', res.error || 'Lỗi công bố lịch làm việc.');
                }
            } else {
                showNotification('error', 'Lỗi máy chủ khi công bố lịch.');
            }
        } catch (error) {
            console.error('Error publishing week:', error);
            showNotification('error', 'Lỗi kết nối mạng.');
        }
    }
}

// ==================== LEAVE VIEW (Yêu cầu nghỉ) ====================

async function loadLeaveRequests() {
    try {
        const response = await fetch('${pageContext.request.contextPath}/manager/yeu-cau-nghi?format=json');
        if (response.ok) {
            const data = await response.json();
            leaveRequests = data;
            renderLeaveTable();
        } else {
            console.error('Failed to load leave requests');
            // Fallback: maybe endpoint returns HTML, we'd need to parse
        }
    } catch (error) {
        console.error('Error loading leave requests:', error);
        alert('Lỗi tải dữ liệu yêu cầu nghỉ');
    }
}

function renderLeaveTable(filteredList = null) {
    const list = filteredList || leaveRequests;
    const tbody = document.getElementById('leaveRequestBody');
    const emptyState = document.getElementById('leaveEmptyState');
    const totalCountEl = document.getElementById('leaveTotalCount');
    const pendingCountEl = document.getElementById('leavePendingCount');
    const approvedCountEl = document.getElementById('leaveApprovedCount');

    // Stats
    totalCountEl.innerText = list.length;
    const pendingCount = list.filter(r => r.trangThai === 'ChoDuyet').length;
    pendingCountEl.innerText = pendingCount;
    const approvedCount = list.filter(r => r.trangThai === 'DaDuyet').length;
    approvedCountEl.innerText = approvedCount;

    if (list.length === 0) {
        tbody.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
    }
    emptyState.classList.add('hidden');

    tbody.innerHTML = list.map(function(req, idx) {
        var statusClass = req.trangThai === 'ChoDuyet' ? 'badge-amber' :
                          req.trangThai === 'DaDuyet'  ? 'badge-green'  :
                          req.trangThai === 'TuChoi'   ? 'badge-red'    : 'badge-zinc';
        var statusLabel = req.trangThai === 'ChoDuyet' ? 'Chờ duyệt' :
                          req.trangThai === 'DaDuyet'  ? 'Đã duyệt'  :
                          req.trangThai === 'TuChoi'   ? 'Từ chối'   :
                          req.trangThai === 'DaHuy'    ? 'Đã hủy'    : req.trangThai;
        var dateFormatted   = formatDate(req.ngayNghi);
        var loaiNghiDisplay = req.loaiNghi === 'FullDay'           ? 'Cả ngày'    :
                              req.loaiNghi === 'HalfDay_Morning'   ? 'Buổi sáng'  :
                              req.loaiNghi === 'HalfDay_Afternoon' ? 'Buổi chiều' : req.loaiNghi;
        
        var typeClass = req.loaiNghi === 'FullDay' ? 'bg-indigo-50 text-indigo-700' : 'bg-sky-50 text-sky-700';

        var dateSent = '-';
        if (req.ngayGui) {
            var d = new Date(req.ngayGui);
            dateSent = d.getDate() + '/' + (d.getMonth()+1) + '/' + d.getFullYear()
                     + ' ' + d.getHours().toString().padStart(2,'0')
                     + ':' + d.getMinutes().toString().padStart(2,'0');
        }

        var nameParts = req.tenNhanVien ? req.tenNhanVien.trim().split(' ') : [];
        var initials = nameParts.length > 0 ? nameParts[nameParts.length - 1].substring(0, 2).toUpperCase() : 'NV';

        var actionHtml = '';
        if (req.trangThai === 'ChoDuyet') {
            actionHtml =
                '<button type="button" onclick="approveLeave(' + req.yeuCauNghiID + ')"'
                + ' class="px-3 py-1.5 rounded-lg bg-green-50 border border-green-200 text-green-700 hover:bg-green-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer mr-2">Phê duyệt</button>'
                + '<button type="button" onclick="rejectLeave(' + req.yeuCauNghiID + ')"'
                + ' class="px-3 py-1.5 rounded-lg bg-red-50 border border-red-200 text-red-650 hover:bg-red-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer">Từ chối</button>';
        }

        return '<tr class="hover:bg-violet-50/10 transition-colors reveal-on-scroll">'
            + '<td class="p-4 text-center text-zinc-500 font-medium">' + (idx + 1) + '</td>'
            + '<td class="p-4">'
            +   '<div class="flex items-center gap-3">'
            +     '<div class="w-9 h-9 rounded-full bg-violet-100 text-violet-700 font-bold flex items-center justify-center text-xs shrink-0">' + initials + '</div>'
            +     '<div>'
            +       '<div class="text-sm font-semibold text-zinc-800">' + req.tenNhanVien + '</div>'
            +       '<div class="text-xs text-zinc-400 font-mono mt-0.5">' + req.username + '</div>'
            +     '</div>'
            +   '</div>'
            + '</td>'
            + '<td class="p-4 text-zinc-600 font-medium">' + req.roleName + '</td>'
            + '<td class="p-4 font-semibold text-zinc-700">' + dateFormatted + '</td>'
            + '<td class="p-4"><span class="px-2 py-0.5 rounded text-[11px] font-semibold ' + typeClass + '">' + loaiNghiDisplay + '</span></td>'
            + '<td class="p-4 text-zinc-600 max-w-[200px] truncate" title="' + req.lyDo + '">' + req.lyDo + '</td>'
            + '<td class="p-4"><span class="badge ' + statusClass + '">' + statusLabel + '</span></td>'
            + '<td class="p-4 text-zinc-400 font-mono">' + dateSent + '</td>'
            + '<td class="p-4 text-right pr-6">' + actionHtml + '</td>'
            + '</tr>';
    }).join('');

    if (typeof observer !== 'undefined') {
        document.querySelectorAll("#leaveRequestBody .reveal-on-scroll").forEach(el => {
            observer.observe(el);
        });
    } else {
        document.querySelectorAll("#leaveRequestBody .reveal-on-scroll").forEach(el => {
            el.classList.add("revealed");
        });
    }
}

function filterLeaveRequests(status, btn) {
    document.querySelectorAll('.leave-filter-btn').forEach(b => {
        b.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer';
    });
    if (btn) {
        btn.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    } else {
        const first = document.querySelector('.leave-filter-btn');
        if (first) first.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    }
    
    if (status === 'all') {
        renderLeaveTable(leaveRequests);
    } else {
        const filtered = leaveRequests.filter(r => r.trangThai === status);
        renderLeaveTable(filtered);
    }
}

function filterSwapRequests(status, btn) {
    currentSwapFilter = status;
    document.querySelectorAll('.swap-filter-btn').forEach(b => {
        b.className = 'swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer';
    });
    if (btn) {
        btn.className = 'swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    } else {
        const first = document.querySelector('.swap-filter-btn');
        if (first) first.className = 'swap-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    }
    renderSwapTable();
}

function renderSwapTable() {
    var tbody = document.getElementById('swapRequestBody');
    var emptyState = document.getElementById('swapEmptyState');
    if (!tbody || !emptyState) return;

    var filtered = scheduleSwaps;
    if (currentSwapFilter !== 'all') {
        filtered = scheduleSwaps.filter(function(sw) {
            return sw.trangThai === currentSwapFilter;
        });
    }

    if (filtered.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="p-8 text-center text-zinc-400 italic">Không có yêu cầu đổi ca nào khớp bộ lọc</td></tr>';
        emptyState.classList.add('hidden');
        return;
    }
    emptyState.classList.add('hidden');

    tbody.innerHTML = filtered.map(function(sw, idx) {
        var statusClass = 'badge-zinc';
        var statusLabel = sw.trangThai;
        if (sw.trangThai === 'ChoXacNhan') {
            statusClass = 'badge-zinc';
            statusLabel = 'Chờ đối phương nhận';
        } else if (sw.trangThai === 'ChoQuanLyDuyet') {
            statusClass = 'badge-amber';
            statusLabel = 'Chờ quản lý duyệt';
        } else if (sw.trangThai === 'DaDuyet') {
            statusClass = 'badge-green';
            statusLabel = 'Đã duyệt';
        } else if (sw.trangThai === 'TuChoi') {
            statusClass = 'badge-red';
            statusLabel = 'Từ chối';
        } else if (sw.trangThai === 'DaHuy') {
            statusClass = 'badge-zinc';
            statusLabel = 'Đã hủy';
        }

        var actionHtml = '';
        if (sw.trangThai === 'ChoQuanLyDuyet') {
            actionHtml = '<button onclick="approveSwap(' + sw.swapRequestId + ')" class="px-3 py-1.5 rounded-lg bg-green-50 border border-green-200 text-green-700 hover:bg-green-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer mr-2">Duyệt</button>'
                       + '<button onclick="rejectSwap(' + sw.swapRequestId + ')" class="px-3 py-1.5 rounded-lg bg-red-50 border border-red-200 text-red-650 hover:bg-red-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer">Từ chối</button>';
        }

        var caNhan = sw.caNhanInfo ? sw.caNhanInfo : '<span class="text-zinc-400 italic">Chỉ làm hộ</span>';

        var sendParts = sw.tenNguoiGui ? sw.tenNguoiGui.trim().split(' ') : [];
        var sendInitials = sendParts.length > 0 ? sendParts[sendParts.length - 1].substring(0, 2).toUpperCase() : 'NV';
        
        var recvParts = sw.tenNguoiNhan ? sw.tenNguoiNhan.trim().split(' ') : [];
        var recvInitials = recvParts.length > 0 ? recvParts[recvParts.length - 1].substring(0, 2).toUpperCase() : 'NV';

        return '<tr class="hover:bg-violet-50/10 transition-colors reveal-on-scroll">'
            + '<td class="p-4 text-center text-zinc-500 font-medium">' + (idx + 1) + '</td>'
            + '<td class="p-4">'
            +   '<div class="flex items-center gap-2.5">'
            +     '<div class="w-8 h-8 rounded-full bg-violet-100 text-violet-700 font-bold flex items-center justify-center text-xs shrink-0">' + sendInitials + '</div>'
            +     '<div class="font-semibold text-zinc-800">' + sw.tenNguoiGui + '</div>'
            +   '</div>'
            + '</td>'
            + '<td class="p-4">'
            +   '<div class="flex items-center gap-2.5">'
            +     '<div class="w-8 h-8 rounded-full bg-blue-50 text-blue-700 font-bold flex items-center justify-center text-xs shrink-0">' + recvInitials + '</div>'
            +     '<div class="font-semibold text-zinc-750">' + sw.tenNguoiNhan + '</div>'
            +   '</div>'
            + '</td>'
            + '<td class="p-4"><span class="px-2.5 py-1 rounded bg-violet-50 text-violet-850 font-medium text-[11px] border border-violet-100/50">' + sw.caGuiInfo + '</span></td>'
            + '<td class="p-4"><span class="px-2.5 py-1 rounded bg-blue-50 text-blue-850 font-medium text-[11px] border border-blue-100/50">' + caNhan + '</span></td>'
            + '<td class="p-4 text-zinc-600 max-w-[150px] truncate" title="' + (sw.lyDo ? sw.lyDo : '') + '">' + (sw.lyDo ? sw.lyDo : '') + '</td>'
            + '<td class="p-4"><span class="badge ' + statusClass + '">' + statusLabel + '</span></td>'
            + '<td class="p-4 text-right pr-6">' + actionHtml + '</td>'
            + '</tr>';
    }).join('');

    if (typeof observer !== 'undefined') {
        document.querySelectorAll("#swapRequestBody .reveal-on-scroll").forEach(el => {
            observer.observe(el);
        });
    } else {
        document.querySelectorAll("#swapRequestBody .reveal-on-scroll").forEach(el => {
            el.classList.add("revealed");
        });
    }
}

async function approveSwap(swapId) {
    const notes = prompt("Nhập ghi chú phê duyệt (tùy chọn):");
    if (notes === null) return; // Cancelled
    
    const params = new URLSearchParams();
    params.append('action', 'approveSwap');
    params.append('format', 'json');
    params.append('id', swapId);
    params.append('notes', notes);

    try {
        const response = await fetch(_ctxPath + '/manager/ca-lam', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã phê duyệt yêu cầu đổi ca!');
                await loadScheduleData();
            } else {
                showNotification('error', res.error || 'Lỗi phê duyệt yêu cầu đổi ca.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi phê duyệt đổi ca.');
        }
    } catch (error) {
        console.error('Error approving swap:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

async function rejectSwap(swapId) {
    const notes = prompt("Nhập lý do từ chối (bắt buộc):");
    if (notes === null) return; // Cancelled
    const trimmed = notes.trim();
    if (!trimmed) {
        alert("Lý do từ chối là bắt buộc!");
        return;
    }
    
    const params = new URLSearchParams();
    params.append('action', 'rejectSwap');
    params.append('format', 'json');
    params.append('id', swapId);
    params.append('notes', trimmed);

    try {
        const response = await fetch(_ctxPath + '/manager/ca-lam', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã từ chối yêu cầu đổi ca!');
                await loadScheduleData();
            } else {
                showNotification('error', res.error || 'Lỗi từ chối yêu cầu đổi ca.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi từ chối đổi ca.');
        }
    } catch (error) {
        console.error('Error rejecting swap:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

async function approveLeave(id) {
    if (!confirm('Phê duyệt yêu cầu nghỉ này?')) return;
    
    const params = new URLSearchParams();
    params.append('action', 'approve');
    params.append('id', id);
    params.append('format', 'json');

    try {
        const response = await fetch(_ctxPath + '/manager/yeu-cau-nghi', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã phê duyệt yêu cầu nghỉ');
                await loadLeaveRequests();
            } else {
                showNotification('error', res.error || 'Lỗi phê duyệt yêu cầu nghỉ.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi phê duyệt.');
        }
    } catch (error) {
        console.error('Error approving leave request:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

async function rejectLeave(id) {
    const ghiChu = prompt('Nhập lý do từ chối (tùy chọn):');
    if (ghiChu === null) return; // Cancelled
    
    const params = new URLSearchParams();
    params.append('action', 'reject');
    params.append('id', id);
    params.append('ghiChu', ghiChu);
    params.append('format', 'json');

    try {
        const response = await fetch(_ctxPath + '/manager/yeu-cau-nghi', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã từ chối yêu cầu nghỉ');
                await loadLeaveRequests();
            } else {
                showNotification('error', res.error || 'Lỗi từ chối yêu cầu nghỉ.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi từ chối.');
        }
    } catch (error) {
        console.error('Error rejecting leave request:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

// Global observer for scroll animations
let observer;

document.addEventListener('DOMContentLoaded', () => {
    // Initialize observer
    observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.classList.add("revealed");
                }, index * 40);
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.05,
        rootMargin: "0px 0px -10px 0px"
    });

    loadStaffList();
    
    // Add validation listeners
    const validationInputs = ['scheduleShiftStaff', 'scheduleShiftDate', 'scheduleStartTime', 'scheduleEndTime', 'scheduleShiftGioNghi'];
    validationInputs.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('change', triggerRealtimeValidation);
            el.addEventListener('input', triggerRealtimeValidation);
        }
    });

    // Default shift Date picker and build weekdays
    const dateInput = document.getElementById('scheduleShiftDate');
    if (dateInput) {
        dateInput.value = new Date().toISOString().split('T')[0];
        updateWeekDays();
    }
    
    // Automatically switch to correct tab if tab parameter is specified
    const urlParams = new URLSearchParams(window.location.search);
    const tab = urlParams.get('tab');
    if (tab && ['staff', 'schedule', 'leave'].includes(tab)) {
        switchView(tab);
    }
});
</script>

</body>
</html>
