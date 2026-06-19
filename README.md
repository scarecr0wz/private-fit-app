<div align="center">
  <img src="assets/icon.jpg" alt="FitApp Logo" width="120" height="120" style="border-radius: 24px;">

  # FitApp

  <p align="center">
    <strong>Fitness Tracker — Track your nutrition, workouts, and outdoor activities</strong>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows-blue" alt="Platforms">
    <img src="https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/state%20management-Riverpod-purple" alt="Riverpod">
    <img src="https://img.shields.io/badge/database-Drift-ff69b4" alt="Drift">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  </p>

  <br>
</div>

FitApp adalah aplikasi fitness personal yang dibangun dengan **Flutter** dan **offline-first architecture**. Aplikasi ini dirancang untuk membantu pengguna mencatat asupan makanan, melacak latihan gym, memantau aktivitas outdoor (lari/bersepeda) dengan GPS, serta melihat statistik perkembangan kebugaran — semuanya tersimpan secara lokal di perangkat tanpa perlu koneksi internet.

> **Status:** Open source — dikembangkan untuk kepentingan pribadi dan pembelajaran. Backend (Hono + Bun + PostgreSQL) sedang dalam tahap perencanaan.

---

## ✨ Fitur

### 📊 Dashboard Harian
- Ringkasan kalori harian dengan **CalorieRing** interaktif (3D arc progress)
- Statistik intake vs outtake dalam bentuk pill cards
- Daftar aktivitas terbaru (lari, gowes, gym)
- Riwayat makanan hari ini lengkap dengan waktu dan kalori
- Tombol aksi cepat untuk membuka Food Logger

### 🍽️ Food Logger
- **Pencarian makanan** via USDA FoodData Central API (debounce 500ms)
- **Pindai barcode** produk menggunakan kamera + Open Food Facts API
- Porsi adjustable (10–500g) dengan rincian makro (kalori, protein, karbohidrat, lemak)
- **Nutrition chart** — arc chart kustom dengan glow effect per makro
- Riwayat makanan harian tersimpan di database lokal

### 🏃 Activity Tracker (GPS)
- Pelacakan aktivitas outdoor real-time dengan **FlutterMap** (CartoDB dark tiles)
- Dua mode: **Running** (pace min/km) dan **Cycling** (speed km/h)
- Countdown 5 detik sebelum memulai
- Live stats: durasi, jarak, pace/speed, estimasi kalori
- Kontrol Start / Pause / Stop dengan 3D buttons
- **LIVE indicator badge** saat aktivitas berlangsung
- Marker kustom: Red Bull F1 untuk gowes, icon shoe untuk lari

### 🏋️ Gym Logger
- Workout lifecycle: mulai → tambah set → selesai
- Template rutin: Push Day, Pull Day, Leg Day, Cardio
- Tracking sets per exercise (reps, weight)
- Tambah set via bottom sheet dengan slider weight & reps
- Ringkasan durasi, total volume (kg), dan estimasi kalori

### 📈 Stats & History
- **Bar chart** kalori terbakar per hari (minggu ini / bulan ini)
- **Line chart** tren berat badan (7 entri terakhir)
- Riwayat aktivitas gabungan (outdoor + gym) diurutkan berdasarkan tanggal
- **Activity Detail** — rute di peta dengan polyline berwarna berdasarkan pace
  - Hijau (cepat), Kuning (sedang), Merah (lambat)
  - Pace checkpoint setiap 0.5km dengan colored bubbles
  - Pace history dengan horizontal progress bars

### 🎨 Tampilan & Tema
- **Dark theme** penuh dengan gaya **glassmorphism** dan aksen 3D
- Palet warna: Electric Indigo, Aquamarine, Punch Pink
- Font: Inter (Google Fonts)
- Animasi splash screen 3D dengan logo
- Bottom navigation dengan glassmorphism blur (GoRouter ShellRoute)

---

## 🧰 Tech Stack

| Lapisan | Teknologi |
|---|---|
| **Framework** | Flutter 3.41 • Dart 3.11 |
| **State Management** | Riverpod (`flutter_riverpod`) + ChangeNotifier |
| **Navigation** | GoRouter 13.x (ShellRoute + bottom nav) |
| **Database** | Drift 2.34 (SQLite ORM code-generated) |
| **Maps** | FlutterMap + OpenStreetMap (CartoDB dark tiles) |
| **Lokasi** | Geolocator (GPS streaming) |
| **Scanner** | Mobile Scanner (barcode) |
| **API** | USDA FoodData Central • Open Food Facts v3 |
| **Charts** | fl_chart • CustomPaint |
| **CI/CD** | GitHub Actions (iOS build → .ipa artifact) |

