import { Calendar, QrCode, TrendingUp, Gift, Smartphone } from 'lucide-react'
import FeatureCard from './FeatureCard'

const FEATURES = [
  {
    icon: Calendar,
    title: 'Quản lý lịch đặt trực quan',
    description: 'Xem toàn bộ lịch đặt sân theo ngày, tuần trên một màn hình. Cập nhật real-time, không bao giờ trùng giờ.',
  },
  {
    icon: QrCode,
    title: 'Thanh toán QR & PayOS',
    description: 'Khách quét QR, tiền vào tài khoản ngay lập tức. Hỗ trợ tất cả ngân hàng Việt Nam, hoàn toàn tự động.',
  },
  {
    icon: TrendingUp,
    title: 'Báo cáo doanh thu',
    description: 'Dashboard phân tích doanh thu theo giờ, ngày, tháng. Biết chính xác khung giờ nào đông để tối ưu giá.',
  },
  {
    icon: Gift,
    title: 'Khuyến mãi thông minh',
    description: 'Tạo mã giảm giá, ưu đãi giờ thấp điểm, chương trình khách hàng thân thiết — chỉ vài bước đơn giản.',
  },
  {
    icon: Smartphone,
    title: 'App mobile cho khách hàng',
    description: 'Khách hàng đặt sân qua app V-Sport 24/7. Tăng lượng booking mà không cần thêm nhân sự tiếp nhận.',
  },
]

export default function FeaturesSection() {
  return (
    <section id="tinh-nang" className="py-24 bg-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Mọi thứ bạn cần để vận hành sân chuyên nghiệp
          </h2>
          <p className="text-vs-slate text-lg max-w-2xl mx-auto">
            5 tính năng cốt lõi được thiết kế dành riêng cho chủ sân thể thao Việt Nam.
          </p>
        </div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURES.map((feature) => (
            <FeatureCard key={feature.title} {...feature} />
          ))}
        </div>
      </div>
    </section>
  )
}
