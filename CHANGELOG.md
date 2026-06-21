# Changelog

## [1.10.1] - 2026-06-21

### Added
- **Activity**: Added an Activity Summary pop-up dialog that displays duration, distance, calories, average pace, and elevation gain when the user stops an activity.
- **Activity Detail**: Added a Pace Profile Chart below the Elevation Profile to visualize pacing dynamics.

### Changed
- **Activity Detail**: Refactored the Weather section into a compact, space-saving text format below the main statistics.

### Fixed
- **Activity**: Fixed a routing error (`Page Not found`) that occurred when pressing the "DONE" button after recording an activity by directing it to the correct root dashboard route.
- **Activity 3D Flyover**: Fixed altitude statistics not starting at 0m by calculating relative altitude from the starting point instead of using raw sea-level data.

## [1.10.0] - 2026-06-21

### Added
- **User Profile**: Created a new dedicated Profile Screen featuring a beautiful glassmorphism design.
- **User Profile**: Added local storage persistence using `shared_preferences` and Riverpod state management.
- **User Profile**: Added Profile Picture upload functionality using the `image_picker` package.
- **Dashboard**: Integrated dynamic Calorie Goal calculation utilizing the Mifflin-St Jeor formula based on the user's Profile data (weight, height, age, gender, activity level, and main goal).
- **Dashboard**: Added the user's customized name from Profile settings to the greeting ("Hello, [Name]! 👋").
- **Dashboard**: Moved the Profile navigation button to the top-right app bar alongside the notification icon.

### Removed
- **User Profile**: Removed "Unit System" setting from the UI to streamline the layout.

## [1.9.3] - 2026-06-21

### Added
- **Food Screen**: Introduced a new minimalist horizontal "Calorie Calendar" timeline. Displays the entire current month's dates with interactive calorie rings colored based on progress towards a 2000 kcal daily goal, directly fed from SQLite food logs.

### Fixed
- **Food Screen**: Re-organized filter UI; replaced horizontally scrolling chips with a clean drop-down action sheet and quick-chips.
- **GitHub Actions**: Fixed YAML syntax error in `.github/workflows/build-ios.yml` caused by an accidental trailing colon.

## [1.9.2] - 2026-06-21

### Added
- **Food**: Added filters on Food page. (Today (customizable-range), This Week, This Month and All Time)

## [1.9.1] - 2026-06-21

### Changed
- **Activity Detail**: Normalized Elevation Profile data to always start at 0m, making the chart show relative elevation changes instead of absolute sea-level altitude. Elevation Gain calculations remain accurate and unaffected.
- **Activity Detail**: Redesigned the "3D Flyover" button to a minimalist "3D Route" control floating at the top-right of the map, separating it from the Pace legend.

## [1.9.0] - 2026-06-21

### Changed
- **Rebranding**: Completely rebranded the application from "FitApp" to "FitFad" globally across the entire system.
  - Updated documentation (`README.md`, `CHANGELOG.md`).
  - Updated Dart/Flutter frontend codebase, package names, and imports.
  - Updated native build configurations (Android, iOS, Web, Windows).
  - Updated local database schema names and SQLite identifiers.

## [1.8.2] - 2026-06-21

# Fixed
- **Dashboard UI**: Fixed "Weather Section" information padding unbalanced, now balanced on the header.

## [1.8.1] - 2026-06-21

### Added
- **Weather Widget**: Short-term predictive weather forecasts (e.g., "Expect rain in ~2h 🌧️") powered by Open-Meteo's hourly API integration.
- **Weather Widget**: Dynamic and specific exercise suitability messages depending on weather thresholds (e.g., "Extreme heat (36°C) 🥵 Risk of heatstroke...").
- **Weather Widget**: City name location tracking via Nominatim OpenStreetMap Reverse Geocoding API.
- **Weather Widget**: Day and night aware emojis (e.g., ☀️ for day, 🌙 for night) using Open-Meteo's `is_day` property.

### Changed
- **Dashboard Layout**: Refactored `WeatherCard` to display inline with the "Hello, User!" greeting, removing the heavy card container for a cleaner, compact dashboard UI that fits the dark-kinetic style.
- **Weather Service**: Reduced caching duration from 15 minutes to 5 minutes for more frequent updates.

### Fixed
- **Dashboard UI**: Fixed `RenderFlex overflowed by 99710 pixels` crash by wrapping inline greeting and weather elements with `Expanded` and `Flexible`.

## [1.8.0] - 2026-06-20

