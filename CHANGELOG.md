# Changelog

## [1.4.1] - 2026-06-19

### Fixed
- **Food Screen**: Debounce timer now properly cancelled in `dispose()` to prevent memory leaks and stray API calls

### Changed
- **Food Screen**: Centralized Dio configuration with `_createDio()` — adds connect/receive timeouts (10s)
- **Food Screen**: Improved error handling with user-friendly Indonesian messages for HTTP 429 (rate limit), connection timeout, and connection errors

## [1.4.0] - 2026-06-19

### Added
- **Food Screen**: Custom arc glow nutrition chart (replaces fl_chart pie chart)
  - `CustomPaint` arc segments with per-segment glow effect
  - Animated entry with `easeOutCubic` curve
  - Tap interaction to show detailed gram info per macro in center
  - Animated legend with active highlight and glow borders
- **Activity Detail Screen**: Pace checkpoints every 0.5km
  - Colored pinpoint markers on map (bubble with distance + pace label)
  - Start (green ▶) and Finish (red ■) markers remain
- **Activity Detail Screen**: Pace history bar chart list
  - Horizontal bars per 0.5km segment, colored by pace
  - Distance label (left) and pace label (right) for each entry
- **Activity Screen**: Icon-based stats overlay
  - Icons: timer_outlined, straighten_outlined, speed_outlined, local_fire_department_outlined
  - Compact value display without units in overlay

### Changed
- **Food Screen**: Removed `fl_chart` dependency; replaced with custom `CustomPaint` painter (`_NutritionArcPainter`) matching `CalorieRing` visual style
- **Activity Screen**: Changed "MULAI" button text to "START"
- **Activity Detail Screen**: Refactored code with `_PaceCheckpoint`, `_PaceHistoryEntry`, `_PaceMarker`, `_PaceHistoryRow` widgets
- Stats overlay in Activity Screen uses icons instead of uppercase text labels

### Fixed
- Nutrition chart now properly resets touched index when tapping same segment again (toggle)

## [1.3.0] - 2026-06-19

### Added
- **Activity Service**: Singleton state management for outdoor run tracking
  - State persists across tab navigation (idle/running/paused)
  - Per-segment pace calculation with minimum distance threshold
  - Route points stored with timestamps for accurate pace data
- **Activity Screen**: LIVE indicator badge and My Location button
  - Green pulsing badge shows active tracking state
  - My Location button re-centers map to current position
  - Tile error fallback handler for offline resilience
- **Activity Detail Screen**: Colored polylines by pace
  - Green (fast ≤4 min/km) → Yellow (medium) → Red (slow ≥8 min/km)
  - Distinct Start (green) and Finish (red) markers
  - Pace legend overlay with gradient bar
- **Food Screen**: Nutrition pie chart with macro breakdown
  - Interactive pie chart showing Protein/Carbs/Fat distribution
  - Touch feedback with percentage display
  - Legend with gram values and percentages

### Changed
- Refactored `activity_screen.dart` to use `ActivityService` instead of local state
- Added `fl_chart` dependency for pie chart visualization
- Route points JSON now includes per-segment pace data

### Fixed
- Activity state no longer resets when switching between tabs
- Pace calculation uses minimum distance threshold (50m) to avoid initial bugs

## [1.2.0] - 2026-06-19

### Added
- **App Entrance**: 3D Animated Flutter splash screen and native launcher icons
  - Generated premium 3D fitness logo (`assets/icon.jpg`)
  - Configured native iOS splash screen via `flutter_native_splash`
  - Configured native iOS launcher icon via `flutter_launcher_icons`
  - Added Flutter-level animated splash screen with glowing effects
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

### Fixed
- **Dashboard**: Fixed StreamBuilder nesting issues and syntax errors.
- **Dashboard**: Merged `WorkoutLogs` stream to accurately calculate total calories burned from gym sessions.
- **Activity Screen**: Standardized activity type logic (`run` instead of `Outdoor Run`) to match history UI icons.
- **Stats Screen**: Cleaned up leftover dummy code (`_DummyHistoryItem`, `_buildHistoryCards`).
- **Stats Screen**: Added `WorkoutLogs` to history list to correctly display Gym sessions alongside Cardio.
- **Database**: Added `caloriesBurned` column to `WorkoutLogs` for accurate dashboard calculations.
- **Tests**: Updated `widget_test.dart` to use `FitApp` instead of `MyApp`.

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
