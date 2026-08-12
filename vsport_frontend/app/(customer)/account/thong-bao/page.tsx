import { Suspense } from 'react'
import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import NotificationsClient from '@/components/customer/account/NotificationsClient'

export const metadata = { title: 'Thông báo | V-SPORT' }

export default function ThongBaoPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <h1 className="text-lg font-bold text-vs-navy mb-4">Thông báo</h1>
        <Suspense fallback={<div className="text-vs-slate text-sm">Đang tải...</div>}>
          <NotificationsClient />
        </Suspense>
      </div>
    </div>
  )
}
