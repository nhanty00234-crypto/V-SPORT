<%-- src/main/webapp/manager/FaceSettings.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Cài đặt điểm danh khuôn mặt | Manager V-SPORT</title>
  <jsp:include page="/manager/common/head.jsp"/>
</head>
<body>
<jsp:include page="/manager/common/sidebar.jsp"/>
<jsp:include page="/manager/common/header.jsp">
  <jsp:param name="pageTitle" value="Điểm danh khuôn mặt"/>
  <jsp:param name="pageSubtitle" value="Cài đặt cho chi nhánh của bạn"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 max-w-xl">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 text-green-700 rounded-xl text-sm">
      ${sessionScope.flashSuccess}
    </div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>

  <div class="bg-white rounded-2xl shadow-sm border border-zinc-100 p-6">
    <h2 class="text-lg font-black text-zinc-800 mb-5">Cài đặt điểm danh khuôn mặt</h2>
    <form method="post" action="${pageContext.request.contextPath}/manager/face-settings" class="flex flex-col gap-5">

      <div class="flex items-center justify-between p-4 bg-zinc-50 rounded-xl">
        <div>
          <p class="font-bold text-zinc-700">Bắt buộc điểm danh bằng khuôn mặt</p>
          <p class="text-sm text-zinc-400">Nhân viên phải qua face scan mới được vào/ra ca</p>
        </div>
        <label class="relative inline-flex items-center cursor-pointer">
          <input type="checkbox" name="faceRequired" class="sr-only peer"
                 ${faceConfig.faceRequired ? 'checked' : ''}>
          <div class="w-11 h-6 bg-zinc-200 peer-focus:ring-2 peer-focus:ring-rose-300 rounded-full peer
                      peer-checked:bg-rose-500 after:content-[''] after:absolute after:top-0.5 after:left-[2px]
                      after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all
                      peer-checked:after:translate-x-full"></div>
        </label>
      </div>

      <div>
        <label class="block text-sm font-semibold text-zinc-600 mb-1">
          Ngưỡng Euclidean distance tối đa (thấp hơn = nghiêm ngặt hơn)
        </label>
        <select name="confidenceMin" class="w-full border border-zinc-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-rose-300">
          <option value="0.4" ${faceConfig.confidenceMin == 0.4 ? 'selected' : ''}>0.4 — Rất nghiêm ngặt (~95% giống)</option>
          <option value="0.5" ${faceConfig.confidenceMin == 0.5 ? 'selected' : ''}>0.5 — Nghiêm ngặt (~88% giống)</option>
          <option value="0.6" ${faceConfig.confidenceMin == 0.6 ? 'selected' : ''}>0.6 — Mặc định (~80% giống)</option>
          <option value="0.7" ${faceConfig.confidenceMin == 0.7 ? 'selected' : ''}>0.7 — Thoải mái hơn (~70% giống)</option>
        </select>
        <p class="text-xs text-zinc-400 mt-1">Khuyến nghị 0.6 — phù hợp hầu hết điều kiện ánh sáng bình thường</p>
      </div>

      <button type="submit"
              class="bg-rose-600 hover:bg-rose-700 text-white font-bold py-3 rounded-xl transition text-sm">
        Lưu cài đặt
      </button>
    </form>
  </div>
</main>
</body>
</html>
