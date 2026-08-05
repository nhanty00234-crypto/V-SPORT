<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🏟️</text></svg>">
<title>V-Sport — Nâng Tầm Quản Lý Cơ Sở Thể Thao</title>
<meta name="description" content="Hệ thống quản lý thông minh giúp tối ưu lịch đặt sân, quản lý hội viên và tăng doanh thu hiệu quả.">
<meta name="theme-color" content="#ea580c">

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="">
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

<style>
/* =====================================================
   V-SPORT OWNER LANDING — Orange Theme
   Inspired by ThanhTruc_Project / Nhiệt Đới Xanh design
   ===================================================== */
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}

:root{
  --cream:#FDFBF7;
  --cream-dark:#F5F0E8;
  --cream-warm:#FFF3E8;
  --orange:#ea580c;
  --orange-dark:#c2410c;
  --orange-light:#f97316;
  --accent:#fb923c;
  --accent-light:#fdba74;
  --white:#FFFFFF;
  --text-dark:#1c0f07;
  --text-body:#4a3520;
  --text-muted:#78614a;
  --border:#E8E0D0;
  --font:'Be Vietnam Pro',-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
  --section-py:96px;
  --max-w:1200px;
  --ease:cubic-bezier(0.16,1,0.3,1);
  --transition:all 0.4s var(--ease);
}

html{scroll-behavior:smooth;font-size:16px}
body{font-family:var(--font);color:var(--text-body);background:var(--cream);line-height:1.7;-webkit-font-smoothing:antialiased;overflow-x:hidden}
h1,h2,h3,h4,h5,h6{font-family:var(--font);color:var(--text-dark);line-height:1.15;font-weight:700}
a{text-decoration:none;color:inherit;transition:var(--transition)}
img{max-width:100%;display:block}
ul{list-style:none}
.container{max-width:var(--max-w);margin:0 auto;padding:0 24px}
.section{padding:var(--section-py) 0;position:relative}

.section-label{display:inline-flex;align-items:center;gap:10px;font-size:0.72rem;font-weight:600;letter-spacing:3px;text-transform:uppercase;color:var(--orange);margin-bottom:16px}
.section-label::before{content:'';width:36px;height:2px;background:var(--accent)}
.section-title{font-size:clamp(2rem,5vw,3.2rem);margin-bottom:18px;color:var(--text-dark);font-weight:800}
.section-subtitle{font-size:1.1rem;color:var(--text-muted);max-width:560px;line-height:1.8}

/* REVEAL */
.reveal{opacity:0;transform:translateY(50px);transition:opacity 0.9s var(--ease),transform 0.9s var(--ease)}
.reveal.visible{opacity:1;transform:translateY(0)}
.reveal-delay-1{transition-delay:0.1s}.reveal-delay-2{transition-delay:0.2s}
.reveal-delay-3{transition-delay:0.3s}.reveal-delay-4{transition-delay:0.4s}
.reveal-delay-5{transition-delay:0.5s}

/* PARALLAX SPORTS */
.parallax-sport{position:fixed;font-size:2.5rem;opacity:0.07;pointer-events:none;z-index:0;will-change:transform}

/* NAVBAR */
.navbar{position:fixed;top:0;left:0;width:100%;z-index:1000;padding:20px 0;transition:var(--transition);background:transparent}
.navbar.scrolled{background:rgba(253,251,247,0.88);backdrop-filter:blur(20px) saturate(180%);-webkit-backdrop-filter:blur(20px) saturate(180%);padding:12px 0;box-shadow:0 1px 30px rgba(0,0,0,0.07);border-bottom:1px solid rgba(234,88,12,0.1)}
.navbar .container{display:flex;align-items:center;justify-content:space-between}
.navbar-brand{display:flex;align-items:center;gap:12px}
.navbar-logo{width:44px;height:44px;background:linear-gradient(135deg,var(--orange),var(--orange-light));border-radius:14px;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 12px rgba(234,88,12,0.3)}
.navbar-logo svg{width:24px;height:24px;fill:var(--white)}
.navbar-name{font-size:1.25rem;font-weight:800;color:var(--text-dark);letter-spacing:-0.3px}
.navbar-name span{color:var(--orange-light)}
.nav-links{display:flex;align-items:center;gap:6px}
.nav-links a{font-size:0.88rem;font-weight:500;color:var(--text-body);padding:8px 18px;border-radius:50px}
.nav-links a:hover{color:var(--orange);background:rgba(234,88,12,0.06)}
.nav-links a.active{color:var(--orange);background:var(--cream-warm);font-weight:600}
.nav-cta{font-weight:600!important;color:var(--white)!important;background:var(--orange)!important;padding:10px 26px!important;border-radius:50px!important;box-shadow:0 4px 16px rgba(234,88,12,0.3)}
.nav-cta:hover{background:var(--orange-dark)!important;transform:translateY(-2px);box-shadow:0 8px 24px rgba(234,88,12,0.4)!important}
.nav-toggle{display:none;flex-direction:column;gap:5px;cursor:pointer;padding:8px;background:none;border:none}
.nav-toggle span{width:24px;height:2px;background:var(--text-dark);border-radius:2px;transition:var(--transition)}
@media(max-width:768px){
  .nav-toggle{display:flex}
  .nav-links{display:none;position:absolute;top:100%;left:0;right:0;flex-direction:column;align-items:stretch;gap:4px;background:var(--white);padding:16px 24px;border-top:1px solid var(--border);box-shadow:0 12px 30px rgba(0,0,0,0.08)}
  .nav-links.active{display:flex}
  .nav-links a{padding:12px 16px;border-radius:12px}
}

/* BUTTONS */
.btn{display:inline-flex;align-items:center;gap:8px;font-family:var(--font);font-weight:700;font-size:0.95rem;padding:16px 36px;border-radius:50px;border:none;cursor:pointer;transition:var(--transition)}
.btn-primary{background:var(--orange);color:var(--white);box-shadow:0 6px 24px rgba(234,88,12,0.35)}
.btn-primary:hover{transform:translateY(-3px);background:var(--orange-dark);box-shadow:0 12px 36px rgba(234,88,12,0.45)}
.btn-secondary{background:var(--white);color:var(--orange);border:2px solid var(--border)}
.btn-secondary:hover{border-color:var(--orange);transform:translateY(-2px)}
.btn-outline{border:1px solid var(--border);color:var(--text-dark);background:var(--white);border-radius:12px;padding:11px 20px;font-family:var(--font);font-weight:700;font-size:.9rem;cursor:pointer;transition:all .2s;display:inline-flex;align-items:center;gap:8px}
.btn-outline:hover{border-color:var(--orange);color:var(--orange)}
.btn svg{width:18px;height:18px}

/* HERO */
.hero{min-height:100vh;display:flex;align-items:center;position:relative;overflow:hidden;background:var(--cream);padding-top:80px}
.hero::before{content:'';position:absolute;top:-20%;right:-10%;width:700px;height:700px;background:radial-gradient(circle,rgba(251,146,60,0.12) 0%,transparent 70%);border-radius:50%;animation:floatBlob 14s ease-in-out infinite}
.hero::after{content:'';position:absolute;bottom:-20%;left:-15%;width:600px;height:600px;background:radial-gradient(circle,rgba(234,88,12,0.06) 0%,transparent 70%);border-radius:50%;animation:floatBlob 18s ease-in-out infinite reverse}
@keyframes floatBlob{0%,100%{transform:translate(0,0) scale(1)}33%{transform:translate(30px,-30px) scale(1.05)}66%{transform:translate(-20px,20px) scale(0.95)}}
.hero .container{position:relative;z-index:2;display:grid;grid-template-columns:1fr 1fr;gap:60px;align-items:center}
@media(max-width:900px){.hero .container{grid-template-columns:1fr;gap:40px}}
.hero-content{max-width:540px}
.hero-badge{display:inline-flex;align-items:center;gap:8px;background:rgba(234,88,12,0.08);border:1px solid rgba(234,88,12,0.15);padding:8px 18px;border-radius:50px;font-size:0.78rem;font-weight:600;color:var(--orange);margin-bottom:28px;animation:fadeInDown 0.8s var(--ease) 0.2s both}
.hero-badge svg{width:16px;height:16px;fill:var(--accent)}
@keyframes fadeInDown{from{opacity:0;transform:translateY(-16px)}to{opacity:1;transform:translateY(0)}}
.hero h1{font-size:clamp(2.8rem,6vw,4.5rem);color:var(--text-dark);margin-bottom:10px;line-height:1.05;font-weight:900;letter-spacing:-1px;animation:fadeInUp 0.8s var(--ease) 0.4s both}
.hero h1 .highlight{background:linear-gradient(135deg,var(--orange),var(--accent));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.hero-slogan{font-size:1.1rem;font-style:italic;color:var(--text-muted);margin-bottom:40px;font-weight:400;animation:fadeInUp 0.8s var(--ease) 0.6s both}
@keyframes fadeInUp{from{opacity:0;transform:translateY(28px)}to{opacity:1;transform:translateY(0)}}
.hero-actions{display:flex;align-items:center;gap:16px;flex-wrap:wrap;animation:fadeInUp 0.8s var(--ease) 0.8s both}
.hero-visual{position:relative;display:flex;align-items:center;justify-content:center;animation:fadeInUp 1s var(--ease) 0.5s both;perspective:800px}
.hero-3d-container{position:relative;width:100%;max-width:420px;aspect-ratio:1;display:flex;align-items:center;justify-content:center}
.hero-3d-bg{position:absolute;inset:0;background:linear-gradient(160deg,var(--cream-warm) 0%,rgba(251,146,60,0.2) 50%,var(--cream-dark) 100%);border-radius:40% 60% 55% 45%/55% 45% 60% 40%;animation:morphBlob 12s ease-in-out infinite}
@keyframes morphBlob{0%,100%{border-radius:40% 60% 55% 45%/55% 45% 60% 40%}25%{border-radius:55% 45% 40% 60%/40% 60% 45% 55%}50%{border-radius:45% 55% 60% 40%/60% 40% 55% 45%}75%{border-radius:60% 40% 45% 55%/45% 55% 40% 60%}}
.hero-product-img{position:relative;z-index:2;width:82%;border-radius:22px;filter:drop-shadow(0 20px 40px rgba(234,88,12,0.25));animation:float3D 5s ease-in-out infinite;object-fit:cover;aspect-ratio:4/3}
@keyframes float3D{0%,100%{transform:translateY(0) rotateY(0) rotateX(0)}25%{transform:translateY(-12px) rotateY(3deg) rotateX(2deg)}50%{transform:translateY(-20px) rotateY(0) rotateX(-2deg)}75%{transform:translateY(-8px) rotateY(-3deg) rotateX(1deg)}}
.floating-sport{position:absolute;font-size:2rem;filter:drop-shadow(0 4px 8px rgba(0,0,0,0.1));animation:floatAround 7s ease-in-out infinite;z-index:3}
.sport-1{top:8%;left:5%;animation-delay:0s}.sport-2{top:5%;right:10%;animation-delay:1.2s}
.sport-3{bottom:15%;left:8%;animation-delay:2.4s}.sport-4{bottom:8%;right:5%;animation-delay:3.6s}
@keyframes floatAround{0%,100%{transform:translate(0,0) rotate(0) scale(1)}25%{transform:translate(8px,-14px) rotate(8deg) scale(1.1)}50%{transform:translate(-6px,-22px) rotate(-5deg) scale(1)}75%{transform:translate(12px,-8px) rotate(10deg) scale(1.05)}}

/* STATS BAR */
.stats-bar{background:var(--white);border-top:1px solid var(--border);border-bottom:1px solid var(--border);padding:40px 0}
.stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:24px}
@media(max-width:768px){.stats-grid{grid-template-columns:repeat(2,1fr)}}
.stat-item{text-align:center}
.stat-number{font-size:2.2rem;font-weight:900;color:var(--orange);line-height:1}
.stat-label{font-size:0.85rem;color:var(--text-muted);margin-top:6px;font-weight:500}

