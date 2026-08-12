import { Suspense } from 'react'
import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import BookingHistoryClient from '@/components/customer/account/BookingHistoryClient'

export const metadata = { title: 'Lịch sử đặt sân | V-SPORT' }

export default function LichSuPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <h1 className="text-lg font-bold text-vs-navy mb-4">Lịch sử đặt sân</h1>
        <Suspense fallback={<div className="text-vs-slate text-sm">Đang tải...</div>}>
          <BookingHistoryClient />
        </Suspense>
      </div>
    </div>
  )
}
