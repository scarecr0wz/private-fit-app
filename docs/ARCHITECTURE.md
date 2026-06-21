# FitFad - Dokumentasi Arsitektur & Sistem

> **Versi**: 1.9.1 | **Framework**: Flutter 3.41 (Dart 3.11) | **Architecture**: Offline-first, Feature-based

---

## Table of Contents

1. [Tech Stack](#1-tech-stack)
2. [Struktur Proyek](#2-struktur-proyek)
3. [Arsitektur & Pola Desain](#3-arsitektur--pola-desain)
4. [Database Schema](#4-database-schema)
5. [Integrasi API Eksternal](#5-integrasi-api-eksternal)
6. [Fitur Aplikasi](#6-fitur-aplikasi)
7. [Konfigurasi & Environment](#7-konfigurasi--environment)
8. [Roadmap & Fitur Mendatang](#8-roadmap--fitur-mendatang)

---

## 1. Tech Stack

| Layer | Technology | Versi |
|---|---|---|
| Framework | Flutter | 3.41 |
| Bahasa | Dart | 3.11 |
| State Management | Riverpod + ChangeNotifier | flutter_riverpod ^2.5.0 |
| Navigasi | GoRouter | ^13.0.0 (ShellRoute + bottom nav) |
| Database (ORM) | Drift (SQLite) | ^2.34.0 + code generation |
| HTTP Client | Dio | ^5.9.2 |
| Maps 2D | FlutterMap | ^8.3.0 (CartoDB dark tiles) |
| Maps 3D | MapLibre GL | ^0.26.2 (MapTiler outdoor-v2 + terrain) |
| Lokasi/GPS | Geolocator | ^14.0.3 |
| Barcode Scanner | Mobile Scanner | ^7.2.0 |
| Charts | fl_chart | ^1.2.0 + CustomPaint |
| Font | Google Fonts (Inter) | ^6.2.1 |
| Connectivity | connectivity_plus | ^6.1.2 |
| Coordinates | latlong2 | ^0.9.1 |
| CI/CD | GitHub Actions | iOS .ipa build workflow |

**Platform Target**: iOS, Android, Web, Windows

---

## 2. Struktur Proyek

```
fit-app/
├── lib/
│   ├── main.dart                    # Entry point aplikasi
│   ├── router.dart                  # GoRouter + ShellRoute (bottom nav)
│   ├── theme.dart                   # AppColors + AppTheme (dark theme)
│   ├── data/
│   │   ├── database.dart            # Drift ORM schema (5 tabel)
│   │   ├── database.g.dart          # Auto-generated Drift code
│   │   └── connection/
│   │       ├── connection.dart      # Platform-conditional DB connection
│   │       ├── native.dart          # SQLite NativeDatabase (mobile/desktop)
│   │       ├── web.dart             # WasmDatabase (web)
│   │       └── unsupported.dart     # Fallback error
│   ├── features/
│   │   ├── splash/                  # Splash screen animasi
│   │   ├── dashboard/               # Ringkasan harian + calorie ring + cuaca
│   │   ├── food/                    # Pencarian makanan (USDA) + barcode (OFF)
│   │   ├── activity/                # GPS tracking + peta + 3D replay
│   │   ├── gym/                     # Logging gym (sets/reps)
│   │   ├── stats/                   # Chart histori + body weight trend
│   │   └── weather/                 # Service cuaca (Open-Meteo + Nominatim)
│   └── shared/widgets/
│       └── calorie_ring.dart        # Widget animated circular progress
├── android/                         # Platform Android
├── ios/                             # Platform iOS (deployment target 15.0)
├── web/                             # Web platform (Drift WASM worker)
├── windows/                         # Platform Windows
├── docs/                            # User feedback docs
├── prompts/                         # Development session logs
└── .github/workflows/
    └── build-ios.yml                # CI/CD iOS build
```

---

## 3. Arsitektur & Pola Desain

### Pola: Offline-first, Feature-based

- **Tidak ada backend server** -- semua data tersimpan lokal di SQLite via Drift
- **Tidak ada sistem autentikasi** -- aplikasi murni personal tracker
- Setiap fitur terisolasi dalam folder `features/` sendiri
- State management menggunakan Riverpod dengan ChangeNotifier untuk state kompleks (GPS tracking)

### Alur Data

```
User Action -> Feature Screen -> Local DB (Drift/SQLite)
                               \-> External API (USDA, Open-Meteo, etc.)
```

### Alur Navigasi (GoRouter)

```
SplashScreen (3 detik)
    |
ShellRoute (BottomNav):
  |-- Dashboard (/dashboard)     -- Tab 1
  |-- Stats (/stats)             -- Tab 2
  |-- Activity (/activity)       -- Tab 3
  +-- Gym (/gym)                 -- Tab 4

Rute overlay:
  |-- /food                      -- Food Logger
  |-- /activity/detail/:id       -- Detail Aktivitas
  +-- /activity/flyover/:id      -- 3D Route Replay
```

---

## 4. Database Schema

**ORM**: Drift 2.34 (code-generated SQLite)
**File**: `fitfad.sqlite`
**Schema Version**: 2

### Tabel: `food_logs`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| date | DATETIME | NOT NULL |
| food_name | TEXT | Nama makanan |
| grams | REAL | Berat dalam gram |
| calories | REAL | Kalori (kcal) |
| protein | REAL | Protein (g) |
| carbs | REAL | Karbohidrat (g) |
| fat | REAL | Lemak (g) |

### Tabel: `workout_logs`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| date | DATETIME | NOT NULL |
| template_name | TEXT | Nama template (Push Day, dll) |
| duration_minutes | INTEGER | Durasi (menit) |
| total_volume_kg | REAL | Total volume (kg) |
| calories_burned | REAL | Estimasi kalori terbakar |

### Tabel: `workout_sets`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| workout_log_id | INTEGER | FK -> workout_logs.id |
| exercise_name | TEXT | Nama latihan |
| reps | INTEGER | Jumlah repetisi |
| weight_kg | REAL | Beban (kg) |

### Tabel: `activity_logs`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| date | DATETIME | NOT NULL |
| type | TEXT | 'run' atau 'bike' |
| duration_seconds | INTEGER | Durasi (detik) |
| distance_meters | REAL | Jarak (meter) |
| calories_burned | REAL | Kalori terbakar |
| route_points | TEXT | JSON array [{lat, lng, pace, alt}] |
| weather_temp | REAL | Suhu saat aktivitas (nullable, v2) |
| weather_humidity | REAL | Kelembapan (nullable, v2) |
| weather_wind_kmh | REAL | Kecepatan angin (nullable, v2) |
| weather_code | INTEGER | Kode cuaca WMO (nullable, v2) |

### Tabel: `body_weights`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT |
| date | DATETIME | NOT NULL |
| weight_kg | REAL | Berat badan (kg) |

---

## 5. Integrasi API Eksternal

### A. USDA FoodData Central (Pencarian Makanan)

| Item | Detail |
|---|---|
| **URL** | `https://api.nal.usda.gov/fdc/v1/foods/search` |
| **Method** | GET |
| **Parameter** | `query`, `api_key=DEMO_KEY`, `pageSize=10` |
| **Digunakan di** | `food_screen.dart` -> `_fetchUSDA()` |
| **Rate Limit** | DEMO_KEY terbatas; disarankan pakai key production |
| **Parsing** | `foodNutrients` -> energy, protein, carbohydrate, lipid/fat |

### B. Open Food Facts v3 (Barcode Scanner)

| Item | Detail |
|---|---|
| **URL** | `https://world.openfoodfacts.org/api/v3/product/{barcode}.json` |
| **Method** | GET |
| **API Key** | Tidak diperlukan (publik) |
| **Digunakan di** | `food_screen.dart` -> `_fetchProduct()` |
| **Parsing** | `nutriments` -> energy-kcal_100g, proteins_100g, carbohydrates_100g, fat_100g |

### C. Open-Meteo Weather API (Cuaca)

| Item | Detail |
|---|---|
| **URL** | `https://api.open-meteo.com/v1/forecast` |
| **Method** | GET |
| **Parameter** | `latitude`, `longitude`, `current` (temp, humidity, wind, weather_code, dll), `wind_speed_unit=kmh`, `timezone=auto` |
| **Digunakan di** | `weather_service.dart` -> `fetchCurrent()` dan `fetchForLocation()` |
| **Cache** | 5 menit di memori |
| **Fitur** | WMO weather code mapping, exercise suitability scoring, prediksi hujan per jam |

### D. Nominatim OpenStreetMap (Reverse Geocoding)

| Item | Detail |
|---|---|
| **URL** | `https://nominatim.openstreetmap.org/reverse` |
| **Method** | GET |
| **Parameter** | `format=jsonv2`, `lat`, `lon` |
| **Header** | `User-Agent: FitFad/1.0` |
| **Digunakan di** | `weather_service.dart` -> `fetchCurrent()` untuk resolve nama kota |

### E. MapTiler (3D Terrain Tiles)

| Item | Detail |
|---|---|
| **URL** | `https://api.maptiler.com/maps/outdoor-v2/style.json?key=KV6n4yl6DjwIdqdqA9NM` |
| **Digunakan di** | `flyover_3d_screen.dart` untuk 3D route replay dengan terrain DEM |

### F. CartoDB Dark Tiles (Peta 2D)

| Item | Detail |
|---|---|
| **URL** | `https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png` |
| **Digunakan di** | `activity_screen.dart` untuk live tracking map |

---

## 6. Fitur Aplikasi

### 6.1 Dashboard (Ringkasan Harian)

- **CalorieRing**: Animated circular progress dengan 3D glow arc
- **Intake vs Outtake**: Pill stats (kalori masuk vs keluar)
- **Weather Card**: Suhu, kota, emoji cuaca, pesan forecast, kelembapan/angin/hujan chips, banner exercise suitability
- **Activity Feed**: Histori lari, bersepeda, gym hari ini
- **Meal History**: Daftar makanan dengan timestamp dan kalori
- **Quick Action FAB**: Navigasi cepat ke Food Logger
- Data dari local DB via **StreamBuilder** (reaktif)

### 6.2 Food Logger (Pencarian & Logging Makanan)

- **Pencarian via USDA API** dengan debounce 500ms
- **Barcode Scanner** via kamera + Open Food Facts API
- **Portion Slider** (10-500g) dengan breakdown makro lengkap
- **Arc Glow Nutrition Chart**: CustomPaint dengan per-segment glow + tap interaction
- **Filter Tanggal**: Today, Yesterday, This Week, This Month, All Time, Custom Range
- **Error Handling**: Rate limit (429), timeout, offline state
- Simpan log ke local SQLite

### 6.3 Activity Tracker (GPS Outdoor)

- **Real-time tracking** dengan FlutterMap (CartoDB dark tiles)
- **Background Tracking**: Android Foreground Service + iOS Background Location
- **2 Mode**: Running (pace min/km) dan Cycling (speed km/h)
- **Elevation Gain** otomatis dengan noise filter 2 meter
- **Weather Snapshot** diam-diam diambil saat mulai aktivitas, disimpan ke DB
- **Countdown 5 detik** sebelum mulai
- **Live Stats Overlay**: durasi, jarak, pace/speed, kalori
- **Kontrol**: Start/Pause/Resume/Stop dengan tombol 3D glassmorphism
- **LIVE Indicator Badge** saat tracking aktif
- **Custom Map Markers**: race car (sepeda), running shoe (lari)
- **Offline Detection** via connectivity_plus dengan warning snackbar

### 6.4 Activity Detail Screen

- **Pace-colored Polylines**: Hijau (cepat), Kuning (sedang), Merah (lambat)
- **Pace Checkpoints** setiap 0.5km dengan bubble marker berwarna
- **Pace History**: Horizontal progress bars + perbandingan faster/slower arrows
- **Elevation Profile**: Interactive area chart (fl_chart)
- **Weather During Activity**: Suhu, kelembapan, angin, kode cuaca dari snapshot
- **3D Route Replay**: MapLibre GL + MapTiler terrain:
  - Satellite + terrain DEM (1.5x elevation exaggeration)
  - Progressive route drawing (Strava-style)
  - Moving dot indicator
  - Camera tilt untuk 3D depth
  - Tombol replay/reset + progress bar

### 6.5 Gym Logger (Workout Tracking)

- **Workout Lifecycle**: Start -> Add Sets -> Finish
- **Routine Templates**: Push Day, Pull Day, Leg Day, Cardio (horizontal chip selector)
- **Per-exercise Set Tracking**: reps + weight via bottom sheet (sliders)
- **Workout Summary**: Durasi, total volume (kg), estimasi kalori (5 kcal/min)
- **Motivational Bento Card** component
- Simpan ke local DB (WorkoutLogs + WorkoutSets)

### 6.6 Stats & History

- **Bar Chart** (fl_chart): Kalori terbakar harian (minggu/bulan toggle)
- **Line Chart** (fl_chart): Tren berat badan (7 data terakhir, curved, gradient fill)
- **Combined Activity History**: Outdoor + gym, sorted by date
- Tap outdoor activity -> navigasi ke Activity Detail

### 6.7 Splash Screen

- **Animated 3D entrance**: Scale + fade dengan glow shadow
- Auto-navigasi ke dashboard setelah 3 detik

---

## 7. Konfigurasi & Environment

### Hardcoded Values (dalam source code)

| Konfigurasi | Nilai | Lokasi |
|---|---|---|
| USDA API Key | `DEMO_KEY` | `food_screen.dart:93` |
| MapTiler API Key | `KV6n4yl6DjwIdqdqA9NM` | `flyover_3d_screen.dart:43` |
| Weather Cache | 5 menit | `weather_service.dart:219` |
| Calorie Goal | 2000 kcal | `dashboard_screen.dart:93` |
| Running Burn Rate | ~60 kcal/km | `activity_service.dart` |
| Cycling Burn Rate | ~30 kcal/km | `activity_service.dart` |
| Gym Burn Rate | ~5 kcal/min | `gym_screen.dart` |
| Elevation Noise Filter | 2 meter | `activity_service.dart:55` |
| Min Distance (pace calc) | 50m (0.05 km) | `activity_service.dart:68` |

### Catatan Penting

- **Tidak ada `.env` file** -- semua API keys hardcoded di source code
- **Tidak ada `config.dart`** -- konfigurasi tersebar di masing-masing file fitur
- **Tidak ada unit tests** -- directory `test/` masih kosong
- **Tidak ada autentikasi** -- aplikasi murni offline personal tracker

---

## 8. Roadmap & Fitur Mendatang

Berdasarkan README proyek:

- [ ] **Backend Server**: Hono + Bun + PostgreSQL
- [ ] **User Authentication**: JWT-based auth
- [ ] **Cloud Sync**: Sinkronisasi data antar device
- [ ] **Meal Photo Logging**: Foto makanan
- [ ] **Advanced Analytics**: Analisis nutrisi lebih detail
- [ ] **Social Features**: Share aktivitas dengan teman
