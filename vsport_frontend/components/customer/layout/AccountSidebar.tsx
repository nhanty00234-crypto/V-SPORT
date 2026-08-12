'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

const links = [
  { href: '/account/tai-khoan', label: 'Tổng quan' },
  { href: '/account/ho-so', label: 'Hồ sơ cá nhân' },
  { href: '/account/doi-mat-khau', label: 'Đổi mật khẩu' },
  { href: '/account/lich-su', label: 'Lịch sử đặt sân' },
  { href: '/account/thong-bao', label: 'Thông báo' },
  { href: '/account/cai-dat', label: 'Cài đặt thông báo' },
  { href: '/account/uu-dai', label: 'Ưu đãi của tôi' },
  { href: '/account/diem-uy-tin', label: 'Điểm uy tín' },
]

export default function AccountSidebar() {
  const pathname = usePathname()

  return (
    <aside className="hidden md:block w-56 flex-shrink-0">
      <nav className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <div className="px-4 py-3 bg-vs-navy text-white">
          <p className="text-xs font-semibold uppercase tracking-widest text-cyan-300">Tài khoản</p>
        </div>
        <ul className="py-2">
          {links.map(link => {
            const active = pathname === link.href
            return (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className={`flex items-center gap-2 px-4 py-2.5 text-sm font-medium transition-colors ${
                    active
                      ? 'text-vs-blue bg-blue-50 border-r-2 border-vs-blue'
                      : 'text-vs-slate hover:text-vs-navy hover:bg-slate-50'
                  }`}
                >
                  {link.label}
                </Link>
              </li>
            )
          })}
        </ul>
      </nav>
    </aside>
  )
}
