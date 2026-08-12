'use client'

import { useState } from 'react'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

interface Props {
  initialMarketing: boolean
}

export default function NotificationSettingsClient({ initialMarketing }: Props) {
  const [marketing, setMarketing] = useState(initialMarketing)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)

  async function handleSave() {
    setSaving(true)
    setSaved(false)
    try {
      const body = new URLSearchParams()
      if (marketing) body.set('nhanThongBaoMarketing', 'on')
      await fetch(`${BASE}/customer/notification-settings`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString(),
      })
      setSaved(true)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="space-y-4 max-w-md">
      {/* Transactional — always on */}
      <div className="bg-white rounded-xl border border-slate-100 p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium text-vs-navy text-sm">Thông báo giao dịch</p>
            <p className="text-xs text-vs-slate mt-0.5">Đặt sân, thanh toán, hoàn tiền</p>
          </div>
          <div className="w-10 h-6 bg-green-500 rounded-full flex items-center justify-end px-1 cursor-not-allowed" title="Không thể tắt">
            <div className="w-4 h-4 bg-white rounded-full" />
          </div>
        </div>
        <p className="text-xs text-vs-slate mt-2 bg-slate-50 rounded-lg px-3 py-1.5">
          Loại thông báo này luôn bật để đảm bảo bạn nhận được thông tin quan trọng.
        </p>
      </div>

      {/* Marketing — toggleable */}
      <div className="bg-white rounded-xl border border-slate-100 p-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium text-vs-navy text-sm">Thông báo khuyến mãi</p>
            <p className="text-xs text-vs-slate mt-0.5">Ưu đãi từ cơ sở thể thao</p>
          </div>
          <button
            type="button"
            onClick={() => setMarketing(m => !m)}
            className={`w-10 h-6 rounded-full transition-colors flex items-center px-1 ${marketing ? 'bg-vs-blue justify-end' : 'bg-slate-200 justify-start'}`}
          >
            <div className="w-4 h-4 bg-white rounded-full shadow transition-all" />
          </button>
        </div>
      </div>

      {saved && (
        <p className="text-sm text-green-600 bg-green-50 rounded-lg px-4 py-2">Đã lưu cài đặt!</p>
      )}

      <button
        onClick={handleSave}
        disabled={saving}
        className="px-6 py-2.5 bg-vs-blue text-white font-semibold text-sm rounded-lg hover:bg-blue-700 disabled:opacity-60 transition-colors"
      >
        {saving ? 'Đang lưu...' : 'Lưu cài đặt'}
      </button>
    </div>
  )
}
