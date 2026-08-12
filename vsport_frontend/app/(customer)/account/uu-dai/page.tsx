import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import Link from 'next/link'

export const metadata = { title: 'Ưu đãi của tôi | V-SPORT' }

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

export default function UuDaiPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h1 className="text-lg font-bold text-vs-navy mb-4">Ưu đãi của tôi</h1>
          <div className="text-center py-10">
            <div className="text-5xl mb-4">🎁</div>
            <p className="text-vs-slate text-sm mb-6">
              Xem tất cả ưu đãi và voucher dành cho bạn tại trang quản lý ưu đãi.
            </p>
            <a
              href={`${BASE}/customer/uu-dai`}
              target="_blank"
              rel="noopener"
              className="inline-block px-6 py-2.5 bg-vs-blue text-white font-semibold text-sm rounded-lg hover:bg-blue-700 transition-colors"
            >
              Xem ưu đãi của tôi
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}
