'use client'
import { DashboardStats } from '@/types/manager'

function fmt(n: number) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + ' tr'
  if (n >= 1_000) return (n / 1_000).toFixed(0) + 'k'
  return n.toString()
}

function fmtVnd(n: number) {
  return new Intl.NumberFormat('vi-VN').format(n) + '₫'
}

const STATUS_COLORS: Record<string, string> = {
  'Đã thanh toán': 'bg-emerald-100 text-emerald-700',
  'Chờ thanh toán': 'bg-amber-100 text-amber-700',
  'Đã hủy': 'bg-red-100 text-red-700',
}

interface Props {
  stats: DashboardStats
}

export default function DashboardClient({ stats }: Props) {
  const statCards = [
    {
      label: 'Tổng số sân',
      value: stats.totalFields,
      sub: `${stats.activeFields} sẵn sàng`,
      bg: 'bg-indigo-50',
      border: 'border-indigo-200',
      icon: '🏟️',
      color: 'text-indigo-700',
    },
    {
      label: 'Đặt sân hôm nay',
      value: stats.todayBookings,
      sub: 'lịch đặt',
      bg: 'bg-sky-50',
      border: 'border-sky-200',
      icon: '📅',
      color: 'text-sky-700',
    },
    {
      label: 'Doanh thu hôm nay',
      value: fmtVnd(stats.revenueToday),
      sub: `Tổng: ${fmt(stats.totalRevenue)}₫`,
      bg: 'bg-emerald-50',
      border: 'border-emerald-200',
      icon: '💰',
      color: 'text-emerald-700',
    },
    {
      label: 'Nhân sự',
      value: stats.totalStaff,
      sub: 'nhân viên',
      bg: 'bg-violet-50',
      border: 'border-violet-200',
      icon: '👤',
      color: 'text-violet-700',
    },
  ]

  return (
    <div className="space-y-5">
      {/* Welcome banner */}
      <div className="bg-gradient-to-r from-[#1e1b4b] to-indigo-600 rounded-2xl p-6 text-white shadow-lg">
        <p className="text-indigo-200 text-xs font-semibold mb-1">Cổng thông tin quản lý</p>
        <h2 className="text-2xl font-black">
          Chào mừng trở lại, <span className="text-yellow-300">{stats.managerName}</span>!
        </h2>
        <p className="text-indigo-200 text-sm mt-1">Cơ sở CS{stats.coSoId} · Hệ thống sẵn sàng</p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map(c => (
          <div key={c.label} className={`${c.bg} ${c.border} border rounded-2xl p-4`}>
            <div className="text-2xl mb-2">{c.icon}</div>
            <p className={`text-2xl font-black ${c.color}`}>{c.value}</p>
            <p className="text-xs font-semibold text-slate-700 mt-0.5">{c.label}</p>
            <p className="text-[11px] text-slate-500 mt-0.5">{c.sub}</p>
          </div>
        ))}
      </div>

      {/* Quick links */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { href: '/quan-ly/san', icon: '🏟️', label: 'Quản lý sân' },
          { href: '/quan-ly/dat-san', icon: '📅', label: 'Đặt sân' },
          { href: '/quan-ly/hoa-don', icon: '🧾', label: 'Hóa đơn' },
          { href: '/quan-ly/nhan-su', icon: '👥', label: 'Nhân sự' },
        ].map(item => (
          <a
            key={item.href}
            href={item.href}
            className="bg-white border border-slate-200 rounded-xl p-4 flex items-center gap-3 hover:border-indigo-300 hover:shadow-sm transition-all group"
          >
            <span className="text-xl">{item.icon}</span>
            <span className="text-sm font-semibold text-slate-700 group-hover:text-indigo-700">{item.label}</span>
          </a>
        ))}
      </div>

      {/* Recent invoices */}
      {stats.recentInvoices.length > 0 && (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="font-bold text-slate-800">Hóa đơn gần đây</h3>
            <a href="/quan-ly/hoa-don" className="text-xs text-indigo-600 hover:underline font-medium">Xem tất cả →</a>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs">
                <tr>
                  <th className="px-5 py-3 text-left font-semibold">Mã HĐ</th>
                  <th className="px-5 py-3 text-left font-semibold">Ngày</th>
                  <th className="px-5 py-3 text-right font-semibold">Tổng tiền</th>
                  <th className="px-5 py-3 text-left font-semibold">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {stats.recentInvoices.map(inv => (
                  <tr key={inv.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3 font-mono text-xs text-slate-600">#{inv.id}</td>
                    <td className="px-5 py-3 text-slate-600">{inv.date || '—'}</td>
                    <td className="px-5 py-3 text-right font-semibold text-slate-800">{fmtVnd(inv.total)}</td>
                    <td className="px-5 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLORS[inv.status] ?? 'bg-slate-100 text-slate-600'}`}>
                        {inv.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
