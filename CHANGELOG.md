y# Changelog

## [1.2.0] - 2026-06-19

### Added
- **Database Layer**: Local SQLite database using Drift for persistent data storage
  - Food logs, activity logs, and workout logs tables
  - Generated database schema (`database.g.dart`)
- **Food Screen**: Real USDA FoodData Central API integration
  - Live food search with debounce
  - Nutritional data parsing (calories, protein, carbs, fat)
  - Barcode scanner with OpenFoodFacts API for product lookup
  - Save food logs to local database
- **Activity Screen**: Real GPS location tracking with Geolocator
  - Live position stream for accurate distance measurement
  - Save activity logs to local database with route points
  - Proper pace calculation based on real distance
- **Gym Screen**: Full workout lifecycle management
  - Start/finish workout flow with duration tracking
  - Save workout logs and sets to local database
  - Total volume calculation
- **Dashboard**: Real-time data from local database via StreamBuilder
  - Today's calorie intake/outtake from DB
  - Recent meals and activities from DB
- **Stats Screen**: Activity history from database instead of dummy data

### Changed
- Added `drift`, `dio`, `mobile_scanner`, `path`, `path_provider` dependencies
- Added `drift_dev`, `build_runner` dev dependencies for code generation
- Updated iOS Info.plist with camera permission for barcode scanning

## [1.1.0] - 2026-06-19

### Added
- **Activity Screen**: Full outdoor run tracking UI with FlutterMap dark tile layer
  - Activity state management (idle/running/paused)
  - Real-time stats display: duration, distance, pace, calories
  - Route polyline tracking on map
  - 3D glass-morphism UI components (buttons, overlays, stat items)
- **Gym Screen**: Full gym workout tracking UI with exercise cards
  - Exercise cards with sets/reps/weight tracking
  - Add Set bottom sheet with weight/reps sliders
  - Daily routines horizontal chip selector
  - Motivational bento card component
  - 3D FAB and glass card UI components
- Data models: WorkoutTemplate, Exercise, WorkoutSet with dummy data

### Changed
- Added `flutter_map`, `latlong2`, `geolocator` dependencies for map and location features
- Updated iOS Info.plist for location permissions

## [1.0.0] - 2026-06-19

### Added
- Daily dashboard with calorie ring, activity cards, and meal list
- Food search with portion calculator and macro breakdown (calories, protein, carbs, fat)
- Barcode scanner placeholder (coming soon)
- Bottom navigation with glassmorphism blur effect
- 3D UI components: floating action button, pill stats, food result cards
- Dark theme with electric indigo and aquamarine accent palette
- Indonesian locale support for date formatting
- GoRouter-based navigation (Today, Food, Activity, Gym)

### Changed
- Restructured project layout: moved `fitapp/` contents to repository root
- Removed `prompts/` folder from repository
