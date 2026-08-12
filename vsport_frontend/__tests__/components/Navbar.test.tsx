import { render, screen } from '@testing-library/react'
import Navbar from '@/components/owner-landing/Navbar'

describe('Navbar', () => {
  it('renders the V-Sport logo', () => {
    render(<Navbar />)
    expect(screen.getByText('V-')).toBeInTheDocument()
    expect(screen.getByText('SPORT')).toBeInTheDocument()
  })

  it('renders navigation links', () => {
    render(<Navbar />)
    expect(screen.getByText('Tính năng')).toBeInTheDocument()
    expect(screen.getByText('Thống kê')).toBeInTheDocument()
    expect(screen.getByText('Liên hệ')).toBeInTheDocument()
  })

  it('renders Đăng ký CTA linking to /owner-register', () => {
    render(<Navbar />)
    const link = screen.getByRole('link', { name: /đăng ký/i })
    expect(link).toHaveAttribute('href', '/owner-register')
  })
})
