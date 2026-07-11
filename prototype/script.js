// Duplicate marquee content so the loop is seamless
const track = document.querySelector('.marquee-track');
if (track) {
    track.innerHTML += track.innerHTML;
}

// Testimonials slider
const testimonials = [
    {
        name: 'NGUYỄN VĂN AN',
        location: 'Hà Nội, Việt Nam',
        avatar: 'https://i.pravatar.cc/80?img=11',
        quote: ['V-SPORT mang đến giải pháp đặt sân thể thao nhanh chóng, tin cậy và tiện lợi. Với hệ thống đối tác sân bãi rộng khắp toàn quốc cùng quy trình thanh toán tích hợp PayOS thông minh, bạn có thể tự tin đặt lịch giữ chỗ.', 'Trải nghiệm những trận đấu thắng hoa cùng bạn bè, gia đình — mọi lúc, mọi nơi, chỉ với vài thao tác đơn giản trên V-SPORT.']
    },
    {
        name: 'TRẦN THỊ BÍCH',
        location: 'TP. Hồ Chí Minh, Việt Nam',
        avatar: 'https://i.pravatar.cc/80?img=5',
        quote: ['Đặt sân trên V-SPORT cực kỳ đơn giản, chỉ mất vài phút là xong. Giao diện thân thiện, thanh toán PayOS an toàn và xác nhận tức thì.', 'Tôi đã giới thiệu cho cả nhóm bạn cùng dùng và ai cũng hài lòng với trải nghiệm đặt sân tiện lợi này.']
    },
    {
        name: 'LÊ MINH TUẤN',
        location: 'Đà Nẵng, Việt Nam',
        avatar: 'https://i.pravatar.cc/80?img=3',
        quote: ['Ứng dụng V-SPORT giúp tôi tiết kiệm rất nhiều thời gian khi đặt sân cầu lông cuối tuần. Hệ thống luôn cập nhật lịch sân theo thời gian thực.', 'Dịch vụ hỗ trợ khách hàng nhiệt tình, chuyên nghiệp. Rất đáng để trải nghiệm!']
    }
];
let testiIndex = 0;

function goToTesti(idx) {
    testiIndex = (idx + testimonials.length) % testimonials.length;
    const t = testimonials[testiIndex];

    const nameEl = document.getElementById('testiName');
    const locEl = document.getElementById('testiLocation');
    const quoteEl = document.getElementById('testiQuote');
    const dotsEl = document.getElementById('testiDots');
    const avatarBtns = document.querySelectorAll('.testi-avatar-btn');

    if (nameEl) nameEl.textContent = t.name;
    if (locEl) locEl.textContent = t.location;
    if (quoteEl) {
        quoteEl.innerHTML = t.quote.map(p => `<p>${p}</p>`).join('');
    }
    if (dotsEl) {
        [...dotsEl.children].forEach((d, i) => d.classList.toggle('testi-dot--active', i === testiIndex));
    }
    avatarBtns.forEach((btn, i) => {
        btn.classList.toggle('is-active', i === testiIndex);
        const badge = btn.querySelector('.testi-quote-badge');
        if (badge) badge.style.display = i === testiIndex ? '' : 'none';
    });
}

document.getElementById('testiPrev')?.addEventListener('click', () => goToTesti(testiIndex - 1));
document.getElementById('testiNext')?.addEventListener('click', () => goToTesti(testiIndex + 1));
document.getElementById('testiAvatars')?.addEventListener('click', e => {
    const btn = e.target.closest('.testi-avatar-btn');
    if (btn) goToTesti(Number(btn.dataset.index));
});

// Scroll-triggered reveal
const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const revealEls = document.querySelectorAll('.reveal');

if (reduceMotion || !('IntersectionObserver' in window)) {
    revealEls.forEach(el => el.classList.add('is-visible'));
} else {
    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.15 });

    revealEls.forEach(el => {
        const delay = el.style.getPropertyValue('--reveal-delay');
        if (delay) el.style.transitionDelay = delay;
        observer.observe(el);
    });
}
