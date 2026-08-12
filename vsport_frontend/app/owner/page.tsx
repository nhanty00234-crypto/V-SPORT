import { getOwnerStats } from '@/lib/api/owner-landing'
import Navbar from '@/components/owner-landing/Navbar'
import HeroSection from '@/components/owner-landing/HeroSection'
import PainPointsSection from '@/components/owner-landing/PainPointsSection'
import SolutionSection from '@/components/owner-landing/SolutionSection'
import FeaturesSection from '@/components/owner-landing/FeaturesSection'
import StatsSection from '@/components/owner-landing/StatsSection'
import TestimonialsSection from '@/components/owner-landing/TestimonialsSection'
import FinalCTASection from '@/components/owner-landing/FinalCTASection'
import Footer from '@/components/owner-landing/Footer'
import ContactModalWrapper from '@/components/owner-landing/ContactModalWrapper'

export const revalidate = 3600

export default async function OwnerPage() {
  const stats = await getOwnerStats()

  return (
    <ContactModalWrapper>
      {({ openContact }) => (
        <main>
          <Navbar />
          <HeroSection onOpenContact={openContact} />
          <PainPointsSection />
          <SolutionSection />
          <FeaturesSection />
          <StatsSection stats={stats} />
          <TestimonialsSection />
          <FinalCTASection onOpenContact={openContact} />
          <Footer />
        </main>
      )}
    </ContactModalWrapper>
  )
}
