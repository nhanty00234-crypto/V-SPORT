import { getBookings } from '@/lib/api/manager-pages'
import BookingsClient from './BookingsClient'

export const metadata = { title: 'Đặt sân | V-SPORT Manager' }

export default async function DatSanPage() {
  const data = await getBookings()
  return <BookingsClient bookings={data?.bookings ?? []} />
}
