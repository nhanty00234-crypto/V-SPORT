import { getAuditLog } from '@/lib/api/manager-pages'
import AuditLogClient from './AuditLogClient'

export const metadata = { title: 'Audit Log | V-SPORT Manager' }

export default async function AuditLogPage() {
  const data = await getAuditLog()
  return <AuditLogClient logs={data?.logs ?? []} />
}
