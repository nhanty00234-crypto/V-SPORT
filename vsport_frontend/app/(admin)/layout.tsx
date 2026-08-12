import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'ADMIN') redirect('/dang-nhap')
  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* AdminSidebar sẽ được thêm vào Phase 5 */}
      <main className="flex-1 p-6">{children}</main>
    </div>
  )
}
