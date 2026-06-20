import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
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

class _Flyover3DScreenState extends State<Flyover3DScreen>
    with SingleTickerProviderStateMixin {
  MapLibreMapController? _mapController;
  final List<ll.LatLng> _route = [];

  bool _isPlaying = false;
  bool _isStyleLoaded = false;

  late AnimationController _animationController;

  // Track the last drawn point index so we only add NEW segments each tick
  int _lastDrawnIndex = 0;

  // The moving "current position" dot symbol
  Symbol? _progressDot;

  static const String _mapTilerKey = 'KV6n4yl6DjwIdqdqA9NM';

  // Satellite (hybrid = satellite tiles + road/label overlay)
  static const String _styleUrl =
      'https://api.maptiler.com/maps/hybrid/style.json?key=$_mapTilerKey';

  // MapTiler terrain DEM source
  static const String _terrainUrl =
      'https://api.maptiler.com/tiles/terrain-rgb-v2/tiles.json?key=$_mapTilerKey';

  // ──────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _parseRoute();

    // Duration: ~30 s for a short route, scales with point count
    final durationSec = math.max(20, _route.length ~/ 3);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSec),
    );
    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
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

    try {
      // ── 1. Add terrain DEM source + enable 3D terrain ──────────────
      await ctrl.addSource(
        'terrain-dem',
        RasterDemSourceProperties(
          url: _terrainUrl,
          tileSize: 256,
        ),
      );
      await ctrl.setTerrain('terrain-dem', exaggeration: 1.5);
    } catch (e) {
      debugPrint('Flyover: terrain setup error (non-fatal): $e');
    }

    // ── 2. Draw full route as a dim ghost line ───────────────────────
    final fullGeom = _route
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    await ctrl.addLine(LineOptions(
      geometry: fullGeom,
      lineColor: '#FFFFFF',
      lineWidth: 2.5,
      lineOpacity: 0.25,
      lineCap: 'round',
      lineJoin: 'round',
    ));

    // ── 3. Start marker (green circle) ──────────────────────────────
    await ctrl.addSymbol(SymbolOptions(
      geometry: LatLng(_route.first.latitude, _route.first.longitude),
      textField: '▶',
      textColor: '#00E676',
      textSize: 20,
      textHaloColor: '#000000',
      textHaloWidth: 2.0,
      textAnchor: 'center',
    ));

    // ── 4. Finish marker (red square) ───────────────────────────────
    await ctrl.addSymbol(SymbolOptions(
      geometry: LatLng(_route.last.latitude, _route.last.longitude),
      textField: '⏹',
      textColor: '#FF1744',
      textSize: 20,
      textHaloColor: '#000000',
      textHaloWidth: 2.0,
      textAnchor: 'center',
    ));

    // ── 5. Animated "head" dot ──────────────────────────────────────
    _progressDot = await ctrl.addSymbol(SymbolOptions(
      geometry: LatLng(_route.first.latitude, _route.first.longitude),
      textField: '⬤',
      textColor: '#FFFFFF',
      textSize: 14,
      textHaloColor: '#FF5252',
      textHaloWidth: 4.0,
      textAnchor: 'center',
    ));

    // ── 6. Fit camera to the full route bounds (stationary, slight tilt) ──
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

    // Add a subtle tilt for the 3D feel after fitting bounds
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) {
      final currentPos = await ctrl.getCameraPosition();
      if (currentPos != null) {
        await ctrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPos.target,
              zoom: (currentPos.zoom ?? 13) - 0.3,
              tilt: 40.0,
              bearing: currentPos.bearing ?? 0,
            ),
          ),
          duration: const Duration(milliseconds: 800),
        );
      }
    }

    if (mounted) setState(() => _isStyleLoaded = true);
  }

  // ──────────────────────────────────────────────
  // Animation
  // ──────────────────────────────────────────────

  void _onAnimationTick() {
    final ctrl = _mapController;
    if (ctrl == null || _route.isEmpty || !_isStyleLoaded) return;

    final progress = _animationController.value;
    final targetIndex =
        (progress * (_route.length - 1)).floor().clamp(0, _route.length - 1);

    // Draw new segments from _lastDrawnIndex to targetIndex
    if (targetIndex > _lastDrawnIndex && _lastDrawnIndex < _route.length - 1) {
      // Batch multiple points into one line call to reduce MapLibre calls
      final batchEnd = math.min(targetIndex, _lastDrawnIndex + 8);
      final segPoints = _route
          .sublist(_lastDrawnIndex, batchEnd + 1)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      if (segPoints.length >= 2) {
        ctrl.addLine(LineOptions(
          geometry: segPoints,
          lineColor: '#FF5252',
          lineWidth: 5.0,
          lineOpacity: 1.0,
          lineCap: 'round',
          lineJoin: 'round',
        ));
      }
      _lastDrawnIndex = batchEnd;
    }

    // Move the progress dot to the current head position
    final dot = _progressDot;
    if (dot != null && targetIndex < _route.length) {
      ctrl.updateSymbol(
        dot,
        SymbolOptions(
          geometry: LatLng(
            _route[targetIndex].latitude,
            _route[targetIndex].longitude,
          ),
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Controls
  // ──────────────────────────────────────────────

  void _togglePlay() {
    if (!_isStyleLoaded) return;
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (_animationController.isCompleted) {
          _resetAnimation();
          return;
        }
        _animationController.forward();
      } else {
        _animationController.stop();
      }
    });
  }

  Future<void> _resetAnimation() async {
    final ctrl = _mapController;
    if (ctrl == null) return;

    _animationController.reset();
    _lastDrawnIndex = 0;

    // Clear all lines and re-draw ghost route
    await ctrl.clearLines();
    await ctrl.addLine(LineOptions(
      geometry: _route.map((p) => LatLng(p.latitude, p.longitude)).toList(),
      lineColor: '#FFFFFF',
      lineWidth: 2.5,
      lineOpacity: 0.25,
      lineCap: 'round',
      lineJoin: 'round',
    ));

    // Reset dot to start
    final dot = _progressDot;
    if (dot != null) {
      await ctrl.updateSymbol(
        dot,
        SymbolOptions(
          geometry: LatLng(_route.first.latitude, _route.first.longitude),
        ),
      );
    }

    if (mounted) {
      setState(() => _isPlaying = true);
      _animationController.forward();
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

  String _progressLabel() {
    if (_route.isEmpty) return '';
    final idx = (_animationController.value * (_route.length - 1))
        .floor()
        .clamp(0, _route.length - 1);
    final pct = ((_animationController.value) * 100).toStringAsFixed(0);
    return '$pct%  (${idx + 1}/${_route.length} pts)';
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          if (_isStyleLoaded)
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.white),
              tooltip: 'Replay from start',
              onPressed: _resetAnimation,
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────
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

          // ── Loading overlay ────────────────────────────────────────
          if (!_isStyleLoaded)
            Container(
              color: Colors.black70,
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
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Setting up 3D terrain',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // ── Progress bar ───────────────────────────────────────────
          if (_isStyleLoaded)
            Positioned(
              bottom: 108,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, __) => Text(
                      _progressLabel(),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _animationController.value,
                        backgroundColor: Colors.white24,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Play / Pause button ────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _isStyleLoaded ? _togglePlay : null,
                backgroundColor:
                    _isStyleLoaded ? AppColors.primary : Colors.grey.shade700,
                elevation: 8,
                icon: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                label: Text(
                  _isPlaying ? 'Pause' : 'Play Route',
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
