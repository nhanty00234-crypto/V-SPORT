import { render, screen, fireEvent } from '@testing-library/react'
import HeroSection from '@/components/owner-landing/HeroSection'

describe('HeroSection', () => {
  it('renders the main headline', () => {
    render(<HeroSection onOpenContact={() => {}} />)
    expect(screen.getByRole('heading', { level: 1 })).toBeInTheDocument()
  })

  it('renders primary CTA link to /owner-register', () => {
    render(<HeroSection onOpenContact={() => {}} />)
    const link = screen.getByRole('link', { name: /đăng ký ngay/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })

  it('calls onOpenContact when secondary CTA is clicked', () => {
    const mock = jest.fn()
    render(<HeroSection onOpenContact={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /liên hệ tư vấn/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
