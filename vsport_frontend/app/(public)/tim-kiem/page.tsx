import { Suspense } from 'react'
import SearchClient from '@/components/customer/SearchClient'
import Link from 'next/link'

export const metadata = { title: 'Tìm sân thể thao | V-SPORT' }

export default function TimKiemPage() {
  return (
    <div className="min-h-screen bg-slate-50">
      {/* Simple header for public search */}
      <header className="bg-white border-b border-slate-100 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 h-14 flex items-center gap-4">
          <Link href="/" className="font-bold text-xl tracking-tight">
            <span className="text-vs-navy">V-</span>
            <span className="text-vs-cyan">SPORT</span>
          </Link>
          <nav className="hidden sm:flex items-center gap-4 ml-4 text-sm text-vs-slate">
            <Link href="/tim-kiem" className="text-vs-navy font-medium">Tìm sân</Link>
            <Link href="/ban-do" className="hover:text-vs-navy">Bản đồ</Link>
            <Link href="/ghep-keo" className="hover:text-vs-navy">Ghép kèo</Link>
          </nav>
          <div className="ml-auto flex items-center gap-2">
            <Link href="/dang-nhap" className="text-sm text-vs-slate hover:text-vs-navy">Đăng nhập</Link>
            <Link href="/dang-ky" className="text-sm px-3 py-1.5 bg-vs-blue text-white rounded-lg hover:bg-blue-700 transition-colors">
              Đăng ký
            </Link>
          </div>
        </div>
      </header>

      <Suspense fallback={<div className="flex justify-center py-16 text-vs-slate text-sm">Đang tải...</div>}>
        <SearchClient />
      </Suspense>
    </div>
  )
}
