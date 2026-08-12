'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'

const SPORTS = ['Cầu lông', 'Bóng đá', 'Bóng rổ', 'Tennis', 'Bóng chuyền', 'Bóng bàn', 'Pickleball']

export default function TaoDoiClient() {
  const router = useRouter()
  const [form, setForm] = useState({ tenDoi: '', monTheThao: 'Cầu lông', moTa: '', soThanhVienToiDa: 10, conTruyCapCong: true })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!form.tenDoi.trim()) { setError('Vui lòng nhập tên đội'); return }
    setLoading(true)
    setError('')
    try {
      const res = await fetch(`${BASE}/customer/doi-nhom/create`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
        body: JSON.stringify(form),
      })
      if (res.ok) {
        router.push('/doi-nhom')
      } else {
        const data = await res.json()
        setError(data.error ?? 'Tạo đội thất bại. Vui lòng thử lại.')
      }
    } catch {
      setError('Lỗi kết nối. Vui lòng thử lại.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-lg mx-auto space-y-5">
      <div className="flex items-center gap-3">
        <Link href="/doi-nhom" className="text-slate-400 hover:text-slate-600">←</Link>
        <h1 className="text-2xl font-black text-vs-navy">Tạo đội mới</h1>
      </div>

      <form onSubmit={handleSubmit} className="bg-white border border-slate-200 rounded-2xl p-6 space-y-5">
        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1.5">Tên đội *</label>
          <input className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
            placeholder="Ví dụ: CLB Cầu lông Thứ 7"
            value={form.tenDoi} onChange={e => setForm(p => ({ ...p, tenDoi: e.target.value }))} />
        </div>

        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1.5">Môn thể thao *</label>
          <select className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
            value={form.monTheThao} onChange={e => setForm(p => ({ ...p, monTheThao: e.target.value }))}>
            {SPORTS.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        </div>

        <div>
          <label className="block text-sm font-semibold text-slate-700 mb-1.5">Mô tả</label>
          <textarea className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300 resize-none"
            rows={3} placeholder="Giới thiệu về đội của bạn..."
            value={form.moTa} onChange={e => setForm(p => ({ ...p, moTa: e.target.value }))} />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1.5">Số thành viên tối đa</label>
            <input type="number" min={2} max={50}
              className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
              value={form.soThanhVienToiDa} onChange={e => setForm(p => ({ ...p, soThanhVienToiDa: Number(e.target.value) }))} />
          </div>
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1.5">Chế độ tham gia</label>
            <select className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
              value={form.conTruyCapCong ? 'public' : 'private'}
              onChange={e => setForm(p => ({ ...p, conTruyCapCong: e.target.value === 'public' }))}>
              <option value="public">Công khai</option>
              <option value="private">Riêng tư</option>
            </select>
          </div>
        </div>

        {error && <p className="text-sm text-red-500 bg-red-50 rounded-xl px-4 py-2">{error}</p>}

        <div className="flex gap-3 pt-2">
          <Link href="/doi-nhom"
            className="flex-1 border border-slate-200 text-slate-600 py-3 rounded-xl font-semibold text-center hover:bg-slate-50">
            Hủy
          </Link>
          <button type="submit" disabled={loading}
            className="flex-1 bg-vs-blue text-white py-3 rounded-xl font-semibold hover:bg-blue-700 disabled:opacity-50 transition-colors">
            {loading ? 'Đang tạo...' : 'Tạo đội'}
          </button>
        </div>
      </form>
    </div>
  )
}
