import { Suspense } from 'react'
import OtpCard from '@/components/auth/OtpCard'

export const metadata = { title: 'Xác thực OTP | V-SPORT' }

export default function XacThucOtpPage() {
  return (
    <Suspense>
      <OtpCard />
    </Suspense>
  )
}
