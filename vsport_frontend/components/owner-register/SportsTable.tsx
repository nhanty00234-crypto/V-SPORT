'use client'

import { Plus, X } from 'lucide-react'
import type { SportRow } from '@/types/owner-register'

const SPORTS = [
  'Cầu lông', 'Bóng đá', 'Bida', 'Pickleball',
  'Tennis', 'Bóng rổ', 'Bóng chuyền', 'Bơi lội',
]

interface Props {
  value: SportRow[]
  onChange: (rows: SportRow[]) => void
}

export default function SportsTable({ value, onChange }: Props) {
  const usedSports = value.map(r => r.sport)
  const available = SPORTS.filter(s => !usedSports.includes(s))

  const addRow = () => {
    if (available.length === 0) return
    onChange([...value, { sport: available[0], quantity: 1 }])
  }

  const removeRow = (i: number) => {
    onChange(value.filter((_, idx) => idx !== i))
  }

  const updateSport = (i: number, sport: string) => {
    onChange(value.map((r, idx) => (idx === i ? { ...r, sport } : r)))
  }

  const updateQuantity = (i: number, qty: number) => {
    onChange(value.map((r, idx) => (idx === i ? { ...r, quantity: qty } : r)))
  }

  return (
    <div className="space-y-3">
      {value.map((row, i) => (
        <div key={i} className="flex items-center gap-3">
          <select
            value={row.sport}
            onChange={e => updateSport(i, e.target.value)}
            className="flex-1 rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          >
            {SPORTS.filter(s => s === row.sport || !usedSports.includes(s)).map(s => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>

          <input
            type="number"
            min={1}
            max={99}
            value={row.quantity}
            onChange={e => updateQuantity(i, parseInt(e.target.value) || 1)}
            className="w-20 rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy text-center focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
          <span className="text-vs-slate text-sm shrink-0">sân</span>

          {value.length > 1 && (
            <button
              type="button"
              onClick={() => removeRow(i)}
              aria-label="Xóa"
              className="text-slate-400 hover:text-red-500 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>
      ))}

      {available.length > 0 && (
        <button
          type="button"
          onClick={addRow}
          className="flex items-center gap-2 text-vs-blue text-sm font-medium hover:text-vs-navy transition-colors mt-1"
        >
          <Plus className="w-4 h-4" /> Thêm môn
        </button>
      )}
    </div>
  )
}