/* STORY */
.story{background:var(--cream-dark);position:relative;overflow:hidden}
.story::before{content:'';position:absolute;top:-100px;right:-100px;width:400px;height:400px;background:radial-gradient(circle,rgba(251,146,60,0.08) 0%,transparent 70%);border-radius:50%;animation:floatBlob 16s ease-in-out infinite}
.story .container{display:grid;grid-template-columns:1fr 1fr;gap:70px;align-items:center;position:relative;z-index:1}
@media(max-width:900px){.story .container{grid-template-columns:1fr;gap:40px}}
.story-visual{position:relative}
.story-image-wrapper{width:100%;aspect-ratio:4/5;border-radius:30px;overflow:hidden;background:#fffbf5;display:flex;align-items:center;justify-content:center}
.story-img{width:100%;height:100%;object-fit:cover}
.story-stat{position:absolute;bottom:20px;right:-20px;background:var(--white);border-radius:16px;padding:16px 24px;box-shadow:0 8px 32px rgba(234,88,12,0.15);text-align:center}
.story-stat-number{font-size:2rem;font-weight:900;color:var(--orange)}
.story-stat-label{font-size:0.78rem;color:var(--text-muted);font-weight:600;margin-top:2px}
.story-highlights{display:flex;gap:20px;flex-wrap:wrap;margin-top:28px}
.story-highlight-item{display:flex;align-items:center;gap:10px}
.story-highlight-icon{font-size:1.4rem}
.story-highlight-text{font-size:0.85rem;color:var(--text-body);font-weight:600;line-height:1.4}

/* VALUES */
.values{background:var(--white)}
.values-header{max-width:640px;margin-bottom:clamp(32px,5vh,52px)}
.values-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:24px}
@media(max-width:768px){.values-grid{grid-template-columns:1fr}}
.value-card{background:var(--cream);border:1px solid var(--border);border-radius:20px;padding:32px;transition:var(--transition)}
.value-card:hover{border-color:var(--accent);transform:translateY(-4px);box-shadow:0 16px 40px rgba(234,88,12,0.1)}
.value-icon{width:52px;height:52px;border-radius:14px;background:linear-gradient(135deg,var(--cream-warm),rgba(251,146,60,0.2));display:flex;align-items:center;justify-content:center;font-size:1.6rem;margin-bottom:20px}
.value-card h3{font-size:1.05rem;margin-bottom:10px;color:var(--text-dark)}
.value-card p{font-size:0.9rem;color:var(--text-muted);line-height:1.7}

/* SPORTS SHOWCASE */
.sports-section{background:var(--cream-dark)}
.shop-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:20px}
@media(max-width:900px){.shop-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:480px){.shop-grid{grid-template-columns:1fr 1fr}}
.shop-card{background:var(--white);border:1px solid var(--border);border-radius:20px;overflow:hidden;transition:var(--transition)}
.shop-card:hover{transform:translateY(-4px);box-shadow:0 16px 40px rgba(234,88,12,0.12);border-color:var(--accent)}
.shop-card-media{aspect-ratio:1;background:linear-gradient(135deg,var(--cream-warm),rgba(251,146,60,0.15));display:flex;align-items:center;justify-content:center;font-size:2.8rem}
.shop-card-body{padding:16px}
.shop-card-name{font-weight:700;font-size:0.95rem;color:var(--text-dark);margin-bottom:4px}
.shop-card-desc{font-size:0.8rem;color:var(--text-muted);line-height:1.5}

/* REGISTRATION CHECKOUT SECTION */
.checkout{background:linear-gradient(160deg,var(--orange-dark) 0%,var(--orange) 60%,var(--orange-light) 100%);position:relative;overflow:hidden}
.checkout::before{content:'';position:absolute;top:-200px;right:-200px;width:600px;height:600px;background:radial-gradient(circle,rgba(255,255,255,0.1) 0%,transparent 70%);border-radius:50%}
.checkout .container{display:grid;grid-template-columns:1fr 1fr;gap:70px;align-items:start}
@media(max-width:900px){.checkout .container{grid-template-columns:1fr;gap:40px}}
.checkout-info .section-label{color:var(--accent-light)}
.checkout-info .section-label::before{background:rgba(255,255,255,0.4)}
.checkout-info .section-title{color:var(--white)}
.checkout-info .section-subtitle{color:rgba(255,255,255,0.8)}
.checkout-features{display:flex;flex-direction:column;gap:20px;margin-top:32px}
.checkout-feature{display:flex;align-items:center;gap:16px}
.checkout-feature-icon{width:48px;height:48px;border-radius:14px;background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;font-size:1.3rem;flex-shrink:0}
.checkout-feature-text h4{font-size:0.95rem;font-weight:700;color:var(--white)}
.checkout-feature-text p{font-size:0.85rem;color:rgba(255,255,255,0.7);margin-top:2px}

/* FORM CARD */
.order-form-wrapper{background:var(--white);border-radius:28px;padding:clamp(24px,4vw,40px);box-shadow:0 24px 60px rgba(0,0,0,0.18)}
.order-form-title{font-size:1.05rem;font-weight:800;color:var(--text-dark);padding-bottom:16px;border-bottom:2px solid var(--cream-warm);margin-bottom:22px;display:flex;align-items:center;gap:10px}

