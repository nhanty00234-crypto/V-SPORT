import { render, screen } from '@testing-library/react'
import FeaturesSection from '@/components/owner-landing/FeaturesSection'

describe('FeaturesSection', () => {
  it('renders section heading', () => {
    render(<FeaturesSection />)
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument()
  })

  it('renders exactly 5 feature cards', () => {
    render(<FeaturesSection />)
    expect(screen.getAllByRole('article')).toHaveLength(5)
  })

  it('renders all feature titles', () => {
    render(<FeaturesSection />)
    expect(screen.getByText('Quản lý lịch đặt trực quan')).toBeInTheDocument()
    expect(screen.getByText('Thanh toán QR & PayOS')).toBeInTheDocument()
    expect(screen.getByText('Báo cáo doanh thu')).toBeInTheDocument()
    expect(screen.getByText('Khuyến mãi thông minh')).toBeInTheDocument()
    expect(screen.getByText('App mobile cho khách hàng')).toBeInTheDocument()
  })
})
