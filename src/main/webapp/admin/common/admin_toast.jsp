<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String trashMessage = (String) session.getAttribute("trashMessage");
    String trashUrl = (String) session.getAttribute("trashUrl");
    Object trashSecondsObj = session.getAttribute("trashCountdownSeconds");
    if (trashMessage != null) {
        session.removeAttribute("trashMessage");
        session.removeAttribute("trashUrl");
        session.removeAttribute("trashCountdownSeconds");
    }
%>
<% if (trashMessage != null) { %>
<div id="adminTrashToast"
     data-message="<%= trashMessage.replace("\"", "&quot;") %>"
     data-url="<%= trashUrl != null ? trashUrl.replace("\"", "&quot;") : "" %>"
     data-seconds="<%= trashSecondsObj != null ? trashSecondsObj.toString() : "10" %>"
     style="position:fixed;right:20px;bottom:20px;z-index:200;max-width:360px;
            background:#0f172a;color:#fff;border-radius:14px;padding:14px 16px;
            box-shadow:0 12px 32px rgba(15,23,42,.28);font-size:13.5px;
            display:flex;flex-direction:column;gap:10px;">
  <div style="display:flex;align-items:flex-start;gap:10px;">
    <i class="ti ti-trash" style="font-size:18px;color:#fbbf24;flex-shrink:0;margin-top:1px;"></i>
    <span id="adminTrashToastMsg" style="line-height:1.4;"><%= trashMessage %></span>
  </div>
  <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;">
    <span style="font-size:11.5px;color:#94a3b8;">Tự ẩn sau <span id="adminTrashCountdown"><%= trashSecondsObj != null ? trashSecondsObj.toString() : "10" %></span>s</span>
    <a id="adminTrashGotoBtn" href="<%= trashUrl != null ? trashUrl : "#" %>"
       style="background:#2563eb;color:#fff;padding:6px 12px;border-radius:8px;font-weight:600;text-decoration:none;font-size:12.5px;white-space:nowrap;">
      Đi tới thùng rác
    </a>
  </div>
</div>
<script>
(function () {
  var toast = document.getElementById('adminTrashToast');
  if (!toast) return;
  var seconds = parseInt(toast.getAttribute('data-seconds') || '10', 10);
  var countdownEl = document.getElementById('adminTrashCountdown');
  var timer = setInterval(function () {
    seconds -= 1;
    if (countdownEl) countdownEl.textContent = Math.max(seconds, 0);
    if (seconds <= 0) {
      clearInterval(timer);
      toast.style.transition = 'opacity .25s ease';
      toast.style.opacity = '0';
      setTimeout(function () { toast.remove(); }, 260);
    }
  }, 1000);
})();
</script>
<% } %>
