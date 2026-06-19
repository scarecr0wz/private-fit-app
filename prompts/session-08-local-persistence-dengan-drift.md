## Session 8 — Local Persistence dengan Drift

**Goal**: Data food log, gym log, dan aktivitas tersimpan di device (SQLite).

### 8.1 Tambah dependencies

```yaml
dependencies:
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.18.0
  build_runner: ^2.4.0
```

### 8.2 Tabel yang dibuat

```dart
// lib/data/database.dart

// Tabel:
// food_logs       : id, date, food_name, grams, calories, protein, carbs, fat
// workout_logs    : id, date, template_name, duration_minutes, total_volume_kg
// workout_sets    : id, workout_log_id, exercise_name, reps, weight_kg
// activity_logs   : id, date, type (run/bike), duration_seconds, distance_meters,
//                   calories_burned, route_points (JSON)
// body_weights    : id, date, weight_kg
```

### 8.3 Generate kode

```bash
dart run build_runner build
```

**Checkpoint session 8**: Data tersimpan di device, tetap ada setelah app restart.

---