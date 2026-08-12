import { CheckCircle2 } from 'lucide-react'

const SOLUTIONS = [
  'Lịch đặt sân trực quan, real-time, không bao giờ trùng giờ',
  'Thanh toán QR tự động — tiền về tài khoản ngay lập tức',
  'Báo cáo doanh thu theo ngày, tuần, tháng ngay trên dashboard',
  'Khuyến mãi linh hoạt để giữ chân khách hàng thường xuyên',
  'App mobile giúp khách đặt sân 24/7 — tăng lượng booking',
]

export default function SolutionSection() {
  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          <div className="order-2 lg:order-1">
            <div className="bg-gradient-to-br from-vs-navy to-vs-blue rounded-3xl p-8 shadow-2xl">
              <div className="text-center mb-6">
                <span className="text-vs-cyan font-semibold text-sm uppercase tracking-wider">
                  V-Sport Platform
                </span>
              </div>
              <div className="space-y-4">
                {[
                  { label: 'Quản lý lịch đặt', pct: 95 },
                  { label: 'Doanh thu tháng này', pct: 78 },
                  { label: 'Tỷ lệ lấp đầy sân', pct: 88 },
                ].map((bar) => (
                  <div key={bar.label}>
                    <div className="flex justify-between text-sm text-white/80 mb-1">
                      <span>{bar.label}</span>
                      <span>{bar.pct}%</span>
                    </div>
                    <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                      <div className="h-full bg-vs-cyan rounded-full" style={{ width: `${bar.pct}%` }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="order-1 lg:order-2">
            <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
              V-Sport giải quyết tất cả —{' '}
              <span className="text-vs-blue">trong một nền tảng</span>
            </h2>
            <p className="text-vs-slate text-lg mb-8">
              Không cần nhiều công cụ rời rạc. V-Sport tích hợp toàn bộ nghiệp vụ quản lý sân
              thể thao vào một hệ thống duy nhất, dễ dùng.
            </p>
            <ul className="space-y-4">
              {SOLUTIONS.map((item) => (
                <li key={item} className="flex items-start gap-3">
                  <CheckCircle2 className="w-5 h-5 text-vs-blue mt-0.5 shrink-0" />
                  <span className="text-vs-navy font-medium">{item}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  )
}
