## Session 5 — GPS Activity Tracker UI

**Goal**: Layar tracker dengan peta (flutter_map), stats real-time dummy, tombol start/stop/pause.

### 5.1 Tambah dependencies

```yaml
dependencies:
  flutter_map: ^6.0.0
  latlong2: ^0.9.0
  geolocator: ^11.0.0
```

### 5.2 Izin di iOS

Tambah ke `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>FitApp butuh lokasi untuk track rute olahraga kamu.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>FitApp butuh lokasi di background untuk tracking rute yang akurat.</string>
```

### 5.3 Activity screen (outline)

```dart
// lib/features/activity/activity_screen.dart
// State: idle | running | paused
// Dummy: timer berjalan, jarak naik tiap detik
// Map: flutter_map dengan tile OpenStreetMap
// Stats bar: durasi | jarak | pace | kalori
// FAB: start → pause/resume + stop
```

> Timer pakai `Timer.periodic`, dummy lat/lng gerak sedikit tiap tick untuk simulasi tracking.

**Checkpoint session 5**: Bisa "mulai" tracking, timer jalan, stats update, peta tampil.

---