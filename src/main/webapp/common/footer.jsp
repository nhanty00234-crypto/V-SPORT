<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<footer class="vs-footer">
    <div class="vs-container">
        <div class="vs-footer__grid">

            <!-- Col 1: Brand -->
            <div>
                <a href="${pageContext.request.contextPath}/" class="vs-footer__logo">
                    <i class="fas fa-basketball" style="color:var(--vs-sage);margin-right:6px"></i>V-<span style="color:var(--vs-sage)">SPORT</span>
                </a>
                <p class="vs-footer__desc">Nền tảng tìm sân, đặt lịch và kết nối cộng đồng thể thao nhanh chóng, thuận tiện tại Vũng Tàu và khu vực lân cận.</p>
                <div class="vs-footer__social">
                    <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                    <a href="#" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
                    <a href="#" aria-label="TikTok"><i class="fab fa-tiktok"></i></a>
                </div>
            </div>

            <!-- Col 2: Links -->
            <div class="vs-footer__col">
                <h4 class="vs-footer__col-title">Liên kết</h4>
                <ul class="vs-footer__links">
                    <li><a href="${pageContext.request.contextPath}/">Về V-SPORT</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/dat-san">Đặt sân</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/ghep-keo">Ghép kèo</a></li>
                    <li><a href="${pageContext.request.contextPath}/customer/tim-kiem">Tin tức & Blog</a></li>
                    <li><a href="#">Điều khoản sử dụng</a></li>
                    <li><a href="#">Chính sách bảo mật</a></li>
                </ul>
            </div>

            <!-- Col 3: Contact -->
            <div class="vs-footer__col">
                <h4 class="vs-footer__col-title">Liên hệ</h4>
                <ul class="vs-footer__contact">
                    <li class="vs-footer__contact-item">
                        <span class="vs-footer__contact-icon"><i class="fas fa-phone-alt"></i></span>
                        <div>
                            <span class="vs-footer__contact-label">Hotline hỗ trợ</span>
                            <a class="vs-footer__contact-val" href="tel:0909000000">0909 000 000</a>
                        </div>
                    </li>
                    <li class="vs-footer__contact-item">
                        <span class="vs-footer__contact-icon"><i class="fas fa-envelope"></i></span>
                        <div>
                            <span class="vs-footer__contact-label">Email</span>
                            <a class="vs-footer__contact-val" href="mailto:support@vsport.vn">support@vsport.vn</a>
                        </div>
                    </li>
                    <li class="vs-footer__contact-item">
                        <span class="vs-footer__contact-icon"><i class="fas fa-clock"></i></span>
                        <div>
                            <span class="vs-footer__contact-label">Thời gian hỗ trợ</span>
                            <span class="vs-footer__contact-val">7:00 – 22:00 hằng ngày</span>
                        </div>
                    </li>
                    <li class="vs-footer__contact-item">
                        <span class="vs-footer__contact-icon"><i class="fas fa-location-dot"></i></span>
                        <div>
                            <span class="vs-footer__contact-label">Địa chỉ</span>
                            <span class="vs-footer__contact-val">Vũng Tàu, Bà Rịa – Vũng Tàu</span>
                        </div>
                    </li>
                </ul>
            </div>

            <!-- Col 4: Partner CTA -->
            <div class="vs-footer__col">
                <h4 class="vs-footer__col-title">Dành cho đối tác</h4>
                <p class="vs-footer__desc" style="margin-bottom:20px">Bạn đang sở hữu một cơ sở thể thao? Hãy đưa sân của mình đến gần hơn với hàng nghìn người chơi.</p>
                <a href="${pageContext.request.contextPath}/owner/register" class="vs-footer__partner-cta">
                    <i class="fas fa-plus-circle"></i> Đăng ký cơ sở
                </a>
            </div>
        </div>

        <!-- Bottom bar -->
        <div class="vs-footer__bottom">
            <span class="vs-footer__copy">&copy; 2026 V-SPORT. Bảo lưu mọi quyền.</span>
            <div class="vs-footer__payments">
                <span class="vs-footer__payment" title="Tiền mặt"><i class="fas fa-money-bill-wave"></i></span>
                <span class="vs-footer__payment" title="QR / Chuyển khoản"><i class="fas fa-qrcode"></i></span>
                <span class="vs-footer__payment" title="Ví điện tử"><i class="fas fa-wallet"></i></span>
            </div>
        </div>
    </div>
</footer>

<jsp:include page="/common/booking-reminder-widget.jsp" />
