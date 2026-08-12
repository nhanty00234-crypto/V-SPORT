'use client'
import { useState } from 'react'
import type { Court, QRRequest } from '@/types/manager-pages'

const STATUS_COLOR: Record<string, string> = {
  'Chờ xử lý': 'bg-yellow-100 text-yellow-700',
  'Đã xử lý': 'bg-green-100 text-green-700',
  'Từ chối': 'bg-red-100 text-red-700',
}

export default function QrClient({ courts, qrRequests }: { courts: Court[]; qrRequests: QRRequest[] }) {
  const [activeTab, setActiveTab] = useState<'courts' | 'requests'>('courts')

  const pending = qrRequests.filter(q => q.status === 'Chờ xử lý').length

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-indigo-700">{courts.length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Tổng sân</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-yellow-700">{pending}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Yêu cầu chờ xử lý</p>
        </div>
        <div className="bg-white border border-slate-200 rounded-xl p-4">
          <p className="text-2xl font-black text-green-700">{qrRequests.filter(q => q.status === 'Đã xử lý').length}</p>
          <p className="text-xs font-semibold text-slate-500 mt-0.5">Đã xử lý</p>
        </div>
      </div>

      <div className="flex gap-2 border-b border-slate-200">
        <button onClick={() => setActiveTab('courts')}
          className={`px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors ${activeTab === 'courts' ? 'border-indigo-600 text-indigo-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
          Sân ({courts.length})
        </button>
        <button onClick={() => setActiveTab('requests')}
          className={`px-4 py-2.5 text-sm font-semibold border-b-2 transition-colors relative ${activeTab === 'requests' ? 'border-indigo-600 text-indigo-700' : 'border-transparent text-slate-500 hover:text-slate-700'}`}>
          Yêu cầu QR ({qrRequests.length})
          {pending > 0 && <span className="ml-1.5 bg-yellow-500 text-white text-[10px] px-1.5 rounded-full">{pending}</span>}
        </button>
      </div>

      {activeTab === 'courts' && (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {courts.map(c => (
            <div key={c.id} className="bg-white border border-slate-200 rounded-2xl p-5">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 bg-indigo-100 rounded-xl flex items-center justify-center text-xl">🏸</div>
                <div>
                  <p className="font-bold text-slate-800">{c.ten}</p>
                  <p className="text-xs text-slate-400">Sân #{c.id}</p>
                </div>
              </div>
              <div className="bg-slate-50 rounded-xl p-4 text-center">
                <div className="text-6xl mb-2">📷</div>
                <p className="text-xs text-slate-500">QR code sân này được tạo tự động bởi hệ thống</p>
              </div>
              <p className="text-xs text-slate-400 text-center mt-3 font-medium">
                Khách quét QR để đặt sân nhanh
              </p>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'requests' && (
        <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs">
                <tr>
                  <th className="px-4 py-3 text-left font-semibold">ID</th>
                  <th className="px-4 py-3 text-left font-semibold">Sân</th>
                  <th className="px-4 py-3 text-left font-semibold">Loại YC</th>
                  <th className="px-4 py-3 text-left font-semibold">Thời gian</th>
                  <th className="px-4 py-3 text-left font-semibold">Ghi chú</th>
                  <th className="px-4 py-3 text-left font-semibold">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {qrRequests.length === 0 ? (
                  <tr><td colSpan={6} className="px-4 py-8 text-center text-slate-400">Không có yêu cầu nào</td></tr>
                ) : qrRequests.map(q => (
                  <tr key={q.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-4 py-3 font-mono text-xs text-slate-500">#{q.id}</td>
                    <td className="px-4 py-3 text-slate-600">Sân #{q.sanId}</td>
                    <td className="px-4 py-3 text-slate-600">{q.requestType || '—'}</td>
                    <td className="px-4 py-3 text-slate-400 text-xs">{q.createdAt}</td>
                    <td className="px-4 py-3 text-slate-400 text-xs max-w-[200px] truncate">{q.note || '—'}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${STATUS_COLOR[q.status] ?? 'bg-slate-100 text-slate-600'}`}>
                        {q.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
