'use client'

import { useState, useEffect } from 'react'
import { getNotifications, markAllNotificationsRead } from '@/lib/api/customer'
import type { NotificationPage, Notification } from '@/types/customer'

function timeAgo(dateStr: string | null): string {
  if (!dateStr) return ''
  const d = new Date(dateStr)
  const diff = Math.floor((Date.now() - d.getTime()) / 1000)
  if (diff < 60) return 'vừa xong'
  if (diff < 3600) return `${Math.floor(diff / 60)} phút trước`
  if (diff < 86400) return `${Math.floor(diff / 3600)} giờ trước`
  return `${Math.floor(diff / 86400)} ngày trước`
}

const LOAI_ICONS: Record<string, string> = {
  BOOKING: '📅',
  PAYMENT: '💳',
  SYSTEM: '🔔',
  PROMOTION: '🎁',
  REFUND: '💰',
}

export default function NotificationsClient() {
  const [data, setData] = useState<NotificationPage | null>(null)
  const [loading, setLoading] = useState(true)

  async function load() {
    setLoading(true)
    const d = await getNotifications(1)
    setData(d)
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  async function handleMarkAll() {
    await markAllNotificationsRead()
    await load()
  }

  if (loading) return <div className="text-vs-slate text-sm py-8 text-center">Đang tải...</div>

  if (!data || data.items.length === 0) {
    return <div className="text-center py-12 text-vs-slate text-sm">Không có thông báo nào.</div>
  }

  return (
    <div>
      {data.unread > 0 && (
        <div className="flex justify-between items-center mb-4">
          <p className="text-sm text-vs-slate">{data.unread} thông báo chưa đọc</p>
          <button
            onClick={handleMarkAll}
            className="text-xs text-vs-blue font-medium hover:underline"
          >
            Đánh dấu tất cả đã đọc
          </button>
        </div>
      )}

      <div className="space-y-2">
        {data.items.map((n: Notification) => (
          <div
            key={n.id}
            className={`bg-white rounded-xl border p-4 shadow-sm ${!n.daDoc ? 'border-vs-blue/20 bg-blue-50/30' : 'border-slate-100'}`}
          >
            <div className="flex items-start gap-3">
              <span className="text-xl flex-shrink-0">{LOAI_ICONS[n.loai ?? ''] ?? '🔔'}</span>
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2">
                  <p className={`text-sm font-medium ${!n.daDoc ? 'text-vs-navy' : 'text-slate-600'}`}>
                    {n.tieuDe}
                    {!n.daDoc && <span className="ml-2 inline-block w-2 h-2 rounded-full bg-vs-blue align-middle" />}
                  </p>
                  <span className="text-xs text-vs-slate flex-shrink-0">{timeAgo(n.thoiGian)}</span>
                </div>
                <p className="text-xs text-vs-slate mt-1 line-clamp-2">{n.noiDung}</p>
                {n.duongDan && (
                  <a href={n.duongDan} className="text-xs text-vs-blue hover:underline mt-1 inline-block">
                    Xem chi tiết →
                  </a>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
