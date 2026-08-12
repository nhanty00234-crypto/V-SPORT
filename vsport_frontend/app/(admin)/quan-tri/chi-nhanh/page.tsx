import { getBranches } from '@/lib/api/admin-pages'
import BranchesClient from './BranchesClient'

export const metadata = { title: 'Chi nhánh | V-SPORT Admin' }

export default async function ChiNhanhPage() {
  const data = await getBranches()
  return <BranchesClient branches={data?.branches ?? []} />
}
