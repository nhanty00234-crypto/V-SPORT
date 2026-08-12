import { LucideIcon } from 'lucide-react'

interface Props {
  icon: LucideIcon
  title: string
  description: string
}

export default function FeatureCard({ icon: Icon, title, description }: Props) {
  return (
    <article className="group bg-white hover:bg-vs-blue border border-slate-100 hover:border-vs-blue rounded-2xl p-8 transition-all duration-300 shadow-sm hover:shadow-xl hover:-translate-y-1 cursor-default">
      <div className="w-12 h-12 bg-vs-blue/10 group-hover:bg-white/20 rounded-xl flex items-center justify-center mb-5 transition-colors">
        <Icon className="w-6 h-6 text-vs-blue group-hover:text-white transition-colors" />
      </div>
      <h3 className="text-lg font-bold text-vs-navy group-hover:text-white mb-3 transition-colors">
        {title}
      </h3>
      <p className="text-vs-slate group-hover:text-blue-100 text-sm leading-relaxed transition-colors">
        {description}
      </p>
    </article>
  )
}
