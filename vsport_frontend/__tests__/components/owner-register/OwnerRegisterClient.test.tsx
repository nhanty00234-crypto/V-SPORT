import { render, screen, fireEvent, waitFor } from '@testing-library/react'

const mockPush = jest.fn()
jest.mock('next/navigation', () => ({
  useRouter: () => ({ push: mockPush }),
}))
jest.mock('@/components/owner-register/RegisterHeader', () => ({
  __esModule: true,
  default: ({ currentStep }: { currentStep: number }) => (
    <div data-testid="progress">{currentStep}</div>
  ),
}))
jest.mock('@/components/owner-register/Step1EmailPhone', () => ({
  __esModule: true,
  default: ({ onSuccess }: { onSuccess: (e: string, p: string) => void }) => (
    <button onClick={() => onSuccess('test@example.com', '0901234567')}>Step1</button>
  ),
}))
jest.mock('@/components/owner-register/Step2OTP', () => ({
  __esModule: true,
  default: ({ onSuccess, onBack }: { onSuccess: () => void; onBack: () => void }) => (
    <div>
      <button onClick={onSuccess}>Step2Success</button>
      <button onClick={onBack}>Step2Back</button>
    </div>
  ),
}))
jest.mock('@/components/owner-register/Step3Details', () => ({
  __esModule: true,
  default: ({ onSuccess }: { onSuccess: () => void }) => (
    <button onClick={onSuccess}>Step3Success</button>
  ),
}))

import OwnerRegisterClient from '@/components/owner-register/OwnerRegisterClient'

beforeEach(() => mockPush.mockReset())

describe('OwnerRegisterClient', () => {
  it('shows step 1 initially', () => {
    render(<OwnerRegisterClient />)
    expect(screen.getByText('Step1')).toBeInTheDocument()
    expect(screen.queryByText('Step2Success')).not.toBeInTheDocument()
  })

  it('shows progress bar at step 1', () => {
    render(<OwnerRegisterClient />)
    expect(screen.getByTestId('progress')).toHaveTextContent('1')
  })

  it('advances to step 2 when step 1 succeeds', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => expect(screen.getByText('Step2Success')).toBeInTheDocument())
    expect(screen.queryByText('Step1')).not.toBeInTheDocument()
  })

  it('goes back to step 1 from step 2', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Back'))
    fireEvent.click(screen.getByText('Step2Back'))
    await waitFor(() => expect(screen.getByText('Step1')).toBeInTheDocument())
  })

  it('advances to step 3 when step 2 succeeds', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Success'))
    fireEvent.click(screen.getByText('Step2Success'))
    await waitFor(() => expect(screen.getByText('Step3Success')).toBeInTheDocument())
  })

  it('calls router.push to success page when step 3 completes', async () => {
    render(<OwnerRegisterClient />)
    fireEvent.click(screen.getByText('Step1'))
    await waitFor(() => screen.getByText('Step2Success'))
    fireEvent.click(screen.getByText('Step2Success'))
    await waitFor(() => screen.getByText('Step3Success'))
    fireEvent.click(screen.getByText('Step3Success'))
    await waitFor(() =>
      expect(mockPush).toHaveBeenCalledWith('/owner-register/success')
    )
  })
})
