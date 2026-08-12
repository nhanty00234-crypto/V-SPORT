'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'

interface Team {
  doiId: number
  tenDoi: string
  monTheThao: string
  soThanhVien: number
  vaiTro: string
  trangThai: string
  avatar?: string
}

export default function DoiNhomClient() {
  const [teams, setTeams] = useState<Team[]>([])
  const [loading, setLoading] = useState(true)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  useEffect(() => {
    fetch(`${BASE}/customer/api/teams`, {
      credentials: 'include',
      headers: { 'X-Requested-With': 'XMLHttpRequest' },
    })
      .then(r => r.ok ? r.json() : null)
      .then(data => { if (data?.teams) setTeams(data.teams) })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-black text-vs-navy">Đội nhóm</h1>
        <Link href="/doi-nhom/tao"
          className="bg-vs-blue text-white px-4 py-2 rounded-xl text-sm font-semibold hover:bg-blue-700 transition-colors">
          + Tạo đội mới
        </Link>
      </div>

      {loading ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-400">Đang tải...</div>
      ) : teams.length === 0 ? (
        <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center">
          <p className="text-4xl mb-3">👥</p>
          <p className="font-medium text-slate-600 mb-2">Bạn chưa có đội nhóm nào</p>
          <p className="text-sm text-slate-400 mb-4">Tạo đội mới hoặc tham gia đội của bạn bè</p>
          <Link href="/doi-nhom/tao"
            className="inline-block bg-vs-blue text-white px-6 py-2.5 rounded-xl font-semibold">
            Tạo đội ngay
          </Link>
        </div>
      ) : (
        <div className="space-y-3">
          {teams.map(t => (
            <Link key={t.doiId} href={`/doi-nhom/${t.doiId}`}
              className="block bg-white border border-slate-200 rounded-2xl p-4 hover:shadow-sm hover:border-blue-200 transition-all">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center text-white font-black text-lg flex-shrink-0">
                  {t.tenDoi.charAt(0)}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-bold text-slate-800 truncate">{t.tenDoi}</p>
                  <p className="text-sm text-slate-400">{t.monTheThao} · {t.soThanhVien} thành viên</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <span className={`px-2 py-0.5 rounded-full text-[11px] font-semibold ${t.vaiTro === 'Trưởng đội' ? 'bg-yellow-100 text-yellow-700' : 'bg-blue-100 text-blue-700'}`}>
                    {t.vaiTro}
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}

      <div className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-center">
        <p className="text-sm text-slate-500">Chức năng đội nhóm đầy đủ tại</p>
        <a href={`${BASE?.replace('/Backend_java', '')}/Backend_java/customer/doi-nhom`} target="_blank" rel="noopener noreferrer"
          className="text-vs-blue text-sm font-semibold hover:underline">
          Giao diện đội nhóm cũ →
        </a>
      </div>
    </div>
  )
}
