// Duplicate marquee content so the loop is seamless
const track = document.querySelector('.marquee-track');
if (track) {
    track.innerHTML += track.innerHTML;
}

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
