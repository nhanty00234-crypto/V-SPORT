import { render, screen } from '@testing-library/react'
import PainPointsSection from '@/components/owner-landing/PainPointsSection'

describe('PainPointsSection', () => {
  it('renders section heading', () => {
    render(<PainPointsSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders exactly 3 pain point cards', () => {
    render(<PainPointsSection />)
    expect(screen.getAllByRole('article')).toHaveLength(3)
  })
})
