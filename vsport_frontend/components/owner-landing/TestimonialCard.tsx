import { Star } from 'lucide-react'
import { Testimonial } from '@/types/owner-landing'

interface Props {
  testimonial: Testimonial
}

export default function TestimonialCard({ testimonial }: Props) {
  return (
    <div className="bg-white rounded-2xl p-8 shadow-sm border border-slate-100 h-full flex flex-col">
      <div className="flex gap-1 mb-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            className={`w-4 h-4 ${i < testimonial.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-200'}`}
          />
        ))}
      </div>

      <p className="text-vs-slate text-sm leading-relaxed flex-1 mb-6 italic">
        &ldquo;{testimonial.content}&rdquo;
      </p>

      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-vs-blue/10 flex items-center justify-center text-vs-blue font-bold text-sm shrink-0">
          {testimonial.ownerName.charAt(0)}
        </div>
        <div>
          <p className="text-vs-navy font-semibold text-sm">{testimonial.ownerName}</p>
          <p className="text-vs-slate text-xs">{testimonial.facilityName}</p>
        </div>
      </div>
    </div>
  )
}
