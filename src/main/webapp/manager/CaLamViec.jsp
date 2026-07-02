<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý ca làm việc — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff; border:1px solid #f3e8ff; border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:8px; font-size:11px; font-weight:600; }
  .badge-purple { background:#f3e8ff; color:#6b21a8; }
  .badge-green { background:#dcfce7; color:#15803d; }
  .badge-blue { background:#dbeafe; color:#1d4ed8; }
  .badge-zinc { background:#f4f4f5; color:#71717a; }
  .badge-red { background:#fee2e2; color:#b91c1c; }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(139,92,246,.4);} 50%{box-shadow:0 0 0 6px rgba(139,92,246,0);} }
  
  @keyframes contentZoomIn {
    from { opacity: 0; transform: scale(0.97); }
    to { opacity: 1; transform: scale(1); }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
  /* Animation for alert boxes */
  @keyframes fadeInUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  .animate-fade-in-up { animation: fadeInUp 0.3s ease-out forwards; }
</style>
</head>
<body class="bg-purple-50/20 text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-700">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-purple-900 tracking-tight">Quản lý ca làm việc</h1>
      <p class="text-xs text-purple-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}
      </p>
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <button class="relative p-2 rounded-lg hover:bg-purple-50 text-purple-550">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-purple-650 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-purple-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <div class="flex items-center justify-between gap-4 mb-2">
    <div>
      <h2 class="text-lg font-bold text-purple-955 flex items-center gap-2">
        Phân công ca làm 
        <span class="text-xs bg-purple-100 px-2 py-0.5 rounded-full font-semibold text-purple-750" id="shiftCountDisplay">0 ca</span>
      </h2>
      <p class="text-xs text-zinc-500">Xem và điều hành lịch làm việc của nhân sự tại chi nhánh</p>
    </div>
  </div>

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
    <div class="p-4 bg-purple-50 border border-purple-100 rounded-xl text-purple-600 text-sm flex items-start gap-3 animate-fade-in-up">
      <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
      <div class="flex-1">
        <span class="font-bold block text-purple-750">Thành công</span>
        <span class="text-purple-600/90 leading-normal block mt-0.5">${sessionScope.message}</span>
      </div>
      <button onclick="this.parentElement.remove()" class="text-purple-400 hover:text-purple-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
      <% session.removeAttribute("message"); %>
    </div>
  </c:if>

  <!-- Inline Shift Configuration Form -->
  <div class="card p-6 bg-white border border-purple-100 shadow-md">
    <div class="flex items-center justify-between border-b border-purple-100 pb-4 mb-5">
      <h3 id="formTitle" class="text-base font-bold text-purple-900 flex items-center gap-2">
        <span class="material-symbols-outlined text-purple-600 text-[22px]">calendar_month</span>
        Phân ca làm việc mới
      </h3>
      <div class="text-xs text-purple-500 font-semibold bg-purple-50 px-3 py-1 rounded-full border border-purple-100">
        Chi nhánh CS${sessionScope.user.coSoId}
      </div>
    </div>

    <form id="inlineShiftForm" onsubmit="handleInlineShiftSubmit(event)" class="flex flex-col gap-5">
      <input type="hidden" id="shiftEditId" value="">
      <input type="hidden" id="shiftFacility" value="${sessionScope.user.coSoId}">

      <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
        <div class="flex flex-col gap-1.5 md:col-span-2">
          <label class="text-sm font-semibold text-purple-900">Chọn nhân viên <span class="text-red-500">*</span></label>
          <select id="shiftStaff" onchange="triggerRealtimeValidation()" required 
                  class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-purple-300">
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Tuần làm việc (Chọn ngày tham chiếu) <span class="text-red-500">*</span></label>
          <input type="date" id="shiftDate" onchange="updateWeekDays(); triggerRealtimeValidation();" required 
                 class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-purple-300">
        </div>
      </div>

      <div class="flex flex-col gap-2 p-4 bg-purple-50/30 border border-purple-100 rounded-xl">
        <div class="flex items-center justify-between">
          <label class="text-sm font-bold text-purple-900">Chọn các ngày làm việc trong tuần <span class="text-red-500">*</span></label>
          <div id="selectAllContainer" class="flex gap-3 text-xs">
            <button type="button" onclick="selectAllWeekDays(true)" class="text-purple-650 hover:text-purple-900 font-bold hover:underline">Chọn tất cả</button>
            <span class="text-purple-200">|</span>
            <button type="button" onclick="selectAllWeekDays(false)" class="text-purple-650 hover:text-purple-900 font-bold hover:underline">Bỏ chọn tất cả</button>
          </div>
        </div>
        <div id="weekDaysCheckboxes" class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-3 mt-1">
          <!-- Populated dynamically via JS -->
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-5">
        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Mẫu ca hệ thống <span class="text-red-500">*</span></label>
          <select id="shiftTemplate" onchange="applyShiftTemplate()" required 
                  class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-purple-300">
            <option value="Tùy chỉnh">-- Tự cấu hình giờ --</option>
            <option value="Ca sáng">Ca sáng (06:00 - 14:00)</option>
            <option value="Ca chiều">Ca chiều (14:00 - 22:00)</option>
            <option value="Ca đêm">Ca đêm (22:00 - 06:00)</option>
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Vai trò trong ca <span class="text-red-500">*</span></label>
          <select id="shiftRole" required 
                  class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-purple-300">
            <option value="Lễ tân">Lễ tân</option>
            <option value="Bảo vệ">Bảo vệ</option>
            <option value="Kỹ thuật sân">Kỹ thuật sân</option>
            <option value="Khác">Khác</option>
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Giờ bắt đầu <span class="text-red-500">*</span></label>
          <input type="time" id="shiftStartTime" onchange="triggerRealtimeValidation()" required 
                 class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-purple-300">
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Giờ kết thúc <span class="text-red-500">*</span></label>
          <input type="time" id="shiftEndTime" onchange="triggerRealtimeValidation()" required 
                 class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-purple-300">
        </div>
      </div>

      <div id="shiftDurationDisplay" class="hidden"></div>
      <div id="shiftAlertBox" class="hidden"></div>

      <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Giờ nghỉ (phút)</label>
          <input type="number" id="shiftBreakTime" onchange="triggerRealtimeValidation()" min="0" value="0" placeholder="Ví dụ: 30"
                 class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-purple-300">
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Trạng thái ca <span class="text-red-500">*</span></label>
          <select id="shiftStatusOption" required 
                  class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all bg-white text-zinc-700 shadow-sm cursor-pointer hover:border-purple-300">
            <option value="Published" selected>Hoạt động (Nhân viên thấy)</option>
            <option value="Draft">Nháp (Ẩn với nhân viên)</option>
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-sm font-semibold text-purple-900">Ghi chú / Phân công</label>
          <input type="text" id="shiftNotes" placeholder="Ví dụ: Bàn giao lại sân số 2..."
                 class="h-[42px] px-3.5 rounded-xl border border-purple-200 text-sm focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none transition-all text-zinc-700 shadow-sm hover:border-purple-300">
        </div>
      </div>

      <div class="flex items-center justify-end gap-3 pt-3 border-t border-purple-100">
        <button type="button" onclick="resetForm()" 
                class="h-[42px] px-6 rounded-xl border border-zinc-200 bg-white text-sm font-semibold text-zinc-600 hover:bg-zinc-100 hover:text-zinc-900 transition-colors shadow-sm">
          Hủy / Đặt lại
        </button>
        <button type="submit" id="btnSubmitShift"
                class="h-[42px] px-8 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 focus:ring-2 focus:ring-purple-500 focus:ring-offset-2 shadow-md shadow-purple-200 transition-all flex items-center justify-center disabled:opacity-50 disabled:cursor-not-allowed">
          Lưu ca làm việc
        </button>
      </div>
    </form>
  </div>

  <!-- Success Result Banner -->
  <div id="successResultBanner" class="hidden p-5 bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 rounded-2xl flex items-start gap-4 shadow-sm animate-fade-in-up">
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

  <div class="card p-4 flex flex-col md:flex-row gap-3 items-center justify-between bg-white">
    <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
      <div class="relative w-full sm:w-[220px]">
        <span class="material-symbols-outlined absolute left-3 top-2.5 text-zinc-400 text-[18px]">search</span>
        <input type="search" id="searchName" autocomplete="off" placeholder="Tìm tên nhân viên..." oninput="filterShifts()"
               class="h-9 w-full pl-9 pr-3 rounded-lg border border-purple-100 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none">
      </div>
      
      <select id="filterRole" onchange="filterShifts()" class="h-9 px-3 rounded-lg border border-purple-100 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none bg-white">
        <option value="">Tất cả vai trò</option>
        <option value="4">Lễ tân</option>
        <option value="5">Bảo vệ</option>
      </select>

      <select id="filterDateOpt" onchange="toggleDateInputs(); filterShifts();" class="h-9 px-3 rounded-lg border border-purple-100 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none bg-white">
        <option value="all">Tất cả ngày</option>
        <option value="today">Hôm nay</option>
        <option value="tomorrow">Ngày mai</option>
        <option value="custom">Chọn khoảng ngày</option>
      </select>
    </div>

    <div id="dateInputs" class="hidden flex items-center gap-2 w-full md:w-auto">
      <div class="flex items-center gap-1.5 w-full sm:w-auto">
        <span class="text-xs text-zinc-500 whitespace-nowrap">Từ</span>
        <input type="date" id="filterStartDate" onchange="filterShifts()" class="h-9 px-3 rounded-lg border border-purple-100 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none w-full sm:w-auto">
      </div>
      <div class="flex items-center gap-1.5 w-full sm:w-auto">
        <span class="text-xs text-zinc-500 whitespace-nowrap">đến</span>
        <input type="date" id="filterEndDate" onchange="filterShifts()" class="h-9 px-3 rounded-lg border border-purple-100 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none w-full sm:w-auto">
      </div>
    </div>

    <div class="flex items-center gap-2">
      <div class="flex bg-purple-50 rounded-lg p-1">
        <button id="viewTableBtn" onclick="switchScheduleView('table')" class="px-3 py-1.5 rounded text-sm font-medium bg-white text-purple-700 shadow-sm transition-all">
          <span class="material-symbols-outlined text-[16px] align-middle mr-1">table_view</span>Bảng
        </button>
        <button id="viewCalendarBtn" onclick="switchScheduleView('calendar')" class="px-3 py-1.5 rounded text-sm font-medium text-purple-600 hover:text-purple-700 transition-all">
          <span class="material-symbols-outlined text-[16px] align-middle mr-1">calendar_view_week</span>Lịch tuần
        </button>
      </div>
    </div>
  </div>

  <div id="tableView" class="card overflow-hidden bg-white">
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-purple-50/50 border-b border-purple-100">
          <tr>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Nhân viên</th>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Vai trò / Ca</th>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Ngày làm</th>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Giờ làm việc</th>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Trạng thái</th>
            <th class="px-5 py-3.5 text-left font-semibold text-purple-900 text-xs">Ghi chú</th>
            <th class="px-5 py-3.5 text-right font-semibold text-purple-900 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-purple-50/70" id="shiftBody">
          </tbody>
      </table>
    </div>
    
    <div id="emptyState" class="hidden flex flex-col items-center justify-center py-12 px-4 text-center">
      <span class="material-symbols-outlined text-[48px] text-purple-200 mb-2">event_busy</span>
      <p class="text-zinc-500 text-sm font-medium">Không tìm thấy ca làm việc nào phù hợp</p>
      <p class="text-zinc-400 text-xs mt-0.5">Hãy điền form phân ca ở trên để bắt đầu xếp lịch</p>
    </div>
  </div>

  <div id="calendarView" class="hidden flex flex-col gap-4">
      <div class="card p-4 bg-white flex items-center justify-between">
        <button onclick="changeWeek(-1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-purple-100 hover:bg-purple-50 text-purple-700 transition-colors">
          <span class="material-symbols-outlined text-[18px]">chevron_left</span>
          <span class="text-sm font-medium">Tuần trước</span>
        </button>
        <h3 class="text-base font-bold text-purple-900" id="weekRangeDisplay">Tuần này</h3>
        <button onclick="changeWeek(1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-purple-100 hover:bg-purple-50 text-purple-700 transition-colors">
          <span class="text-sm font-medium">Tuần sau</span>
          <span class="material-symbols-outlined text-[18px]">chevron_right</span>
        </button>
      </div>

      <div class="card overflow-hidden bg-white p-4">
        <div id="calendarGrid" class="grid gap-4">
          </div>
      </div>
  </div>

  <!-- =========== ADVANCED ACTIONS PANEL =========== -->
  <div class="card p-6 bg-white border border-purple-100 shadow-md">
    <div class="flex items-center gap-2 mb-5 pb-4 border-b border-purple-100">
      <span class="material-symbols-outlined text-purple-600 text-[22px]">tune</span>
      <h3 class="text-base font-bold text-purple-900">Tác vụ nâng cao</h3>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
      <!-- Clone Week -->
      <div class="flex flex-col gap-3 p-4 bg-purple-50/40 rounded-xl border border-purple-100">
        <div class="flex items-center gap-2">
          <span class="material-symbols-outlined text-purple-600 text-[20px]">content_copy</span>
          <h4 class="text-sm font-bold text-purple-900">Nhân bản lịch tuần</h4>
        </div>
        <p class="text-xs text-zinc-500">Sao chép toàn bộ ca làm từ tuần nguồn sang tuần đích</p>
        <div class="flex flex-col gap-2">
          <div class="flex flex-col gap-1">
            <label class="text-xs font-semibold text-purple-700">Ngày bất kỳ trong tuần nguồn</label>
            <input type="date" id="cloneFromWeek" class="h-9 px-3 rounded-lg border border-purple-200 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none bg-white">
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-semibold text-purple-700">Ngày bất kỳ trong tuần đích</label>
            <input type="date" id="cloneToWeek" class="h-9 px-3 rounded-lg border border-purple-200 text-sm focus:ring-2 focus:ring-purple-400 focus:outline-none bg-white">
          </div>
          <button onclick="cloneWeekShifts()" class="h-9 px-4 rounded-lg bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 transition-colors flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[16px]">content_copy</span> Nhân bản
          </button>
        </div>
      </div>
      <!-- Publish Week -->
      <div class="flex flex-col gap-3 p-4 bg-emerald-50/40 rounded-xl border border-emerald-100">
        <div class="flex items-center gap-2">
          <span class="material-symbols-outlined text-emerald-600 text-[20px]">send</span>
          <h4 class="text-sm font-bold text-emerald-900">Công bố lịch tuần</h4>
        </div>
        <p class="text-xs text-zinc-500">Chuyển tất cả ca Draft của tuần sang Published để nhân viên thấy</p>
        <div class="flex flex-col gap-2">
          <div class="flex flex-col gap-1">
            <label class="text-xs font-semibold text-emerald-700">Ngày bất kỳ trong tuần cần công bố</label>
            <input type="date" id="publishWeekDate" class="h-9 px-3 rounded-lg border border-emerald-200 text-sm focus:ring-2 focus:ring-emerald-400 focus:outline-none bg-white">
          </div>
          <button onclick="publishWeekShifts()" class="h-9 px-4 rounded-lg bg-emerald-600 text-white text-sm font-semibold hover:bg-emerald-700 transition-colors flex items-center justify-center gap-2 mt-auto">
            <span class="material-symbols-outlined text-[16px]">send</span> Công bố
          </button>
        </div>
      </div>
      <!-- Auto Schedule -->
      <div class="flex flex-col gap-3 p-4 bg-blue-50/40 rounded-xl border border-blue-100">
        <div class="flex items-center gap-2">
          <span class="material-symbols-outlined text-blue-600 text-[20px]">auto_fix_high</span>
          <h4 class="text-sm font-bold text-blue-900">Sắp lịch tự động</h4>
        </div>
        <p class="text-xs text-zinc-500">Tự động phân công nhân viên rảnh vào ca trống (tối đa 30 ngày)</p>
        <div class="flex flex-col gap-2">
          <div class="flex flex-col gap-1">
            <label class="text-xs font-semibold text-blue-700">Từ ngày</label>
            <input type="date" id="autoStartDate" class="h-9 px-3 rounded-lg border border-blue-200 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none bg-white">
          </div>
          <div class="flex flex-col gap-1">
            <label class="text-xs font-semibold text-blue-700">Đến ngày</label>
            <input type="date" id="autoEndDate" class="h-9 px-3 rounded-lg border border-blue-200 text-sm focus:ring-2 focus:ring-blue-400 focus:outline-none bg-white">
          </div>
          <button onclick="autoScheduleShifts()" class="h-9 px-4 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[16px]">auto_fix_high</span> Sắp lịch
          </button>
        </div>
      </div>
    </div>
    <!-- Warnings/result area for advanced actions -->
    <div id="advancedActionsWarnings" class="hidden mt-4 p-4 bg-amber-50 border border-amber-200 rounded-xl">
      <div class="flex items-center gap-2 text-sm font-bold text-amber-800 mb-2">
        <span class="material-symbols-outlined text-[18px]">warning</span>Kết quả / Cảnh báo:
      </div>
      <ul id="advancedWarningsList" class="list-disc pl-5 space-y-0.5 text-sm text-amber-700"></ul>
    </div>
  </div>

  <!-- =========== SWAP REQUESTS PANEL =========== -->
  <div class="card p-6 bg-white border border-purple-100 shadow-md">
    <div class="flex items-center justify-between mb-5 pb-4 border-b border-purple-100">
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-purple-600 text-[22px]">swap_horiz</span>
        <h3 class="text-base font-bold text-purple-900">Yêu cầu đổi ca chờ duyệt</h3>
        <span id="swapBadge" class="hidden ml-1 px-2 py-0.5 rounded-full bg-red-100 text-red-700 text-xs font-bold"></span>
      </div>
      <button onclick="loadSwapRequests()" class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-purple-100 hover:bg-purple-50 text-purple-700 text-xs font-semibold transition-colors">
        <span class="material-symbols-outlined text-[14px]">refresh</span> Tải lại
      </button>
    </div>
    <div id="swapRequestsContainer">
      <div class="text-center py-8 text-zinc-400 text-sm flex flex-col items-center gap-2">
        <span class="material-symbols-outlined text-[36px] text-zinc-200">swap_horiz</span>
        Đang tải yêu cầu đổi ca...
      </div>
    </div>
  </div>

</main>

<!-- Modal removed since shift configuration form is now inline -->

<!-- ===== DELETE REASON MODAL ===== -->
<div id="deleteReasonModal" class="hidden fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
  <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
    <div class="flex items-center gap-3 mb-4">
      <div class="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-red-600 text-[22px]">delete_forever</span>
      </div>
      <div>
        <h3 class="text-base font-bold text-zinc-900">Xác nhận xóa ca làm việc</h3>
        <p class="text-xs text-zinc-500 mt-0.5">Ca đang ở trạng thái <strong id="deleteShiftStatus" class="text-red-600"></strong> — bắt buộc nhập lý do</p>
      </div>
    </div>
    <input type="hidden" id="deleteShiftId">
    <div class="flex flex-col gap-1.5 mb-5">
      <label class="text-sm font-semibold text-zinc-700">Lý do xóa <span class="text-red-500">*</span></label>
      <textarea id="deleteReasonInput" rows="3"
                placeholder="Ví dụ: Nhân viên xin nghỉ đột xuất, cơ sở đóng cửa ngày này..."
                class="px-3.5 py-2.5 rounded-xl border border-zinc-200 text-sm focus:ring-2 focus:ring-red-400 focus:border-red-400 outline-none resize-none text-zinc-700"></textarea>
    </div>
    <div class="flex items-center justify-end gap-3">
      <button onclick="document.getElementById('deleteReasonModal').classList.add('hidden')"
              class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-100 transition-colors">
        Hủy
      </button>
      <button onclick="confirmDeleteWithReason()"
              class="h-10 px-6 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700 transition-colors flex items-center gap-2">
        <span class="material-symbols-outlined text-[16px]">delete_forever</span> Xác nhận xóa
      </button>
    </div>
  </div>
</div>

<!-- ===== CONFIRMED OVERRIDE MODAL ===== -->
<div id="confirmedOverrideModal" class="hidden fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
  <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
    <div class="flex items-center gap-3 mb-4">
      <div class="w-10 h-10 rounded-full bg-amber-100 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-amber-600 text-[22px]">warning</span>
      </div>
      <div>
        <h3 class="text-base font-bold text-zinc-900">Ca đã được nhân viên xác nhận</h3>
        <p class="text-xs text-zinc-500 mt-0.5">Thay đổi sẽ gửi thông báo tự động đến nhân viên</p>
      </div>
    </div>
    <div class="flex flex-col gap-1.5 mb-5">
      <label class="text-sm font-semibold text-zinc-700">Lý do thay đổi <span class="text-red-500">*</span></label>
      <textarea id="overrideReasonInput" rows="3"
                placeholder="Ví dụ: Điều chỉnh giờ làm do cơ sở có sự kiện đặc biệt..."
                class="px-3.5 py-2.5 rounded-xl border border-zinc-200 text-sm focus:ring-2 focus:ring-amber-400 focus:border-amber-400 outline-none resize-none text-zinc-700"></textarea>
    </div>
    <div class="flex items-center justify-end gap-3">
      <button onclick="document.getElementById('confirmedOverrideModal').classList.add('hidden')"
              class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-100 transition-colors">
        Hủy
      </button>
      <button onclick="confirmOverrideAndSave()"
              class="h-10 px-6 rounded-xl bg-amber-600 text-white text-sm font-semibold hover:bg-amber-700 transition-colors flex items-center gap-2">
        <span class="material-symbols-outlined text-[16px]">edit_note</span> Xác nhận thay đổi
      </button>
    </div>
  </div>
</div>

<!-- ===== SWAP APPROVE/REJECT MODAL ===== -->
<div id="swapActionModal" class="hidden fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
  <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md p-6">
    <div class="flex items-center gap-3 mb-4">
      <div id="swapModalIconWrap" class="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center shrink-0">
        <span id="swapModalIconSymbol" class="material-symbols-outlined text-emerald-600 text-[22px]">check_circle</span>
      </div>
      <div>
        <h3 id="swapModalTitle" class="text-base font-bold text-zinc-900">Phê duyệt đổi ca</h3>
        <p id="swapModalSub" class="text-xs text-zinc-500 mt-0.5"></p>
      </div>
    </div>
    <input type="hidden" id="swapActionId">
    <input type="hidden" id="swapActionType">
    <div class="flex flex-col gap-1.5 mb-5">
      <label class="text-sm font-semibold text-zinc-700">Ghi chú (tùy chọn)</label>
      <textarea id="swapNotesInput" rows="2" placeholder="Ghi chú cho nhân viên..."
                class="px-3.5 py-2.5 rounded-xl border border-zinc-200 text-sm focus:ring-2 focus:ring-purple-400 outline-none resize-none text-zinc-700"></textarea>
    </div>
    <div class="flex items-center justify-end gap-3">
      <button onclick="document.getElementById('swapActionModal').classList.add('hidden')"
              class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-100 transition-colors">
        Hủy
      </button>
      <button id="swapConfirmBtn" onclick="confirmSwapAction()"
              class="h-10 px-6 rounded-xl bg-emerald-600 text-white text-sm font-semibold hover:bg-emerald-700 transition-colors flex items-center gap-2">
        <span class="material-symbols-outlined text-[16px]">check_circle</span> Phê duyệt
      </button>
    </div>
  </div>
</div>

<script>
// Context Path
const _ctxPath = '${pageContext.request.contextPath}';

let staffList = [
  <c:forEach items="${staffs}" var="staff" varStatus="loop">
    {
      id: ${staff.accountId},
      username: '${staff.username}',
      fullName: '<c:out value="${staff.fullName != null && !staff.fullName.trim().isEmpty() ? staff.fullName : staff.username}" />',
      roleId: ${staff.roleId},
      roleName: '${staff.roleId == 4 ? "Lễ tân" : (staff.roleId == 5 ? "Bảo vệ" : "Nhân viên")}'
    }${!loop.last ? ',' : ''}
  </c:forEach>
];

let shiftList = [
  <c:forEach items="${shifts}" var="s" varStatus="loop">
    {
      caLamViecId: ${s.caLamViecId},
      accountId: ${s.accountId},
      ngayLam: '${s.ngayLam}',
      gioBatDau: '${s.gioBatDau}',
      gioKetThuc: '${s.gioKetThuc}',
      tenCa: '<c:out value="${s.tenCa != null ? s.tenCa : ''}" />',
      viTri: '<c:out value="${s.viTri != null ? s.viTri : ''}" />',
      trangThai: '<c:out value="${s.trangThai != null ? s.trangThai : ''}" />',
      gioNghi: ${s.gioNghi != null ? s.gioNghi : 0},
      ghiChu: `<c:out value="${s.ghiChu != null ? s.ghiChu : ''}" />`
    }${!loop.last ? ',' : ''}
  </c:forEach>
];

function formatDate(str) {
  if (!str) return '';
  const parts = str.split('-');
  if (parts.length !== 3) return str;
  return `\${parts[2]}/\${parts[1]}/\${parts[0]}`;
}

function formatTime(str) {
  if (!str) return '';
  const parts = str.split(':');
  if (parts.length < 2) return str;
  return `\${parts[0]}:\${parts[1]}`;
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

function toggleDateInputs() {
  const opt = document.getElementById('filterDateOpt').value;
  const container = document.getElementById('dateInputs');
  if (opt === 'custom') {
    container.classList.remove('hidden');
  } else {
    container.classList.add('hidden');
    document.getElementById('filterStartDate').value = '';
    document.getElementById('filterEndDate').value = '';
  }
}

function filterShifts() {
  const searchName = document.getElementById('searchName').value.trim().toLowerCase();
  const filterRole = document.getElementById('filterRole').value;
  const dateOpt = document.getElementById('filterDateOpt').value;
  const startDate = document.getElementById('filterStartDate').value;
  const endDate = document.getElementById('filterEndDate').value;

  const todayStr = new Date().toISOString().split('T')[0];
  let tomorrowStr = '';
  {
    const tom = new Date();
    tom.setDate(tom.getDate() + 1);
    tomorrowStr = tom.toISOString().split('T')[0];
  }

  const filtered = shiftList.filter(s => {
    const staff = staffList.find(st => st.id === s.accountId);
    const staffName = staff ? staff.fullName.toLowerCase() : '';
    const staffUsername = staff ? staff.username.toLowerCase() : '';
    const staffRole = staff ? String(staff.roleId) : '';

    if (searchName && !staffName.includes(searchName) && !staffUsername.includes(searchName)) return false;
    if (filterRole && staffRole !== filterRole) return false;
    if (dateOpt === 'today' && s.ngayLam !== todayStr) return false;
    if (dateOpt === 'tomorrow' && s.ngayLam !== tomorrowStr) return false;
    if (dateOpt === 'custom') {
      if (startDate && s.ngayLam < startDate) return false;
      if (endDate && s.ngayLam > endDate) return false;
    }
    return true;
  });

  renderTable(filtered);
}

function renderTable(list) {
  const tbody = document.getElementById('shiftBody');
  const emptyState = document.getElementById('emptyState');
  document.getElementById('shiftCountDisplay').innerText = `\${list.length} ca`;

  if (list.length === 0) {
    tbody.innerHTML = '';
    emptyState.classList.remove('hidden');
    return;
  }
  emptyState.classList.add('hidden');

  list.sort((a, b) => {
    if (a.ngayLam !== b.ngayLam) return b.ngayLam.localeCompare(a.ngayLam);
    return b.gioBatDau.localeCompare(a.gioBatDau);
  });

  tbody.innerHTML = list.map(s => {
    const staff = staffList.find(st => st.id === s.accountId);
    const staffName = staff ? staff.fullName : 'Nhân viên không tồn tại';
    const staffUsername = staff ? staff.username : 'N/A';
    const initial = staffName.substring(0, 1).toUpperCase();

    const statusWork = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
    const statusSched = getTrangThaiBadge(s.trangThai);
    const dateFormatted = formatDate(s.ngayLam);
    const timeFrame = `\${formatTime(s.gioBatDau)} - \${formatTime(s.gioKetThuc)}`;

    return `
      <tr class="hover:bg-purple-50/35 transition-colors">
        <td class="px-5 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8.5 h-8.5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center shrink-0 font-bold text-xs">\${initial}</div>
            <div>
              <p class="font-bold text-purple-950 leading-tight">\${staffName}</p>
              <p class="text-[10px] text-purple-400 mt-0.5">\${staffUsername}</p>
            </div>
          </div>
        </td>
        <td class="px-5 py-4 text-xs">
          <p class="font-semibold text-purple-750">\${s.tenCa || 'Tùy chỉnh'} / \${s.viTri || 'Lễ tân'}</p>
        </td>
        <td class="px-5 py-4 text-xs font-medium text-zinc-700">\${dateFormatted}</td>
        <td class="px-5 py-4 text-xs font-bold text-purple-900">
          \${timeFrame}
          \${s.gioNghi > 0 ? `<span class="text-[10px] text-red-500 block font-semibold mt-0.5">Nghỉ: \${s.gioNghi}m</span>` : ''}
        </td>
        <td class="px-5 py-4">
            <div class="flex flex-col gap-1 items-start">
                <span class="badge \${statusSched.cssClass}">\${statusSched.label}</span>
                <span class="badge \${statusWork.cssClass}">\${statusWork.label}</span>
            </div>
        </td>
        <td class="px-5 py-4 text-xs text-zinc-500 max-w-[150px] truncate" title="\${s.ghiChu || 'Không có'}">\${s.ghiChu || '-'}</td>
        <td class="px-5 py-4 text-right">
          <div class="flex items-center justify-end gap-1">
            <button onclick="editShift(\${s.caLamViecId})" class="p-1.5 rounded-lg hover:bg-purple-50 text-purple-600"><span class="material-symbols-outlined text-[18px]">edit</span></button>
            <button onclick="deleteShift(\${s.caLamViecId})" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><span class="material-symbols-outlined text-[18px]">delete</span></button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

// ============================================
// MODAL & VALIDATION LOGIC CẢI TIẾN
// ============================================

// ============================================
// AJAX & INLINE CONFIGURATION LOGIC
// ============================================

function populateStaffDropdown(selectedId) {
  const select = document.getElementById('shiftStaff');
  select.innerHTML = '<option value="">-- Chọn nhân viên --</option>';
  staffList.forEach(st => {
    const opt = document.createElement('option');
    opt.value = st.id;
    opt.textContent = `[\${st.roleName}] \${st.fullName} (\${st.username})`;
    if (selectedId && st.id === selectedId) opt.selected = true;
    select.appendChild(opt);
  });
}

function applyShiftTemplate() {
    const tpl = document.getElementById('shiftTemplate').value;
    const start = document.getElementById('shiftStartTime');
    const end = document.getElementById('shiftEndTime');
    const breakTime = document.getElementById('shiftBreakTime');

    if (tpl === 'Ca sáng') { start.value = '06:00'; end.value = '14:00'; breakTime.value = '30'; }
    else if (tpl === 'Ca chiều') { start.value = '14:00'; end.value = '22:00'; breakTime.value = '30'; }
    else if (tpl === 'Ca đêm') { start.value = '22:00'; end.value = '06:00'; breakTime.value = '0'; }
    
    triggerRealtimeValidation();
}

// Generate Weekday Checkboxes dynamically based on shiftDate selection
function updateWeekDays() {
  const dateVal = document.getElementById('shiftDate').value;
  if (!dateVal) return;
  
  const d = new Date(dateVal);
  const day = d.getDay();
  // Get Monday of the selected date's week
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(d.setDate(diff));
  
  const container = document.getElementById('weekDaysCheckboxes');
  container.innerHTML = '';
  
  const dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  const editId = document.getElementById('shiftEditId').value;
  
  for (let i = 0; i < 7; i++) {
    const current = new Date(monday);
    current.setDate(monday.getDate() + i);
    
    const year = current.getFullYear();
    const month = String(current.getMonth() + 1).padStart(2, '0');
    const dateNum = String(current.getDate()).padStart(2, '0');
    const dateStr = `\${year}-\\${month}-\\${dateNum}`;
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
    wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border cursor-pointer select-none transition-all text-center bg-white border-zinc-200 hover:border-purple-300 hover:bg-purple-50/10`;
    
    wrapper.innerHTML = `
      <span class="text-[10px] font-bold text-zinc-500 uppercase tracking-wide">\${dayNames[i]}</span>
      <span class="text-sm font-extrabold text-zinc-800 my-1">\${displayDate}</span>
      <input type="checkbox" id="\${checkboxId}" value="\${dateStr}" \${isChecked ? 'checked' : ''} \${isDisabled ? 'disabled' : ''} onchange="updateCheckboxStyles(); triggerRealtimeValidation();"
             class="w-4 h-4 text-purple-650 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer mt-1">
    `;
    container.appendChild(wrapper);
  }
  updateCheckboxStyles();
}

function selectAllWeekDays(checked) {
  const editId = document.getElementById('shiftEditId').value;
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
      wrapper.classList.remove('bg-white', 'border-zinc-200', 'hover:bg-purple-50/10');
      wrapper.classList.add('bg-purple-100/40', 'border-purple-500', 'ring-2', 'ring-purple-400');
    } else {
      const dateStr = cb.value;
      const isToday = (dateStr === new Date().toISOString().split('T')[0]);
      wrapper.classList.remove('bg-purple-100/40', 'border-purple-500', 'ring-2', 'ring-purple-400');
      if (isToday) {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-purple-300 ring-1 ring-purple-300 cursor-pointer select-none transition-all text-center bg-purple-50/50`;
      } else {
        wrapper.className = `flex flex-col items-center justify-center p-3.5 rounded-xl border border-zinc-200 hover:border-purple-300 hover:bg-purple-50/10 cursor-pointer select-none transition-all text-center bg-white`;
      }
    }
  });
}

function calculateDurationAndOvertime() {
    const staffId = document.getElementById('shiftStaff').value;
    const startVal = document.getElementById('shiftStartTime').value;
    const endVal = document.getElementById('shiftEndTime').value;
    const breakVal = parseInt(document.getElementById('shiftBreakTime').value) || 0;
    
    const displayDiv = document.getElementById('shiftDurationDisplay');
    
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
            const referenceDate = document.getElementById('shiftDate').value;
            if (referenceDate) datesToCalculate.push(referenceDate);
        }
        
        if (datesToCalculate.length > 0) {
            const months = [...new Set(datesToCalculate.map(d => d.substring(0, 7)))];
            
            months.forEach(month => {
                let existingMins = 0;
                const editId = document.getElementById('shiftEditId').value;
                
                shiftList.forEach(s => {
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
    const staffId = document.getElementById('shiftStaff').value;
    const gioBatDau = document.getElementById('shiftStartTime').value;
    const gioKetThuc = document.getElementById('shiftEndTime').value;
    const gioNghi = document.getElementById('shiftBreakTime').value || '0';
    const editId = document.getElementById('shiftEditId').value;
    
    const alertBox = document.getElementById('shiftAlertBox');
    const submitBtn = document.getElementById('btnSubmitShift');
    
    if (!staffId || !gioBatDau || !gioKetThuc) {
        alertBox.classList.add('hidden');
        submitBtn.disabled = false;
        return;
    }

    const checkedCheckboxes = Array.from(document.querySelectorAll('#weekDaysCheckboxes input[type="checkbox"]:checked'));
    let datesToValidate = checkedCheckboxes.map(cb => cb.value);
    
    if (datesToValidate.length === 0) {
        const referenceDate = document.getElementById('shiftDate').value;
        if (referenceDate) datesToValidate.push(referenceDate);
    }
    
    if (datesToValidate.length === 0) {
        alertBox.classList.add('hidden');
        submitBtn.disabled = false;
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
            alertBox.className = 'p-3 rounded-xl text-sm flex flex-col gap-1.5 bg-red-50 border border-red-200 text-red-750 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[18px]">cancel</span> Lỗi xung đột ca (Hệ thống chặn lưu):</div><ul class="list-disc pl-5 space-y-0.5">';
            allErrors.forEach(err => { html += `<li>\${err}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            submitBtn.disabled = true;
        } else if (allWarnings.length > 0) {
            alertBox.className = 'p-3 rounded-xl text-sm flex flex-col gap-1.5 bg-amber-50 border border-amber-200 text-amber-700 animate-fade-in-up mt-2';
            let html = '<div class="flex items-center gap-1.5 font-bold"><span class="material-symbols-outlined text-[18px]">warning</span> Cảnh báo lưu ý:</div><ul class="list-disc pl-5 space-y-0.5">';
            allWarnings.forEach(warn => { html += `<li>\${warn}</li>`; });
            html += '</ul>';
            alertBox.innerHTML = html;
            alertBox.classList.remove('hidden');
            submitBtn.disabled = false;
        } else {
            alertBox.classList.add('hidden');
            submitBtn.disabled = false;
        }
    } catch (err) {
        console.error('Validation API failed:', err);
    }
}

function resetForm() {
    document.getElementById('inlineShiftForm').reset();
    document.getElementById('shiftEditId').value = '';
    document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-purple-650 text-[22px]">calendar_month</span> Phân ca làm việc mới`;
    
    // Set default values
    document.getElementById('shiftDate').value = new Date().toISOString().split('T')[0];
    document.getElementById('shiftTemplate').value = 'Tùy chỉnh';
    document.getElementById('shiftRole').value = 'Lễ tân';
    document.getElementById('shiftStatusOption').value = 'Published';
    document.getElementById('shiftBreakTime').value = '0';
    
    document.getElementById('shiftDurationDisplay').innerHTML = '';
    document.getElementById('shiftDurationDisplay').classList.add('hidden');
    document.getElementById('shiftAlertBox').innerHTML = '';
    document.getElementById('shiftAlertBox').classList.add('hidden');
    document.getElementById('btnSubmitShift').disabled = false;
    
    if (document.getElementById('selectAllContainer')) {
        document.getElementById('selectAllContainer').classList.remove('hidden');
    }
    
    populateStaffDropdown(null);
    updateWeekDays();
}

function editShift(id) {
  const s = shiftList.find(x => x.caLamViecId === id);
  if (!s) return;

  document.getElementById('formTitle').innerHTML = `<span class="material-symbols-outlined text-purple-600 text-[22px]">edit_calendar</span> Chỉnh sửa ca làm việc`;
  
  document.getElementById('shiftEditId').value = s.caLamViecId;
  document.getElementById('shiftDate').value = s.ngayLam;
  document.getElementById('shiftStartTime').value = formatTime(s.gioBatDau);
  document.getElementById('shiftEndTime').value = formatTime(s.gioKetThuc);
  document.getElementById('shiftTemplate').value = s.tenCa || 'Tùy chỉnh';
  document.getElementById('shiftRole').value = s.viTri || 'Lễ tân';
  document.getElementById('shiftBreakTime').value = s.gioNghi || 0;
  document.getElementById('shiftStatusOption').value = s.trangThai || 'Draft';
  document.getElementById('shiftNotes').value = s.ghiChu || '';
  
  document.getElementById('btnSubmitShift').disabled = false;

  populateStaffDropdown(s.accountId);
  
  if (document.getElementById('selectAllContainer')) {
      document.getElementById('selectAllContainer').classList.add('hidden');
  }
  
  // Update weekdays list and check ONLY the current shift's date
  updateWeekDays();
  
  // Scroll to form smoothly
  document.getElementById('inlineShiftForm').scrollIntoView({ behavior: 'smooth', block: 'center' });
  triggerRealtimeValidation();
}

async function deleteShift(id) {
  const s = shiftList.find(x => x.caLamViecId === id);
  const isPublishedOrConfirmed = s && (s.trangThai === 'Published' || s.trangThai === 'Confirmed');
  if (isPublishedOrConfirmed) {
    document.getElementById('deleteShiftId').value = id;
    document.getElementById('deleteShiftStatus').textContent = s.trangThai === 'Confirmed' ? 'Đã xác nhận' : 'Đã công bố';
    document.getElementById('deleteReasonInput').value = '';
    document.getElementById('deleteReasonModal').classList.remove('hidden');
  } else {
    if (confirm('Xóa ca làm việc này? Hành động này không thể hoàn tác.')) {
      await performDelete(id, '');
    }
  }
}

async function confirmDeleteWithReason() {
  const id = document.getElementById('deleteShiftId').value;
  const reason = document.getElementById('deleteReasonInput').value.trim();
  if (!reason) { showToast('error', 'Vui lòng nhập lý do xóa'); return; }
  document.getElementById('deleteReasonModal').classList.add('hidden');
  await performDelete(id, reason);
}

async function performDelete(id, reason) {
  try {
    const params = new URLSearchParams({ action: 'delete', format: 'json', id });
    if (reason) params.append('reason', reason);
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    }).then(r => r.json());
    if (res.success) {
      showToast('success', 'Đã xóa ca làm việc thành công!');
      await loadScheduleData();
    } else {
      showToast('error', res.error || 'Không thể xóa ca làm việc.');
    }
  } catch (err) {
    console.error(err);
    showToast('error', 'Lỗi kết nối hệ thống.');
  }
}

// Unified dynamic loader for shifts via AJAX format=json
async function loadScheduleData() {
  try {
    const response = await fetch(`\${_ctxPath}/manager/ca-lam?format=json`);
    if (response.ok) {
      const data = await response.json();
      shiftList = data.shifts || [];
      // Rerender table
      filterShifts();
      // Rerender calendar grid
      if (!document.getElementById('calendarView').classList.contains('hidden')) {
        renderCalendar();
      }
      // Update swap requests from same payload
      const pending = (data.swaps || []).filter(s => s.trangThai === 'ChoQuanLyDuyet');
      _swapList = pending;
      renderSwapRequests();
    }
  } catch (error) {
    console.error("Lỗi khi tải lại lịch làm việc:", error);
  }
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

// Toast Notifications Helper
function showToast(type, message) {
  let container = document.getElementById('toastContainer');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'fixed top-5 right-5 z-[100] flex flex-col gap-3 max-w-sm w-full pointer-events-none';
    document.body.appendChild(container);
  }
  
  const toast = document.createElement('div');
  toast.className = 'pointer-events-auto flex items-center gap-3 p-4 rounded-xl border shadow-lg transition-all transform translate-x-10 opacity-0 duration-300 bg-white border-purple-100';
  
  let icon = 'info';
  let iconColor = 'text-blue-500';
  
  if (type === 'success') {
    icon = 'check_circle';
    iconColor = 'text-emerald-500';
  } else if (type === 'error') {
    icon = 'cancel';
    iconColor = 'text-red-500';
  } else if (type === 'warning') {
    icon = 'warning';
    iconColor = 'text-amber-500';
  }
  
  toast.innerHTML = `
    <span class="material-symbols-outlined \${iconColor} shrink-0">\${icon}</span>
    <p class="text-sm font-semibold text-zinc-700 flex-1 leading-snug">\${message}</p>
    <button class="text-zinc-400 hover:text-zinc-700 transition-colors shrink-0" onclick="this.parentElement.remove()">
      <span class="material-symbols-outlined text-[18px]">close</span>
    </button>
  `;
  
  container.appendChild(toast);
  
  setTimeout(() => {
    toast.classList.remove('translate-x-10', 'opacity-0');
  }, 10);
  
  setTimeout(() => {
    toast.classList.add('opacity-0', 'scale-95');
    setTimeout(() => {
      toast.remove();
    }, 300);
  }, 4000);
}

async function handleInlineShiftSubmit(e) {
  e.preventDefault();
  
  const submitBtn = document.getElementById('btnSubmitShift');
  if (submitBtn.disabled) {
    alert("Đang có lỗi xung đột ca hoặc dữ liệu không hợp lệ. Vui lòng kiểm tra lại!");
    return;
  }
  
  const staffId = document.getElementById('shiftStaff').value;
  const startTime = document.getElementById('shiftStartTime').value;
  const endTime = document.getElementById('shiftEndTime').value;
  const editId = document.getElementById('shiftEditId').value;
  
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
    const staffSelect = document.getElementById('shiftStaff');
    const staffName = staffSelect.options[staffSelect.selectedIndex].text.split('] ')[1] || staffSelect.options[staffSelect.selectedIndex].text;
    
    if (editId) {
      // Edit Mode (single day)
      const dateToSave = checkedCheckboxes.length > 0 ? checkedCheckboxes[0].value : document.getElementById('shiftDate').value;
      
      const params = new URLSearchParams();
      params.append('action', 'update');
      params.append('format', 'json');
      params.append('caLamViecId', editId);
      params.append('accountId', staffId);
      params.append('coSoId', document.getElementById('shiftFacility').value);
      params.append('ngayLam', dateToSave);
      params.append('gioBatDau', startTime);
      params.append('gioKetThuc', endTime);
      params.append('tenCa', document.getElementById('shiftTemplate').value);
      params.append('viTri', document.getElementById('shiftRole').value);
      params.append('trangThai', document.getElementById('shiftStatusOption').value);
      params.append('gioNghi', document.getElementById('shiftBreakTime').value || '0');
      params.append('ghiChu', document.getElementById('shiftNotes').value);
      params.append('reason', 'Cập nhật ca làm việc');

      const response = await fetch(`\${_ctxPath}/manager/ca-lam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
      });

      if (response.ok) {
        const res = await response.json();
        if (res.success) {
          showToast('success', 'Đã cập nhật ca làm việc thành công!');
          if (res.warnings && res.warnings.length > 0) {
            res.warnings.forEach(w => showToast('warning', w));
          }
          const weekdayAndDateStr = getWeekdayAndDateStr(dateToSave);
          showSuccessBanner(staffName, startTime, endTime, weekdayAndDateStr);
          await loadScheduleData();
          resetForm();
          scrollToCalendar();
        } else if (res.error && res.error.startsWith('CONFIRMED_OVERRIDE_REQUIRED')) {
          // Ca đã confirmed — mở modal xác nhận override
          document.getElementById('overrideReasonInput').value = '';
          _pendingUpdateParams = params;
          _pendingUpdateStaffName = staffName;
          _pendingUpdateStartTime = startTime;
          _pendingUpdateEndTime = endTime;
          _pendingUpdateDateToSave = dateToSave;
          document.getElementById('confirmedOverrideModal').classList.remove('hidden');
        } else {
          showToast('error', res.error || 'Cập nhật thất bại');
        }
      } else {
        showToast('error', 'Lỗi kết nối máy chủ');
      }
    } else {
      // Add Mode (multiple days in parallel)
      const promises = checkedCheckboxes.map(cb => {
        const dateToSave = cb.value;
        const params = new URLSearchParams();
        params.append('action', 'add');
        params.append('format', 'json');
        params.append('accountId', staffId);
        params.append('coSoId', document.getElementById('shiftFacility').value);
        params.append('ngayLam', dateToSave);
        params.append('gioBatDau', startTime);
        params.append('gioKetThuc', endTime);
        params.append('tenCa', document.getElementById('shiftTemplate').value);
        params.append('viTri', document.getElementById('shiftRole').value);
        params.append('trangThai', document.getElementById('shiftStatusOption').value);
        params.append('gioNghi', document.getElementById('shiftBreakTime').value || '0');
        params.append('ghiChu', document.getElementById('shiftNotes').value);
        
        return fetch(`\${_ctxPath}/manager/ca-lam`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: params.toString()
        }).then(res => res.json());
      });
      
      const results = await Promise.all(promises);
      
      const successes = results.filter(r => r.success);
      const errors = results.filter(r => !r.success);
      
      if (successes.length > 0) {
        showToast('success', `Đã phân ca thành công cho \${successes.length} ngày!`);
        // Collect and show warnings from all successful responses
        const allWarnings = successes.flatMap(r => r.warnings || []);
        if (allWarnings.length > 0) {
          [...new Set(allWarnings)].forEach(w => showToast('warning', w));
        }
        const dateStrings = checkedCheckboxes.map(cb => getWeekdayAndDateStr(cb.value));
        const datesFormattedText = dateStrings.join(', ');
        showSuccessBanner(staffName, startTime, endTime, datesFormattedText);
        await loadScheduleData();
        resetForm();
        scrollToCalendar();
      }
      
      if (errors.length > 0) {
        const errorMsgs = [...new Set(errors.map(e => e.error))].join('; ');
        showToast('error', `Có \${errors.length} lỗi xảy ra: \${errorMsgs}`);
      }
    }
  } catch (err) {
    console.error(err);
    showToast('error', 'Đã xảy ra lỗi trong quá trình xử lý');
  } finally {
    submitBtn.disabled = false;
    submitBtn.innerHTML = originalBtnText;
  }
}

function switchScheduleView(viewMode) {
  // Logic giữ nguyên như trước (đổi qua lại Lịch / Bảng)
  const tableView = document.getElementById('tableView');
  const calendarView = document.getElementById('calendarView');
  const tableBtn = document.getElementById('viewTableBtn');
  const calendarBtn = document.getElementById('viewCalendarBtn');

  if (viewMode == 'table') {
    tableView.classList.remove('hidden'); calendarView.classList.add('hidden');
    tableBtn.classList.add('bg-white', 'text-purple-700', 'shadow-sm'); tableBtn.classList.remove('text-purple-600', 'hover:text-purple-700');
    calendarBtn.classList.remove('bg-white', 'text-purple-700', 'shadow-sm'); calendarBtn.classList.add('text-purple-600', 'hover:text-purple-700');
  } else if (viewMode == 'calendar') {
    tableView.classList.add('hidden'); calendarView.classList.remove('hidden');
    calendarBtn.classList.add('bg-white', 'text-purple-700', 'shadow-sm'); calendarBtn.classList.remove('text-purple-600', 'hover:text-purple-700');
    tableBtn.classList.remove('bg-white', 'text-purple-700', 'shadow-sm'); tableBtn.classList.add('text-purple-600', 'hover:text-purple-700');
    renderCalendar();
  }
}

// ================= Lịch Tuần (Calendar) Helper =================
function getMonday(date) { const d = new Date(date); const day = d.getDay(); const diff = d.getDate() - day + (day === 0 ? -6 : 1); return new Date(d.setDate(diff)); }
let currentWeekStart = getMonday(new Date());
function changeWeek(direction) { currentWeekStart.setDate(currentWeekStart.getDate() + (direction * 7)); renderCalendar(); }

function renderCalendar() {
  const grid = document.getElementById('calendarGrid');
  const weekRangeDisplay = document.getElementById('weekRangeDisplay');
  const weekEnd = new Date(currentWeekStart); weekEnd.setDate(weekEnd.getDate() + 6);
  const formatDateVN = (date) => date.getDate() + '/' + (date.getMonth() + 1);
  weekRangeDisplay.textContent = formatDateVN(currentWeekStart) + ' - ' + formatDateVN(weekEnd);

  const days = [];
  for (let i = 0; i < 7; i++) { const dayDate = new Date(currentWeekStart); dayDate.setDate(dayDate.getDate() + i); days.push(dayDate); }

  const shiftsByDate = {};
  days.forEach(day => { const dateStr = day.toISOString().split('T')[0]; shiftsByDate[dateStr] = shiftList.filter(s => s.ngayLam === dateStr); });

  let html = '<div class="grid grid-cols-7 gap-4">';
  days.forEach(day => {
    const dateStr = day.toISOString().split('T')[0];
    const dayShifts = shiftsByDate[dateStr] || [];
    const dayName = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][day.getDay() === 0 ? 6 : day.getDay() - 1];
    const dateNum = day.getDate();
    const isToday = dateStr === new Date().toISOString().split('T')[0];

    html += `<div class="flex flex-col gap-2 min-h-[400px]">
        <div class="text-center pb-2 border-b border-purple-50">
          <p class="text-xs font-semibold text-purple-600 uppercase">\${dayName}</p>
          <p class="text-lg font-bold \${isToday ? 'text-purple-600' : 'text-zinc-800'}">\${dateNum}</p>
        </div>
        <div class="flex flex-col gap-2 flex-1">`;

    if (dayShifts.length === 0) {
      html += `<div class="text-center text-zinc-400 text-xs italic py-4">Không có ca</div>`;
    } else {
      dayShifts.sort((a, b) => a.gioBatDau.localeCompare(b.gioBatDau));
      dayShifts.forEach(s => {
        const staff = staffList.find(st => st.id === s.accountId);
        if (!staff) return;
        const timeFrame = formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc);
        const status = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);
        let roleColor = ''; let bgColor = '';
        if (staff.roleId === 4) { roleColor = 'text-green-600'; bgColor = 'bg-green-50 border-green-200 hover:bg-green-100'; } 
        else if (staff.roleId === 5) { roleColor = 'text-orange-600'; bgColor = 'bg-orange-50 border-orange-200 hover:bg-orange-100'; } 
        else { roleColor = 'text-blue-600'; bgColor = 'bg-blue-50 border-blue-200 hover:bg-blue-100'; }

        html += `<div class="shift-block \${bgColor} border rounded-lg p-2 cursor-pointer transition-all shadow-sm" onclick="editShift(\${s.caLamViecId})" title="Nhấn để chỉnh sửa">
            <div class="flex items-center justify-between mb-1">
              <span class="text-[10px] font-bold \${roleColor}">\${s.tenCa || 'Tùy chỉnh'}</span>
              <span class="text-[9px] px-1 py-0.5 rounded \${status.cssClass}">\${status.label}</span>
            </div>
            <p class="text-[11px] font-bold text-zinc-700 mb-1">\${timeFrame}</p>
            <div class="flex items-center gap-2">
              <div class="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">\${staff.fullName.substring(0, 1).toUpperCase()}</div>
              <p class="text-xs text-zinc-650 truncate">\${staff.fullName}</p>
            </div>
          </div>`;
      });
    }
    html += `</div></div>`;
  });
  html += '</div>';
  grid.innerHTML = html;
}

document.addEventListener('DOMContentLoaded', () => {
  // Populate staff dropdown
  populateStaffDropdown(null);

  // Set date picker to today and build weekdays
  const shiftDateInput = document.getElementById('shiftDate');
  if (shiftDateInput) {
    shiftDateInput.value = new Date().toISOString().split('T')[0];
    updateWeekDays();
  }

  // Default to Calendar view to see the weekly schedule diagram directly under the form
  switchScheduleView('calendar');

  // Load pending swap requests on page load
  loadSwapRequests();

  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => { document.getElementById('sidebar').classList.toggle('-translate-x-full'); });
  }
});

// ============================================================
// ADVANCED ACTIONS: state + helpers
// ============================================================
let _pendingUpdateParams = null;
let _pendingUpdateStaffName = '';
let _pendingUpdateStartTime = '';
let _pendingUpdateEndTime = '';
let _pendingUpdateDateToSave = '';

function getMondayStr(dateStr) {
  const d = new Date(dateStr);
  const day = d.getDay();
  const monday = new Date(dateStr);
  monday.setDate(d.getDate() - day + (day === 0 ? -6 : 1));
  return monday.toISOString().split('T')[0];
}

function showAdvancedWarnings(items) {
  const panel = document.getElementById('advancedActionsWarnings');
  const list = document.getElementById('advancedWarningsList');
  list.innerHTML = items.map(w => `<li>\${w}</li>`).join('');
  panel.classList.remove('hidden');
}

async function cloneWeekShifts() {
  const fromDate = document.getElementById('cloneFromWeek').value;
  const toDate = document.getElementById('cloneToWeek').value;
  if (!fromDate || !toDate) { showToast('error', 'Vui lòng chọn ngày thuộc tuần nguồn và tuần đích'); return; }
  const fromMonday = getMondayStr(fromDate);
  const toMonday = getMondayStr(toDate);
  if (fromMonday === toMonday) { showToast('error', 'Tuần nguồn và tuần đích không được trùng nhau'); return; }
  const params = new URLSearchParams({ action: 'cloneWeek', format: 'json', fromWeek: fromMonday, toWeek: toMonday });
  try {
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    }).then(r => r.json());
    if (res.success) {
      showToast('success', res.message || 'Nhân bản lịch tuần thành công!');
      if (res.warnings && res.warnings.length > 0) showAdvancedWarnings(res.warnings);
      else document.getElementById('advancedActionsWarnings').classList.add('hidden');
      await loadScheduleData();
    } else {
      showToast('error', res.error || 'Nhân bản thất bại');
    }
  } catch (e) { showToast('error', 'Lỗi kết nối'); }
}

async function publishWeekShifts() {
  const weekDate = document.getElementById('publishWeekDate').value;
  if (!weekDate) { showToast('error', 'Vui lòng chọn ngày thuộc tuần cần công bố'); return; }
  const weekMonday = getMondayStr(weekDate);
  if (!confirm(`Công bố lịch làm việc tuần bắt đầu từ \${weekMonday}?\nNhân viên sẽ nhận thông báo.`)) return;
  const params = new URLSearchParams({ action: 'publishWeek', format: 'json', weekStart: weekMonday });
  try {
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    }).then(r => r.json());
    if (res.success) {
      showToast('success', 'Công bố lịch tuần thành công!');
      if (res.warnings && res.warnings.length > 0) showAdvancedWarnings(res.warnings);
      else document.getElementById('advancedActionsWarnings').classList.add('hidden');
      await loadScheduleData();
    } else {
      showToast('error', res.error || 'Công bố thất bại');
    }
  } catch (e) { showToast('error', 'Lỗi kết nối'); }
}

async function autoScheduleShifts() {
  const start = document.getElementById('autoStartDate').value;
  const end = document.getElementById('autoEndDate').value;
  if (!start || !end) { showToast('error', 'Vui lòng chọn khoảng ngày'); return; }
  const params = new URLSearchParams({ action: 'autoSchedule', format: 'json', startDate: start, endDate: end });
  try {
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    }).then(r => r.json());
    if (res.success) { showToast('success', res.message || 'Sắp lịch tự động hoàn tất!'); await loadScheduleData(); }
    else { showToast('error', res.error || 'Sắp lịch thất bại'); }
  } catch (e) { showToast('error', 'Lỗi kết nối'); }
}

// ============================================================
// CONFIRMED OVERRIDE HANDLING
// ============================================================
async function confirmOverrideAndSave() {
  const reason = document.getElementById('overrideReasonInput').value.trim();
  if (!reason) { showToast('error', 'Vui lòng nhập lý do thay đổi'); return; }
  document.getElementById('confirmedOverrideModal').classList.add('hidden');
  if (!_pendingUpdateParams) return;

  _pendingUpdateParams.set('overrideConfirm', 'true');
  _pendingUpdateParams.set('reason', reason);

  const submitBtn = document.getElementById('btnSubmitShift');
  submitBtn.disabled = true;
  try {
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: _pendingUpdateParams.toString()
    }).then(r => r.json());

    if (res.success) {
      showToast('success', 'Đã cập nhật ca làm việc thành công!');
      if (res.warnings && res.warnings.length > 0) res.warnings.forEach(w => showToast('warning', w));
      showSuccessBanner(_pendingUpdateStaffName, _pendingUpdateStartTime, _pendingUpdateEndTime, getWeekdayAndDateStr(_pendingUpdateDateToSave));
      await loadScheduleData();
      resetForm();
      scrollToCalendar();
    } else {
      showToast('error', res.error || 'Cập nhật thất bại');
    }
  } catch (e) {
    showToast('error', 'Lỗi kết nối');
  } finally {
    submitBtn.disabled = false;
    _pendingUpdateParams = null;
  }
}

// ============================================================
// SWAP REQUESTS
// ============================================================
let _swapList = [];

async function loadSwapRequests() {
  try {
    const data = await fetch(`\${_ctxPath}/manager/ca-lam?format=json`).then(r => r.json());
    _swapList = (data.swaps || []).filter(s => s.trangThai === 'ChoQuanLyDuyet');
    renderSwapRequests();
  } catch (e) { console.error('loadSwapRequests error', e); }
}

function renderSwapRequests() {
  const container = document.getElementById('swapRequestsContainer');
  const badge = document.getElementById('swapBadge');

  if (_swapList.length === 0) {
    badge.classList.add('hidden');
    container.innerHTML = `<div class="text-center py-8 text-zinc-400 text-sm flex flex-col items-center gap-2">
      <span class="material-symbols-outlined text-[36px] text-zinc-200">swap_horiz</span>
      Không có yêu cầu đổi ca nào đang chờ duyệt
    </div>`;
    return;
  }

  badge.textContent = _swapList.length;
  badge.classList.remove('hidden');

  const rows = _swapList.map(sr => {
    const guiShift = shiftList.find(s => s.caLamViecId === sr.caLamViecIdGui);
    const nhanShift = sr.caLamViecIdNhan ? shiftList.find(s => s.caLamViecId === sr.caLamViecIdNhan) : null;
    const fmtShift = s => s ? `\${formatDate(s.ngayLam)} \${formatTime(s.gioBatDau)}-\${formatTime(s.gioKetThuc)}` : 'N/A';
    const nhanInfo = nhanShift ? fmtShift(nhanShift) : '<span class="text-zinc-400 italic">Nhường ca</span>';
    const swapId = sr.swapId || sr.id || 0;
    const labelSafe = `\${(sr.tenNguoiGui || 'N/A')} ↔ \${(sr.tenNguoiNhan || 'N/A')}`;

    return `<tr class="hover:bg-purple-50/30 transition-colors">
      <td class="px-4 py-3">
        <div class="flex items-center gap-2">
          <div class="w-7 h-7 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">\${(sr.tenNguoiGui || 'N')[0].toUpperCase()}</div>
          <span class="text-xs font-semibold text-purple-950">\${sr.tenNguoiGui || 'N/A'}</span>
        </div>
      </td>
      <td class="px-4 py-3 text-xs font-medium text-zinc-700">\${fmtShift(guiShift)}</td>
      <td class="px-4 py-3">
        <div class="flex items-center gap-2">
          <div class="w-7 h-7 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center text-[10px] font-bold">\${(sr.tenNguoiNhan || 'N')[0].toUpperCase()}</div>
          <span class="text-xs font-semibold text-blue-950">\${sr.tenNguoiNhan || 'N/A'}</span>
        </div>
      </td>
      <td class="px-4 py-3 text-xs text-zinc-700">\${nhanInfo}</td>
      <td class="px-4 py-3 text-xs text-zinc-500 max-w-[120px] truncate" title="\${sr.lyDo || ''}">\${sr.lyDo || '-'}</td>
      <td class="px-4 py-3">
        <div class="flex items-center justify-end gap-1.5">
          <button onclick="openSwapAction(\${swapId}, 'approve', \`\${labelSafe}\`)"
                  class="px-3 py-1.5 rounded-lg bg-emerald-100 hover:bg-emerald-200 text-emerald-700 text-xs font-semibold transition-colors flex items-center gap-1">
            <span class="material-symbols-outlined text-[13px]">check_circle</span> Duyệt
          </button>
          <button onclick="openSwapAction(\${swapId}, 'reject', \`\${labelSafe}\`)"
                  class="px-3 py-1.5 rounded-lg bg-red-100 hover:bg-red-200 text-red-700 text-xs font-semibold transition-colors flex items-center gap-1">
            <span class="material-symbols-outlined text-[13px]">cancel</span> Từ chối
          </button>
        </div>
      </td>
    </tr>`;
  }).join('');

  container.innerHTML = `<div class="overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-purple-50/50 border-b border-purple-100">
        <tr>
          <th class="px-4 py-3 text-left text-xs font-semibold text-purple-900">Người gửi</th>
          <th class="px-4 py-3 text-left text-xs font-semibold text-purple-900">Ca của người gửi</th>
          <th class="px-4 py-3 text-left text-xs font-semibold text-purple-900">Người nhận</th>
          <th class="px-4 py-3 text-left text-xs font-semibold text-purple-900">Ca của người nhận</th>
          <th class="px-4 py-3 text-left text-xs font-semibold text-purple-900">Lý do</th>
          <th class="px-4 py-3 text-right text-xs font-semibold text-purple-900">Thao tác</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-purple-50/70">\${rows}</tbody>
    </table>
  </div>`;
}

function openSwapAction(swapId, type, label) {
  document.getElementById('swapActionId').value = swapId;
  document.getElementById('swapActionType').value = type;
  document.getElementById('swapNotesInput').value = '';
  document.getElementById('swapModalSub').textContent = label;

  const iconWrap = document.getElementById('swapModalIconWrap');
  const iconSym = document.getElementById('swapModalIconSymbol');
  const title = document.getElementById('swapModalTitle');
  const btn = document.getElementById('swapConfirmBtn');

  if (type === 'approve') {
    iconWrap.className = 'w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center shrink-0';
    iconSym.className = 'material-symbols-outlined text-emerald-600 text-[22px]';
    iconSym.textContent = 'check_circle';
    title.textContent = 'Phê duyệt đổi ca';
    btn.className = 'h-10 px-6 rounded-xl bg-emerald-600 text-white text-sm font-semibold hover:bg-emerald-700 transition-colors flex items-center gap-2';
    btn.innerHTML = '<span class="material-symbols-outlined text-[16px]">check_circle</span> Phê duyệt';
  } else {
    iconWrap.className = 'w-10 h-10 rounded-full bg-red-100 flex items-center justify-center shrink-0';
    iconSym.className = 'material-symbols-outlined text-red-600 text-[22px]';
    iconSym.textContent = 'cancel';
    title.textContent = 'Từ chối yêu cầu đổi ca';
    btn.className = 'h-10 px-6 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700 transition-colors flex items-center gap-2';
    btn.innerHTML = '<span class="material-symbols-outlined text-[16px]">cancel</span> Từ chối';
  }
  document.getElementById('swapActionModal').classList.remove('hidden');
}

async function confirmSwapAction() {
  const swapId = document.getElementById('swapActionId').value;
  const type = document.getElementById('swapActionType').value;
  const notes = document.getElementById('swapNotesInput').value.trim();
  document.getElementById('swapActionModal').classList.add('hidden');

  const params = new URLSearchParams({
    action: type === 'approve' ? 'approveSwap' : 'rejectSwap',
    format: 'json',
    id: swapId,
    notes
  });

  try {
    const res = await fetch(`\${_ctxPath}/manager/ca-lam`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    }).then(r => r.json());

    if (res.success) {
      showToast('success', type === 'approve' ? 'Đã phê duyệt yêu cầu đổi ca!' : 'Đã từ chối yêu cầu đổi ca!');
      await loadScheduleData();
    } else {
      showToast('error', res.error || 'Thao tác thất bại');
    }
  } catch (e) {
    showToast('error', 'Lỗi kết nối');
  }
}

// Reload page when navigated back/forward via bfcache
window.addEventListener('pageshow', function(event) {
  if (event.persisted) {
    window.location.reload();
  }
});
</script>

</body>
</html>