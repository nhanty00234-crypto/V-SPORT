'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const NAV = [
  { href: '/nhan-vien', icon: '📊', label: 'Tổng quan', exact: true },
  { href: '/nhan-vien/check-in', icon: '✅', label: 'Check-in sân' },
  { href: '/nhan-vien/dat-san', icon: '📅', label: 'Quản lý đặt sân' },
  { href: '/nhan-vien/hoa-don', icon: '🧾', label: 'Hóa đơn' },
  { href: '/nhan-vien/hoan-tien', icon: '💰', label: 'Hoàn tiền' },
  { href: '/nhan-vien/ca-lam-viec', icon: '🕐', label: 'Ca làm việc' },
  { href: '/nhan-vien/yeu-cau-qr', icon: '📷', label: 'Yêu cầu QR' },
]

export default function StaffSidebar() {
  const pathname = usePathname()

  return (
    <aside className="fixed top-0 left-0 h-full w-[248px] bg-[#431407] flex flex-col z-30 hidden lg:flex">
      {/* Logo */}
      <div className="px-5 py-4 border-b border-white/10">
        <Link href="/nhan-vien" className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-lg bg-orange-400 flex items-center justify-center text-white font-black text-sm">V</div>
          <div>
            <p className="text-white font-bold text-sm leading-tight">V-SPORT</p>
            <p className="text-orange-300 text-[10px] font-medium">Cổng lễ tân</p>
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
                  ? 'bg-orange-500 text-white shadow-lg shadow-orange-900/50'
                  : 'text-orange-200 hover:bg-white/10 hover:text-white'
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
        <Link href="/tim-kiem" className="text-[11px] text-orange-400 hover:text-orange-200 transition-colors">
          ← Về trang khách hàng
        </Link>
      </div>
    </aside>
  )
}
