'use client'
import { AdminDashboardStats } from '@/types/admin'

const ROLE_LABELS: Record<number, { label: string; color: string }> = {
  1: { label: 'Admin', color: 'bg-red-100 text-red-700' },
  2: { label: 'Manager', color: 'bg-indigo-100 text-indigo-700' },
  3: { label: 'Khách hàng', color: 'bg-sky-100 text-sky-700' },
  4: { label: 'Lễ tân', color: 'bg-orange-100 text-orange-700' },
  5: { label: 'Nhân viên', color: 'bg-amber-100 text-amber-700' },
  6: { label: 'Owner', color: 'bg-violet-100 text-violet-700' },
}

interface Props {
  stats: AdminDashboardStats
}

export default function AdminDashboardClient({ stats }: Props) {
  const userCards = [
    { label: 'Tổng tài khoản', value: stats.totalAccounts, icon: '👥', color: 'text-slate-800', bg: 'bg-slate-50', border: 'border-slate-200' },
    { label: 'Owner', value: stats.totalOwners, icon: '👑', color: 'text-violet-700', bg: 'bg-violet-50', border: 'border-violet-200' },
    { label: 'Quản lý', value: stats.totalManagers, icon: '🏢', color: 'text-indigo-700', bg: 'bg-indigo-50', border: 'border-indigo-200' },
    { label: 'Lễ tân / NV', value: stats.totalStaff, icon: '👤', color: 'text-orange-700', bg: 'bg-orange-50', border: 'border-orange-200' },
    { label: 'Khách hàng', value: stats.totalCustomers, icon: '🙋', color: 'text-sky-700', bg: 'bg-sky-50', border: 'border-sky-200' },
    {
      label: 'Chi nhánh',
      value: `${stats.activeBranches}/${stats.totalBranches}`,
      icon: '🏪',
      color: 'text-emerald-700',
      bg: 'bg-emerald-50',
      border: 'border-emerald-200',
    },
  ]

  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-2xl p-6 text-white shadow-lg">
        <p className="text-blue-200 text-xs font-semibold mb-1">Quản trị hệ thống</p>
        <h2 className="text-2xl font-black">Tổng quan V-SPORT Platform</h2>
        <p className="text-blue-200 text-sm mt-1">
          {stats.activeBranches} chi nhánh đang hoạt động · {stats.totalAccounts} tài khoản
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        {userCards.map(c => (
          <div key={c.label} className={`${c.bg} ${c.border} border rounded-2xl p-4`}>
            <div className="text-xl mb-2">{c.icon}</div>
            <p className={`text-2xl font-black ${c.color}`}>{c.value}</p>
            <p className="text-[11px] font-semibold text-slate-600 mt-0.5">{c.label}</p>
          </div>
        ))}
      </div>

      {/* Quick links */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { href: '/quan-tri/chi-nhanh', icon: '🏢', label: 'Chi nhánh', desc: 'Quản lý cơ sở & phê duyệt' },
          { href: '/quan-tri/owner', icon: '👑', label: 'Owner', desc: 'Xem & duyệt đăng ký Owner' },
          { href: '/quan-tri/nhan-su', icon: '👤', label: 'Nhân sự', desc: 'Toàn bộ người dùng hệ thống' },
          { href: '/quan-tri/audit-log', icon: '📋', label: 'Audit Log', desc: 'Nhật ký thao tác hệ thống' },
        ].map(item => (
          <a
            key={item.href}
            href={item.href}
            className="bg-white border border-slate-200 rounded-xl p-4 hover:border-blue-300 hover:shadow-sm transition-all group"
          >
            <div className="text-xl mb-2">{item.icon}</div>
            <p className="text-sm font-bold text-slate-700 group-hover:text-blue-700">{item.label}</p>
            <p className="text-[11px] text-slate-400 mt-0.5">{item.desc}</p>
          </a>
        ))}
      </div>

      {/* Recent accounts */}
      {stats.recentAccounts.length > 0 && (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="font-bold text-slate-800">Tài khoản mới nhất</h3>
            <a href="/quan-tri/nhan-su" className="text-xs text-blue-600 hover:underline font-medium">Xem tất cả →</a>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs">
                <tr>
                  <th className="px-5 py-3 text-left font-semibold">ID</th>
                  <th className="px-5 py-3 text-left font-semibold">Họ tên</th>
                  <th className="px-5 py-3 text-left font-semibold">Email</th>
                  <th className="px-5 py-3 text-left font-semibold">Vai trò</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {stats.recentAccounts.map(acc => {
                  const role = ROLE_LABELS[acc.roleId] ?? { label: `Role ${acc.roleId}`, color: 'bg-slate-100 text-slate-600' }
                  return (
                    <tr key={acc.id} className="hover:bg-slate-50 transition-colors">
                      <td className="px-5 py-3 font-mono text-xs text-slate-500">#{acc.id}</td>
                      <td className="px-5 py-3 font-medium text-slate-800">{acc.fullName || '—'}</td>
                      <td className="px-5 py-3 text-slate-500 text-xs">{acc.email || '—'}</td>
                      <td className="px-5 py-3">
                        <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${role.color}`}>
                          {role.label}
                        </span>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
