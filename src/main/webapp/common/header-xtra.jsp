<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.example.model.TaiKhoan" %>
        <header class="header">
            <div class="top-header">
                <div class="container">
                    <div class="header-main">
                        <a href="${pageContext.request.contextPath}/" class="logo">
                            <i class="fa-solid fa-basket-shopping"></i>
                            V-<span>SPORT</span>
                        </a>

                        <div class="search-bar">
                            <form action="#">
                                <input type="text" placeholder="What are you looking for?">
                                <button type="submit"><i class="fas fa-search"></i></button>
                            </form>
                        </div>

                        <div class="header-actions">
                            <div class="call-center">
                                <div class="call-icon">
                                    <i class="fas fa-phone-alt"></i>
                                </div>
                                <div class="call-text">
                                    <span>Call Center</span>
                                    <strong>818-555 67 88</strong>
                                </div>
                            </div>

                            <div class="action-icons">
                                <a href="#" class="icon-btn">
                                    <i class="fas fa-shopping-basket"></i>
                                    <span class="badge">0</span>
                                </a>
                                <a href="#" class="icon-btn">
                                    <i class="far fa-heart"></i>
                                    <span class="badge">0</span>
                                </a>
                                <% TaiKhoan user=(TaiKhoan) session.getAttribute("user"); if (user !=null) { %>
                                    <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="icon-btn"
                                        style="width: auto; padding: 0 15px; gap: 8px; border-radius: 20px;">
                                        <i class="far fa-user"></i>
                                        <span style="font-size: 14px; font-weight: 600;">
                                            <%= user.getFullName() %>
                                        </span>
                                    </a>
                                    <% } else { %>
                                        <a href="#auth" class="icon-btn" id="authBtn">
                                            <i class="far fa-user"></i>
                                        </a>
                                        <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Navigation -->
            <div class="bottom-header">
                <div class="container">
                    <div class="nav-inner">
                        <nav class="main-nav">
                            <ul>
                                <li><a href="#" class="nav-category"><i class="fas fa-bars"></i>Bản đồ</a></li>
                                <li><a href="#">Đặt sân</a></li>
                                <li><a href="#">Ghép Kèo<span class="hot-badge">HOT</span></a></li>
                                <li><a href="#">Tin tức <i class="fas fa-angle-down"></i></a></li>
                                <li><a href="#">Thẻ thành viên</a></li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>
        </header>