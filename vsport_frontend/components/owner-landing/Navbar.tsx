'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 10)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-vs-navy/90 backdrop-blur-md border-b border-white/10 shadow-lg'
          : 'bg-transparent'
      }`}
    >
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <Link href="/" className="text-white font-bold text-xl tracking-tight flex">
          <span>V-</span><span className="text-vs-cyan">SPORT</span>
        </Link>

        <div className="hidden md:flex items-center gap-8">
          <a href="#tinh-nang" className="text-slate-300 hover:text-white text-sm transition-colors">
            Tính năng
          </a>
          <a href="#thong-ke" className="text-slate-300 hover:text-white text-sm transition-colors">
            Thống kê
          </a>
          <a href="#lien-he" className="text-slate-300 hover:text-white text-sm transition-colors">
            Liên hệ
          </a>
        </div>

        <div className="flex items-center gap-3">
          <Link
            href="/dang-nhap"
            className="text-slate-300 hover:text-white text-sm transition-colors px-3 py-1.5"
          >
            Đăng nhập
          </Link>
          <Link
            href="/owner-register"
            className="bg-vs-blue hover:bg-blue-700 text-white text-sm font-semibold px-4 py-2 rounded-lg transition-colors"
          >
            Đăng ký
          </Link>
        </div>
      </nav>
    </header>
  )
}
