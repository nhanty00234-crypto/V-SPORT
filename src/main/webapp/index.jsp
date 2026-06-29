<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>V-Sport  - Nền tảng đặt sân thể thao số 1</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            corePlugins: {
               preflight: false,
            }
        }
    </script>
    
    <style>
        /* Reset & Variables */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        :root {
            /* Tông màu thể thao: Xanh lá sân cỏ */
            --primary: #10b981; 
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --text-dark: #1e293b;
            --text-muted: #64748b;
            --bg-light: #f8fafc;
            --white: #ffffff;
            --transition: all 0.3s ease;
        }

        body {
            background-color: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* Utilities */
        .text-center { text-align: center; }
        .highlight { color: var(--primary); }
        .subtitle {
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 2px;
            color: var(--primary-dark);
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .justify-center { justify-content: center !important; }

        /* Buttons */
        .btn {
            padding: 10px 24px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
            display: inline-block;
        }
        .btn-primary {
            background-color: var(--primary);
            color: var(--white);
            border: 2px solid var(--primary);
        }
        .btn-primary:hover {
            background-color: transparent;
            color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.2);
        }
        .btn-outline {
            background-color: transparent;
            color: var(--text-dark);
            border: 1px solid #cbd5e1;
        }
        .btn-outline:hover {
            border-color: var(--primary);
            color: var(--primary);
        }

        /* Navigation */
        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 8%;
            background: var(--bg-light);
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .nav-links {
            list-style: none;
            display: flex;
            gap: 30px;
        }
        .nav-links a {
            text-decoration: none;
            color: var(--text-dark);
            font-size: 0.95rem;
            font-weight: 500;
            transition: var(--transition);
        }
        .nav-links a:hover, .nav-links a.active {
            color: var(--primary);
            font-weight: 600;
        }

        /* Hero Section */
        .hero {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 50px 8%;
            min-height: 80vh;
        }
        .hero-content {
            flex: 1;
            padding-right: 50px;
        }
        .hero h1 {
            font-size: 3.5rem;
            line-height: 1.2;
            margin-bottom: 20px;
            color: var(--text-dark);
        }
        .hero p {
            color: var(--text-muted);
            margin-bottom: 30px;
            font-size: 1.1rem;
            max-width: 500px;
        }
        .store-buttons {
            display: flex;
            gap: 15px;
        }
        .store-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #1e293b;
            color: #fff;
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            transition: var(--transition);
        }
        .store-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            background: var(--primary);
        }

        /* Hero Image */
        .hero-image {
            flex: 1;
            position: relative;
            display: flex;
            justify-content: center;
        }
        .mockup-img {
            width: 350px;
            border-radius: 20px;
            box-shadow: 0 30px 60px rgba(0,0,0,0.15);
            border: 8px solid #fff;
            object-fit: cover;
        }

        /* Community Section */
        .community {
            padding: 80px 8%;
            position: relative;
            background: #fff;
        }
        .community-map {
            height: 400px;
            background: url('https://images.unsplash.com/photo-1551280857-2b9bbe5260fc?auto=format&fit=crop&w=1000&q=80') center/cover;
            border-radius: 40px;
            margin-top: 50px;
            position: relative;
            box-shadow: inset 0 0 0 2000px rgba(16, 185, 129, 0.2); /* Tint xanh nhẹ cho ảnh sân */
        }
        .user-card {
            position: absolute;
            background: #fff;
            padding: 8px 16px 8px 8px;
            border-radius: 30px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--text-dark);
        }
        .user-card img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--primary);
        }
        .pos-1 { top: 20%; left: 15%; }
        .pos-2 { top: 60%; left: 45%; }
        .pos-3 { top: 30%; right: 20%; }

        /* Features Section */
        .features {
            display: flex;
            align-items: center;
            gap: 60px;
            padding: 80px 8%;
        }
        .features-image {
            flex: 1;
        }
        .features-image img {
            width: 100%;
            max-width: 450px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(16, 185, 129, 0.2);
        }
        .features-content {
            flex: 1;
        }
        .features-content h2 {
            font-size: 2.5rem;
            margin-bottom: 40px;
        }
        .feature-list {
            list-style: none;
        }
        .feature-list li {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        .icon-box {
            width: 55px;
            height: 55px;
            background: var(--primary-light);
            color: var(--primary);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
        }

        /* Pricing Section */
        .pricing {
            padding: 80px 8%;
            background: var(--bg-light);
        }
        .billing-toggle {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            margin: 30px 0 50px;
            font-weight: 600;
        }
        .switch { position: relative; display: inline-block; width: 50px; height: 26px; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #cbd5e1; transition: .4s; }
        .slider:before { position: absolute; content: ""; height: 18px; width: 18px; left: 4px; bottom: 4px; background-color: white; transition: .4s; }
        input:checked + .slider { background-color: var(--primary); }
        input:checked + .slider:before { transform: translateX(24px); }
        .slider.round { border-radius: 34px; }
        .slider.round:before { border-radius: 50%; }

        .pricing-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
        }
        .price-card {
            background: #fff;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.05);
            transition: var(--transition);
            border: 1px solid #e2e8f0;
        }
        .price-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(16, 185, 129, 0.15);
            border-color: var(--primary-light);
        }
        .price-card.active-card {
            border: 2px solid var(--primary);
            transform: scale(1.05);
            background: linear-gradient(to bottom right, #ffffff, var(--primary-light));
        }
        .price-card h3 { font-size: 2.5rem; margin-bottom: 10px; color: var(--text-dark); }
        .price-card h3 span { font-size: 1rem; color: var(--text-muted); font-weight: 500; }
        .price-card h4 { font-size: 1.2rem; color: var(--primary-dark); margin-bottom: 10px; text-transform: uppercase; letter-spacing: 1px;}
        .price-card ul { list-style: none; margin: 30px 0; }
        .price-card ul li { margin-bottom: 15px; display: flex; align-items: center; gap: 10px; color: var(--text-muted); }
        .price-card ul li i { color: var(--primary); font-size: 1.2rem; }

        /* CTA Section */
        .cta { padding: 50px 8% 80px; }
        .cta-banner {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: #fff;
            text-align: center;
            padding: 60px 20px;
            border-radius: 30px;
            box-shadow: 0 20px 40px rgba(16, 185, 129, 0.3);
        }
        .cta-banner h2 { font-size: 2.5rem; margin-bottom: 15px; }
        .cta-banner p { margin-bottom: 30px; opacity: 0.9; font-size: 1.1rem;}
        .bg-dark { background-color: #1e293b !important; color: #fff !important; }

        /* Animations */
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }
        .float-animation { animation: float 5s ease-in-out infinite; }
        .float-slow { animation: float 7s ease-in-out infinite; }
        .float-fast { animation: float 3.5s ease-in-out infinite; }

        .fade-down { animation: fadeDown 1s cubic-bezier(0.1, 0.8, 0.2, 1); }
        @keyframes fadeDown {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .reveal {
            opacity: 0;
            transform: translateY(60px);
            transition: all 0.8s cubic-bezier(0.1, 0.8, 0.2, 1);
        }
        .reveal.active { 
            opacity: 1;
            transform: translateY(0); 
        }

        /* Responsive */
        @media (max-width: 991px) {
            .hero, .features { flex-direction: column; text-align: center; }
            .hero-content { padding-right: 0; margin-bottom: 40px; }
            .store-buttons { justify-content: center; }
            .price-card.active-card { transform: scale(1); }
            .nav-links { display: none; }
            .feature-list li { flex-direction: column; align-items: center; text-align: center; }
        }

        /* Shimmering Register Button */
        .btn-register-shimmer {
            position: relative;
            padding: 12px 32px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: #ffffff;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 30px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            overflow: hidden;
            border: none;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
            transition: all 0.4s cubic-bezier(0.25, 1, 0.5, 1);
            cursor: pointer;
        }

        .btn-register-shimmer::before {
            content: '';
            position: absolute;
            top: 0;
            left: -150%;
            width: 50%;
            height: 100%;
            background: linear-gradient(
                90deg,
                rgba(255, 255, 255, 0) 0%,
                rgba(255, 255, 255, 0.4) 50%,
                rgba(255, 255, 255, 0) 100%
            );
            transform: skewX(-20deg);
            transition: none;
        }

        .btn-register-shimmer:hover::before { animation: shimmerEffect 1.5s infinite; }
        .btn-register-shimmer:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(16, 185, 129, 0.5);
            color: #ffffff;
        }
        .btn-register-shimmer:active {
            transform: translateY(-1px);
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.4);
        }
        .btn-register-shimmer i {
            font-size: 1rem;
            transition: transform 0.3s ease;
        }
        .btn-register-shimmer:hover i { transform: translateX(4px); }

        @keyframes shimmerEffect {
            0% { left: -150%; }
            100% { left: 150%; }
        }
    </style>