### Added
- **Weather System**: Integrated [Open-Meteo](https://open-meteo.com/) free weather API (no API key required).
- **Dashboard**: New glassmorphism weather card showing:
  - Current temperature, feels-like temperature, and weather description (WMO code → emoji + label)
  - Humidity, wind speed, and precipitation chips
  - Color-coded "Exercise Suitability" banner: 💪 Great / ⚠️ Fair / 🚫 Poor — based on temperature, rain, wind, and humidity thresholds
  - Refresh button; auto-refreshes every 15 minutes (cached to avoid spam)
- **Activity Recording**: Weather snapshot automatically captured at GPS start position when an outdoor activity begins. Saved silently in the background without blocking the start flow.
- **Activity Detail Screen**: New "Weather During Activity" section displayed below the Elevation Profile, showing the weather that was recorded at activity start time — weather emoji, temperature, wind speed, and humidity.
- **Database Migration**: `ActivityLogs` table migrated from schema v1 → v2 with 4 new nullable columns: `weatherTemp`, `weatherHumidity`, `weatherWindKmh`, `weatherCode`. Old activity records are preserved (columns default to null).

### Technical
- New `WeatherService` singleton (`lib/features/weather/weather_service.dart`) with 15-minute in-memory cache and graceful fallback on network errors.
- `WmoWeather` helper class maps WMO weather codes to emoji and description strings.
- `ExerciseSuitability` enum with scoring logic: Poor if thunderstorm / temp >35°C or <5°C / wind >50 km/h / rain >5mm; Fair if rain / temp >30°C / wind >30 km/h / humidity >80%; otherwise Great.

## [1.7.2] - 2026-06-20

### Changed
- **3D Flyover → Route Replay**: Redesigned the 3D map screen from a cinematic flyover into a Strava-style route replay.
  - **Route now renders correctly**: switched from unreliable GeoJSON source updates to MapLibre `addLine` annotation API, which guarantees the route line is always visible.
  - **Satellite + 3D terrain**: map style changed to MapTiler `hybrid` (satellite tiles with road/label overlay); terrain DEM source added with 1.5× elevation exaggeration via `setTerrain`.
  - **Strava-style progressive drawing**: full ghost route (dim white) shown immediately on load; a bright red line grows from start to finish as the animation plays; a moving white dot indicates the current head position.
  - **Stationary camera**: camera now fits the entire route in view on load (with slight 40° tilt for 3D depth) and stays fixed during replay — no more disorienting camera flying.
  - **Replay button**: added a reset/replay icon in the app bar to restart animation from the beginning without re-navigating.
  - **Progress bar**: a progress indicator below the play button shows replay % and current point count.
  - **Loading overlay**: descriptive loading screen shown while satellite tiles and terrain DEM initialize.

## [1.7.0] - 2026-06-19

### Added
- **Activity Detail Screen**: Added "3D Flyover" feature utilizing MapLibre GL and MapTiler's 3D Terrain data.
- **Activity Detail Screen**: Users can now watch an automated cinematic 3D camera flyover animation tracing their exact activity route from start to finish.

## [1.6.0] - 2026-06-19

### Added
- **Activity Tracking**: Added background altitude (elevation) recording utilizing GPS sensors.
- **Activity Tracking**: Real-time automated Elevation Gain calculation with a 2-meter noise threshold filter to prevent inaccurate GPS leaps.
- **Activity Detail Screen**: Added new "ELEV GAIN" statistic to the summary metrics panel.
- **Activity Detail Screen**: Beautiful 2D interactive Area Chart added below Pace History to visualize the route's elevation profile.

## [1.5.3] - 2026-06-19

### Added
- **Activity Detail Screen**: Pace history list now displays pace difference (faster/slower) compared to the previous segment.
  - Slower pace is marked with a red downward arrow (↓) and red highlight.
  - Faster pace is marked with a green upward arrow (↑) and green highlight.

## [1.5.2] - 2026-06-19

### Added
- **Activity Tracking**: Added true background tracking support for both Android and iOS.
  - Android: Implemented Foreground Service with persistent notification to prevent OS from killing the app.
  - iOS: Enabled Background Location Updates mode in `Info.plist`.
  - Android: Added necessary permissions (`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `WAKE_LOCK`, `ACCESS_BACKGROUND_LOCATION`) in `AndroidManifest.xml`.
- **Activity Tracking**: Absolute time calculation for duration. Prevents timer from pausing when the device goes into deep sleep mode.
- **Activity Screen**: Offline detection using `connectivity_plus`. Displays a red warning Snackbar if the user starts an activity without internet, clarifying that tracking still works even if the map doesn't load.

## [1.5.1] - 2026-06-19

### Changed
- **Activity Screen**: Start button text changed from "MULAI" to "START".
- **Activity Screen**: Removed circular progress bar from the countdown overlay for a cleaner UI.
- **Activity Tracking**: Replaced CustomPaint F1 car map marker with a crisp, high-res OS Race Car Emoji (🏎️).
- **Food Screen**: Changed default portion size from 200g to 100g in Add Food bottom sheet to match standard nutritional data baseline.
- **Documentation**: Generated `docs/user_feedback_v3.md` compiling the recent feedback and fixes.

### Fixed
- **Activity Screen**: Fixed metrics card UI wrapping by forcing 4-column equal width via `Expanded` + `FittedBox` + `maxLines: 1`. 
- **Food Screen**: Fixed "Protein" label wrapping in the nutrition legend by replacing `Expanded` with `Spacer()`.
## [1.5.0] - 2026-06-19

### Added
- **Activity Screen**: Activity Type selector (Running / Cycling) bottom sheet with 3D animated cards
- **Activity Screen**: Fullscreen 5-second countdown overlay before activity starts
- **Activity Tracking**: Dynamic pace/speed label and calculation based on activity type (Pace min/km for run, Speed km/h for bike)
- **Activity Tracking**: Custom map markers (`activity_icons.dart`) replacing standard blue dot:
  - F1 Red Bull Car (`CustomPainter`) for Cycling
  - Running Shoe Emoji (`👟`) for Running
- **Activity Detail Screen**: Finish marker now uses custom F1 Car or Running Shoe based on recorded activity type
- **Documentation**: Updated `docs/user_feedback_v2.md` with activity type & map markers section
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
- **Tests**: Updated `widget_test.dart` to use `FitFad` instead of `MyApp`.

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
- Restructured project layout: moved `fitfad/` contents to repository root
- Removed `prompts/` folder from repository
