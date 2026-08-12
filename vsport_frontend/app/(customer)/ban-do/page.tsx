'use client'
import { useEffect, useRef, useState } from 'react'

interface Facility {
  coSoID: number
  tenCoSo: string
  diaChi?: string
  lat?: number
  lng?: number
  tongSoSan?: number
}

const BASE = typeof window !== 'undefined' ? (process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java') : ''

export default function BanDoPage() {
  const [facilities, setFacilities] = useState<Facility[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState<Facility | null>(null)
  const iframeRef = useRef<HTMLIFrameElement>(null)

  useEffect(() => {
    fetch(`${BASE}/customer/api/facilities`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      .then(r => r.ok ? r.json() : null)
      .then(data => { if (data?.facilities) setFacilities(data.facilities) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const filtered = facilities.filter(f =>
    f.tenCoSo.toLowerCase().includes(search.toLowerCase()) ||
    (f.diaChi ?? '').toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      <div className="bg-gradient-to-br from-vs-navy to-blue-800 rounded-2xl p-6 text-white">
        <h1 className="text-2xl font-black mb-1">Bản đồ cơ sở thể thao</h1>
        <p className="text-blue-200 text-sm">Tìm cơ sở thể thao gần bạn nhất.</p>
      </div>

      {/* Search */}
      <div>
        <input
          className="w-full border border-slate-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300"
          placeholder="Tìm cơ sở theo tên hoặc địa chỉ..."
          value={search} onChange={e => setSearch(e.target.value)}
        />
      </div>

      {/* Map iframe */}
      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="h-48 bg-slate-100 flex items-center justify-center relative">
          <div className="text-center">
            <p className="text-4xl mb-2">🗺️</p>
            <p className="text-sm text-slate-500 mb-3">Xem bản đồ tương tác</p>
            <a href={`${BASE}/customer/ban-do`} target="_blank" rel="noopener noreferrer"
              className="bg-vs-blue text-white px-6 py-2.5 rounded-xl font-semibold text-sm hover:bg-blue-700">
              Mở bản đồ Leaflet →
            </a>
          </div>
        </div>
      </div>

      {/* Facility list */}
      {loading ? (
        <div className="text-center py-6 text-slate-400">Đang tải...</div>
      ) : filtered.length === 0 ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-6 text-center text-slate-400">
          {search ? 'Không tìm thấy cơ sở nào.' : 'Không có dữ liệu cơ sở.'}
        </div>
      ) : (
        <div className="space-y-2">
          {filtered.map(f => (
            <div key={f.coSoID}
              onClick={() => setSelected(selected?.coSoID === f.coSoID ? null : f)}
              className={`bg-white border rounded-2xl p-4 cursor-pointer transition-all ${selected?.coSoID === f.coSoID ? 'border-blue-300 shadow-sm' : 'border-slate-200 hover:border-blue-200'}`}>
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center text-blue-700 font-black flex-shrink-0">
                    {f.tenCoSo.charAt(0)}
                  </div>
                  <div>
                    <p className="font-bold text-slate-800">{f.tenCoSo}</p>
                    {f.diaChi && <p className="text-sm text-slate-400">{f.diaChi}</p>}
                  </div>
                </div>
                {f.tongSoSan !== undefined && (
                  <span className="text-xs bg-slate-100 text-slate-600 px-2 py-1 rounded-full">{f.tongSoSan} sân</span>
                )}
              </div>
              {selected?.coSoID === f.coSoID && (
                <div className="mt-3 flex gap-2 pt-3 border-t border-slate-100">
                  <a href={`/dat-san/${f.coSoID}`}
                    className="flex-1 bg-vs-blue text-white py-2 rounded-xl text-sm font-semibold text-center hover:bg-blue-700">
                    Đặt sân
                  </a>
                  {f.lat && f.lng && (
                    <a href={`https://maps.google.com/?q=${f.lat},${f.lng}`} target="_blank" rel="noopener noreferrer"
                      className="flex-1 border border-slate-200 text-slate-600 py-2 rounded-xl text-sm font-semibold text-center hover:bg-slate-50">
                      Google Maps
                    </a>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
