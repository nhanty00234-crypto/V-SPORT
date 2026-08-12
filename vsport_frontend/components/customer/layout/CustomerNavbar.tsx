'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { useState, useEffect } from 'react'
import type { CustomerProfile } from '@/types/customer'

const BASE = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

interface Props {
  user: CustomerProfile
}

export default function CustomerNavbar({ user }: Props) {
  const pathname = usePathname()
  const router = useRouter()

  async function handleLogout() {
    await fetch(`${BASE}/dangxuat`, { credentials: 'include' })
    router.push('/dang-nhap')
  }

  const initials = user.fullName
    ? user.fullName.split(' ').slice(-1)[0]?.[0]?.toUpperCase() ?? 'U'
    : 'U'

  return (
    <header className="sticky top-0 z-40 bg-white border-b border-slate-100 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
        {/* Logo */}
        <Link href="/tim-kiem" className="font-bold text-xl tracking-tight flex-shrink-0">
          <span className="text-vs-navy">V-</span>
          <span className="text-vs-cyan">SPORT</span>
        </Link>

        {/* Search */}
        <form
          onSubmit={e => { e.preventDefault(); const v = (e.currentTarget.elements.namedItem('q') as HTMLInputElement).value; router.push(`/tim-kiem?q=${encodeURIComponent(v)}`) }}
          className="hidden sm:flex flex-1 max-w-sm"
        >
          <input
            name="q"
            type="search"
            placeholder="Tìm sân thể thao..."
            className="w-full px-3 py-1.5 text-sm rounded-full border border-slate-200 focus:outline-none focus:ring-2 focus:ring-vs-blue"
          />
        </form>

        {/* Actions */}
        <div className="flex items-center gap-2">
          {/* Notifications */}
          <Link href="/account/thong-bao" className="relative p-2 rounded-full hover:bg-slate-100 transition-colors">
            <svg className="w-5 h-5 text-vs-slate" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            {user.unreadNotifications > 0 && (
              <span className="absolute top-1 right-1 w-4 h-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold">
                {user.unreadNotifications > 9 ? '9+' : user.unreadNotifications}
              </span>
            )}
          </Link>

          {/* Avatar menu */}
          <div className="relative group">
            <button className="flex items-center gap-1.5 hover:opacity-80 transition-opacity">
              {user.avatarUrl ? (
                <img src={user.avatarUrl} alt="" className="w-8 h-8 rounded-full object-cover border-2 border-vs-cyan" />
              ) : (
                <div className="w-8 h-8 rounded-full bg-vs-navy text-white flex items-center justify-center text-sm font-bold">
                  {initials}
                </div>
              )}
            </button>
            <div className="absolute right-0 mt-1 w-48 bg-white border border-slate-100 rounded-xl shadow-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-50">
              <div className="px-4 py-3 border-b border-slate-50">
                <p className="text-sm font-semibold text-vs-navy truncate">{user.fullName}</p>
                <p className="text-xs text-vs-slate truncate">{user.email}</p>
              </div>
              <div className="py-1">
                <Link href="/account/tai-khoan" className="flex items-center gap-2 px-4 py-2 text-sm text-vs-navy hover:bg-slate-50">
                  Tài khoản của tôi
                </Link>
                <Link href="/account/lich-su" className="flex items-center gap-2 px-4 py-2 text-sm text-vs-navy hover:bg-slate-50">
                  Lịch sử đặt sân
                </Link>
                <Link href="/account/ho-so" className="flex items-center gap-2 px-4 py-2 text-sm text-vs-navy hover:bg-slate-50">
                  Hồ sơ
                </Link>
                <hr className="my-1 border-slate-100" />
                <button onClick={handleLogout} className="w-full text-left flex items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-red-50">
                  Đăng xuất
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
  )
}
