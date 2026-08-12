'use client'

import useEmblaCarousel from 'embla-carousel-react'
import { useCallback } from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { Testimonial } from '@/types/owner-landing'
import TestimonialCard from './TestimonialCard'

const TESTIMONIALS: Testimonial[] = [
  {
    id: 1,
    ownerName: 'Nguyễn Văn Hùng',
    facilityName: 'Sân cầu lông Hoàng Anh',
    avatarUrl: '',
    content: 'Kể từ khi dùng V-Sport, lượng đặt sân tăng gấp đôi. Quản lý lịch rất dễ, thanh toán tự động, không cần thu tiền mặt nữa.',
    rating: 5,
  },
  {
    id: 2,
    ownerName: 'Trần Thị Mai',
    facilityName: 'Trung tâm thể thao Mai Linh',
    avatarUrl: '',
    content: 'Báo cáo doanh thu rõ ràng theo từng ngày, giờ. Tôi biết chính xác khung giờ nào đông để tối ưu giá và chạy khuyến mãi.',
    rating: 5,
  },
  {
    id: 3,
    ownerName: 'Lê Minh Tuấn',
    facilityName: 'CLB Bóng đá Phú Nhuận',
    avatarUrl: '',
    content: 'Tính năng QR code sân giúp khách tự đặt dịch vụ mà không cần nhân viên can thiệp. Tiết kiệm được 2 nhân sự xử lý đơn.',
    rating: 5,
  },
]

export default function TestimonialsSection() {
  const [emblaRef, emblaApi] = useEmblaCarousel({ loop: true, align: 'start' })

  const scrollPrev = useCallback(() => emblaApi?.scrollPrev(), [emblaApi])
  const scrollNext = useCallback(() => emblaApi?.scrollNext(), [emblaApi])

  return (
    <section className="py-24 bg-slate-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-vs-navy mb-4">
            Chủ sân nói gì về V-Sport?
          </h2>
          <p className="text-vs-slate text-lg">
            Hơn 200 chủ cơ sở đang tin tưởng dùng V-Sport mỗi ngày.
          </p>
        </div>

        <div>
          <div ref={emblaRef} className="overflow-hidden">
            <div className="flex gap-6">
              {TESTIMONIALS.map((t) => (
                <div
                  key={t.id}
                  className="flex-none w-full sm:w-[calc(50%-12px)] lg:w-[calc(33.333%-16px)]"
                >
                  <TestimonialCard testimonial={t} />
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-center gap-3 mt-8">
            <button
              onClick={scrollPrev}
              className="w-10 h-10 rounded-full border border-slate-200 hover:border-vs-blue hover:text-vs-blue flex items-center justify-center transition-colors"
              aria-label="Testimonial trước"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={scrollNext}
              className="w-10 h-10 rounded-full border border-slate-200 hover:border-vs-blue hover:text-vs-blue flex items-center justify-center transition-colors"
              aria-label="Testimonial tiếp"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}
