<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${pageTitle}</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background: #fff; border: 1px solid #f3e8ff; border-radius: 16px; transition: box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow: 0 8px 24px -8px rgba(139, 92, 246, 0.12); transform: translateY(-2px); }
  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
  .badge-green { background: #dcfce7; color: #15803d; }
  .badge-amber { background: #fef3c7; color: #b45309; }
  .badge-red { background: #fee2e2; color: #b91c1c; }
  .badge-purple { background: #f3e8ff; color: #7e22ce; }
  .badge-gray { background: #f4f4f5; color: #52525b; }
  .tab-btn { transition: all .15s; }
  .tab-btn.active { border-color: #7c3aed; color: #7c3aed; font-weight: 700; }
  ::-webkit-scrollbar { width: 6px; height: 6px }
  ::-webkit-scrollbar-track { background: transparent }
  ::-webkit-scrollbar-thumb { background: #ddd6fe; border-radius: 6px }
  ::-webkit-scrollbar-thumb:hover { background: #c084fc; }
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  main > section { animation: fadeUp .3s ease both; }
  .tab-content { display: none; animation: fadeUp .25s ease both; }
  .tab-content.active { display: block; }
</style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar Manager -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-600"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-purple-950 tracking-tight">Quản lý Khách hàng</h1>
      <p class="text-xs text-purple-550 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">groups</span>Phân tích tệp khách hàng tại CS${sessionScope.user.coSoId}</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button class="relative p-2 rounded-lg hover:bg-purple-50 text-purple-650">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-purple-650"></span>
    </button>
    <div class="w-px h-6 bg-purple-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Overview Tab Navigation -->
  <section class="border-b border-purple-100 bg-white p-3 rounded-2xl border flex gap-1.5 shadow-sm">
    <button onclick="switchTab('tab-directory')" id="btn-tab-directory" class="tab-btn active px-4 py-2 text-xs font-semibold border-b-2 border-transparent text-zinc-550 hover:text-purple-700 flex items-center gap-1.5">
      <span class="material-symbols-outlined text-[16px]">stars</span>Khách hàng & VIP
    </button>
    <button onclick="switchTab('tab-reviews')" id="btn-tab-reviews" class="tab-btn px-4 py-2 text-xs font-semibold border-b-2 border-transparent text-zinc-550 hover:text-purple-700 flex items-center gap-1.5">
      <span class="material-symbols-outlined text-[16px]">reviews</span>Đánh giá / Phản hồi
    </button>
    <button onclick="switchTab('tab-risk')" id="btn-tab-risk" class="tab-btn px-4 py-2 text-xs font-semibold border-b-2 border-transparent text-zinc-550 hover:text-purple-700 flex items-center gap-1.5 relative">
      <span class="material-symbols-outlined text-[16px]">warning</span>Cảnh báo rủi ro
      <c:if test="${not empty riskBookings || not empty riskCancelers}">
        <span class="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-red-500 border-2 border-white"></span>
      </c:if>
    </button>
  </section>

  <!-- ================= TAB 1: CUSTOMERS DIRECTORY (VIP & REPEAT) ================= -->
  <section id="tab-directory" class="tab-content active flex flex-col gap-5">
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-5">
      
      <!-- Column 1: Top VIP Customers -->
      <div class="card p-5">
        <div class="flex items-center justify-between mb-4 pb-3 border-b border-purple-50">
          <div>
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2">
              <span class="material-symbols-outlined text-amber-500 fill-amber-500 text-[18px]">workspace_premium</span>Khách VIP chi tiêu cao nhất
            </h3>
            <p class="text-[10px] text-zinc-400 mt-0.5">Xếp hạng theo tổng giá trị thanh toán đặt sân tại cơ sở</p>
          </div>
          <span class="badge badge-purple">Top 10 VIP</span>
        </div>

        <div class="flex flex-col gap-4">
          <c:if test="${empty vipCustomers}">
            <div class="text-center text-zinc-400 p-8 text-xs">Chưa có lịch đặt sân hoàn tất nào để xếp hạng VIP.</div>
          </c:if>
          
          <c:forEach items="${vipCustomers}" var="cust" varStatus="status">
            <div class="flex items-center gap-3 p-3.5 rounded-xl bg-zinc-50/50 hover:bg-purple-50/10 border border-purple-50/40 transition-colors">
              <div class="w-8 h-8 rounded-full bg-amber-100 text-amber-800 flex items-center justify-center font-bold text-xs shrink-0">
                ${status.index + 1}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <p class="text-xs font-bold text-zinc-800 truncate">${cust[1] != null ? cust[1] : cust[2]}</p>
                  <p class="text-xs font-black text-purple-950">
                    <fmt:formatNumber value="${cust[5]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                  </p>
                </div>
                <div class="flex items-center justify-between text-[10px] text-zinc-400 mt-1">
                  <span>${cust[3]}</span>
                  <span class="font-semibold text-purple-700">${cust[4]} lượt đặt thành công</span>
                </div>
                
                <!-- Relative spending progress bar -->
                <div class="w-full bg-zinc-200 h-1.5 rounded-full mt-2">
                  <c:set var="maxVipSpent" value="${vipCustomers[0][5]}" />
                  <c:set var="percent" value="${(cust[5] * 100) / maxVipSpent}" />
                  <div class="bg-gradient-to-r from-amber-400 to-amber-600 h-1.5 rounded-full" style="width: ${percent > 100 ? 100 : (percent < 5 ? 5 : percent)}%"></div>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <!-- Column 2: Top Repeat Customers -->
      <div class="card p-5">
        <div class="flex items-center justify-between mb-4 pb-3 border-b border-purple-50">
          <div>
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2">
              <span class="material-symbols-outlined text-purple-600 text-[18px]">replay</span>Top khách hàng thân thiết
            </h3>
            <p class="text-[10px] text-zinc-400 mt-0.5">Xếp hạng theo số lượt đặt sân hoàn thành tại cơ sở</p>
          </div>
          <span class="badge badge-purple">Lặp lại nhiều nhất</span>
        </div>

        <div class="flex flex-col gap-4">
          <c:if test="${empty repeatCustomers}">
            <div class="text-center text-zinc-400 p-8 text-xs">Chưa có lịch đặt sân nào được hoàn tất.</div>
          </c:if>

          <c:forEach items="${repeatCustomers}" var="cust" varStatus="status">
            <div class="flex items-center gap-3 p-3.5 rounded-xl bg-zinc-50/50 hover:bg-purple-50/10 border border-purple-50/40 transition-colors">
              <div class="w-8 h-8 rounded-full bg-purple-100 text-purple-800 flex items-center justify-center font-bold text-xs shrink-0">
                ${status.index + 1}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <p class="text-xs font-bold text-zinc-800 truncate">${cust[1] != null ? cust[1] : cust[2]}</p>
                  <span class="badge badge-green">${cust[4]} lượt đặt</span>
                </div>
                <div class="flex items-center justify-between text-[10px] text-zinc-400 mt-1">
                  <span>${cust[3]}</span>
                  <span>Đã chi tiêu: <span class="font-bold text-purple-950"><fmt:formatNumber value="${cust[5]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span></span>
                </div>
                
                <!-- Relative booking count progress bar -->
                <div class="w-full bg-zinc-200 h-1.5 rounded-full mt-2">
                  <c:set var="maxRepeatCount" value="${repeatCustomers[0][4]}" />
                  <c:set var="percentCount" value="${(cust[4] * 100) / maxRepeatCount}" />
                  <div class="bg-gradient-to-r from-purple-550 to-indigo-600 h-1.5 rounded-full" style="width: ${percentCount > 100 ? 100 : (percentCount < 5 ? 5 : percentCount)}%"></div>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

    </div>
  </section>

  <!-- ================= TAB 2: REVIEWS & FEEDBACK ================= -->
  <section id="tab-reviews" class="tab-content flex flex-col gap-5">
    <div class="card p-5">
      <div class="flex items-center justify-between mb-4 pb-3 border-b border-purple-50">
        <div>
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2">
            <span class="material-symbols-outlined text-purple-700 text-[18px]">rate_review</span>Phản hồi từ khách hàng
          </h3>
          <p class="text-[10px] text-zinc-400 mt-0.5">Các đánh giá sao và bình luận về cơ sở được gửi từ người chơi</p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <c:if test="${empty reviews}">
          <div class="col-span-2 text-center text-zinc-400 p-12 text-xs">Cơ sở chưa có đánh giá nào từ khách hàng.</div>
        </c:if>

        <c:forEach items="${reviews}" var="rev">
          <div class="p-4 rounded-2xl border border-purple-50 bg-zinc-50/30 flex flex-col gap-3 card-hover">
            <div class="flex items-start justify-between">
              <div class="flex items-center gap-2">
                <div class="w-8 h-8 rounded-xl bg-purple-100 text-purple-850 font-bold text-xs flex items-center justify-center">
                  ${rev[4] != null ? rev[4].substring(0,1).toUpperCase() : rev[5].substring(0,1).toUpperCase()}
                </div>
                <div>
                  <p class="text-xs font-bold text-zinc-800">${rev[4] != null && rev[4].length() > 0 ? rev[4] : rev[5]}</p>
                  <p class="text-[9px] text-zinc-400">
                    <fmt:parseDate value="${rev[3]}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </p>
                </div>
              </div>
              <div class="flex gap-0.5">
                <c:forEach begin="1" end="5" var="i">
                  <svg class="w-3.5 h-3.5 ${i <= rev[1] ? 'text-amber-400 fill-amber-400' : 'text-zinc-300 fill-zinc-200'}" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
                </c:forEach>
              </div>
            </div>

            <p class="text-xs text-zinc-650 italic bg-white p-3 rounded-xl border border-purple-50/50">
              "${rev[2] != null ? rev[2] : 'Khách hàng không để lại bình luận.'}"
            </p>

            <div class="flex items-center gap-1.5 text-[10px] text-purple-700 font-semibold mt-1">
              <span class="material-symbols-outlined text-[13px]">stadium</span>
              <span>Sân đánh giá: ${rev[6]}</span>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>
  </section>

  <!-- ================= TAB 3: RISK ALERTS & WARNINGS ================= -->
  <section id="tab-risk" class="tab-content flex flex-col gap-5">
    
    <!-- Subsection 1: Unpaid Pending Bookings Today (Booking Risk) -->
    <div class="card p-5">
      <div class="flex items-center justify-between mb-4 pb-3 border-b border-purple-50">
        <div>
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2">
            <span class="material-symbols-outlined text-red-500 text-[18px]">event_busy</span>Lịch đặt cận giờ chưa thanh toán
          </h3>
          <p class="text-[10px] text-zinc-400 mt-0.5">Các lịch đặt sân hôm nay hoặc ngày mai ở trạng thái "Chờ thanh toán" - Nguy cơ khách không đến hoặc hủy sát giờ</p>
        </div>
        <span class="badge badge-red">${riskBookings.size()} cảnh báo</span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse text-xs">
          <thead>
            <tr class="bg-red-50/40 text-red-950 font-bold border-b border-red-100">
              <th class="p-3">Khách hàng</th>
              <th class="p-3">Sân bóng</th>
              <th class="p-3 text-center">Ngày đặt</th>
              <th class="p-3 text-center">Khung giờ</th>
              <th class="p-3 text-right">Tổng tiền dự kiến</th>
              <th class="p-3 text-center">Trạng thái rủi ro</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-red-50/50">
            <c:if test="${empty riskBookings}">
              <tr>
                <td colspan="6" class="p-6 text-center text-zinc-400">Không phát hiện lịch đặt cận giờ chưa thanh toán nào.</td>
              </tr>
            </c:if>
            <c:forEach items="${riskBookings}" var="risk">
              <tr class="hover:bg-red-50/5 transition-colors">
                <td class="p-3 font-semibold text-zinc-800">${risk[5] != null ? risk[5] : risk[6]}</td>
                <td class="p-3 text-purple-700 font-semibold">${risk[7]}</td>
                <td class="p-3 text-center">${risk[1]}</td>
                <td class="p-3 text-center font-bold text-zinc-700">${risk[2]} – ${risk[3]}</td>
                <td class="p-3 text-right font-bold text-zinc-900">
                  <fmt:formatNumber value="${risk[4]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </td>
                <td class="p-3 text-center">
                  <span class="badge badge-amber flex gap-1 items-center justify-center"><span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>Cần xác nhận</span>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Subsection 2: Accounts with High Cancellation Rate (Cancellation Risk) -->
    <div class="card p-5">
      <div class="flex items-center justify-between mb-4 pb-3 border-b border-purple-50">
        <div>
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2">
            <span class="material-symbols-outlined text-red-500 text-[18px]">warning_amber</span>Khách hàng có tần suất hủy cao
          </h3>
          <p class="text-[10px] text-zinc-400 mt-0.5">Khách hàng đã đặt từ 3 lần trở lên nhưng có tỷ lệ hủy lịch trên 30% tại chi nhánh</p>
        </div>
        <span class="badge badge-red">${riskCancelers.size()} tài khoản</span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse text-xs">
          <thead>
            <tr class="bg-purple-50/40 text-purple-950 font-bold border-b border-purple-100">
              <th class="p-3">Tên khách hàng</th>
              <th class="p-3">Email liên hệ</th>
              <th class="p-3 text-center">Tổng lịch đặt</th>
              <th class="p-3 text-center">Số lần hủy</th>
              <th class="p-3 text-center">Tỷ lệ hủy</th>
              <th class="p-3 text-center">Mức độ rủi ro</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-purple-50">
            <c:if test="${empty riskCancelers}">
              <tr>
                <td colspan="6" class="p-6 text-center text-zinc-400">Không có khách hàng nào có tỷ lệ hủy lịch cao vượt ngưỡng.</td>
              </tr>
            </c:if>
            <c:forEach items="${riskCancelers}" var="canc">
              <tr class="hover:bg-purple-50/5 transition-colors">
                <td class="p-3 font-semibold text-zinc-800">${canc[1] != null ? canc[1] : canc[2]}</td>
                <td class="p-3 text-zinc-500">${canc[3]}</td>
                <td class="p-3 text-center font-semibold text-zinc-700">${canc[4]}</td>
                <td class="p-3 text-center font-bold text-red-650">${canc[5]}</td>
                <td class="p-3 text-center">
                  <span class="text-red-600 font-black"><fmt:formatNumber value="${canc[6]}" maxFractionDigits="1"/>%</span>
                </td>
                <td class="p-3 text-center">
                  <span class="badge badge-red">Rủi ro cao</span>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </section>

</main>

<script>
  // Mobile menu toggle
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  // Tab switching logic
  function switchTab(tabId) {
    // Hide all tab contents
    const contents = document.querySelectorAll('.tab-content');
    contents.forEach(c => c.classList.remove('active'));

    // Remove active styles from buttons
    const buttons = document.querySelectorAll('.tab-btn');
    buttons.forEach(b => b.classList.remove('active'));

    // Show selected tab content
    document.getElementById(tabId).classList.add('active');

    // Add active style to selected button
    document.getElementById('btn-' + tabId).classList.add('active');
  }
</script>
</body>
</html>
