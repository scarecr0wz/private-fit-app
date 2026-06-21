import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { authRoutes } from './routes/auth'
import { authMiddleware } from './middleware/auth'
import { foodRoutes } from './routes/food'
import { workoutRoutes } from './routes/workout'
import { activityRoutes } from './routes/activity'
import { dashboardRoutes } from './routes/dashboard'

const app = new Hono()

app.use('*', cors())

// Public routes
app.route('/api/auth', authRoutes)

// Protected routes
app.route('/api/food-logs', foodRoutes)
app.route('/api/workout-logs', workoutRoutes)
app.route('/api/activities', activityRoutes)
app.route('/api/dashboard', dashboardRoutes)

app.get('/', (c) => c.json({ status: 'FitApp API is running (Auth Enabled)' }))

const port = 3000
console.log(`Server is running on port ${port}`)

serve({
  fetch: app.fetch,
  port
})
