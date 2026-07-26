<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Hoàn tiền — Manager</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
body { background-color:#f8fafc!important; }
.badge{display:inline-flex;align-items:center;padding:3px 10px;border-radius:8px;font-size:11px;font-weight:600;}
.badge-yellow{background:#fef3c7;color:#b45309;}
.badge-blue{background:#dbeafe;color:#1d4ed8;}
.badge-green{background:#dcfce7;color:#15803d;}
.badge-red{background:#fee2e2;color:#b91c1c;}
.tbl-row:hover{background:#f0f9ff;}
</style>
</head>
<body>
<jsp:include page="/manager/common/manager_sidebar.jsp" />
<main class="ml-64 p-8 min-h-screen">

  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-bold text-zinc-900">Quản lý Hoàn tiền</h1>
    <a href="${ctx}/manager/hoa-don" class="text-sm text-blue-600 hover:underline">← Quay lại Hóa đơn</a>
  </div>

  <c:if test="${not empty param.success}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg text-green-800 text-sm">
      Thao tác thành công với yêu cầu hoàn tiền #<c:out value="${param.success}"/>.
    </div>
  </c:if>
  <c:if test="${not empty param.error}">
    <div class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-800 text-sm">
      Lỗi: <c:out value="${param.error}"/>
    </div>
  </c:if>

  <div class="bg-white rounded-xl shadow-sm border border-zinc-100 overflow-hidden">
    <table class="w-full text-sm">
      <thead class="bg-zinc-50 border-b border-zinc-100">
        <tr>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">ID</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Hóa đơn</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Khách hàng</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-700">Số tiền</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Lý do</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Trạng thái</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Ngày tạo</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty danhSachHoanTien}">
            <tr><td colspan="8" class="px-4 py-8 text-center text-zinc-400">Không có yêu cầu hoàn tiền nào.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="ht" items="${danhSachHoanTien}">
              <tr class="tbl-row border-b border-zinc-50">
                <td class="px-4 py-3 font-mono text-zinc-600">#<c:out value="${ht.hoanTienId}"/></td>
                <td class="px-4 py-3 text-zinc-700">#<c:out value="${ht.hoaDonId}"/></td>
                <td class="px-4 py-3 text-zinc-700">ID:<c:out value="${ht.accountId}"/></td>
                <td class="px-4 py-3 text-right font-semibold text-zinc-900">
                  <fmt:formatNumber value="${ht.soTienHoan}" type="number" groupingUsed="true"/>đ
                </td>
                <td class="px-4 py-3 text-zinc-600 max-w-xs truncate"><c:out value="${ht.lyDo}"/></td>
                <td class="px-4 py-3">
                  <c:choose>
                    <c:when test="${ht.trangThai == 'Chờ xử lý'}">
                      <span class="badge badge-yellow">Chờ xử lý</span>
                    </c:when>
                    <c:when test="${ht.trangThai == 'Đã duyệt'}">
                      <span class="badge badge-blue">Đã duyệt</span>
                    </c:when>
                    <c:when test="${ht.trangThai == 'Đã hoàn tiền'}">
                      <span class="badge badge-green">Đã hoàn tiền</span>
                    </c:when>
                    <c:when test="${ht.trangThai == 'Từ chối'}">
                      <span class="badge badge-red">Từ chối</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge">${ht.trangThai}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="px-4 py-3 text-zinc-500 text-xs">
                  <c:if test="${not empty ht.ngayTaoYeuCau}">
                    <fmt:formatDate value="${ht.ngayTaoYeuCau}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:if>
                </td>
                <td class="px-4 py-3 space-x-1">
                  <c:if test="${ht.trangThai == 'Chờ xử lý'}">
                    <button onclick="openApprove(${ht.hoanTienId})"
                      class="px-3 py-1 text-xs bg-green-600 text-white rounded hover:bg-green-700">Duyệt</button>
                    <button onclick="openReject(${ht.hoanTienId})"
                      class="px-3 py-1 text-xs bg-red-500 text-white rounded hover:bg-red-600">Từ chối</button>
                  </c:if>
                  <c:if test="${ht.trangThai == 'Đã duyệt'}">
                    <button onclick="openComplete(${ht.hoanTienId})"
                      class="px-3 py-1 text-xs bg-blue-600 text-white rounded hover:bg-blue-700">Xác nhận CK</button>
                  </c:if>
                  <c:if test="${ht.trangThai == 'Đã hoàn tiền' || ht.trangThai == 'Từ chối'}">
                    <span class="text-zinc-400 text-xs">—</span>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <%-- Pagination --%>
  <div class="mt-4 flex justify-end gap-2">
    <c:if test="${page > 1}">
      <a href="${ctx}/manager/hoan-tien?page=${page-1}" class="px-3 py-1 text-sm border rounded hover:bg-zinc-50">Trang trước</a>
    </c:if>
    <span class="px-3 py-1 text-sm text-zinc-500">Trang ${page}</span>
    <c:if test="${not empty danhSachHoanTien && fn:length(danhSachHoanTien) == 20}">
      <a href="${ctx}/manager/hoan-tien?page=${page+1}" class="px-3 py-1 text-sm border rounded hover:bg-zinc-50">Trang sau</a>
    </c:if>
  </div>
</main>

<%-- Modal: Approve --%>
<div id="modalApprove" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="approve"/>
    <input type="hidden" name="hoanTienId" id="approveId"/>
    <h3 class="font-bold text-lg mb-4">Duyệt yêu cầu hoàn tiền</h3>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Ghi chú (tuỳ chọn)</label>
      <textarea name="ghiChu" rows="3" class="w-full border rounded-lg p-2 text-sm" placeholder="Ghi chú duyệt..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded text-sm hover:bg-green-700">Duyệt</button>
    </div>
  </form>
</div>

<%-- Modal: Reject --%>
<div id="modalReject" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="reject"/>
    <input type="hidden" name="hoanTienId" id="rejectId"/>
    <h3 class="font-bold text-lg mb-4">Từ chối yêu cầu hoàn tiền</h3>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Lý do từ chối <span class="text-red-500">*</span></label>
      <textarea name="lyDo" rows="3" required class="w-full border rounded-lg p-2 text-sm" placeholder="Nhập lý do..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded text-sm hover:bg-red-600">Từ chối</button>
    </div>
  </form>
</div>

<%-- Modal: Confirm Complete --%>
<div id="modalComplete" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="complete"/>
    <input type="hidden" name="hoanTienId" id="completeId"/>
    <h3 class="font-bold text-lg mb-4">Xác nhận đã chuyển khoản</h3>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Mã giao dịch ngân hàng</label>
      <input type="text" name="maGiaoDich" class="w-full border rounded-lg p-2 text-sm" placeholder="VD: FT23001XXXXXX"/>
    </div>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Ghi chú (tuỳ chọn)</label>
      <textarea name="ghiChu" rows="2" class="w-full border rounded-lg p-2 text-sm"></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">Xác nhận</button>
    </div>
  </form>
</div>

<script>
function openApprove(id){ document.getElementById('approveId').value=id; document.getElementById('modalApprove').classList.remove('hidden'); }
function openReject(id){ document.getElementById('rejectId').value=id; document.getElementById('modalReject').classList.remove('hidden'); }
function openComplete(id){ document.getElementById('completeId').value=id; document.getElementById('modalComplete').classList.remove('hidden'); }
function closeModals(){
  ['modalApprove','modalReject','modalComplete'].forEach(id=>document.getElementById(id).classList.add('hidden'));
}
window.addEventListener('click', e=>{
  if(e.target.id==='modalApprove'||e.target.id==='modalReject'||e.target.id==='modalComplete') closeModals();
});
</script>
</body>
</html>
