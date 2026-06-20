import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import '../../data/database.dart';
import '../../theme.dart';

class Flyover3DScreen extends StatefulWidget {
  final ActivityLog activity;
  const Flyover3DScreen({super.key, required this.activity});

  @override
  State<Flyover3DScreen> createState() => _Flyover3DScreenState();
}

class _Flyover3DScreenState extends State<Flyover3DScreen> {
  MapLibreMapController? _mapController;

  // ── Route data (pre-parsed) ──────────────────────────────────────────────
  final List<ll.LatLng> _route = [];
  final List<double> _pacePerPoint = []; // min/km, -1 = unknown
  final List<double> _altPerPoint = [];  // meters ASL
  final List<double> _cumDistKm = [];    // cumulative km at each index

  // ── UI state ─────────────────────────────────────────────────────────────
  bool _isPlaying = false;
  bool _isStyleLoaded = false;
  bool _isResetting = false;
  bool _cameraFollowMode = true; // third-person follow cam

  // ── Timer-based animation ────────────────────────────────────────────────
  Timer? _playTimer;
  int _currentIndex = 0;
  static const int _pointsPerTick = 2;
  static const Duration _tickInterval = Duration(milliseconds: 100);

  Symbol? _progressDot;

  static const String _mapTilerKey = 'KV6n4yl6DjwIdqdqA9NM';
  // outdoor-v2: hillshading + contour lines — best for terrain feel
  static const String _styleUrl =
      'https://api.maptiler.com/maps/outdoor-v2/style.json?key=$_mapTilerKey';

  // ── Computed getters ─────────────────────────────────────────────────────

  double get _progress => _route.length <= 1
      ? 0.0
      : _currentIndex / (_route.length - 1);

  double get _currentDistKm =>
      (_cumDistKm.isNotEmpty && _currentIndex < _cumDistKm.length)
          ? _cumDistKm[_currentIndex]
          : 0.0;

  double get _currentAlt =>
      (_altPerPoint.isNotEmpty && _currentIndex < _altPerPoint.length)
          ? _altPerPoint[_currentIndex]
          : 0.0;

  double get _currentPace =>
      (_pacePerPoint.isNotEmpty && _currentIndex < _pacePerPoint.length)
          ? _pacePerPoint[_currentIndex]
          : -1.0;

  int get _elapsedSeconds =>
      (widget.activity.durationSeconds * _progress).toInt();

  double get _currentCalories => widget.activity.caloriesBurned * _progress;

  bool get _hasAltData => _altPerPoint.any((a) => a > 1.0);
  bool get _hasPaceData => _pacePerPoint.any((p) => p > 0);
  bool get _atEnd =>
      _route.isNotEmpty && _currentIndex >= _route.length - 1;

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _parseRoute();
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Route parsing
  // ──────────────────────────────────────────────────────────────────────────

