<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Footer -->
<footer class="footer">
    <div class="container">
        <div class="footer-grid">
            <!-- Col 1 -->
            <div class="footer-col">
                <a href="${pageContext.request.contextPath}/" class="logo" style="margin-bottom: 25px;">
                    <i class="fa-solid fa-basket-shopping"></i>
                    V-<span>SPORT</span>
                </a>
                <p>Nền tảng giúp bạn tìm sân, đặt lịch và kết nối với cộng đồng thể thao một cách nhanh chóng, thuận tiện.</p>
                <div class="social-icons">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-youtube"></i></a>
                </div>
            </div>

            <!-- Col 2 -->
            <div class="footer-col">
                <h4>Liên kết hữu ích</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/">Về V-SPORT</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/tim-kiem">Tìm sân</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/ghep-keo">Ghép kèo</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/tim-kiem">Tin tức</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách quyền riêng tư</a></li>
                    <li><a href="#">Chính sách đặt và hủy sân</a></li>
                </ul>
            </div>

            <!-- Col 3 -->
            <div class="footer-col">
                <h4>Liên hệ</h4>
                <ul class="contact-info">
                    <li>
                        <i class="fas fa-phone-alt"></i>
                        <div>
                            <span style="font-size: 13px; display: block;">Hotline hỗ trợ</span>
                            <a href="tel:8185556788">818-555 67 88</a>
                        </div>
                    </li>
                    <li>
                        <i class="fas fa-envelope"></i>
                        <div>
                            <span style="font-size: 13px; display: block;">Email hỗ trợ</span>
                            <a href="mailto:support@vsport.vn" style="font-size: 15px; font-weight: 400; font-family: 'Inter', sans-serif;">support@vsport.vn</a>
                        </div>
                    </li>
                    <li>
                        <i class="fas fa-clock"></i>
                        <div>
                            <span style="font-size: 13px; display: block;">Thời gian hỗ trợ</span>
                            <span style="font-size: 15px; font-weight: 400;">7:00 - 22:00 hằng ngày</span>
                        </div>
                    </li>
                </ul>
            </div>

            <!-- Col 4 -->
            <div class="footer-col">
                <h4>Dành cho đối tác</h4>
                <p>Bạn đang sở hữu một cơ sở thể thao? Hãy đưa sân của mình đến gần hơn với cộng đồng người chơi.</p>
                <a href="${pageContext.request.contextPath}/owner/register" class="btn btn-primary">Đăng ký cơ sở</a>
            </div>
        </div>

        <div class="footer-bottom">
            <div class="copyright">
                &copy; 2026 V-SPORT. Bảo lưu mọi quyền.
            </div>
            <div class="payments">
                <div class="payment-card" title="Tiền mặt"><i class="fas fa-money-bill-wave" style="color: #1a8f4c; font-size: 22px;"></i></div>
                <div class="payment-card" title="PayOS / QR ngân hàng"><i class="fas fa-qrcode" style="color: #185A9D; font-size: 22px;"></i></div>
            </div>
        </div>
    </div>
</footer>

<jsp:include page="/common/booking-reminder-widget.jsp" />
