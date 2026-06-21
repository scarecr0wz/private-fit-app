import { Hono } from 'hono'
import { prisma } from '../lib/db'
import { authMiddleware } from '../middleware/auth'

export const dashboardRoutes = new Hono()

dashboardRoutes.use('*', authMiddleware)

// GET /api/dashboard/summary?date=2024-01-15
dashboardRoutes.get('/summary', async (c) => {
  const userId = c.get('userId')
  const dateStr = c.req.query('date')
  
  if (!dateStr) {
    return c.json({ error: 'date query parameter is required' }, 400)
  }

  const start = new Date(dateStr)
  start.setUTCHours(0, 0, 0, 0)
  const end = new Date(dateStr)
  end.setUTCHours(23, 59, 59, 999)

  const where = { userId, date: { gte: start, lte: end } }

  const [foodLogs, workoutLogs, activities] = await Promise.all([
    prisma.foodLog.findMany({ where }),
    prisma.workoutLog.findMany({ where }),
    prisma.activityLog.findMany({ where })
  ])

  const caloriesIn = foodLogs.reduce((sum, log) => sum + log.calories, 0)
  
  const workoutCaloriesOut = workoutLogs.reduce((sum, log) => sum + log.caloriesBurned, 0)
  const activityCaloriesOut = activities.reduce((sum, log) => sum + log.caloriesBurned, 0)
  const caloriesOut = workoutCaloriesOut + activityCaloriesOut

  // Contoh hardcode calorieGoal. Nantinya bisa dari setting/tabel Profile user.
  const calorieGoal = 2400

  return c.json({
    caloriesIn,
    caloriesOut,
    calorieGoal,
    meals: foodLogs,
    workouts: workoutLogs,
    activities: activities
  })
})
