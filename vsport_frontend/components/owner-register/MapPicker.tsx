'use client'

import { useRef, useEffect, useState } from 'react'
import Script from 'next/script'

interface Props {
  viDo?: string
  kinhDo?: string
  onChange: (lat: string, lng: string) => void
}

const API_KEY = process.env.NEXT_PUBLIC_GOOGLE_MAPS_KEY

declare global {
  interface Window {
    google?: {
      maps: {
        Map: new (
          el: HTMLElement,
          opts: { center: { lat: number; lng: number }; zoom: number }
        ) => {
          addListener: (
            event: string,
            fn: (e: { latLng: { lat: () => number; lng: () => number } }) => void
          ) => void
        }
        Marker: new (opts: {
          map: unknown
          position: { lat: number; lng: number }
        }) => { setPosition: (p: { lat: number; lng: number }) => void }
      }
    }
  }
}

export default function MapPicker({ viDo, kinhDo, onChange }: Props) {
  const mapRef = useRef<HTMLDivElement>(null)
  const [mapsLoaded, setMapsLoaded] = useState(false)
  const [localLat, setLocalLat] = useState(viDo ?? '')
  const [localLng, setLocalLng] = useState(kinhDo ?? '')

  useEffect(() => {
    if (!mapsLoaded || !mapRef.current || !window.google) return
    const center =
      viDo && kinhDo
        ? { lat: parseFloat(viDo), lng: parseFloat(kinhDo) }
        : { lat: 10.8231, lng: 106.6297 }

    const map = new window.google.maps.Map(mapRef.current, { center, zoom: 13 })
    const marker = new window.google.maps.Marker({ map, position: center })

    map.addListener('click', (e: { latLng: { lat: () => number; lng: () => number } }) => {
      const lat = e.latLng.lat().toFixed(6)
      const lng = e.latLng.lng().toFixed(6)
      marker.setPosition({ lat: parseFloat(lat), lng: parseFloat(lng) })
      onChange(lat, lng)
    })
  }, [mapsLoaded]) // eslint-disable-line react-hooks/exhaustive-deps

  if (!API_KEY) {
    return (
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label htmlFor="viDo" className="block text-xs text-vs-slate mb-1">
            Vĩ độ
          </label>
          <input
            id="viDo"
            type="number"
            step="any"
            placeholder="Vĩ độ (10.82...)"
            value={localLat}
            onChange={e => {
              setLocalLat(e.target.value)
              onChange(e.target.value, localLng)
            }}
            className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
        </div>
        <div>
          <label htmlFor="kinhDo" className="block text-xs text-vs-slate mb-1">
            Kinh độ
          </label>
          <input
            id="kinhDo"
            type="number"
            step="any"
            placeholder="Kinh độ (106.62...)"
            value={localLng}
            onChange={e => {
              setLocalLng(e.target.value)
              onChange(localLat, e.target.value)
            }}
            className="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm text-vs-navy focus:border-vs-blue focus:ring-2 focus:ring-vs-blue/20 outline-none"
          />
        </div>
      </div>
    )
  }

  return (
    <>
      <Script
        src={`https://maps.googleapis.com/maps/api/js?key=${API_KEY}`}
        onLoad={() => setMapsLoaded(true)}
      />
      <div
        ref={mapRef}
        className="w-full h-64 rounded-xl border border-slate-200 bg-slate-50"
      />
      {!mapsLoaded && (
        <p className="text-center text-vs-slate text-sm mt-2">Đang tải bản đồ...</p>
      )}
    </>
  )
}
