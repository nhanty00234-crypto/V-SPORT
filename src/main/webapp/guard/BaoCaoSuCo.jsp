<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Báo cáo sự cố | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
</head>
<body>

<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Báo cáo sự cố"/>
  <jsp:param name="pageSubtitle" value="Ghi nhận và gửi sự cố lên manager"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6">
  <div class="max-w-xl mx-auto">

    <div class="gd-card p-6">
      <div class="flex items-center gap-3 mb-6">
        <div class="w-12 h-12 rounded-xl bg-rose-100 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px] text-rose-600" style="font-variation-settings:'FILL' 1">report</span>
        </div>
        <div>
          <h2 class="font-black text-rose-900">Báo cáo sự cố mới</h2>
          <p class="text-xs text-zinc-500">Manager sẽ nhận thông báo ngay khi bạn gửi</p>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/guard/bao-cao-su-co"
            enctype="multipart/form-data" class="flex flex-col gap-5" id="suco-form">

        <!-- Vị trí sân -->
        <div>
          <label class="block text-xs font-bold text-rose-700 mb-1.5">
            <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">location_on</span>
            Vị trí sự cố
          </label>
          <select name="sanId"
                  class="w-full border border-rose-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-rose-400 bg-white">
            <option value="">— Khu vực chung —</option>
            <c:forEach var="san" items="${danhSachSan}">
              <option value="${san.sanID}">${san.tenSan}</option>
            </c:forEach>
          </select>
        </div>

        <!-- Loại sự cố -->
        <div>
          <label class="block text-xs font-bold text-rose-700 mb-2">
            <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">category</span>
            Loại sự cố <span class="text-rose-500">*</span>
          </label>
          <div class="grid grid-cols-2 gap-2" id="loai-group">
            <label class="loai-option cursor-pointer border-2 border-rose-100 rounded-xl p-3 flex items-center gap-2 hover:border-rose-300 transition has-[:checked]:border-rose-500 has-[:checked]:bg-rose-50">
              <input type="radio" name="loaiSuCo" value="VI_PHAM_NOI_QUY" class="sr-only" required>
              <span class="material-symbols-outlined text-[18px] text-rose-500" style="font-variation-settings:'FILL' 1">gavel</span>
              <span class="text-xs font-semibold text-zinc-700">Vi phạm nội quy</span>
            </label>
            <label class="loai-option cursor-pointer border-2 border-rose-100 rounded-xl p-3 flex items-center gap-2 hover:border-rose-300 transition has-[:checked]:border-rose-500 has-[:checked]:bg-rose-50">
              <input type="radio" name="loaiSuCo" value="HU_HONG_THIET_BI" class="sr-only">
              <span class="material-symbols-outlined text-[18px] text-amber-500" style="font-variation-settings:'FILL' 1">build</span>
              <span class="text-xs font-semibold text-zinc-700">Hư hỏng thiết bị</span>
            </label>
            <label class="loai-option cursor-pointer border-2 border-rose-100 rounded-xl p-3 flex items-center gap-2 hover:border-rose-300 transition has-[:checked]:border-rose-500 has-[:checked]:bg-rose-50">
              <input type="radio" name="loaiSuCo" value="SU_CO_AN_NINH" class="sr-only">
              <span class="material-symbols-outlined text-[18px] text-red-600" style="font-variation-settings:'FILL' 1">emergency</span>
              <span class="text-xs font-semibold text-zinc-700">Sự cố an ninh</span>
            </label>
            <label class="loai-option cursor-pointer border-2 border-rose-100 rounded-xl p-3 flex items-center gap-2 hover:border-rose-300 transition has-[:checked]:border-rose-500 has-[:checked]:bg-rose-50">
              <input type="radio" name="loaiSuCo" value="KHAC" class="sr-only">
              <span class="material-symbols-outlined text-[18px] text-zinc-400" style="font-variation-settings:'FILL' 1">more_horiz</span>
              <span class="text-xs font-semibold text-zinc-700">Khác</span>
            </label>
          </div>
        </div>

        <!-- Mức độ -->
        <div>
          <label class="block text-xs font-bold text-rose-700 mb-2">
            <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">signal_cellular_alt</span>
            Mức độ nghiêm trọng <span class="text-rose-500">*</span>
          </label>
          <div class="flex gap-2">
            <label class="flex-1 cursor-pointer border-2 border-green-100 rounded-xl p-3 text-center hover:border-green-400 transition has-[:checked]:border-green-500 has-[:checked]:bg-green-50">
              <input type="radio" name="mucDo" value="THAP" class="sr-only" required>
              <span class="text-lg">🟢</span>
              <p class="text-xs font-bold text-green-700 mt-1">Thấp</p>
            </label>
            <label class="flex-1 cursor-pointer border-2 border-amber-100 rounded-xl p-3 text-center hover:border-amber-400 transition has-[:checked]:border-amber-500 has-[:checked]:bg-amber-50">
              <input type="radio" name="mucDo" value="TRUNG_BINH" class="sr-only">
              <span class="text-lg">🟡</span>
              <p class="text-xs font-bold text-amber-700 mt-1">Trung bình</p>
            </label>
            <label class="flex-1 cursor-pointer border-2 border-red-100 rounded-xl p-3 text-center hover:border-red-400 transition has-[:checked]:border-red-500 has-[:checked]:bg-red-50">
              <input type="radio" name="mucDo" value="CAO" class="sr-only">
              <span class="text-lg">🔴</span>
              <p class="text-xs font-bold text-red-700 mt-1">Cao</p>
            </label>
          </div>
        </div>

        <!-- Mô tả -->
        <div>
          <label class="block text-xs font-bold text-rose-700 mb-1.5">
            <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">description</span>
            Mô tả sự cố <span class="text-rose-500">*</span>
          </label>
          <textarea name="moTa" rows="4" required minlength="10"
                    placeholder="Mô tả chi tiết sự cố: vị trí cụ thể, người liên quan, diễn biến... (tối thiểu 10 ký tự)"
                    class="w-full border border-rose-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-rose-400 resize-none"
                    id="mota-input" oninput="updateCharCount(this)"></textarea>
          <p class="text-[11px] text-zinc-400 mt-1 text-right"><span id="char-count">0</span> ký tự</p>
        </div>

        <!-- Ảnh đính kèm -->
        <div>
          <label class="block text-xs font-bold text-rose-700 mb-1.5">
            <span class="material-symbols-outlined text-[14px] align-[-2px] mr-0.5">photo_camera</span>
            Ảnh đính kèm <span class="text-zinc-400 font-normal">(tùy chọn)</span>
          </label>
          <label class="block border-2 border-dashed border-rose-200 rounded-xl p-5 text-center cursor-pointer hover:border-rose-400 hover:bg-rose-50 transition" id="img-drop">
            <input type="file" name="anh" accept="image/*" class="sr-only" id="img-input" onchange="previewImg(this)">
            <span class="material-symbols-outlined text-[32px] text-rose-300 block mb-1">add_photo_alternate</span>
            <p class="text-xs text-zinc-500">Nhấn để chọn ảnh (tối đa 5MB)</p>
          </label>
          <img id="img-preview" src="" alt="" class="hidden mt-2 rounded-xl max-h-40 object-cover w-full">
        </div>

        <!-- Submit -->
        <button type="submit"
                class="w-full bg-rose-600 hover:bg-rose-700 text-white font-black py-3.5 rounded-xl shadow-lg shadow-rose-200 transition text-sm flex items-center justify-center gap-2">
          <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">send</span>
          GỬI BÁO CÁO
        </button>
      </form>
    </div>
  </div>
</main>

<script>
function updateCharCount(el) {
  document.getElementById('char-count').textContent = el.value.length;
}
function previewImg(input) {
  var preview = document.getElementById('img-preview');
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function(e) { preview.src = e.target.result; preview.classList.remove('hidden'); };
    reader.readAsDataURL(input.files[0]);
    document.getElementById('img-drop').querySelector('p').textContent = input.files[0].name;
  }
}
</script>
</body>
</html>
