import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/database.dart';

enum ActivityState { idle, running, paused }

/// Singleton service yang menyimpan state Outdoor Run secara global.
/// State tidak akan hilang meski user berpindah tab.
class ActivityService extends ChangeNotifier {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  // ─── State ────────────────────────────────────────────────────────────────
  ActivityState state = ActivityState.idle;
  Duration duration = Duration.zero;
  double distanceKm = 0.0;
  int calories = 0;
  String pace = "0'00\"";
  List<LatLng> routePoints = [];

  // Internal tracking data: list of (point, timestamp) untuk pace per segment
  final List<_RoutePointData> _routeData = [];

  // Pace per segmen yang sudah dihitung (min/km), indeks sejajar routePoints
  final List<double> pacePerPoint = []; // nilai -1 berarti belum terhitung

  Timer? _timer;
  StreamSubscription<Position>? _positionSub;

  // ─── Minimum distance sebelum menghitung pace (hindari bug pace awal) ─────
  static const double _minDistanceForPaceKm = 0.05; // 50m

  // ─── Start ────────────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> startActivity() async {
    final granted = await requestPermission();
    if (!granted) return;

    state = ActivityState.running;
    if (routePoints.isEmpty) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        final startPoint = LatLng(pos.latitude, pos.longitude);
        final now = DateTime.now();
        routePoints.add(startPoint);
        pacePerPoint.add(-1);
        _routeData.add(_RoutePointData(point: startPoint, time: now));
      } catch (_) {}
    }
    notifyListeners();

    _startTimerAndStream();
  }

  void _startTimerAndStream() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      duration += const Duration(seconds: 1);
      _recalcPace();
      notifyListeners();
    });

    _positionSub ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      if (state != ActivityState.running) return;

      final newPoint = LatLng(pos.latitude, pos.longitude);
      final now = DateTime.now();

      double segPace = -1;
      if (_routeData.isNotEmpty) {
        final lastData = _routeData.last;
        final distM = Geolocator.distanceBetween(
          lastData.point.latitude, lastData.point.longitude,
          newPoint.latitude, newPoint.longitude,
        );
        distanceKm += distM / 1000.0;
        calories = (distanceKm * 60).round();

        // Hitung pace untuk segmen ini (menit per km)
        final timeDiffSec = now.difference(lastData.time).inMilliseconds / 1000.0;
        if (distM > 0 && timeDiffSec > 0) {
          final meterPerSec = distM / timeDiffSec;
          if (meterPerSec > 0) {
            segPace = (1000.0 / meterPerSec) / 60.0; // min/km
          }
        }
      }

      routePoints.add(newPoint);
      pacePerPoint.add(segPace);
      _routeData.add(_RoutePointData(point: newPoint, time: now));
      _recalcPace();
      notifyListeners();
    });
  }

  /// Hitung pace hanya jika sudah menempuh jarak minimum (hindari bug awal)
  void _recalcPace() {
    if (distanceKm < _minDistanceForPaceKm) {
      pace = "--'--\"";
      return;
    }
    final minutes = duration.inSeconds / 60.0;
    final paceValue = minutes / distanceKm;
    final paceMinutes = paceValue.floor();
    final paceSeconds = ((paceValue - paceMinutes) * 60).floor();
    pace = "$paceMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
  }

  // ─── Pause ────────────────────────────────────────────────────────────────
  void pauseActivity() {
    state = ActivityState.paused;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  // ─── Resume ───────────────────────────────────────────────────────────────
  void resumeActivity() {
    state = ActivityState.running;
    notifyListeners();
    _startTimerAndStream();
  }

  // ─── Stop & Save ──────────────────────────────────────────────────────────
  Future<void> stopActivity() async {
    _timer?.cancel();
    _timer = null;
    _positionSub?.cancel();
    _positionSub = null;

    if (routePoints.isNotEmpty) {
      // Simpan routePoints beserta pace per titik
      final routeJson = jsonEncode(
        List.generate(routePoints.length, (i) => {
          'lat': routePoints[i].latitude,
          'lng': routePoints[i].longitude,
          'pace': pacePerPoint.length > i ? pacePerPoint[i] : -1.0,
        }),
      );
      await db.into(db.activityLogs).insert(
        ActivityLogsCompanion.insert(
          type: 'run',
          date: DateTime.now(),
          durationSeconds: duration.inSeconds,
          distanceMeters: distanceKm * 1000,
          caloriesBurned: calories.toDouble(),
          routePoints: routeJson,
        ),
      );
    }

    // Reset semua state
    state = ActivityState.idle;
    duration = Duration.zero;
    distanceKm = 0.0;
    calories = 0;
    pace = "0'00\"";
    routePoints.clear();
    pacePerPoint.clear();
    _routeData.clear();

    notifyListeners();
  }
}

class _RoutePointData {
  final LatLng point;
  final DateTime time;
  _RoutePointData({required this.point, required this.time});
}
