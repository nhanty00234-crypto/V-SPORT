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
<title>Yêu cầu hoàn tiền — Manager</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  .rf-badge{display:inline-flex;align-items:center;gap:5px;padding:5px 12px;border-radius:999px;font-size:11.5px;font-weight:700;white-space:nowrap;}
  .rf-badge-CHO_BO_SUNG_THONG_TIN{background:#fef3c7;color:#b45309;}
  .rf-badge-CHO_XU_LY{background:#dbeafe;color:#1d4ed8;}
  .rf-badge-DA_DUYET{background:#f3e8ff;color:#6b21a8;}
  .rf-badge-DANG_HOAN_TIEN{background:#e0e7ff;color:#3730a3;}
  .rf-badge-DA_HOAN_TIEN{background:#dcfce7;color:#15803d;}
  .rf-badge-TU_CHOI{background:#fee2e2;color:#b91c1c;}
  .rf-badge-DA_HUY{background:#f4f4f5;color:#52525b;}

  .rf-stat{background:#fff;border:1px solid #f3e8ff;border-radius:16px;padding:16px 18px;display:flex;flex-direction:column;gap:4px;}
  .rf-stat .num{font-size:22px;font-weight:800;color:#1e1b2e;}
  .rf-stat .lbl{font-size:12px;font-weight:600;color:#78716c;}

  .rf-table-wrap{background:#fff;border:1px solid #f3e8ff;border-radius:20px;overflow:hidden;}
  .rf-table{width:100%;border-collapse:separate;border-spacing:0;font-size:13.5px;}
  .rf-table thead th{background:#faf5ff;padding:13px 16px;text-align:left;font-size:10.5px;font-weight:800;color:#7c3aed;border-bottom:1px solid #f3e8ff;}
  .rf-table tbody td{padding:13px 16px;border-bottom:1px solid #fafaf9;vertical-align:middle;color:#292524;}
  .rf-table tbody tr:last-child td{border-bottom:none;}
  .rf-table tbody tr:hover td{background:#faf5ff;}

  .rf-act-btn{padding:7px 13px;font-size:12px;font-weight:700;border-radius:8px;cursor:pointer;border:none;transition:filter .15s;color:#fff;}
  .rf-act-btn:hover{filter:brightness(0.92);}
  .rf-act-approve{background:#16a34a;}
  .rf-act-reject{background:#ef4444;}
  .rf-act-info{background:#f59e0b;}
  .rf-act-process{background:#7c3aed;}
  .rf-act-complete{background:#4338ca;}

  .rf-modal-overlay{background:rgba(30,27,46,0.45);}
  .rf-modal-card{background:#fff;border-radius:20px;box-shadow:0 20px 50px -12px rgba(124,58,237,0.25);}

  .rf-tab-btn{padding:9px 18px;border-radius:10px;font-size:13px;font-weight:700;color:#78716c;background:#fff;border:1px solid #f3e8ff;cursor:pointer;transition:all .15s;display:flex;align-items:center;gap:6px;}
  .rf-tab-btn:hover{background:#faf5ff;}
  .rf-tab-btn.active{background:#7c3aed;color:#fff;border-color:#7c3aed;}

  .rf-qr-box{display:flex;gap:14px;align-items:center;background:#faf5ff;border:1px solid #f3e8ff;border-radius:14px;padding:14px;margin-bottom:16px;}
  .rf-qr-box img{width:130px;height:130px;border-radius:10px;background:#fff;flex-shrink:0;}
  .rf-qr-hint{font-size:12px;color:#78716c;width:130px;text-align:center;}

  .rf-hist-item{border-bottom:1px solid #fafaf9;padding:14px 16px;display:flex;flex-direction:column;gap:4px;}
  .rf-hist-item:last-child{border-bottom:none;}
  .rf-hist-item:hover{background:#faf5ff;}

  .rf-sla-badge{display:inline-flex;align-items:center;gap:4px;margin-left:6px;padding:3px 9px;border-radius:999px;font-size:10.5px;font-weight:800;background:#fee2e2;color:#b91c1c;white-space:nowrap;}
  tr.rf-row-overdue td{background:#fff1f2 !important;}
  tr.rf-row-overdue:hover td{background:#ffe4e6 !important;}
</style>
</head>
<body class="bg-zinc-50">
<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle"    value="Yêu cầu hoàn tiền" scope="page" />
<c:set var="headerSubtitle" value="Duyệt và xử lý chuyển khoản hoàn tiền cho khách hàng" scope="page" />
<c:set var="headerIcon"     value="receipt_long" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty param.success}">
    <div class="p-3 bg-green-50 border border-green-200 rounded-xl text-green-800 text-sm font-semibold flex items-center gap-2">
      <span class="material-symbols-outlined text-[18px]">check_circle</span>
      Thao tác thành công với yêu cầu hoàn tiền #<c:out value="${param.success}"/>.
    </div>
  </c:if>
  <c:if test="${not empty param.error}">
    <div class="p-3 bg-red-50 border border-red-200 rounded-xl text-red-800 text-sm font-semibold flex items-center gap-2">
      <span class="material-symbols-outlined text-[18px]">error</span>
      Lỗi: <c:out value="${param.error}"/>
    </div>
  </c:if>

  <c:set var="countChoXuLy" value="0" />
  <c:set var="countDaDuyet" value="0" />
  <c:set var="countDangHoan" value="0" />
  <c:forEach var="htc" items="${danhSachHoanTien}">
    <c:if test="${htc.trangThai == 'CHO_XU_LY'}"><c:set var="countChoXuLy" value="${countChoXuLy + 1}" /></c:if>
    <c:if test="${htc.trangThai == 'DA_DUYET'}"><c:set var="countDaDuyet" value="${countDaDuyet + 1}" /></c:if>
    <c:if test="${htc.trangThai == 'DANG_HOAN_TIEN'}"><c:set var="countDangHoan" value="${countDangHoan + 1}" /></c:if>
  </c:forEach>

  <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
    <div class="rf-stat"><span class="num">${fn:length(danhSachHoanTien)}</span><span class="lbl">Tổng yêu cầu (trang này)</span></div>
    <div class="rf-stat"><span class="num" style="color:#1d4ed8;">${countChoXuLy}</span><span class="lbl">Chờ xử lý</span></div>
    <div class="rf-stat"><span class="num" style="color:#6b21a8;">${countDaDuyet}</span><span class="lbl">Đã duyệt</span></div>
    <div class="rf-stat"><span class="num" style="color:#3730a3;">${countDangHoan}</span><span class="lbl">Đang chuyển khoản</span></div>
  </div>

  <div class="flex gap-2">
    <button type="button" id="tab-btn-list" class="rf-tab-btn active" onclick="switchRefundTab('list')">
      <span class="material-symbols-outlined text-[16px]">list_alt</span>Danh sách yêu cầu
    </button>
    <button type="button" id="tab-btn-history" class="rf-tab-btn" onclick="switchRefundTab('history')">
      <span class="material-symbols-outlined text-[16px]">history</span>Lịch sử xử lý
    </button>
  </div>

  <div id="panel-list">
  <div class="rf-table-wrap overflow-x-auto">
    <table class="rf-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Mã đặt sân</th>
          <th style="text-align:right;">Đã thực trả</th>
          <th style="text-align:right;">Đề nghị hoàn</th>
          <th>Ngân hàng nhận</th>
          <th>Trạng thái</th>
          <th>Ngày gửi</th>
          <th>Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty danhSachHoanTien}">
            <tr><td colspan="8" class="text-center text-zinc-400 py-10">Không có yêu cầu hoàn tiền nào.</td></tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="ht" items="${danhSachHoanTien}">
              <tr data-status="${ht.trangThai}" data-requested-at="${not empty ht.thoiGianYeuCau ? ht.thoiGianYeuCau.time : ''}">
                <td class="font-mono text-zinc-500">#<c:out value="${ht.hoanTienId}"/></td>
                <td class="font-semibold">#<c:out value="${ht.datSanId}"/></td>
                <td style="text-align:right;"><fmt:formatNumber value="${ht.soTienDaThanhToan}" pattern="#,##0"/>đ</td>
                <td style="text-align:right; font-weight:700; color:#7c3aed;"><fmt:formatNumber value="${ht.soTienDeNghiHoan}" pattern="#,##0"/>đ</td>
                <td>
                  <c:choose>
                    <c:when test="${not empty ht.nganHangNhan}">
                      <div class="font-semibold text-xs">${fn:escapeXml(ht.nganHangNhan)}</div>
                      <div class="text-xs text-zinc-500">${fn:escapeXml(ht.soTaiKhoanNhan)}</div>
                    </c:when>
                    <c:otherwise><span class="text-amber-600 text-xs font-semibold">Chưa nhập TK</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:set var="stClass" value="rf-badge-${ht.trangThai}" />
                  <span class="rf-badge ${stClass}">
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
                  <span class="rf-sla-slot"></span>
                </td>
                <td class="text-zinc-500 text-xs">
                  <c:if test="${not empty ht.thoiGianYeuCau}">
                    <fmt:formatDate value="${ht.thoiGianYeuCau}" pattern="dd/MM/yyyy HH:mm"/>
                  </c:if>
                </td>
                <td class="whitespace-nowrap">
                  <div class="flex gap-1.5">
                    <c:if test="${ht.trangThai == 'CHO_XU_LY'}">
                      <button type="button" class="rf-act-btn rf-act-approve"
                        data-approve-id="${ht.hoanTienId}"
                        data-approve-bank="${fn:escapeXml(ht.nganHangNhan)}"
                        data-approve-account="${fn:escapeXml(ht.soTaiKhoanNhan)}"
                        data-approve-holder="${fn:escapeXml(ht.chuTaiKhoanNhan)}"
                        data-approve-amount="${ht.soTienDeNghiHoan}"
                        onclick="openApproveFromButton(this)">Duyệt</button>
                      <button onclick="openReject(${ht.hoanTienId})" class="rf-act-btn rf-act-reject">Từ chối</button>
                      <button onclick="openMoreInfo(${ht.hoanTienId})" class="rf-act-btn rf-act-info">Y/c bổ sung</button>
                    </c:if>
                    <c:if test="${ht.trangThai == 'DA_DUYET'}">
                      <button onclick="openStartProcessing(${ht.hoanTienId})" class="rf-act-btn rf-act-process">Bắt đầu CK</button>
                    </c:if>
                    <c:if test="${ht.trangThai == 'DANG_HOAN_TIEN'}">
                      <button onclick="openComplete(${ht.hoanTienId})" class="rf-act-btn rf-act-complete">Xác nhận đã CK</button>
                    </c:if>
                    <c:if test="${ht.trangThai == 'DA_HOAN_TIEN' || ht.trangThai == 'TU_CHOI' || ht.trangThai == 'DA_HUY' || ht.trangThai == 'CHO_BO_SUNG_THONG_TIN'}">
                      <span class="text-zinc-400 text-xs">—</span>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

  <div class="flex justify-end items-center gap-2 mt-3">
    <c:if test="${page > 1}">
      <a href="${ctx}/manager/hoan-tien?page=${page-1}" class="px-3 py-1.5 text-sm font-semibold border border-purple-200 rounded-lg hover:bg-purple-50 text-zinc-700">Trang trước</a>
    </c:if>
    <span class="px-3 py-1 text-sm text-zinc-500 font-medium">Trang ${page}</span>
    <c:if test="${not empty danhSachHoanTien && fn:length(danhSachHoanTien) == 20}">
      <a href="${ctx}/manager/hoan-tien?page=${page+1}" class="px-3 py-1.5 text-sm font-semibold border border-purple-200 rounded-lg hover:bg-purple-50 text-zinc-700">Trang sau</a>
    </c:if>
  </div>
  </div>

  <div id="panel-history" class="hidden">
    <div class="rf-table-wrap">
      <div class="flex items-center justify-between px-4 py-3 border-b border-purple-100">
        <span class="text-xs font-bold text-purple-700">Lịch sử xử lý (tự cập nhật)</span>
        <span class="flex items-center gap-1.5 text-xs text-zinc-500"><span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>Real-time</span>
      </div>
      <div id="historyList"></div>
    </div>
  </div>
</main>

<%-- Modal: Duyệt --%>
<div id="modalApprove" class="hidden fixed inset-0 rf-modal-overlay flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="rf-modal-card p-6 w-full max-w-md">
    <input type="hidden" name="action" value="approve"/>
    <input type="hidden" name="hoanTienId" id="approveId"/>
    <h3 class="font-bold text-lg mb-4">Duyệt yêu cầu hoàn tiền</h3>

    <div class="rf-qr-box" id="approveQrBox">
      <img id="approveQrImg" src="" alt="VietQR" style="display:none;">
      <div id="approveQrHint" class="rf-qr-hint">Chọn ngân hàng hợp lệ để hiển thị mã QR chuyển khoản.</div>
      <div class="flex-1">
        <div class="text-xs text-zinc-500 font-semibold">Chuyển khoản tới</div>
        <div id="approveBankName" class="text-sm font-bold text-zinc-900 mt-0.5">—</div>
        <div id="approveAccountNo" class="text-xs text-zinc-600 font-mono">—</div>
        <div id="approveHolderName" class="text-xs text-zinc-500">—</div>
        <div class="text-xs text-zinc-500 font-semibold mt-2">Số tiền đề nghị hoàn</div>
        <div id="approveAmount" class="text-base font-extrabold text-purple-700">—</div>
      </div>
    </div>

    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Số tiền thực tế được duyệt <span class="text-red-500">*</span></label>
      <input type="number" name="soTienDuocDuyet" id="approveAmountInput" required min="1" step="1" class="w-full border rounded-lg p-2 text-sm" placeholder="VD: 100000"/>
    </div>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Ghi chú (tuỳ chọn)</label>
      <textarea name="ghiChu" rows="2" class="w-full border rounded-lg p-2 text-sm" placeholder="Ghi chú duyệt..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-green-600 text-white rounded text-sm hover:bg-green-700">Duyệt</button>
    </div>
  </form>
</div>

<%-- Modal: Từ chối --%>
<div id="modalReject" class="hidden fixed inset-0 rf-modal-overlay flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="rf-modal-card p-6 w-full max-w-md">
    <input type="hidden" name="action" value="reject"/>
    <input type="hidden" name="hoanTienId" id="rejectId"/>
    <h3 class="font-bold text-lg mb-4">Từ chối yêu cầu hoàn tiền</h3>
    <div class="mb-3">
      <label class="block text-sm font-medium mb-1">Chọn lý do có sẵn (tuỳ chọn)</label>
      <select id="rejectReasonPreset" class="w-full border rounded-lg p-2 text-sm" onchange="applyPreset('lyDoTuChoi', this.value)">
        <option value="">-- Chọn nhanh --</option>
        <option value="Số tài khoản ngân hàng không đúng định dạng.">Số tài khoản không đúng định dạng</option>
        <option value="Tên chủ tài khoản không khớp với thông tin đặt sân.">Tên chủ tài khoản không khớp</option>
        <option value="Đơn đặt sân không đủ điều kiện hoàn tiền theo chính sách.">Không đủ điều kiện hoàn tiền theo chính sách</option>
        <option value="Yêu cầu hoàn tiền trùng lặp với đơn đã xử lý trước đó.">Yêu cầu trùng lặp</option>
        <option value="Không xác minh được thông tin thanh toán gốc.">Không xác minh được thanh toán gốc</option>
      </select>
    </div>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Lý do từ chối <span class="text-red-500">*</span></label>
      <textarea name="lyDo" id="lyDoTuChoi" rows="3" required class="w-full border rounded-lg p-2 text-sm" placeholder="Nhập lý do..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded text-sm hover:bg-red-600">Từ chối</button>
    </div>
  </form>
</div>

<%-- Modal: Yêu cầu bổ sung thông tin --%>
<div id="modalMoreInfo" class="hidden fixed inset-0 rf-modal-overlay flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="rf-modal-card p-6 w-full max-w-md">
    <input type="hidden" name="action" value="request-more-info"/>
    <input type="hidden" name="hoanTienId" id="moreInfoId"/>
    <h3 class="font-bold text-lg mb-4">Yêu cầu khách bổ sung thông tin</h3>
    <div class="mb-3">
      <label class="block text-sm font-medium mb-1">Chọn lý do có sẵn (tuỳ chọn)</label>
      <select id="moreInfoReasonPreset" class="w-full border rounded-lg p-2 text-sm" onchange="applyPreset('ghiChuMoreInfo', this.value)">
        <option value="">-- Chọn nhanh --</option>
        <option value="Số tài khoản không hợp lệ, vui lòng nhập lại chính xác.">Số tài khoản không hợp lệ</option>
        <option value="Vui lòng bổ sung tên ngân hàng và số tài khoản nhận tiền.">Thiếu thông tin ngân hàng</option>
        <option value="Tên chủ tài khoản chưa khớp, vui lòng kiểm tra lại.">Tên chủ tài khoản chưa khớp</option>
        <option value="Vui lòng cung cấp thêm ảnh QR nhận tiền để xác minh.">Cần bổ sung ảnh QR</option>
      </select>
    </div>
    <div class="mb-4">
      <label class="block text-sm font-medium mb-1">Ghi chú</label>
      <textarea name="ghiChu" id="ghiChuMoreInfo" rows="3" class="w-full border rounded-lg p-2 text-sm" placeholder="VD: Số tài khoản không hợp lệ..."></textarea>
    </div>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-amber-500 text-white rounded text-sm hover:bg-amber-600">Gửi yêu cầu</button>
    </div>
  </form>
</div>

<%-- Modal: Bắt đầu chuyển khoản --%>
<div id="modalStartProcessing" class="hidden fixed inset-0 rf-modal-overlay flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="rf-modal-card p-6 w-full max-w-md">
    <input type="hidden" name="action" value="start-processing"/>
    <input type="hidden" name="hoanTienId" id="startProcessingId"/>
    <h3 class="font-bold text-lg mb-4">Bắt đầu chuyển khoản</h3>
    <p class="text-sm text-zinc-600 mb-4">Xác nhận bạn đang tiến hành chuyển khoản hoàn tiền cho khách hàng.</p>
    <div class="flex gap-2 justify-end">
      <button type="button" onclick="closeModals()" class="px-4 py-2 border rounded text-sm">Huỷ</button>
      <button type="submit" class="px-4 py-2 bg-purple-600 text-white rounded text-sm hover:bg-purple-700">Xác nhận</button>
    </div>
  </form>
</div>

<%-- Modal: Xác nhận đã chuyển khoản --%>
<div id="modalComplete" class="hidden fixed inset-0 rf-modal-overlay flex items-center justify-center z-50">
  <form method="post" action="${ctx}/manager/hoan-tien" class="rf-modal-card p-6 w-full max-w-md">
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
      <button type="submit" class="px-4 py-2 bg-indigo-700 text-white rounded text-sm hover:bg-indigo-800">Xác nhận</button>
    </div>
  </form>
</div>

<script>
var VIETQR_BIN = {
  'Vietcombank': '970436', 'MBBank': '970422', 'Techcombank': '970407', 'VPBank': '970432',
  'ACB': '970416', 'BIDV': '970418', 'VietinBank': '970415', 'TPBank': '970423',
  'Sacombank': '970403', 'Agribank': '970405'
};

// ==================== SLA hoàn tiền: cảnh báo quá 24h chưa xử lý ====================
var SLA_HOURS = 24;

function applySlaWarnings(){
  var rows = Array.prototype.slice.call(document.querySelectorAll('#panel-list tbody tr[data-status="CHO_XU_LY"]'));
  var now = new Date().getTime();
  var tbody = document.querySelector('#panel-list tbody');
  if (!tbody) return;

  rows.forEach(function(row){
    var slot = row.querySelector('.rf-sla-slot');
    if (!slot) return;
    var requestedAt = Number(row.getAttribute('data-requested-at'));
    if (!requestedAt) { row.setAttribute('data-overdue', '0'); return; }
    var hoursElapsed = (now - requestedAt) / 3600000;
    if (hoursElapsed >= SLA_HOURS) {
      slot.innerHTML = '<span class="rf-sla-badge">⏱ Quá hạn ' + Math.floor(hoursElapsed - SLA_HOURS) + 'h</span>';
      row.classList.add('rf-row-overdue');
      row.setAttribute('data-overdue', '1');
    } else {
      slot.innerHTML = '';
      row.classList.remove('rf-row-overdue');
      row.setAttribute('data-overdue', '0');
    }
  });

  // Đưa các dòng quá hạn lên đầu bảng để Manager xử lý ngay.
  var overdueRows = rows.filter(function(r){ return r.getAttribute('data-overdue') === '1'; });
  overdueRows.reverse().forEach(function(r){ tbody.insertBefore(r, tbody.firstChild); });
}
document.addEventListener('DOMContentLoaded', applySlaWarnings);

function openApproveFromButton(btn){
  var d = btn.dataset;
  openApprove(
    Number(d.approveId),
    d.approveBank === 'null' ? '' : d.approveBank,
    d.approveAccount === 'null' ? '' : d.approveAccount,
    d.approveHolder === 'null' ? '' : d.approveHolder,
    Number(d.approveAmount)
  );
}

function openApprove(id, bankName, accountNo, holderName, amount){
  document.getElementById('approveId').value = id;
  document.getElementById('approveAmountInput').value = amount || '';

  var bin = VIETQR_BIN[bankName];
  var img = document.getElementById('approveQrImg');
  var hint = document.getElementById('approveQrHint');

  document.getElementById('approveBankName').innerText = bankName || '—';
  document.getElementById('approveAccountNo').innerText = accountNo || '—';
  document.getElementById('approveHolderName').innerText = holderName || '—';
  document.getElementById('approveAmount').innerText = amount ? Number(amount).toLocaleString('vi-VN') + ' đ' : '—';

  if (bin && accountNo && accountNo !== 'null' && accountNo.trim() !== '') {
    var addInfo = encodeURIComponent('Hoan tien don ' + id);
    img.src = 'https://img.vietqr.io/image/' + bin + '-' + encodeURIComponent(accountNo) + '-compact2.png'
      + '?amount=' + Math.max(0, Math.round(amount || 0)) + '&addInfo=' + addInfo;
    img.style.display = 'block';
    hint.style.display = 'none';
  } else {
    img.style.display = 'none';
    hint.style.display = 'block';
    hint.innerText = bankName && bankName !== 'null' ? 'Ngân hàng này chưa hỗ trợ tạo QR tự động.' : 'Khách chưa nhập thông tin ngân hàng.';
  }

  document.getElementById('modalApprove').classList.remove('hidden');
}
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

function applyPreset(textareaId, value){
  if (!value) return;
  document.getElementById(textareaId).value = value;
}

// ==================== Tabs: Danh sách / Lịch sử xử lý ====================
var historyPollTimer = null;

function switchRefundTab(tab){
  var isList = tab === 'list';
  document.getElementById('tab-btn-list').classList.toggle('active', isList);
  document.getElementById('tab-btn-history').classList.toggle('active', !isList);
  document.getElementById('panel-list').classList.toggle('hidden', !isList);
  document.getElementById('panel-history').classList.toggle('hidden', isList);

  if (!isList) {
    fetchHistory();
    if (!historyPollTimer) historyPollTimer = setInterval(fetchHistory, 8000);
  } else if (historyPollTimer) {
    clearInterval(historyPollTimer);
    historyPollTimer = null;
  }
}

var HIST_STATUS_LABEL = {
  'DA_DUYET': 'Đã duyệt', 'DANG_HOAN_TIEN': 'Đang chuyển khoản',
  'DA_HOAN_TIEN': 'Đã hoàn tiền', 'TU_CHOI': 'Từ chối'
};
var HIST_STATUS_CLASS = {
  'DA_DUYET': 'rf-badge-DA_DUYET', 'DANG_HOAN_TIEN': 'rf-badge-DANG_HOAN_TIEN',
  'DA_HOAN_TIEN': 'rf-badge-DA_HOAN_TIEN', 'TU_CHOI': 'rf-badge-TU_CHOI'
};

function fetchHistory(){
  var ctxPath = '${ctx}';
  fetch(ctxPath + '/manager/hoan-tien?format=json-history')
    .then(function(r){ return r.json(); })
    .then(function(data){
      var list = document.getElementById('historyList');
      if (!data.success || !data.rows || data.rows.length === 0) {
        list.innerHTML = '<div class="text-center text-zinc-400 py-10 text-sm">Chưa có yêu cầu nào được xử lý.</div>';
        return;
      }
      list.innerHTML = data.rows.map(function(row){
        var badge = '<span class="rf-badge ' + (HIST_STATUS_CLASS[row.trangThai] || '') + '">' + (HIST_STATUS_LABEL[row.trangThai] || row.trangThai) + '</span>';
        var amount = row.soTienDuocDuyet != null ? row.soTienDuocDuyet : row.soTienDeNghiHoan;
        var when = row.completedAt || row.approvedAt || row.updatedAt || '';
        var note = '';
        if (row.trangThai === 'TU_CHOI' && row.lyDoTuChoi) note = '<div class="text-xs text-red-600 mt-1">Lý do: ' + row.lyDoTuChoi + '</div>';
        else if (row.maGiaoDichHoan) note = '<div class="text-xs text-zinc-500 mt-1">Mã GD: <span class="font-mono">' + row.maGiaoDichHoan + '</span></div>';
        else if (row.ghiChuXuLy) note = '<div class="text-xs text-zinc-500 mt-1">' + row.ghiChuXuLy + '</div>';
        return '<div class="rf-hist-item">'
          + '<div class="flex items-center justify-between">'
          + '<span class="font-semibold text-sm">Yêu cầu #' + row.hoanTienId + ' — Đặt sân #' + row.datSanId + '</span>'
          + badge
          + '</div>'
          + '<div class="flex items-center justify-between text-xs text-zinc-500">'
          + '<span>Số tiền: <strong class="text-purple-700">' + Number(amount || 0).toLocaleString('vi-VN') + ' đ</strong></span>'
          + '<span>' + when + '</span>'
          + '</div>'
          + note
          + '</div>';
      }).join('');
    })
    .catch(function(){ /* im lặng, giữ nguyên nội dung cũ khi lỗi mạng tạm thời */ });
}
</script>
</body>
</html>
