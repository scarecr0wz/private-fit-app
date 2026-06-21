import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { prisma } from '../lib/db'
import { authMiddleware } from '../middleware/auth'

export const workoutRoutes = new Hono()

workoutRoutes.use('*', authMiddleware)

const workoutSchema = z.object({
  date: z.string(), // ISO string
  templateName: z.string(),
  durationMinutes: z.number(),
  totalVolumeKg: z.number(),
  caloriesBurned: z.number().default(0),
})

const setSchema = z.object({
  exerciseName: z.string(),
  reps: z.number(),
  weightKg: z.number(),
})

// GET /api/workout-logs?date=2024-01-15
workoutRoutes.get('/', async (c) => {
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

  const logs = await prisma.workoutLog.findMany({
    where,
    include: { sets: true }, // Sertakan sets
    orderBy: { date: 'desc' }
  })
  return c.json(logs)
})

// POST /api/workout-logs
workoutRoutes.post('/', zValidator('json', workoutSchema), async (c) => {
  const userId = c.get('userId')
  const body = c.req.valid('json')

  const log = await prisma.workoutLog.create({
    data: {
      userId,
      date: new Date(body.date),
      templateName: body.templateName,
      durationMinutes: body.durationMinutes,
      totalVolumeKg: body.totalVolumeKg,
      caloriesBurned: body.caloriesBurned,
    }
  })
  return c.json(log, 201)
})

// POST /api/workout-logs/:id/sets
workoutRoutes.post('/:id/sets', zValidator('json', setSchema), async (c) => {
  const userId = c.get('userId')
  const id = parseInt(c.req.param('id'))

  if (isNaN(id)) return c.json({ error: 'Invalid ID' }, 400)

  // Pastikan workout log milik user ini
  const log = await prisma.workoutLog.findFirst({ where: { id, userId } })
  if (!log) return c.json({ error: 'Workout not found' }, 404)

  const body = c.req.valid('json')

  const set = await prisma.workoutSet.create({
    data: {
      workoutLogId: id,
      exerciseName: body.exerciseName,
      reps: body.reps,
      weightKg: body.weightKg,
    }
  })
  return c.json(set, 201)
})

// DELETE /api/workout-logs/:id
workoutRoutes.delete('/:id', async (c) => {
  const userId = c.get('userId')
  const id = parseInt(c.req.param('id'))

  if (isNaN(id)) return c.json({ error: 'Invalid ID' }, 400)

  const existing = await prisma.workoutLog.findFirst({ where: { id, userId } })
  if (!existing) return c.json({ error: 'Not found' }, 404)

  // Sets akan otomatis terhapus karena `onDelete: Cascade` di Prisma Schema
  await prisma.workoutLog.delete({ where: { id } })
  return c.json({ success: true })
})
