import { Suspense } from 'react'
import LoginCard from '@/components/auth/LoginCard'

export const metadata = { title: 'Đăng nhập | V-SPORT' }

export default function DangNhapPage() {
  return (
    <Suspense>
      <LoginCard />
    </Suspense>
  )
}
