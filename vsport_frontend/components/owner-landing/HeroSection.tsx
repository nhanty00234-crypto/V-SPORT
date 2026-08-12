import Link from 'next/link'
import { ArrowRight, ChevronDown } from 'lucide-react'

interface Props {
  onOpenContact: () => void
}

export default function HeroSection({ onOpenContact }: Props) {
  return (
    <section className="relative min-h-screen flex items-center bg-gradient-to-br from-vs-navy via-[#1e3a5f] to-vs-blue overflow-hidden">
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/4 right-1/4 w-96 h-96 bg-vs-cyan/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-1/4 w-64 h-64 bg-vs-blue/20 rounded-full blur-3xl" />
      </div>

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-24 pb-16">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          <div>
            <span className="inline-flex items-center gap-2 bg-vs-cyan/10 border border-vs-cyan/30 text-vs-cyan text-sm font-medium px-3 py-1 rounded-full mb-6">
              Nền tảng quản lý sân thể thao #1 Việt Nam
            </span>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-white leading-tight mb-6">
              Đưa sân thể thao của bạn{' '}
              <span className="text-vs-cyan">lên tầm cao mới</span>
            </h1>

            <p className="text-lg text-slate-300 mb-8 max-w-lg">
              Quản lý lịch đặt, thu tiền tự động, phân tích doanh thu — tất cả trong một nền tảng.
              Tham gia cùng hàng trăm chủ sân đang phát triển với V-Sport.
            </p>

            <div className="flex flex-wrap gap-4">
              <Link
                href="/owner-register"
                className="inline-flex items-center gap-2 bg-vs-blue hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-xl transition-all duration-200 shadow-lg hover:-translate-y-0.5"
              >
                Đăng ký ngay
                <ArrowRight className="w-4 h-4" />
              </Link>

              <button
                onClick={onOpenContact}
                className="inline-flex items-center gap-2 border border-white/30 hover:border-white/60 text-white font-semibold px-6 py-3 rounded-xl transition-all duration-200 hover:bg-white/5"
              >
                Liên hệ tư vấn
              </button>
            </div>
          </div>

          <div className="hidden lg:flex justify-center">
            <div className="w-full max-w-md bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl p-6 shadow-2xl">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-3 h-3 rounded-full bg-red-400" />
                <div className="w-3 h-3 rounded-full bg-yellow-400" />
                <div className="w-3 h-3 rounded-full bg-green-400" />
                <span className="ml-2 text-white/60 text-xs">V-Sport Dashboard</span>
              </div>
              <div className="space-y-3">
                {[
                  { label: 'Lịch đặt hôm nay', value: '24 lượt', color: 'bg-vs-blue' },
                  { label: 'Doanh thu tháng', value: '18.5M ₫', color: 'bg-vs-cyan' },
                  { label: 'Sân đang hoạt động', value: '8/10 sân', color: 'bg-green-400' },
                ].map((item) => (
                  <div key={item.label} className="bg-white/5 rounded-lg p-3 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-2 h-8 rounded-full ${item.color}`} />
                      <span className="text-white/80 text-sm">{item.label}</span>
                    </div>
                    <span className="text-white font-semibold text-sm">{item.value}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
        <ChevronDown className="w-6 h-6 text-white/40" />
      </div>
    </section>
  )
}
