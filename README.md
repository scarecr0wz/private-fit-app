<div align="center">
  <img src="assets/icon.jpg" alt="FitFad Logo" width="128" height="128" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">

  # ⚡ FitFad

  <p align="center">
    <strong>The Ultimate Offline-First Personal Fitness, Nutrition & Outdoor Activity Tracking Suite</strong>
  </p>

  <p align="center">
    <a href="#-tech-stack"><img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Windows-blue?style=for-the-badge" alt="Platforms"></a>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter" alt="Flutter"></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart" alt="Dart"></a>
    <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/state%20management-Riverpod-purple?style=for-the-badge" alt="Riverpod"></a>
    <a href="https://drift.simonbinder.eu"><img src="https://img.shields.io/badge/database-Drift%20SQLite-ff69b4?style=for-the-badge" alt="Drift"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License"></a>
  </p>

  <br>
</div>

---

## 🚀 Overview

**FitFad** is an ultra-modern, privacy-focused, and feature-rich fitness application designed to revolutionize how you track nutrition, gym workouts, and outdoor activities. Built with **Flutter** using a robust **offline-first architecture**, FitFad delivers instantaneous responsiveness without requiring an active internet connection, while seamlessly backing up and synchronizing data across devices via a cloud REST API.

Whether you're calculating macro distributions, searching an offline catalog of 800+ gym exercises, rendering interactive body muscle heatmaps, listening to live TTS milestone voice coaching during runs, or generating cinematic 3D route replays and social media story videos—FitFad provides an all-in-one, premium experience tailored for athletes and fitness enthusiasts.

---

## 🌟 Key Highlights — Why FitFad?

* 🧬 **Interactive Muscle Activation Heatmap**: Real-time SVG body diagrams mapping workout intensity across 17 distinct muscle groups (front & back views) for daily workouts, weekly summaries, and past session histories.
* 🎬 **Cinematic 3D Route Replay & Video Export**: Experience Strava-style progressive route playback over satellite imagery and 3D terrain (MapLibre GL + MapTiler). Record animated MP4 video flyovers complete with stat overlays directly to your device for social sharing.
* 🔊 **Audio Voice Coaching & Milestones**: Live Text-To-Speech (TTS) announcements every kilometer announcing distance, current pace/speed, and burnt calories, plus automated countdown timers.
* 🏋️ **800+ Offline Exercise Catalog & Auto Rest Timers**: Instant fuzzy-search exercise lookup powered by a pre-seeded local SQLite database (`ExerciseDictionary`) with zero network delay. Automated 90-second glassmorphic rest timers with haptic feedback keep your workout tempo on point.
* ☁️ **Hybrid Cloud Sync & Multi-Device Auth**: Full JWT authentication (`LoginScreen` & `RegisterScreen`) connected to a Node.js + Hono + Prisma VPS backend. Pushes local offline logs asynchronously and restores complete personal histories upon sign-in.
* 🍎 **Global Barcode & Calorie Intelligence**: Lightning-fast food logging powered by Open Food Facts v3 (unmetered global barcode scanning) and USDA FoodData Central APIs, complete with custom arc macro glow charts and interactive monthly Calorie Calendars.
* 🌤️ **Contextual Weather Advisor**: Integrated Open-Meteo forecasts and reverse geocoding deliver real-time exercise suitability ratings and automatically snapshot weather conditions onto GPS activity logs.

---

## ✨ Core Features Breakdown

### 📊 1. Intelligent Dashboard & Weather Advisor
* **Dynamic Calorie Ring**: Animated 3D arc displaying live target intake vs. burn progress derived from personal BMR formulas (Mifflin-St Jeor).
* **Contextual Weather Widget**: Real-time ambient weather updates, hourly rain forecasts, and color-coded "Exercise Suitability" indicators (Great 💪 / Fair ⚠️ / Poor 🚫).
* **Weekly Muscle Heatmap Card**: At-a-glance 7-day aggregated muscle load visualization directly on your main feed.
* **Stream-Fed Feeds**: Instant updates of today's meal logs, gym sessions, and GPS cardio runs.