/* FORM ELEMENTS (kept from original) */
.field label{display:block;font-size:.72rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--text-muted);margin-bottom:7px}
.field input,.field textarea,.field select{width:100%;padding:12px 15px;border:1px solid var(--border);border-radius:11px;font-size:.92rem;font-family:var(--font);color:var(--text-dark);background:var(--cream);transition:all .15s}
.field input::placeholder,.field textarea::placeholder{color:#b5a99a}
.field input:focus,.field textarea:focus,.field select:focus{outline:none;border-color:var(--orange);box-shadow:0 0 0 3px rgba(234,88,12,.12);background:var(--white)}
.step-dot{display:flex;align-items:center;gap:8px;padding:9px 14px;border-radius:12px;font-size:.82rem;font-weight:700;white-space:nowrap;transition:all .2s;background:#f1f5f9;color:#94a3b8}
.step-dot.active{background:var(--orange);color:#fff}
.step-dot.done{background:#dcfce7;color:#15803d}
.step-num{display:flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:7px;font-size:.7rem;background:rgba(255,255,255,.25)}
.step-dot.active .step-num{background:rgba(255,255,255,.28)}
.step-dot:not(.active):not(.done) .step-num{background:#e2e8f0}
.otp-box{width:46px;height:52px;text-align:center;font-size:1.2rem;font-weight:800;border:2px solid var(--border);border-radius:12px;color:var(--text-dark);background:var(--cream);font-family:var(--font)}
.otp-box:focus{outline:none;border-color:var(--orange);box-shadow:0 0 0 3px rgba(234,88,12,.12);background:var(--white)}
.day-chip input{display:none}
.day-chip{display:block}
.day-chip span{display:block;padding:8px 4px;border-radius:100px;border:1px solid var(--border);font-size:.82rem;font-weight:600;color:var(--text-body);cursor:pointer;transition:all .15s;text-align:center;white-space:nowrap}
.day-chip input:checked + span{background:var(--orange);color:#fff;border-color:var(--orange)}
.capability-chip{border:1px solid var(--border);border-radius:14px;background:#fff;transition:all .15s}
.capability-chip:hover{border-color:var(--accent-light)}
.capability-chip input:checked ~ span,.capability-chip:has(input:checked){border-color:var(--orange);background:rgba(234,88,12,.04)}
.vtimepicker-wrap{position:relative;user-select:none}
.vtimepicker-btn{width:100%;display:flex;align-items:center;gap:8px;padding:12px 15px;border:1px solid var(--border);border-radius:11px;font-size:.92rem;font-family:var(--font);color:var(--text-dark);background:var(--cream);cursor:pointer;transition:all .15s;text-align:left}
.vtimepicker-btn:hover,.vtimepicker-wrap.open .vtimepicker-btn{border-color:var(--orange);box-shadow:0 0 0 3px rgba(234,88,12,.12)}
.vtimepicker-icon{font-size:18px;color:var(--orange)}
.vtimepicker-display{flex:1;font-weight:600;font-size:1rem;letter-spacing:.04em}
.vtimepicker-caret{font-size:18px;color:#94a3b8;transition:transform .2s}
.vtimepicker-wrap.open .vtimepicker-caret{transform:rotate(180deg)}
.vtimepicker-popup{display:none;position:absolute;top:calc(100% + 6px);left:0;right:0;background:#fff;border:1px solid #e2e8f0;border-radius:14px;box-shadow:0 8px 30px rgba(0,0,0,.12);z-index:999;padding:12px 8px;flex-direction:row;gap:4px;align-items:flex-start}
.vtimepicker-wrap.open .vtimepicker-popup{display:flex}
.vtimepicker-col{flex:1;display:flex;flex-direction:column;gap:2px;max-height:220px;overflow-y:auto;scrollbar-width:thin;scrollbar-color:#fdba74 #fff7ed}
.vtimepicker-col::-webkit-scrollbar{width:4px}
.vtimepicker-col::-webkit-scrollbar-thumb{background:#fdba74;border-radius:4px}
.vtimepicker-col button{width:100%;padding:7px 4px;border:none;background:transparent;border-radius:8px;font-size:.88rem;font-family:var(--font);cursor:pointer;color:#475569;transition:all .12s;text-align:center}
.vtimepicker-col button:hover{background:#fff7ed;color:var(--orange)}
.vtimepicker-col button.active{background:var(--orange);color:#fff;font-weight:700}
.vtimepicker-sep{font-size:1.4rem;font-weight:700;color:#94a3b8;padding:6px 2px;align-self:flex-start;margin-top:4px}
.alert{border-radius:14px;padding:14px 16px;display:flex;align-items:center;gap:10px;font-size:.88rem;font-weight:600}
.alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534}
.alert-error{background:#fef2f2;border:1px solid #fecaca;color:#b91c1c}
#stepIndicators::-webkit-scrollbar{display:none}
#stepIndicators{-ms-overflow-style:none;scrollbar-width:none}

/* PROCESS */
.process-section{background:var(--cream-warm)}
.process-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:18px}
@media(max-width:900px){.process-grid{grid-template-columns:1fr 1fr}}
@media(max-width:560px){.process-grid{grid-template-columns:1fr}}
.process-card{background:var(--white);border:1px solid var(--border);border-radius:18px;padding:24px;transition:var(--transition)}
.process-card:hover{border-color:var(--accent);transform:translateY(-2px)}
.process-card .num{font-size:1.8rem;font-weight:900;color:var(--orange);line-height:1}
.process-card h3{font-size:0.95rem;font-weight:700;margin:12px 0 6px;color:var(--text-dark)}
.process-card p{font-size:0.84rem;color:var(--text-muted)}

/* QUOTE */
.quote-band{background:linear-gradient(135deg,var(--orange),var(--orange-light));border-radius:28px;padding:clamp(36px,6vw,60px);margin-inline:clamp(16px,3vw,48px);color:#fff}
.quote-band q{font-size:clamp(1.2rem,2.4vw,1.7rem);font-weight:600;line-height:1.35;quotes:none;display:block}
.quote-band .who{margin-top:20px;font-size:0.85rem;opacity:.85;font-weight:600}

/* MARQUEE */
.marquee-wrap{overflow:hidden;padding:32px 0;background:var(--cream);border-top:1px solid var(--border);border-bottom:1px solid var(--border)}
.mrow{display:flex;white-space:nowrap;width:max-content;animation:scroll-left 30s linear infinite}
.mrow span{font-size:1.1rem;font-weight:700;padding:0 22px;color:var(--text-muted);display:inline-flex;align-items:center;gap:22px}
.mrow span::after{content:"🏆"}
@keyframes scroll-left{from{transform:translateX(0)}to{transform:translateX(-50%)}}

/* FOOTER */
.footer-vs{background:var(--text-dark);color:rgba(255,255,255,0.7);padding:clamp(40px,6vw,60px) 0 28px}
.footer-top{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:32px;padding-bottom:32px}
@media(max-width:760px){.footer-top{grid-template-columns:1fr 1fr}}
.footer-brand-title{font-size:1.8rem;font-weight:900;color:var(--white);margin-bottom:6px}
.footer-brand-title span{color:var(--accent)}
.footer-brand-slogan{font-size:0.88rem;color:rgba(255,255,255,0.4);margin-top:6px;max-width:28ch;line-height:1.6}
.footer-col h4{font-size:0.72rem;letter-spacing:.1em;text-transform:uppercase;color:rgba(255,255,255,0.35);font-weight:700;margin-bottom:14px}
.footer-col a{display:block;padding:5px 0;font-size:0.88rem;color:rgba(255,255,255,0.55);transition:color .2s}
.footer-col a:hover{color:var(--accent)}
.footer-bottom{display:flex;justify-content:space-between;flex-wrap:wrap;gap:12px;padding-top:24px;border-top:1px solid rgba(255,255,255,0.08);font-size:0.8rem;color:rgba(255,255,255,0.3)}
</style>
</head>
<body>

<!-- PARALLAX SPORTS (decorative) -->
<div class="parallax-sport" style="top:18%;left:3%" data-speed="0.3">⚽</div>
<div class="parallax-sport" style="top:42%;right:2%" data-speed="0.5">🏸</div>
<div class="parallax-sport" style="top:68%;left:6%" data-speed="0.2">🎾</div>
<div class="parallax-sport" style="top:82%;right:4%" data-speed="0.4">🏓</div>

<!-- ================================================================ NAVBAR ================================================================ -->
<nav class="navbar" id="navbar">
  <div class="container">
    <a href="${pageContext.request.contextPath}/" class="navbar-brand">
      <div class="navbar-logo">
        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/></svg>
      </div>
      <span class="navbar-name">V-SPORT<span>.</span></span>
    </a>
    <div class="nav-links" id="navLinks">
      <a href="#story">Về V-SPORT</a>
      <a href="#sports">Quản lý</a>
      <a href="#process">Quy trình</a>
      <a href="${pageContext.request.contextPath}/index.jsp">Đăng nhập</a>
      <a href="#begin" class="nav-cta">Đăng ký ngay</a>
    </div>
    <button class="nav-toggle" id="navToggle" aria-label="Menu">
      <span></span><span></span><span></span>
    </button>
  </div>
</nav>

<!-- ================================================================ HERO ================================================================ -->
<section class="hero section" id="hero">
  <div class="container">
    <div class="hero-content">
      <div class="hero-badge">
        <svg viewBox="0 0 24 24"><path d="M12 2L9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2z"/></svg>
        Nền Tảng Quản Lý Thể Thao #1 Việt Nam
      </div>
      <h1>
        Sân Thể Thao<br>
        Vận Hành<br>
        <span class="highlight">Thông Minh Hơn</span>
      </h1>
      <p class="hero-slogan">"Tối Ưu Vận Hành — Tăng Doanh Thu Bền Vững"</p>
      <div class="hero-actions">
        <a href="#begin" class="btn btn-primary">
          <i class="fa-solid fa-rocket"></i>
          Đăng Ký Miễn Phí
        </a>
        <a href="#sports" class="btn btn-secondary">Xem Giải Pháp</a>
      </div>
    </div>
    <div class="hero-visual">
      <div class="hero-3d-container">
        <div class="hero-3d-bg"></div>
        <img src="${pageContext.request.contextPath}/assets/images/owner/owner-hero-vsport.webp"
             alt="Cơ sở thể thao được quản lý bởi V-SPORT"
             class="hero-product-img"
             onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div style="display:none;width:82%;aspect-ratio:4/3;border-radius:22px;background:linear-gradient(135deg,var(--cream-warm),rgba(251,146,60,0.3));flex-direction:column;align-items:center;justify-content:center;gap:12px;position:relative;z-index:2;">
          <span style="font-size:4rem">🏟️</span>
          <span style="font-weight:800;color:var(--orange);font-size:1rem">V-SPORT</span>
        </div>
        <span class="floating-sport sport-1">⚽</span>
        <span class="floating-sport sport-2">🏸</span>
        <span class="floating-sport sport-3">🎾</span>
        <span class="floating-sport sport-4">🏓</span>
      </div>
    </div>
  </div>
</section>

<!-- ================================================================ STATS BAR ================================================================ -->
<div class="stats-bar">
  <div class="container">
    <div class="stats-grid">
      <div class="stat-item reveal reveal-delay-1">
        <div class="stat-number">500+</div>
        <div class="stat-label">Cơ sở tin dùng</div>
      </div>
      <div class="stat-item reveal reveal-delay-2">
        <div class="stat-number">10k+</div>
        <div class="stat-label">Người chơi mỗi ngày</div>
      </div>
      <div class="stat-item reveal reveal-delay-3">
        <div class="stat-number">99%</div>
        <div class="stat-label">Chủ cơ sở hài lòng</div>
      </div>
      <div class="stat-item reveal reveal-delay-4">
        <div class="stat-number">24/7</div>
        <div class="stat-label">Hỗ trợ kỹ thuật</div>
      </div>
    </div>
  </div>
</div>

<!-- ================================================================ STORY / ABOUT ================================================================ -->
<section class="story section" id="story">
  <div class="container">
    <div class="story-visual reveal">
      <div class="story-image-wrapper">
        <img src="${pageContext.request.contextPath}/assets/images/owner/owner-hero-vsport.webp"
             alt="V-SPORT nền tảng quản lý thể thao"
             class="story-img"
             onerror="this.style.fontSize='5rem';this.style.textAlign='center';this.outerHTML='<div style=\'font-size:5rem;text-align:center\'>🏟️</div>'">
      </div>
      <div class="story-stat">
        <div class="story-stat-number">25%</div>
        <div class="story-stat-label">Tăng doanh thu<br>trung bình</div>
      </div>
    </div>

    <div class="story-content reveal reveal-delay-2">
      <span class="section-label">Câu Chuyện Của Chúng Tôi</span>
      <h2 class="section-title">Sứ Mệnh Của V-SPORT</h2>
      <p style="color:var(--text-body);line-height:1.8;margin-bottom:16px">
        V-SPORT ra đời từ trăn trở thực tế: các chủ cơ sở thể thao tại Việt Nam vẫn đang quản lý sân bằng sổ tay, Excel và tin nhắn thủ công — vừa dễ sai sót, vừa mất doanh thu vào những khung giờ trống không ai biết.
      </p>
      <p style="color:var(--text-body);line-height:1.8">
        Chúng tôi xây dựng một nền tảng duy nhất tích hợp đặt lịch trực tuyến, quản lý hội viên, báo cáo doanh thu và vận hành nhân sự — giúp bạn tập trung vào thể thao, không phải giấy tờ.
      </p>
      <div class="story-highlights">
        <div class="story-highlight-item">
          <div class="story-highlight-icon">🏟️</div>
          <div class="story-highlight-text">Quản lý đa<br>loại sân</div>
        </div>
        <div class="story-highlight-item">
          <div class="story-highlight-icon">📊</div>
          <div class="story-highlight-text">Báo cáo<br>thời gian thực</div>
        </div>
        <div class="story-highlight-item">
          <div class="story-highlight-icon">📱</div>
          <div class="story-highlight-text">Khách đặt<br>qua app</div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ================================================================ VALUES / FEATURES ================================================================ -->
<section class="values section" id="features">
  <div class="container">
    <div class="values-header reveal">
      <span class="section-label">Giá Trị Cốt Lõi</span>
      <h2 class="section-title">Ba Giải Pháp Vận Hành Vượt Trội</h2>
      <p class="section-subtitle">
        Hệ thống tích hợp đầy đủ công cụ giúp bạn quản lý cơ sở thể thao chuyên nghiệp và hiệu quả.
      </p>
    </div>
    <div class="values-grid">
      <div class="value-card reveal reveal-delay-1">
        <div class="value-icon">📅</div>
        <h3>Đặt Lịch Thông Minh</h3>
        <p>Giao diện đặt lịch trực quan, tránh trùng lịch tức thì. Khách tự đặt sân trực tuyến 24/7 — không cần gọi điện.</p>
      </div>
      <div class="value-card reveal reveal-delay-2">
        <div class="value-icon">👥</div>
        <h3>Quản Lý Hội Viên</h3>
        <p>Theo dõi gói tập, lịch sử đặt sân và điểm thưởng. Điểm danh tự động thông qua mã QR Code tiện lợi.</p>
      </div>
      <div class="value-card reveal reveal-delay-3">
        <div class="value-icon">📈</div>
        <h3>Báo Cáo Doanh Thu</h3>
        <p>Dashboard thời gian thực, biểu đồ doanh thu theo giờ/ngày/tháng. Nhận diện khung giờ vàng để tối ưu giá.</p>
      </div>
    </div>
  </div>
</section>

<!-- ================================================================ SPORTS SHOWCASE ================================================================ -->
<section class="sports-section section" id="sports">
  <div class="container">
    <div class="reveal" style="max-width:640px;margin-bottom:48px">
      <span class="section-label">Quản Lý</span>
      <h2 class="section-title">Môn Thể Thao Được Hỗ Trợ</h2>
      <p class="section-subtitle">V-SPORT hỗ trợ quản lý đa dạng loại hình thể thao — từ sân bóng đến gym, bể bơi đến yoga.</p>
    </div>
    <div class="shop-grid">
      <div class="shop-card reveal reveal-delay-1">
        <div class="shop-card-media">⚽</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Bóng Đá</div>
          <div class="shop-card-desc">Sân 5, 7, 11 người — đặt lịch theo ca, theo nhóm</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-2">
        <div class="shop-card-media">🏸</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Cầu Lông</div>
          <div class="shop-card-desc">Quản lý nhiều sân, bán vé giờ và theo tháng</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-3">
        <div class="shop-card-media">🎾</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Tennis</div>
          <div class="shop-card-desc">Lịch HLV, gói thuê sân và dịch vụ căng vợt</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-4">
        <div class="shop-card-media">🏐</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Bóng Chuyền</div>
          <div class="shop-card-desc">Đặt sân cho nhóm, giải đấu nội bộ và câu lạc bộ</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-1">
        <div class="shop-card-media">🏀</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Bóng Rổ</div>
          <div class="shop-card-desc">Phân sân theo khu vực, quản lý hội viên câu lạc bộ</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-2">
        <div class="shop-card-media">🏓</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Bóng Bàn</div>
          <div class="shop-card-desc">Đặt theo giờ, cho thuê bàn và vợt linh hoạt</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-3">
        <div class="shop-card-media">💪</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Gym &amp; Fitness</div>
          <div class="shop-card-desc">Gói tập theo tháng, check-in QR, lịch PT cá nhân</div>
        </div>
      </div>
      <div class="shop-card reveal reveal-delay-4">
        <div class="shop-card-media">🏊</div>
        <div class="shop-card-body">
          <div class="shop-card-name">Bơi Lội</div>
          <div class="shop-card-desc">Vé bơi theo lượt, đăng ký khóa học và lịch HLV</div>
        </div>
      </div>
    </div>
    <div class="reveal" style="text-align:center;margin-top:36px">
      <a href="#begin" class="btn btn-secondary">
        <i class="fa-solid fa-plus"></i>
        Đăng ký môn thể thao của bạn
      </a>
    </div>
  </div>
</section>

<!-- ================================================================ PROCESS ================================================================ -->
<section class="process-section section" id="process">
  <div class="container">
    <div class="reveal" style="max-width:640px;margin-bottom:48px">
      <span class="section-label">Quy Trình</span>
      <h2 class="section-title">Bốn Bước Đơn Giản — Hệ Thống Sẵn Sàng</h2>
    </div>
    <div class="process-grid">
      <div class="process-card reveal reveal-delay-1">
        <div class="num">01</div>
        <h3>Đăng ký thông tin</h3>
        <p>Điền thông tin cơ bản về cơ sở của bạn chỉ trong 1 phút để khởi tạo tài khoản quản lý.</p>
      </div>
      <div class="process-card reveal reveal-delay-2">
        <div class="num">02</div>
        <h3>Xác thực Email</h3>
        <p>Nhập mã OTP gửi tới email để xác minh danh tính và bảo mật tài khoản.</p>
      </div>
      <div class="process-card reveal reveal-delay-3">
        <div class="num">03</div>
        <h3>Cấu hình cơ sở</h3>
        <p>Khai báo môn thể thao, số sân và khung giờ mở cửa — đội V-SPORT hỗ trợ 24/7.</p>
      </div>
      <div class="process-card reveal reveal-delay-4">
        <div class="num">04</div>
        <h3>Vận hành ngay</h3>
        <p>Sân của bạn hiển thị trên hệ sinh thái V-SPORT và đón nhận lịch đặt đầu tiên.</p>
      </div>
    </div>
  </div>
</section>

<!-- ================================================================ MARQUEE ================================================================ -->
<div class="marquee-wrap" aria-hidden="true">
  <div class="mrow">
    <span>Bóng đá</span><span>Cầu lông</span><span>Tennis</span><span>Bóng rổ</span><span>Bóng chuyền</span><span>Pickleball</span><span>Bơi lội</span><span>Gym</span>
    <span>Bóng đá</span><span>Cầu lông</span><span>Tennis</span><span>Bóng rổ</span><span>Bóng chuyền</span><span>Pickleball</span><span>Bơi lội</span><span>Gym</span>
  </div>
</div>

<!-- ================================================================ QUOTE ================================================================ -->
<section class="section" style="padding-top:60px;padding-bottom:60px">
  <div class="quote-band">
    <q>Từ khi dùng V-SPORT, tôi không còn bị đau đầu vì trùng lịch đặt sân của khách nữa. Doanh thu tăng hơn 25% nhờ tối ưu các khung giờ trống.</q>
    <p class="who">— Anh Minh Tuấn · Chủ sân bóng Tân Bình, TP.HCM</p>
  </div>
</section>

<!-- ================================================================ REGISTRATION ================================================================ -->
<section class="checkout section" id="begin">
  <div class="container">
    <div class="checkout-info reveal">
      <span class="section-label">Đăng Ký Cơ Sở</span>
      <h2 class="section-title">Đăng Ký Ngay Hôm Nay</h2>
      <p class="section-subtitle">
        Điền thông tin bên cạnh — đội ngũ V-SPORT sẽ liên hệ trong vòng 24 giờ để hỗ trợ cấu hình hệ thống.
      </p>
      <div class="checkout-features">
        <div class="checkout-feature">
          <div class="checkout-feature-icon">🚀</div>
          <div class="checkout-feature-text">
            <h4>Thiết lập trong 5 phút</h4>
            <p>Đăng ký đơn giản, không cần kỹ thuật</p>
          </div>
        </div>
        <div class="checkout-feature">
          <div class="checkout-feature-icon">🆓</div>
          <div class="checkout-feature-text">
            <h4>Dùng thử 30 ngày miễn phí</h4>
            <p>Không ràng buộc, không cần thẻ tín dụng</p>
          </div>
        </div>
        <div class="checkout-feature">
          <div class="checkout-feature-icon">🛡️</div>
          <div class="checkout-feature-text">
            <h4>Bảo mật dữ liệu chuẩn</h4>
            <p>Mã hóa đầu cuối, backup tự động hàng ngày</p>
          </div>
        </div>
        <div class="checkout-feature">
          <div class="checkout-feature-icon">📞</div>
          <div class="checkout-feature-text">
            <h4>Hỗ trợ 24/7 miễn phí</h4>
            <p>Đội ngũ kỹ thuật luôn sẵn sàng hỗ trợ bạn</p>
          </div>
        </div>
      </div>
    </div>

    <div class="order-form-wrapper reveal reveal-delay-2">
      <div class="order-form-title">
        <span style="font-size:1.2rem">📋</span> Thông Tin Đăng Ký Cơ Sở
      </div>

      <!-- Success Alert -->
      <div id="successAlert" class="hidden mb-5 alert alert-success">
        <span class="material-symbols-outlined">check_circle</span>
        <span>Đăng ký thành công! Chúng tôi sẽ sớm liên hệ với bạn.</span>
      </div>
      <!-- Error Alert -->
      <div id="errorAlert" class="hidden mb-5 alert alert-error">
        <span class="material-symbols-outlined">error</span>
        <span id="errorMessage"></span>
      </div>

      <!-- Step Indicators -->
      <div class="flex items-center justify-between gap-2 mb-6 overflow-x-auto pb-1" id="stepIndicators">
        <div class="step-dot active" data-step="1">
          <span class="step-num">1</span> <span class="hidden sm:inline">Thông tin</span>
        </div>
        <div class="flex-grow h-px bg-slate-200 min-w-[8px] max-w-[28px]"></div>
        <div class="step-dot" data-step="2">
          <span class="step-num">2</span> <span class="hidden sm:inline">Xác thực OTP</span>
        </div>
        <div class="flex-grow h-px bg-slate-200 min-w-[8px] max-w-[28px]"></div>
        <div class="step-dot" data-step="3">
          <span class="step-num">3</span> <span class="hidden sm:inline">Cơ sở &amp; Sân</span>
        </div>
      </div>

      <!-- Xóa bản nháp -->
      <div class="flex justify-end -mt-3 mb-3">
        <button type="button" onclick="confirmResetOwnerDraft()" class="text-slate-400 hover:text-slate-600 text-xs underline underline-offset-2 bg-transparent border-none cursor-pointer transition-colors">Xóa bản nháp / Bắt đầu lại</button>
      </div>

      <!-- ====== STEP 1 ====== -->
      <div id="formStep1" class="form-step">
        <h3 class="text-lg font-extrabold mb-5 text-slate-900">Thông tin cơ bản</h3>
        <div class="flex flex-col gap-4">
          <div class="field">
            <label for="ownerName">Tên cơ sở <span class="text-[#ea580c]">*</span></label>
            <input type="text" id="ownerName" name="ownerName" required placeholder="VD: Sân bóng Tân Bình" />
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div class="field">
              <label for="regEmail">Email liên hệ <span class="text-[#ea580c]">*</span></label>
              <input type="email" id="regEmail" required placeholder="email@example.com" />
            </div>
            <div class="field">
              <label for="regPhone">Số điện thoại <span class="text-[#ea580c]">*</span></label>
              <input type="tel" id="regPhone" required placeholder="0912 345 678" />
            </div>
          </div>
          <div class="field">
            <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-1.5 sm:gap-4 mb-1">
              <label for="regAddress" class="!mb-0">Địa chỉ cơ sở</label>
              <button type="button" onclick="autoFillAddress()" class="text-xs text-[#ea580c] hover:underline flex items-center gap-1 bg-transparent border-none cursor-pointer focus:outline-none font-semibold">
                <span class="material-symbols-outlined text-[14px]">my_location</span> Lấy vị trí / Tọa độ GG Map
              </button>
            </div>
            <input type="text" id="regAddress" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành" />
            <div id="coordPreview" class="hidden mt-1.5 flex flex-col gap-0.5">
              <div class="flex items-start gap-1.5">
                <span class="material-symbols-outlined mt-px text-[14px] text-[#ea580c]">location_on</span>
                <span id="coordPreviewText" class="text-xs leading-snug text-[#ea580c]"></span>
              </div>
              <a id="coordMapsLink" href="#" target="_blank" rel="noopener noreferrer" class="hidden text-xs underline pl-5 text-[#ea580c]">Mở Google Maps để kiểm tra vị trí</a>
            </div>
          </div>
          <button type="button" onclick="goToStep2()" class="btn btn-primary w-full justify-center py-3.5 text-base mt-1">
            Tiếp tục — Xác thực Email <span class="material-symbols-outlined align-middle text-lg">arrow_forward</span>
          </button>
        </div>
      </div>

      <!-- ====== STEP 2: OTP ====== -->
      <div id="formStep2" class="form-step hidden">
        <h3 class="text-lg font-extrabold mb-2 text-slate-900">Xác thực Email</h3>
        <p class="text-slate-500 text-sm mb-5">Chúng tôi đã gửi mã OTP đến <strong id="otpEmailDisplay" class="text-[#ea580c]"></strong>. Vui lòng nhập mã bên dưới.</p>
        <p id="otpValidityHint" class="hidden text-slate-400 text-xs -mt-3 mb-3"></p>
        <div class="flex justify-center gap-2 mb-5" id="otpInputs">
          <input type="text" maxlength="1" class="otp-box" data-index="0" />
          <input type="text" maxlength="1" class="otp-box" data-index="1" />
          <input type="text" maxlength="1" class="otp-box" data-index="2" />
          <input type="text" maxlength="1" class="otp-box" data-index="3" />
          <input type="text" maxlength="1" class="otp-box" data-index="4" />
          <input type="text" maxlength="1" class="otp-box" data-index="5" />
        </div>
        <div id="otpError" class="hidden text-center text-red-600 text-sm mb-4 font-semibold"></div>
        <div class="flex flex-col gap-3">
          <button type="button" onclick="verifyOtp()" id="btnVerifyOtp" class="btn btn-primary w-full justify-center py-3.5 text-base">
            Xác thực OTP
          </button>
          <div class="flex items-center justify-between mt-1">
            <button type="button" onclick="goToStep1()" class="text-slate-500 hover:text-slate-800 transition-colors text-sm flex items-center gap-1 bg-transparent border-none cursor-pointer font-semibold">
              <span class="material-symbols-outlined text-sm">arrow_back</span> Quay lại
            </button>
            <button type="button" onclick="resendOtp()" id="btnResendOtp" class="text-[#ea580c] hover:text-[#c2410c] text-sm transition-colors disabled:opacity-40 bg-transparent border-none cursor-pointer font-semibold" disabled>
              Gửi lại mã<span id="resendCountdownWrap"> (<span id="resendCountdown">60</span>s)</span>
            </button>
          </div>
        </div>
        <p class="text-center text-slate-400 text-xs mt-4">Số lần nhập sai: <span id="otpAttemptCount" class="font-bold text-red-500">0</span>/5</p>
      </div>

      <!-- ====== STEP 3: Sports, Courts, Hours ====== -->
      <div id="formStep3" class="form-step hidden">
        <h3 class="text-lg font-extrabold mb-5 text-slate-900">Cấu hình cơ sở</h3>

        <div class="field mb-5">
          <label>Môn thể thao / Dịch vụ <span class="text-[#ea580c]">*</span></label>
          <button type="button" onclick="openSportsPopup()" class="w-full px-4 py-3 border border-slate-200 rounded-xl bg-white text-left flex items-center justify-between hover:border-[#ea580c]/50 transition-all cursor-pointer">
            <span id="sportsPreviewText" class="text-slate-400">Chọn các môn thể thao...</span>
            <span class="material-symbols-outlined text-[#ea580c]">add_circle</span>
          </button>
        </div>

        <div id="courtQuantitySection" class="hidden mb-5">
          <label class="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Số lượng sân từng môn</label>
          <div id="courtQuantityList" class="flex flex-col gap-3"></div>
        </div>

        <input type="hidden" id="openTime"  value="06:00">
        <input type="hidden" id="closeTime" value="22:00">
        <input type="hidden" id="viDo"   name="viDo">
        <input type="hidden" id="kinhDo" name="kinhDo">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-5">
          <div class="field">
            <label>Giờ mở cửa <span class="text-[#ea580c]">*</span></label>
            <div class="vtimepicker-wrap" id="openTimePicker" data-target="openTime" data-default="06:00">
              <button type="button" class="vtimepicker-btn" onclick="vtpToggle('openTimePicker')">
                <span class="material-symbols-outlined vtimepicker-icon">schedule</span>
                <span class="vtimepicker-display" id="openTimePicker-display">06:00</span>
                <span class="material-symbols-outlined vtimepicker-caret">expand_more</span>
              </button>
              <div class="vtimepicker-popup" id="openTimePicker-popup">
                <div class="vtimepicker-col" id="openTimePicker-hours"></div>
                <div class="vtimepicker-sep">:</div>
                <div class="vtimepicker-col" id="openTimePicker-minutes"></div>
              </div>
            </div>
          </div>
          <div class="field">
            <label>Giờ đóng cửa <span class="text-[#ea580c]">*</span></label>
            <div class="vtimepicker-wrap" id="closeTimePicker" data-target="closeTime" data-default="22:00">
              <button type="button" class="vtimepicker-btn" onclick="vtpToggle('closeTimePicker')">
                <span class="material-symbols-outlined vtimepicker-icon">schedule</span>
                <span class="vtimepicker-display" id="closeTimePicker-display">22:00</span>
                <span class="material-symbols-outlined vtimepicker-caret">expand_more</span>
              </button>
              <div class="vtimepicker-popup" id="closeTimePicker-popup">
                <div class="vtimepicker-col" id="closeTimePicker-hours"></div>
                <div class="vtimepicker-sep">:</div>
                <div class="vtimepicker-col" id="closeTimePicker-minutes"></div>
              </div>
            </div>
          </div>
        </div>

        <div class="mb-5">
          <label class="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Ngày hoạt động <span class="text-[#ea580c]">*</span></label>
          <div class="grid grid-cols-7 gap-2" id="operatingDays">
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T2" checked/><span>Thứ 2</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T3" checked/><span>Thứ 3</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T4" checked/><span>Thứ 4</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T5" checked/><span>Thứ 5</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T6" checked/><span>Thứ 6</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="T7" checked/><span>Thứ 7</span></label>
            <label class="day-chip cursor-pointer"><input type="checkbox" value="CN" checked/><span>CN</span></label>
          </div>
        </div>

        <div class="field mb-5">
          <label for="regDescription">Mô tả thêm về cơ sở</label>
          <textarea id="regDescription" rows="3" placeholder="Dịch vụ đi kèm, tiện ích, lưu ý đặc biệt..." class="resize-vertical"></textarea>
        </div>


        <div class="flex gap-3">
          <button type="button" onclick="goToStep2Back()" class="btn-outline flex-shrink-0 py-3.5">
            <span class="material-symbols-outlined text-sm">arrow_back</span> Quay lại
          </button>
          <button type="button" onclick="submitFullForm()" class="btn btn-primary flex-1 justify-center py-3.5 text-base">
            🚀 Gửi đăng ký
          </button>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- ================================================================ FOOTER ================================================================ -->
<footer class="footer-vs">
  <div class="container">
    <div class="footer-top">
      <div>
        <div class="footer-brand-title">V-SPORT<span>.</span></div>
        <div class="footer-brand-slogan">Nâng tầm vận hành cơ sở thể thao Việt Nam.</div>
        <div style="display:flex;gap:12px;margin-top:20px">
          <a href="#" style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,0.1);display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,0.6);font-size:0.9rem;transition:var(--transition)" class="social-link">
            <i class="fab fa-facebook-f"></i>
          </a>
          <a href="#" style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,0.1);display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,0.6);font-size:0.9rem;transition:var(--transition)">
            <i class="fab fa-instagram"></i>
          </a>
          <a href="#" style="width:36px;height:36px;border-radius:50%;background:rgba(255,255,255,0.1);display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,0.6);font-size:0.9rem;transition:var(--transition)">
            <i class="fab fa-tiktok"></i>
          </a>
        </div>
      </div>
      <div class="footer-col">
        <h4>Tính năng</h4>
        <a href="#features">Đặt lịch thông minh</a>
        <a href="#features">Quản lý hội viên</a>
        <a href="#features">Báo cáo doanh thu</a>
      </div>
      <div class="footer-col">
        <h4>Thông tin</h4>
        <a href="#story">Về V-SPORT</a>
        <a href="#process">Quy trình</a>
        <a href="#sports">Môn thể thao</a>
      </div>
      <div class="footer-col">
        <h4>Liên kết</h4>
        <a href="#begin">Đăng ký đối tác</a>
        <a href="${pageContext.request.contextPath}/index.jsp">Đăng nhập</a>
      </div>
    </div>
    <div class="footer-bottom">
      <span>© 2026 V-Sport. Tất cả quyền được bảo lưu.</span>
      <span>Premium Sports Management Platform.</span>
    </div>
  </div>
</footer>

<!-- ====== SPORTS POPUP MODAL ====== -->
<div id="sportsPopup" class="fixed inset-0 z-[100] hidden">
  <div class="absolute inset-0 bg-slate-900/50 backdrop-blur-sm" onclick="closeSportsPopup()"></div>
  <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-white border border-slate-200 rounded-3xl w-[95vw] max-w-lg max-h-[80vh] overflow-hidden shadow-2xl flex flex-col text-slate-900">
    <div class="p-6 border-b border-slate-100 flex items-center justify-between">
      <h3 class="text-xl font-extrabold">Chọn môn thể thao</h3>
      <button onclick="closeSportsPopup()" class="w-10 h-10 rounded-full hover:bg-slate-100 flex items-center justify-center transition-all bg-transparent border-none text-slate-500 cursor-pointer">
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
    <div class="p-6 overflow-y-auto flex-1">
      <div class="grid grid-cols-2 gap-3" id="sportsGrid"></div>
    </div>
    <div class="p-6 border-t border-slate-100 flex justify-between items-center">
      <span class="text-sm text-slate-500">Đã chọn: <strong id="selectedSportsCount" class="text-[#ea580c]">0</strong> môn</span>
      <button onclick="confirmSportsSelection()" class="btn btn-primary px-8 py-3">Xác nhận</button>
    </div>
  </div>
</div>

<!-- Custom Geolocation Modal -->
<div id="geoModal" class="hidden fixed inset-0 z-[8000] flex items-end sm:items-center justify-center bg-slate-900/60 backdrop-blur-sm p-0 sm:p-4">
  <style>
    @keyframes geoFadeIn  { from { opacity: 0; } to { opacity: 1; } }
    @keyframes geoSlideUp { from { transform: translateY(40px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    #geoModal:not(.hidden) { animation: geoFadeIn 180ms ease-out forwards; }
    #geoModalBox { animation: geoSlideUp 260ms cubic-bezier(.16,1,.3,1) forwards; }
    #geoMapEl { height: 340px; border-radius: 12px; overflow: hidden; z-index: 0; }
    @media (min-height: 700px) { #geoMapEl { height: 400px; } }
    .geo-search-wrap { position: relative; }
    .geo-search-results { position: absolute; top: calc(100% + 4px); left: 0; right: 0; background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,.12); z-index: 9999; max-height: 200px; overflow-y: auto; }
    .geo-search-item { padding: 10px 14px; font-size: 13px; cursor: pointer; color: #1e293b; border-bottom: 1px solid #f1f5f9; transition: background 120ms; }
    .geo-search-item:last-child { border-bottom: none; }
    .geo-search-item:hover { background: #f8fafc; }
    .geo-coord-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; background: #ea580c14; border: 1px solid #ea580c30; border-radius: 999px; font-size: 12px; font-weight: 700; color: #9a3412; }
  </style>
  <div id="geoModalBox" class="bg-white w-full sm:max-w-2xl rounded-t-3xl sm:rounded-3xl shadow-2xl flex flex-col" style="max-height:92vh;">
    <div class="flex items-center justify-between px-5 pt-5 pb-3 flex-shrink-0">
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-[#ea580c] text-2xl">location_on</span>
        <h3 class="text-lg font-extrabold text-slate-900">Chọn vị trí cơ sở</h3>
      </div>
      <button type="button" onclick="closeGeoModal()" class="text-slate-400 hover:text-slate-700 transition-all bg-transparent border-none cursor-pointer p-1">
        <span class="material-symbols-outlined text-2xl">close</span>
      </button>
    </div>
    <div class="px-5 pb-3 flex-shrink-0">
      <div class="geo-search-wrap">
        <input type="text" id="geoSearchInput" placeholder="Tìm địa chỉ hoặc tên cơ sở..."
          class="w-full px-4 py-2.5 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-[#ea580c] transition-colors" autocomplete="off"/>
        <div id="geoSearchResults" class="geo-search-results hidden"></div>
      </div>
      <p class="text-xs text-slate-400 mt-2">Bấm vào bản đồ hoặc kéo điểm ghim để chọn vị trí chính xác.</p>
    </div>
    <div class="px-5 flex-shrink-0">
      <div id="geoMapEl"></div>
    </div>
    <div class="px-5 py-4 flex-shrink-0">
      <div id="geoCoordPill" class="geo-coord-pill mb-3 hidden">
        <span class="material-symbols-outlined text-[14px]">my_location</span>
        <span id="geoCoordText">—</span>
      </div>
      <div id="geoCoordNone" class="text-xs text-slate-400 mb-3">Chưa chọn vị trí — bấm vào bản đồ để ghim điểm.</div>
      <div class="flex gap-2">
        <button type="button" onclick="geoUseGps()" id="geoGpsBtn"
          class="flex-1 flex items-center justify-center gap-1.5 py-2.5 border border-slate-200 rounded-xl text-sm font-semibold text-slate-700 hover:border-[#ea580c] hover:text-[#ea580c] transition-all bg-white">
          <span class="material-symbols-outlined text-base">my_location</span> Vị trí hiện tại
        </button>
        <button type="button" onclick="geoConfirm()" id="geoConfirmBtn" disabled
          class="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl text-sm font-bold text-white transition-all"
          style="background:#ea580c; opacity:.4; cursor:not-allowed;">
          <span class="material-symbols-outlined text-base">check_circle</span> Xác nhận vị trí
        </button>
      </div>
    </div>
  </div>
</div>

<script>
    // ==========================================
    // GLOBAL STATE
    // ==========================================
    let currentStep = 1;
    let serverOtp = ''; // OTP returned from server
    let otpAttempts = 0;
    let resendCount = 0;
    let resendTimer = null;
    let selectedSports = []; // [{name, icon}]
    let emailVerified = false;

    if (typeof window.ownerServerFormHasData === 'undefined') {
        window.ownerServerFormHasData = false;
    }

    const POPULAR_SPORTS = [
        { name: 'Bóng đá', icon: 'sports_soccer' },
        { name: 'Bóng rổ', icon: 'sports_basketball' },
        { name: 'Cầu lông', icon: 'sports_tennis' },
        { name: 'Tennis', icon: 'sports_tennis' },
        { name: 'Bóng chuyền', icon: 'sports_volleyball' },
        { name: 'Bóng bàn', icon: 'sports_cricket' },
        { name: 'Bơi lội', icon: 'pool' },
        { name: 'Gym / Fitness', icon: 'fitness_center' },
        { name: 'Yoga', icon: 'self_improvement' },
        { name: 'Pickleball', icon: 'sports_tennis' },
        { name: 'Đá cầu', icon: 'sports' },
        { name: 'Billiards', icon: 'sports' },
        { name: 'Võ thuật', icon: 'sports_martial_arts' },
        { name: 'Chạy bộ', icon: 'directions_run' },
        { name: 'Đồ uống / Canteen', icon: 'local_cafe' },
        { name: 'Khác', icon: 'more_horiz' }
    ];

    // ==========================================
    // STEP NAVIGATION
    // ==========================================
    function showStep(step) {
        currentStep = step;
        document.getElementById('formStep1').classList.toggle('hidden', step !== 1);
        document.getElementById('formStep2').classList.toggle('hidden', step !== 2);
        document.getElementById('formStep3').classList.toggle('hidden', step !== 3);
        document.querySelectorAll('#stepIndicators .step-dot').forEach(dot => {
            const s = parseInt(dot.dataset.step);
            if (s < step) {
                dot.className = 'step-dot done';
            } else if (s === step) {
                dot.className = 'step-dot active';
            } else {
                dot.className = 'step-dot';
            }
        });
    }

    function showError(msg) {
        const el = document.getElementById('errorAlert');
        document.getElementById('errorMessage').textContent = msg;
        el.classList.remove('hidden');
        el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    function hideError() { document.getElementById('errorAlert').classList.add('hidden'); }

    // ==========================================
    // GEO MAP MODAL
    // ==========================================
    let geoMap = null;
    let geoMarker = null;
    let geoPendingLat = null;
    let geoPendingLng = null;
    let geoSearchTimer = null;

    const GEO_DEFAULT = [10.776530, 106.700981];

    function autoFillAddress() {
        document.getElementById('geoModal').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
        setTimeout(initGeoMap, 80);
    }
    window.autoFillAddress = autoFillAddress;

    function closeGeoModal() {
        document.getElementById('geoModal').classList.add('hidden');
        document.body.style.overflow = '';
        document.getElementById('geoSearchResults').classList.add('hidden');
        document.getElementById('geoSearchInput').value = '';
    }
    window.closeGeoModal = closeGeoModal;

    function initGeoMap() {
        if (geoMap) {
            geoMap.invalidateSize();
            return;
        }
        const savedLat = parseFloat(document.getElementById('viDo').value);
        const savedLng = parseFloat(document.getElementById('kinhDo').value);
        const center = (savedLat && savedLng) ? [savedLat, savedLng] : GEO_DEFAULT;
        const zoom   = (savedLat && savedLng) ? 16 : 6;

        geoMap = L.map('geoMapEl', { zoomControl: true, attributionControl: true });
        geoMap.setView(center, zoom);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a>'
        }).addTo(geoMap);

        if (savedLat && savedLng) {
            geoSetPin(savedLat, savedLng, false);
        }

        geoMap.on('click', function(e) {
            geoSetPin(e.latlng.lat, e.latlng.lng, true);
        });

        const inp = document.getElementById('geoSearchInput');
        inp.addEventListener('input', function() {
            clearTimeout(geoSearchTimer);
            const q = inp.value.trim();
            if (q.length < 3) { document.getElementById('geoSearchResults').classList.add('hidden'); return; }
            geoSearchTimer = setTimeout(function() { geoSearchAddress(q); }, 400);
        });
        inp.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeGeoModal(); });

        document.addEventListener('click', function(e) {
            if (!e.target.closest('.geo-search-wrap')) {
                document.getElementById('geoSearchResults').classList.add('hidden');
            }
        });
    }

    function geoSetPin(lat, lng, reverseGeocode) {
        lat = parseFloat(lat.toFixed(6));
        lng = parseFloat(lng.toFixed(6));
        geoPendingLat = lat;
        geoPendingLng = lng;

        const icon = L.divIcon({
            className: '',
            html: '<div style="width:32px;height:32px;display:flex;align-items:center;justify-content:center;margin-left:-16px;margin-top:-32px"><svg viewBox="0 0 24 24" width="32" height="32" fill="#ea580c" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg></div>',
            iconSize: [32, 32], iconAnchor: [0, 0]
        });

        if (geoMarker) {
            geoMarker.setLatLng([lat, lng]);
        } else {
            geoMarker = L.marker([lat, lng], { icon: icon, draggable: true }).addTo(geoMap);
            geoMarker.on('dragend', function(e) {
                const ll = e.target.getLatLng();
                geoSetPin(ll.lat, ll.lng, true);
            });
        }

        geoMap.panTo([lat, lng]);
        document.getElementById('geoCoordText').textContent = lat + ', ' + lng;
        document.getElementById('geoCoordPill').classList.remove('hidden');
        document.getElementById('geoCoordNone').classList.add('hidden');

        const btn = document.getElementById('geoConfirmBtn');
        btn.disabled = false;
        btn.style.opacity = '1';
        btn.style.cursor = 'pointer';

        if (reverseGeocode) {
            document.getElementById('geoCoordText').textContent = lat + ', ' + lng + ' — đang lấy địa chỉ...';
            fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng + '&accept-language=vi')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    const addr = data && data.display_name ? data.display_name : '';
                    document.getElementById('geoCoordText').textContent = lat + ', ' + lng + (addr ? ' — ' + addr.substring(0, 60) + '…' : '');
                    if (addr) document.getElementById('geoSearchInput').value = addr.substring(0, 80);
                })
                .catch(function() {
                    document.getElementById('geoCoordText').textContent = lat + ', ' + lng;
                });
        }
    }

    function geoSearchAddress(q) {
        fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(q) + '&countrycodes=vn&limit=5&accept-language=vi')
            .then(function(r) { return r.json(); })
            .then(function(results) {
                const box = document.getElementById('geoSearchResults');
                if (!results || !results.length) { box.classList.add('hidden'); return; }
                box.innerHTML = '';
                results.forEach(function(item) {
                    const div = document.createElement('div');
                    div.className = 'geo-search-item';
                    div.textContent = item.display_name;
                    div.addEventListener('click', function() {
                        document.getElementById('geoSearchInput').value = item.display_name;
                        box.classList.add('hidden');
                        geoSetPin(parseFloat(item.lat), parseFloat(item.lon), false);
                        geoMap.setView([parseFloat(item.lat), parseFloat(item.lon)], 17);
                        document.getElementById('geoCoordText').textContent = parseFloat(item.lat).toFixed(6) + ', ' + parseFloat(item.lon).toFixed(6) + ' — ' + item.display_name.substring(0, 60) + '…';
                    });
                    box.appendChild(div);
                });
                box.classList.remove('hidden');
            })
            .catch(function() {});
    }

    function geoUseGps() {
        if (!navigator.geolocation) { alert('Trình duyệt không hỗ trợ lấy vị trí.'); return; }
        const btn = document.getElementById('geoGpsBtn');
        btn.disabled = true;
        btn.innerHTML = '<span style="display:inline-block;width:16px;height:16px;border:2px solid currentColor;border-top-color:transparent;border-radius:50%;animation:spin 0.7s linear infinite;vertical-align:middle;margin-right:4px"></span> Đang định vị...';
        if (!document.getElementById('geoMapEl').querySelector('style')) {
            const s = document.createElement('style'); s.textContent = '@keyframes spin{to{transform:rotate(360deg)}}'; document.head.appendChild(s);
        }
        navigator.geolocation.getCurrentPosition(
            function(pos) {
                btn.disabled = false;
                btn.innerHTML = '<span class="material-symbols-outlined text-base">my_location</span> Vị trí hiện tại';
                geoMap.setView([pos.coords.latitude, pos.coords.longitude], 17);
                geoSetPin(pos.coords.latitude, pos.coords.longitude, true);
            },
            function(err) {
                btn.disabled = false;
                btn.innerHTML = '<span class="material-symbols-outlined text-base">my_location</span> Vị trí hiện tại';
                alert('Không lấy được vị trí: ' + err.message);
            },
            { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
        );
    }
    window.geoUseGps = geoUseGps;

    function geoConfirm() {
        if (geoPendingLat === null) return;
        setLocationCoords(geoPendingLat, geoPendingLng);
        closeGeoModal();
        fetchAddressFromCoords(geoPendingLat, geoPendingLng);
        saveOwnerDraft();
    }
    window.geoConfirm = geoConfirm;

    function setLocationCoords(lat, lng) {
        document.getElementById('viDo').value = lat;
        document.getElementById('kinhDo').value = lng;
        document.getElementById('coordPreviewText').textContent = 'Đã xác nhận vị trí: ' + lat + ', ' + lng;
        const mapsLink = document.getElementById('coordMapsLink');
        mapsLink.href = 'https://www.google.com/maps?q=' + lat + ',' + lng;
        mapsLink.classList.remove('hidden');
        document.getElementById('coordPreview').classList.remove('hidden');
    }

    function fetchAddressFromCoords(lat, lon, callback) {
        const addrInput = document.getElementById('regAddress');
        const originalPlaceholder = addrInput.placeholder;
        const savedAddress = addrInput.value.trim();
        addrInput.disabled = true;
        addrInput.value = "";
        addrInput.placeholder = "Đang lấy địa chỉ từ tọa độ [" + parseFloat(lat).toFixed(4) + ", " + parseFloat(lon).toFixed(4) + "]...";

        fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lon + '&accept-language=vi')
            .then(r => r.json())
            .then(data => {
                addrInput.disabled = false;
                addrInput.placeholder = originalPlaceholder;
                if (data && data.display_name) {
                    addrInput.value = data.display_name;
                } else {
                    addrInput.value = savedAddress;
                }
                if (callback) callback();
            })
            .catch(() => {
                addrInput.disabled = false;
                addrInput.placeholder = originalPlaceholder;
                addrInput.value = savedAddress;
                const hint = document.getElementById('coordPreviewText');
                if (hint) hint.textContent += ' — Không tự lấy được địa chỉ, hãy nhập thủ công.';
                if (callback) callback();
            });
    }

    function goToStep1() { hideError(); showStep(1); saveOwnerDraft(); }

    function goToStep2() {
        hideError();
        const name = document.getElementById('ownerName').value.trim();
        const email = document.getElementById('regEmail').value.trim();
        const phone = document.getElementById('regPhone').value.trim();

        if (!name) { showError('Vui lòng nhập tên cơ sở.'); return; }
        if (!email) { showError('Vui lòng nhập email.'); return; }
        if (!phone) { showError('Vui lòng nhập số điện thoại.'); return; }
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { showError('Email không hợp lệ.'); return; }
        if (!/^(0|\+84)[35789][0-9]{8}$/.test(phone)) { showError('Số điện thoại không hợp lệ.'); return; }

        document.getElementById('otpEmailDisplay').textContent = email;
        sendOtpToServer(email);
    }

    function sendOtpToServer(email) {
        const phone = document.getElementById('regPhone').value.trim();
        const btn = document.querySelector('#formStep1 button');
        btn.disabled = true;
        btn.innerHTML = '<span class="animate-spin inline-block w-5 h-5 border-2 border-current border-t-transparent rounded-full mr-2"></span> Đang gửi OTP...';

        fetch('${pageContext.request.contextPath}/owner/send-otp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'email=' + encodeURIComponent(email) + '&phone=' + encodeURIComponent(phone)
        })
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            btn.innerHTML = 'Tiếp tục — Xác thực Email <span class="material-symbols-outlined align-middle text-lg">arrow_forward</span>';
            if (data.success) {
                otpAttempts = 0;
                resendCount = 0;
                document.getElementById('otpAttemptCount').textContent = '0';
                document.getElementById('otpValidityHint').classList.add('hidden');
                showStep(2);
                startResendCountdown();
                saveOwnerDraft();
                document.querySelector('.otp-box[data-index="0"]').focus();
            } else {
                showError(data.message || 'Không thể gửi OTP. Vui lòng thử lại.');
            }
        })
        .catch(() => {
            btn.disabled = false;
            btn.innerHTML = 'Tiếp tục — Xác thực Email <span class="material-symbols-outlined align-middle text-lg">arrow_forward</span>';
            showError('Lỗi kết nối. Vui lòng thử lại.');
        });
    }

    // ==========================================
    // OTP INPUT HANDLING
    // ==========================================
    document.querySelectorAll('.otp-box').forEach(box => {
        box.addEventListener('input', (e) => {
            const val = e.target.value;
            if (val && parseInt(e.target.dataset.index) < 5) {
                const next = document.querySelector('.otp-box[data-index="' + (parseInt(e.target.dataset.index) + 1) + '"]');
                if (next) next.focus();
            }
        });
        box.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && !e.target.value) {
                const prev = document.querySelector('.otp-box[data-index="' + (parseInt(e.target.dataset.index) - 1) + '"]');
                if (prev) { prev.focus(); prev.value = ''; }
            }
        });
        box.addEventListener('paste', (e) => {
            e.preventDefault();
            const pasted = (e.clipboardData || window.clipboardData).getData('text').trim();
            const digits = pasted.replace(/\D/g, '').split('');
            document.querySelectorAll('.otp-box').forEach((b, i) => { b.value = digits[i] || ''; });
            const lastIdx = Math.min(digits.length - 1, 5);
            document.querySelector('.otp-box[data-index="' + lastIdx + '"]').focus();
        });
    });

    // ==========================================
    // VERIFY OTP
    // ==========================================
    function verifyOtp() {
        hideError();
        const otpError = document.getElementById('otpError');
        otpError.classList.add('hidden');

        let otp = '';
        document.querySelectorAll('.otp-box').forEach(b => otp += b.value);
        if (otp.length < 6) { otpError.textContent = 'Vui lòng nhập đủ 6 chữ số.'; otpError.classList.remove('hidden'); return; }

        const email = document.getElementById('regEmail').value.trim();
        const btn = document.getElementById('btnVerifyOtp');
        if (btn.disabled) return;
        btn.disabled = true;
        fetch('${pageContext.request.contextPath}/owner/verify-otp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'email=' + encodeURIComponent(email) + '&otp=' + encodeURIComponent(otp)
        })
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            if (data.success) {
                emailVerified = true;
                showStep(3);
                saveOwnerDraft();
            } else {
                otpAttempts++;
                document.getElementById('otpAttemptCount').textContent = otpAttempts;
                document.querySelectorAll('.otp-box').forEach(b => b.value = '');
                document.querySelector('.otp-box[data-index="0"]').focus();
                if (otpAttempts >= 5) {
                    showError('Bạn đã nhập sai OTP quá 5 lần. Vui lòng quay lại và thử lại.');
                    showStep(1);
                    otpAttempts = 0;
                } else {
                    otpError.textContent = 'Mã OTP không đúng. Còn ' + (5 - otpAttempts) + ' lần thử.';
                    otpError.classList.remove('hidden');
                }
            }
        })
        .catch(() => {
            btn.disabled = false;
            otpError.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
            otpError.classList.remove('hidden');
        });
    }

    // ==========================================
    // RESEND OTP
    // ==========================================
    function startResendCountdown(startSeconds) {
        let seconds = typeof startSeconds === 'number' ? startSeconds : 60;
        const btn = document.getElementById('btnResendOtp');
        const countdown = document.getElementById('resendCountdown');
        const wrap = document.getElementById('resendCountdownWrap');
        clearInterval(resendTimer);
        if (seconds <= 0) {
            btn.disabled = false;
            if (wrap) wrap.classList.add('hidden');
            return;
        }
        countdown.textContent = seconds;
        if (wrap) wrap.classList.remove('hidden');
        btn.disabled = true;
        resendTimer = setInterval(() => {
            seconds--;
            countdown.textContent = seconds;
            if (seconds <= 0) {
                clearInterval(resendTimer);
                btn.disabled = false;
                if (wrap) wrap.classList.add('hidden');
            }
        }, 1000);
    }

    function resendOtp() {
        resendCount++;
        if (resendCount >= 3) {
            showError('Bạn đã gửi lại mã quá 3 lần. Vui lòng quay lại và thử lại.');
            showStep(1);
            return;
        }
        const email = document.getElementById('regEmail').value.trim();
        sendOtpToServer(email);
        document.querySelectorAll('.otp-box').forEach(b => b.value = '');
        otpAttempts = 0;
        document.getElementById('otpAttemptCount').textContent = '0';
    }

    function goToStep2Back() {
        hideError();
        showStep(2);
        saveOwnerDraft();
    }

    // ==========================================
    // SPORTS POPUP
    // ==========================================
    function initSportsGrid() {
        const grid = document.getElementById('sportsGrid');
        grid.innerHTML = '';
        POPULAR_SPORTS.forEach(sport => {
            const isSelected = selectedSports.some(s => s.name === sport.name);
            const div = document.createElement('label');
            div.className = 'sport-item cursor-pointer';
            div.innerHTML = '<input type="checkbox" value="' + sport.name + '" data-icon="' + sport.icon + '" class="hidden peer sport-checkbox" ' + (isSelected ? 'checked' : '') + ' />' +
                '<div class="flex items-center gap-3 p-3 rounded-xl border border-slate-200 peer-checked:border-[#ea580c] peer-checked:bg-[#ea580c]/10 transition-all hover:bg-slate-50">' +
                    '<span class="material-symbols-outlined text-[22px] peer-checked:text-[#ea580c] text-slate-400">' + sport.icon + '</span>' +
                    '<span class="text-sm font-medium text-slate-800">' + sport.name + '</span>' +
                '</div>';
            grid.appendChild(div);
        });
        updateSportsCount();
    }

    function updateSportsCount() {
        const checked = document.querySelectorAll('#sportsGrid .sport-checkbox:checked');
        document.getElementById('selectedSportsCount').textContent = checked.length;
    }

    document.addEventListener('change', (e) => {
        if (e.target.classList.contains('sport-checkbox')) updateSportsCount();
    });

    window.openSportsPopup = function() {
        initSportsGrid();
        document.getElementById('sportsPopup').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    };
    window.closeSportsPopup = function() {
        document.getElementById('sportsPopup').classList.add('hidden');
        document.body.style.overflow = '';
    };
    window.confirmSportsSelection = function() {
        selectedSports = [];
        document.querySelectorAll('#sportsGrid .sport-checkbox:checked').forEach(cb => {
            selectedSports.push({ name: cb.value, icon: cb.dataset.icon });
        });
        closeSportsPopup();
        renderCourtQuantities();
        saveOwnerDraft();
    };

    // ==========================================
    // COURT QUANTITIES
    // ==========================================
    function renderCourtQuantities() {
        const section = document.getElementById('courtQuantitySection');
        const list = document.getElementById('courtQuantityList');
        const preview = document.getElementById('sportsPreviewText');

        if (selectedSports.length === 0) {
            section.classList.add('hidden');
            preview.textContent = 'Chọn các môn thể thao...';
            preview.className = 'text-slate-400';
            return;
        }

        preview.textContent = selectedSports.map(s => s.name).join(', ');
        preview.className = 'text-slate-800 font-medium';
        section.classList.remove('hidden');

        list.innerHTML = '';
        selectedSports.forEach(sport => {
            const row = document.createElement('div');
            row.className = 'flex items-center gap-4 bg-slate-50 p-4 rounded-xl border border-slate-200';
            row.innerHTML = '<span class="material-symbols-outlined text-[#ea580c] text-[22px]">' + sport.icon + '</span>' +
                '<span class="flex-1 font-medium text-slate-800 text-sm">' + sport.name + '</span>' +
                '<div class="flex items-center gap-2">' +
                    '<button type="button" onclick="changeQty(this,-1)" class="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-100 transition-all text-lg font-bold text-slate-700 cursor-pointer">−</button>' +
                    '<input type="number" min="1" value="1" class="court-qty w-14 h-8 text-center border border-slate-200 rounded-lg bg-white font-bold text-slate-800 text-sm" data-sport="' + sport.name + '" />' +
                    '<button type="button" onclick="changeQty(this,1)" class="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center hover:bg-slate-100 transition-all text-lg font-bold text-slate-700 cursor-pointer">+</button>' +
                    '<span class="text-xs text-slate-500 ml-1">sân</span>' +
                '</div>';
            list.appendChild(row);
        });
    }

    window.changeQty = function(btn, delta) {
        const input = btn.parentElement.querySelector('.court-qty');
        let val = parseInt(input.value) || 1;
        val = Math.max(1, val + delta);
        input.value = val;
        saveOwnerDraft();
    };

    // ==========================================
    // FINAL SUBMISSION
    // ==========================================
    window.submitFullForm = function() {
        hideError();
        if (!emailVerified) { showError('Vui lòng xác thực email trước.'); return; }
        if (selectedSports.length === 0) { showError('Vui lòng chọn ít nhất 1 môn thể thao.'); return; }

        const openTime = document.getElementById('openTime').value;
        const closeTime = document.getElementById('closeTime').value;
        if (!openTime || !closeTime) { showError('Vui lòng chọn giờ mở cửa và đóng cửa.'); return; }

        const days = [];
        document.querySelectorAll('#operatingDays input[type="checkbox"]:checked').forEach(cb => days.push(cb.value));
        if (days.length === 0) { showError('Vui lòng chọn ít nhất 1 ngày hoạt động.'); return; }

        const sportsData = [];
        document.querySelectorAll('.court-qty').forEach(input => {
            sportsData.push({ sport: input.dataset.sport, quantity: parseInt(input.value) || 1 });
        });

        const capabilities = [];
        document.querySelectorAll('#capabilityList input[type="checkbox"]:checked').forEach(cb => capabilities.push(cb.value));

        const formData = new URLSearchParams();
        formData.append('ownerName', document.getElementById('ownerName').value.trim());
        formData.append('email', document.getElementById('regEmail').value.trim());
        formData.append('phone', document.getElementById('regPhone').value.trim());
        formData.append('address', document.getElementById('regAddress').value.trim());
        formData.append('description', document.getElementById('regDescription').value.trim());
        formData.append('openTime', openTime);
        formData.append('closeTime', closeTime);
        formData.append('operatingDays', days.join(','));
        formData.append('sportsData', JSON.stringify(sportsData));
        formData.append('capabilities', capabilities.join(','));
        const viDoVal = document.getElementById('viDo').value;
        const kinhDoVal = document.getElementById('kinhDo').value;
        if (viDoVal) formData.append('viDo', viDoVal);
        if (kinhDoVal) formData.append('kinhDo', kinhDoVal);

        const btn = document.querySelector('#formStep3 button[onclick="submitFullForm()"]');
        btn.disabled = true;
        btn.innerHTML = '<span class="animate-spin inline-block w-5 h-5 border-2 border-current border-t-transparent rounded-full mr-2"></span> Đang gửi...';

        fetch('${pageContext.request.contextPath}/owner/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData.toString()
        })
        .then(r => r.json())
        .then(data => {
            btn.disabled = false;
            btn.innerHTML = '🚀 Gửi đăng ký';
            if (data.success) {
                document.getElementById('successAlert').classList.remove('hidden');
                document.getElementById('formStep3').innerHTML = '<div class="text-center py-12"><span class="material-symbols-outlined text-emerald-500 text-6xl mb-4">check_circle</span><h3 class="text-2xl font-extrabold text-slate-900 mb-2">Đăng ký thành công!</h3><p class="text-slate-500">Chúng tôi sẽ sớm liên hệ với bạn qua email hoặc số điện thoại đã cung cấp.</p></div>';
                clearOwnerDraft();
            } else {
                showError(data.message || 'Có lỗi xảy ra. Vui lòng thử lại.');
            }
        })
        .catch(() => {
            btn.disabled = false;
            btn.innerHTML = '🚀 Gửi đăng ký';
            showError('Lỗi kết nối. Vui lòng thử lại.');
        });
    };

    window.goToStep1 = goToStep1;
    window.goToStep2 = goToStep2;
    window.goToStep2Back = goToStep2Back;
    window.verifyOtp = verifyOtp;
    window.resendOtp = resendOtp;

    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('success')) {
        document.getElementById('successAlert').classList.remove('hidden');
        const regSection = document.getElementById('begin');
        if (regSection) regSection.scrollIntoView({behavior:'smooth'});
        clearOwnerDraft();
    }

    // ===== CUSTOM TIME PICKER =====
    (function() {
        const MINUTES = [0, 15, 30, 45];

        function initVtp(wrapId, defaultTime) {
            const wrap = document.getElementById(wrapId);
            if (!wrap) return;
            const [dh, dm] = (defaultTime || '00:00').split(':').map(Number);
            const targetId = wrap.dataset.target;
            let selH = dh, selM = dm;

            const hCol = document.getElementById(wrapId + '-hours');
            const mCol = document.getElementById(wrapId + '-minutes');

            for (let h = 0; h <= 23; h++) {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.textContent = String(h).padStart(2, '0') + ':00';
                if (h === selH) btn.classList.add('active');
                btn.addEventListener('click', function() {
                    selH = h;
                    hCol.querySelectorAll('button').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    commit();
                });
                hCol.appendChild(btn);
            }

            MINUTES.forEach(function(m) {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.textContent = ':' + String(m).padStart(2, '0');
                if (m === selM) btn.classList.add('active');
                btn.addEventListener('click', function() {
                    selM = m;
                    mCol.querySelectorAll('button').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    commit();
                });
                mCol.appendChild(btn);
            });

            function commit() {
                const val = String(selH).padStart(2, '0') + ':' + String(selM).padStart(2, '0');
                document.getElementById(wrapId + '-display').textContent = val;
                if (targetId) document.getElementById(targetId).value = val;
            }

            setTimeout(function() {
                const activeH = hCol.querySelector('.active');
                if (activeH) activeH.scrollIntoView({block: 'center'});
            }, 0);

            commit();
        }

        initVtp('openTimePicker',  '06:00');
        initVtp('closeTimePicker', '22:00');

        document.addEventListener('click', function(e) {
            document.querySelectorAll('.vtimepicker-wrap.open').forEach(function(w) {
                if (!w.contains(e.target)) w.classList.remove('open');
            });
        });
    })();

    window.vtpSetTime = function(wrapId, timeStr) {
        if (!timeStr) return;
        const parts = timeStr.split(':');
        const h = parseInt(parts[0], 10);
        const m = parseInt(parts[1] || '0', 10);
        const wrap = document.getElementById(wrapId);
        if (!wrap) return;
        const targetId = wrap.dataset.target;
        const hCol = document.getElementById(wrapId + '-hours');
        const mCol = document.getElementById(wrapId + '-minutes');
        if (hCol) hCol.querySelectorAll('button').forEach(function(b, i) {
            b.classList.toggle('active', i === h);
        });
        if (mCol) mCol.querySelectorAll('button').forEach(function(b, i) {
            const mins = [0, 15, 30, 45];
            b.classList.toggle('active', mins[i] === m);
        });
        const val = String(h).padStart(2, '0') + ':' + String(m).padStart(2, '0');
        const disp = document.getElementById(wrapId + '-display');
        if (disp) disp.textContent = val;
        if (targetId) document.getElementById(targetId).value = val;
    };

    window.vtpToggle = function(wrapId) {
        const wrap = document.getElementById(wrapId);
        if (!wrap) return;
        const isOpen = wrap.classList.contains('open');
        document.querySelectorAll('.vtimepicker-wrap.open').forEach(function(w) { w.classList.remove('open'); });
        if (!isOpen) {
            wrap.classList.add('open');
            const activeH = document.getElementById(wrapId + '-hours').querySelector('.active');
            if (activeH) setTimeout(function() { activeH.scrollIntoView({block: 'center'}); }, 50);
        }
    };

    // ==========================================
    // BẢN NHÁP ĐĂNG KÝ (sessionStorage)
    // ==========================================
    const OWNER_DRAFT_KEY = 'vsport_owner_registration_draft';
    const OWNER_DRAFT_TTL_MS = 2 * 60 * 60 * 1000;
    const OWNER_DRAFT_VERSION = 1;

    function debounce(fn, wait) {
        let timer = null;
        return function() {
            const args = arguments;
            const ctx = this;
            clearTimeout(timer);
            timer = setTimeout(function() { fn.apply(ctx, args); }, wait);
        };
    }

    function ownerDraftGetVal(id) {
        const el = document.getElementById(id);
        return el ? el.value.trim() : '';
    }

    function collectOwnerDraft() {
        const courtQuantities = {};
        document.querySelectorAll('.court-qty').forEach(function(input) {
            courtQuantities[input.dataset.sport] = input.value;
        });
        const operatingDays = [];
        document.querySelectorAll('#operatingDays input[type="checkbox"]:checked').forEach(function(cb) {
            operatingDays.push(cb.value);
        });
        const capabilities = [];
        document.querySelectorAll('#capabilityList input[type="checkbox"]:checked').forEach(function(cb) {
            capabilities.push(cb.value);
        });
        return {
            version: OWNER_DRAFT_VERSION,
            savedAt: Date.now(),
            currentStep: currentStep,
            fields: {
                tenCoSo: ownerDraftGetVal('ownerName'),
                email: ownerDraftGetVal('regEmail'),
                soDienThoai: ownerDraftGetVal('regPhone'),
                diaChi: ownerDraftGetVal('regAddress'),
                viDo: ownerDraftGetVal('viDo'),
                kinhDo: ownerDraftGetVal('kinhDo')
            },
            step3: {
                selectedSports: selectedSports,
                courtQuantities: courtQuantities,
                openTime: document.getElementById('openTimePicker') ? document.getElementById('openTimePicker').value : '',
                closeTime: document.getElementById('closeTimePicker') ? document.getElementById('closeTimePicker').value : '',
                operatingDays: operatingDays,
                description: ownerDraftGetVal('regDescription'),
                capabilities: capabilities
            }
        };
    }

    function saveOwnerDraft() {
        try {
            const draft = collectOwnerDraft();
            sessionStorage.setItem(OWNER_DRAFT_KEY, JSON.stringify(draft));
        } catch (e) {}
    }
    const debouncedSaveOwnerDraft = debounce(saveOwnerDraft, 400);

    function isDraftExpired(draft) {
        if (!draft || !draft.savedAt) return true;
        return (Date.now() - draft.savedAt) > OWNER_DRAFT_TTL_MS;
    }

    function clearOwnerDraft() {
        try { sessionStorage.removeItem(OWNER_DRAFT_KEY); } catch (e) {}
    }

    function loadOwnerDraft() {
        let raw;
        try { raw = sessionStorage.getItem(OWNER_DRAFT_KEY); } catch (e) { return null; }
        if (!raw) return null;
        let draft;
        try { draft = JSON.parse(raw); } catch (e) { clearOwnerDraft(); return null; }
        if (!draft || draft.version !== OWNER_DRAFT_VERSION || isDraftExpired(draft)) {
            clearOwnerDraft();
            return null;
        }
        if (draft.fields) {
            const hasVi = !!draft.fields.viDo;
            const hasKinh = !!draft.fields.kinhDo;
            if (hasVi !== hasKinh) {
                draft.fields.viDo = '';
                draft.fields.kinhDo = '';
            }
        }
        return draft;
    }

    function goToRegistrationStep(step) { showStep(step); }

    function restoreOwnerDraftFieldsToDom(draft) {
        const f = draft.fields || {};
        if (f.tenCoSo) document.getElementById('ownerName').value = f.tenCoSo;
        if (f.email) document.getElementById('regEmail').value = f.email;
        if (f.soDienThoai) document.getElementById('regPhone').value = f.soDienThoai;
        if (f.diaChi) document.getElementById('regAddress').value = f.diaChi;

        if (f.viDo && f.kinhDo) {
            document.getElementById('viDo').value = f.viDo;
            document.getElementById('kinhDo').value = f.kinhDo;
            setLocationCoords(f.viDo, f.kinhDo);
        }

        const s3 = draft.step3 || {};
        if (Array.isArray(s3.selectedSports) && s3.selectedSports.length) {
            selectedSports = s3.selectedSports;
            renderCourtQuantities();
            if (s3.courtQuantities) {
                document.querySelectorAll('.court-qty').forEach(function(input) {
                    const qty = s3.courtQuantities[input.dataset.sport];
                    if (qty) input.value = qty;
                });
            }
        }
        if (Array.isArray(s3.operatingDays) && s3.operatingDays.length) {
            document.querySelectorAll('#operatingDays input[type="checkbox"]').forEach(function(cb) {
                cb.checked = s3.operatingDays.indexOf(cb.value) !== -1;
            });
        }
        if (s3.openTime) { vtpSetTime('openTimePicker', s3.openTime); }
        if (s3.closeTime) { vtpSetTime('closeTimePicker', s3.closeTime); }
        if (s3.description) document.getElementById('regDescription').value = s3.description;
        if (Array.isArray(s3.capabilities) && s3.capabilities.length) {
            document.querySelectorAll('#capabilityList input[type="checkbox"]').forEach(function(cb) {
                cb.checked = s3.capabilities.indexOf(cb.value) !== -1;
            });
        }
    }

    function fetchOwnerOtpStatus() {
        return fetch('${pageContext.request.contextPath}/owner/otp-status')
            .then(function(r) { return r.json(); })
            .catch(function() { return { emailVerified: false, otpActive: false, secondsRemaining: 0, otpEmail: null }; });
    }

    function showOtpValidityHint(secondsRemaining) {
        const el = document.getElementById('otpValidityHint');
        if (!el) return;
        const mins = Math.max(1, Math.ceil(secondsRemaining / 60));
        el.textContent = 'Mã xác thực còn hiệu lực khoảng ' + mins + ' phút.';
        el.classList.remove('hidden');
    }

    function applyResendCooldownFromOtpValidity(secondsRemainingOtpValidity) {
        const elapsedSinceSent = Math.max(0, 300 - (secondsRemainingOtpValidity || 0));
        const cooldownLeft = Math.max(0, 60 - elapsedSinceSent);
        startResendCountdown(cooldownLeft);
    }

    async function reconcileOtpState(candidateStep, emailForDisplay) {
        if (!candidateStep || candidateStep <= 1) {
            goToRegistrationStep(1);
            return;
        }
        const status = await fetchOwnerOtpStatus();
        if (status.emailVerified) {
            emailVerified = true;
            if (emailForDisplay) document.getElementById('otpEmailDisplay').textContent = emailForDisplay;
            goToRegistrationStep(3);
            return;
        }
        if (status.otpActive) {
            document.getElementById('otpEmailDisplay').textContent = status.otpEmail || emailForDisplay || '';
            goToRegistrationStep(2);
            applyResendCooldownFromOtpValidity(status.secondsRemaining);
            showOtpValidityHint(status.secondsRemaining);
            return;
        }
        emailVerified = false;
        showError('Phiên xác thực đã hết hạn. Vui lòng gửi lại OTP.');
        goToRegistrationStep(1);
    }

    async function initOwnerRegistrationDraft() {
        if (window.ownerServerFormHasData) return;
        const draft = loadOwnerDraft();
        if (!draft) return;
        restoreOwnerDraftFieldsToDom(draft);
        await reconcileOtpState(draft.currentStep, draft.fields && draft.fields.email);
    }

    const OWNER_DRAFT_WATCHED_SELECTOR = '#ownerName, #regEmail, #regPhone, #regAddress, #regDescription, ' +
        '#openTimePicker, #closeTimePicker, #operatingDays input[type="checkbox"], .court-qty, ' +
        '#capabilityList input[type="checkbox"]';

    ['input', 'change', 'focusout'].forEach(function(evt) {
        document.addEventListener(evt, function(e) {
            if (e.target && e.target.matches && e.target.matches(OWNER_DRAFT_WATCHED_SELECTOR)) {
                debouncedSaveOwnerDraft();
            }
        });
    });

    window.confirmResetOwnerDraft = function() {
        const ok = window.confirm('Bạn có chắc muốn xóa toàn bộ thông tin đã nhập và bắt đầu lại không?');
        if (!ok) return;
        clearOwnerDraft();
        resetOwnerFormToInitialState();
    };

    function resetOwnerFormToInitialState() {
        document.getElementById('ownerName').value = '';
        document.getElementById('regEmail').value = '';
        document.getElementById('regPhone').value = '';
        document.getElementById('regAddress').value = '';
        document.getElementById('viDo').value = '';
        document.getElementById('kinhDo').value = '';
        document.getElementById('coordPreview').classList.add('hidden');
        document.getElementById('coordPreviewText').textContent = '';
        document.getElementById('coordMapsLink').classList.add('hidden');
        document.getElementById('regDescription').value = '';
        selectedSports = [];
        renderCourtQuantities();
        document.querySelectorAll('#operatingDays input[type="checkbox"]').forEach(function(cb) { cb.checked = true; });
        document.querySelectorAll('#capabilityList input[type="checkbox"]').forEach(function(cb) { cb.checked = false; });
        emailVerified = false;
        otpAttempts = 0;
        resendCount = 0;
        clearInterval(resendTimer);
        document.querySelectorAll('.otp-box').forEach(function(b) { b.value = ''; });
        document.getElementById('otpValidityHint').classList.add('hidden');
        hideError();
        goToRegistrationStep(1);
    }

    document.addEventListener('DOMContentLoaded', function() {
        initOwnerRegistrationDraft();
    });

    window.addEventListener('pageshow', function(e) {
        if (e.persisted && currentStep > 1) {
            reconcileOtpState(currentStep, ownerDraftGetVal('regEmail'));
        }
    });

    // ==========================================
    // NAVBAR + REVEAL + PARALLAX (ThanhTruc patterns)
    // ==========================================
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        navbar.classList.toggle('scrolled', window.scrollY > 50);
    });

    const navToggle = document.getElementById('navToggle');
    const navLinksEl = document.getElementById('navLinks');
    if (navToggle) {
        navToggle.addEventListener('click', () => navLinksEl.classList.toggle('active'));
        navLinksEl.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => navLinksEl.classList.remove('active'));
        });
    }

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                revealObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

    window.addEventListener('scroll', () => {
        const scrollY = window.scrollY;
        document.querySelectorAll('.parallax-sport').forEach(el => {
            const speed = parseFloat(el.dataset.speed) || 0.3;
            el.style.transform = 'translateY(' + (scrollY * speed * -0.5) + 'px)';
        });
    });

    // Social link hover
    document.querySelectorAll('.social-link').forEach(a => {
        a.addEventListener('mouseenter', () => { a.style.background = 'var(--orange)'; a.style.color = '#fff'; });
        a.addEventListener('mouseleave', () => { a.style.background = 'rgba(255,255,255,0.1)'; a.style.color = 'rgba(255,255,255,0.6)'; });
    });
</script>

</body>
</html>
