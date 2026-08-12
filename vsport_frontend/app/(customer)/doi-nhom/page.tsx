import Link from 'next/link'
const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
export const metadata = { title: 'Đội nhóm | V-SPORT' }
export default function DoiNhomPage() {
  return (
    <div className="max-w-2xl mx-auto px-4 py-12 text-center">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8">
        <div className="text-5xl mb-4">👥</div>
        <h1 className="text-xl font-bold text-vs-navy mb-2">Đội nhóm của tôi</h1>
        <p className="text-sm text-vs-slate mb-6">Tạo và quản lý đội nhóm thể thao của bạn.</p>
        <div className="flex gap-3 justify-center">
          <a href={`${BASE}/customer/doi-nhom`} className="px-5 py-2.5 bg-vs-blue text-white font-semibold text-sm rounded-xl hover:bg-blue-700 transition-colors">
            Xem đội nhóm
          </a>
          <Link href="/doi-nhom/tao" className="px-5 py-2.5 border border-vs-blue text-vs-blue font-semibold text-sm rounded-xl hover:bg-blue-50 transition-colors">
            Tạo đội mới
          </Link>
        </div>
      </div>
    </div>
  )
}