### 🍽️ 2. Food Logger & Calorie Calendar
* **Global Barcode Scanning**: Scan packaged food products via camera using Open Food Facts v3 API.
* **Smart USDA Search**: Instant search over thousands of whole foods with 500ms debounce protection and timeout fallbacks.
* **Custom Arc Glow Macro Chart**: Hand-crafted `CustomPaint` interactive nutrition chart rendering glowing protein, carb, and fat macro breakdowns.
* **Monthly Calorie Calendar**: Horizontal calendar timeline rendering color-coded progress rings for every single day of the current month.

### 🏃 3. Outdoor GPS Activity Tracker & 3D Flyover
* **Dual Activity Modes**: Tailored tracking algorithms for **Running** (pace min/km) and **Cycling** (speed km/h).
* **True Background Tracking**: OS-level persistence via Android Foreground Service and iOS Background Location updates with zero sleeping timer drops.
* **Pace Checkpoints & Profiles**: Colored map polyline segments (Green/Yellow/Red), 0.5km milestone pinpoint bubbles, and side-by-side segment speed comparison metrics.
* **Strava-Style 3D Replay & Video Recording**: Interactive MapLibre GL 3D terrain visualization. Export ready-to-share MP4 videos or photo graphic overlays for Instagram/Strava stories.

### 🏋️ 4. Gym Logger & Interactive Muscle Heatmap
* **SVG Body Heatmap Visualizer**: Powered by `flutter_body_part_selector` to highlight targeted muscles in gradient intensities based on sets, volume, and exercise mechanics.
* **800+ Exercise Offline Seeder**: Instant offline exercise search via local Drift SQLite queries without requiring an internet connection.
* **Automated Rest Timer**: Inline rest countdown overlay with glassmorphism styling, quick adjustment buttons (-30s/+30s), skip options, and heavy haptic alerts.
* **Comprehensive Session Summaries**: Full post-workout breakdown highlighting total duration, total volume (kg), sets performed, calories burned, and targeted muscle groups.

### 🔐 5. Cloud Sync Engine & Multi-Device Auth
* **JWT Authentication**: Full Registration and Login flow securing user sessions and personalized data.
* **Optimistic Offline Sync (`SyncService`)**: Log your workouts anywhere offline; background workers quietly sync local records to the VPS REST API once connected.
* **Multi-User Isolation**: Automatic local database sanitization (`db.clearAllData()`) upon logout guarantees data confidentiality on shared family devices.

---

## 🧰 Tech Stack & Architecture

FitFad follows clean architecture principles, cleanly separating UI components, state management providers, local Drift ORM layers, and remote HTTP services.

### Frontend (Flutter App)
| Component | Technology | Description |
|---|---|---|
| **Framework** | Flutter 3.41 • Dart 3.11 | Cross-platform UI toolkit |
| **State Management** | Riverpod 2.5 • ChangeNotifier | Reactive reactive dependency injection & complex GPS singletons |
| **Navigation** | GoRouter 13.x | Declarative routing with ShellRoute bottom navigation & auth guards |
| **Database (ORM)** | Drift 2.34 (SQLite) | Code-generated, type-safe reactive local storage (`fitfad.sqlite`) |
| **Mapping & GPS** | FlutterMap • MapLibre GL | CartoDB dark tile 2D tracking & MapTiler 3D terrain replay |
| **Location & Background** | Geolocator • Background Service | OS-level persistent GPS tracking and wake-locks |
| **Body Visualization** | flutter_body_part_selector | SVG vector rendering for interactive muscle heatmaps |
| **Barcode Scanner** | Mobile Scanner | Camera-based barcode scanning |
| **Audio & TTS** | flutter_tts | Real-time text-to-speech voice coaching and milestone announcements |
| **Charts & Graphics** | fl_chart • CustomPaint | Custom animated arc painters, line charts, and bar charts |

### Backend API & Cloud Services
| Component | Technology | Description |
|---|---|---|
| **API Server** | Node.js • Hono Framework | High-performance light REST API server |
| **Database & ORM** | PostgreSQL • Prisma ORM | Relational cloud database persistence |
| **Authentication** | JWT (JSON Web Tokens) | Secure stateless authentication & route protection |
| **Networking** | Dio HTTP Client | Front-end REST client with interceptors & optimistic background sync |

---

## 🏗️ Project Directory Structure

