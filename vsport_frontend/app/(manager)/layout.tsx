import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function ManagerLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user || user.role !== 'MANAGER') redirect('/dang-nhap')
  return (
    <div className="flex min-h-screen bg-slate-100">
      {/* ManagerSidebar sẽ được thêm vào Phase 3 */}
      <main className="flex-1 p-6">{children}</main>
    </div>
  )
}