---

## 📸 Screenshot

> _Coming soon — tangkapan layar akan ditambahkan setelah sesi polish._

---

## 🏗️ Arsitektur

```
lib/
├── main.dart                  # Entry point, ProviderScope, MaterialApp.router
├── router.dart                # GoRouter config (6 routes + ShellRoute)
├── theme.dart                 # Dark theme system (AppColors, AppTheme)
├── data/
│   └── database.dart          # Drift ORM — 5 tables + AppDatabase singleton
├── features/
│   ├── splash/                # Animated splash screen
│   ├── dashboard/             # Daily summary & stats
│   ├── food/                  # Food search, barcode scan, nutrition chart
│   ├── activity/              # GPS tracking, route map, activity detail
│   ├── gym/                   # Workout logging & set tracking
│   └── stats/                 # Charts & activity history
└── shared/
    └── widgets/               # CalorieRing, GlassCard, 3D buttons, etc.
```

### Arsitektur Data

- **Offline-first** — semua data disimpan lokal di SQLite via Drift
- 5 tabel utama: `FoodLogs`, `WorkoutLogs`, `WorkoutSets`, `ActivityLogs`, `BodyWeights`
- State outdoor activity dikelola oleh `ActivityService` (singleton ChangeNotifier) agar tetap aktif saat navigasi antar tab
- Integrasi API eksternal (USDA, Open Food Facts) untuk enrichment data makanan

---

## 🚀 Mulai

### Prasyarat

- Flutter SDK 3.41+ ([install](https://docs.flutter.dev/get-started/install))
- Dart 3.11+ (bundled with Flutter)
- Code generation: `build_runner`

### Instalasi

```bash
# Clone repository
git clone https://github.com/username/fitapp.git
cd fitapp

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build

# Jalankan di platform pilihan
flutter run           # Auto-detect device
flutter run -d ios    # iOS
flutter run -d android
flutter run -d chrome # Web
flutter run -d windows
```

### Catatan API

- **USDA FoodData Central** menggunakan `DEMO_KEY` (terbatas). Untuk penggunaan lebih lanjut, daftar API key gratis di [fdc.nal.usda.gov](https://fdc.nal.usda.gov/).
- **Open Food Facts** bersifat public, tidak perlu API key.

---

## 📁 Struktur Project

```
fitapp/
├── .github/workflows/   # CI/CD — iOS build workflow
├── android/             # Platform Android
├── assets/              # Logo & assets
├── docs/                # Dokumentasi feedback user
├── ios/                 # Platform iOS (deployment target 15.0)
├── lib/                 # Source code utama
├── prompts/             # Session development plans
├── test/                # Unit tests
├── web/                 # Platform Web (Drift WASM worker)
├── windows/             # Platform Windows
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🗺️ Roadmap

### ✅ Tersedia (v1.0.0 – v1.5.0)
- [x] Dashboard with CalorieRing
- [x] Food search (USDA API) & barcode scanner (Open Food Facts)
- [x] GPS outdoor activity tracking (running / cycling)
- [x] Gym workout logging with sets & reps
- [x] Stats charts & activity history
- [x] Route review with pace-colored polyline
- [x] Local SQLite persistence (Drift)

### 🔜 Rencana Selanjutnya
- [ ] Sinkronisasi backend (Hono + Bun + PostgreSQL + JWT)
- [ ] Autentikasi pengguna
- [ ] Cloud backup & restore
- [ ] Social features (challenges, leaderboard)
- [ ] Widget iOS & Android
- [ ] Apple Watch / Wear OS companion
- [ ] Dark/light mode toggle
- [ ] Unit & integration tests coverage

---

## 🤝 Kontribusi

Karena proyek ini bersifat personal, kontribusi eksternal tidak direncanakan saat ini. Namun, jika Anda menemukan bug atau memiliki saran, silakan buka [issue](https://github.com/username/fitapp/issues).

---

## 📄 Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <sub>Built with ❤️ using Flutter & Dart</sub>
  <br>
  <sub>© 2026 FitApp</sub>
</div>
