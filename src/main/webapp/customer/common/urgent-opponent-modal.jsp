<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%-- Component: Modal "Tìm đối thủ gấp" --%>
<div id="urgentOpponentModal" style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 2000; display: none; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: #fff; width: 100%; max-width: 440px; border-radius: 20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); overflow: hidden;">
        <div style="background: linear-gradient(135deg, #f59e0b, #d97706); padding: 16px 24px; display: flex; align-items: center; justify-content: space-between; color: #fff;">
            <h3 style="font-size: 15px; font-weight: 800; margin: 0; font-family: 'Outfit', sans-serif; display: flex; align-items: center; gap: 8px;">
                <i class="fas fa-bolt"></i> Tìm đối thủ gấp
            </h3>
            <button type="button" onclick="closeUrgentOpponentModal()" style="background: none; border: none; color: rgba(255,255,255,0.8); cursor: pointer; font-size: 18px;"><i class="fas fa-times"></i></button>
        </div>
        <form id="urgentOpponentForm" onsubmit="return submitUrgentOpponentRequest(event)" style="padding: 24px;">
            <p style="font-size: 13px; color: #64748b; margin-top: 0; margin-bottom: 16px; line-height: 1.5;">Dùng khi lịch sắp diễn ra và bạn cần thêm người chơi gấp (ví dụ có người bùng kèo). Yêu cầu này sẽ ưu tiên người chơi có điểm uy tín tốt và ở gần bạn.</p>
            
            <div style="margin-bottom: 14px;">
                <label style="display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 6px;">Môn thể thao</label>
                <select name="monTheThao" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 13px; outline: none; background: #fff; box-sizing: border-box;">
                    <option>Bóng đá</option>
                    <option>Cầu lông</option>
                    <option>Tennis</option>
                    <option>Bóng rổ</option>
                    <option>Pickleball</option>
                </select>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
                <div>
                    <label style="display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 6px;">Số người cần tìm</label>
                    <input type="number" name="soNguoi" min="1" max="20" value="2" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 13px; outline: none; box-sizing: border-box;">
                </div>
                <div>
                    <label style="display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 6px;">Trình độ</label>
                    <select name="trinhDo" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 13px; outline: none; background: #fff; box-sizing: border-box;">
                        <option>Không yêu cầu</option>
                        <option>Mới chơi</option>
                        <option>Trung bình</option>
                        <option>Khá</option>
                        <option>Giỏi</option>
                    </select>
                </div>
            </div>

            <div style="margin-bottom: 20px;">
                <label style="display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; margin-bottom: 6px;">Bán kính tìm kiếm</label>
                <select name="banKinh" style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 13px; outline: none; background: #fff; box-sizing: border-box;">
                    <option>Trong vòng 2km</option>
                    <option>Trong vòng 5km</option>
                    <option>Trong vòng 10km</option>
                    <option>Toàn thành phố</option>
                </select>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; padding-top: 12px; border-top: 1px solid #f1f5f9;">
                <button type="button" onclick="closeUrgentOpponentModal()" style="padding: 10px 20px; border-radius: 8px; font-weight: 700; background: #f1f5f9; border: none; color: #475569; cursor: pointer;">Đóng</button>
                <button type="submit" style="padding: 10px 20px; border-radius: 8px; font-weight: 700; background: #d97706; border: none; color: #fff; cursor: pointer;">Gửi yêu cầu tìm đối thủ</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openUrgentOpponentModal() {
        var modal = document.getElementById('urgentOpponentModal');
        if (!modal) return;
        modal.style.display = 'flex';
    }
    function closeUrgentOpponentModal() {
        var modal = document.getElementById('urgentOpponentModal');
        if (!modal) return;
        modal.style.display = 'none';
    }
    function submitUrgentOpponentRequest(evt) {
        evt.preventDefault();
        closeUrgentOpponentModal();
        alert('Chức năng tìm đối thủ gấp đang được phát triển. Yêu cầu của bạn sẽ được ưu tiên người chơi có điểm uy tín tốt và ở gần bạn.');
        return false;
    }
</script>
