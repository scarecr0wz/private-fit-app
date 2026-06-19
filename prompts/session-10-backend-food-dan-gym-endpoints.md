## Session 10 — Backend: Food & Gym Endpoints

**Goal**: CRUD food log dan workout log, semua protected by JWT.

### Endpoints food log

```typescript
// src/routes/food.ts
// GET  /api/food-logs?date=2024-01-15   → list log hari itu
// POST /api/food-logs                   → tambah log baru
// DELETE /api/food-logs/:id             → hapus log
```

### Endpoints workout log

```typescript
// src/routes/workout.ts
// GET  /api/workout-logs?date=2024-01-15
// POST /api/workout-logs                → buat workout baru
// POST /api/workout-logs/:id/sets       → tambah set ke workout
// DELETE /api/workout-logs/:id
```

> Semua route pakai `authMiddleware` dari session 9. Selalu filter by `userId` dari JWT — jangan pakai userId dari body request.

**Checkpoint session 10**: Bisa CRUD food log dan workout via Postman/curl dengan JWT token.

---