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

        <!-- ═══ ANNOUNCEMENT BAR ═══ -->
        <div class="vs-ann-bar" role="region" aria-label="Thông báo">
            <div class="vs-ann-bar__track">
                <span class="vs-ann-bar__msg is-active">Đặt sân lần đầu — nhận ưu đãi đến 10% tại các cơ sở áp dụng.</span>
                <span class="vs-ann-bar__msg">Đặt sân nhanh, xác nhận rõ ràng — không chờ đợi, không lo lắng.</span>
                <span class="vs-ann-bar__msg">Ghép kèo cùng cộng đồng thể thao — tìm đồng đội ngay hôm nay!</span>
            </div>
            <button class="vs-ann-bar__close" aria-label="Đóng">&times;</button>
        </div>

        <div class="vs-commerce-home">

        <!-- ═══ HERO SLIDER ═══ -->
        <section class="vs-hero" aria-label="Trang chủ V-SPORT">
            <div class="vs-hero__track">

                <!-- Slide 1 – Sân bóng đá -->
                <div class="vs-slide is-active">
                    <div class="vs-slide__bg">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-football.jpg" alt="Sân bóng đá V-SPORT" loading="eager">
                        <div class="vs-slide__overlay"></div>
                    </div>
                    <div class="vs-slide__content">
                        <span class="vs-slide__eyebrow">V-Sport · Đặt sân thông minh</span>
                        <h1 class="vs-slide__title">Đặt Sân Nhanh<br>Chơi Ngay Hôm Nay</h1>
                        <p class="vs-slide__desc">Hàng trăm sân bóng đá, cầu lông, pickleball chất lượng cao — đặt sân chỉ trong 30 giây, xác nhận tức thì.</p>
                        <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-slide__cta">
                            Đặt sân ngay
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                    </div>
                </div>

                <!-- Slide 2 – Cộng đồng -->
                <div class="vs-slide">
                    <div class="vs-slide__bg">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-playing.jpg" alt="Cộng đồng V-SPORT" loading="lazy">
                        <div class="vs-slide__overlay"></div>
                    </div>
                    <div class="vs-slide__content">
                        <span class="vs-slide__eyebrow">Cộng đồng thể thao</span>
                        <h1 class="vs-slide__title">Ghép Kèo<br>Kết Nối Đồng Đội</h1>
                        <p class="vs-slide__desc">Không đủ người? Tìm ngay đối thủ hoặc đồng đội phù hợp trình độ, gần khu vực của bạn chỉ với vài cú chạm.</p>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-slide__cta">
                            Ghép kèo ngay
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                    </div>
                </div>

                <!-- Slide 3 – Cầu lông -->
                <div class="vs-slide">
                    <div class="vs-slide__bg">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-badminton.jpg" alt="Sân cầu lông V-SPORT" loading="lazy">
                        <div class="vs-slide__overlay"></div>
                    </div>
                    <div class="vs-slide__content">
                        <span class="vs-slide__eyebrow">Khám phá hệ thống sân</span>
                        <h1 class="vs-slide__title">Đa Dạng Bộ Môn<br>Đẳng Cấp Dịch Vụ</h1>
                        <p class="vs-slide__desc">Từ bóng đá, cầu lông đến pickleball — hệ thống sân trải dài khắp thành phố, sẵn sàng cho mọi lịch trình của bạn.</p>
                        <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-slide__cta">
                            Khám phá ngay
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                    </div>
                </div>
            </div>

            <!-- Dots -->
            <div class="vs-hero__dots" role="tablist" aria-label="Điều hướng slider">
                <button class="vs-hero__dot is-active" role="tab" aria-selected="true" aria-label="Slide 1"></button>
                <button class="vs-hero__dot" role="tab" aria-selected="false" aria-label="Slide 2"></button>
                <button class="vs-hero__dot" role="tab" aria-selected="false" aria-label="Slide 3"></button>
            </div>

            <!-- Arrows -->
            <button class="vs-hero__arrow vs-hero__arrow--l" aria-label="Slide trước">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
            </button>
            <button class="vs-hero__arrow vs-hero__arrow--r" aria-label="Slide tiếp">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </button>
        </section>

        <!-- ═══ PRODUCTS & SERVICES ═══ -->
        <section class="vs-products-section vs-reveal" aria-label="Sản phẩm nổi bật">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Sản phẩm &amp; <span>dịch vụ nổi bật</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-section-link">Xem tất cả
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                    </a>
                </div>

                <!-- Pill tabs -->
                <div class="vs-tabs-row" role="tablist">
                    <button class="vs-pill is-active" data-tab="all" role="tab">Tất cả</button>
                    <button class="vs-pill" data-tab="dungcu" role="tab">Dụng cụ</button>
                    <button class="vs-pill" data-tab="trangphuc" role="tab">Trang phục</button>
                    <button class="vs-pill" data-tab="dichvu" role="tab">Dịch vụ</button>
                    <button class="vs-pill" data-tab="phukien" role="tab">Phụ kiện</button>
                </div>

                <!-- Panel: All -->
                <div class="vs-carousel-wrap">
                    <div class="vs-tab-panel" data-panel="all">
                        <div class="vs-carousel" id="productCarouselAll">
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/pickleball.jpg" alt="Vợt Pickleball Carbon Pro" loading="lazy">
                                    <span class="vs-product-card__badge">Hot</span>
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Pickleball</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball">Vợt Pickleball Carbon Pro</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(48)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">1.290.000đ</span>
                                        <span class="vs-product-card__price-old">1.590.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/badminton.jpg" alt="Giày cầu lông chống trượt" loading="lazy">
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Cầu lông</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông">Giày cầu lông chống trượt</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(72)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">890.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/football.jpg" alt="Bóng đá tiêu chuẩn Size 5" loading="lazy">
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Bóng đá</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá">Bóng đá tiêu chuẩn Size 5</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i> <span style="color:var(--vs-muted);font-size:12px">(35)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">350.000đ</span>
                                        <span class="vs-product-card__price-old">420.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-04.jpg" alt="Áo thể thao V-SPORT Dry Fit" loading="lazy">
                                    <span class="vs-product-card__badge">Mới</span>
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Trang phục</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Áo thể thao V-SPORT Dry Fit</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(61)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">249.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/tennis.jpg" alt="Túi đựng vợt đa năng" loading="lazy">
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Phụ kiện</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis">Túi đựng vợt đa năng</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i> <span style="color:var(--vs-muted);font-size:12px">(29)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">459.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Thuê vợt tại cơ sở" loading="lazy">
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Dịch vụ</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Thuê vợt tại cơ sở</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(114)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">Từ 30.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-05.jpg" alt="Huấn luyện viên cá nhân" loading="lazy">
                                    <span class="vs-product-card__badge">HOT</span>
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Dịch vụ</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Huấn luyện viên cá nhân</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(88)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">Từ 200.000đ/buổi</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/basketball.jpg" alt="Bình nước thể thao 750ml" loading="lazy">
                                    <button class="vs-product-card__fav" aria-label="Yêu thích"><i class="far fa-heart"></i></button>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Phụ kiện</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Bình nước thể thao 750ml</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i> <span style="color:var(--vs-muted);font-size:12px">(55)</span></div>
                                    <div class="vs-product-card__price-row">
                                        <span class="vs-product-card__price">159.000đ</span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Panel: Dụng cụ -->
                    <div class="vs-tab-panel" data-panel="dungcu" hidden>
                        <div class="vs-carousel">
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/pickleball.jpg" alt="Vợt Pickleball Carbon Pro" loading="lazy">
                                    <span class="vs-product-card__badge">Hot</span>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Pickleball</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball">Vợt Pickleball Carbon Pro</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">1.290.000đ</span><span class="vs-product-card__price-old">1.590.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/football.jpg" alt="Bóng đá Size 5" loading="lazy">
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Bóng đá</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá">Bóng đá tiêu chuẩn Size 5</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">350.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Panel: Trang phục -->
                    <div class="vs-tab-panel" data-panel="trangphuc" hidden>
                        <div class="vs-carousel">
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-04.jpg" alt="Áo Dry Fit" loading="lazy">
                                    <span class="vs-product-card__badge">Mới</span>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Trang phục</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Áo thể thao V-SPORT Dry Fit</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">249.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-06.jpg" alt="Quần short thể thao" loading="lazy">
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Trang phục</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Quần short thể thao V-SPORT</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">189.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Panel: Dịch vụ -->
                    <div class="vs-tab-panel" data-panel="dichvu" hidden>
                        <div class="vs-carousel">
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Thuê vợt" loading="lazy">
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Dịch vụ</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Thuê vợt tại cơ sở</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">Từ 30.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-05.jpg" alt="HLV cá nhân" loading="lazy">
                                    <span class="vs-product-card__badge">HOT</span>
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Dịch vụ</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Huấn luyện viên cá nhân</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">Từ 200.000đ/buổi</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem tại cơ sở</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Panel: Phụ kiện -->
                    <div class="vs-tab-panel" data-panel="phukien" hidden>
                        <div class="vs-carousel">
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/tennis.jpg" alt="Túi vợt" loading="lazy">
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Phụ kiện</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis">Túi đựng vợt đa năng</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="far fa-star"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">459.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                            <div class="vs-product-card">
                                <div class="vs-product-card__img-wrap">
                                    <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/basketball.jpg" alt="Bình nước" loading="lazy">
                                </div>
                                <div class="vs-product-card__body">
                                    <div class="vs-product-card__cat">Phụ kiện</div>
                                    <h3 class="vs-product-card__name"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Bình nước thể thao 750ml</a></h3>
                                    <div class="vs-product-card__stars"><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i></div>
                                    <div class="vs-product-card__price-row"><span class="vs-product-card__price">159.000đ</span></div>
                                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-product-card__cta"><i class="fas fa-eye"></i> Xem chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="vs-c-arrows">
                        <button class="vs-c-arrow vs-c-arrow--l" aria-label="Trước"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                        <button class="vs-c-arrow vs-c-arrow--r" aria-label="Tiếp"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ CATEGORY DISCOVERY ═══ -->
        <section class="vs-cats-section vs-reveal" aria-label="Khám phá môn thể thao">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Khám phá <span>môn thể thao</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-section-link">Xem tất cả sân</a>
                </div>
                <div class="vs-cats-layout">
                    <!-- Sidebar list -->
                    <div class="vs-cat-list">
                        <p class="vs-cat-list__title">Chọn môn bạn yêu thích</p>
                        <div class="vs-cat-item is-active" data-cat="football" data-title="Sân Bóng đá" data-sub="70+ sân tại Vũng Tàu & khu vực lân cận" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-futbol" style="margin-right:10px;color:var(--vs-sage)"></i>Bóng đá</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                        <div class="vs-cat-item" data-cat="badminton" data-title="Sân Cầu lông" data-sub="85+ sân có mái che, đèn chiếu sáng" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Cầu lông" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-table-tennis-paddle-ball" style="margin-right:10px;color:var(--vs-sage)"></i>Cầu lông</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                        <div class="vs-cat-item" data-cat="pickleball" data-title="Sân Pickleball" data-sub="40+ sân tiêu chuẩn, cho thuê vợt tại chỗ" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-circle-dot" style="margin-right:10px;color:var(--vs-sage)"></i>Pickleball</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                        <div class="vs-cat-item" data-cat="tennis" data-title="Sân Tennis" data-sub="30+ sân đất nện và sân cứng" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-baseball-bat-ball" style="margin-right:10px;color:var(--vs-sage)"></i>Tennis</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                        <div class="vs-cat-item" data-cat="basketball" data-title="Sân Bóng rổ" data-sub="20+ sân trong nhà & ngoài trời" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng rổ" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-basketball" style="margin-right:10px;color:var(--vs-sage)"></i>Bóng rổ</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                        <div class="vs-cat-item" data-cat="volleyball" data-title="Sân Bóng chuyền" data-sub="15+ sân bãi biển & trong nhà" data-link="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng chuyền" role="button" tabindex="0">
                            <span class="vs-cat-item__label"><i class="fas fa-volleyball" style="margin-right:10px;color:var(--vs-sage)"></i>Bóng chuyền</span>
                            <span class="vs-cat-item__arrow"><i class="fas fa-chevron-right"></i></span>
                        </div>
                    </div>

                    <!-- Image panel -->
                    <div class="vs-cat-panel" role="img">
                        <div class="vs-cat-panel__img is-visible" data-cat="football">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-football.jpg" alt="Sân bóng đá" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__img" data-cat="badminton">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-badminton.jpg" alt="Sân cầu lông" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__img" data-cat="pickleball">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Sân Pickleball" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__img" data-cat="tennis">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-tennis.jpg" alt="Sân Tennis" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__img" data-cat="basketball">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/basketball.jpg" alt="Sân Bóng rổ" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__img" data-cat="volleyball">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/volleyball.jpg" alt="Sân Bóng chuyền" loading="lazy">
                        </div>
                        <div class="vs-cat-panel__overlay">
                            <h3 class="vs-cat-panel__title" id="catPanelTitle">Sân Bóng đá</h3>
                            <p class="vs-cat-panel__sub" id="catPanelSub">70+ sân tại Vũng Tàu & khu vực lân cận</p>
                            <a class="vs-cat-panel__btn" id="catPanelLink" href="${pageContext.request.contextPath}/customer/tim-kiem?q=Bóng đá">
                                Xem sân ngay <i class="fas fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ WHY V-SPORT ═══ -->
        <section class="vs-why-section" aria-label="Vì sao chọn V-SPORT">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Vì sao chọn <span>V-SPORT?</span></h2>
                </div>
                <div class="vs-why-grid">
                    <div class="vs-why-card vs-reveal vs-reveal--delay-1">
                        <div class="vs-why-card__icon"><i class="fas fa-calendar-check"></i></div>
                        <h3 class="vs-why-card__title">Đặt sân nhanh chóng</h3>
                        <p class="vs-why-card__desc">Chọn môn, khu vực, khung giờ và xác nhận trong vài phút. Không cần gọi điện, không phải chờ đợi.</p>
                    </div>
                    <div class="vs-why-card vs-reveal vs-reveal--delay-2">
                        <div class="vs-why-card__icon"><i class="fas fa-shield-halved"></i></div>
                        <h3 class="vs-why-card__title">Thanh toán an toàn</h3>
                        <p class="vs-why-card__desc">Hỗ trợ thanh toán trực tuyến và tiền mặt. Mọi giao dịch được mã hóa và bảo mật tuyệt đối.</p>
                    </div>
                    <div class="vs-why-card vs-reveal vs-reveal--delay-3">
                        <div class="vs-why-card__icon"><i class="fas fa-users"></i></div>
                        <h3 class="vs-why-card__title">Ghép kèo thông minh</h3>
                        <p class="vs-why-card__desc">Tìm đồng đội cùng trình độ, cùng môn và khung giờ phù hợp. Không bao giờ thiếu người chơi.</p>
                    </div>
                    <div class="vs-why-card vs-reveal vs-reveal--delay-4">
                        <div class="vs-why-card__icon"><i class="fas fa-headset"></i></div>
                        <h3 class="vs-why-card__title">Hỗ trợ tận tâm</h3>
                        <p class="vs-why-card__desc">Đội ngũ V-SPORT luôn sẵn sàng hỗ trợ bạn trước, trong và sau khi đặt sân. 7 ngày/tuần.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ COURTS CAROUSEL ═══ -->
        <section class="vs-courts-section vs-reveal" aria-label="Sân nổi bật">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Sân <span>được đặt nhiều nhất</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-section-link">Xem tất cả sân</a>
                </div>
                <div class="vs-carousel-wrap">
                    <div class="vs-carousel" id="courtCarousel">
                        <div class="vs-court-card">
                            <div class="vs-court-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-badminton.jpg" alt="Sân cầu lông" loading="lazy">
                                <span class="vs-court-card__status">Còn sân</span>
                            </div>
                            <div class="vs-court-card__body">
                                <div class="vs-court-card__sport"><i class="fas fa-table-tennis-paddle-ball"></i> Cầu lông</div>
                                <h3 class="vs-court-card__name">Trung tâm Cầu lông Vũng Tàu</h3>
                                <div class="vs-court-card__addr"><i class="fas fa-location-dot"></i> 12 Lê Lợi, P.1, Vũng Tàu</div>
                                <div class="vs-court-card__meta">
                                    <span class="vs-court-card__rating"><i class="fas fa-star"></i> 4.9 <span style="color:var(--vs-muted);font-weight:400">(128 đánh giá)</span></span>
                                    <span class="vs-court-card__price">Từ 80.000đ/h</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-court-card__cta">Đặt sân ngay</a>
                            </div>
                        </div>
                        <div class="vs-court-card">
                            <div class="vs-court-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-football.jpg" alt="Sân bóng đá" loading="lazy">
                                <span class="vs-court-card__status">Còn sân</span>
                            </div>
                            <div class="vs-court-card__body">
                                <div class="vs-court-card__sport"><i class="fas fa-futbol"></i> Bóng đá</div>
                                <h3 class="vs-court-card__name">Sân bóng đá Thành Công</h3>
                                <div class="vs-court-card__addr"><i class="fas fa-location-dot"></i> 55 Trương Công Định, Vũng Tàu</div>
                                <div class="vs-court-card__meta">
                                    <span class="vs-court-card__rating"><i class="fas fa-star"></i> 4.8 <span style="color:var(--vs-muted);font-weight:400">(96 đánh giá)</span></span>
                                    <span class="vs-court-card__price">Từ 200.000đ/h</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-court-card__cta">Đặt sân ngay</a>
                            </div>
                        </div>
                        <div class="vs-court-card">
                            <div class="vs-court-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-pickleball.jpg" alt="Sân Pickleball" loading="lazy">
                                <span class="vs-court-card__status">Còn sân</span>
                            </div>
                            <div class="vs-court-card__body">
                                <div class="vs-court-card__sport"><i class="fas fa-circle-dot"></i> Pickleball</div>
                                <h3 class="vs-court-card__name">Sân Pickleball Long Điền</h3>
                                <div class="vs-court-card__addr"><i class="fas fa-location-dot"></i> 28 Lý Thường Kiệt, Long Điền</div>
                                <div class="vs-court-card__meta">
                                    <span class="vs-court-card__rating"><i class="fas fa-star"></i> 4.7 <span style="color:var(--vs-muted);font-weight:400">(74 đánh giá)</span></span>
                                    <span class="vs-court-card__price">Từ 60.000đ/h</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-court-card__cta">Đặt sân ngay</a>
                            </div>
                        </div>
                        <div class="vs-court-card">
                            <div class="vs-court-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-tennis.jpg" alt="Sân Tennis" loading="lazy">
                                <span class="vs-court-card__status">Còn sân</span>
                            </div>
                            <div class="vs-court-card__body">
                                <div class="vs-court-card__sport"><i class="fas fa-baseball-bat-ball"></i> Tennis</div>
                                <h3 class="vs-court-card__name">Sân Tennis Trung Tâm</h3>
                                <div class="vs-court-card__addr"><i class="fas fa-location-dot"></i> 8 Nguyễn Trãi, P.7, Vũng Tàu</div>
                                <div class="vs-court-card__meta">
                                    <span class="vs-court-card__rating"><i class="fas fa-star"></i> 4.8 <span style="color:var(--vs-muted);font-weight:400">(52 đánh giá)</span></span>
                                    <span class="vs-court-card__price">Từ 120.000đ/h</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-court-card__cta">Đặt sân ngay</a>
                            </div>
                        </div>
                        <div class="vs-court-card">
                            <div class="vs-court-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/basketball.jpg" alt="Sân bóng rổ" loading="lazy">
                                <span class="vs-court-card__status">Còn sân</span>
                            </div>
                            <div class="vs-court-card__body">
                                <div class="vs-court-card__sport"><i class="fas fa-basketball"></i> Bóng rổ</div>
                                <h3 class="vs-court-card__name">Sân Bóng rổ V-Arena</h3>
                                <div class="vs-court-card__addr"><i class="fas fa-location-dot"></i> 44 Hoàng Diệu, P.5, Vũng Tàu</div>
                                <div class="vs-court-card__meta">
                                    <span class="vs-court-card__rating"><i class="fas fa-star"></i> 4.6 <span style="color:var(--vs-muted);font-weight:400">(41 đánh giá)</span></span>
                                    <span class="vs-court-card__price">Từ 90.000đ/h</span>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-court-card__cta">Đặt sân ngay</a>
                            </div>
                        </div>
                    </div>
                    <div class="vs-c-arrows">
                        <button class="vs-c-arrow vs-c-arrow--l" aria-label="Trước"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                        <button class="vs-c-arrow vs-c-arrow--r" aria-label="Tiếp"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ HOW IT WORKS ═══ -->
        <section class="vs-howto-section" aria-label="Cách thức hoạt động">
            <div class="vs-container">
                <h2 class="vs-section-title" style="color:#fff;margin-bottom:0">Đặt sân chỉ trong <span style="color:var(--vs-sage)">4 bước đơn giản</span></h2>
                <div class="vs-howto-layout">
                    <!-- Visual side -->
                    <div class="vs-howto-img-wrap">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-booking.jpg" data-step="1" class="is-visible" alt="Tìm kiếm sân" loading="lazy">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-payment.jpg" data-step="2" alt="Thanh toán" loading="lazy">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-checkin.jpg" data-step="3" alt="Check in" loading="lazy">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-playing.jpg" data-step="4" alt="Thi đấu" loading="lazy">
                    </div>

                    <!-- Steps -->
                    <div class="vs-howto-steps">
                        <div class="vs-howto-step is-active" data-step="1">
                            <div class="vs-howto-step__num">1</div>
                            <div class="vs-howto-step__text">
                                <h3 class="vs-howto-step__title">Tìm sân phù hợp</h3>
                                <p class="vs-howto-step__desc">Lọc theo môn thể thao, khu vực và khung giờ bạn muốn. Xem ảnh, giá và đánh giá thực tế từ cộng đồng.</p>
                            </div>
                        </div>
                        <div class="vs-howto-step" data-step="2">
                            <div class="vs-howto-step__num">2</div>
                            <div class="vs-howto-step__text">
                                <h3 class="vs-howto-step__title">Chọn giờ & thanh toán</h3>
                                <p class="vs-howto-step__desc">Chọn khung giờ trống, điền thông tin và thanh toán trực tuyến hoặc tiền mặt tại sân. An toàn, bảo mật.</p>
                            </div>
                        </div>
                        <div class="vs-howto-step" data-step="3">
                            <div class="vs-howto-step__num">3</div>
                            <div class="vs-howto-step__text">
                                <h3 class="vs-howto-step__title">Nhận xác nhận tức thì</h3>
                                <p class="vs-howto-step__desc">Xác nhận đặt sân qua email và thông báo. Lịch thi đấu hiển thị ngay trong tài khoản của bạn.</p>
                            </div>
                        </div>
                        <div class="vs-howto-step" data-step="4">
                            <div class="vs-howto-step__num">4</div>
                            <div class="vs-howto-step__text">
                                <h3 class="vs-howto-step__title">Check-in & thi đấu</h3>
                                <p class="vs-howto-step__desc">Đến sân, xuất trình mã xác nhận và sẵn sàng thi đấu. Đơn giản như vậy thôi!</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ COMMUNITY / GHEP KEO ═══ -->
        <section class="vs-community-section vs-reveal" aria-label="Ghép kèo">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Ghép kèo <span>cùng cộng đồng</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-section-link">Xem tất cả trận</a>
                </div>
                <div class="vs-match-grid">
                    <div class="vs-match-card">
                        <div class="vs-match-card__sport"><i class="fas fa-futbol"></i> Bóng đá</div>
                        <h3 class="vs-match-card__title">Tìm 2 người cho trận 5vs5 tối thứ 7</h3>
                        <div class="vs-match-card__meta">
                            <div class="vs-match-card__row"><i class="fas fa-calendar"></i> Thứ 7, 02/08/2026 · 19:00</div>
                            <div class="vs-match-card__row"><i class="fas fa-location-dot"></i> Sân Thành Công, Vũng Tàu</div>
                            <div class="vs-match-card__row"><i class="fas fa-signal"></i> Trình độ: Trung bình</div>
                        </div>
                        <div class="vs-match-card__slots">Còn 2 chỗ trống</div>
                        <div class="vs-match-card__avatars">
                            <div class="vs-match-card__avatar">T</div>
                            <div class="vs-match-card__avatar">N</div>
                            <div class="vs-match-card__avatar">H</div>
                            <div class="vs-match-card__avatar" style="background:var(--vs-beige);color:var(--vs-dark);font-size:10px">+5</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-match-card__cta">Tham gia ngay</a>
                    </div>
                    <div class="vs-match-card">
                        <div class="vs-match-card__sport"><i class="fas fa-table-tennis-paddle-ball"></i> Cầu lông</div>
                        <h3 class="vs-match-card__title">Đôi nam ghép cặp đánh đôi cuối tuần</h3>
                        <div class="vs-match-card__meta">
                            <div class="vs-match-card__row"><i class="fas fa-calendar"></i> Chủ nhật, 03/08/2026 · 07:00</div>
                            <div class="vs-match-card__row"><i class="fas fa-location-dot"></i> TT Cầu lông Vũng Tàu</div>
                            <div class="vs-match-card__row"><i class="fas fa-signal"></i> Trình độ: Khá</div>
                        </div>
                        <div class="vs-match-card__slots">Còn 1 chỗ trống</div>
                        <div class="vs-match-card__avatars">
                            <div class="vs-match-card__avatar">A</div>
                            <div class="vs-match-card__avatar">B</div>
                            <div class="vs-match-card__avatar">C</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-match-card__cta">Tham gia ngay</a>
                    </div>
                    <div class="vs-match-card">
                        <div class="vs-match-card__sport"><i class="fas fa-circle-dot"></i> Pickleball</div>
                        <h3 class="vs-match-card__title">Tìm bạn đánh Pickleball buổi sáng</h3>
                        <div class="vs-match-card__meta">
                            <div class="vs-match-card__row"><i class="fas fa-calendar"></i> Thứ 2, 04/08/2026 · 06:30</div>
                            <div class="vs-match-card__row"><i class="fas fa-location-dot"></i> Sân Pickleball Long Điền</div>
                            <div class="vs-match-card__row"><i class="fas fa-signal"></i> Trình độ: Mọi trình độ</div>
                        </div>
                        <div class="vs-match-card__slots">Còn 3 chỗ trống</div>
                        <div class="vs-match-card__avatars">
                            <div class="vs-match-card__avatar">M</div>
                            <div class="vs-match-card__avatar">L</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-match-card__cta">Tham gia ngay</a>
                    </div>
                    <div class="vs-match-card">
                        <div class="vs-match-card__sport"><i class="fas fa-basketball"></i> Bóng rổ</div>
                        <h3 class="vs-match-card__title">3vs3 pickup game chiều tối thứ 6</h3>
                        <div class="vs-match-card__meta">
                            <div class="vs-match-card__row"><i class="fas fa-calendar"></i> Thứ 6, 01/08/2026 · 18:00</div>
                            <div class="vs-match-card__row"><i class="fas fa-location-dot"></i> Sân V-Arena, Vũng Tàu</div>
                            <div class="vs-match-card__row"><i class="fas fa-signal"></i> Trình độ: Mọi trình độ</div>
                        </div>
                        <div class="vs-match-card__slots">Còn 2 chỗ trống</div>
                        <div class="vs-match-card__avatars">
                            <div class="vs-match-card__avatar">K</div>
                            <div class="vs-match-card__avatar">P</div>
                            <div class="vs-match-card__avatar">Q</div>
                            <div class="vs-match-card__avatar">R</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-match-card__cta">Tham gia ngay</a>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ PARTNERS ═══ -->
        <section class="vs-partners-section vs-reveal" aria-label="Đối tác">
            <div class="vs-container">
                <p class="vs-partners-label">Đối tác & cơ sở uy tín trên V-SPORT</p>
                <div class="vs-partners-list">
                    <span class="vs-partner-item">SportZone</span>
                    <span class="vs-partner-item">ArenaVT</span>
                    <span class="vs-partner-item">ProCourt</span>
                    <span class="vs-partner-item">VungTau FC</span>
                    <span class="vs-partner-item">SmashPro</span>
                    <span class="vs-partner-item">FitArena</span>
                </div>
            </div>
        </section>

        <!-- ═══ BLOG ═══ -->
        <section class="vs-blog-section vs-reveal" aria-label="Tin tức & kinh nghiệm">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Tin tức & <span>kinh nghiệm thể thao</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-section-link">Xem thêm bài viết</a>
                </div>
                <div class="vs-carousel-wrap">
                    <div class="vs-carousel" id="blogCarousel">
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-01.jpg" alt="5 lưu ý chọn sân phù hợp" loading="lazy">
                                <span class="vs-blog-card__cat">Kinh nghiệm</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 10/06/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">5 lưu ý giúp bạn chọn sân thể thao phù hợp nhất</a></h3>
                                <p class="vs-blog-card__excerpt">Không phải sân nào cũng phù hợp với mọi trình độ và phong cách chơi. Cùng V-SPORT tìm hiểu cách chọn sân thông minh.</p>
                                <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/categories/pickleball.jpg" alt="Chọn vợt Pickleball" loading="lazy">
                                <span class="vs-blog-card__cat">Pickleball</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 08/06/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball">Hướng dẫn chọn vợt Pickleball cho người mới bắt đầu</a></h3>
                                <p class="vs-blog-card__excerpt">Carbon hay fiberglass? Nặng hay nhẹ? Bài viết này giải đáp mọi thắc mắc để bạn chọn được cây vợt ưng ý đầu tiên.</p>
                                <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Pickleball" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/experience/experience-playing.jpg" alt="Khởi động" loading="lazy">
                                <span class="vs-blog-card__cat">Sức khỏe</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 05/06/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Tầm quan trọng của khởi động đúng cách trước khi thi đấu</a></h3>
                                <p class="vs-blog-card__excerpt">Khởi động kỹ không chỉ tăng hiệu suất mà còn giúp bạn tránh chấn thương không đáng có. Đừng bỏ qua bước này!</p>
                                <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-03.jpg" alt="Tìm đồng đội" loading="lazy">
                                <span class="vs-blog-card__cat">Cộng đồng</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 02/06/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/ghep-keo">Làm thế nào để tìm được đồng đội hợp trình độ trên V-SPORT?</a></h3>
                                <p class="vs-blog-card__excerpt">Tính năng ghép kèo trên V-SPORT hoạt động như thế nào? Hướng dẫn đầy đủ cho người mới sử dụng nền tảng.</p>
                                <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-02.jpg" alt="Dinh dưỡng" loading="lazy">
                                <span class="vs-blog-card__cat">Sức khỏe</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 28/05/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/tim-kiem">Dinh dưỡng trước và sau khi tập thể thao — bí quyết phục hồi nhanh</a></h3>
                                <p class="vs-blog-card__excerpt">Ăn gì trước khi ra sân? Bổ sung gì sau khi thi đấu? Cùng chuyên gia V-SPORT chia sẻ bí quyết.</p>
                                <a href="${pageContext.request.contextPath}/customer/tim-kiem" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                        <div class="vs-blog-card">
                            <div class="vs-blog-card__img">
                                <img src="${pageContext.request.contextPath}/assets/images/vsport/courts/court-tennis.jpg" alt="Bí quyết Tennis" loading="lazy">
                                <span class="vs-blog-card__cat">Tennis</span>
                            </div>
                            <div class="vs-blog-card__body">
                                <div class="vs-blog-card__date"><i class="far fa-calendar"></i> 20/05/2026</div>
                                <h3 class="vs-blog-card__title"><a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis">5 kỹ thuật đánh Tennis cơ bản cho người mới bắt đầu</a></h3>
                                <p class="vs-blog-card__excerpt">Từ grip, stance cho đến swing cơ bản — hướng dẫn từng bước để bạn tự tin bước ra sân ngay hôm nay.</p>
                                <a href="${pageContext.request.contextPath}/customer/tim-kiem?q=Tennis" class="vs-blog-card__read">Đọc tiếp <i class="fas fa-arrow-right"></i></a>
                            </div>
                        </div>
                    </div>
                    <div class="vs-c-arrows">
                        <button class="vs-c-arrow vs-c-arrow--l" aria-label="Trước"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                        <button class="vs-c-arrow vs-c-arrow--r" aria-label="Tiếp"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ TEAM ═══ -->
        <section class="vs-team-section vs-reveal" aria-label="Đội ngũ V-SPORT">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Đội ngũ <span>xây dựng V-SPORT</span></h2>
                </div>
                <div class="vs-team-grid">
                    <div class="vs-team-card">
                        <div class="vs-team-card__img">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-01.jpg" alt="Nguyễn Văn An" loading="lazy">
                        </div>
                        <div class="vs-team-card__body">
                            <h3 class="vs-team-card__name">Nguyễn Văn An</h3>
                            <div class="vs-team-card__role">Backend Developer</div>
                            <p class="vs-team-card__contribution">Thiết kế và xây dựng API đặt sân, hệ thống thanh toán và quản lý người dùng.</p>
                            <div class="vs-team-card__skills">
                                <span class="vs-team-card__skill">Java</span>
                                <span class="vs-team-card__skill">Jakarta EE</span>
                                <span class="vs-team-card__skill">MySQL</span>
                            </div>
                        </div>
                    </div>
                    <div class="vs-team-card">
                        <div class="vs-team-card__img">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-02.jpg" alt="Trần Thị Bảo" loading="lazy">
                        </div>
                        <div class="vs-team-card__body">
                            <h3 class="vs-team-card__name">Trần Thị Bảo</h3>
                            <div class="vs-team-card__role">Frontend Developer</div>
                            <p class="vs-team-card__contribution">Thiết kế giao diện người dùng, tối ưu trải nghiệm đặt sân và ghép kèo trên mọi thiết bị.</p>
                            <div class="vs-team-card__skills">
                                <span class="vs-team-card__skill">JSP</span>
                                <span class="vs-team-card__skill">CSS</span>
                                <span class="vs-team-card__skill">JavaScript</span>
                            </div>
                        </div>
                    </div>
                    <div class="vs-team-card">
                        <div class="vs-team-card__img">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/players/person-03.jpg" alt="Lê Hoàng Cường" loading="lazy">
                        </div>
                        <div class="vs-team-card__body">
                            <h3 class="vs-team-card__name">Lê Hoàng Cường</h3>
                            <div class="vs-team-card__role">Full-Stack Developer</div>
                            <p class="vs-team-card__contribution">Tích hợp tính năng ghép kèo, hệ thống thông báo real-time và bản đồ sân gần bạn.</p>
                            <div class="vs-team-card__skills">
                                <span class="vs-team-card__skill">Java</span>
                                <span class="vs-team-card__skill">JSP/JSTL</span>
                                <span class="vs-team-card__skill">Ajax</span>
                            </div>
                        </div>
                    </div>
                    <div class="vs-team-card">
                        <div class="vs-team-card__img">
                            <img src="${pageContext.request.contextPath}/assets/images/vsport/community/team-01.jpg" alt="Phạm Thị Dung" loading="lazy">
                        </div>
                        <div class="vs-team-card__body">
                            <h3 class="vs-team-card__name">Phạm Thị Dung</h3>
                            <div class="vs-team-card__role">UX & Product</div>
                            <p class="vs-team-card__contribution">Nghiên cứu người dùng, xây dựng luồng đặt sân và tối ưu chuyển đổi trên toàn nền tảng.</p>
                            <div class="vs-team-card__skills">
                                <span class="vs-team-card__skill">UX Research</span>
                                <span class="vs-team-card__skill">Figma</span>
                                <span class="vs-team-card__skill">Testing</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ GALLERY ═══ -->
        <section class="vs-gallery-section vs-reveal" aria-label="Thư viện ảnh">
            <div class="vs-container">
                <div class="vs-section-head">
                    <h2 class="vs-section-title">Cộng đồng <span>V-SPORT</span></h2>
                    <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="vs-section-link">Khám phá cộng đồng</a>
                </div>
                <div class="vs-gallery-grid">
                    <div class="vs-gallery-item">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-01.jpg" alt="Cộng đồng 1" loading="lazy">
                        <div class="vs-gallery-item__overlay"><i class="fas fa-expand vs-gallery-item__icon"></i></div>
                    </div>
                    <div class="vs-gallery-item">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-01.jpg" alt="Gallery 1" loading="lazy">
                        <div class="vs-gallery-item__overlay"><i class="fas fa-expand vs-gallery-item__icon"></i></div>
                    </div>
                    <div class="vs-gallery-item">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-02.jpg" alt="Gallery 2" loading="lazy">
                        <div class="vs-gallery-item__overlay"><i class="fas fa-expand vs-gallery-item__icon"></i></div>
                    </div>
                    <div class="vs-gallery-item">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/community/community-02.jpg" alt="Cộng đồng 2" loading="lazy">
                        <div class="vs-gallery-item__overlay"><i class="fas fa-expand vs-gallery-item__icon"></i></div>
                    </div>
                    <div class="vs-gallery-item">
                        <img src="${pageContext.request.contextPath}/assets/images/vsport/gallery/gallery-03.jpg" alt="Gallery 3" loading="lazy">
                        <div class="vs-gallery-item__overlay"><i class="fas fa-expand vs-gallery-item__icon"></i></div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ═══ NEWSLETTER ═══ -->
        <section class="vs-newsletter-section vs-reveal" aria-label="Đăng ký nhận tin">
            <div class="vs-container">
                <div class="vs-newsletter-box">
                    <div class="vs-newsletter-copy">
                        <h2>Nhận ưu đãi từ V-SPORT</h2>
                        <p>Cập nhật sân mới, khuyến mãi độc quyền và lịch thi đấu cộng đồng hằng tuần.</p>
                    </div>
                    <form class="vs-nl-form" id="newsletterForm" novalidate>
                        <input type="email" placeholder="Nhập địa chỉ email của bạn" required aria-label="Email đăng ký nhận tin">
                        <button type="submit">Đăng ký ngay</button>
                    </form>
                </div>
            </div>
        </section>

        </div><!-- /.vs-commerce-home -->
        </div><!-- /#homeView -->

        <!-- Auth View – PRESERVED UNCHANGED -->
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
                    <p>Nhập email của bạn, chúng tôi sẽ tạo một mật khẩu mới và gửi ngay đến email này.</p>

                    <form id="forgotForm" novalidate>
                        <div class="form-group">
                            <label for="forgotEmail">Email <span>*</span></label>
                            <input type="email" id="forgotEmail" name="email" class="form-control" placeholder="Nhập email..." required aria-describedby="forgotEmailError">
                            <div id="forgotEmailError" class="error-message"><i class="fas fa-exclamation-circle"></i> Email không hợp lệ</div>
                        </div>

                        <div class="auth-actions">
                            <button type="submit" class="btn btn-primary btn-auth" id="forgotSubmitBtn" style="width: 100%;">
                                <i class="fas fa-spinner"></i>
                                <span class="btn-text">Gửi mật khẩu mới</span>
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

    <!-- OTP Verification Modal – PRESERVED UNCHANGED -->
    <div id="otpModal" style="display:none;position:fixed;inset:0;z-index:10000;align-items:center;justify-content:center;padding:20px;background:rgba(15,23,42,.6);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);" role="dialog" aria-modal="true">
        <div style="background:#fff;border-radius:20px;width:100%;max-width:400px;box-shadow:0 24px 64px rgba(0,0,0,.2);overflow:hidden;animation:otpCardIn .28s cubic-bezier(.34,1.3,.64,1);">
            <div style="background:#0f172a;padding:18px 24px;display:flex;align-items:center;justify-content:space-between;">
                <div style="display:flex;align-items:center;gap:9px;">
                    <div style="width:28px;height:28px;background:#01e281;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:13px;color:#042d1a;">
                        <i class="fas fa-shield-halved"></i>
                    </div>
                    <span style="color:#fff;font-size:13px;font-weight:700;letter-spacing:.5px;font-family:'Outfit',sans-serif;">Xác minh tài khoản</span>
                </div>
                <span id="otpTimerDisplay" style="font-size:13px;font-weight:700;color:#01e281;font-family:'JetBrains Mono','Courier New',monospace;">5:00</span>
            </div>
            <div style="padding:24px 28px 26px;">
                <p style="font-size:13px;color:#64748b;margin:0 0 20px;line-height:1.5;">
                    Mã 6 số đã gửi tới <strong id="otpEmailDisplay" style="color:#0f172a;"></strong>
                </p>
                <div id="otpBoxRow" style="display:flex;gap:8px;justify-content:center;margin-bottom:20px;">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                    <input class="otp-digit" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="off">
                </div>
                <button id="otpSubmitBtn" disabled style="width:100%;padding:13px;border:none;border-radius:12px;background:#0f172a;color:#fff;font-size:14px;font-weight:700;font-family:'Outfit',sans-serif;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;opacity:.35;transition:all .2s;">
                    <i class="fas fa-spinner" id="otpSpinner" style="display:none;animation:spin 1s linear infinite;"></i>
                    <span>Xác minh</span>
                </button>
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

    <!-- Cart Drawer -->
    <div class="vs-cart-overlay" id="vsCartOverlay" aria-hidden="true"></div>
    <aside class="vs-cart-drawer" id="vsCartDrawer" role="dialog" aria-modal="true" aria-label="Giỏ hàng">
        <div class="vs-cart-drawer__header">
            <h2 class="vs-cart-drawer__title"><i class="fas fa-shopping-cart" style="color:var(--vs-primary);margin-right:8px"></i>Giỏ hàng</h2>
            <button class="vs-cart-drawer__close" id="vsCartClose" aria-label="Đóng giỏ hàng"><i class="fas fa-times"></i></button>
        </div>
        <div class="vs-cart-drawer__body">
            <div class="vs-cart-empty">
                <i class="fas fa-shopping-basket"></i>
                <p>Giỏ hàng của bạn đang trống</p>
                <a href="${pageContext.request.contextPath}/customer/tim-kiem" style="display:inline-block;margin-top:16px;padding:10px 24px;background:var(--vs-primary);color:#fff;border-radius:999px;font-weight:700;text-decoration:none;font-size:14px">Khám phá sản phẩm</a>
            </div>
        </div>
        <div class="vs-cart-drawer__footer">
            <div class="vs-cart-drawer__total"><span>Tổng cộng</span><span>0đ</span></div>
            <div class="vs-cart-drawer__actions">
                <a href="${pageContext.request.contextPath}/customer/gio-hang" class="vs-cart-drawer__btn vs-cart-drawer__btn--primary"><i class="fas fa-shopping-cart"></i>Xem giỏ hàng</a>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-cart-drawer__btn vs-cart-drawer__btn--outline"><i class="fas fa-calendar-check"></i>Đặt sân ngay</a>
            </div>
        </div>
    </aside>

    <!-- Scroll to Top with SVG Progress Ring -->
    <button class="vs-scroll-top" id="scrollTop" aria-label="Lên đầu trang">
        <svg viewBox="0 0 48 48" aria-hidden="true">
            <circle class="vs-scroll-top__bg" cx="24" cy="24" r="20.8"/>
            <circle class="vs-scroll-top__progress" cx="24" cy="24" r="20.8"/>
        </svg>
        <i class="fas fa-chevron-up vs-scroll-top__icon"></i>
    </button>

    <!-- Scripts -->
    <script defer src="${pageContext.request.contextPath}/assets/js/home-commerce.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {

            // ── AUTH LOGIC ──────────────────────────────────────────────
            const homeView = document.getElementById('homeView');
            const authView = document.getElementById('authView');
            const accountBtn = document.getElementById('authBtn');

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

            const pendingRedirect = urlParams.get('redirect');

            if (accountBtn) {
                accountBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    window.location.hash = '#auth';
                });
            }

            const breadcrumbHome = document.getElementById('breadcrumbHome');
            if (breadcrumbHome) {
                breadcrumbHome.addEventListener('click', (e) => {
                    e.preventDefault();
                    window.location.hash = '#home';
                });
            }

            // Auth Tabs
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
            document.querySelectorAll('.password-toggle').forEach(btn => {
                btn.addEventListener('click', () => {
                    const input = btn.previousElementSibling;
                    const icon = btn.querySelector('i');
                    if (input.type === 'password') {
                        input.type = 'text';
                        icon.classList.replace('fa-eye-slash', 'fa-eye');
                    } else {
                        input.type = 'password';
                        icon.classList.replace('fa-eye', 'fa-eye-slash');
                    }
                });
            });

            // Forgot Modal
            const forgotModal = document.getElementById('forgotModal');
            const forgotBtn   = document.getElementById('forgotBtn');
            const closeModalBtn = document.getElementById('closeModalBtn');
            const forgotEmail = document.getElementById('forgotEmail');

            function openModal()  { forgotModal.classList.add('active'); document.body.style.overflow = 'hidden'; setTimeout(() => forgotEmail && forgotEmail.focus(), 100); }
            function closeModal() { forgotModal.classList.remove('active'); document.body.style.overflow = ''; if (forgotBtn) forgotBtn.focus(); }

            if (forgotBtn) forgotBtn.addEventListener('click', (e) => { e.preventDefault(); openModal(); });
            if (closeModalBtn) closeModalBtn.addEventListener('click', closeModal);
            window.addEventListener('click', (e) => { if (e.target === forgotModal) closeModal(); });
            window.addEventListener('keydown', (e) => { if (e.key === 'Escape' && forgotModal && forgotModal.classList.contains('active')) closeModal(); });

            // Toast
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
                setTimeout(() => successToast.classList.remove('active'), 3500);
            }

            // Newsletter
            const newsletterForm = document.getElementById('newsletterForm');
            if (newsletterForm) {
                newsletterForm.addEventListener('submit', function(e) {
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

            // Validation helpers
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
            document.querySelectorAll('.form-control, .form-check input').forEach(input => {
                input.addEventListener('input', () => showError(input, false));
                input.addEventListener('change', () => showError(input, false));
            });

            // Login Form
            const loginForm = document.getElementById('loginForm');
            const loginSubmitBtn = document.getElementById('loginSubmitBtn');
            if (loginForm) {
                loginForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    let isValid = true, firstError = null;
                    const email = document.getElementById('loginEmail');
                    const password = document.getElementById('loginPassword');
                    if (!email.value.trim()) { showError(email, true); isValid = false; if (!firstError) firstError = email; }
                    if (!password.value.trim()) { showError(password, true); isValid = false; if (!firstError) firstError = password; }
                    if (!isValid) { firstError.focus(); return; }

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
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: formData.toString()
                    })
                    .then(r => r.json())
                    .then(data => {
                        loginSubmitBtn.disabled = false;
                        loginSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        if (data.success) {
                            showToast('Đăng nhập thành công!', false);
                            setTimeout(() => { window.location.href = data.redirectUrl; }, 500);
                        } else {
                            showToast('Lỗi: ' + (data.loi || 'Đăng nhập thất bại'), true);
                        }
                    })
                    .catch(() => {
                        loginSubmitBtn.disabled = false;
                        loginSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        showToast('Lỗi kết nối máy chủ', true);
                    });
                });
            }

            // Register Form
            const registerForm = document.getElementById('registerForm');
            const registerSubmitBtn = document.getElementById('registerSubmitBtn');
            if (registerForm) {
                registerForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    let isValid = true, firstError = null;
                    const name = document.getElementById('regName');
                    const phone = document.getElementById('regPhone');
                    const email = document.getElementById('regEmail');
                    const password = document.getElementById('regPassword');
                    const confirm = document.getElementById('regConfirmPassword');
                    const terms = document.getElementById('agreeTerms');

                    if (!name.value.trim()) { showError(name, true); isValid = false; if (!firstError) firstError = name; }
                    if (!/(84|0[3|5|7|8|9])+([0-9]{8})\b/.test(phone.value.trim())) { showError(phone, true); isValid = false; if (!firstError) firstError = phone; }
                    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) { showError(email, true); isValid = false; if (!firstError) firstError = email; }
                    if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(password.value.trim())) { showError(password, true); isValid = false; if (!firstError) firstError = password; }
                    if (!confirm.value.trim() || password.value.trim() !== confirm.value.trim()) { showError(confirm, true); isValid = false; if (!firstError) firstError = confirm; }
                    if (!terms.checked) { showError(terms, true); isValid = false; if (!firstError) firstError = terms; }
                    if (!isValid) { if (firstError) firstError.focus(); return; }

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
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
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

            // ── OTP MODAL ───────────────────────────────────────────────
            (function() {
                const modal = document.getElementById('otpModal');
                const boxes = Array.from(document.querySelectorAll('.otp-digit'));
                const submitBtn = document.getElementById('otpSubmitBtn');
                const spinner = document.getElementById('otpSpinner');
                const timerEl = document.getElementById('otpTimerDisplay');
                const resendLink = document.getElementById('otpResendLink');
                const resendCooldown = document.getElementById('otpResendCooldown');
                const emailDisplay = document.getElementById('otpEmailDisplay');
                let otpEmail = '', expireTimer, resendTimer;

                function setBoxBlur(box) { box.classList.toggle('filled', !!box.value); }
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
                function startResendCooldown() {
                    clearInterval(resendTimer);
                    resendLink.style.color = '#94a3b8';
                    resendLink.style.pointerEvents = 'none';
                    let secs = 60;
                    function tick() {
                        resendCooldown.textContent = 'Có thể gửi lại sau ' + secs + 's';
                        if (secs <= 0) { clearInterval(resendTimer); resendCooldown.textContent = ''; resendLink.style.color = '#01a85a'; resendLink.style.pointerEvents = 'auto'; }
                        secs--;
                    }
                    tick(); resendTimer = setInterval(tick, 1000);
                }
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
                resendLink.addEventListener('click', (e) => {
                    e.preventDefault();
                    if (resendLink.style.pointerEvents === 'none') return;
                    fetch('${pageContext.request.contextPath}/resend-otp', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: 'email=' + encodeURIComponent(otpEmail)
                    }).catch(() => {});
                    startExpireTimer(); startResendCooldown();
                    boxes.forEach(b => { b.value = ''; setBoxBlur(b); });
                    updateState(); boxes[0].focus();
                });
                submitBtn.addEventListener('click', () => {
                    const code = boxes.map(b => b.value).join('');
                    if (code.length < 6) { shakeBoxes(); return; }
                    submitBtn.disabled = true;
                    spinner.style.display = 'inline-block';
                    const p = new URLSearchParams();
                    p.append('otp', code); p.append('email', otpEmail);
                    fetch('${pageContext.request.contextPath}/nhapma', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: p
                    })
                    .then(r => r.json())
                    .then(data => {
                        spinner.style.display = 'none';
                        if (data.success) {
                            clearInterval(expireTimer); clearInterval(resendTimer);
                            modal.style.display = 'none'; document.body.style.overflow = '';
                            showToast('Tạo tài khoản thành công! Đang chuyển trang...', false);
                            setTimeout(() => { window.location.href = data.redirectUrl || '${pageContext.request.contextPath}/index.jsp?auth=login'; }, 1500);
                        } else {
                            shakeBoxes(); submitBtn.disabled = false;
                            showToast(data.loi || 'Mã OTP không đúng, vui lòng thử lại.', true);
                        }
                    })
                    .catch(() => {
                        spinner.style.display = 'none'; submitBtn.disabled = false;
                        shakeBoxes(); showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    });
                });
                modal.addEventListener('click', (e) => { if (e.target === modal) { /* intentionally no close */ } });
            })();
            // ── END OTP MODAL ────────────────────────────────────────────

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
                const match = cf.value.trim() && pw.value.trim() === cf.value.trim();
                if (match) {
                    showError(cf, false);
                    if (ok) ok.style.display = 'flex';
                } else {
                    if (ok) ok.style.display = 'none';
                    if (cf.value.trim()) showError(cf, true);
                }
            }

            // Forgot Form
            const forgotForm = document.getElementById('forgotForm');
            const forgotSubmitBtn = document.getElementById('forgotSubmitBtn');
            if (forgotForm) {
                forgotForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const email = document.getElementById('forgotEmail');
                    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim())) {
                        showError(email, true); email.focus(); return;
                    }
                    forgotSubmitBtn.disabled = true;
                    forgotSubmitBtn.classList.add('loading');
                    const btnText = forgotSubmitBtn.querySelector('.btn-text');
                    const originalText = btnText.textContent;
                    btnText.textContent = 'Đang gửi...';

                    const formData = new URLSearchParams();
                    formData.append('method', 'email');
                    formData.append('email', email.value.trim());

                    fetch('${pageContext.request.contextPath}/quenmatkhau', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                        body: formData.toString()
                    })
                    .then(r => r.json())
                    .then(data => {
                        forgotSubmitBtn.disabled = false;
                        forgotSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        if (data.success) {
                            closeModal();
                            showToast(data.thongbao || 'Mật khẩu mới đã được gửi đến email của bạn.');
                            forgotForm.reset();
                            setTimeout(() => { window.location.href = data.redirectUrl; }, 1500);
                        } else {
                            showToast(data.loi || 'Không thể đặt lại mật khẩu. Vui lòng thử lại.', true);
                        }
                    })
                    .catch(() => {
                        forgotSubmitBtn.disabled = false;
                        forgotSubmitBtn.classList.remove('loading');
                        btnText.textContent = originalText;
                        showToast('Lỗi kết nối máy chủ', true);
                    });
                });
            }

            // Category panel interactive (supplement to home-commerce.js)
            const catItems = document.querySelectorAll('.vs-cat-item');
            const catPanelTitle = document.getElementById('catPanelTitle');
            const catPanelSub   = document.getElementById('catPanelSub');
            const catPanelLink  = document.getElementById('catPanelLink');
            catItems.forEach(item => {
                item.addEventListener('click', () => {
                    const cat = item.dataset.cat;
                    catItems.forEach(c => c.classList.remove('is-active'));
                    item.classList.add('is-active');
                    document.querySelectorAll('.vs-cat-panel__img').forEach(img => img.classList.remove('is-visible'));
                    const target = document.querySelector('.vs-cat-panel__img[data-cat="' + cat + '"]');
                    if (target) target.classList.add('is-visible');
                    if (catPanelTitle) catPanelTitle.textContent = item.dataset.title || '';
                    if (catPanelSub)   catPanelSub.textContent   = item.dataset.sub   || '';
                    if (catPanelLink)  catPanelLink.href          = item.dataset.link  || '#';
                });
                item.addEventListener('keydown', (e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); item.click(); } });
            });
        });
    </script>
</body>
</html>
