import { getQrCourts } from '@/lib/api/manager-pages'
import QrClient from './QrClient'

export const metadata = { title: 'Mã QR sân | V-SPORT Manager' }

export default async function MaQrSanPage() {
  const data = await getQrCourts()
  return <QrClient courts={data?.courts ?? []} qrRequests={data?.qrRequests ?? []} />
}
