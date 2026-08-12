import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import ReputationClient from '@/components/customer/account/ReputationClient'

export const metadata = { title: 'Điểm uy tín | V-SPORT' }

export default function DiemUyTinPage() {
  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <ReputationClient />
      </div>
    </div>
  )
}
