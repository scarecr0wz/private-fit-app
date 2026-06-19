## Session 9 — Backend Hono: Setup + Auth

**Goal**: Project Hono jalan di local, endpoint register + login menghasilkan JWT.

### 9.1 Install Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

### 9.2 Buat project

```bash
bun create hono fitapp-api
cd fitapp-api
# Pilih "bun" saat ditanya runtime
```

### 9.3 Install dependencies

```bash
bun add @hono/zod-validator zod
bun add @prisma/client
bun add hono
bunx prisma init --datasource-provider postgresql
```

### 9.4 Struktur folder backend

```
fitapp-api/
├── src/
│   ├── index.ts          # entry point
│   ├── routes/
│   │   ├── auth.ts
│   │   ├── food.ts
│   │   ├── workout.ts
│   │   └── activity.ts
│   ├── middleware/
│   │   └── auth.ts       # JWT verify
│   └── lib/
│       └── db.ts         # Prisma client singleton
├── prisma/
│   └── schema.prisma
└── .env
```

### 9.5 `prisma/schema.prisma`

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id           String        @id @default(cuid())
  email        String        @unique
  passwordHash String
  createdAt    DateTime      @default(now())
  foodLogs     FoodLog[]
  workoutLogs  WorkoutLog[]
  activities   Activity[]
  bodyWeights  BodyWeight[]
}

model FoodLog {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  date      DateTime
  foodName  String
  grams     Float
  calories  Int
  protein   Float
  carbs     Float
  fat       Float
  createdAt DateTime @default(now())
}

model WorkoutLog {
  id               String       @id @default(cuid())
  userId           String
  user             User         @relation(fields: [userId], references: [id])
  date             DateTime
  templateName     String?
  durationMinutes  Int
  totalVolumeKg    Float
  sets             WorkoutSet[]
  createdAt        DateTime     @default(now())
}

model WorkoutSet {
  id            String     @id @default(cuid())
  workoutLogId  String
  workoutLog    WorkoutLog @relation(fields: [workoutLogId], references: [id])
  exerciseName  String
  reps          Int
  weightKg      Float
}

model Activity {
  id              String   @id @default(cuid())
  userId          String
  user            User     @relation(fields: [userId], references: [id])
  date            DateTime
  type            String   // 'run' | 'bike'
  durationSeconds Int
  distanceMeters  Float
  caloriesBurned  Int
  routePoints     Json?    // array of {lat, lng, timestamp}
  createdAt       DateTime @default(now())
}

model BodyWeight {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  date      DateTime
  weightKg  Float
  createdAt DateTime @default(now())
}
```

### 9.6 `src/index.ts`

```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { authRoutes } from './routes/auth'
import { foodRoutes } from './routes/food'
import { workoutRoutes } from './routes/workout'
import { activityRoutes } from './routes/activity'

const app = new Hono()

app.use('*', cors())

app.route('/api/auth', authRoutes)
app.route('/api/food-logs', foodRoutes)
app.route('/api/workout-logs', workoutRoutes)
app.route('/api/activities', activityRoutes)

app.get('/', (c) => c.json({ status: 'FitApp API is running' }))

export default app
```

### 9.7 `src/routes/auth.ts`

```typescript
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'
import { sign } from 'hono/jwt'
import { prisma } from '../lib/db'

const JWT_SECRET = process.env.JWT_SECRET ?? 'dev-secret-ganti-di-production'

export const authRoutes = new Hono()

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

authRoutes.post('/register', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')

  const exists = await prisma.user.findUnique({ where: { email } })
  if (exists) return c.json({ error: 'Email sudah terdaftar' }, 400)

  const passwordHash = await Bun.password.hash(password)
  const user = await prisma.user.create({ data: { email, passwordHash } })

  const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
  return c.json({ token, userId: user.id }, 201)
})

authRoutes.post('/login', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')

  const user = await prisma.user.findUnique({ where: { email } })
  if (!user) return c.json({ error: 'Email atau password salah' }, 401)

  const valid = await Bun.password.verify(password, user.passwordHash)
  if (!valid) return c.json({ error: 'Email atau password salah' }, 401)

  const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
  return c.json({ token, userId: user.id })
})
```

### 9.8 `src/middleware/auth.ts`

```typescript
import { createMiddleware } from 'hono/factory'
import { verify } from 'hono/jwt'

const JWT_SECRET = process.env.JWT_SECRET ?? 'dev-secret-ganti-di-production'

export const authMiddleware = createMiddleware(async (c, next) => {
  const header = c.req.header('Authorization')
  if (!header?.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401)
  }

  try {
    const token = header.slice(7)
    const payload = await verify(token, JWT_SECRET)
    c.set('userId', payload.sub as string)
    await next()
  } catch {
    return c.json({ error: 'Token tidak valid' }, 401)
  }
})
```

### 9.9 `src/lib/db.ts`

```typescript
import { PrismaClient } from '@prisma/client'

export const prisma = new PrismaClient()
```

### 9.10 Jalankan migration & dev server

```bash
# Setup database
bunx prisma migrate dev --name init

# Jalankan dev server (hot reload)
bun --watch src/index.ts
```

**Checkpoint session 9**: `POST /api/auth/register` dan `/api/auth/login` jalan, balik JWT.

---