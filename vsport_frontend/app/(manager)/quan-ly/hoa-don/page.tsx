import { getInvoices } from '@/lib/api/manager-pages'
import InvoicesClient from './InvoicesClient'

export const metadata = { title: 'Hóa đơn | V-SPORT Manager' }

export default async function HoaDonPage() {
  const data = await getInvoices()
  return <InvoicesClient data={data} />
}
