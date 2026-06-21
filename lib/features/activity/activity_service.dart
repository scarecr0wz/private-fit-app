import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;
import '../../data/database.dart';
import '../../data/sync_service.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../weather/weather_service.dart';

enum ActivityState { idle, countdown, running, paused }

/// Tipe aktivitas
enum OutdoorActivityType { run, bike }

extension OutdoorActivityTypeExt on OutdoorActivityType {
  String get dbKey => this == OutdoorActivityType.run ? 'run' : 'bike';
  String get label => this == OutdoorActivityType.run ? 'Running' : 'Cycling';
  String get speedLabel => this == OutdoorActivityType.run ? 'Pace' : 'Speed';
}

/// Singleton service yang menyimpan state Outdoor Activity secara global.
/// State tidak akan hilang meski user berpindah tab.
class ActivityService extends ChangeNotifier {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  // ─── State ────────────────────────────────────────────────────────────────
  ActivityState state = ActivityState.idle;
  OutdoorActivityType activityType = OutdoorActivityType.run;

  Duration _accumulatedDuration = Duration.zero;
  DateTime? _lastStartTime;
  
  Duration get duration {
    if (state == ActivityState.running && _lastStartTime != null) {
      return _accumulatedDuration + DateTime.now().difference(_lastStartTime!);
    }
    return _accumulatedDuration;
  }
  double distanceKm = 0.0;
  int calories = 0;

  /// Running: pace (min/km) | Cycling: speed (km/h)
  String speedDisplay = "0'00\"";

  List<LatLng> routePoints = [];

  // Internal tracking data
  final List<_RoutePointData> _routeData = [];
  final List<double> pacePerPoint = []; // min/km per titik (-1 = unknown)
  final List<double> altitudePerPoint = []; // meter dari atas permukaan laut

  double elevationGain = 0.0;
  double _currentBaselineAlt = 0.0;
  static const double _elevationThreshold = 2.0; // Filter noise 2 meter

  // Weather snapshot saat activity dimulai
  WeatherData? _weatherSnapshot;

  // Countdown state
  int countdownValue = 5;

  Timer? _timer;
  Timer? _countdownTimer;
  StreamSubscription<Position>? _positionSub;

  // ─── Minimum distance sebelum menghitung pace ─────────────────────────────
  static const double _minDistanceForPaceKm = 0.05; // 50m

