import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'
import AdminSidebar from '@/components/admin/layout/AdminSidebar'
import AdminTopbar from '@/components/admin/layout/AdminTopbar'

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'ADMIN') redirect('/dang-nhap')
  return (
    <div className="min-h-screen bg-slate-50">
      <AdminSidebar />
      <AdminTopbar user={user} />
      <main className="lg:ml-[260px] mt-16 p-4 lg:p-6">
        {children}
      </main>
    </div>
  )
}
