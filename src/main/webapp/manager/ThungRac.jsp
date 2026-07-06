<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Thùng rác chi nhánh — V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
</head>
<body class="text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<c:set var="headerTitle" value="Thùng rác chi nhánh" scope="page" />
<c:set var="headerSubtitle" value="Cơ sở CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="delete" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Header section -->
  <section class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-purple-950">Quản lý mục đã xóa</h2>
      <p class="text-xs text-purple-500 mt-1">Nơi khôi phục hoặc xóa vĩnh viễn các thông tin đã bị xóa mềm.</p>
    </div>
  </section>

  <!-- Alert Messages -->
  <c:if test="${not empty sessionScope.errorMsg}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-650 text-sm flex items-start gap-3 shadow-sm">
      <span class="material-symbols-outlined text-[20px] text-red-600 shrink-0">error</span>
      <div>
        <span class="font-bold block text-red-700">Lỗi</span>
        <span class="text-red-650/95 leading-normal block mt-0.5">${sessionScope.errorMsg}</span>
      </div>
    </div>
    <c:remove var="errorMsg" scope="session" />
  </c:if>

  <c:if test="${not empty sessionScope.successMsg}">
    <div class="p-4 bg-green-50 border border-green-100 rounded-xl text-green-650 text-sm flex items-start gap-3 shadow-sm">
      <span class="material-symbols-outlined text-[20px] text-green-600 shrink-0">check_circle</span>
      <div>
        <span class="font-bold block text-green-700">Thành công</span>
        <span class="text-green-650/95 leading-normal block mt-0.5">${sessionScope.successMsg}</span>
      </div>
    </div>
    <c:remove var="successMsg" scope="session" />
  </c:if>

  <!-- Navigation Tabs -->
  <section class="flex border-b border-purple-100 gap-6 overflow-x-auto pb-px">
    <button id="tabBtn-san" onclick="switchTab('san')" class="tab-btn pb-3 text-sm font-bold border-b-2 border-purple-600 text-purple-600 flex items-center gap-2 transition-all whitespace-nowrap">
      <span class="material-symbols-outlined text-[18px]">stadium</span>Sân thi đấu
    </button>
    <button id="tabBtn-loaisan" onclick="switchTab('loaisan')" class="tab-btn pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all whitespace-nowrap">
      <span class="material-symbols-outlined text-[18px]">category</span>Loại sân
    </button>
    <button id="tabBtn-sanpham" onclick="switchTab('sanpham')" class="tab-btn pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all whitespace-nowrap">
      <span class="material-symbols-outlined text-[18px]">inventory_2</span>Kho & Dịch vụ
    </button>
    <button id="tabBtn-nhansu" onclick="switchTab('nhansu')" class="tab-btn pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all whitespace-nowrap">
      <span class="material-symbols-outlined text-[18px]">groups</span>Nhân sự
    </button>
  </section>

  <!-- TAB CONTENTS -->
  
  <!-- 1. SÂN THI ĐẤU -->
  <div id="tabContent-san" class="tab-content-panel flex flex-col gap-4">
    <div class="card p-6">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-sm border-collapse">
          <thead>
            <tr class="border-b border-purple-50 text-purple-900 font-bold text-xs uppercase tracking-wider">
              <th class="pb-3 pl-2">Tên sân</th>
              <th class="pb-3">Trạng thái</th>
              <th class="pb-3">Mô tả</th>
              <th class="pb-3 text-right pr-4">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty deletedSans}">
                <tr>
                  <td colspan="4" class="py-8 text-center text-zinc-400 font-medium">Thùng rác trống.</td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="s" items="${deletedSans}">
                  <tr class="border-b border-purple-50 hover:bg-purple-50/10 transition-colors">
                    <td class="py-4 pl-2 font-semibold text-purple-950">${s.tenSan}</td>
                    <td class="py-4">
                      <span class="badge badge-gray">${s.trangThai}</span>
                    </td>
                    <td class="py-4 text-zinc-500 max-w-xs truncate">${s.moTa}</td>
                    <td class="py-4 text-right pr-4 flex items-center justify-end gap-2">
                      <button onclick="performAction('restore', 'san', ${s.sanID})" class="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">settings_backup_restore</span>Khôi phục
                      </button>
                      <button onclick="performAction('delete', 'san', ${s.sanID})" class="flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-700 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">delete_forever</span>Xóa vĩnh viễn
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- 2. LOẠI SÂN -->
  <div id="tabContent-loaisan" class="tab-content-panel hidden flex flex-col gap-4">
    <div class="card p-6">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-sm border-collapse">
          <thead>
            <tr class="border-b border-purple-50 text-purple-900 font-bold text-xs uppercase tracking-wider">
              <th class="pb-3 pl-2">Tên loại</th>
              <th class="pb-3">Giá không đèn</th>
              <th class="pb-3">Giá có đèn</th>
              <th class="pb-3 text-right pr-4">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty deletedLoaiSans}">
                <tr>
                  <td colspan="4" class="py-8 text-center text-zinc-400 font-medium">Thùng rác trống.</td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="ls" items="${deletedLoaiSans}">
                  <tr class="border-b border-purple-50 hover:bg-purple-50/10 transition-colors">
                    <td class="py-4 pl-2 font-semibold text-purple-950">${ls.tenLoai}</td>
                    <td class="py-4 text-purple-800 font-semibold">
                      <fmt:formatNumber value="${ls.giaKhongDen}" type="number" />đ/h
                    </td>
                    <td class="py-4 text-purple-800 font-semibold">
                      <fmt:formatNumber value="${ls.giaCoDen}" type="number" />đ/h
                    </td>
                    <td class="py-4 text-right pr-4 flex items-center justify-end gap-2">
                      <button onclick="performAction('restore', 'loaisan', ${ls.loaiSanID})" class="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">settings_backup_restore</span>Khôi phục
                      </button>
                      <button onclick="performAction('delete', 'loaisan', ${ls.loaiSanID})" class="flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-700 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">delete_forever</span>Xóa vĩnh viễn
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- 3. KHO & DỊCH VỤ -->
  <div id="tabContent-sanpham" class="tab-content-panel hidden flex flex-col gap-4">
    <div class="card p-6">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-sm border-collapse">
          <thead>
            <tr class="border-b border-purple-50 text-purple-900 font-bold text-xs uppercase tracking-wider">
              <th class="pb-3 pl-2">Mã SKU</th>
              <th class="pb-3">Tên sản phẩm</th>
              <th class="pb-3">Đơn giá</th>
              <th class="pb-3">Tồn kho</th>
              <th class="pb-3 text-right pr-4">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty deletedProducts}">
                <tr>
                  <td colspan="5" class="py-8 text-center text-zinc-400 font-medium">Thùng rác trống.</td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="sp" items="${deletedProducts}">
                  <tr class="border-b border-purple-50 hover:bg-purple-50/10 transition-colors">
                    <td class="py-4 pl-2 font-mono text-xs text-purple-700 font-bold">${sp.skuCode}</td>
                    <td class="py-4 font-semibold text-purple-950">${sp.tenSanPham}</td>
                    <td class="py-4 text-purple-800 font-semibold">
                      <fmt:formatNumber value="${sp.donGia}" type="number" />đ
                    </td>
                    <td class="py-4 text-zinc-600">${sp.soLuongTon} ${sp.donViTinh}</td>
                    <td class="py-4 text-right pr-4 flex items-center justify-end gap-2">
                      <button onclick="performAction('restore', 'sanpham', ${sp.sanPhamID})" class="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">settings_backup_restore</span>Khôi phục
                      </button>
                      <button onclick="performAction('delete', 'sanpham', ${sp.sanPhamID})" class="flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-700 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">delete_forever</span>Xóa vĩnh viễn
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- 4. NHÂN SỰ -->
  <div id="tabContent-nhansu" class="tab-content-panel hidden flex flex-col gap-4">
    <div class="card p-6">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-sm border-collapse">
          <thead>
            <tr class="border-b border-purple-50 text-purple-900 font-bold text-xs uppercase tracking-wider">
              <th class="pb-3 pl-2">Username</th>
              <th class="pb-3">Họ và tên</th>
              <th class="pb-3">Email</th>
              <th class="pb-3">Số điện thoại</th>
              <th class="pb-3 text-right pr-4">Hành động</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty deletedStaff}">
                <tr>
                  <td colspan="5" class="py-8 text-center text-zinc-400 font-medium">Thùng rác trống.</td>
                </tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="st" items="${deletedStaff}">
                  <tr class="border-b border-purple-50 hover:bg-purple-50/10 transition-colors">
                    <td class="py-4 pl-2 font-semibold text-purple-950">${st.username}</td>
                    <td class="py-4 font-medium text-zinc-800">${st.fullName}</td>
                    <td class="py-4 text-zinc-500">${st.email}</td>
                    <td class="py-4 text-zinc-500">${st.phoneNumber}</td>
                    <td class="py-4 text-right pr-4 flex items-center justify-end gap-2">
                      <button onclick="performAction('restore', 'nhansu', ${st.accountId})" class="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">settings_backup_restore</span>Khôi phục
                      </button>
                      <button onclick="performAction('delete', 'nhansu', ${st.accountId})" class="flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-700 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors">
                        <span class="material-symbols-outlined text-[14px]">delete_forever</span>Xóa vĩnh viễn
                      </button>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </div>
  </div>

