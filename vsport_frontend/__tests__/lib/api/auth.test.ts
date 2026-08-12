const mockFetch = jest.fn()
beforeAll(() => { global.fetch = mockFetch as unknown as typeof fetch })
afterEach(() => mockFetch.mockReset())

import { getCurrentUser, login, logout } from '@/lib/api/auth'

describe('getCurrentUser', () => {
  it('returns user when authenticated', async () => {
    mockFetch.mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({
        id: 1, email: 'a@b.com', role: 'CUSTOMER',
        fullName: 'Test User', phone: '0901234567', avatarUrl: null,
      }),
    })
    const user = await getCurrentUser()
    expect(user?.email).toBe('a@b.com')
    expect(user?.role).toBe('CUSTOMER')
  })

  it('returns null on 401', async () => {
    mockFetch.mockResolvedValueOnce({ ok: false })
    expect(await getCurrentUser()).toBeNull()
  })

  it('returns null on network error', async () => {
    mockFetch.mockRejectedValueOnce(new Error('network'))
    expect(await getCurrentUser()).toBeNull()
  })
})

describe('login', () => {
  it('posts to /dangnhap with AJAX header', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })
    await login('user@example.com', 'password123')
    const [url, opts] = mockFetch.mock.calls[0] as [string, RequestInit & { headers: Record<string, string> }]
    expect(url).toContain('/dangnhap')
    expect(opts.headers['X-Requested-With']).toBe('XMLHttpRequest')
    expect(opts.method).toBe('POST')
    expect(opts.credentials).toBe('include')
  })

  it('returns success result with user', async () => {
    mockFetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: true, user: { id: 1, role: 'CUSTOMER' } }),
    })
    const result = await login('user@example.com', 'pass')
    expect(result.success).toBe(true)
  })

  it('returns error message on failure', async () => {
    mockFetch.mockResolvedValueOnce({
      json: () => Promise.resolve({ success: false, loi: 'Sai mật khẩu' }),
    })
    const result = await login('user@example.com', 'wrong')
    expect(result.success).toBe(false)
    expect(result.loi).toBe('Sai mật khẩu')
  })

  it('uses phone field when method=phone', async () => {
    mockFetch.mockResolvedValueOnce({ json: () => Promise.resolve({ success: true }) })
    await login('0901234567', 'pass', 'phone')
    const [, opts] = mockFetch.mock.calls[0] as [string, RequestInit]
    expect(opts.body?.toString()).toContain('phone=0901234567')
  })
})
