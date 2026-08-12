import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import NotificationSettingsClient from '@/components/customer/account/NotificationSettingsClient'

export const metadata = { title: 'Cài đặt thông báo | V-SPORT' }

export default function CaiDatPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h1 className="text-lg font-bold text-vs-navy mb-2">Cài đặt thông báo</h1>
          <p className="text-sm text-vs-slate mb-6">Quản lý các loại thông báo bạn muốn nhận.</p>
          <NotificationSettingsClient initialMarketing={true} />
        </div>
      </div>
    </div>
  )
}
