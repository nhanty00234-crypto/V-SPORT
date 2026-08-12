import { render, screen } from '@testing-library/react'
import AnimatedCounter from '@/components/owner-landing/AnimatedCounter'

const mockObserve = jest.fn()
const mockDisconnect = jest.fn()

beforeEach(() => {
  global.IntersectionObserver = jest.fn().mockImplementation((cb) => {
    cb([{ isIntersecting: true }])
    return { observe: mockObserve, disconnect: mockDisconnect }
  }) as unknown as typeof IntersectionObserver
})

describe('AnimatedCounter', () => {
  it('renders without crashing', () => {
    render(<AnimatedCounter target={1000} />)
    expect(screen.getByRole('status')).toBeInTheDocument()
  })

  it('renders a suffix when provided', () => {
    render(<AnimatedCounter target={500} suffix="+" />)
    expect(screen.getByRole('status').textContent).toContain('+')
  })
})