  void _parseRoute() {
    if (widget.activity.routePoints.isEmpty) return;
    try {
      final decoded = jsonDecode(widget.activity.routePoints) as List;
      const calc = ll.Distance();
      double cumDist = 0.0;

      for (int i = 0; i < decoded.length; i++) {
        final p = decoded[i];
        final point = ll.LatLng(
          (p['lat'] as num).toDouble(),
          (p['lng'] as num).toDouble(),
        );
        _route.add(point);
        _pacePerPoint.add((p['pace'] as num? ?? -1).toDouble());
        _altPerPoint.add((p['alt'] as num? ?? 0).toDouble());

        if (i > 0) {
          cumDist += calc.distance(_route[i - 1], point) / 1000.0;
        }
        _cumDistKm.add(cumDist);
      }
    } catch (e) {
      debugPrint('Flyover: parse error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Map callbacks
  // ──────────────────────────────────────────────────────────────────────────

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    final ctrl = _mapController;
    if (ctrl == null || _route.isEmpty) return;

    // Ghost route (dim indigo so outdoor map features are still visible)
    try {
      await ctrl.addLine(LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: '#5C6BC0',
        lineWidth: 3.0,
        lineOpacity: 0.4,
      ));
    } catch (e) {
      debugPrint('Flyover: ghost line error: $e');
    }

    // Start marker ▶
    try {
      await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.first.latitude, _route.first.longitude),
        textField: '▶',
        textColor: '#00E676',
        textSize: 22,
        textHaloColor: '#000000',
        textHaloWidth: 2.5,
        textAnchor: 'center',
      ));
    } catch (e) {
      debugPrint('Flyover: start marker error: $e');
    }

    // Finish marker ■
    try {
      await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.last.latitude, _route.last.longitude),
        textField: '■',
        textColor: '#FF1744',
        textSize: 22,
        textHaloColor: '#000000',
        textHaloWidth: 2.5,
        textAnchor: 'center',
      ));
    } catch (e) {
      debugPrint('Flyover: finish marker error: $e');
    }

    // Animated head dot
    try {
      _progressDot = await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.first.latitude, _route.first.longitude),
        textField: '●',
        textColor: '#FF5252',
        textSize: 20,
        textHaloColor: '#FFFFFF',
        textHaloWidth: 3.5,
        textAnchor: 'center',
      ));
    } catch (e) {
      debugPrint('Flyover: dot error: $e');
    }

    // Initial camera: overview of full route
    await _fitBounds();

    if (mounted) setState(() => _isStyleLoaded = true);
  }

  Future<void> _fitBounds() async {
    try {
      final bounds = _computeBounds();
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          left: 60,
          top: 120,
          right: 60,
          bottom: 200,
        ),
        duration: const Duration(milliseconds: 1200),
      );
    } catch (e) {
      debugPrint('Flyover: fitBounds error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Animation (Timer-based — avoids AnimationController listener crashes)
  // ──────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _stopTimer() {
    _playTimer?.cancel();
    _playTimer = null;
  }

  Future<void> _tick() async {
    final ctrl = _mapController;
    if (ctrl == null || !_isStyleLoaded || !mounted) {
      _stopTimer();
      return;
    }

    // Reached end of route
    if (_currentIndex >= _route.length - 1) {
      _stopTimer();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    // Draw next batch of segments
    final batchEnd =
        math.min(_route.length - 1, _currentIndex + _pointsPerTick);

    if (batchEnd > _currentIndex) {
      final segPoints = _route
          .sublist(_currentIndex, batchEnd + 1)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      if (segPoints.length >= 2) {
        try {
          await ctrl.addLine(LineOptions(
            geometry: segPoints,
            lineColor: '#FF5252',
            lineWidth: 5.5,
            lineOpacity: 1.0,
          ));
        } catch (e) {
          debugPrint('Flyover: addLine error: $e');
        }
      }
    }

    _currentIndex = batchEnd;

    // Move the head dot
    final dot = _progressDot;
    if (dot != null) {
      try {
        await ctrl.updateSymbol(
          dot,
          SymbolOptions(
            geometry: LatLng(
              _route[_currentIndex].latitude,
              _route[_currentIndex].longitude,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Flyover: updateSymbol error: $e');
      }
    }

    // ── Third-person camera follow ──────────────────────────────────
    if (_cameraFollowMode) {
      final current = _route[_currentIndex];

      // Bearing: direction from current to next point
      double bearing = 0.0;
      if (_currentIndex < _route.length - 1) {
        bearing = _getBearing(current, _route[_currentIndex + 1]);
      } else if (_currentIndex > 0) {
        bearing = _getBearing(_route[_currentIndex - 1], current);
      }

      // Fire-and-forget (don't await — avoids blocking tick cadence)
      ctrl
          .animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(current.latitude, current.longitude),
                zoom: 16.5,
                tilt: 60.0,   // third-person tilt
                bearing: bearing,
              ),
            ),
            duration: const Duration(milliseconds: 250),
          )
          .catchError((e) {});
    }

    if (mounted) setState(() {});
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Controls
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _togglePlay() async {
    if (!_isStyleLoaded || _isResetting) return;

    if (_isPlaying) {
      _stopTimer();
      setState(() => _isPlaying = false);
    } else {
      if (_atEnd) {
        await _resetAndPlay();
      } else {
        setState(() => _isPlaying = true);
        _startTimer();
      }
    }
  }

  Future<void> _resetAndPlay() async {
    final ctrl = _mapController;
    if (ctrl == null || _isResetting) return;

    setState(() {
      _isResetting = true;
      _isPlaying = false;
    });
    _stopTimer();

    // Clear animated lines
    try {
      await ctrl.clearLines();
    } catch (e) {
      debugPrint('Flyover: clearLines error: $e');
    }

    // Re-add ghost route
    try {
      await ctrl.addLine(LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: '#5C6BC0',
        lineWidth: 3.0,
        lineOpacity: 0.4,
      ));
    } catch (e) {
      debugPrint('Flyover: re-ghost error: $e');
    }

    // Reset dot to start
    final dot = _progressDot;
    if (dot != null) {
      try {
        await ctrl.updateSymbol(
          dot,
          SymbolOptions(
            geometry:
                LatLng(_route.first.latitude, _route.first.longitude),
          ),
        );
      } catch (e) {
        debugPrint('Flyover: reset dot error: $e');
      }
    }

    // Fly back to overview
    await _fitBounds();

    _currentIndex = 0;

    if (mounted) {
      setState(() {
        _isResetting = false;
        _isPlaying = true;
      });
      _startTimer();
    }
  }

  void _toggleCameraMode() {
    setState(() => _cameraFollowMode = !_cameraFollowMode);
    if (!_cameraFollowMode) {
      // Switch to overview
      _fitBounds();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  LatLngBounds _computeBounds() {
    double minLat = _route.first.latitude;
    double maxLat = _route.first.latitude;
    double minLng = _route.first.longitude;
    double maxLng = _route.first.longitude;

    for (final p in _route) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _getBearing(ll.LatLng from, ll.LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180.0 / math.pi + 360.0) % 360.0;
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0) return "--'--\"";
    final min = paceMinPerKm.floor();
    final sec = ((paceMinPerKm - min) * 60).round().clamp(0, 59);
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────
          MapLibreMap(
            styleString: _styleUrl,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            compassEnabled: false,
            myLocationEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
          ),

          // ── Loading overlay ─────────────────────────────────────────────
          if (!_isStyleLoaded)
            Container(
              color: const Color(0xCC000000),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading map…',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // ── Resetting overlay ───────────────────────────────────────────
          if (_isResetting)
            Container(
              color: const Color(0x80000000),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // ── Stats HUD ───────────────────────────────────────────────────
          if (_isStyleLoaded && _route.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              left: 12,
              right: 12,
              child: _StatsHud(
                time: _formatTime(_elapsedSeconds),
                distKm: _currentDistKm,
                calories: _currentCalories,
                pace: _hasPaceData ? _formatPace(_currentPace) : null,
                altM: _hasAltData ? _currentAlt : null,
              ),
            ),

          // ── Bottom panel (progress + controls) ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomPanel(
              progress: _progress,
              isPlaying: _isPlaying,
              atEnd: _atEnd,
              isStyleLoaded: _isStyleLoaded,
              isResetting: _isResetting,
              onTogglePlay: _togglePlay,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Route Replay',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 17),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
      ),
      actions: [
        if (_isStyleLoaded)
          Tooltip(
            message: _cameraFollowMode ? 'Following (tap for overview)' : 'Overview (tap to follow)',
            child: IconButton(
              icon: Icon(
                _cameraFollowMode ? Icons.videocam_rounded : Icons.map_rounded,
                color: _cameraFollowMode ? AppColors.primary : Colors.white60,
              ),
              onPressed: _toggleCameraMode,
            ),
          ),
        if (_isStyleLoaded && !_isResetting)
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            tooltip: 'Restart',
            onPressed: _resetAndPlay,
          ),
      ],
    );
  }
}

// ── Stats HUD widget ─────────────────────────────────────────────────────────

class _StatsHud extends StatelessWidget {
  final String time;
  final double distKm;
  final double calories;
  final String? pace;
  final double? altM;

  const _StatsHud({
    required this.time,
    required this.distKm,
    required this.calories,
    this.pace,
    this.altM,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasExtra = pace != null || altM != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Primary stats row ────────────────────────────────────
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCell(
                      icon: Icons.timer_outlined,
                      iconColor: Colors.white70,
                      value: time,
                      label: 'TIME',
                    ),
                    const VerticalDivider(color: Colors.white12, width: 1),
                    _StatCell(
                      icon: Icons.straighten_rounded,
                      iconColor: Colors.white70,
                      value: '${distKm.toStringAsFixed(2)} km',
                      label: 'DISTANCE',
                    ),
                    const VerticalDivider(color: Colors.white12, width: 1),
                    _StatCell(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFFF7043),
                      value: '${calories.toInt()}',
                      label: 'KCAL',
                    ),
                  ],
                ),
              ),

              // ── Secondary stats row (pace + altitude) ─────────────────
              if (hasExtra) ...[
                const SizedBox(height: 10),
                Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (pace != null)
                        _StatCell(
                          icon: Icons.speed_rounded,
                          iconColor: AppColors.primary,
                          value: pace!,
                          label: 'PACE',
                          valueSize: 17,
                        ),
                      if (pace != null && altM != null)
                        const VerticalDivider(color: Colors.white12, width: 1),
                      if (altM != null)
                        _StatCell(
                          icon: Icons.terrain_rounded,
                          iconColor: const Color(0xFF66BB6A),
                          value: '${altM!.toInt()} m',
                          label: 'ALTITUDE',
                          valueSize: 17,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double valueSize;

  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor.withValues(alpha: 0.8)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom control panel ──────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final double progress;
  final bool isPlaying;
  final bool atEnd;
  final bool isStyleLoaded;
  final bool isResetting;
  final VoidCallback onTogglePlay;

  const _BottomPanel({
    required this.progress,
    required this.isPlaying,
    required this.atEnd,
    required this.isStyleLoaded,
    required this.isResetting,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = isStyleLoaded && !isResetting;

    final Color btnColor = !enabled
        ? Colors.grey.shade800
        : atEnd
            ? const Color(0xFFFF7043)
            : isPlaying
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primary;

    final IconData btnIcon = atEnd
        ? Icons.replay_rounded
        : (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded);

    final String btnLabel =
        atEnd ? 'Replay' : (isPlaying ? 'Pause' : 'Play Route');

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            border: const Border(
              top: BorderSide(color: Colors.white12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Play / Pause / Replay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: enabled ? onTogglePlay : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(btnIcon, size: 22),
                  label: Text(
                    btnLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
