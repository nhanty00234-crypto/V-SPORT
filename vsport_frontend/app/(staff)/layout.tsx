import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'
import StaffSidebar from '@/components/staff/layout/StaffSidebar'
import StaffTopbar from '@/components/staff/layout/StaffTopbar'

export default async function StaffLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'STAFF') redirect('/dang-nhap')
  return (
    <div className="min-h-screen bg-slate-100">
      <StaffSidebar />
      <StaffTopbar user={user} />
      <main className="lg:ml-[248px] mt-16 p-4 lg:p-6">
        {children}
      </main>
    </div>
  )
}