</head>
<body>

    <nav class="navbar fade-down">
        <div class="logo">
            <i class="fa-solid fa-futbol"></i> V-SPORT
        </div>
        <ul class="nav-links">
            <li><a href="#" class="active">Trang Chủ</a></li>
            <li><a href="#">Tìm Sân</a></li>
            <li><a href="#">Giải Đấu</a></li>
            <li><a href="#">Cộng Đồng</a></li>
            <li><a href="#">Bảng Giá</a></li>
        </ul>
        <button onclick="openAuthModal('login')" class="btn-register-shimmer">
            Đăng ký / Đăng nhập <i class="fa-solid fa-arrow-right-to-bracket"></i>
        </button>
    </nav>

    <section class="hero reveal">
        <div class="hero-content">
            <h1>Đặt Sân Nhanh, <br><span class="highlight">Thỏa Đam Mê</span> Thể Thao</h1>
            <p>Khám phá và đặt ngay các sân bóng đá, tennis, cầu lông chất lượng nhất khu vực. Dễ dàng tìm đối thủ, ghép kèo và tạo giải đấu của riêng bạn!</p>
            <div class="store-buttons">
                <a href="#" class="store-btn"><i class="fa-solid fa-calendar-check"></i> Đặt Sân Ngay</a>
                <a href="#" class="btn btn-outline" style="display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-compass"></i> Khám phá
                </a>
            </div>
        </div>
        <div class="hero-image float-animation">
            <img src="https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=500&q=80" alt="Sport Field Mockup" class="mockup-img">
        </div>
    </section>

    <section class="community reveal">
        <div class="section-header text-center">
            <p class="subtitle">KẾT NỐI ĐAM MÊ</p>
            <h2>Tham gia cộng đồng thể thao lớn nhất</h2>
        </div>
        <div class="community-map">
            <div class="user-card float-slow pos-1">
                <img src="https://i.pravatar.cc/150?img=11" alt="Player">
                <span>Tuấn Anh (Cần đối)</span>
            </div>
            <div class="user-card float-fast pos-2">
                <img src="https://i.pravatar.cc/150?img=12" alt="Player">
                <span>FC Hổ Vằn</span>
            </div>
            <div class="user-card float-slow pos-3">
                <img src="https://i.pravatar.cc/150?img=33" alt="Player">
                <span>Minh Hoàng (Bắt gôn)</span>
            </div>
        </div>
    </section>

    <section class="features reveal">
        <div class="features-image">
            <img src="https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=500&q=80" alt="Football Pitch" class="rounded-img" style="border-radius: 20px; box-shadow: 0 20px 40px rgba(16, 185, 129, 0.3);">
        </div>
        <div class="features-content">
            <p class="subtitle">TIỆN ÍCH VƯỢT TRỘI</p>
            <h2>Mọi thứ bạn cần cho một trận đấu hoàn hảo</h2>
            <ul class="feature-list">
                <li>
                    <div class="icon-box"><i class="fa-solid fa-map-location-dot"></i></div>
                    <div>
                        <h3 style="font-size: 1.2rem; margin-bottom: 5px;">Tìm Sân Gần Nhất</h3>
                        <p style="color: var(--text-muted);">Hệ thống gợi ý sân cỏ nhân tạo, tennis, cầu lông dựa trên vị trí hiện tại của bạn.</p>
                    </div>
                </li>
                <li>
                    <div class="icon-box"><i class="fa-solid fa-handshake-angle"></i></div>
                    <div>
                        <h3 style="font-size: 1.2rem; margin-bottom: 5px;">Ghép Kèo & Bắt Đối</h3>
                        <p style="color: var(--text-muted);">Đội bạn thiếu người? Đăng tin tìm đối thủ ngang trình độ chỉ với 1 lượt chạm.</p>
                    </div>
                </li>
                <li>
                    <div class="icon-box"><i class="fa-solid fa-trophy"></i></div>
                    <div>
                        <h3 style="font-size: 1.2rem; margin-bottom: 5px;">Tổ Chức Giải Đấu</h3>
                        <p style="color: var(--text-muted);">Tạo lịch thi đấu, bảng xếp hạng và cập nhật tỉ số theo thời gian thực.</p>
                    </div>
                </li>
            </ul>
        </div>
    </section>

    <section class="pricing reveal">
        <div class="section-header text-center">
            <p class="subtitle">BẢNG GIÁ THUÊ SÂN</p>
            <h2>Chọn khung giờ phù hợp với đội bạn</h2>
            <div class="billing-toggle">
                <span>Sân 5 Người</span>
                <label class="switch">
                    <input type="checkbox">
                    <span class="slider round"></span>
                </label>
                <span>Sân 7 Người</span>
            </div>
        </div>
        <div class="pricing-cards">
            <div class="price-card">
                <h3>300K <span>/giờ</span></h3>
                <h4>Giờ Hành Chính</h4>
                <p>Từ 06:00 - 16:00 (Thứ 2 - Thứ 6)</p>
                <ul>
                    <li><i class="fa-solid fa-circle-check"></i> Tặng 2 bình nước suối lớn</li>
                    <li><i class="fa-solid fa-circle-check"></i> Miễn phí gửi xe</li>
                    <li><i class="fa-solid fa-circle-check"></i> Mượn bóng miễn phí</li>
                </ul>
                <a href="#" class="btn btn-outline">Đặt Giờ Này <i class="fa-solid fa-arrow-right"></i></a>
            </div>
            <div class="price-card active-card">
                <h3>550K <span>/giờ</span></h3>
                <h4>Giờ Vàng (Cao điểm)</h4>
                <p>Từ 17:30 - 20:30 (Thứ 2 - Thứ 6)</p>
                <ul>
                    <li><i class="fa-solid fa-circle-check"></i> Hỗ trợ trọng tài (Có phí)</li>
                    <li><i class="fa-solid fa-circle-check"></i> Bật đèn pha công suất cao</li>
                    <li><i class="fa-solid fa-circle-check"></i> Có trà đá phục vụ sân</li>
                    <li><i class="fa-solid fa-star"></i> Ưu tiên giữ lịch cố định</li>
                </ul>
                <a href="#" class="btn btn-primary">Đặt Giờ Này <i class="fa-solid fa-arrow-right"></i></a>
            </div>
            <div class="price-card">
                <h3>400K <span>/giờ</span></h3>
                <h4>Khung Cuối Tuần</h4>
                <p>Áp dụng cả ngày Thứ 7, Chủ Nhật</p>
                <ul>
                    <li><i class="fa-solid fa-circle-check"></i> Không khí nhộn nhịp, dễ bắt đối</li>
                    <li><i class="fa-solid fa-circle-check"></i> Trà đá miễn phí</li>
                    <li><i class="fa-solid fa-circle-check"></i> Có khu vực nghỉ ngơi VIP</li>
                </ul>
                <a href="#" class="btn btn-outline">Đặt Giờ Này <i class="fa-solid fa-arrow-right"></i></a>
            </div>
        </div>
    </section>

    <section class="cta reveal">
        <div class="cta-banner">
            <h2>Bạn đã sẵn sàng ra sân chưa?</h2>
            <p>Tải ứng dụng V-SPORT ngay hôm nay để nhận voucher giảm 20% cho lần đặt sân đầu tiên.</p>
            <div class="store-buttons justify-center">
                <a href="#" class="store-btn bg-dark"><i class="fa-brands fa-google-play"></i> Google Play</a>
                <a href="#" class="store-btn bg-dark"><i class="fa-brands fa-apple"></i> App Store</a>
            </div>
        </div>
    </section>

    <script>
        // Hiệu ứng Fade-in khi scroll tới các section
        const reveals = document.querySelectorAll(".reveal");

        const revealOnScroll = () => {
            const windowHeight = window.innerHeight;
            const elementVisible = 150;

            reveals.forEach(reveal => {
                const elementTop = reveal.getBoundingClientRect().top;
                if (elementTop < windowHeight - elementVisible) {
                    reveal.classList.add("active");
                }
            });
        };

        window.addEventListener("scroll", revealOnScroll);
        
        // Chạy một lần khi vừa tải trang xong để hiện ngay các phần tử ở trên cùng
        revealOnScroll();
    </script>

    <jsp:include page="/auth/AuthModal.jsp" />
</body>
</html>