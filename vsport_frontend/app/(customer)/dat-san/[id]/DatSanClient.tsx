'use client'
import { useEffect, useState } from 'react'

interface CourtSlot {
  sanId: number
  tenSan: string
  slots: { time: string; available: boolean; price: number }[]
}

const HOURS = ['06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00']

export default function DatSanClient({ coSoId }: { coSoId: string }) {
  const [date, setDate] = useState(() => new Date().toISOString().split('T')[0])
  const [courts, setCourts] = useState<CourtSlot[]>([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState<{ sanId: number; tenSan: string; gioBatDau: string; gioKetThuc: string; price: number } | null>(null)
  const [startHour, setStartHour] = useState<string | null>(null)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  useEffect(() => {
    setLoading(true)
    fetch(`${BASE}/customer/api/timetable-availability?coSoId=${coSoId}&date=${date}`, {
      credentials: 'include',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
    })
      .then(r => r.ok ? r.json() : null)
      .then(data => {
        if (data?.courts) setCourts(data.courts)
        else setCourts([])
      })
      .catch(() => setCourts([]))
      .finally(() => setLoading(false))
  }, [coSoId, date])

  function handleSlotClick(sanId: number, tenSan: string, time: string, price: number) {
    if (!startHour) {
      setStartHour(time)
      const endIdx = HOURS.indexOf(time) + 1
      const endTime = HOURS[endIdx] ?? '23:00'
      setSelected({ sanId, tenSan, gioBatDau: time, gioKetThuc: endTime, price })
    } else {
      const startIdx = HOURS.indexOf(startHour)
      const endIdx = HOURS.indexOf(time)
      if (endIdx > startIdx) {
        setSelected({ sanId, tenSan, gioBatDau: startHour, gioKetThuc: time + ':00'.replace(':00:00', ':00'), price: price * (endIdx - startIdx) })
      }
      setStartHour(null)
    }
  }

  const jspUrl = `${BASE?.replace('/Backend_java', '')}/Backend_java/customer/dat-san?coSoId=${coSoId}&date=${date}`

  return (
    <div className="max-w-5xl mx-auto space-y-5">
      <div className="flex flex-wrap items-center gap-4">
        <h1 className="text-2xl font-black text-vs-navy">Đặt sân</h1>
        <input type="date" value={date} min={new Date().toISOString().split('T')[0]}
          onChange={e => setDate(e.target.value)}
          className="border border-slate-200 rounded-xl px-3 py-2 text-sm font-medium focus:outline-none focus:ring-2 focus:ring-blue-300" />
      </div>

      {selected && (
        <div className="bg-blue-50 border border-blue-200 rounded-2xl p-4 flex items-center justify-between gap-4">
          <div>
            <p className="font-bold text-blue-800">Đã chọn: {selected.tenSan}</p>
            <p className="text-sm text-blue-600">{date} · {selected.gioBatDau} – {selected.gioKetThuc}</p>
            <p className="font-bold text-blue-700 mt-1">{selected.price.toLocaleString('vi-VN')}đ</p>
          </div>
          <div className="flex gap-2">
            <button onClick={() => { setSelected(null); setStartHour(null) }}
              className="px-3 py-2 border border-slate-200 rounded-lg text-sm text-slate-600 hover:bg-slate-50">
              Bỏ chọn
            </button>
            <a href={`${jspUrl}&sanId=${selected.sanId}&gioBatDau=${selected.gioBatDau}&gioKetThuc=${selected.gioKetThuc}`}
              target="_blank" rel="noopener noreferrer"
              className="px-4 py-2 bg-vs-blue text-white rounded-lg text-sm font-bold hover:bg-blue-700">
              Xác nhận đặt sân →
            </a>
          </div>
        </div>
      )}

      {loading ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-400">
          Đang tải lịch sân...
        </div>
      ) : courts.length === 0 ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center">
          <p className="text-4xl mb-3">🏸</p>
          <p className="font-medium text-slate-600 mb-4">Không tải được thông tin sân. Vui lòng thử giao diện cũ.</p>
          <a href={jspUrl} target="_blank" rel="noopener noreferrer"
            className="inline-block bg-vs-blue text-white px-6 py-3 rounded-xl font-semibold hover:bg-blue-700 transition-colors">
            Đặt sân tại đây →
          </a>
        </div>
      ) : (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-xs">
              <thead className="bg-slate-50">
                <tr>
                  <th className="px-3 py-3 text-left font-semibold text-slate-600 sticky left-0 bg-slate-50 z-10 min-w-[120px]">Sân / Giờ</th>
                  {HOURS.map(h => <th key={h} className="px-2 py-3 text-center font-semibold text-slate-500 min-w-[60px]">{h}</th>)}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {courts.map(court => (
                  <tr key={court.sanId} className="hover:bg-slate-50">
                    <td className="px-3 py-2 font-semibold text-slate-700 sticky left-0 bg-white z-10">{court.tenSan}</td>
                    {HOURS.map(h => {
                      const slot = court.slots?.find(s => s.time === h)
                      const isAvailable = slot ? slot.available : true
                      const isSelected = selected?.sanId === court.sanId && (h === selected.gioBatDau || (h > selected.gioBatDau && h < selected.gioKetThuc))
                      const isStart = startHour === h && selected?.sanId === court.sanId
                      return (
                        <td key={h} className="px-1 py-2 text-center">
                          <button
                            onClick={() => isAvailable && handleSlotClick(court.sanId, court.tenSan, h, slot?.price ?? 0)}
                            disabled={!isAvailable}
                            className={`w-full h-8 rounded text-[10px] font-medium transition-colors ${
                              isSelected || isStart
                                ? 'bg-blue-500 text-white'
                                : isAvailable
                                ? 'bg-green-100 text-green-700 hover:bg-green-200'
                                : 'bg-red-100 text-red-500 cursor-not-allowed'
                            }`}
                          >
                            {isAvailable ? (slot?.price ? `${Math.round(slot.price / 1000)}k` : '✓') : '✗'}
                          </button>
                        </td>
                      )
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="px-4 py-3 border-t border-slate-100 flex gap-4 text-xs">
            <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-green-100 inline-block"></span>Trống</span>
            <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-red-100 inline-block"></span>Đã đặt</span>
            <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-blue-500 inline-block"></span>Đang chọn</span>
            <span className="ml-auto text-slate-400">Nhấn 2 lần để chọn khung giờ. Hoặc <a href={jspUrl} target="_blank" rel="noopener noreferrer" className="text-blue-600 underline">dùng giao diện đầy đủ</a>.</span>
          </div>
        </div>
      )}
    </div>
  )
}
