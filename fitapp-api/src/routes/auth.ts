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

authRoutes.post('/register', zValidator('json', registerSchema, (result, c) => {
  if (!result.success) {
    console.error(`[REGISTER VALIDATION ERROR]:`, result.error.issues);
    // Hono's zValidator auto-returns 400 by default, but we can override it to ensure consistent format
    return c.json({ error: result.error.issues[0].message || 'Format data tidak valid' }, 400);
  }
}), async (c) => {
  try {
    const { email, password } = c.req.valid('json')
    console.log(`[REGISTER DEBUG] Attempting to register email: ${email}`);

    const exists = await prisma.user.findUnique({ where: { email } })
    if (exists) {
      console.log(`[REGISTER DEBUG] Email ${email} already exists! Returning 400.`);
      return c.json({ error: 'Email sudah terdaftar' }, 400)
    }

    console.log(`[REGISTER DEBUG] Email ${email} is available. Hashing password...`);
    const passwordHash = await bcrypt.hash(password, 10)
    
    console.log(`[REGISTER DEBUG] Creating user in DB...`);
    const user = await prisma.user.create({ data: { email, passwordHash } })

    console.log(`[REGISTER DEBUG] User created with ID: ${user.id}. Signing JWT...`);
    const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
    
    console.log(`[REGISTER DEBUG] Registration successful! Returning 201.`);
    return c.json({ token, userId: user.id }, 201)
  } catch (error) {
    console.error(`[REGISTER DEBUG] FATAL ERROR:`, error);
    return c.json({ error: 'Internal server error during registration' }, 500);
  }
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