</main>

<!-- Hidden action form -->
<form id="actionForm" action="${pageContext.request.contextPath}/manager/thung-rac" method="POST" class="hidden">
  <input type="hidden" name="action" id="formAction">
  <input type="hidden" name="type" id="formType">
  <input type="hidden" name="id" id="formId">
</form>

<script>
  function switchTab(tabName) {
      // Hide all panels
      document.querySelectorAll('.tab-content-panel').forEach(p => p.classList.add('hidden'));
      // Show chosen panel
      document.getElementById('tabContent-' + tabName).classList.remove('hidden');

      // Update button active states
      document.querySelectorAll('.tab-btn').forEach(btn => {
          btn.classList.remove('border-purple-600', 'text-purple-600', 'font-bold');
          btn.classList.add('border-transparent', 'text-purple-500', 'font-medium');
      });
      const activeBtn = document.getElementById('tabBtn-' + tabName);
      activeBtn.classList.remove('border-transparent', 'text-purple-500', 'font-medium');
      activeBtn.classList.add('border-purple-600', 'text-purple-600', 'font-bold');
  }

  function performAction(action, type, id) {
      if (action === 'delete') {
          let msg = 'Bạn có chắc chắn muốn xóa vĩnh viễn mục này? Hành động này sẽ xóa dữ liệu hoàn toàn khỏi hệ thống và không thể khôi phục.';
          if (type === 'nhansu') {
              msg = 'Cảnh báo về tài khoản này: Tài khoản nhân viên có thể đang liên kết với ca làm việc, yêu cầu nghỉ,... Việc xóa vĩnh viễn sẽ xóa sạch hoặc gỡ bỏ các liên kết này khỏi database. Bạn vẫn muốn tiếp tục xóa?';
          }
          if (!confirm(msg)) {
              return;
          }
      }
      document.getElementById('formAction').value = action;
      document.getElementById('formType').value = type;
      document.getElementById('formId').value = id;
      document.getElementById('actionForm').submit();
  }
</script>

</body>
</html>
