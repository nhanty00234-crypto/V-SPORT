import { getCurrentUser } from '@/lib/api/auth'
import { getCustomerProfile } from '@/lib/api/customer'
import { redirect } from 'next/navigation'
import CustomerNavbar from '@/components/customer/layout/CustomerNavbar'
import BottomNav from '@/components/customer/layout/BottomNav'

export default async function CustomerLayout({ children }: { children: React.ReactNode }) {
  const auth = await getCurrentUser()
  if (!auth) redirect('/dang-nhap')

  const profile = await getCustomerProfile()

  return (
    <div className="min-h-screen bg-slate-50">
      {profile && <CustomerNavbar user={profile} />}
      <main className="pb-16 md:pb-0">{children}</main>
      <BottomNav />
    </div>
  )
}
