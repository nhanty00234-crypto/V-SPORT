'use client'

import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'
import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import { searchFacilities } from '@/lib/api/customer'
import type { FacilitySummary, Sport, SearchResult } from '@/types/customer'

function FacilityCard({ f }: { f: FacilitySummary }) {
  function fmtCurrency(n: number) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(n)
  }

  return (
    <Link href={`/co-so/${f.id}`} className="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm hover:shadow-md hover:-translate-y-1 transition-all block group">
      <div className="relative h-44 bg-slate-100 overflow-hidden">
        {f.image ? (
          <img src={f.image} alt={f.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-vs-slate text-4xl">🏟</div>
        )}
        <div className="absolute top-2 right-2 flex gap-1">
          {f.openNow ? (
            <span className="bg-green-500 text-white text-xs px-2 py-0.5 rounded-full font-medium">Đang mở</span>
          ) : (
            <span className="bg-slate-500 text-white text-xs px-2 py-0.5 rounded-full font-medium">Đóng cửa</span>
          )}
          {f.hasPromotion && (
            <span className="bg-red-500 text-white text-xs px-2 py-0.5 rounded-full font-medium">KM</span>
          )}
        </div>
      </div>
      <div className="p-4">
        <h3 className="font-bold text-vs-navy text-sm truncate">{f.name}</h3>
        <p className="text-xs text-vs-slate mt-1 truncate">{f.address}</p>
        {f.sports.length > 0 && (
          <div className="flex gap-1 flex-wrap mt-2">
            {f.sports.slice(0, 3).map(s => (
              <span key={s} className="bg-slate-100 text-vs-slate text-xs px-2 py-0.5 rounded-full">{s}</span>
            ))}
          </div>
        )}
        <div className="flex items-center justify-between mt-3 pt-3 border-t border-slate-50">
          <span className="text-xs text-vs-slate">{f.readyCourtCount} sân sẵn sàng</span>
          <span className="text-sm font-bold text-vs-blue">từ {fmtCurrency(f.minPrice)}</span>
        </div>
      </div>
    </Link>
  )
}

export default function SearchClient() {
  const router = useRouter()
  const pathname = usePathname()
  const params = useSearchParams()

  const [q, setQ] = useState(params.get('q') ?? '')
  const [sportId, setSportId] = useState<number | undefined>(params.get('sportId') ? Number(params.get('sportId')) : undefined)
  const [openNow, setOpenNow] = useState(params.get('openNow') === '1')
  const [result, setResult] = useState<SearchResult | null>(null)
  const [loading, setLoading] = useState(true)

  const doSearch = useCallback(async (qv: string, sid?: number, on?: boolean) => {
    setLoading(true)
    const r = await searchFacilities(qv, sid, on)
    setResult(r)
    setLoading(false)
  }, [])

  useEffect(() => {
    doSearch(params.get('q') ?? '', params.get('sportId') ? Number(params.get('sportId')) : undefined, params.get('openNow') === '1')
  }, [params, doSearch])

  function applyFilter(newQ: string, newSportId?: number, newOpenNow?: boolean) {
    const search = new URLSearchParams()
    if (newQ) search.set('q', newQ)
    if (newSportId) search.set('sportId', String(newSportId))
    if (newOpenNow) search.set('openNow', '1')
    router.push(`${pathname}?${search.toString()}`)
  }

  function handleSearch(e: React.FormEvent) {
    e.preventDefault()
    applyFilter(q, sportId, openNow)
  }

  const sports: Sport[] = result?.sports ?? []
  const facilities: FacilitySummary[] = result?.facilities ?? []

  return (
    <div className="max-w-7xl mx-auto px-4 py-6">
      {/* Search bar */}
      <form onSubmit={handleSearch} className="flex gap-2 mb-6">
        <input
          type="search"
          value={q}
          onChange={e => setQ(e.target.value)}
          placeholder="Tìm tên sân, địa chỉ..."
          className="flex-1 px-4 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-vs-blue"
        />
        <button type="submit" className="px-5 py-2.5 bg-vs-blue text-white rounded-xl font-semibold text-sm hover:bg-blue-700 transition-colors">
          Tìm
        </button>
      </form>

      {/* Sport chips */}
      {sports.length > 0 && (
        <div className="flex gap-2 flex-wrap mb-4">
          <button
            onClick={() => { setSportId(undefined); applyFilter(q, undefined, openNow) }}
            className={`px-4 py-1.5 text-sm rounded-full border font-medium transition-all ${!sportId ? 'bg-vs-navy text-white border-vs-navy' : 'border-slate-200 text-vs-slate hover:border-vs-navy hover:text-vs-navy'}`}
          >
            Tất cả
          </button>
          {sports.map(s => (
            <button
              key={s.id}
              onClick={() => { setSportId(s.id); applyFilter(q, s.id, openNow) }}
              className={`px-4 py-1.5 text-sm rounded-full border font-medium transition-all ${sportId === s.id ? 'bg-vs-navy text-white border-vs-navy' : 'border-slate-200 text-vs-slate hover:border-vs-navy hover:text-vs-navy'}`}
            >
              {s.name}
            </button>
          ))}
        </div>
      )}

      {/* Open now toggle */}
      <div className="flex items-center gap-2 mb-6">
        <button
          type="button"
          onClick={() => { const n = !openNow; setOpenNow(n); applyFilter(q, sportId, n) }}
          className={`flex items-center gap-2 px-3 py-1.5 text-sm rounded-full border font-medium transition-all ${openNow ? 'bg-green-500 text-white border-green-500' : 'border-slate-200 text-vs-slate hover:border-green-500 hover:text-green-600'}`}
        >
          <span className={`inline-block w-2 h-2 rounded-full ${openNow ? 'bg-white' : 'bg-green-400'}`} />
          Đang mở cửa
        </button>
        {!loading && (
          <span className="text-sm text-vs-slate">{facilities.length} cơ sở</span>
        )}
      </div>

      {/* Results */}
      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-72 bg-slate-100 rounded-2xl animate-pulse" />
          ))}
        </div>
      ) : facilities.length === 0 ? (
        <div className="text-center py-16">
          <div className="text-5xl mb-4">🏟</div>
          <p className="text-vs-slate">Không tìm thấy cơ sở nào. Hãy thử từ khóa khác.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {facilities.map(f => <FacilityCard key={f.id} f={f} />)}
        </div>
      )}
    </div>
  )
}
