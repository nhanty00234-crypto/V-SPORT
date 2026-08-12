'use client'
import { usePathname } from 'next/navigation'
import { User } from '@/types/auth'

const PAGE_TITLES: Record<string, string> = {
  '/nhan-vien': 'Tổng quan vận hành',
  '/nhan-vien/check-in': 'Check-in sân',
  '/nhan-vien/dat-san': 'Quản lý đặt sân',
  '/nhan-vien/hoa-don': 'Hóa đơn',
  '/nhan-vien/hoan-tien': 'Hoàn tiền',
  '/nhan-vien/ca-lam-viec': 'Ca làm việc',
  '/nhan-vien/yeu-cau-qr': 'Yêu cầu QR',
}

interface Props {
  user: User
}

export default function StaffTopbar({ user }: Props) {
  const pathname = usePathname()
  const title = PAGE_TITLES[pathname] ?? 'Lễ tân'

  return (
    <header className="fixed top-0 left-0 lg:left-[248px] right-0 h-16 bg-white border-b border-slate-200 flex items-center justify-between px-4 lg:px-6 z-20">
      <h1 className="text-base font-bold text-slate-800">{title}</h1>
      <div className="flex items-center gap-3">
        <span className="hidden sm:block text-sm text-slate-500">{user.fullName}</span>
        <div className="w-8 h-8 rounded-full bg-orange-600 flex items-center justify-center text-white font-bold text-xs">
          {(user.fullName || user.email).charAt(0).toUpperCase()}
        </div>
      </div>
    </header>
  )
}
