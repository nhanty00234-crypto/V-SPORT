'use client'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { User } from '@/types/auth'

const PAGE_TITLES: Record<string, string> = {
  '/quan-ly': 'Tổng quan vận hành',
  '/quan-ly/san': 'Quản lý sân',
  '/quan-ly/dat-san': 'Quản lý đặt sân',
  '/quan-ly/hoa-don': 'Hóa đơn',
  '/quan-ly/khach-hang': 'Khách hàng',
  '/quan-ly/kho-dich-vu': 'Kho dịch vụ',
  '/quan-ly/khuyen-mai': 'Khuyến mãi',
  '/quan-ly/nhan-su': 'Nhân sự',
  '/quan-ly/ca-lam-viec': 'Ca làm việc',
  '/quan-ly/ma-qr-san': 'Mã QR sân',
  '/quan-ly/hoan-tien': 'Hoàn tiền',
  '/quan-ly/thung-rac': 'Thùng rác',
  '/quan-ly/audit-log': 'Audit Log',
}

interface Props {
  user: User
}

export default function ManagerTopbar({ user }: Props) {
  const pathname = usePathname()
  const title = PAGE_TITLES[pathname] ?? 'Quản lý'

  return (
    <header className="fixed top-0 left-0 lg:left-[248px] right-0 h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-6 z-20">
      <h1 className="text-base font-bold text-slate-800">{title}</h1>
      <div className="flex items-center gap-3">
        <span className="hidden sm:block text-sm text-slate-500">{user.fullName}</span>
        <div className="w-8 h-8 rounded-full bg-indigo-600 flex items-center justify-center text-white font-bold text-xs">
          {(user.fullName || user.email).charAt(0).toUpperCase()}
        </div>
      </div>
    </header>
  )
}
