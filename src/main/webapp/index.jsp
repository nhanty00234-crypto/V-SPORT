<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.TaiKhoan" %>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="/common/xtra-head.jsp" />
<body>

    <!-- Header -->
    <jsp:include page="/common/header-xtra.jsp" />

<%
    String authParam = request.getParameter("auth");
    boolean isAuthTab = authParam != null && !authParam.isEmpty();
%>
    <main>
        <div id="homeView" class="page-view <%= isAuthTab ? "" : "active" %>">
        <!-- Hero Section -->
        <section class="hero">
            <div class="hero-pattern"></div>
            <div class="container">
                <div class="hero-inner">
                    <div class="hero-content">
                        <h1><span class="highlight">Đặt sân</span><br>&amp; Ghép kèo ngay</h1>
                        <p>Kết nối đam mê thể thao, tìm sân và đối thủ dễ dàng chỉ với vài thao tác.</p>
                        <div class="hero-actions">
                            <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn btn-primary">
                                Đặt sân ngay <i class="fas fa-calendar-alt" style="margin-left: 8px;"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="btn btn-outline">
                                Ghép kèo ngay
                            </a>
                        </div>
                    </div>
                    <div class="hero-image">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport-hero-booking-match.webp" alt="V-SPORT Booking Match">
                    </div>
                </div>
            </div>
        </section>

        <!-- Service Benefits -->
        <div class="benefits-wrapper">
            <div class="container">
                <div class="benefits">
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <div class="benefit-text">
                            <h4>Đặt sân nhanh chóng</h4>
                            <p>Chọn sân và khung giờ phù hợp chỉ trong vài phút.</p>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-rotate-left"></i>
                        </div>
                        <div class="benefit-text">
                            <h4>Linh hoạt thay đổi</h4>
                            <p>Theo dõi, quản lý và thay đổi lịch theo chính sách của sân.</p>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-shield-halved"></i>
                        </div>
                        <div class="benefit-text">
                            <h4>Thanh toán an toàn</h4>
                            <p>Hỗ trợ tiền mặt và thanh toán trực tuyến bảo mật.</p>
                        </div>
                    </div>
                    <div class="benefit-item">
                        <div class="benefit-icon">
                            <i class="fas fa-headset"></i>
                        </div>
                        <div class="benefit-text">
                            <h4>Hỗ trợ tận tâm</h4>
                            <p>Đội ngũ V-SPORT sẵn sàng hỗ trợ khi bạn cần.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Promotional Banners -->
        <section class="promotions">
            <div class="container">
                <div class="promo-banners">
                    <!-- Banner 1 -->
                    <div class="promo-banner banner-red">
                        <div class="banner-content">
                            <div class="banner-discount">ƯU ĐÃI 20%</div>
                            <h3>Đặt sân lần đầu</h3>
                            <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn-banner">Đặt ngay <i class="fas fa-arrow-right"></i></a>
                        </div>
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Đặt sân lần đầu" class="banner-image" style="border-radius: 50%; right: -40px; bottom: -40px; width: 70%;">
                    </div>
                    <!-- Banner 2 -->
                    <div class="promo-banner banner-light">
                        <div class="banner-content">
                            <div class="banner-discount" style="color: var(--primary);">COMBO TIẾT KIỆM</div>
                            <h3>Thuê sân &amp; dụng cụ</h3>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="btn-banner" style="background: var(--primary);">Khám phá <i class="fas fa-arrow-right"></i></a>
                        </div>
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-badminton.jpg" alt="Thuê sân và dụng cụ" class="banner-image" style="border-radius: 50%; right: -40px; bottom: -40px; width: 70%;">
                    </div>
                    <!-- Banner 3 -->
                    <div class="promo-banner banner-green">
                        <div class="banner-content">
                            <div class="banner-discount">GIẢM ĐẾN 30%</div>
                            <h3>Đồ thể thao chính hãng</h3>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="btn-banner">Xem ngay <i class="fas fa-arrow-right"></i></a>
                        </div>
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-03.jpg" alt="Đồ thể thao chính hãng" class="banner-image" style="border-radius: 50%; right: -40px; bottom: -40px; width: 80%;">
                    </div>
                    <!-- Banner 4 -->
                    <div class="promo-banner banner-navy">
                        <div class="banner-content">
                            <div class="banner-discount">KẾT NỐI MIỄN PHÍ</div>
                            <h3>Tìm đồng đội ghép kèo</h3>
                            <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="btn-banner">Ghép kèo <i class="fas fa-arrow-right"></i></a>
                        </div>
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-01.jpg" alt="Tìm đồng đội ghép kèo" class="banner-image" style="border-radius: 50%; right: -40px; bottom: -40px; width: 80%;">
                    </div>
                </div>
            </div>
        </section>

        <!-- Categories Section -->
        <section class="categories">
            <div class="container">
                <h2 class="section-title">Khám phá <span class="highlight">môn thể thao</span></h2>
                <div class="category-grid">
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá" class="category-card cat-football">
                        <div class="category-icon"><i class="fas fa-futbol"></i></div>
                        <h4>Bóng đá</h4>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông" class="category-card cat-badminton">
                        <div class="category-icon"><i class="fas fa-table-tennis-paddle-ball"></i></div>
                        <h4>Cầu lông</h4>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" class="category-card cat-pickleball">
                        <div class="category-icon"><i class="fas fa-table-tennis-paddle-ball"></i></div>
                        <h4>Pickleball</h4>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" class="category-card cat-tennis">
                        <div class="category-icon"><i class="fas fa-baseball-bat-ball"></i></div>
                        <h4>Tennis</h4>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng rổ" class="category-card cat-basketball">
                        <div class="category-icon"><i class="fas fa-basketball"></i></div>
                        <h4>Bóng rổ</h4>
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Gym" class="category-card cat-gym">
                        <div class="category-icon"><i class="fas fa-dumbbell"></i></div>
                        <h4>Gym &amp; Fitness</h4>
                    </a>
                </div>
            </div>
        </section>

        <!-- Featured Products & Services Section -->
        <section class="products">
            <div class="container">
                <div class="products-header">
                    <h2 class="section-title">Sản phẩm &amp; <span class="highlight">dịch vụ nổi bật</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="btn btn-primary">Xem tất cả</a>
                </div>
                
                <div class="product-grid">
                    <!-- Product 1 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/pickleball.jpg" alt="Vợt Pickleball Carbon Pro">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Pickleball</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball">Vợt Pickleball Carbon Pro</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">1.290.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>

                    <!-- Product 2 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/badminton.jpg" alt="Giày cầu lông chống trượt">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Cầu lông</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông">Giày cầu lông chống trượt</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">890.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>

                    <!-- Product 3 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/football.jpg" alt="Bóng đá tiêu chuẩn Size 5">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Bóng đá</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá">Bóng đá tiêu chuẩn Size 5</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">350.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>

                    <!-- Product 4 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-04.jpg" alt="Áo thể thao V-SPORT Dry Fit">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Trang phục</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Áo thể thao V-SPORT Dry Fit</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">249.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>

                    <!-- Product 5 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/tennis.jpg" alt="Túi đựng vợt đa năng">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Phụ kiện</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis">Túi đựng vợt đa năng</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">459.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>

                    <!-- Product 6 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Thuê vợt tại cơ sở">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Dịch vụ</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Thuê vợt tại cơ sở</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">Từ 30.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="add-to-cart"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                        </div>
                    </div>

                    <!-- Product 7 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-05.jpg" alt="Huấn luyện viên cá nhân">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Dịch vụ</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Huấn luyện viên cá nhân</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">Từ 200.000đ/buổi</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="add-to-cart"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                        </div>
                    </div>

                    <!-- Product 8 -->
                    <div class="product-card">
                        <div class="product-badges">
                            <!-- No badge -->
                        </div>
                        <div class="product-actions">
                            <div class="action-icon" title="Thêm vào yêu thích"><i class="far fa-heart"></i></div>
                            <div class="action-icon" title="Xem chi tiết"><i class="fas fa-search"></i></div>
                            <div class="action-icon" title="Xem cơ sở cung cấp"><i class="fas fa-arrow-up-right-from-square"></i></div>
                        </div>
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/basketball.jpg" alt="Bình nước thể thao 750ml">
                        </div>
                        <div class="product-info">
                            <div class="product-category">Phụ kiện</div>
                            <h3 class="product-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng rổ">Bình nước thể thao 750ml</a></h3>
                            <div class="product-rating">
                                <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                            </div>
                            <div class="product-price-wrapper">
                                <div class="product-price">159.000đ</div>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng rổ" class="add-to-cart"><i class="fas fa-eye"></i> Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Mobile App Banner -->
        <section class="app-section">
            <div class="container">
                <div class="mobile-app">
                    <div class="app-content">
                        <h4>V-SPORT</h4>
                        <h2>Thể thao trong tầm tay</h2>
                        <p>Tìm sân gần bạn, đặt lịch theo khung giờ thuận tiện và kết nối với cộng đồng người chơi cùng đam mê.</p>
                        <div class="app-buttons">
                            <a href="${pageContext.request.contextPath}/customer/BanDo.jsp" class="app-btn">
                                <i class="fas fa-location-dot"></i>
                                <div class="app-btn-text">
                                    <span>Bản đồ sân gần bạn</span>
                                    <strong>Tìm sân gần bạn</strong>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="app-btn">
                                <i class="fas fa-people-arrows"></i>
                                <div class="app-btn-text">
                                    <span>Kết nối cộng đồng</span>
                                    <strong>Ghép kèo ngay</strong>
                                </div>
                            </a>
                        </div>
                    </div>
                    <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-02.jpg" alt="Cộng đồng V-SPORT" class="app-image" style="border-radius: 20px;">
                </div>
            </div>
        </section>

        <!-- News and Blog Section -->
        <section class="blog">
            <div class="container">
                <div class="blog-header">
                    <h2 class="section-title">Tin tức &amp; <span class="highlight">kinh nghiệm thể thao</span></h2>
                    <div class="blog-nav">
                        <button class="prev-blog"><i class="fas fa-arrow-left"></i></button>
                        <button class="next-blog"><i class="fas fa-arrow-right"></i></button>
                    </div>
                </div>
                
                <div class="blog-grid" id="blogSlider">
                    <!-- Blog 1 -->
                    <div class="blog-card">
                        <div class="blog-image">
                            <span class="blog-badge">Kinh nghiệm</span>
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-01.jpg" alt="5 lưu ý giúp bạn chọn sân phù hợp">
                        </div>
                        <div class="blog-content">
                            <span class="blog-date">10/06/2026</span>
                            <h3 class="blog-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">5 lưu ý giúp bạn chọn sân phù hợp</a></h3>
                        </div>
                    </div>

                    <!-- Blog 2 -->
                    <div class="blog-card">
                        <div class="blog-image">
                            <span class="blog-badge">Pickleball</span>
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/pickleball.jpg" alt="Cách chọn vợt Pickleball cho người mới">
                        </div>
                        <div class="blog-content">
                            <span class="blog-date">10/06/2026</span>
                            <h3 class="blog-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball">Cách chọn vợt Pickleball cho người mới</a></h3>
                        </div>
                    </div>

                    <!-- Blog 3 -->
                    <div class="blog-card">
                        <div class="blog-image">
                            <span class="blog-badge">Sức khỏe</span>
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-playing.jpg" alt="Khởi động đúng cách trước khi thi đấu">
                        </div>
                        <div class="blog-content">
                            <span class="blog-date">10/06/2026</span>
                            <h3 class="blog-title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Khởi động đúng cách trước khi thi đấu</a></h3>
                        </div>
                    </div>

                    <!-- Blog 4 -->
                    <div class="blog-card">
                        <div class="blog-image">
                            <span class="blog-badge">Cộng đồng</span>
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-03.jpg" alt="Làm thế nào để tìm đồng đội hợp trình độ?">
                        </div>
                        <div class="blog-content">
                            <span class="blog-date">10/06/2026</span>
                            <h3 class="blog-title"><a href="${pageContext.request.contextPath}/customer/ghep-keo">Làm thế nào để tìm đồng đội hợp trình độ?</a></h3>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Customer Reviews -->
        <section class="reviews">
            <div class="container">
                <div class="reviews-header">
                    <div>
                        <h2 class="section-title">Khách hàng nói gì về <span class="highlight">V-SPORT</span></h2>
                        <p class="reviews-subtitle">Những trải nghiệm thực tế từ cộng đồng đặt sân và ghép kèo trên V-SPORT.</p>
                    </div>
                    <div class="reviews-nav">
                        <button class="prev-review"><i class="fas fa-arrow-left"></i></button>
                        <button class="next-review"><i class="fas fa-arrow-right"></i></button>
                    </div>
                </div>

                <div class="reviews-grid" id="reviewsSlider">
                    <!-- Review 1 -->
                    <div class="review-card">
                        <div class="review-top">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/reviews/review-01.jpg" alt="Minh Anh" class="review-avatar">
                            <div class="review-identity">
                                <h4>Minh Anh</h4>
                                <span class="review-sport">Pickleball</span>
                            </div>
                        </div>
                        <div class="review-rating">
                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                        </div>
                        <p class="review-text">Tôi tìm được sân gần nhà rất nhanh, thông tin khung giờ rõ ràng và quá trình đặt sân chỉ mất vài phút.</p>
                        <div class="review-meta">
                            <div>
                                <div class="review-venue">Sân Pickleball Long Điền</div>
                                <span class="review-date">10/06/2026</span>
                            </div>
                            <span class="review-badge"><i class="fas fa-circle-check"></i> Đã đặt sân</span>
                        </div>
                    </div>

                    <!-- Review 2 -->
                    <div class="review-card">
                        <div class="review-top">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/reviews/review-02.jpg" alt="Hoàng Nam" class="review-avatar">
                            <div class="review-identity">
                                <h4>Hoàng Nam</h4>
                                <span class="review-sport">Cầu lông</span>
                            </div>
                        </div>
                        <div class="review-rating">
                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i>
                        </div>
                        <p class="review-text">Tính năng ghép kèo giúp tôi tìm được nhóm chơi phù hợp trình độ. Mọi người đều thân thiện và đúng giờ.</p>
                        <div class="review-meta">
                            <div>
                                <div class="review-venue">Trung tâm Cầu lông Vũng Tàu</div>
                                <span class="review-date">08/06/2026</span>
                            </div>
                            <span class="review-badge"><i class="fas fa-circle-check"></i> Đã đặt sân</span>
                        </div>
                    </div>

                    <!-- Review 3 -->
                    <div class="review-card">
                        <div class="review-top">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/reviews/review-03.jpg" alt="Thu Trang" class="review-avatar">
                            <div class="review-identity">
                                <h4>Thu Trang</h4>
                                <span class="review-sport">Bóng đá</span>
                            </div>
                        </div>
                        <div class="review-rating">
                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                        </div>
                        <p class="review-text">Sân hiển thị đúng hình ảnh và giá. Tôi cũng có thể thuê thêm bóng và áo bib ngay tại cơ sở.</p>
                        <div class="review-meta">
                            <div>
                                <div class="review-venue">Sân bóng Thành Công</div>
                                <span class="review-date">02/06/2026</span>
                            </div>
                            <span class="review-badge"><i class="fas fa-circle-check"></i> Đã đặt sân</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Newsletter -->
        <div class="newsletter-wrapper">
            <div class="container">
                <div class="newsletter">
                    <div class="newsletter-content">
                        <h2>Nhận ưu đãi từ <span style="color: var(--primary);">V-SPORT</span></h2>
                        <p>Cập nhật sân mới, chương trình ưu đãi và hoạt động thể thao nổi bật.</p>
                    </div>
                    <form class="newsletter-form" id="newsletterForm">
                        <input type="email" placeholder="Nhập địa chỉ email của bạn" required>
                        <button type="submit">Đăng ký</button>
                    </form>
                </div>
            </div>
        </div>
        </div> <!-- End of homeView -->

        <!-- Auth View -->
        <div id="authView" class="page-view <%= isAuthTab ? "active" : "" %>">
            <!-- Auth Header -->
            <div class="auth-header">
                <div class="container">
                    <div class="auth-header-inner">
                        <h1 class="auth-title">Tài khoản của tôi</h1>
                        <div class="breadcrumb">
                            <a href="#home" id="breadcrumbHome"><i class="fas fa-home"></i> Trang chủ</a>
                            <span><i class="fas fa-chevron-right" style="font-size: 10px; margin: 0 5px;"></i></span>
                            <span>Tài khoản</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Auth Container -->
            <div class="container">
                <div class="auth-tabs">
                    <button class="auth-tab-btn active" data-target="loginCol">Đăng nhập</button>
                    <button class="auth-tab-btn" data-target="registerCol">Đăng ký</button>
                </div>

                <div class="auth-container">
                    <!-- Login Column -->
                    <div class="auth-col active" id="loginCol">
                        <h3>Đăng nhập</h3>
                        <form id="loginForm" novalidate>
                            <div class="form-group">
                                <label for="loginEmail">Email hoặc số điện thoại <span>*</span></label>
                                <input type="text" id="loginEmail" class="form-control" placeholder="Nhập email hoặc số điện thoại..." required aria-describedby="loginEmailError">
                                <div id="loginEmailError" class="error-message"><i class="fas fa-exclamation-circle"></i> Vui lòng nhập email hoặc số điện thoại</div>
                            </div>

                            <div class="form-group">
                                <label for="loginPassword">Mật khẩu <span>*</span></label>
                                <div class="password-input-wrap">
                                    <input type="password" id="loginPassword" class="form-control" placeholder="Nhập mật khẩu..." required aria-describedby="loginPasswordError">
                                    <button type="button" class="password-toggle" aria-label="Hiện/ẩn mật khẩu">
                                        <i class="far fa-eye-slash"></i>
                                    </button>
                                </div>
                                <div id="loginPasswordError" class="error-message"><i class="fas fa-exclamation-circle"></i> Vui lòng nhập mật khẩu</div>
                            </div>

                            <div class="form-check">
                                <input type="checkbox" id="rememberMe">
                                <label for="rememberMe">Ghi nhớ đăng nhập</label>
                            </div>

                            <div class="auth-actions">
                                <button type="submit" class="btn btn-primary btn-auth" id="loginSubmitBtn">
                                    <i class="fas fa-spinner"></i>
                                    <span class="btn-text">Đăng nhập</span>
                                </button>
                                <a href="#" class="forgot-link" id="forgotBtn">Quên mật khẩu?</a>
                            </div>
                        </form>
                    </div>

                    <!-- Register Column -->
                    <div class="auth-col" id="registerCol">
                        <h3>Đăng ký</h3>
                        <form id="registerForm" novalidate>
                            <div style="display: flex; gap: 20px;">
                                <div class="form-group" style="flex: 1;">
                                    <label for="regName">Họ và tên <span>*</span></label>
                                    <input type="text" id="regName" class="form-control" placeholder="Nhập họ và tên..." required aria-describedby="regNameError">
                                    <div id="regNameError" class="error-message"><i class="fas fa-exclamation-circle"></i> Vui lòng nhập họ và tên</div>
                                </div>
                                <div class="form-group" style="flex: 1;">
                                    <label for="regPhone">Số điện thoại <span>*</span></label>
                                    <input type="tel" id="regPhone" class="form-control" placeholder="Nhập số điện thoại..." required aria-describedby="regPhoneError">
                                    <div id="regPhoneError" class="error-message"><i class="fas fa-exclamation-circle"></i> Số điện thoại không hợp lệ</div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="regEmail">Email <span>*</span></label>
                                <input type="email" id="regEmail" class="form-control" placeholder="Nhập email..." required aria-describedby="regEmailError">
                                <div id="regEmailError" class="error-message"><i class="fas fa-exclamation-circle"></i> Email không hợp lệ</div>
                            </div>

                            <div class="form-group">
                                <label for="regPassword">Mật khẩu <span>*</span></label>
                                <div class="password-input-wrap">
                                    <input type="password" id="regPassword" class="form-control" placeholder="Nhập mật khẩu..." required autocomplete="new-password" aria-describedby="regPasswordError" oninput="onRegPasswordInput()">
                                    <button type="button" class="password-toggle" aria-label="Hiện/ẩn mật khẩu">
                                        <i class="far fa-eye-slash"></i>
                                    </button>
                                </div>
                                <div class="password-helper">Tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt (vd: <strong>Password1!</strong>).</div>
                                <div id="regPasswordError" class="error-message"><i class="fas fa-exclamation-circle"></i> Mật khẩu cần có chữ hoa, chữ thường, số và ký tự đặc biệt</div>
                            </div>

                            <div class="form-group">
                                <label for="regConfirmPassword">Xác nhận mật khẩu <span>*</span></label>
                                <div class="password-input-wrap">
                                    <input type="password" id="regConfirmPassword" class="form-control" placeholder="Nhập lại mật khẩu..." required autocomplete="new-password" aria-describedby="regConfirmPasswordError" oninput="onRegConfirmInput()">
                                    <button type="button" class="password-toggle" aria-label="Hiện/ẩn mật khẩu">
                                        <i class="far fa-eye-slash"></i>
                                    </button>
                                </div>
                                <div id="regConfirmPasswordError" class="error-message"><i class="fas fa-exclamation-circle"></i> Mật khẩu xác nhận không khớp</div>
                                <div id="regConfirmOk" style="display:none;align-items:center;gap:5px;color:#16a34a;font-size:11.5px;font-weight:600;margin-top:5px;">
                                    <i class="fas fa-check-circle"></i> Mật khẩu khớp
                                </div>
                            </div>

                            <div class="form-check">
                                <input type="checkbox" id="agreeTerms" required>
                                <label for="agreeTerms">Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật</label>
                                <div id="agreeTermsError" class="error-message"><i class="fas fa-exclamation-circle"></i> Vui lòng đồng ý với điều khoản</div>
                            </div>

                            <div class="auth-actions">
                                <button type="submit" class="btn btn-primary btn-auth" id="registerSubmitBtn" style="width: 100%;">
                                    <i class="fas fa-spinner"></i>
                                    <span class="btn-text">Tạo tài khoản</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Forgot Password Modal -->
            <div class="modal-overlay" id="forgotModal" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
                <div class="modal-content">
                    <button class="modal-close" aria-label="Đóng" id="closeModalBtn"><i class="fas fa-times"></i></button>
                    <h3 id="modalTitle">Khôi phục mật khẩu</h3>
                    <p>Nhập email của bạn và chúng tôi sẽ gửi cho bạn một liên kết để đặt lại mật khẩu.</p>

                    <form id="forgotForm" novalidate>
                        <div class="form-group">
                            <label for="forgotEmail">Email <span>*</span></label>
                            <input type="email" id="forgotEmail" class="form-control" placeholder="Nhập email..." required aria-describedby="forgotEmailError">
                            <div id="forgotEmailError" class="error-message"><i class="fas fa-exclamation-circle"></i> Email không hợp lệ</div>
                        </div>

                        <div class="auth-actions">
                            <button type="submit" class="btn btn-primary btn-auth" id="forgotSubmitBtn" style="width: 100%;">
                                <i class="fas fa-spinner"></i>
                                <span class="btn-text">Gửi liên kết khôi phục</span>
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Toast -->
            <div class="success-toast" id="successToast">
                <i class="fas fa-check-circle" id="toastIcon" style="margin-right: 8px;"></i> <span id="toastMessage">Thành công!</span>
            </div>
        </div>
    </main>

    <!-- OTP Verification Modal -->
    <div id="otpModal" style="display:none;position:fixed;inset:0;z-index:10000;align-items:center;justify-content:center;padding:20px;background:rgba(15,23,42,.6);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);" role="dialog" aria-modal="true">
        <div style="background:#fff;border-radius:20px;width:100%;max-width:400px;box-shadow:0 24px 64px rgba(0,0,0,.2);overflow:hidden;animation:otpCardIn .28s cubic-bezier(.34,1.3,.64,1);">

            <!-- Compact header -->
            <div style="background:#0f172a;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;">
                <div style="display:flex;align-items:center;gap:9px;">
                    <div style="width:28px;height:28px;background:#01e281;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:13px;color:#042d1a;">
                        <i class="fas fa-shield-halved"></i>
                    </div>
                    <span style="color:#fff;font-size:13px;font-weight:700;letter-spacing:.5px;font-family:'Outfit',sans-serif;">Xác minh tài khoản</span>
                </div>
                <span id="otpTimerDisplay" style="font-size:13px;font-weight:700;color:#01e281;font-family:'JetBrains Mono','Courier New',monospace;">5:00</span>
            </div>

            <!-- Body -->
            <div style="padding:24px 28px 26px;">
                <p style="font-size:13px;color:#64748b;margin:0 0 20px;line-height:1.5;">
                    Mã 6 số đã gửi tới <strong id="otpEmailDisplay" style="color:#0f172a;"></strong>
                </p>

                <!-- 6 OTP boxes -->
                <div id="otpBoxRow" style="display:flex;gap:8px;justify-content:center;margin-bottom:20px;">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                </div>

                <!-- Submit -->
                <button id="otpSubmitBtn" disabled style="width:100%;padding:13px;border:none;border-radius:12px;background:#0f172a;color:#fff;font-size:14px;font-weight:700;font-family:'Outfit',sans-serif;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;opacity:.35;transition:all .2s;">
                    <i class="fas fa-spinner" id="otpSpinner" style="display:none;animation:spin 1s linear infinite;"></i>
                    <span>Xác minh</span>
                </button>

                <!-- Resend -->
                <div style="text-align:center;margin-top:14px;font-size:12.5px;color:#94a3b8;">
                    <a href="#" id="otpResendLink" style="color:#94a3b8;font-weight:600;pointer-events:none;text-decoration:none;">Gửi lại mã</a>
                    <span id="otpResendCooldown" style="color:#94a3b8;margin-left:4px;"></span>
                </div>
            </div>
        </div>
    </div>
    <style>
        .otp-digit {
            width:46px; height:54px; border-radius:12px;
            border:2px solid #e2e8f0;
            text-align:center; font-size:22px; font-weight:700;
            font-family:'JetBrains Mono','Courier New',monospace;
            color:#0f172a; outline:none; transition:all .18s; background:#fff;
        }
        .otp-digit:focus { border-color:#01e281; box-shadow:0 0 0 3px rgba(1,226,129,.15); transform:scale(1.06); }
        .otp-digit.filled { border-color:#01e281; background:#f0fff8; color:#065f46; }
        @keyframes otpCardIn {
            from { opacity:0; transform:scale(.92) translateY(18px); }
            to   { opacity:1; transform:scale(1)   translateY(0); }
        }
        @keyframes otpShake {
            0%,100% { transform:translateX(0); }
            20%     { transform:translateX(-5px); }
            40%     { transform:translateX(5px); }
            60%     { transform:translateX(-3px); }
            80%     { transform:translateX(3px); }
        }
    </style>

    <!-- Footer -->
    <jsp:include page="/common/footer.jsp" />

    <!-- Floating Scroll Top -->
    <div class="scroll-top" id="scrollTop">
        <i class="fas fa-arrow-up"></i>
    </div>

    <!-- JavaScript -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Scroll to top functionality
            const scrollTopBtn = document.getElementById('scrollTop');
            
            window.addEventListener('scroll', function() {
                if (window.pageYOffset > 300) {
                    scrollTopBtn.classList.add('active');
                } else {
                    scrollTopBtn.classList.remove('active');
                }
            });
            
            scrollTopBtn.addEventListener('click', function() {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            });

            // Simple Blog Slider mock functionality
            const prevBtn = document.querySelector('.prev-blog');
            const nextBtn = document.querySelector('.next-blog');
            const blogGrid = document.getElementById('blogSlider');
            
            if (prevBtn && nextBtn && blogGrid) {
                // In a real app, this would shift cards
                // Since we only have 4 cards and they are all visible on desktop,
                // we'll just add a small visual effect for demonstration
                nextBtn.addEventListener('click', () => {
                    blogGrid.style.transform = 'translateX(-10px)';
                    setTimeout(() => {
                        blogGrid.style.transform = 'translateX(0)';
                    }, 300);
                });
                
                prevBtn.addEventListener('click', () => {
                    blogGrid.style.transform = 'translateX(10px)';
                    setTimeout(() => {
                        blogGrid.style.transform = 'translateX(0)';
                    }, 300);
                });
            }
        });
            // --- AUTH LOGIC ---

            const homeView = document.getElementById('homeView');
            const authView = document.getElementById('authView');
            const accountBtn = document.getElementById('authBtn');

            // Routing
            const urlParams = new URLSearchParams(window.location.search);
            const wantsAuthView = window.location.hash === '#auth' || urlParams.has('auth');

            function handleRoute() {
                const hash = window.location.hash;
                const params = new URLSearchParams(window.location.search);
                const isAuth = hash === '#auth' || params.has('auth');
                if (isAuth) {
                    homeView.classList.remove('active');
                    authView.classList.add('active');
                } else {
                    authView.classList.remove('active');
                    homeView.classList.add('active');
                }
                window.scrollTo({ top: 0, behavior: 'instant' });
            }

            window.addEventListener('hashchange', handleRoute);

            if (wantsAuthView) {
                handleRoute();

                if (urlParams.get('notice') === 'loginRequired') {
                    const banner = document.createElement('div');
                    banner.className = 'auth-login-notice';
                    banner.style.cssText = 'max-width:520px;margin:0 auto 20px;padding:14px 18px;border-radius:10px;background:#fff7ed;border:1px solid #fdba74;color:#9a3412;font-size:14px;text-align:center;';
                    banner.textContent = 'Vui lòng đăng nhập để tiếp tục thao tác này.';
                    const authContainer = document.querySelector('#authView .auth-container');
                    if (authContainer) authContainer.parentNode.insertBefore(banner, authContainer);
                }
            }

            // Giữ redirect param (nếu có) để gắn vào form đăng nhập, dùng sau khi login thành công.
            const pendingRedirect = urlParams.get('redirect');

            if (accountBtn) {
                accountBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    window.location.hash = '#auth';
                });
            }

            // Breadcrumb and Logo click to home
            const breadcrumbHome = document.getElementById('breadcrumbHome');
            if (breadcrumbHome) {
                breadcrumbHome.addEventListener('click', (e) => {
                    e.preventDefault();
                    window.location.hash = '#home';
                });
            }

            const mainLogo = document.querySelector('.logo');
            if (mainLogo) {
                mainLogo.addEventListener('click', (e) => {
                    if (window.location.hash === '#auth') {
                        e.preventDefault();
                        window.location.hash = '#home';
                    }
                });
            }

            // Auth Tabs (Mobile)
            const tabBtns = document.querySelectorAll('.auth-tab-btn');
            const authCols = document.querySelectorAll('.auth-col');

            tabBtns.forEach(btn => {
                btn.addEventListener('click', () => {
                    tabBtns.forEach(b => b.classList.remove('active'));
                    authCols.forEach(c => c.classList.remove('active'));

                    btn.classList.add('active');
                    const targetId = btn.getAttribute('data-target');
                    document.getElementById(targetId).classList.add('active');
                });
            });
            
            // Password Toggle
            const toggleBtns = document.querySelectorAll('.password-toggle');
            toggleBtns.forEach(btn => {
                btn.addEventListener('click', () => {
                    const input = btn.previousElementSibling;
                    const icon = btn.querySelector('i');
                    
                    if (input.type === 'password') {
                        input.type = 'text';
                        icon.classList.remove('fa-eye-slash');
                        icon.classList.add('fa-eye');
                    } else {
                        input.type = 'password';
                        icon.classList.remove('fa-eye');
                        icon.classList.add('fa-eye-slash');
                    }
                });
            });
            
            // Modal Logic
            const forgotModal = document.getElementById('forgotModal');
            const forgotBtn = document.getElementById('forgotBtn');
            const closeModalBtn = document.getElementById('closeModalBtn');
            const forgotEmail = document.getElementById('forgotEmail');
            
            function openModal() {
                forgotModal.classList.add('active');
                document.body.style.overflow = 'hidden';
                setTimeout(() => forgotEmail.focus(), 100);
            }
            
            function closeModal() {
                forgotModal.classList.remove('active');
                document.body.style.overflow = '';
                forgotBtn.focus();
            }
            
            if (forgotBtn) {
                forgotBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    openModal();
                });
            }
            
            if (closeModalBtn) {
                closeModalBtn.addEventListener('click', closeModal);
            }
            
            window.addEventListener('click', (e) => {
                if (e.target === forgotModal) {
                    closeModal();
                }
            });
            
            window.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && forgotModal.classList.contains('active')) {
                    closeModal();
                }
            });
            
            // Toast functionality
            const successToast = document.getElementById('successToast');
            const toastMessage = document.getElementById('toastMessage');
            
            function showToast(msg, isError) {
                const icon = document.getElementById('toastIcon');
                toastMessage.textContent = msg;
                if (isError) {
                    successToast.classList.add('error');
                    if (icon) { icon.className = 'fas fa-times-circle'; icon.style.marginRight = '8px'; }
                } else {
                    successToast.classList.remove('error');
                    if (icon) { icon.className = 'fas fa-check-circle'; icon.style.marginRight = '8px'; }
                }
                successToast.classList.add('active');
                setTimeout(() => {
                    successToast.classList.remove('active');
                }, 3500);
            }

            // Newsletter signup - backend chưa sẵn sàng, chỉ validate và báo đang phát triển
            const newsletterForm = document.getElementById('newsletterForm');
            if (newsletterForm) {
                newsletterForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const emailInput = newsletterForm.querySelector('input[type="email"]');
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailInput || !emailRegex.test(emailInput.value.trim())) {
                        showToast('Vui lòng nhập một địa chỉ email hợp lệ.', true);
                        return;
                    }
                    showToast('Chức năng đăng ký nhận ưu đãi đang được phát triển.', false);
                    newsletterForm.reset();
                });
            }
            
            // Validation Helpers
            const showError = (input, show) => {
                const errorMsg = document.getElementById(input.id + 'Error');
                if (show) {
                    input.setAttribute('aria-invalid', 'true');
                    if (errorMsg) errorMsg.classList.add('visible');
                } else {
                    input.removeAttribute('aria-invalid');
                    if (errorMsg) errorMsg.classList.remove('visible');
                }
            };
            
            // Clear errors on input
            document.querySelectorAll('.form-control, .form-check input').forEach(input => {
                input.addEventListener('input', () => showError(input, false));
                input.addEventListener('change', () => showError(input, false));
            });
            
            // Form Submissions
            
            // Login Form
            const loginForm = document.getElementById('loginForm');
            const loginSubmitBtn = document.getElementById('loginSubmitBtn');
            
            if (loginForm) {
                loginForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    let isValid = true;
                    let firstError = null;
                    
                    const email = document.getElementById('loginEmail');
                    const password = document.getElementById('loginPassword');
                    
                    if (!email.value.trim()) {
                        showError(email, true);
                        isValid = false;
                        if (!firstError) firstError = email;
                    }
                    
                    if (!password.value.trim()) {
                        showError(password, true);
                        isValid = false;
                        if (!firstError) firstError = password;
                    }
                    
                    if (!isValid) {
                        firstError.focus();
                        return;
                    }
                    
                    // Connect to Backend API
                    loginSubmitBtn.disabled = true;
                    loginSubmitBtn.classList.add('loading');
                    const btnText = loginSubmitBtn.querySelector('.btn-text');
                    const originalText = btnText.textContent;
                    btnText.textContent = 'Đang đăng nhập...';
                    
                    const formData = new URLSearchParams();
                    const loginIdentifier = email.value.trim();
                    const isPhone = /^(0|\+84|84)[0-9]{8,9}$/.test(loginIdentifier);
                    formData.append('username', loginIdentifier);
                    formData.append('phone', loginIdentifier);
                    formData.append('password', password.value);
                    formData.append('loginMethod', isPhone ? 'phone' : 'account');
                    if (pendingRedirect) formData.append('redirect', pendingRedirect);

                    fetch('dangnhap', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: formData.toString()
                    })
                    .then(response => response.json())
                    .then(data => {
                        loginSubmitBtn.disabled = false;
                        loginSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        
                        if (data.success) {
                            showToast('Đăng nhập thành công!', false);
                            setTimeout(() => {
                                window.location.href = data.redirectUrl;
                            }, 500);
                        } else {
                            showToast('Lỗi: ' + (data.loi || 'Đăng nhập thất bại'), true);
                        }
                    })
                    .catch(error => {
                        loginSubmitBtn.disabled = false;
                        loginSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        showToast('Lỗi kết nối máy chủ', true);
                        console.error('Error:', error);
                    });
                });
            }
            
            // Register Form
            const registerForm = document.getElementById('registerForm');
            const registerSubmitBtn = document.getElementById('registerSubmitBtn');
            
            if (registerForm) {
                registerForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    let isValid = true;
                    let firstError = null;
                    
                    const name = document.getElementById('regName');
                    const phone = document.getElementById('regPhone');
                    const email = document.getElementById('regEmail');
                    const password = document.getElementById('regPassword');
                    const confirm = document.getElementById('regConfirmPassword');
                    const terms = document.getElementById('agreeTerms');
                    
                    if (!name.value.trim()) { showError(name, true); isValid = false; if (!firstError) firstError = name; }
                    
                    const phoneRegex = /(84|0[3|5|7|8|9])+([0-9]{8})\b/;
                    if (!phoneRegex.test(phone.value.trim())) { showError(phone, true); isValid = false; if (!firstError) firstError = phone; }
                    
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email.value.trim())) { showError(email, true); isValid = false; if (!firstError) firstError = email; }
                    
                    const passRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
                    if (!passRegex.test(password.value.trim())) { showError(password, true); isValid = false; if (!firstError) firstError = password; }

                    if (!confirm.value.trim() || password.value.trim() !== confirm.value.trim()) { showError(confirm, true); isValid = false; if (!firstError) firstError = confirm; }
                    
                    if (!terms.checked) { showError(terms, true); isValid = false; if (!firstError) firstError = terms; }
                    
                    if (!isValid) {
                        if (firstError) firstError.focus();
                        return;
                    }
                    
                    registerSubmitBtn.disabled = true;
                    registerSubmitBtn.classList.add('loading');
                    const btnText = registerSubmitBtn.querySelector('.btn-text');
                    const originalText = btnText.textContent;
                    btnText.textContent = 'Đang tạo tài khoản...';

                    const params = new URLSearchParams();
                    params.append('fullname', name.value.trim());
                    params.append('phone', phone.value.trim());
                    params.append('email', email.value.trim());
                    params.append('password', password.value.trim());
                    params.append('confirm_password', confirm.value.trim());
                    params.append('agree', 'Đồng ý');

                    fetch('${pageContext.request.contextPath}/dangky', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: params
                    })
                    .then(r => r.json())
                    .then(data => {
                        if (data.success && data.step === 'otp') {
                            openOtpModal(data.email);
                        } else if (data.success && data.redirectUrl) {
                            window.location.href = data.redirectUrl;
                        } else {
                            registerSubmitBtn.disabled = false;
                            registerSubmitBtn.classList.remove('loading');
                            btnText.textContent = originalText;
                            showToast(data.loi || 'Đã xảy ra lỗi, vui lòng thử lại.', true);
                        }
                    })
                    .catch(() => {
                        registerSubmitBtn.disabled = false;
                        registerSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    });
                });
            }
            
            // ── OTP MODAL LOGIC ──────────────────────────────────────────
            (function() {
                const modal = document.getElementById('otpModal');
                const boxes = Array.from(document.querySelectorAll('.otp-digit'));
                const submitBtn = document.getElementById('otpSubmitBtn');
                const spinner = document.getElementById('otpSpinner');
                const timerEl = document.getElementById('otpTimerDisplay');
                const resendLink = document.getElementById('otpResendLink');
                const resendCooldown = document.getElementById('otpResendCooldown');
                const emailDisplay = document.getElementById('otpEmailDisplay');

                let otpEmail = '';
                let expireTimer, resendTimer;

                // Style helpers (use CSS classes)
                function setBoxBlur(box) {
                    box.classList.toggle('filled', !!box.value);
                }
                function shakeBoxes() {
                    boxes.forEach(b => {
                        b.style.borderColor = '#dc2626';
                        b.style.animation = 'otpShake .4s ease';
                        setTimeout(() => { b.style.animation = ''; b.style.borderColor = ''; setBoxBlur(b); }, 500);
                    });
                }

                function updateState() {
                    const full = boxes.every(b => b.value);
                    submitBtn.disabled = !full;
                    submitBtn.style.opacity = full ? '1' : '.35';
                    submitBtn.style.cursor = full ? 'pointer' : 'not-allowed';
                }

                // OTP box interactions
                boxes.forEach((box, i) => {
                    box.addEventListener('blur', () => setBoxBlur(box));
                    box.addEventListener('keydown', e => {
                        if (e.key === 'Backspace') {
                            if (!box.value && i > 0) { boxes[i-1].focus(); boxes[i-1].value = ''; setBoxBlur(boxes[i-1]); }
                            else box.value = '';
                            updateState();
                        } else if (e.key === 'ArrowLeft' && i > 0) boxes[i-1].focus();
                        else if (e.key === 'ArrowRight' && i < 5) boxes[i+1].focus();
                    });
                    box.addEventListener('input', e => {
                        const raw = box.value.replace(/\D/g,'').slice(-1);
                        box.value = raw;
                        updateState();
                        if (raw && i < 5) boxes[i+1].focus();
                    });
                    box.addEventListener('paste', e => {
                        e.preventDefault();
                        const text = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g,'');
                        text.split('').slice(0,6).forEach((ch, idx) => { if (boxes[idx]) boxes[idx].value = ch; });
                        updateState();
                        const last = Math.min(text.length, 5);
                        if (boxes[last]) boxes[last].focus();
                    });
                });

                // Countdown timer (5 min)
                function startExpireTimer() {
                    clearInterval(expireTimer);
                    let secs = 5 * 60;
                    function tick() {
                        const m = Math.floor(secs / 60), s = secs % 60;
                        timerEl.textContent = m + ':' + String(s).padStart(2,'0');
                        timerEl.style.color = secs < 30 ? '#f87171' : '#01e281';
                        if (secs <= 0) { clearInterval(expireTimer); timerEl.textContent = 'Hết hạn'; }
                        secs--;
                    }
                    tick(); expireTimer = setInterval(tick, 1000);
                }

                // Resend cooldown (60s)
                function startResendCooldown() {
                    clearInterval(resendTimer);
                    resendLink.style.color = '#94a3b8';
                    resendLink.style.pointerEvents = 'none';
                    let secs = 60;
                    function tick() {
                        resendCooldown.textContent = 'Có thể gửi lại sau ' + secs + 's';
                        if (secs <= 0) {
                            clearInterval(resendTimer);
                            resendCooldown.textContent = '';
                            resendLink.style.color = '#01a85a';
                            resendLink.style.pointerEvents = 'auto';
                        }
                        secs--;
                    }
                    tick(); resendTimer = setInterval(tick, 1000);
                }

                // Open modal
                window.openOtpModal = function(email) {
                    otpEmail = email;
                    emailDisplay.textContent = email;
                    boxes.forEach(b => { b.value = ''; setBoxBlur(b); });
                    updateState();
                    modal.style.display = 'flex';
                    document.body.style.overflow = 'hidden';
                    startExpireTimer();
                    startResendCooldown();
                    setTimeout(() => boxes[0].focus(), 150);
                };

                // Resend OTP
                resendLink.addEventListener('click', (e) => {
                    e.preventDefault();
                    if (resendLink.style.pointerEvents === 'none') return;
                    fetch('${pageContext.request.contextPath}/resend-otp', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: 'email=' + encodeURIComponent(otpEmail)
                    }).catch(() => {});
                    startExpireTimer();
                    startResendCooldown();
                    boxes.forEach(b => { b.value = ''; setBoxBlur(b); });
                    updateState();
                    boxes[0].focus();
                });

                // Submit OTP
                submitBtn.addEventListener('click', () => {
                    const code = boxes.map(b => b.value).join('');
                    if (code.length < 6) { shakeBoxes(); return; }

                    submitBtn.disabled = true;
                    spinner.style.display = 'inline-block';

                    const p = new URLSearchParams();
                    p.append('otp', code);
                    p.append('email', otpEmail);

                    fetch('${pageContext.request.contextPath}/nhapma', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: p
                    })
                    .then(r => r.json())
                    .then(data => {
                        spinner.style.display = 'none';
                        if (data.success) {
                            clearInterval(expireTimer);
                            clearInterval(resendTimer);
                            modal.style.display = 'none';
                            document.body.style.overflow = '';
                            showToast('Tạo tài khoản thành công! Đang chuyển trang...', false);
                            setTimeout(() => { window.location.href = data.redirectUrl || '${pageContext.request.contextPath}/index.jsp?auth=login'; }, 1500);
                        } else {
                            shakeBoxes();
                            submitBtn.disabled = false;
                            showToast(data.loi || 'Mã OTP không đúng, vui lòng thử lại.', true);
                        }
                    })
                    .catch(() => {
                        spinner.style.display = 'none';
                        submitBtn.disabled = false;
                        shakeBoxes();
                        showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    });
                });

                // Close on backdrop click (optional — prevent accidental close)
                modal.addEventListener('click', (e) => { if (e.target === modal) { /* intentionally no close */ } });
            })();
            // ── END OTP MODAL ──────────────────────────────────────────────

            // Real-time password matching feedback
            const PASS_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
            function onRegPasswordInput() {
                const pw = document.getElementById('regPassword');
                const cf = document.getElementById('regConfirmPassword');
                if (!pw) return;
                showError(pw, pw.value.trim() && !PASS_REGEX.test(pw.value.trim()));
                if (cf && cf.value.trim()) updateConfirmFeedback(pw, cf);
            }
            function onRegConfirmInput() {
                const pw = document.getElementById('regPassword');
                const cf = document.getElementById('regConfirmPassword');
                if (!pw || !cf) return;
                updateConfirmFeedback(pw, cf);
            }
            function updateConfirmFeedback(pw, cf) {
                const ok = document.getElementById('regConfirmOk');
                const errEl = document.getElementById('regConfirmPasswordError');
                const match = cf.value.trim() && pw.value.trim() === cf.value.trim();
                if (match) {
                    showError(cf, false);
                    if (ok) ok.style.display = 'flex';
                } else {
                    if (ok) ok.style.display = 'none';
                    if (cf.value.trim()) showError(cf, true);
                }
            }

            // ── Universal scroll-reveal helper ──────────────────────────
            function makeObserver(selector, staggerMs, threshold) {
                const els = document.querySelectorAll(selector);
                if (!els.length) return;
                const io = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (!entry.isIntersecting) return;
                        const items = entry.target.tagName === 'UL' || entry.target.classList.contains('grid-parent')
                            ? entry.target.children
                            : [entry.target];
                        [...items].forEach((el, i) => setTimeout(() => el.classList.add('visible'), i * (staggerMs || 0)));
                        io.unobserve(entry.target);
                    });
                }, { threshold: threshold || 0.12 });
                els.forEach(el => io.observe(el));
            }

            // Benefit bar – stagger each item
            (function() {
                const grid = document.querySelector('.benefits');
                if (!grid) return;
                const io = new IntersectionObserver(entries => {
                    entries.forEach(e => {
                        if (!e.isIntersecting) return;
                        [...grid.querySelectorAll('.benefit-item')].forEach((el, i) =>
                            setTimeout(() => el.classList.add('visible'), i * 110));
                        io.unobserve(e.target);
                    });
                }, { threshold: 0.15 });
                io.observe(grid);
            })();

            // Product cards – stagger
            (function() {
                const grid = document.querySelector('.product-grid');
                if (!grid) return;
                const io = new IntersectionObserver(entries => {
                    entries.forEach(e => {
                        if (!e.isIntersecting) return;
                        [...grid.querySelectorAll('.product-card')].forEach((el, i) =>
                            setTimeout(() => el.classList.add('visible'), i * 90));
                        io.unobserve(e.target);
                    });
                }, { threshold: 0.08 });
                io.observe(grid);
            })();

            // App / mobile-app section
            makeObserver('.mobile-app', 0, 0.15);

            // Blog cards – stagger
            (function() {
                const grid = document.querySelector('.blog-grid');
                if (!grid) return;
                const io = new IntersectionObserver(entries => {
                    entries.forEach(e => {
                        if (!e.isIntersecting) return;
                        [...grid.querySelectorAll('.blog-card')].forEach((el, i) =>
                            setTimeout(() => el.classList.add('visible'), i * 100));
                        io.unobserve(e.target);
                    });
                }, { threshold: 0.1 });
                io.observe(grid);
            })();

            // Review cards – stagger
            (function() {
                const grid = document.querySelector('.reviews-grid');
                if (!grid) return;
                const io = new IntersectionObserver(entries => {
                    entries.forEach(e => {
                        if (!e.isIntersecting) return;
                        [...grid.querySelectorAll('.review-card')].forEach((el, i) =>
                            setTimeout(() => el.classList.add('visible'), i * 110));
                        io.unobserve(e.target);
                    });
                }, { threshold: 0.12 });
                io.observe(grid);
            })();

            // Promo banners curtain animation (odd from left, even from right, staggered)
            const promoBanners = document.querySelectorAll('.promo-banner');
            if (promoBanners.length > 0 && 'IntersectionObserver' in window) {
                const bannerObserver = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            const grid = entry.target;
                            const banners = grid.querySelectorAll('.promo-banner');
                            banners.forEach((b, i) => {
                                setTimeout(() => b.classList.add('visible'), i * 120);
                            });
                            bannerObserver.unobserve(grid);
                        }
                    });
                }, { threshold: 0.1 });
                const promoGrid = document.querySelector('.promo-banners');
                if (promoGrid) bannerObserver.observe(promoGrid);
            } else {
                promoBanners.forEach(b => b.classList.add('visible'));
            }

            // Category scroll-in animation (sequential stagger)
            const categoryCards = document.querySelectorAll('.category-card');
            if (categoryCards.length > 0 && 'IntersectionObserver' in window) {
                const catObserver = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            const cards = entry.target.querySelectorAll('.category-card');
                            cards.forEach((card, i) => {
                                setTimeout(() => card.classList.add('visible'), i * 100);
                            });
                            catObserver.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.15 });
                const categoryGrid = document.querySelector('.category-grid');
                if (categoryGrid) catObserver.observe(categoryGrid);
            } else {
                categoryCards.forEach(c => c.classList.add('visible'));
            }

            // Forgot Form
            const forgotForm = document.getElementById('forgotForm');
            const forgotSubmitBtn = document.getElementById('forgotSubmitBtn');
            
            if (forgotForm) {
                forgotForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    
                    const email = document.getElementById('forgotEmail');
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    
                    if (!emailRegex.test(email.value.trim())) {
                        showError(email, true);
                        email.focus();
                        return;
                    }
                    
                    // Simulate API Call
                    forgotSubmitBtn.disabled = true;
                    forgotSubmitBtn.classList.add('loading');
                    const btnText = forgotSubmitBtn.querySelector('.btn-text');
                    const originalText = btnText.textContent;
                    btnText.textContent = 'Đang gửi...';
                    
                    setTimeout(() => {
                        forgotSubmitBtn.disabled = false;
                        forgotSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        closeModal();
                        showToast('Liên kết khôi phục mật khẩu đã được gửi đến email của bạn.');
                        forgotForm.reset();
                    }, 800);
                });
            }
    </script>
</body>
</html>
