import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

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
  final List<ll.LatLng> _route = [];

  bool _isPlaying = false;
  bool _isStyleLoaded = false;
  bool _isResetting = false; // prevent concurrent resets

  // Periodic timer drives the animation (safer than AnimationController listener)
  Timer? _playTimer;
  int _currentIndex = 0;
  static const int _pointsPerTick = 3; // how many points to draw per tick
  static const Duration _tickInterval = Duration(milliseconds: 80);

  Symbol? _progressDot;

  static const String _mapTilerKey = 'KV6n4yl6DjwIdqdqA9NM';
  static const String _styleUrl =
      'https://api.maptiler.com/maps/hybrid/style.json?key=$_mapTilerKey';

  // ──────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────

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

  // ──────────────────────────────────────────────
  // Route parsing
  // ──────────────────────────────────────────────

  void _parseRoute() {
    if (widget.activity.routePoints.isEmpty) return;
    try {
      final decoded = jsonDecode(widget.activity.routePoints) as List;
      for (final p in decoded) {
        _route.add(ll.LatLng(
          (p['lat'] as num).toDouble(),
          (p['lng'] as num).toDouble(),
        ));
      }
    } catch (e) {
      debugPrint('Flyover: route parse error: $e');
    }
  }

  // ──────────────────────────────────────────────
  // Map callbacks
  // ──────────────────────────────────────────────

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    final ctrl = _mapController;
    if (ctrl == null || _route.isEmpty) return;

    // ── 1. Ghost route (full, dim) ───────────────────────────────────
    try {
      await ctrl.addLine(LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: '#FFFFFF',
        lineWidth: 2.0,
        lineOpacity: 0.2,
      ));
    } catch (e) {
      debugPrint('Flyover: addLine ghost error: $e');
    }

    // ── 2. Start & Finish symbols ────────────────────────────────────
    try {
      await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.first.latitude, _route.first.longitude),
        textField: '▶',
        textColor: '#00E676',
        textSize: 20,
        textHaloColor: '#000000',
        textHaloWidth: 2.0,
        textAnchor: 'center',
      ));
      await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.last.latitude, _route.last.longitude),
        textField: '■',
        textColor: '#FF1744',
        textSize: 20,
        textHaloColor: '#000000',
        textHaloWidth: 2.0,
        textAnchor: 'center',
      ));
    } catch (e) {
      debugPrint('Flyover: addSymbol marker error: $e');
    }

    // ── 3. Progress dot at start ─────────────────────────────────────
    try {
      _progressDot = await ctrl.addSymbol(SymbolOptions(
        geometry: LatLng(_route.first.latitude, _route.first.longitude),
        textField: '●',
        textColor: '#FFFFFF',
        textSize: 16,
        textHaloColor: '#FF5252',
        textHaloWidth: 4.0,
        textAnchor: 'center',
      ));
    } catch (e) {
      debugPrint('Flyover: addSymbol dot error: $e');
    }

    // ── 4. Fit camera to route bounds ────────────────────────────────
    try {
      final bounds = _computeBounds();
      await ctrl.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          left: 60,
          top: 120,
          right: 60,
          bottom: 140,
        ),
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      debugPrint('Flyover: fitBounds error: $e');
    }

    if (mounted) setState(() => _isStyleLoaded = true);
  }

  // ──────────────────────────────────────────────
  // Animation — driven by Timer, NOT AnimationController
  // (safer for async platform calls)
  // ──────────────────────────────────────────────

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

    if (_currentIndex >= _route.length - 1) {
      // Reached the end
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
            lineWidth: 5.0,
            lineOpacity: 1.0,
          ));
        } catch (e) {
          debugPrint('Flyover: addLine segment error: $e');
        }
      }
    }

    _currentIndex = batchEnd;

    // Update progress dot
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

    // Update progress UI
    if (mounted) setState(() {});
  }

  // ──────────────────────────────────────────────
  // Controls
  // ──────────────────────────────────────────────

  Future<void> _togglePlay() async {
    if (!_isStyleLoaded || _isResetting) return;

    if (_isPlaying) {
      // Pause
      _stopTimer();
      setState(() => _isPlaying = false);
    } else {
      // Play or replay from end
      if (_currentIndex >= _route.length - 1) {
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

    try {
      await ctrl.clearLines();
    } catch (e) {
      debugPrint('Flyover: clearLines error: $e');
    }

    // Re-add ghost route
    try {
      await ctrl.addLine(LineOptions(
        geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        lineColor: '#FFFFFF',
        lineWidth: 2.0,
        lineOpacity: 0.2,
      ));
    } catch (e) {
      debugPrint('Flyover: re-add ghost error: $e');
    }

    // Reset dot
    final dot = _progressDot;
    if (dot != null) {
      try {
        await ctrl.updateSymbol(
          dot,
          SymbolOptions(
            geometry: LatLng(_route.first.latitude, _route.first.longitude),
          ),
        );
      } catch (e) {
        debugPrint('Flyover: reset dot error: $e');
      }
    }

    _currentIndex = 0;

    if (mounted) {
      setState(() {
        _isResetting = false;
        _isPlaying = true;
      });
      _startTimer();
    }
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────

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

  double get _progress =>
      _route.isEmpty ? 0.0 : _currentIndex / (_route.length - 1);

  String get _progressLabel {
    final pct = (_progress * 100).toStringAsFixed(0);
    return '$pct%  (${_currentIndex + 1}/${_route.length} pts)';
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool atEnd =
        _route.isNotEmpty && _currentIndex >= _route.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Route Replay',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black54,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isStyleLoaded && !_isResetting)
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.white),
              tooltip: 'Replay from start',
              onPressed: _resetAndPlay,
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────
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

          // ── Loading overlay ───────────────────────────────────────────
          if (!_isStyleLoaded)
            Container(
              color: const Color(0xB3000000),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading satellite map…',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Resetting overlay ─────────────────────────────────────────
          if (_isResetting)
            Container(
              color: const Color(0x80000000),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // ── Progress bar ──────────────────────────────────────────────
          if (_isStyleLoaded)
            Positioned(
              bottom: 108,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _progressLabel,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),

          // ── Play / Pause / Replay button ──────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed:
                    (_isStyleLoaded && !_isResetting) ? _togglePlay : null,
                backgroundColor: _isStyleLoaded && !_isResetting
                    ? (atEnd ? Colors.orange : AppColors.primary)
                    : Colors.grey.shade700,
                elevation: 8,
                icon: Icon(
                  atEnd
                      ? Icons.replay
                      : (_isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                  color: Colors.white,
                  size: 26,
                ),
                label: Text(
                  atEnd
                      ? 'Replay'
                      : (_isPlaying ? 'Pause' : 'Play Route'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
