'use client'
import { useEffect, useState } from 'react'
import Link from 'next/link'

interface Member {
  accountId: number
  fullName: string
  memberRole: 'CAPTAIN' | 'CO_CAPTAIN' | 'MEMBER'
  avatarUrl?: string
}

interface JoinRequest {
  joinRequestId: number
  requesterName: string
  message?: string
}

interface Match {
  keoId: number
  tenCoSo: string
  tenSan: string
  ngayDat: string
  gioBatDau: string
  gioKetThuc: string
  trangThai: string
  teamNameNguoiTao?: string
}

interface TeamDetail {
  teamId: number
  teamName: string
  sportName: string
  locationText?: string
  description?: string
  memberCount: number
  maxMembers: number
  captainName: string
  captain: boolean
  coCaptain: boolean
  myRole?: string
  members: Member[]
}

const ROLE_LABEL: Record<string, string> = { CAPTAIN: 'Đội trưởng', CO_CAPTAIN: 'Đội phó', MEMBER: 'Thành viên' }
const STATUS_COLOR: Record<string, string> = {
  'Đang mở': 'bg-green-100 text-green-700',
  'Đã đủ người': 'bg-yellow-100 text-yellow-700',
  'Đã hủy': 'bg-red-100 text-red-700',
}

export default function DoiNhomChiTietClient({ id }: { id: string }) {
  const [team, setTeam] = useState<TeamDetail | null>(null)
  const [joinRequests, setJoinRequests] = useState<JoinRequest[]>([])
  const [openMatches, setOpenMatches] = useState<Match[]>([])
  const [myMatches, setMyMatches] = useState<Match[]>([])
  const [loading, setLoading] = useState(true)
  const [joining, setJoining] = useState(false)
  const [toast, setToast] = useState<{ msg: string; ok: boolean } | null>(null)

  const BASE = process.env.NEXT_PUBLIC_BACKEND_URL

  function showToast(msg: string, ok = true) {
    setToast({ msg, ok })
    setTimeout(() => setToast(null), 3000)
  }

  async function post(path: string, body: object) {
    const res = await fetch(`${BASE}${path}`, {
      method: 'POST', credentials: 'include',
      headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
      body: JSON.stringify(body),
    })
    return res.ok ? res.json() : null
  }

  useEffect(() => {
    Promise.all([
      fetch(`${BASE}/customer/api/team-detail?id=${id}`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : null),
      fetch(`${BASE}/customer/api/team-matches?excludeTeamId=${id}`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : null),
      fetch(`${BASE}/customer/api/team-matches/mine?teamId=${id}`, { credentials: 'include', headers: { 'X-Requested-With': 'XMLHttpRequest' } }).then(r => r.ok ? r.json() : null),
    ]).then(([teamData, openData, mineData]) => {
      if (teamData) {
        setTeam(teamData.team ?? teamData)
        setJoinRequests(teamData.joinRequests ?? [])
      }
      if (Array.isArray(openData)) setOpenMatches(openData)
      if (Array.isArray(mineData)) setMyMatches(mineData)
    }).catch(() => {}).finally(() => setLoading(false))
  }, [id, BASE])

  async function handleJoin() {
    setJoining(true)
    const data = await post('/customer/doi-nhom/xin-tham-gia', { teamId: Number(id) }).catch(() => null)
    showToast(data?.message ?? 'Đã gửi yêu cầu tham gia.', data?.success ?? false)
    setJoining(false)
  }

  async function handleLeave() {
    if (!confirm('Bạn có chắc muốn rời đội?')) return
    const data = await post('/customer/doi-nhom/roi-doi', { teamId: Number(id) }).catch(() => null)
    showToast(data?.message ?? 'Đã rời đội.', data?.success ?? false)
    if (data?.success) setTimeout(() => window.location.href = '/doi-nhom', 500)
  }

  async function handleDisband() {
    if (!confirm('Giải tán đội? Hành động không thể hoàn tác.')) return
    const data = await post('/customer/doi-nhom/giai-tan', { teamId: Number(id) }).catch(() => null)
    showToast(data?.message ?? 'Đã giải tán đội.', data?.success ?? false)
    if (data?.success) setTimeout(() => window.location.href = '/doi-nhom', 500)
  }

  async function handleRemoveMember(accountId: number, name: string) {
    if (!confirm(`Xóa "${name}" khỏi đội?`)) return
    const data = await post('/customer/doi-nhom/xoa-thanh-vien', { teamId: Number(id), accountId }).catch(() => null)
    showToast(data?.message ?? 'Đã xóa.', data?.success ?? false)
    if (data?.success) setTeam(t => t ? { ...t, members: t.members.filter(m => m.accountId !== accountId) } : t)
  }

  async function handleApproveJR(joinRequestId: number) {
    const data = await post('/customer/doi-nhom/duyet-tham-gia', { joinRequestId }).catch(() => null)
    showToast(data?.message ?? 'Đã duyệt.', data?.success ?? false)
    if (data?.success) { setJoinRequests(jrs => jrs.filter(j => j.joinRequestId !== joinRequestId)); window.location.reload() }
  }

  async function handleRejectJR(joinRequestId: number) {
    const data = await post('/customer/doi-nhom/tu-choi-tham-gia', { joinRequestId }).catch(() => null)
    showToast(data?.message ?? 'Đã từ chối.', data?.success ?? false)
    if (data?.success) setJoinRequests(jrs => jrs.filter(j => j.joinRequestId !== joinRequestId))
  }

  if (loading) return <div className="text-center py-12 text-slate-400">Đang tải...</div>

  if (!team) return (
    <div className="text-center py-12">
      <p className="text-slate-500 mb-4">Không tìm thấy đội nhóm.</p>
      <Link href="/doi-nhom" className="text-vs-blue hover:underline">← Quay lại</Link>
    </div>
  )

  const isLeader = team.captain || team.coCaptain
  const isMember = !!team.myRole

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      {toast && (
        <div className={`fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-6 py-3 rounded-full text-white text-sm font-semibold shadow-lg transition-all ${toast.ok ? 'bg-green-600' : 'bg-red-600'}`}>
          {toast.msg}
        </div>
      )}

      <div className="flex items-center gap-3">
        <Link href="/doi-nhom" className="text-slate-400 hover:text-slate-600">←</Link>
        <h1 className="text-2xl font-black text-vs-navy">{team.teamName}</h1>
      </div>

      {/* Cover + info */}
      <div className="bg-white border border-slate-200 rounded-2xl overflow-hidden">
        <div className="h-24 bg-gradient-to-br from-emerald-700 to-emerald-500"></div>
        <div className="px-5 pb-5">
          <div className="-mt-8 mb-3">
            <div className="w-16 h-16 rounded-full border-4 border-white bg-emerald-100 flex items-center justify-center text-2xl font-black text-emerald-700 shadow">
              {team.teamName.charAt(0)}
            </div>
          </div>
          <p className="text-xl font-black text-slate-800 mb-1">{team.teamName}</p>
          <div className="flex flex-wrap gap-2 text-sm text-slate-500 mb-2">
            <span className="bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full font-semibold text-xs">{team.sportName}</span>
            <span>{team.memberCount}/{team.maxMembers} thành viên</span>
            <span>Đội trưởng: <strong>{team.captainName}</strong></span>
            {team.locationText && <span>📍 {team.locationText}</span>}
          </div>
          {team.description && <p className="text-sm text-slate-600 bg-slate-50 rounded-xl px-4 py-2">{team.description}</p>}
        </div>
      </div>

      {/* Actions */}
      <div className="flex flex-wrap gap-2">
        {team.captain && (
          <>
            <button onClick={handleDisband} className="border border-red-200 text-red-600 px-4 py-2 rounded-xl text-sm font-semibold hover:bg-red-50">Giải tán đội</button>
            <Link href={`${BASE}/customer/doi-nhom/chinh-sua?id=${id}`} className="border border-slate-200 text-slate-600 px-4 py-2 rounded-xl text-sm font-semibold hover:bg-slate-50">Chỉnh sửa</Link>
          </>
        )}
        {isMember && !team.captain && (
          <button onClick={handleLeave} className="border border-red-200 text-red-600 px-4 py-2 rounded-xl text-sm font-semibold hover:bg-red-50">Rời đội</button>
        )}
        {!isMember && (
          <button onClick={handleJoin} disabled={joining || team.memberCount >= team.maxMembers}
            className="bg-vs-blue text-white px-4 py-2 rounded-xl text-sm font-semibold disabled:opacity-50 hover:bg-blue-700">
            {team.memberCount >= team.maxMembers ? 'Đã đủ người' : joining ? 'Đang gửi...' : 'Xin tham gia'}
          </button>
        )}
      </div>

      {/* Members */}
      <div className="bg-white border border-slate-200 rounded-2xl p-5">
        <h2 className="font-black text-slate-800 mb-3">Thành viên ({team.memberCount}/{team.maxMembers})</h2>
        <div className="space-y-2">
          {team.members.map(m => (
            <div key={m.accountId} className="flex items-center gap-3 p-3 border border-slate-100 rounded-xl">
              <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-700 font-bold flex-shrink-0">
                {m.fullName.charAt(0)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-slate-800 text-sm">{m.fullName}</p>
                <p className="text-xs text-slate-400">{ROLE_LABEL[m.memberRole]}</p>
              </div>
              {isLeader && m.memberRole !== 'CAPTAIN' && (
                <button onClick={() => handleRemoveMember(m.accountId, m.fullName)}
                  className="text-xs text-red-500 border border-red-200 px-2 py-1 rounded-lg hover:bg-red-50">Xóa</button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Join requests */}
      {isLeader && joinRequests.length > 0 && (
        <div className="bg-white border border-slate-200 rounded-2xl p-5">
          <h2 className="font-black text-slate-800 mb-3">Yêu cầu tham gia ({joinRequests.length})</h2>
          <div className="space-y-2">
            {joinRequests.map(jr => (
              <div key={jr.joinRequestId} className="flex items-center gap-3 p-3 border border-slate-100 rounded-xl">
                <div className="flex-1">
                  <p className="font-semibold text-slate-800 text-sm">{jr.requesterName}</p>
                  {jr.message && <p className="text-xs text-slate-400">{jr.message}</p>}
                </div>
                <div className="flex gap-2">
                  <button onClick={() => handleApproveJR(jr.joinRequestId)} className="text-xs text-green-600 border border-green-200 px-2 py-1 rounded-lg hover:bg-green-50">Duyệt</button>
                  <button onClick={() => handleRejectJR(jr.joinRequestId)} className="text-xs text-red-500 border border-red-200 px-2 py-1 rounded-lg hover:bg-red-50">Từ chối</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* My matches */}
      {isLeader && (
        <div className="bg-white border border-slate-200 rounded-2xl p-5">
          <h2 className="font-black text-slate-800 mb-3">Kèo của đội tôi</h2>
          {myMatches.length === 0 ? (
            <p className="text-sm text-slate-400">Đội bạn chưa tạo kèo nào.</p>
          ) : (
            <div className="space-y-2">
              {myMatches.map(m => (
                <div key={m.keoId} className="border border-slate-100 rounded-xl p-3">
                  <div className="flex items-start justify-between">
                    <div>
                      <p className="font-semibold text-slate-800 text-sm">{m.tenCoSo} – {m.tenSan}</p>
                      <p className="text-xs text-slate-400">{m.ngayDat} · {m.gioBatDau}–{m.gioKetThuc}</p>
                    </div>
                    <span className={`text-xs px-2 py-0.5 rounded-full font-semibold ${STATUS_COLOR[m.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>{m.trangThai}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Open matches */}
      <div className="bg-white border border-slate-200 rounded-2xl p-5">
        <h2 className="font-black text-slate-800 mb-3">Kèo đang mở (từ đội khác)</h2>
        {openMatches.length === 0 ? (
          <p className="text-sm text-slate-400">Hiện chưa có kèo đội nào đang mở.</p>
        ) : (
          <div className="space-y-2">
            {openMatches.map(m => (
              <div key={m.keoId} className="border border-slate-100 rounded-xl p-3">
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-semibold text-slate-800 text-sm">{m.tenCoSo} – {m.tenSan}</p>
                    <p className="text-xs text-slate-400">{m.ngayDat} · {m.gioBatDau}–{m.gioKetThuc}</p>
                    {m.teamNameNguoiTao && <p className="text-xs text-slate-400">Đội: {m.teamNameNguoiTao}</p>}
                  </div>
                  <span className={`text-xs px-2 py-0.5 rounded-full font-semibold ${STATUS_COLOR[m.trangThai] ?? 'bg-slate-100 text-slate-600'}`}>{m.trangThai}</span>
                </div>
                {isLeader && (
                  <button onClick={async () => {
                    const data = await post('/customer/doi-nhom/thach-dau', { keoId: m.keoId, challengerTeamId: Number(id) }).catch(() => null)
                    showToast(data?.message ?? 'Đã gửi thách đấu.', data?.success ?? false)
                  }} className="mt-2 w-full bg-vs-blue text-white py-1.5 rounded-lg text-xs font-semibold hover:bg-blue-700">
                    Thách đấu
                  </button>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-center">
        <a href={`${BASE}/customer/doi-nhom-chi-tiet?doiNhomId=${id}`} target="_blank" rel="noopener noreferrer"
          className="text-vs-blue text-sm font-semibold hover:underline">
          Xem đầy đủ tại giao diện JSP →
        </a>
      </div>
    </div>
  )
}
