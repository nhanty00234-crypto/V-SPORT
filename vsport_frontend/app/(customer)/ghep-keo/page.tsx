'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'

interface Match {
  keoId: number
  tenCoSo: string
  tenSan: string
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  trangThai: string
  tenMon?: string
  soNguoiCanTim: number
  soNguoiDaTham: number
  trinhDo?: string
  note?: string
  teamNameNguoiTao?: string
  isMine?: boolean
}

interface Booking {
  datSanId: number
  tenCoSo: string
  tenSan: string
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
}

const STATUS_COLOR: Record<string, string> = {
  'Đang mở': 'bg-green-100 text-green-700 border-green-200',
  'Đã đủ người': 'bg-yellow-100 text-yellow-700 border-yellow-200',
  'Đã hủy': 'bg-red-100 text-red-700 border-red-200',
}

const BASE = typeof window !== 'undefined' ? (process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java') : ''

export default function GhepKeoPage() {
  const [tab, setTab] = useState<'kham-pha' | 'tao-keo' | 'cua-toi'>('kham-pha')
  const [matches, setMatches] = useState<Match[]>([])
  const [myMatches, setMyMatches] = useState<Match[]>([])
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)

  // create form
  const [selectedBooking, setSelectedBooking] = useState('')
  const [soNguoi, setSoNguoi] = useState(3)
  const [trinhDo, setTrinhDo] = useState('Không yêu cầu')
  const [note, setNote] = useState('')
  const [creating, setCreating] = useState(false)

  function showToast(msg: string, ok = true) {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3000)
  }

  useEffect(() => {
    Promise.all([
      fetch(`${BASE}/customer/api/team-matches`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : []),
      fetch(`${BASE}/customer/api/team-matches/mine`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : []),
      fetch(`${BASE}/customer/api/team-matches/eligible-bookings`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : null),
    ]).then(([all, mine, bookingData]) => {
      setMatches(Array.isArray(all) ? all : [])
      setMyMatches(Array.isArray(mine) ? mine : [])
      const bks = bookingData?.bookings ?? (Array.isArray(bookingData) ? bookingData : [])
      setBookings(bks)
    }).catch(() => {}).finally(() => setLoading(false))
  }, [])

  async function handleJoin(keoId: number) {
    const res = await fetch(`${BASE}/customer/ghep-keo/tham-gia`, {
      method: 'POST', credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify({ keoId }),
    }).catch(() => null)
    const data = res && res.ok ? await res.json() : null
    showToast(data?.message ?? 'Đã gửi yêu cầu.', data?.success ?? false)
  }

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault()
    if (!selectedBooking) { showToast('Vui lòng chọn ca đặt sân.', false); return }
    setCreating(true)
    const res = await fetch(`${BASE}/customer/ghep-keo/tao-keo`, {
      method: 'POST', credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify({ datSanId: Number(selectedBooking), soNguoiCanTim: soNguoi, trinhDo, note }),
    }).catch(() => null)
    const data = res && res.ok ? await res.json() : null
    showToast(data?.message ?? (data?.success ? 'Đã tạo kèo!' : 'Tạo kèo thất bại.'), data?.success ?? false)
    if (data?.success) {
      setTab('cua-toi')
      const mine = await fetch(`${BASE}/customer/api/team-matches/mine`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : []).catch(() => [])
      setMyMatches(Array.isArray(mine) ? mine : [])
    }
    setCreating(false)
  }

  const openMatches = matches.filter(m => m.trangThai === 'Đang mở')

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      {toast && (
        <div className={`fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-6 py-3 rounded-full text-white text-sm font-semibold shadow-lg ${toast.ok ? 'bg-green-600' : 'bg-red-600'}`}>
          {toast.msg}
        </div>
      )}

      {/* Hero */}
      <div className="bg-gradient-to-br from-emerald-700 to-emerald-500 rounded-2xl p-6 text-white">
        <h1 className="text-2xl font-black mb-1">Ghép kèo thể thao</h1>
        <p className="text-emerald-100 text-sm">Tìm đồng đội hoặc đối thủ, bắt đầu trận đấu ngay hôm nay.</p>
      </div>

      {/* Tabs */}
      <div className="grid grid-cols-3 gap-1 bg-white border border-slate-200 rounded-xl p-1">
        {(['kham-pha', 'tao-keo', 'cua-toi'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className={`py-2 rounded-lg text-sm font-semibold transition-colors ${tab === t ? 'bg-emerald-500 text-white shadow' : 'text-slate-600 hover:bg-slate-50'}`}>
            {t === 'kham-pha' ? 'Tìm kèo' : t === 'tao-keo' ? 'Tạo kèo' : 'Kèo của tôi'}
          </button>
        ))}
      </div>

      {/* Panel: Tìm kèo */}
      {tab === 'kham-pha' && (
        <div className="space-y-3">
          <p className="text-sm text-slate-500">{openMatches.length} kèo đang mở</p>
          {loading ? (
            <div className="text-center py-8 text-slate-400">Đang tải...</div>
          ) : openMatches.length === 0 ? (
            <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center">
              <p className="text-4xl mb-3">⚡</p>
              <p className="font-medium text-slate-600 mb-2">Chưa có kèo nào đang mở</p>
              <button onClick={() => setTab('tao-keo')} className="bg-emerald-500 text-white px-6 py-2 rounded-xl text-sm font-semibold mt-2">
                Tạo kèo ngay
              </button>
            </div>
          ) : (
            openMatches.map(m => (
              <div key={m.keoId} className="bg-white border border-slate-200 rounded-2xl p-4 space-y-2">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-bold text-slate-800">{m.tenCoSo} – {m.tenSan}</p>
                    <p className="text-sm text-slate-400">{m.ngayDat} · {m.gioBatDau}–{m.gioKetThuc}</p>
                    {m.tenMon && <p className="text-xs text-slate-400">{m.tenMon}</p>}
                    {m.teamNameNguoiTao && <p className="text-xs text-slate-400">Đội: {m.teamNameNguoiTao}</p>}
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-semibold border ${STATUS_COLOR[m.trangThai] ?? 'bg-slate-100 text-slate-600 border-slate-200'}`}>{m.trangThai}</span>
                </div>
                <div className="flex flex-wrap gap-3 text-xs text-slate-500">
                  <span>Cần thêm: {m.soNguoiCanTim} người</span>
                  {m.trinhDo && <span>Trình độ: {m.trinhDo}</span>}
                </div>
                {m.note && <p className="text-xs text-slate-500 bg-slate-50 rounded-lg px-3 py-2">{m.note}</p>}
                <button onClick={() => handleJoin(m.keoId)}
                  className="w-full bg-emerald-500 text-white py-2 rounded-xl text-sm font-semibold hover:bg-emerald-600">
                  Tham gia kèo
                </button>
              </div>
            ))
          )}
        </div>
      )}

      {/* Panel: Tạo kèo */}
      {tab === 'tao-keo' && (
        <form onSubmit={handleCreate} className="bg-white border border-slate-200 rounded-2xl p-5 space-y-4">
          <h2 className="font-black text-slate-800">Tạo kèo mới</h2>
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1.5">Ca đặt sân của bạn *</label>
            {bookings.length === 0 ? (
              <div className="text-sm text-slate-500 bg-slate-50 rounded-xl p-4">
                Bạn chưa có ca đặt sân nào sắp diễn ra.{' '}
                <Link href="/tim-kiem" className="text-vs-blue hover:underline">Đặt sân ngay →</Link>
              </div>
            ) : (
              <select className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-300"
                value={selectedBooking} onChange={e => setSelectedBooking(e.target.value)}>
                <option value="">-- Chọn ca đặt sân --</option>
                {bookings.map(b => (
                  <option key={b.datSanId} value={b.datSanId}>
                    {b.tenCoSo} – {b.tenSan} ({b.ngayDat} {b.gioBatDau}–{b.gioKetThuc})
                  </option>
                ))}
              </select>
            )}
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Số người cần tìm *</label>
              <input type="number" min={1} max={20} value={soNguoi} onChange={e => setSoNguoi(Number(e.target.value))}
                className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-300" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Trình độ</label>
              <select value={trinhDo} onChange={e => setTrinhDo(e.target.value)}
                className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-300">
                {['Không yêu cầu', 'Mới chơi', 'Cơ bản', 'Trung bình', 'Khá', 'Nâng cao'].map(v => <option key={v}>{v}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-1.5">Ghi chú</label>
            <textarea rows={3} value={note} onChange={e => setNote(e.target.value)} maxLength={240}
              placeholder="Ví dụ: chơi vui vẻ, giao lưu là chính..."
              className="w-full border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-300 resize-none" />
          </div>
          <button type="submit" disabled={creating || bookings.length === 0}
            className="w-full bg-emerald-500 text-white py-3 rounded-xl font-semibold hover:bg-emerald-600 disabled:opacity-50">
            {creating ? 'Đang tạo...' : 'Tạo kèo'}
          </button>
        </form>
      )}

      {/* Panel: Kèo của tôi */}
      {tab === 'cua-toi' && (
        <div className="space-y-3">
          {myMatches.length === 0 ? (
            <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center">
              <p className="text-4xl mb-3">📋</p>
              <p className="font-medium text-slate-600 mb-2">Bạn chưa tạo kèo nào</p>
              <button onClick={() => setTab('tao-keo')} className="bg-emerald-500 text-white px-6 py-2 rounded-xl text-sm font-semibold mt-2">
                Tạo kèo đầu tiên
              </button>
            </div>
          ) : (
            myMatches.map(m => (
              <div key={m.keoId} className="bg-white border border-slate-200 rounded-2xl p-4 space-y-2">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-bold text-slate-800">{m.tenCoSo} – {m.tenSan}</p>
                    <p className="text-sm text-slate-400">{m.ngayDat} · {m.gioBatDau}–{m.gioKetThuc}</p>
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-semibold border ${STATUS_COLOR[m.trangThai] ?? 'bg-slate-100 text-slate-600 border-slate-200'}`}>{m.trangThai}</span>
                </div>
                <div className="flex gap-3 text-xs text-slate-500">
                  <span>Đã tham gia: {m.soNguoiDaTham ?? 0}/{m.soNguoiCanTim}</span>
                  {m.trinhDo && <span>Trình độ: {m.trinhDo}</span>}
                </div>
              </div>
            ))
          )}
        </div>
      )}

      <div className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-center">
        <p className="text-xs text-slate-400 mb-1">Tính năng đầy đủ (lọc, sắp xếp, ghép đội) tại</p>
        <a href={`${BASE}/customer/ghep-keo`} target="_blank" rel="noopener noreferrer"
          className="text-vs-blue text-sm font-semibold hover:underline">Giao diện ghép kèo đầy đủ →</a>
      </div>
    </div>
  )
}
