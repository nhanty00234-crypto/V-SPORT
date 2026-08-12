import { getDashboardStats } from '@/lib/api/manager'
import DashboardClient from '@/components/manager/DashboardClient'

export const metadata = { title: 'Dashboard | V-SPORT Quản lý' }

export default async function ManagerDashboardPage() {
  const stats = await getDashboardStats()

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

  return <DashboardClient stats={stats} />
}
