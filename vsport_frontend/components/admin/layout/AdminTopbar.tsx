'use client'
import { usePathname } from 'next/navigation'
import { User } from '@/types/auth'

const PAGE_TITLES: Record<string, string> = {
  '/quan-tri': 'Tổng quan hệ thống',
  '/quan-tri/chi-nhanh': 'Quản lý chi nhánh',
  '/quan-tri/owner': 'Quản lý Owner',
  '/quan-tri/nhan-su': 'Nhân sự',
  '/quan-tri/hoa-don': 'Hóa đơn',
  '/quan-tri/lich-dat-san': 'Lịch đặt sân',
  '/quan-tri/khuyen-mai': 'Khuyến mãi',
  '/quan-tri/kho-dich-vu': 'Kho dịch vụ',
  '/quan-tri/ho-tro': 'Hỗ trợ',
  '/quan-tri/audit-log': 'Audit Log',
  '/quan-tri/thung-rac': 'Thùng rác',
}

export default function AdminTopbar({ user }: { user: User }) {
  const pathname = usePathname()
  const title = PAGE_TITLES[pathname] ?? 'Quản trị'

  return (
    <header className="fixed top-0 left-0 lg:left-[260px] right-0 h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-6 z-20">
      <h1 className="text-base font-bold text-slate-800">{title}</h1>
      <div className="flex items-center gap-3">
        <span className="hidden sm:block text-sm text-slate-500">{user.fullName}</span>
        <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white font-bold text-xs">
          {(user.fullName || user.email).charAt(0).toUpperCase()}
        </div>
      </div>
    </header>
  )
}
