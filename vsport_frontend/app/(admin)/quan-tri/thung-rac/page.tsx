const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'
export const metadata = { title: 'Thùng rác | V-SPORT Admin' }
export default function Page() {
  return (
    <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      <div className="px-6 py-5 border-b border-slate-100 flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold text-slate-800">Thùng rác</h2>
          <p className="text-sm text-slate-500 mt-0.5">Khôi phục hoặc xóa vĩnh viễn dữ liệu đã xóa.</p>
        </div>
        <a href={`${BASE}/admin/thung-rac`}
           className="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-xl hover:bg-blue-700 transition-colors">
          Mở giao diện đầy đủ →
        </a>
      </div>
      <div className="p-6 text-center text-slate-400 py-16">
        <div className="text-5xl mb-3">🗑️</div>
        <p className="font-medium">Giao diện Thùng rác.</p>
        <a href={`${BASE}/admin/thung-rac`} className="mt-4 inline-block text-blue-600 text-sm hover:underline">
          Nhấn vào đây nếu không tự chuyển →
        </a>
      </div>
    </div>
  )
}
