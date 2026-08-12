import DoiNhomChiTietClient from './DoiNhomChiTietClient'

export const metadata = { title: 'Chi tiết đội nhóm | V-SPORT' }

export default function DoiNhomChiTietPage({ params }: { params: { id: string } }) {
  return <DoiNhomChiTietClient id={params.id} />
}
