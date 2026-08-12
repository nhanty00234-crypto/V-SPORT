import { getTrash } from '@/lib/api/manager-pages'
import TrashClient from './TrashClient'

export const metadata = { title: 'Thùng rác | V-SPORT Manager' }

export default async function ThungRacPage() {
  const data = await getTrash()
  return <TrashClient data={data} />
}
