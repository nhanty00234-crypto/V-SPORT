import { render, screen, fireEvent } from '@testing-library/react'
import FinalCTASection from '@/components/owner-landing/FinalCTASection'

describe('FinalCTASection', () => {
  it('renders primary CTA linking to /owner-register', () => {
    render(<FinalCTASection onOpenContact={() => {}} />)
    const link = screen.getByRole('link', { name: /đăng ký ngay/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })

  it('calls onOpenContact when secondary CTA is clicked', () => {
    const mock = jest.fn()
    render(<FinalCTASection onOpenContact={mock} />)
    fireEvent.click(screen.getByRole('button', { name: /liên hệ tư vấn/i }))
    expect(mock).toHaveBeenCalledTimes(1)
  })
})
