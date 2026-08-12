import { sendOtp, verifyOtp, register } from '@/lib/api/owner-register'
import type { RegistrationData } from '@/types/owner-register'

const mockFetch = jest.fn()
beforeAll(() => { global.fetch = mockFetch })
afterEach(() => mockFetch.mockReset())

const BASE = 'http://localhost:8080/Backend_java'

describe('sendOtp', () => {
  it('POSTs email and phone to /owner/send-otp with credentials', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    const result = await sendOtp('owner@example.com', '0901234567')

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/send-otp`,
      expect.objectContaining({
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      })
    )
    expect(result).toEqual({ success: true })
  })

  it('returns success: false with message on API error', async () => {
    mockFetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: false, message: 'Email đã tồn tại.' }),
    })
    const result = await sendOtp('used@example.com', '0901234567')
    expect(result).toEqual({ success: false, message: 'Email đã tồn tại.' })
  })
})

describe('verifyOtp', () => {
  it('POSTs email and otp to /owner/verify-otp', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    await verifyOtp('owner@example.com', '123456')

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/verify-otp`,
      expect.objectContaining({ method: 'POST', credentials: 'include' })
    )
  })
})

describe('register', () => {
  it('POSTs registration data to /owner/register', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })

    const data: RegistrationData = {
      ownerName: 'Sân Cầu Lông ABC',
      email: 'abc@example.com',
      phone: '0901234567',
      address: '123 Lê Lợi, Q1, TP.HCM',
      description: 'Cơ sở chất lượng',
      openTime: '06:00',
      closeTime: '22:00',
      operatingDays: 'T2,T3,T4,T5,T6',
      sportsData: '[{"sport":"Cầu lông","quantity":4}]',
    }

    const result = await register(data)

    expect(mockFetch).toHaveBeenCalledWith(
      `${BASE}/owner/register`,
      expect.objectContaining({ method: 'POST', credentials: 'include' })
    )
    expect(result).toEqual({ success: true })
  })
})