```
fitfad/
├── assets/                    # App icons, splash assets, and offline 800+ exercise dataset JSON
├── docs/                      # Technical architecture blueprints and implementation plans
├── lib/
│   ├── main.dart              # Application entry point, ProviderScope & DB seeding triggers
│   ├── router.dart            # GoRouter configuration with Auth Guards & ShellRoutes
│   ├── theme.dart             # Dark-kinetic glassmorphism theme system & AppColors
│   ├── data/
│   │   ├── database.dart      # Drift SQLite tables (FoodLogs, WorkoutLogs, ActivityLogs, ExerciseDictionary, etc.)
│   │   └── seeders/           # Automatic exercise database seeder logic
│   ├── features/
│   │   ├── auth/              # Login, Register, & Auth State Providers
│   │   ├── dashboard/         # Daily summary, CalorieRing, & Weekly Muscle Heatmap
│   │   ├── food/              # Food search, barcode scanner, macro chart, & Calorie Calendar
│   │   ├── activity/          # GPS tracking, background services, 3D route replay, & video exporter
│   │   ├── gym/               # Workout session logger, 800+ exercise search, & muscle heatmap widgets
│   │   ├── profile/           # User profile management & Mifflin-St Jeor calorie calculations
│   │   ├── sync/              # Background REST sync engine (`SyncService`)
│   │   ├── weather/           # Open-Meteo weather integrations & suitability engines
│   │   └── stats/             # Activity history & analytics charts
│   └── shared/
│       ├── services/          # Audio TTS services & location utilities
│       └── widgets/           # Glassmorphism cards, 3D buttons, & custom painters
├── test/                      # Unit and widget test suite
├── pubspec.yaml               # Package manifests & asset dependencies
└── README.md                  # System overview documentation
```

---

## 🚀 Getting Started

### Prerequisites
1. Install **Flutter SDK (v3.41.0 or higher)**: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
2. Ensure **Dart SDK (v3.11.0 or higher)** is available.
3. Android Studio / Xcode configured for mobile emulation or direct device deployment.

### Installation & Local Setup

```bash
# 1. Clone the repository
git clone https://github.com/your-username/fitfad.git
cd fitfad

# 2. Fetch dependencies
flutter pub get

# 3. Generate reactive Drift database code
dart run build_runner build --delete-conflicting-outputs

# 4. Launch FitFad on your preferred device
flutter run                  # Auto-detect connected target
flutter run -d ios           # iOS Simulator / Device
flutter run -d android       # Android Emulator / Device
flutter run -d chrome        # Web platform
flutter run -d windows       # Windows Desktop app
```

---

## 🗺️ Roadmap & Milestones

### ✅ Completed Features (v1.0.0 – v1.14.0)
- [x] **Core Dashboard**: CalorieRing, weather suitability widget, stream-fed daily activity feed.
- [x] **Nutrition Engine**: USDA food search, Open Food Facts v3 global barcode scanner, custom arc glow macro chart, Calorie Calendar.
- [x] **Outdoor GPS Suite**: True background location persistence, pace-colored polyline maps, elevation profiles, weather snapshots.
- [x] **Cinematic 3D Replay & Social Sharing**: MapLibre 3D terrain replay, automated MP4 flyover video recording export, story image templates.
- [x] **Voice Coaching**: Real-time TTS audio updates every 1km and automated countdowns.
- [x] **Gym & Muscle Heatmap**: Interactive SVG body heatmaps (17 muscle groups), local 800+ exercise catalog seeder, auto glassmorphic rest timers with haptics.
- [x] **Cloud Sync & Auth**: Full JWT authentication screens, background optimistic VPS REST synchronization (`SyncService`), per-user local DB wiping.

### 🔜 Upcoming Enhancements
- [ ] **Meal Photo Logging**: AI-powered food recognition via device camera.
- [ ] **Wearable Sync**: Companion apps for Apple Watch & Wear OS devices.
- [ ] **Home Screen Widgets**: iOS & Android glanceable widget extensions for daily calorie and streak tracking.
- [ ] **Social Leaderboards**: Challenge friends and compare weekly activity miles.

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for details.

<div align="center">
  <br>
  <sub>Engineered with ❤️ using Flutter, Dart & Drift SQLite</sub>
  <br>
  <sub>© 2026 FitFad Systems</sub>
</div>
