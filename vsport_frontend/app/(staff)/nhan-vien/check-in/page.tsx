import { getCheckInBookings } from '@/lib/api/staff-pages'
import CheckInClient from './CheckInClient'

export const metadata = { title: 'Check-in | V-SPORT Staff' }

export default async function CheckInPage() {
  const data = await getCheckInBookings()
  return <CheckInClient bookings={data?.bookings ?? []} />
}
