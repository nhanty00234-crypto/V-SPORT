<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Yêu cầu hoàn tiền — V-SPORT</title>
<jsp:include page="/staff/common/staff_head.jsp" />
<style>
  .badge{display:inline-flex;align-items:center;gap:6px;padding:4px 12px;border-radius:999px;font-size:11px;font-weight:700;white-space:nowrap;}
  .badge-CHO_BO_SUNG_THONG_TIN{background:#fef3c7;color:#b45309;}
  .badge-CHO_XU_LY{background:#dbeafe;color:#1d4ed8;}
  .badge-DA_DUYET{background:#f3e8ff;color:#6b21a8;}
  .badge-DANG_HOAN_TIEN{background:#e0e7ff;color:#3730a3;}
  .badge-DA_HOAN_TIEN{background:#dcfce7;color:#15803d;}
  .badge-TU_CHOI{background:#fee2e2;color:#b91c1c;}
  .badge-DA_HUY{background:#f1f5f9;color:#64748b;}
  .tbl-row:hover{background:#fff7ed;}
  .act-btn{padding:6px 12px;font-size:12px;font-weight:700;border-radius:8px;cursor:pointer;border:none;transition:background .15s;}
</style>
</head>
<body class="bg-zinc-50">
<jsp:include page="/staff/common/sidebar.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <div class="flex items-center justify-between">
    <h1 class="text-2xl font-bold text-zinc-900">Yêu cầu hoàn tiền</h1>
  </div>

  <c:if test="${not empty param.success}">
    <div class="p-3 bg-green-50 border border-green-200 rounded-lg text-green-800 text-sm">
      Thao tác thành công với yêu cầu hoàn tiền #<c:out value="${param.success}"/>.
    </div>
  </c:if>
  <c:if test="${not empty param.error}">
    <div class="p-3 bg-red-50 border border-red-200 rounded-lg text-red-800 text-sm">
      Lỗi: <c:out value="${param.error}"/>
    </div>
  </c:if>

  <div class="bg-white rounded-xl shadow-sm border border-zinc-100 overflow-x-auto">
    <table class="w-full text-sm">
      <thead class="bg-zinc-50 border-b border-zinc-100">
        <tr>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">ID</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Mã đặt sân</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-700">Đã thực trả</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-700">Đề nghị hoàn</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Ngân hàng nhận</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Trạng thái</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-700">Ngày gửi</th>
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
                <td class="px-4 py-3 text-zinc-700">#<c:out value="${ht.datSanId}"/></td>
                <td class="px-4 py-3 text-right text-zinc-700"><fmt:formatNumber value="${ht.soTienDaThanhToan}" pattern="#,##0"/>đ</td>
                <td class="px-4 py-3 text-right font-semibold text-zinc-900"><fmt:formatNumber value="${ht.soTienDeNghiHoan}" pattern="#,##0"/>đ</td>
                <td class="px-4 py-3 text-zinc-700">
                  <c:choose>
                    <c:when test="${not empty ht.nganHangNhan}">
                      <div class="font-semibold text-xs">${fn:escapeXml(ht.nganHangNhan)}</div>
                      <div class="text-xs text-zinc-500">${fn:escapeXml(ht.soTaiKhoanNhan)}</div>
                    </c:when>
                    <c:otherwise><span class="text-amber-600 text-xs font-semibold">Chưa nhập TK</span></c:otherwise>
                  </c:choose>
                </td>
                <td class="px-4 py-3">
                  <c:set var="stClass" value="badge-${ht.trangThai}" />
                  <span class="badge ${stClass}">
                    <c:choose>
                      <c:when test="${ht.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">Chờ bổ sung thông tin</c:when>
                      <c:when test="${ht.trangThai == 'CHO_XU_LY'}">Chờ xử lý</c:when>
                      <c:when test="${ht.trangThai == 'DA_DUYET'}">Đã duyệt</c:when>
                      <c:when test="${ht.trangThai == 'DANG_HOAN_TIEN'}">Đang chuyển khoản</c:when>
                      <c:when test="${ht.trangThai == 'DA_HOAN_TIEN'}">Đã hoàn tiền</c:when>
                      <c:when test="${ht.trangThai == 'TU_CHOI'}">Từ chối</c:when>
                      <c:when test="${ht.trangThai == 'DA_HUY'}">Đã hủy</c:when>
                      <c:otherwise>${ht.trangThai}</c:otherwise>
                    </c:choose>
                  </span>
                </td>
                <td class="px-4 py-3 text-zinc-500 text-xs">
                  <c:if test="${not empty ht.thoiGianYeuCau}">
                    <fmt:formatDate value="${ht.thoiGianYeuCau}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:if>
                </td>
                <td class="px-4 py-3 space-x-1 whitespace-nowrap">
                  <c:if test="${ht.trangThai == 'CHO_XU_LY'}">
                    <button onclick="openApprove(${ht.hoanTienId})" class="act-btn bg-green-600 text-white hover:bg-green-700">Duyệt</button>
                    <button onclick="openReject(${ht.hoanTienId})" class="act-btn bg-red-500 text-white hover:bg-red-600">Từ chối</button>
                    <button onclick="openMoreInfo(${ht.hoanTienId})" class="act-btn bg-amber-500 text-white hover:bg-amber-600">Y/c bổ sung</button>
                  </c:if>
                  <c:if test="${ht.trangThai == 'DA_DUYET'}">
                    <button onclick="openStartProcessing(${ht.hoanTienId})" class="act-btn bg-indigo-600 text-white hover:bg-indigo-700">Bắt đầu CK</button>
                  </c:if>
                  <c:if test="${ht.trangThai == 'DANG_HOAN_TIEN'}">
                    <button onclick="openComplete(${ht.hoanTienId})" class="act-btn bg-blue-600 text-white hover:bg-blue-700">Xác nhận đã CK</button>
                  </c:if>
                  <c:if test="${ht.trangThai == 'DA_HOAN_TIEN' || ht.trangThai == 'TU_CHOI' || ht.trangThai == 'DA_HUY' || ht.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">
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

  <div class="flex justify-end gap-2">
    <c:if test="${page > 1}">
      <a href="${ctx}/staff/hoan-tien?page=${page-1}" class="px-3 py-1 text-sm border rounded hover:bg-zinc-50">Trang trước</a>
    </c:if>
    <span class="px-3 py-1 text-sm text-zinc-500">Trang ${page}</span>
    <c:if test="${not empty danhSachHoanTien && fn:length(danhSachHoanTien) == 20}">
      <a href="${ctx}/staff/hoan-tien?page=${page+1}" class="px-3 py-1 text-sm border rounded hover:bg-zinc-50">Trang sau</a>
    </c:if>
  </div>
</main>

<%-- Modal: Duyệt --%>
<div id="modalApprove" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/staff/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="approve"/>
    <input type="hidden" name="hoanTienId" id="approveId"/>
    <h3 class="font-bold text-lg mb-4">Duyệt yêu cầu hoàn tiền</h3>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Số tiền thực tế được duyệt <span class="text-red-500">*</span></label>
      <input type="number" name="soTienDuocDuyet" required min="1" step="1" class="w-full border rounded-lg p-2 text-sm" placeholder="VD: 100000"/>
    </div>
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

<%-- Modal: Từ chối --%>
<div id="modalReject" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/staff/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
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

<%-- Modal: Yêu cầu bổ sung thông tin --%>
<div id="modalMoreInfo" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/staff/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="request-more-info"/>
    <input type="hidden" name="hoanTienId" id="moreInfoId"/>
    <h3 class="font-bold text-lg mb-4">Yêu cầu khách bổ sung thông tin</h3>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Ghi chú</label>
      <textarea name="ghiChu" rows="3" class="w-full border rounded-lg p-2 text-sm" placeholder="VD: Số tài khoản không hợp lệ..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-amber-500 text-white rounded text-sm hover:bg-amber-600">Gửi yêu cầu</button>
    </div>
  </form>
</div>

<%-- Modal: Bắt đầu chuyển khoản --%>
<div id="modalStartProcessing" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/staff/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
    <input type="hidden" name="action" value="start-processing"/>
    <input type="hidden" name="hoanTienId" id="startProcessingId"/>
    <h3 class="font-bold text-lg mb-4">Bắt đầu chuyển khoản</h3>
    <p class="text-sm text-zinc-600 mb-4">Xác nhận bạn đang tiến hành chuyển khoản hoàn tiền cho khách hàng.</p>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded text-sm hover:bg-indigo-700">Xác nhận</button>
    </div>
  </form>
</div>

<%-- Modal: Xác nhận đã chuyển khoản --%>
<div id="modalComplete" class="hidden fixed inset-0 bg-black/40 flex items-center justify-center z-50">
  <form method="post" action="${ctx}/staff/hoan-tien" class="bg-white rounded-xl p-6 w-full max-w-md shadow-xl">
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
function openMoreInfo(id){ document.getElementById('moreInfoId').value=id; document.getElementById('modalMoreInfo').classList.remove('hidden'); }
function openStartProcessing(id){ document.getElementById('startProcessingId').value=id; document.getElementById('modalStartProcessing').classList.remove('hidden'); }
function openComplete(id){ document.getElementById('completeId').value=id; document.getElementById('modalComplete').classList.remove('hidden'); }
function closeModals(){
  ['modalApprove','modalReject','modalMoreInfo','modalStartProcessing','modalComplete'].forEach(id=>document.getElementById(id).classList.add('hidden'));
}
window.addEventListener('click', e=>{
  ['modalApprove','modalReject','modalMoreInfo','modalStartProcessing','modalComplete'].forEach(id=>{
    if(e.target.id===id) closeModals();
  });
});
</script>
</body>
</html>
