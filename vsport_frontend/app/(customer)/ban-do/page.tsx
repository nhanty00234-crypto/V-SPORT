const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
export const metadata = { title: 'Bản đồ sân | V-SPORT' }
export default function BanDoPage() {
  return (
    <div className="max-w-2xl mx-auto px-4 py-12 text-center">
      <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-8">
        <div className="text-5xl mb-4">🗺️</div>
        <h1 className="text-xl font-bold text-vs-navy mb-2">Bản đồ cơ sở thể thao</h1>
        <p className="text-sm text-vs-slate mb-6">Tìm sân gần bạn nhất trên bản đồ.</p>
        <a href={`${BASE}/customer/ban-do`} className="inline-block px-6 py-3 bg-vs-blue text-white font-bold rounded-xl hover:bg-blue-700 transition-colors">
          Mở bản đồ →
        </a>
      </div>
    </div>
  )
}
