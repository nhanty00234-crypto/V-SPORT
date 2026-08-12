'use client'

import { useState, useEffect } from 'react'
import { getReputation } from '@/lib/api/customer'
import type { ReputationData } from '@/types/customer'

export default function ReputationClient() {
  const [data, setData] = useState<ReputationData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    getReputation().then(d => { setData(d); setLoading(false) })
  }, [])

  if (loading) return <div className="text-vs-slate text-sm py-8 text-center">Đang tải...</div>

  const score = data?.score ?? 100
  const pct = Math.min(100, Math.max(0, score))
  const color = score >= 80 ? 'bg-green-500' : score >= 50 ? 'bg-yellow-400' : 'bg-red-400'

  return (
    <div>
      {/* Score card */}
      <div className="bg-gradient-to-br from-vs-navy to-blue-900 rounded-2xl p-6 text-white mb-6">
        <p className="text-sm text-blue-200 mb-1">Điểm uy tín của bạn</p>
        <p className="text-5xl font-bold mb-3">{score}</p>
        <div className="w-full bg-white/20 rounded-full h-2">
          <div className={`${color} h-2 rounded-full transition-all`} style={{ width: `${pct}%` }} />
        </div>
        <p className="text-xs text-blue-200 mt-2">
          {score >= 80 ? '✨ Xuất sắc — Bạn là khách hàng tin cậy' :
           score >= 60 ? '👍 Tốt' :
           score >= 40 ? '⚠️ Cần cải thiện' : '❌ Thấp — Cần chú ý'}
        </p>
      </div>

      {/* History */}
      <h2 className="font-semibold text-vs-navy mb-3">Lịch sử biến động</h2>
      {(!data?.history || data.history.length === 0) ? (
        <p className="text-sm text-vs-slate">Chưa có lịch sử biến động.</p>
      ) : (
        <div className="space-y-2">
          {data.history.map(h => (
            <div key={h.id} className="bg-white rounded-xl border border-slate-100 p-4 flex items-center justify-between">
              <div>
                <p className="text-sm text-vs-navy font-medium">{h.reason ?? h.actionType ?? 'Biến động điểm'}</p>
                <p className="text-xs text-vs-slate">{h.createdAt?.slice(0, 10) ?? ''}</p>
              </div>
              <span className={`text-lg font-bold ${h.change >= 0 ? 'text-green-600' : 'text-red-500'}`}>
                {h.change >= 0 ? `+${h.change}` : h.change}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
