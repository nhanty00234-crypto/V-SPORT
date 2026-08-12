'use client'

import { useState } from 'react'
import { OwnerStats } from '@/types/owner-landing'
import Navbar from './Navbar'
import HeroSection from './HeroSection'
import PainPointsSection from './PainPointsSection'
import SolutionSection from './SolutionSection'
import FeaturesSection from './FeaturesSection'
import StatsSection from './StatsSection'
import TestimonialsSection from './TestimonialsSection'
import FinalCTASection from './FinalCTASection'
import Footer from './Footer'
import ContactModal from './ContactModal'

interface Props {
  stats: OwnerStats | null
}

export default function OwnerPageClient({ stats }: Props) {
  const [contactOpen, setContactOpen] = useState(false)

  return (
    <main>
      <Navbar />
      <HeroSection onOpenContact={() => setContactOpen(true)} />
      <PainPointsSection />
      <SolutionSection />
      <FeaturesSection />
      <StatsSection stats={stats} />
      <TestimonialsSection />
      <FinalCTASection onOpenContact={() => setContactOpen(true)} />
      <Footer />
      <ContactModal isOpen={contactOpen} onClose={() => setContactOpen(false)} />
    </main>
  )
}
