# FitApp — Vibe Coding Plan

Flutter iOS · Hono + Bun Backend · PostgreSQL di VPS

> **Strategi**: Flutter-first dengan dummy data sampai ~50% fitur selesai, baru koneksi ke backend.
> Setiap session dirancang untuk bisa **selesai dalam 1–3 jam** dan punya hasil yang kelihatan.

---

## Stack

| Layer | Tech |
|---|---|
| Mobile | Flutter (iOS) |
| Local cache | SQLite via `drift` |
| Backend (nanti) | Hono + Bun |
| Database (nanti) | PostgreSQL di VPS |
| Auth (nanti) | JWT via `hono/jwt` |
| ORM (nanti) | Prisma |
| Food API | Open Food Facts + USDA FoodData |
| Maps | `flutter_map` (OpenStreetMap, gratis) |

### Kenapa Hono + Bun?

- **Hono**: framework web TypeScript yang ringan, syntax mirip Express tapi lebih clean
- **Bun**: runtime JavaScript baru yang jauh lebih cepat dari Node, include package manager + bundler
- **Prisma**: ORM dengan schema-first mirip migration Laravel, type-safe, nyaman untuk PostgreSQL
- Tidak ada magic, tidak ada boilerplate — kode yang kamu tulis = yang jalan

---

## Roadmap Session

| # | Session | Output |
|---|---|---|
| 1 | Setup project + navigasi dasar | App jalan, bottom nav 4 tab |
| 2 | Daily Dashboard UI | Layar utama dengan dummy summary |
| 3 | Food Logger UI | List makanan, barcode scanner dummy |
| 4 | Gym Logger UI | Input set/reps/weight, template dummy |
| 5 | GPS Tracker UI | Peta + live stats dummy |
| 6 | History & Stats UI | Chart mingguan dummy |
| 7 | Integrasi Open Food Facts API | Barcode scan nyambung ke API real |
| 8 | Local persistence (drift) | Data tersimpan di device |
| 9 | Backend Hono — setup + auth | Project Hono, endpoint login/register |
| 10 | Backend — food & gym endpoints | CRUD food log, workout log |
| 11 | Backend — activity endpoints | Simpan rute GPS, kalori |
| 12 | Flutter ↔ Hono connect | Replace dummy data dengan API calls |
| 13 | Polish & bugfix | Loading states, error handling |

---
