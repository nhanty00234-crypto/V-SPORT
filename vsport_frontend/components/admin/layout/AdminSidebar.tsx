'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const NAV = [
  { href: '/quan-tri', icon: '📊', label: 'Tổng quan', exact: true },
  { href: '/quan-tri/chi-nhanh', icon: '🏢', label: 'Quản lý chi nhánh' },
  { href: '/quan-tri/owner', icon: '👑', label: 'Quản lý Owner' },
  { href: '/quan-tri/nhan-su', icon: '👤', label: 'Nhân sự' },
  { href: '/quan-tri/hoa-don', icon: '🧾', label: 'Hóa đơn' },
  { href: '/quan-tri/lich-dat-san', icon: '📅', label: 'Lịch đặt sân' },
  { href: '/quan-tri/khuyen-mai', icon: '🎁', label: 'Khuyến mãi' },
  { href: '/quan-tri/kho-dich-vu', icon: '📦', label: 'Kho dịch vụ' },
  { href: '/quan-tri/ho-tro', icon: '💬', label: 'Hỗ trợ' },
  { href: '/quan-tri/audit-log', icon: '📋', label: 'Audit Log' },
  { href: '/quan-tri/thung-rac', icon: '🗑️', label: 'Thùng rác' },
]

export default function AdminSidebar() {
  const pathname = usePathname()

  return (
    <aside className="fixed top-0 left-0 h-full w-[260px] bg-white border-r border-slate-200 shadow-sm flex flex-col z-30 hidden lg:flex">
      {/* Logo */}
      <div className="px-5 py-4 border-b border-slate-100">
        <Link href="/quan-tri" className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white font-black text-sm">V</div>
          <div>
            <p className="text-slate-800 font-bold text-sm leading-tight">V-SPORT</p>
            <p className="text-blue-500 text-[10px] font-medium">Quản trị hệ thống</p>
          </div>
        </Link>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto py-3 px-3 space-y-0.5">
        {NAV.map(item => {
          const active = item.exact
            ? pathname === item.href
            : pathname.startsWith(item.href)
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${
                active
                  ? 'bg-blue-50 text-blue-700 border border-blue-100'
                  : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <span className="text-base w-5 text-center">{item.icon}</span>
              {item.label}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="px-4 py-3 border-t border-slate-100">
        <Link href="/tim-kiem" className="text-[11px] text-slate-400 hover:text-slate-600 transition-colors">
          ← Về trang khách hàng
        </Link>
      </div>
    </aside>
  )
}
