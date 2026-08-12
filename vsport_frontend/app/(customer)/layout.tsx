import { getCurrentUser } from '@/lib/api/auth'
import { redirect } from 'next/navigation'

export default async function CustomerLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser()
  if (!user) redirect('/dang-nhap')
  return (
    <div className="min-h-screen bg-slate-50">
      {/* CustomerNavbar và BottomNav sẽ được thêm vào Phase 2 */}
      <main className="pb-20 md:pb-0">{children}</main>
    </div>
  )
}
