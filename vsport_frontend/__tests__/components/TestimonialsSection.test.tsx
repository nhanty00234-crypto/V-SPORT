import { render, screen } from '@testing-library/react'

jest.mock('embla-carousel-react', () => ({
  __esModule: true,
  default: () => [jest.fn(), null],
}))

import TestimonialsSection from '@/components/owner-landing/TestimonialsSection'

describe('TestimonialsSection', () => {
  it('renders section heading', () => {
    render(<TestimonialsSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders at least one testimonial owner name', () => {
    render(<TestimonialsSection />)
    expect(screen.getByText('Nguyễn Văn Hùng')).toBeInTheDocument()
  })
})
