<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🏸</text></svg>">
<title>V-Sport — Nâng Tầm Quản Lý Cơ Sở Thể Thao</title>
<meta name="description" content="Hệ thống quản lý thông minh giúp tối ưu lịch đặt sân, quản lý hội viên và tăng doanh thu hiệu quả với công nghệ AI tiên tiến.">
<meta name="theme-color" content="#ffffff">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="">
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800&amp;display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
<style>
:root{
  --ink:#0f172a;
  --ink-2:#334155;
  --muted:#64748b;
  --paper:#ffffff;
  --paper-2:#f8fafc;
  --paper-3:#f1f5f9;
  --line:#e2e8f0;
  --accent:#7c3aed;
  --accent-2:#9333ea;
  --accent-soft:#f5f3ff;
  --sans:"Be Vietnam Pro",-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
  --maxw:1280px;
  --pad:clamp(20px,5vw,64px);
}
*{box-sizing:border-box;margin:0;padding:0}
html{scroll-behavior:smooth}
body{
  font-family:var(--sans);
  background:var(--paper);
  color:var(--ink);
  line-height:1.6;
  -webkit-font-smoothing:antialiased;
}
img{display:block;max-width:100%;height:auto}
a{color:inherit;text-decoration:none}
::selection{background:var(--accent);color:#fff}
.wrap{max-width:var(--maxw);margin-inline:auto;padding-inline:var(--pad)}
h1,h2,h3{font-weight:800;letter-spacing:-.02em;line-height:1.1}
.eyebrow{font-weight:700;font-size:.72rem;letter-spacing:.14em;text-transform:uppercase;color:var(--accent)}
.lead{font-size:clamp(1rem,1.3vw,1.15rem);color:var(--ink-2);font-weight:400}
.h2{font-size:clamp(1.8rem,3.6vw,2.7rem)}
.card-shadow{box-shadow:0 1px 2px rgba(15,23,42,.04),0 12px 32px -12px rgba(15,23,42,.10)}

/* ===== NAV ===== */
header.nav{
  position:sticky;top:0;left:0;width:100%;z-index:100;
  display:flex;align-items:center;justify-content:space-between;
  padding:16px var(--pad);background:rgba(255,255,255,.85);backdrop-filter:blur(10px);
  border-bottom:1px solid var(--line);
}
.brand{font-weight:800;font-size:1.3rem;letter-spacing:-.02em;display:flex;align-items:center;gap:8px}
.brand span{color:var(--accent)}
.nav-links{display:flex;gap:28px;align-items:center}
.nav-links a:not(.btn){font-size:.88rem;font-weight:600;color:var(--ink-2);transition:color .2s}
.nav-links a:not(.btn):hover{color:var(--accent)}
@media(max-width:820px){.nav-links a:not(.btn):not(.btn-outline){display:none}}
.btn{display:inline-flex;align-items:center;gap:8px;border-radius:12px;font-weight:700;font-size:.9rem;
  padding:11px 20px;transition:all .2s;border:1px solid transparent;cursor:pointer}
.btn-primary{background:var(--accent);color:#fff}
.btn-primary:hover{background:var(--accent-2);transform:translateY(-1px)}
.btn-outline{border-color:var(--line);color:var(--ink);background:#fff}
.btn-outline:hover{border-color:var(--accent);color:var(--accent)}

/* ===== HERO (full-width photo thesis) ===== */
.hero{position:relative;min-height:min(78vh,720px);display:flex;align-items:flex-end;overflow:hidden;
  background:var(--ink)}
.hero-media{position:absolute;inset:0}
.hero-media img{width:100%;height:100%;object-fit:cover;object-position:65% 50%}
.hero-media::after{content:"";position:absolute;inset:0;
  background:linear-gradient(0deg,rgba(15,23,42,.92) 0%,rgba(15,23,42,.55) 46%,rgba(15,23,42,.22) 72%,rgba(15,23,42,.08) 100%)}
.hero-content{position:relative;z-index:2;color:#fff;padding:clamp(40px,8vh,88px) 0 clamp(36px,6vh,56px)}
.hero-content .eyebrow{color:#c4b5fd}
.hero h1{font-size:clamp(2.1rem,4.8vw,3.5rem);margin-top:14px;max-width:17ch;color:#fff}
.hero .lead{margin-top:18px;max-width:54ch;color:#e2e8f0}
.hero-benefits{margin-top:28px;display:flex;flex-wrap:wrap;gap:12px 28px}
.hero-benefits div{display:flex;align-items:center;gap:9px;font-size:.88rem;color:#f1f5f9;font-weight:500}
.hero-benefits .material-symbols-outlined{color:#c4b5fd;font-size:19px}
.hero-actions{margin-top:32px;display:flex;flex-wrap:wrap;align-items:center;gap:18px}
.hero-stats{display:flex;gap:clamp(20px,4vw,40px)}
.hero-stats div{text-align:left}
.hero-stats .v{font-size:1.4rem;font-weight:800;color:#fff;line-height:1}
.hero-stats .k{font-size:.7rem;color:#cbd5e1;font-weight:600;margin-top:3px}

/* ===== REGISTRATION (own section, below hero) ===== */
.registration{background:var(--paper-2);padding:clamp(48px,7vh,80px) 0}
.registration-grid{display:grid;grid-template-columns:.9fr 1.1fr;gap:clamp(32px,5vw,64px);align-items:start}
@media(max-width:980px){.registration-grid{grid-template-columns:1fr}}
.registration-intro h2{margin-top:10px}
.registration-intro .lead{margin-top:14px;max-width:44ch}
.registration-steps-mini{margin-top:32px;display:flex;flex-direction:column;gap:18px}
.registration-steps-mini div{display:flex;gap:14px;align-items:flex-start}
.registration-steps-mini .n{width:30px;height:30px;border-radius:9px;background:var(--accent-soft);color:var(--accent);
  font-weight:800;font-size:.85rem;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.registration-steps-mini h4{font-size:.92rem;font-weight:700;color:var(--ink)}
.registration-steps-mini p{font-size:.82rem;color:var(--muted);margin-top:2px}

/* ===== REGISTRATION CARD ===== */
.reg-card{background:#fff;border:1px solid var(--line);border-radius:24px;padding:clamp(22px,3vw,32px);
  position:relative}
.field label{display:block;font-size:.72rem;font-weight:700;letter-spacing:.06em;text-transform:uppercase;
  color:var(--muted);margin-bottom:7px}
.field input,.field textarea,.field select{
  width:100%;padding:12px 15px;border:1px solid var(--line);border-radius:11px;font-size:.92rem;
  font-family:var(--sans);color:var(--ink);background:#fff;transition:all .15s;
}
.field input::placeholder,.field textarea::placeholder{color:#94a3b8}
.field input:focus,.field textarea:focus,.field select:focus{
  outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(124,58,237,.12)
}
.step-dot{display:flex;align-items:center;gap:8px;padding:9px 14px;border-radius:12px;font-size:.82rem;
  font-weight:700;white-space:nowrap;transition:all .2s;background:var(--paper-3);color:var(--muted)}
.step-dot.active{background:var(--accent);color:#fff}
.step-dot.done{background:#dcfce7;color:#15803d}
.step-num{display:flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:7px;
  font-size:.7rem;background:rgba(255,255,255,.25)}
.step-dot.active .step-num{background:rgba(255,255,255,.28)}
.step-dot:not(.active):not(.done) .step-num{background:#e2e8f0}
.otp-box{width:46px;height:52px;text-align:center;font-size:1.2rem;font-weight:800;border:2px solid var(--line);
  border-radius:12px;color:var(--ink)}
.otp-box:focus{outline:none;border-color:var(--accent);box-shadow:0 0 0 3px rgba(124,58,237,.12)}
.day-chip input{display:none}
.day-chip{display:block}
.day-chip span{display:block;padding:8px 4px;border-radius:100px;border:1px solid var(--line);
  font-size:.82rem;font-weight:600;color:var(--ink-2);cursor:pointer;transition:all .15s;
  text-align:center;white-space:nowrap}
.day-chip input:checked + span{background:var(--accent);color:#fff;border-color:var(--accent)}
.capability-chip{border:1px solid var(--line);border-radius:14px;background:#fff;transition:all .15s}
.capability-chip:hover{border-color:#c4b5fd}
.capability-chip input:checked ~ span,.capability-chip:has(input:checked){border-color:var(--accent);background:var(--accent-soft)}

/* ===== CUSTOM TIME PICKER ===== */
.vtimepicker-wrap{position:relative;user-select:none}
.vtimepicker-btn{width:100%;display:flex;align-items:center;gap:8px;padding:12px 15px;border:1px solid var(--line);
  border-radius:11px;font-size:.92rem;font-family:var(--sans);color:var(--ink);background:#fff;
  cursor:pointer;transition:all .15s;text-align:left}
.vtimepicker-btn:hover,.vtimepicker-wrap.open .vtimepicker-btn{border-color:var(--accent);box-shadow:0 0 0 3px rgba(124,58,237,.12)}
.vtimepicker-icon{font-size:18px;color:var(--accent)}
.vtimepicker-display{flex:1;font-weight:600;font-size:1rem;letter-spacing:.04em}
.vtimepicker-caret{font-size:18px;color:#94a3b8;transition:transform .2s}
.vtimepicker-wrap.open .vtimepicker-caret{transform:rotate(180deg)}
.vtimepicker-popup{display:none;position:absolute;top:calc(100% + 6px);left:0;right:0;
  background:#fff;border:1px solid #e2e8f0;border-radius:14px;
  box-shadow:0 8px 30px rgba(0,0,0,.12);z-index:999;
  padding:12px 8px;flex-direction:row;gap:4px;align-items:flex-start}
.vtimepicker-wrap.open .vtimepicker-popup{display:flex}
.vtimepicker-col{flex:1;display:flex;flex-direction:column;gap:2px;max-height:220px;overflow-y:auto;
  scrollbar-width:thin;scrollbar-color:#c4b5fd #f5f3ff}
.vtimepicker-col::-webkit-scrollbar{width:4px}
.vtimepicker-col::-webkit-scrollbar-thumb{background:#c4b5fd;border-radius:4px}
.vtimepicker-col button{width:100%;padding:7px 4px;border:none;background:transparent;
  border-radius:8px;font-size:.88rem;font-family:var(--sans);cursor:pointer;
  color:#475569;transition:all .12s;text-align:center}
.vtimepicker-col button:hover{background:#f5f3ff;color:var(--accent)}
.vtimepicker-col button.active{background:var(--accent);color:#fff;font-weight:700}
.vtimepicker-sep{font-size:1.4rem;font-weight:700;color:#94a3b8;padding:6px 2px;align-self:flex-start;margin-top:4px}

/* ===== SECTIONS ===== */
section.block{padding:clamp(56px,8vh,96px) 0}
.eyebrow.muted{color:var(--muted)}
.section-head{max-width:640px;margin-bottom:clamp(32px,5vh,52px)}
.section-head h2{margin-top:10px}
.section-head .lead{margin-top:14px}

/* feature cards */
.feature-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:22px}
@media(max-width:900px){.feature-grid{grid-template-columns:1fr}}
.feature-card{background:#fff;border:1px solid var(--line);border-radius:20px;padding:28px;transition:all .2s}
.feature-card:hover{border-color:#c4b5fd;transform:translateY(-2px)}
.feature-card .ico{width:44px;height:44px;border-radius:12px;background:var(--accent-soft);color:var(--accent);
  display:flex;align-items:center;justify-content:center;margin-bottom:16px}
.feature-card h3{font-size:1.05rem;margin-bottom:8px}
.feature-card p{font-size:.88rem;color:var(--muted);font-weight:400}

/* process steps */
.process-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:18px}
@media(max-width:900px){.process-grid{grid-template-columns:1fr 1fr}}
@media(max-width:560px){.process-grid{grid-template-columns:1fr}}
.process-card{background:var(--paper-2);border:1px solid var(--line);border-radius:18px;padding:22px}
.process-card .num{font-size:1.8rem;font-weight:800;color:var(--accent);line-height:1}
.process-card h3{font-size:.98rem;margin:12px 0 6px}
.process-card p{font-size:.84rem;color:var(--muted)}

/* solution split */
.solution-grid{display:grid;grid-template-columns:1fr 1fr;gap:clamp(30px,5vw,64px);align-items:center}
@media(max-width:860px){.solution-grid{grid-template-columns:1fr}}
.solution-media{border-radius:20px;overflow:hidden;aspect-ratio:4/3;background:var(--paper-3)}
.solution-media img{width:100%;height:100%;object-fit:cover}
.ledger div{display:flex;justify-content:space-between;padding:13px 0;border-bottom:1px solid var(--line);font-size:.9rem}
.ledger div:first-child{border-top:1px solid var(--line)}
.ledger span:first-child{color:var(--muted)}
.ledger span:last-child{font-weight:700}

/* testimonial */
.quote-band{background:var(--accent);color:#fff;border-radius:28px;padding:clamp(36px,6vw,60px);margin-inline:var(--pad)}
.quote-band q{font-size:clamp(1.2rem,2.4vw,1.7rem);font-weight:600;line-height:1.35;quotes:none;display:block}
.quote-band .who{margin-top:20px;font-size:.85rem;opacity:.85;font-weight:600}

/* marquee */
.marquee{overflow:hidden;padding:36px 0;border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.mrow{display:flex;white-space:nowrap;width:max-content;animation:scroll-left 30s linear infinite}
.mrow span{font-size:1.1rem;font-weight:700;padding:0 22px;color:var(--ink-2);display:inline-flex;align-items:center;gap:22px}
.mrow span::after{content:"•";color:var(--accent)}
@keyframes scroll-left{from{transform:translateX(0)}to{transform:translateX(-50%)}}

/* final CTA */
.final-cta{background:linear-gradient(135deg,var(--ink),#1e1b4b);border-radius:28px;color:#fff;
  padding:clamp(40px,6vw,64px);margin-inline:var(--pad);text-align:center}
.final-cta h2{color:#fff;font-size:clamp(1.8rem,4vw,2.6rem)}
.final-cta p{color:#cbd5e1;margin-top:14px;max-width:52ch;margin-inline:auto}

/* footer */
footer.foot{background:var(--paper-2);border-top:1px solid var(--line);padding:48px 0 28px}
.foot-top{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:32px;padding-bottom:36px}
.foot-top p{color:var(--muted);font-size:.88rem;max-width:34ch;margin-top:10px}
.foot-col h4{font-size:.72rem;letter-spacing:.1em;text-transform:uppercase;color:var(--muted);
  font-weight:700;margin-bottom:14px}
.foot-col a{display:block;padding:5px 0;font-size:.88rem;color:var(--ink-2);transition:color .2s}
.foot-col a:hover{color:var(--accent)}
.foot-bottom{display:flex;justify-content:space-between;flex-wrap:wrap;gap:12px;padding-top:24px;
  border-top:1px solid var(--line);font-size:.8rem;color:var(--muted)}
@media(max-width:760px){.foot-top{grid-template-columns:1fr 1fr}}

/* alerts */
.alert{border-radius:14px;padding:14px 16px;display:flex;align-items:center;gap:10px;font-size:.88rem;font-weight:600}
.alert-success{background:#f0fdf4;border:1px solid #bbf7d0;color:#166534}
.alert-error{background:#fef2f2;border:1px solid #fecaca;color:#b91c1c}

#stepIndicators::-webkit-scrollbar{display:none}
#stepIndicators{-ms-overflow-style:none;scrollbar-width:none}
</style>
</head>
<body>

<header class="nav">
  <a href="${pageContext.request.contextPath}/" class="brand">V-SPORT<span>.</span></a>
  <nav class="nav-links">
    <a href="#features">Tính năng</a>
    <a href="#process">Quy trình</a>
    <a href="#solution">Giải pháp</a>
    <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-outline">Đăng nhập</a>
    <a href="#begin" class="btn btn-primary">Đăng ký ngay</a>
  </nav>
</header>

<main>

  <!-- ================= HERO (photo thesis) ================= -->
  <section class="hero">
    <div class="hero-media">
      <img src="${pageContext.request.contextPath}/assets/images/owner/owner-hero-vsport.webp" alt="Chủ cơ sở thể thao quan sát sân bóng và sân tennis từ ban công, quản lý bằng V-SPORT trên máy tính bảng">
    </div>
    <div class="wrap hero-content">
      <p class="eyebrow">V-SPORT · GIẢI PHÁP VẬN HÀNH THỂ THAO</p>
      <h1>Nâng tầm vận hành cơ sở thể thao của bạn.</h1>
      <p class="lead">Quản lý lịch sân, nhân sự, thanh toán và doanh thu trên một nền tảng duy nhất — giúp cơ sở vận hành chính xác và phát triển bền vững.</p>
      <div class="hero-benefits">
        <div><span class="material-symbols-outlined">event_available</span> Quản lý lịch sân tập trung</div>
        <div><span class="material-symbols-outlined">monitoring</span> Theo dõi doanh thu theo thời gian thực</div>
        <div><span class="material-symbols-outlined">groups</span> Vận hành nhân sự và dịch vụ hiệu quả</div>
      </div>
      <div class="hero-actions">
        <a href="#begin" class="btn btn-primary" style="padding:13px 28px;font-size:.95rem">Đăng ký cơ sở miễn phí</a>
        <div class="hero-stats">
          <div><div class="v">500+</div><div class="k">Cơ sở tin dùng</div></div>
          <div><div class="v">99%</div><div class="k">Hài lòng</div></div>
          <div><div class="v">24/7</div><div class="k">Hỗ trợ</div></div>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= REGISTRATION ================= -->
  <section class="registration" id="begin">
    <div class="wrap registration-grid">
      <div class="registration-intro">
        <p class="eyebrow muted">/ Đăng ký cơ sở</p>
        <h2 class="h2">Bắt đầu số hóa vận hành ngay hôm nay.</h2>
        <p class="lead">Điền thông tin bên cạnh — đội ngũ V-SPORT sẽ liên hệ trong vòng 24 giờ để hỗ trợ bạn cấu hình hệ thống.</p>
        <div class="registration-steps-mini">
          <div><span class="n">1</span><div><h4>Thông tin cơ bản</h4><p>Tên cơ sở, email và số điện thoại liên hệ.</p></div></div>
          <div><span class="n">2</span><div><h4>Xác thực email</h4><p>Nhập mã OTP gửi tới email để xác minh chủ quyền.</p></div></div>
          <div><span class="n">3</span><div><h4>Cấu hình sân</h4><p>Môn thể thao, số lượng sân và khung giờ hoạt động.</p></div></div>
        </div>
      </div>

      <!-- ====== REGISTRATION FORM ====== -->
      <div class="reg-card card-shadow">
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

        <!-- Xóa bản nháp / Bắt đầu lại -->
        <div class="flex justify-end -mt-3 mb-3">
          <button type="button" onclick="confirmResetOwnerDraft()" class="text-slate-400 hover:text-slate-600 text-xs underline underline-offset-2 bg-transparent border-none cursor-pointer transition-colors">Xóa bản nháp / Bắt đầu lại</button>
        </div>

        <!-- ====== STEP 1: Basic Info ====== -->
        <div id="formStep1" class="form-step">
          <h3 class="text-lg font-extrabold mb-5 text-slate-900">Thông tin cơ bản</h3>
          <div class="flex flex-col gap-4">
            <div class="field">
              <label for="ownerName">Tên cơ sở <span class="text-[#7c3aed]">*</span></label>
              <input type="text" id="ownerName" name="ownerName" required placeholder="VD: Sân bóng Tân Bình" />
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="field">
                <label for="regEmail">Email liên hệ <span class="text-[#7c3aed]">*</span></label>
                <input type="email" id="regEmail" required placeholder="email@example.com" />
              </div>
              <div class="field">
                <label for="regPhone">Số điện thoại <span class="text-[#7c3aed]">*</span></label>
                <input type="tel" id="regPhone" required placeholder="0912 345 678" />
              </div>
            </div>
            <div class="field">
              <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-1.5 sm:gap-4 mb-1">
                <label for="regAddress" class="!mb-0">Địa chỉ cơ sở</label>
                <button type="button" onclick="autoFillAddress()" class="text-xs text-[#7c3aed] hover:underline flex items-center gap-1 bg-transparent border-none cursor-pointer focus:outline-none font-semibold">
                  <span class="material-symbols-outlined text-[14px]">my_location</span> Lấy vị trí / Tọa độ GG Map
                </button>
              </div>
              <input type="text" id="regAddress" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành" />
              <div id="coordPreview" class="hidden mt-1.5 flex flex-col gap-0.5">
                <div class="flex items-start gap-1.5">
                  <span class="material-symbols-outlined mt-px text-[14px] text-[#7c3aed]">location_on</span>
                  <span id="coordPreviewText" class="text-xs leading-snug text-[#7c3aed]"></span>
                </div>
                <a id="coordMapsLink" href="#" target="_blank" rel="noopener noreferrer" class="hidden text-xs underline pl-5 text-[#7c3aed]">Mở Google Maps để kiểm tra vị trí</a>
              </div>
            </div>
            <button type="button" onclick="goToStep2()" class="btn btn-primary w-full justify-center py-3.5 text-base mt-1">
              Tiếp tục — Xác thực Email <span class="material-symbols-outlined align-middle text-lg">arrow_forward</span>
            </button>
          </div>
        </div>

        <!-- ====== STEP 2: OTP Verification ====== -->
        <div id="formStep2" class="form-step hidden">
          <h3 class="text-lg font-extrabold mb-2 text-slate-900">Xác thực Email</h3>
          <p class="text-slate-500 text-sm mb-5">Chúng tôi đã gửi mã OTP đến <strong id="otpEmailDisplay" class="text-[#7c3aed]"></strong>. Vui lòng nhập mã bên dưới.</p>
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
              <button type="button" onclick="resendOtp()" id="btnResendOtp" class="text-[#7c3aed] hover:text-[#9333ea] text-sm transition-colors disabled:opacity-40 bg-transparent border-none cursor-pointer font-semibold" disabled>
                Gửi lại mã<span id="resendCountdownWrap"> (<span id="resendCountdown">60</span>s)</span>
              </button>
            </div>
          </div>
          <p class="text-center text-slate-400 text-xs mt-4">Số lần nhập sai: <span id="otpAttemptCount" class="font-bold text-red-500">0</span>/5</p>
        </div>

        <!-- ====== STEP 3: Sports, Courts, Operating Hours ====== -->
        <div id="formStep3" class="form-step hidden">
          <h3 class="text-lg font-extrabold mb-5 text-slate-900">Cấu hình cơ sở</h3>

          <!-- Sports selector -->
          <div class="field mb-5">
            <label>Môn thể thao / Dịch vụ <span class="text-[#7c3aed]">*</span></label>
            <button type="button" onclick="openSportsPopup()" class="w-full px-4 py-3 border border-slate-200 rounded-xl bg-white text-left flex items-center justify-between hover:border-[#7c3aed]/50 transition-all cursor-pointer">
              <span id="sportsPreviewText" class="text-slate-400">Chọn các môn thể thao...</span>
              <span class="material-symbols-outlined text-[#7c3aed]">add_circle</span>
            </button>
          </div>

          <!-- Selected sports tags + court quantities -->
          <div id="courtQuantitySection" class="hidden mb-5">
            <label class="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Số lượng sân từng môn</label>
            <div id="courtQuantityList" class="flex flex-col gap-3"></div>
          </div>

          <!-- Operating hours -->
          <input type="hidden" id="openTime"  value="06:00">
          <input type="hidden" id="closeTime" value="22:00">
          <!-- Coordinates (set by geo modal) -->
          <input type="hidden" id="viDo"   name="viDo">
          <input type="hidden" id="kinhDo" name="kinhDo">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-5">
            <div class="field">
              <label>Giờ mở cửa <span class="text-[#7c3aed]">*</span></label>
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
              <label>Giờ đóng cửa <span class="text-[#7c3aed]">*</span></label>
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

          <!-- Operating days -->
          <div class="mb-5">
            <label class="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Ngày hoạt động <span class="text-[#7c3aed]">*</span></label>
            <div class="grid grid-cols-7 gap-2" id="operatingDays">
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T2" checked/>
                <span>Thứ 2</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T3" checked/>
                <span>Thứ 3</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T4" checked/>
                <span>Thứ 4</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T5" checked/>
                <span>Thứ 5</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T6" checked/>
                <span>Thứ 6</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="T7" checked/>
                <span>Thứ 7</span>
              </label>
              <label class="day-chip cursor-pointer">
                <input type="checkbox" value="CN" checked/>
                <span>Chủ nhật</span>
              </label>
            </div>
          </div>

          <!-- Description -->
          <div class="field mb-5">
            <label for="regDescription">Mô tả thêm về cơ sở</label>
            <textarea id="regDescription" rows="3" placeholder="Dịch vụ đi kèm, tiện ích, lưu ý đặc biệt..." class="resize-vertical"></textarea>
          </div>

          <!-- Business capabilities (ngoài cho thuê sân, cần Admin duyệt riêng từng mục) -->
          <div class="mb-5">
            <label class="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">Hoạt động và dịch vụ tại cơ sở</label>
            <p class="text-xs text-slate-400 mb-3">Ngoài cho thuê sân, chọn thêm nếu cơ sở của bạn có các hoạt động sau. Mỗi lựa chọn cần quản trị viên phê duyệt riêng trước khi được kích hoạt.</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2" id="capabilityList">
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="SAN_PHAM" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Bán sản phẩm thể thao</b> — giày, áo quần, vợt, bóng, phụ kiện</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="THUE_DUNG_CU" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Cho thuê dụng cụ thể thao</b> — vợt, bóng, giày, áo bib...</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="DO_AN_NUOC_UONG" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Đồ ăn và nước uống</b> — quầy giải khát, đồ ăn nhẹ tại chỗ</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="HUAN_LUYEN_VIEN" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Cung cấp huấn luyện viên</b> — HLV riêng hoặc theo nhóm</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="LOP_HOC" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Tổ chức lớp học</b> — lớp học theo lịch, theo khóa</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="DICH_VU_THE_THAO" id="capDichVuTheThao" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Cung cấp dịch vụ thể thao</b> — căng lưới vợt, thay quấn cán, sửa chữa/bảo dưỡng dụng cụ...</span>
              </label>
              <label class="capability-chip flex items-center gap-3 px-4 py-3 cursor-pointer">
                <input type="checkbox" value="KHAC" class="w-5 h-5 accent-[#7c3aed] flex-shrink-0"/>
                <span class="text-sm text-slate-600"><b class="text-slate-900">Dịch vụ khác</b> — sẽ trao đổi thêm với V-SPORT sau khi duyệt</span>
              </label>
            </div>
            <!-- Sub-options bên ngoài #capabilityList: chỉ mô tả nhu cầu, KHÔNG được thu thập vào mảng
                 capabilities[] gửi lên server (JS collector chỉ query trong #capabilityList) -->
            <div id="dichVuTheThaoOptions" class="hidden mt-2 ml-8 flex flex-col gap-1.5 pl-3 border-l border-slate-200">
              <p class="text-xs text-slate-500 mb-1">Loại dịch vụ dự kiến cung cấp (không bắt buộc):</p>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="CANG_LUOI_VOT" class="w-4 h-4 accent-[#7c3aed]"/> Căng lưới vợt (cầu lông/tennis)</label>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="THAY_QUAN_CAN" class="w-4 h-4 accent-[#7c3aed]"/> Thay quấn cán</label>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="SUA_CHUA_VOT" class="w-4 h-4 accent-[#7c3aed]"/> Sửa chữa vợt</label>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="BAO_DUONG_DUNG_CU" class="w-4 h-4 accent-[#7c3aed]"/> Bảo dưỡng dụng cụ</label>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="HUAN_LUYEN_VIEN_DV" class="w-4 h-4 accent-[#7c3aed]"/> Huấn luyện viên</label>
              <label class="flex items-center gap-2 text-xs text-slate-600"><input type="checkbox" value="DICH_VU_KHAC" class="w-4 h-4 accent-[#7c3aed]"/> Dịch vụ khác</label>
              <p class="text-[11px] text-slate-400 mt-1">Đây chỉ là mô tả nhu cầu đăng ký, chưa tạo dịch vụ công khai. Sau khi được duyệt, bạn sẽ cấu hình chi tiết trong khu vực Quản lý dịch vụ.</p>
            </div>
          </div>
          <script>
            document.addEventListener('DOMContentLoaded', function () {
              var toggle = document.getElementById('capDichVuTheThao');
              var opts = document.getElementById('dichVuTheThaoOptions');
              if (toggle && opts) {
                toggle.addEventListener('change', function () {
                  opts.classList.toggle('hidden', !toggle.checked);
                });
              }
            });
          </script>

          <div class="flex gap-3">
            <button type="button" onclick="goToStep2Back()" class="btn btn-outline flex-shrink-0 py-3.5">
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

  <!-- ================= FEATURES ================= -->
  <section class="block" id="features">
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow muted">/ Tính năng cốt lõi</p>
        <h2 class="h2">Ba giải pháp vận hành vượt trội.</h2>
        <p class="lead">Hệ thống tích hợp mọi công cụ cần thiết để tối ưu doanh thu và quản lý sân chơi hiệu quả.</p>
      </div>
      <div class="feature-grid">
        <div class="feature-card">
          <div class="ico"><span class="material-symbols-outlined">event_available</span></div>
          <h3>Đặt lịch thông minh</h3>
          <p>Giao diện đặt lịch trực quan, tránh trùng lịch trong 3 giây.</p>
        </div>
        <div class="feature-card">
          <div class="ico"><span class="material-symbols-outlined">groups</span></div>
          <h3>Quản lý Hội viên</h3>
          <p>Theo dõi gói tập, điểm danh tự động thông qua mã QR Code.</p>
        </div>
        <div class="feature-card">
          <div class="ico"><span class="material-symbols-outlined">monitoring</span></div>
          <h3>Báo cáo Doanh thu</h3>
          <p>Báo cáo thời gian thực, minh bạch biểu đồ doanh thu chi tiết.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= PROCESS ================= -->
  <section class="block" id="process" style="background:var(--paper-2)">
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow muted">/ Quy trình</p>
        <h2 class="h2">Bốn bước đơn giản. Hệ thống sẵn sàng vận hành.</h2>
      </div>
      <div class="process-grid">
        <div class="process-card">
          <div class="num">01</div>
          <h3>Đăng ký thông tin</h3>
          <p>Điền thông tin cơ bản về cơ sở của bạn chỉ trong 1 phút để khởi tạo tài khoản quản lý.</p>
        </div>
        <div class="process-card">
          <div class="num">02</div>
          <h3>Xác thực Email</h3>
          <p>Nhập mã bảo mật OTP gửi trực tiếp tới email của bạn để xác minh chủ quyền.</p>
        </div>
        <div class="process-card">
          <div class="num">03</div>
          <h3>Cấu hình sân</h3>
          <p>Khai báo môn thể thao, số lượng sân hiện có và khung giờ mở cửa hoạt động.</p>
        </div>
        <div class="process-card">
          <div class="num">04</div>
          <h3>Vận hành hệ thống</h3>
          <p>Sân của bạn lập tức hiển thị trên hệ sinh thái V-Sport để đón nhận lịch đặt sân đầu tiên.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= SOLUTION ================= -->
  <section class="block" id="solution">
    <div class="wrap solution-grid">
      <div class="solution-media">
        <img src="${pageContext.request.contextPath}/assets/images/owner/owner-hero-vsport.webp" alt="V-SPORT Sports Management Platform">
      </div>
      <div>
        <p class="eyebrow muted">/ Giải pháp quản lý</p>
        <h2 class="h2" style="margin-top:10px">Giải phóng thời gian. Tối ưu doanh thu cơ sở.</h2>
        <p class="lead" style="margin-top:14px">Không còn những cuốn sổ tay ghi chép hay file Excel phức tạp dễ sai sót. V-Sport mang lại giao diện tinh tế, dễ dàng làm quen trong vài phút và bảo mật dữ liệu chuẩn quốc tế.</p>
        <div class="ledger" style="margin-top:24px">
          <div><span>Thời gian thiết lập</span><span>Dưới 5 phút</span></div>
          <div><span>Nền tảng vận hành</span><span>Cloud &amp; Mobile</span></div>
          <div><span>Hỗ trợ kỹ thuật</span><span>24/7 Miễn phí</span></div>
        </div>
      </div>
    </div>
  </section>

  <!-- ================= QUOTE ================= -->
  <section class="block" style="padding-top:0">
    <div class="quote-band">
      <q>Từ khi dùng V-Sport, tôi không còn bị đau đầu vì trùng lịch đặt sân của khách nữa. Doanh thu tăng hơn 25% nhờ tối ưu các khung giờ trống.</q>
      <p class="who">— Anh Minh Tuấn · Chủ sân bóng Tân Bình</p>
    </div>
  </section>

  <!-- ================= MARQUEE ================= -->
  <section class="marquee" aria-hidden="true">
    <div class="mrow">
      <span>Bóng đá</span><span>Bóng rổ</span><span>Cầu lông</span><span>Tennis</span><span>Bóng chuyền</span><span>Billiards</span><span>Pickleball</span>
      <span>Bóng đá</span><span>Bóng rổ</span><span>Cầu lông</span><span>Tennis</span><span>Bóng chuyền</span><span>Billiards</span><span>Pickleball</span>
    </div>
  </section>

  <!-- ================= FINAL CTA ================= -->
  <section class="block">
    <div class="wrap">
      <div class="final-cta">
        <p class="eyebrow" style="color:#c4b5fd">/ Sẵn sàng đồng hành</p>
        <h2 style="margin-top:14px">Bắt đầu số hóa ngay hôm nay?</h2>
        <p>Đội ngũ chúng tôi sẽ liên hệ trong vòng 24 giờ để hỗ trợ bạn cấu hình hệ thống — miễn phí dùng thử 30 ngày, không ràng buộc hợp đồng dài hạn.</p>
        <a href="#begin" class="btn btn-primary" style="margin-top:24px;padding:14px 32px;font-size:1rem">Đăng ký cơ sở miễn phí</a>
      </div>
    </div>
  </section>

  <!-- ================= FOOTER ================= -->
  <footer class="foot">
    <div class="wrap">
      <div class="foot-top">
        <div>
          <a href="#" class="brand">V-SPORT<span style="color:var(--accent)">.</span></a>
          <p>Hệ thống quản lý thể thao hàng đầu. Đơn giản hóa quy trình vận hành và tối ưu doanh thu của bạn.</p>
        </div>
        <div class="foot-col"><h4>Tính năng</h4><a href="#features">Đặt lịch</a><a href="#features">Hội viên</a><a href="#features">Báo cáo</a></div>
        <div class="foot-col"><h4>Thông tin</h4><a href="#process">Quy trình</a><a href="#solution">Giải pháp</a></div>
        <div class="foot-col"><h4>Liên kết</h4><a href="#begin">Đăng ký đối tác</a><a href="${pageContext.request.contextPath}/index.jsp">Đăng nhập</a></div>
      </div>
      <div class="foot-bottom">
        <span>© 2026 V-Sport. Tất cả quyền được bảo lưu.</span>
        <span>Premium Sports Management.</span>
      </div>
    </div>
  </footer>

</main>

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
      <div class="grid grid-cols-2 gap-3" id="sportsGrid">
        <!-- Sports will be generated by JS -->
      </div>
    </div>
    <div class="p-6 border-t border-slate-100 flex justify-between items-center">
      <span class="text-sm text-slate-500">Đã chọn: <strong id="selectedSportsCount" class="text-[#7c3aed]">0</strong> môn</span>
      <button onclick="confirmSportsSelection()" class="btn btn-primary px-8 py-3">
        Xác nhận
      </button>
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
    .geo-coord-pill { display: inline-flex; align-items: center; gap: 6px; padding: 5px 12px; background: #7c3aed14; border: 1px solid #7c3aed30; border-radius: 999px; font-size: 12px; font-weight: 700; color: #6d28d9; }
  </style>
  <div id="geoModalBox" class="bg-white w-full sm:max-w-2xl rounded-t-3xl sm:rounded-3xl shadow-2xl flex flex-col" style="max-height:92vh;">
    <!-- Header -->
    <div class="flex items-center justify-between px-5 pt-5 pb-3 flex-shrink-0">
      <div class="flex items-center gap-2">
        <span class="material-symbols-outlined text-[#7c3aed] text-2xl">location_on</span>
        <h3 class="text-lg font-extrabold text-slate-900">Chọn vị trí cơ sở</h3>
      </div>
      <button type="button" onclick="closeGeoModal()" class="text-slate-400 hover:text-slate-700 transition-all bg-transparent border-none cursor-pointer p-1">
        <span class="material-symbols-outlined text-2xl">close</span>
      </button>
    </div>

    <!-- Search box -->
    <div class="px-5 pb-3 flex-shrink-0">
      <div class="geo-search-wrap">
        <input type="text" id="geoSearchInput" placeholder="Tìm địa chỉ hoặc tên cơ sở..."
          class="w-full px-4 py-2.5 border border-slate-200 rounded-xl text-sm focus:outline-none focus:border-[#7c3aed] transition-colors" autocomplete="off"/>
        <div id="geoSearchResults" class="geo-search-results hidden"></div>
      </div>
      <p class="text-xs text-slate-400 mt-2">Bấm vào bản đồ hoặc kéo điểm ghim để chọn vị trí chính xác.</p>
    </div>

    <!-- Map -->
    <div class="px-5 flex-shrink-0">
      <div id="geoMapEl"></div>
    </div>

    <!-- Coord preview + actions -->
    <div class="px-5 py-4 flex-shrink-0">
      <div id="geoCoordPill" class="geo-coord-pill mb-3 hidden">
        <span class="material-symbols-outlined text-[14px]">my_location</span>
        <span id="geoCoordText">—</span>
      </div>
      <div id="geoCoordNone" class="text-xs text-slate-400 mb-3">Chưa chọn vị trí — bấm vào bản đồ để ghim điểm.</div>
      <div class="flex gap-2">
        <button type="button" onclick="geoUseGps()" id="geoGpsBtn"
          class="flex-1 flex items-center justify-center gap-1.5 py-2.5 border border-slate-200 rounded-xl text-sm font-semibold text-slate-700 hover:border-[#7c3aed] hover:text-[#7c3aed] transition-all bg-white">
          <span class="material-symbols-outlined text-base">my_location</span> Vị trí hiện tại
        </button>
        <button type="button" onclick="geoConfirm()" id="geoConfirmBtn" disabled
          class="flex-1 flex items-center justify-center gap-1.5 py-2.5 rounded-xl text-sm font-bold text-white transition-all"
          style="background:#7c3aed; opacity:.4; cursor:not-allowed;">
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

    // Cờ do backend đặt khi JSP được forward lại kèm dữ liệu form (vd: lỗi validate).
    // Khi true, bản nháp trong sessionStorage KHÔNG được ghi đè lên dữ liệu backend trả về.
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
        // Update step indicators
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
    // STEP 1 -> STEP 2 (Send OTP)
    // ==========================================
    // ==========================================
    // GEO MAP MODAL
    // ==========================================
    let geoMap = null;
    let geoMarker = null;
    let geoPendingLat = null;
    let geoPendingLng = null;
    let geoSearchTimer = null;

    const GEO_DEFAULT = [16.047079, 108.206230]; // Đà Nẵng — trung tâm VN

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
        // Khởi tạo tại tọa độ đã lưu (nếu có) hoặc default
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

        // Nếu đã có tọa độ cũ, đặt marker sẵn
        if (savedLat && savedLng) {
            geoSetPin(savedLat, savedLng, false);
        }

        // Click bản đồ để ghim
        geoMap.on('click', function(e) {
            geoSetPin(e.latlng.lat, e.latlng.lng, true);
        });

        // Search input
        const inp = document.getElementById('geoSearchInput');
        inp.addEventListener('input', function() {
            clearTimeout(geoSearchTimer);
            const q = inp.value.trim();
            if (q.length < 3) { document.getElementById('geoSearchResults').classList.add('hidden'); return; }
            geoSearchTimer = setTimeout(function() { geoSearchAddress(q); }, 400);
        });
        inp.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeGeoModal(); });

        // Đóng search khi click ngoài
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
            html: '<div style="width:32px;height:32px;display:flex;align-items:center;justify-content:center;margin-left:-16px;margin-top:-32px"><svg viewBox="0 0 24 24" width="32" height="32" fill="#7c3aed" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg></div>',
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

        // Hiện tọa độ
        document.getElementById('geoCoordText').textContent = lat + ', ' + lng;
        document.getElementById('geoCoordPill').classList.remove('hidden');
        document.getElementById('geoCoordNone').classList.add('hidden');

        // Bật nút xác nhận
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
        const savedAddress = addrInput.value.trim(); // giữ lại nếu API lỗi
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
                    addrInput.value = savedAddress; // khôi phục, không alert
                }
                if (callback) callback();
            })
            .catch(() => {
                addrInput.disabled = false;
                addrInput.placeholder = originalPlaceholder;
                addrInput.value = savedAddress; // khôi phục địa chỉ cũ
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

        // Validate email format
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { showError('Email không hợp lệ.'); return; }

        // Validate phone format
        if (!/^(0|\+84)[35789][0-9]{8}$/.test(phone)) { showError('Số điện thoại không hợp lệ.'); return; }

        // Send OTP via AJAX
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
                // Focus first OTP box
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
        // Allow paste
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
        if (btn.disabled) return; // chống double-click / double-submit
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
                // Clear OTP boxes
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
        // Reset OTP fields
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
                '<div class="flex items-center gap-3 p-3 rounded-xl border border-slate-200 peer-checked:border-[#7c3aed] peer-checked:bg-[#7c3aed]/10 transition-all hover:bg-slate-50">' +
                    '<span class="material-symbols-outlined text-[22px] peer-checked:text-[#7c3aed] text-slate-400">' + sport.icon + '</span>' +
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

    // Make functions globally accessible so inline HTML event handlers can call them
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
            row.innerHTML = '<span class="material-symbols-outlined text-[#7c3aed] text-[22px]">' + sport.icon + '</span>' +
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

        // Collect operating days
        const days = [];
        document.querySelectorAll('#operatingDays input[type="checkbox"]:checked').forEach(cb => days.push(cb.value));
        if (days.length === 0) { showError('Vui lòng chọn ít nhất 1 ngày hoạt động.'); return; }

        // Collect court data
        const sportsData = [];
        document.querySelectorAll('.court-qty').forEach(input => {
            sportsData.push({ sport: input.dataset.sport, quantity: parseInt(input.value) || 1 });
        });

        // Collect selected business capabilities (optional — court rental itself is not a checkbox here)
        const capabilities = [];
        document.querySelectorAll('#capabilityList input[type="checkbox"]:checked').forEach(cb => capabilities.push(cb.value));

        // Build form data
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

    // Attach step transition functions to window so they are globally callable
    window.goToStep1 = goToStep1;
    window.goToStep2 = goToStep2;
    window.goToStep2Back = goToStep2Back;
    window.verifyOtp = verifyOtp;
    window.resendOtp = resendOtp;

    // URL param alerts
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

            // Build hour buttons 0-23
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

            // Build minute buttons
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

            // Scroll selected hour into view
            setTimeout(function() {
                const activeH = hCol.querySelector('.active');
                if (activeH) activeH.scrollIntoView({block: 'center'});
            }, 0);

            commit();
        }

        initVtp('openTimePicker',  '06:00');
        initVtp('closeTimePicker', '22:00');

        // Close on outside click
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
        // Update active states
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
        // Close all others
        document.querySelectorAll('.vtimepicker-wrap.open').forEach(function(w) { w.classList.remove('open'); });
        if (!isOpen) {
            wrap.classList.add('open');
            // Scroll selected hour into view after popup opens
            const activeH = document.getElementById(wrapId + '-hours').querySelector('.active');
            if (activeH) setTimeout(function() { activeH.scrollIntoView({block: 'center'}); }, 50);
        }
    };

    // ==========================================
    // BẢN NHÁP ĐĂNG KÝ (sessionStorage) — chống mất dữ liệu khi reload
    // ==========================================
    const OWNER_DRAFT_KEY = 'vsport_owner_registration_draft';
    const OWNER_DRAFT_TTL_MS = 2 * 60 * 60 * 1000; // 2 giờ
    const OWNER_DRAFT_VERSION = 1;

    // Debounce đơn giản: trì hoãn thực thi để không ghi sessionStorage liên tục
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

    // Thu thập dữ liệu KHÔNG nhạy cảm từ form hiện tại (không đọc OTP/password)
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
        } catch (e) {
            // sessionStorage có thể bị trình duyệt chặn (chế độ ẩn danh nghiêm ngặt...) — bỏ qua an toàn
        }
    }
    const debouncedSaveOwnerDraft = debounce(saveOwnerDraft, 400);

    function isDraftExpired(draft) {
        if (!draft || !draft.savedAt) return true;
        return (Date.now() - draft.savedAt) > OWNER_DRAFT_TTL_MS;
    }

    function clearOwnerDraft() {
        try { sessionStorage.removeItem(OWNER_DRAFT_KEY); } catch (e) { /* bỏ qua */ }
    }

    function loadOwnerDraft() {
        let raw;
        try {
            raw = sessionStorage.getItem(OWNER_DRAFT_KEY);
        } catch (e) {
            return null;
        }
        if (!raw) return null;

        let draft;
        try {
            draft = JSON.parse(raw);
        } catch (e) {
            clearOwnerDraft(); // JSON hỏng — xóa key để không lặp lại lỗi ở lần sau
            return null;
        }

        if (!draft || draft.version !== OWNER_DRAFT_VERSION || isDraftExpired(draft)) {
            clearOwnerDraft();
            return null;
        }

        // Nếu chỉ có 1 trong 2 giá trị tọa độ thì bỏ luôn cặp tọa độ lỗi, không restore
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

    // Điều hướng bước dùng khi khôi phục / reset — không kèm side-effect gửi OTP hay submit
    function goToRegistrationStep(step) {
        showStep(step);
    }

    // Đổ dữ liệu draft vào các input thật trên form (không đụng tới bước hiện tại / OTP)
    function restoreOwnerDraftFieldsToDom(draft) {
        const f = draft.fields || {};
        if (f.tenCoSo) document.getElementById('ownerName').value = f.tenCoSo;
        if (f.email) document.getElementById('regEmail').value = f.email;
        if (f.soDienThoai) document.getElementById('regPhone').value = f.soDienThoai;
        if (f.diaChi) document.getElementById('regAddress').value = f.diaChi;

        if (f.viDo && f.kinhDo) {
            document.getElementById('viDo').value = f.viDo;
            document.getElementById('kinhDo').value = f.kinhDo;
            setLocationCoords(f.viDo, f.kinhDo); // chỉ hiển thị lại preview, không gọi GPS/Nominatim
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

    // Gọi server để biết trạng thái OTP/xác thực THẬT (không bao giờ tin sessionStorage cho việc này)
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

    // Suy ra cooldown còn lại của nút "Gửi lại mã" (60s) từ thời gian OTP đã tồn tại (tối đa 5 phút)
    function applyResendCooldownFromOtpValidity(secondsRemainingOtpValidity) {
        const elapsedSinceSent = Math.max(0, 300 - (secondsRemainingOtpValidity || 0));
        const cooldownLeft = Math.max(0, 60 - elapsedSinceSent);
        startResendCountdown(cooldownLeft);
    }

    // Đối chiếu bước muốn khôi phục với trạng thái OTP thật trên server (CASE A/B/C)
    async function reconcileOtpState(candidateStep, emailForDisplay) {
        if (!candidateStep || candidateStep <= 1) {
            goToRegistrationStep(1);
            return;
        }

        const status = await fetchOwnerOtpStatus();

        if (status.emailVerified) {
            // CASE C — server xác nhận email đã verify, không bắt xác minh lại
            emailVerified = true;
            if (emailForDisplay) document.getElementById('otpEmailDisplay').textContent = emailForDisplay;
            goToRegistrationStep(3);
            return;
        }

        if (status.otpActive) {
            // CASE A — OTP server vẫn còn hiệu lực, không tự gửi lại
            document.getElementById('otpEmailDisplay').textContent = status.otpEmail || emailForDisplay || '';
            goToRegistrationStep(2);
            applyResendCooldownFromOtpValidity(status.secondsRemaining);
            showOtpValidityHint(status.secondsRemaining);
            return;
        }

        // CASE B — OTP hết hạn hoặc không còn phiên hợp lệ
        emailVerified = false;
        showError('Phiên xác thực đã hết hạn. Vui lòng gửi lại OTP.');
        goToRegistrationStep(1);
    }

    async function initOwnerRegistrationDraft() {
        if (window.ownerServerFormHasData) return; // ưu tiên dữ liệu backend, không ghi đè bằng draft cũ
        const draft = loadOwnerDraft();
        if (!draft) return;

        restoreOwnerDraftFieldsToDom(draft);
        await reconcileOtpState(draft.currentStep, draft.fields && draft.fields.email);
    }

    // Tự động lưu draft khi người dùng nhập/chọn (không gắn cho OTP box / file input)
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

    // Nút "Xóa bản nháp / Bắt đầu lại"
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

    // Khôi phục từ bfcache (nút back/forward trình duyệt): chỉ đồng bộ lại trạng thái OTP,
    // KHÔNG gửi lại OTP, KHÔNG submit lại — dữ liệu form đã được bfcache giữ nguyên.
    window.addEventListener('pageshow', function(e) {
        if (e.persisted && currentStep > 1) {
            reconcileOtpState(currentStep, ownerDraftGetVal('regEmail'));
        }
    });
</script>

</body>
</html>
