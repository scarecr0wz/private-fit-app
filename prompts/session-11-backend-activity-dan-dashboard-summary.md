## Session 11 — Backend: Activity + Dashboard Summary

**Goal**: Simpan rute GPS, dan endpoint summary untuk dashboard Flutter.

### Endpoints activity

```typescript
// src/routes/activity.ts
// GET  /api/activities?date=2024-01-15
// POST /api/activities                  → simpan aktivitas selesai (include routePoints)
// GET  /api/activities/:id              → detail + rute
```

### Endpoint dashboard summary

```typescript
// GET /api/dashboard/summary?date=2024-01-15
// Response:
// {
//   caloriesIn: 1850,
//   caloriesOut: 420,
//   calorieGoal: 2400,
//   meals: [...],
//   activities: [...]
// }
```

**Checkpoint session 11**: Backend lengkap, semua endpoint jalan.

---