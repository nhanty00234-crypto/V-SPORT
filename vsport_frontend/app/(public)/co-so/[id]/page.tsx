import Link from 'next/link'
import { notFound } from 'next/navigation'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

async function getFacilityDetail(id: string) {
  try {
    const res = await fetch(`${BASE}/api/customer/facilities/detail?coSoId=${id}`, {
      credentials: 'include',
      cache: 'no-store',
    })
    if (!res.ok) return null
    return res.json()
  } catch {
    return null
  }
}

export default async function CoSoPage({ params }: { params: { id: string } }) {
  const data = await getFacilityDetail(params.id)
  if (!data || data.error) notFound()

  const f = data.facility ?? data
  const courts = data.courts ?? []

  function fmtCurrency(n: number) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', maximumFractionDigits: 0 }).format(n)
  }

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="bg-white border-b border-slate-100 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 h-14 flex items-center gap-3">
          <Link href="/tim-kiem" className="text-vs-slate hover:text-vs-navy text-sm">← Tìm sân</Link>
          <span className="text-slate-300">/</span>
          <span className="text-sm text-vs-navy font-medium truncate">{f?.tenCoSo ?? f?.name ?? 'Chi tiết cơ sở'}</span>
        </div>
      </header>

      <div className="max-w-5xl mx-auto px-4 py-6">
        {/* Hero image */}
        {(f?.hinhAnh ?? f?.image) && (
          <div className="rounded-2xl overflow-hidden h-64 mb-6">
            <img src={f.hinhAnh ?? f.image} alt={f?.tenCoSo ?? ''} className="w-full h-full object-cover" />
          </div>
        )}

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Main info */}
          <div className="lg:col-span-2 space-y-4">
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
              <h1 className="text-xl font-bold text-vs-navy">{f?.tenCoSo ?? f?.name}</h1>
              <p className="text-sm text-vs-slate mt-2">{f?.diaChi ?? f?.address}</p>
              {(f?.soDienThoai ?? f?.phone) && (
                <p className="text-sm text-vs-slate mt-1">📞 {f.soDienThoai ?? f.phone}</p>
              )}
              <div className="flex items-center gap-3 mt-3">
                <span className="text-sm text-vs-slate">
                  🕐 {f?.gioMoCua ?? f?.openTime} – {f?.gioDongCua ?? f?.closeTime}
                </span>
              </div>
              {(f?.moTa ?? f?.description) && (
                <p className="text-sm text-vs-slate mt-3 leading-relaxed">{f.moTa ?? f.description}</p>
              )}
            </div>

            {/* Courts list */}
            {courts.length > 0 && (
              <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5">
                <h2 className="font-bold text-vs-navy mb-4">Danh sách sân</h2>
                <div className="space-y-3">
                  {courts.map((c: Record<string, unknown>, i: number) => (
                    <div key={i} className="flex items-center justify-between py-3 border-b border-slate-50 last:border-0">
                      <div>
                        <p className="font-medium text-vs-navy text-sm">{String(c.tenSan ?? c.courtName ?? `Sân ${i + 1}`)}</p>
                        <p className="text-xs text-vs-slate">{String(c.loaiSan ?? c.sportName ?? '')}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-bold text-vs-blue">{fmtCurrency(Number(c.giaThue ?? c.price ?? 0))}/h</p>
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                          String(c.trangThai ?? c.status) === 'Sẵn sàng'
                            ? 'bg-green-100 text-green-700'
                            : 'bg-slate-100 text-slate-500'
                        }`}>
                          {String(c.trangThai ?? c.status ?? 'Sẵn sàng')}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* CTA sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-2xl border border-slate-100 shadow-sm p-5 sticky top-20">
              <p className="text-2xl font-bold text-vs-blue mb-1">
                từ {fmtCurrency(f?.giaToiThieu ?? f?.minPrice ?? 0)}
              </p>
              <p className="text-xs text-vs-slate mb-4">mỗi giờ</p>
              <Link
                href={`/dat-san/${params.id}`}
                className="block w-full text-center py-3 bg-vs-blue text-white font-bold rounded-xl hover:bg-blue-700 transition-colors"
              >
                Đặt sân ngay
              </Link>
              <p className="text-xs text-vs-slate text-center mt-3">
                {courts.length} sân · {f?.readyCourtCount ?? courts.length} sẵn sàng
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export async function generateMetadata({ params }: { params: { id: string } }) {
  const data = await getFacilityDetail(params.id)
  const name = data?.facility?.tenCoSo ?? data?.name ?? 'Chi tiết cơ sở'
  return { title: `${name} | V-SPORT` }
}