  // ─── Permission ───────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  // ─── Begin countdown then start ───────────────────────────────────────────
  Future<void> beginCountdown(OutdoorActivityType type) async {
    final granted = await requestPermission();
    if (!granted) return;

    activityType = type;
    state = ActivityState.countdown;
    countdownValue = 5;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdownValue--;
      notifyListeners();
      if (countdownValue <= 0) {
        t.cancel();
        _countdownTimer = null;
        _startActivity();
      }
    });
  }

  // ─── Start (dipanggil otomatis setelah countdown selesai) ─────────────────
  Future<void> _startActivity() async {
    state = ActivityState.running;
    if (routePoints.isEmpty) {
      try {
        LocationSettings settings;
        if (defaultTargetPlatform == TargetPlatform.android) {
          settings = AndroidSettings(
            accuracy: LocationAccuracy.high,
            forceLocationManager: true,
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          settings = AppleSettings(
            accuracy: LocationAccuracy.high,
            activityType: ActivityType.fitness,
          );
        } else {
          settings = const LocationSettings(accuracy: LocationAccuracy.high);
        }

        final pos = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );
        final startPoint = LatLng(pos.latitude, pos.longitude);
        final now = DateTime.now();
        routePoints.add(startPoint);
        pacePerPoint.add(-1);
        altitudePerPoint.add(pos.altitude);
        _currentBaselineAlt = pos.altitude;
        _routeData.add(_RoutePointData(point: startPoint, time: now, altitude: pos.altitude));

        // Snapshot cuaca di lokasi start (fire-and-forget)
        WeatherService.instance.fetchForLocation(pos.latitude, pos.longitude).then((w) {
          _weatherSnapshot = w;
        });
      } catch (_) {}
    }
    _lastStartTime ??= DateTime.now();
    notifyListeners();
    _startTimerAndStream();
  }

  void _startTimerAndStream() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      // The duration getter automatically calculates the current duration 
      // based on _lastStartTime, so we just need to notify listeners to update UI.
      _recalcSpeed();
      notifyListeners();
    });

    LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "Aplikasi sedang melacak aktivitas Anda di latar belakang.",
          notificationTitle: "FitFad Tracking",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 2,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      settings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
    }

    _positionSub ??= Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((pos) {
      if (state != ActivityState.running) return;

      final newPoint = LatLng(pos.latitude, pos.longitude);
      final now = DateTime.now();

      double segPace = -1;
      if (_routeData.isNotEmpty) {
        final lastData = _routeData.last;
        final distM = Geolocator.distanceBetween(
          lastData.point.latitude,
          lastData.point.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        distanceKm += distM / 1000.0;

        // Hitung kalori — running: ~60 kcal/km, cycling: ~30 kcal/km
        calories = activityType == OutdoorActivityType.run
            ? (distanceKm * 60).round()
            : (distanceKm * 30).round();

        final timeDiffSec =
            now.difference(lastData.time).inMilliseconds / 1000.0;
        if (distM > 0 && timeDiffSec > 0) {
          final meterPerSec = distM / timeDiffSec;
          if (meterPerSec > 0) {
            segPace = (1000.0 / meterPerSec) / 60.0; // min/km
          }
        }
      }

      // Hitung Elevation Gain (dengan noise filter)
      final newAlt = pos.altitude;
      if (altitudePerPoint.isNotEmpty) {
        final altDiff = newAlt - _currentBaselineAlt;
        if (altDiff >= _elevationThreshold) {
          elevationGain += altDiff;
          _currentBaselineAlt = newAlt;
        } else if (altDiff <= -_elevationThreshold) {
          _currentBaselineAlt = newAlt;
        }
      }

      routePoints.add(newPoint);
      pacePerPoint.add(segPace);
      altitudePerPoint.add(newAlt);
      _routeData.add(_RoutePointData(point: newPoint, time: now, altitude: newAlt));
      _recalcSpeed();
      notifyListeners();
    });
  }

  void _recalcSpeed() {
    if (activityType == OutdoorActivityType.run) {
      // Pace: min/km
      if (distanceKm < _minDistanceForPaceKm) {
        speedDisplay = "--'--\"";
        return;
      }
      final minutes = duration.inSeconds / 60.0;
      final paceValue = minutes / distanceKm;
      final paceMin = paceValue.floor();
      final paceSec = ((paceValue - paceMin) * 60).floor();
      speedDisplay = "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";
    } else {
      // Speed: km/h
      if (duration.inSeconds == 0 || distanceKm < _minDistanceForPaceKm) {
        speedDisplay = '0.0';
        return;
      }
      final hours = duration.inSeconds / 3600.0;
      final kmh = distanceKm / hours;
      speedDisplay = kmh.toStringAsFixed(1);
    }
  }

  // ─── Pause ────────────────────────────────────────────────────────────────
  void pauseActivity() {
    state = ActivityState.paused;
    if (_lastStartTime != null) {
      _accumulatedDuration += DateTime.now().difference(_lastStartTime!);
      _lastStartTime = null;
    }
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  // ─── Resume ───────────────────────────────────────────────────────────────
  void resumeActivity() {
    state = ActivityState.running;
    _lastStartTime = DateTime.now();
    notifyListeners();
    _startTimerAndStream();
  }

  // ─── Cancel countdown ─────────────────────────────────────────────────────
  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = ActivityState.idle;
    countdownValue = 5;
    notifyListeners();
  }

  // ─── Stop & Save ──────────────────────────────────────────────────────────
  Future<void> stopActivity() async {
    _timer?.cancel();
    _timer = null;
    _positionSub?.cancel();
    _positionSub = null;

    if (routePoints.isNotEmpty) {
      final routeJson = jsonEncode(
        List.generate(
          routePoints.length,
          (i) => {
            'lat': routePoints[i].latitude,
            'lng': routePoints[i].longitude,
            'pace': pacePerPoint.length > i ? pacePerPoint[i] : -1.0,
            'alt': altitudePerPoint.length > i ? altitudePerPoint[i] : 0.0,
          },
        ),
      );
      final now = DateTime.now();
      final insertData = ActivityLogsCompanion.insert(
        type: activityType.dbKey,
        date: now,
        durationSeconds: duration.inSeconds,
        distanceMeters: distanceKm * 1000,
        caloriesBurned: calories.toDouble(),
        routePoints: routeJson,
        weatherTemp: Value(_weatherSnapshot?.temperature),
        weatherHumidity: Value(_weatherSnapshot?.humidity),
        weatherWindKmh: Value(_weatherSnapshot?.windSpeedKmh),
        weatherCode: Value(_weatherSnapshot?.weatherCode),
      );
      final insertedId = await db.into(db.activityLogs).insert(insertData);
      
      // Sync ke VPS Backend
      final activityLogData = ActivityLog(
        id: insertedId,
        date: now,
        type: activityType.dbKey,
        durationSeconds: duration.inSeconds,
        distanceMeters: distanceKm * 1000,
        caloriesBurned: calories.toDouble(),
        routePoints: routeJson,
        weatherTemp: _weatherSnapshot?.temperature,
        weatherHumidity: _weatherSnapshot?.humidity,
        weatherWindKmh: _weatherSnapshot?.windSpeedKmh,
        weatherCode: _weatherSnapshot?.weatherCode,
      );
      syncServiceInstance.syncActivity(activityLogData);
    }

    // Reset semua state
    state = ActivityState.idle;
    _accumulatedDuration = Duration.zero;
    _lastStartTime = null;
    distanceKm = 0.0;
    calories = 0;
    speedDisplay = "0'00\"";
    elevationGain = 0.0;
    _currentBaselineAlt = 0.0;
    _weatherSnapshot = null;
    routePoints.clear();
    pacePerPoint.clear();
    altitudePerPoint.clear();
    _routeData.clear();

    notifyListeners();
  }
}

class _RoutePointData {
  final LatLng point;
  final DateTime time;
  final double altitude;
  _RoutePointData({required this.point, required this.time, required this.altitude});
}
