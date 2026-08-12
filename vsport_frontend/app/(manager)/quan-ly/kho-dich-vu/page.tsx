import { getInventory } from '@/lib/api/manager-pages'
import InventoryClient from './InventoryClient'

export const metadata = { title: 'Kho dịch vụ | V-SPORT Manager' }

export default async function KhoDichVuPage() {
  const data = await getInventory()
  return <InventoryClient data={data} />
}
