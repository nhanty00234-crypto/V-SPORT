import { BookOpen, Banknote, BarChart2 } from 'lucide-react'

const PAIN_POINTS = [
  {
    icon: BookOpen,
    title: 'Quản lý lịch bằng sổ tay',
    description: 'Ghi chép thủ công dễ nhầm lẫn, đặt trùng giờ, khó theo dõi lịch sử. Mỗi ngày mất hàng giờ chỉ để sắp xếp lịch.',
  },
  {
    icon: Banknote,
    title: 'Thu tiền thủ công, dễ thất thoát',
    description: 'Nhận tiền mặt không có hóa đơn, khó đối soát, nhân viên dễ sai sót. Không biết doanh thu thực tế là bao nhiêu.',
  },
  {
    icon: BarChart2,
    title: 'Không nắm được hiệu suất sân',
    description: 'Không biết giờ nào sân đông, giờ nào vắng. Không có dữ liệu để điều chỉnh giá hoặc chạy khuyến mãi hiệu quả.',
  },
]

export default function PainPointsSection() {
  return (
    <section className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Bạn đang gặp những vấn đề này?
          </h2>
          <p className="text-vs-slate text-lg max-w-2xl mx-auto">
            Hầu hết chủ sân thể thao đều gặp phải những khó khăn chung khi vận hành thủ công.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {PAIN_POINTS.map((point) => {
            const Icon = point.icon
            return (
              <article
                key={point.title}
                className="group bg-slate-50 hover:bg-red-50 border border-slate-100 hover:border-red-100 rounded-2xl p-8 transition-all duration-300"
              >
                <div className="w-12 h-12 bg-red-100 group-hover:bg-red-200 rounded-xl flex items-center justify-center mb-5 transition-colors">
                  <Icon className="w-6 h-6 text-red-500" />
                </div>
                <h3 className="text-lg font-bold text-vs-navy mb-3">{point.title}</h3>
                <p className="text-vs-slate text-sm leading-relaxed">{point.description}</p>
              </article>
            )
          })}
        </div>
      </div>
    </section>
  )
}
