'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const NAV = [
  { href: '/quan-ly', icon: '📊', label: 'Tổng quan', exact: true },
  { href: '/quan-ly/san', icon: '🏟️', label: 'Quản lý sân' },
  { href: '/quan-ly/dat-san', icon: '📅', label: 'Quản lý đặt sân' },
  { href: '/quan-ly/hoa-don', icon: '🧾', label: 'Hóa đơn' },
  { href: '/quan-ly/khach-hang', icon: '👥', label: 'Khách hàng' },
  { href: '/quan-ly/kho-dich-vu', icon: '📦', label: 'Kho dịch vụ' },
  { href: '/quan-ly/khuyen-mai', icon: '🎁', label: 'Khuyến mãi' },
  { href: '/quan-ly/nhan-su', icon: '👤', label: 'Nhân sự' },
  { href: '/quan-ly/ca-lam-viec', icon: '🕐', label: 'Ca làm việc' },
  { href: '/quan-ly/ma-qr-san', icon: '📷', label: 'Mã QR sân' },
  { href: '/quan-ly/hoan-tien', icon: '💰', label: 'Hoàn tiền' },
  { href: '/quan-ly/thung-rac', icon: '🗑️', label: 'Thùng rác' },
  { href: '/quan-ly/audit-log', icon: '📋', label: 'Audit Log' },
]

export default function ManagerSidebar() {
  const pathname = usePathname()

  return (
    <>
      {/* Sidebar */}
      <aside className="fixed top-0 left-0 h-full w-[248px] bg-[#1e1b4b] flex flex-col z-30 hidden lg:flex">
        {/* Logo */}
        <div className="px-5 py-4 border-b border-white/10">
          <Link href="/quan-ly" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-indigo-400 flex items-center justify-center text-white font-black text-sm">V</div>
            <div>
              <p className="text-white font-bold text-sm leading-tight">V-SPORT</p>
              <p className="text-indigo-300 text-[10px] font-medium">Cổng quản lý</p>
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
                    ? 'bg-indigo-500 text-white shadow-lg shadow-indigo-900/50'
                    : 'text-indigo-200 hover:bg-white/10 hover:text-white'
                }`}
              >
                <span className="text-base w-5 text-center">{item.icon}</span>
                {item.label}
              </Link>
            )
          })}
        </nav>

        {/* Footer */}
        <div className="px-4 py-3 border-t border-white/10">
          <Link href="/tim-kiem" className="text-[11px] text-indigo-400 hover:text-indigo-200 transition-colors">
            ← Về trang khách hàng
          </Link>
        </div>
      </aside>
    </>
  )
}
