import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { prisma } from '../lib/db'
import { authMiddleware } from '../middleware/auth'

export const foodRoutes = new Hono()

// Gunakan authMiddleware untuk semua route food
foodRoutes.use('*', authMiddleware)

const foodSchema = z.object({
  date: z.string(), // ISO string
  foodName: z.string(),
  grams: z.number(),
  calories: z.number(),
  protein: z.number(),
  carbs: z.number(),
  fat: z.number(),
})

// GET /api/food-logs?date=2024-01-15
foodRoutes.get('/', async (c) => {
  const userId = c.get('userId')
  const dateStr = c.req.query('date')
  
  const where: any = { userId }
  if (dateStr) {
    const start = new Date(dateStr)
    start.setUTCHours(0, 0, 0, 0)
    const end = new Date(dateStr)
    end.setUTCHours(23, 59, 59, 999)
    where.date = { gte: start, lte: end }
  }

  const logs = await prisma.foodLog.findMany({
    where,
    orderBy: { date: 'desc' }
  })
  return c.json(logs)
})

// POST /api/food-logs
foodRoutes.post('/', zValidator('json', foodSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')

  const log = await prisma.foodLog.create({
    data: {
      userId,
      date: new Date(body.date),
      foodName: body.foodName,
      grams: body.grams,
      calories: body.calories,
      protein: body.protein,
      carbs: body.carbs,
      fat: body.fat,
    }
  })
  return c.json(log, 201)
})

// DELETE /api/food-logs/:id
foodRoutes.delete('/:id', async (c) => {
  const userId = c.get('userId')
  const id = parseInt(c.req.param('id'))

  if (isNaN(id)) return c.json({ error: 'Invalid ID' }, 400)

  // Pastikan log tersebut milik user ini
  const existing = await prisma.foodLog.findFirst({ where: { id, userId } })
  if (!existing) return c.json({ error: 'Not found' }, 404)

  await prisma.foodLog.delete({ where: { id } })
  return c.json({ success: true })
})
