import AccountSidebar from '@/components/customer/layout/AccountSidebar'
import ProfileForm from '@/components/customer/account/ProfileForm'
import { getCustomerProfile } from '@/lib/api/customer'
import { redirect } from 'next/navigation'

export const metadata = { title: 'Hồ sơ | V-SPORT' }

export default async function HoSoPage() {
  const profile = await getCustomerProfile()
  if (!profile) redirect('/dang-nhap')

  return (
    <div className="max-w-5xl mx-auto px-4 py-6 flex gap-6">
      <AccountSidebar />
      <div className="flex-1">
        <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-6">
          <h1 className="text-lg font-bold text-vs-navy mb-6">Hồ sơ cá nhân</h1>
          <ProfileForm profile={profile} />
        </div>
      </div>
    </div>
  )
}
