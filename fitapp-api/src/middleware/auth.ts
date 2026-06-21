import { createMiddleware } from 'hono/factory'
import { verify } from 'hono/jwt'

const JWT_SECRET = process.env.JWT_SECRET ?? 'super-secret-jwt-key-ganti-di-production'

export const authMiddleware = createMiddleware(async (c, next) => {
  const header = c.req.header('Authorization')
  if (!header?.startsWith('Bearer ')) {
    console.log('[REALTIME DEBUG] Auth ditolak: Header Authorization tidak valid atau kosong ->', header)
    return c.json({ error: 'Unauthorized' }, 401)
  }

  try {
    const token = header.slice(7)
    const payload = await verify(token, JWT_SECRET)
    c.set('userId', payload.sub as string)
    await next()
  } catch (err) {
    console.log('[REALTIME DEBUG] Auth ditolak: Token gagal diverifikasi ->', err)
    return c.json({ error: 'Token tidak valid' }, 401)
  }
})
