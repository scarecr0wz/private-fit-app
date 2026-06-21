import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { prisma } from '../lib/db'
import { authMiddleware } from '../middleware/auth'

export const activityRoutes = new Hono()

activityRoutes.use('*', authMiddleware)

const activitySchema = z.object({
  date: z.string(), // ISO string
  type: z.string(),
  durationSeconds: z.number(),
  distanceMeters: z.number(),
  caloriesBurned: z.number(),
  routePoints: z.string(), // Disimpan sebagai JSON string sesuai schema Prisma
  weatherTemp: z.number().nullable().optional(),
  weatherHumidity: z.number().nullable().optional(),
  weatherWindKmh: z.number().nullable().optional(),
  weatherCode: z.number().nullable().optional(),
})

// GET /api/activities?date=2024-01-15
activityRoutes.get('/', async (c) => {
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

  const activities = await prisma.activityLog.findMany({
    where,
    orderBy: { date: 'desc' }
  })
  return c.json(activities)
})

// POST /api/activities
activityRoutes.post('/', zValidator('json', activitySchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')

  const activity = await prisma.activityLog.create({
    data: {
      userId,
      date: new Date(body.date),
      type: body.type,
      durationSeconds: body.durationSeconds,
      distanceMeters: body.distanceMeters,
      caloriesBurned: body.caloriesBurned,
      routePoints: body.routePoints,
      weatherTemp: body.weatherTemp,
      weatherHumidity: body.weatherHumidity,
      weatherWindKmh: body.weatherWindKmh,
      weatherCode: body.weatherCode,
    }
  })
  return c.json(activity, 201)
})

// GET /api/activities/:id
activityRoutes.get('/:id', async (c) => {
  const userId = c.get('userId')
  const id = parseInt(c.req.param('id'))

  if (isNaN(id)) return c.json({ error: 'Invalid ID' }, 400)

  const activity = await prisma.activityLog.findFirst({ where: { id, userId } })
  if (!activity) return c.json({ error: 'Not found' }, 404)

  return c.json(activity)
})

// DELETE /api/activities/:id
activityRoutes.delete('/:id', async (c) => {
  const userId = c.get('userId')
  const id = parseInt(c.req.param('id'))

  if (isNaN(id)) return c.json({ error: 'Invalid ID' }, 400)

  const existing = await prisma.activityLog.findFirst({ where: { id, userId } })
  if (!existing) return c.json({ error: 'Not found' }, 404)

  await prisma.activityLog.delete({ where: { id } })
  return c.json({ success: true })
})
