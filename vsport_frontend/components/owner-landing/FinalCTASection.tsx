import Link from 'next/link'
import { ArrowRight } from 'lucide-react'

interface Props {
  onOpenContact: () => void
}

export default function FinalCTASection({ onOpenContact }: Props) {
  return (
    <section className="py-24 bg-gradient-to-br from-vs-navy via-[#1e3a5f] to-vs-blue">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h2 className="text-3xl sm:text-4xl font-extrabold text-white mb-4">
          Sẵn sàng đưa sân của bạn lên V-Sport?
        </h2>
        <p className="text-slate-300 text-lg mb-10 max-w-2xl mx-auto">
          Đăng ký miễn phí hôm nay. Cài đặt trong 15 phút, bắt đầu nhận booking ngay lập tức.
        </p>

        <div className="flex flex-wrap justify-center gap-4">
          <Link
            href="/owner-register"
            className="inline-flex items-center gap-2 bg-vs-cyan hover:bg-cyan-400 text-vs-navy font-bold px-8 py-4 rounded-xl transition-all duration-200 shadow-lg hover:-translate-y-0.5"
          >
            Đăng ký ngay
            <ArrowRight className="w-5 h-5" />
          </Link>

          <button
            onClick={onOpenContact}
            className="inline-flex items-center border-2 border-white/40 hover:border-white text-white font-semibold px-8 py-4 rounded-xl transition-all duration-200 hover:bg-white/5"
          >
            Liên hệ tư vấn
          </button>
        </div>
      </div>
    </section>
  )
}
