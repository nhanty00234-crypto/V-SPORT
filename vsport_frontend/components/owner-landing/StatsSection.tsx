import AnimatedCounter from './AnimatedCounter'
import { OwnerStats } from '@/types/owner-landing'

interface Props {
  stats: OwnerStats | null
}

const STATS_CONFIG = [
  { key: 'totalFacilities' as const, label: 'Cơ sở đang hoạt động', suffix: '+' },
  { key: 'totalCourts'     as const, label: 'Sân thể thao',          suffix: '+' },
  { key: 'totalBookings'   as const, label: 'Lượt đặt sân',          suffix: '+' },
  { key: 'totalCustomers'  as const, label: 'Khách hàng tin dùng',   suffix: '+' },
]

export default function StatsSection({ stats }: Props) {
  return (
    <section id="thong-ke" className="py-24 bg-vs-navy">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-white mb-4">
            Những con số nói lên tất cả
          </h2>
          <p className="text-slate-400 text-lg">
            V-Sport đang phục vụ hàng trăm cơ sở thể thao trên toàn quốc.
          </p>
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {STATS_CONFIG.map(({ key, label, suffix }) => (
            <div key={key} className="text-center">
              <div className="text-4xl sm:text-5xl font-extrabold text-vs-cyan mb-2">
                {stats ? (
                  <AnimatedCounter target={stats[key]} suffix={suffix} />
                ) : (
                  <span>--</span>
                )}
              </div>
              <p className="text-slate-400 text-sm font-medium">{label}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
