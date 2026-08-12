import { render, screen } from '@testing-library/react'
import SolutionSection from '@/components/owner-landing/SolutionSection'

describe('SolutionSection', () => {
  it('renders section heading', () => {
    render(<SolutionSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders at least 4 checklist items', () => {
    render(<SolutionSection />)
    expect(screen.getAllByRole('listitem').length).toBeGreaterThanOrEqual(4)
  })
})
