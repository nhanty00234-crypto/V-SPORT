import Link from 'next/link'
import { CheckCircle, ArrowLeft } from 'lucide-react'
import RegisterHeader from './RegisterHeader'

export default function SuccessPageClient() {
  return (
    <>
      <RegisterHeader currentStep={3} />
      <main className="min-h-[80vh] flex flex-col items-center justify-center px-4 py-16 text-center">
        <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
          <CheckCircle className="w-10 h-10 text-green-600" />
        </div>

        <h1 className="text-3xl font-bold text-vs-navy mb-3">Đăng ký thành công!</h1>

        <p className="text-vs-slate text-base max-w-md mb-2">
          Chúng tôi đã nhận được thông tin của bạn. Admin V-Sport sẽ xem xét và duyệt hồ
          sơ trong vòng <strong>1-3 ngày làm việc</strong>.
        </p>
        <p className="text-vs-slate text-sm max-w-md mb-10">
          Sau khi được duyệt, bạn sẽ nhận thông báo qua email và có thể đăng nhập để quản
          lý cơ sở.
        </p>

        <Link
          href="/owner"
          className="inline-flex items-center gap-2 bg-vs-blue hover:bg-vs-navy text-white font-semibold px-8 py-3.5 rounded-xl transition-colors"
        >
          <ArrowLeft className="w-4 h-4" /> Về trang chủ
        </Link>
      </main>
    </>
  )
}
