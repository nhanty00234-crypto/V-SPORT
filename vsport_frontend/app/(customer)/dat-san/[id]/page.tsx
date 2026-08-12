import DatSanClient from './DatSanClient'

export const metadata = { title: 'Đặt sân | V-SPORT' }

export default function DatSanPage({ params }: { params: { id: string } }) {
  return <DatSanClient coSoId={params.id} />
}
