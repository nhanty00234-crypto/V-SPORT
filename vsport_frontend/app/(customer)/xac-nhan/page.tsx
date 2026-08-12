const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
export const metadata = { title: 'Xác nhận đặt sân | V-SPORT' }
export default function XacNhanPage() {
  return (
    <div className="max-w-2xl mx-auto px-4 py-12 text-center">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8">
        <div className="text-5xl mb-4">✅</div>
        <h1 className="text-xl font-bold text-vs-navy mb-2">Xác nhận đặt sân</h1>
        <a href={`${BASE}/customer/xac-nhan`} className="inline-block px-6 py-3 bg-vs-blue text-white font-bold rounded-xl hover:bg-blue-700 transition-colors">
          Tiếp tục →
        </a>
      </div>
    </div>
  )
}
