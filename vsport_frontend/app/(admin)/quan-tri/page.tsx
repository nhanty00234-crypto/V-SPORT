import { getAdminDashboard } from '@/lib/api/admin'
import AdminDashboardClient from '@/components/admin/AdminDashboardClient'

export const metadata = { title: 'Quản trị | V-SPORT Admin' }

export default async function AdminDashboardPage() {
  const stats = await getAdminDashboard()

  if (!stats) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="text-4xl mb-3">⚠️</div>
          <p className="text-slate-600 font-medium">Không thể tải dữ liệu dashboard.</p>
          <p className="text-sm text-slate-400 mt-1">Vui lòng thử lại sau.</p>
        </div>
      </div>
    )
  }

  return <AdminDashboardClient stats={stats} />
}
