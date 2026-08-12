import Link from 'next/link'
import ProgressBar from './ProgressBar'

const BACKEND = process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:8080/Backend_java'

interface Props {
  currentStep: 1 | 2 | 3
}

export default function RegisterHeader({ currentStep }: Props) {
  return (
    <header className="sticky top-0 z-50 bg-white shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center justify-between border-b border-slate-100">
        <Link
          href="/owner"
          className="font-bold text-xl tracking-tight flex items-center"
          aria-label="Về trang chủ V-Sport"
        >
          <span className="text-vs-navy">V-</span>
          <span className="text-vs-cyan">SPORT</span>
        </Link>

        <a
          href={`${BACKEND}/dangnhap`}
          className="text-sm text-vs-slate hover:text-vs-navy transition-colors"
        >
          Đăng nhập
        </a>
      </div>

      <ProgressBar currentStep={currentStep} />
    </header>
  )
}
