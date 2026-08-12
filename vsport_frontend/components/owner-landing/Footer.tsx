import Link from 'next/link'

export default function Footer() {
  return (
    <footer id="lien-he" className="bg-vs-navy border-t border-white/10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid md:grid-cols-3 gap-8 mb-8">
          <div>
            <p className="text-white font-bold text-xl mb-3">
              V-<span className="text-vs-cyan">SPORT</span>
            </p>
            <p className="text-slate-400 text-sm leading-relaxed">
              Nền tảng quản lý và đặt sân thể thao hàng đầu Việt Nam.
            </p>
          </div>

          <div>
            <p className="text-white font-semibold mb-4">Sản phẩm</p>
            <ul className="space-y-2 text-sm text-slate-400">
              <li><a href="#tinh-nang" className="hover:text-white transition-colors">Tính năng</a></li>
              <li><a href="#thong-ke" className="hover:text-white transition-colors">Thống kê</a></li>
              <li><Link href="/owner-register" className="hover:text-white transition-colors">Đăng ký đối tác</Link></li>
            </ul>
          </div>

          <div>
            <p className="text-white font-semibold mb-4">Liên hệ</p>
            <ul className="space-y-2 text-sm text-slate-400">
              <li>Email: support@vsport.vn</li>
              <li>Hotline: 1800 xxxx</li>
              <li>TP. Hồ Chí Minh, Việt Nam</li>
            </ul>
          </div>
        </div>

        <div className="border-t border-white/10 pt-6 text-center text-slate-500 text-xs">
          © {new Date().getFullYear()} V-Sport. All rights reserved.
        </div>
      </div>
    </footer>
  )
}
