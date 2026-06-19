## Session 1 — Setup Project + Navigasi Dasar

**Goal**: App Flutter jalan di simulator iOS, ada bottom navigation 4 tab.

### 1.1 Buat project Flutter

```bash
flutter create fitapp --org com.yourname --platforms ios
cd fitapp
flutter pub get
```

### 1.2 Tambah dependencies awal ke `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Navigasi
  go_router: ^13.0.0

  # State management
  riverpod: ^2.5.0
  flutter_riverpod: ^2.5.0

  # Utils
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

Jalankan:
```bash
flutter pub get
```

### 1.3 Struktur folder

Buat folder-folder ini di dalam `lib/`:

```
lib/
├── main.dart
├── router.dart
├── theme.dart
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── food/
│   │   └── food_screen.dart
│   ├── activity/
│   │   └── activity_screen.dart
│   └── gym/
│       └── gym_screen.dart
└── shared/
    └── widgets/
```

### 1.4 `lib/theme.dart` — warna dan typography

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color surface = Color(0xFF1E1E2E);
  static const Color background = Color(0xFF13131F);
  static const Color cardBg = Color(0xFF252535);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF9090A8);
  static const Color accent = Color(0xFF63FFDA);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      surface: surface,
      onSurface: textPrimary,
    ),
    cardTheme: const CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    ),
  );
}
```

### 1.5 `lib/router.dart` — navigasi dengan go_router

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/food/food_screen.dart';
import 'features/activity/activity_screen.dart';
import 'features/gym/gym_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/food', builder: (c, s) => const FoodScreen()),
        GoRoute(path: '/activity', builder: (c, s) => const ActivityScreen()),
        GoRoute(path: '/gym', builder: (c, s) => const GymScreen()),
      ],
    ),
  ],
);

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/food') return 1;
    if (location == '/activity') return 2;
    if (location == '/gym') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/food');
            case 2: context.go('/activity');
            case 3: context.go('/gym');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Food'),
          NavigationDestination(icon: Icon(Icons.directions_run_outlined), selectedIcon: Icon(Icons.directions_run), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Gym'),
        ],
      ),
    );
  }
}
```

### 1.6 `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: FitApp()));
}

class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FitApp',
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
```

### 1.7 Screen placeholder sementara

`lib/features/dashboard/dashboard_screen.dart`:
```dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard')),
    );
  }
}
```

Buat yang sama untuk `food_screen.dart`, `activity_screen.dart`, `gym_screen.dart` — ganti teks di Center.

### 1.8 Cek di simulator

```bash
open -a Simulator
flutter run
```

**Checkpoint session 1**: App jalan, bisa pindah 4 tab, tidak ada error.

---