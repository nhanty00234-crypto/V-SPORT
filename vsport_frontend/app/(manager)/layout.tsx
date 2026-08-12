import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'
import ManagerSidebar from '@/components/manager/layout/ManagerSidebar'
import ManagerTopbar from '@/components/manager/layout/ManagerTopbar'

export default async function ManagerLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'MANAGER') redirect('/dang-nhap')
  return (
    <div className="min-h-screen bg-slate-100">
      <ManagerSidebar />
      <ManagerTopbar user={user} />
      <main className="lg:ml-[248px] mt-16 p-4 lg:p-6">
        {children}
      </main>
    </div>
  )
}
