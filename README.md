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

FitApp is a personal fitness tracker built with **Flutter** and an **offline-first architecture**. This project was born from my own passion for working out and the desire to have a platform fully tailored to how I train, eat, and track progress — built by me, for me.

It helps you log your meals, scan barcodes, track outdoor runs and rides with GPS, record gym workouts with sets and reps, and visualize your stats — all stored locally on your device with no internet required.

> **Status:** Open source — built for personal use and learning. Backend sync (Hono + Bun + PostgreSQL) is planned.

---

## ✨ Features

### 📊 Daily Dashboard
- Daily calorie summary with an interactive **CalorieRing** (3D animated arc)
- Intake vs outtake stats in pill cards
- Recent activity feed (running, cycling, gym)
- Today's meal history with timestamps and calories
- Quick action FAB to open the Food Logger

### 🍽️ Food Logger
- **Food search** via the USDA FoodData Central API (500ms debounce)
- **Barcode scanning** using the camera + Open Food Facts API
- Adjustable portion size (10–500g) with full macro breakdown (calories, protein, carbs, fat)
- **Custom nutrition chart** — arc chart with per-macro glow effects
- Daily food history persisted to local database

### 🏃 Activity Tracker (GPS)
- Real-time outdoor activity tracking with **FlutterMap** (CartoDB dark tiles)
- Two modes: **Running** (pace in min/km) and **Cycling** (speed in km/h)
- 5-second countdown before starting
- Live stats overlay: duration, distance, pace/speed, estimated calories
- Start / Pause / Stop controls with 3D buttons
- **LIVE indicator badge** while tracking
- Custom map markers: Red Bull F1-inspired for cycling, running shoe for running

### 🏋️ Gym Logger
- Full workout lifecycle: start → add sets → finish
- Routine templates: Push Day, Pull Day, Leg Day, Cardio
- Per-exercise set tracking (reps, weight)
- Add sets via a bottom sheet with weight & reps sliders
- Workout summary: duration, total volume (kg), estimated calories burned

### 📈 Stats & History
- **Bar chart** — daily calories burned (this week / this month)
- **Line chart** — body weight trend (last 7 entries)
- Combined activity history (outdoor + gym), sorted by date
- **Activity Detail** — route map with pace-colored polyline:
  - Green (fast), Yellow (moderate), Red (slow)
  - Pace checkpoint every 0.5km with colored bubbles
  - Pace history with horizontal progress bars

### 🎨 UI & Theme
- **Dark theme** with **glassmorphism** and 3D accents
- Custom palette: Electric Indigo, Aquamarine, Punch Pink
- Font: Inter (Google Fonts)
- Animated 3D splash screen
- Bottom navigation with glassmorphism blur (GoRouter ShellRoute)

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.41 • Dart 3.11 |
| **State Management** | Riverpod (`flutter_riverpod`) + ChangeNotifier |
| **Navigation** | GoRouter 13.x (ShellRoute + bottom nav) |
| **Database** | Drift 2.34 (SQLite ORM, code-generated) |
| **Maps** | FlutterMap + OpenStreetMap (CartoDB dark tiles) |
| **Location** | Geolocator (GPS streaming) |
| **Scanner** | Mobile Scanner (barcode) |
| **APIs** | USDA FoodData Central • Open Food Facts v3 |
| **Charts** | fl_chart • CustomPaint |
| **CI/CD** | GitHub Actions (iOS build → .ipa artifact) |

---

## 📸 Screenshots

> _Coming soon — screenshots will be added after the polish session._

---

## 🏗️ Architecture

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

### Data Architecture

- **Offline-first** — all data is stored locally in SQLite via Drift
- 5 main tables: `FoodLogs`, `WorkoutLogs`, `WorkoutSets`, `ActivityLogs`, `BodyWeights`
- Outdoor activity state is managed by `ActivityService` (singleton ChangeNotifier) to persist across tab switches
- External APIs (USDA, Open Food Facts) enrich food data on demand

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.41+ ([install guide](https://docs.flutter.dev/get-started/install))
- Dart 3.11+ (bundled with Flutter)
- Code generation: `build_runner`

### Installation

```bash
# Clone the repository
git clone https://github.com/username/fitapp.git
cd fitapp

# Install dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build

# Run on your preferred platform
flutter run           # Auto-detect device
flutter run -d ios    # iOS
flutter run -d android
flutter run -d chrome # Web
flutter run -d windows
```

### API Notes

- **USDA FoodData Central** uses a `DEMO_KEY` by default (rate-limited). For production use, get a free API key at [fdc.nal.usda.gov](https://fdc.nal.usda.gov/).
- **Open Food Facts** is a public API — no key required.

---

## 📁 Project Structure

```
fitapp/
├── .github/workflows/   # CI/CD — iOS build workflow
├── android/             # Android platform
├── assets/              # Logo & assets
├── docs/                # User feedback documentation
├── ios/                 # iOS platform (deployment target 15.0)
├── lib/                 # Main source code
├── prompts/             # Session development plans
├── test/                # Unit tests
├── web/                 # Web platform (Drift WASM worker)
├── windows/             # Windows platform
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🗺️ Roadmap

### ✅ Shipped (v1.0.0 – v1.5.0)
- [x] Dashboard with CalorieRing
- [x] Food search (USDA API) & barcode scanner (Open Food Facts)
- [x] GPS outdoor activity tracking (running / cycling)
- [x] Gym workout logging with sets & reps
- [x] Stats charts & activity history
- [x] Route review with pace-colored polyline
- [x] Local SQLite persistence (Drift)

### 🔜 Up Next
- [ ] Backend sync (Hono + Bun + PostgreSQL + JWT)
- [ ] User authentication
- [ ] Cloud backup & restore
- [ ] Social features (challenges, leaderboard)
- [ ] iOS & Android widgets
- [ ] Apple Watch / Wear OS companion
- [ ] Dark/light mode toggle
- [ ] Unit & integration test coverage

---

## 🤝 Contributing

Since this is a personal project, external contributions are not planned at this time. However, if you find a bug or have a suggestion, feel free to open an [issue](https://github.com/username/fitapp/issues).

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <sub>Built with ❤️ using Flutter & Dart</sub>
  <br>
  <sub>© 2026 FitApp</sub>
</div>
