import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { sign } from 'hono/jwt'
import { prisma } from '../lib/db'
import bcrypt from 'bcryptjs'

const JWT_SECRET = process.env.JWT_SECRET ?? 'super-secret-jwt-key-ganti-di-production'

export const authRoutes = new Hono()

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

authRoutes.post('/register', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')

  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) return c.json({ error: 'Email sudah terdaftar' }, 400)

  const passwordHash = await bcrypt.hash(password, 10)
  const user = await prisma.user.create({ data: { email, passwordHash } })

  const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
  return c.json({ token, userId: user.id }, 201)
})

authRoutes.post('/login', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')

  const user = await prisma.user.findUnique({ where: { email } })
  if (!user) return c.json({ error: 'Email atau password salah' }, 401)

  const valid = await bcrypt.compare(password, user.passwordHash)
  if (!valid) return c.json({ error: 'Email atau password salah' }, 401)

  const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
  return c.json({ token, userId: user.id })
})
