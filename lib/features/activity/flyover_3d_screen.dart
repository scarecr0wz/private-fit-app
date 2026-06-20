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

  // Throttle camera/geojson updates so we don't flood MapLibre
  int _lastUpdatedIndex = -1;

  static const String mapTilerKey = 'KV6n4yl6DjwIdqdqA9NM';
  static const String styleUrl =
      'https://api.maptiler.com/maps/outdoor-v2/style.json?key=$mapTilerKey';

  @override
  void initState() {
    super.initState();
    _parseRoute();

    // Duration in seconds: min 15s, max based on route length
    final durationSec = math.max(15, _route.length ~/ 3);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSec),
    );

    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _isPlaying = false);
        }
      }
    });
  }

  void _parseRoute() {
    if (widget.activity.routePoints.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.activity.routePoints) as List;
        for (final p in decoded) {
          _route.add(ll.LatLng(p['lat'] as double, p['lng'] as double));
        }
      } catch (_) {}
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    if (_mapController == null) return;

    // Build the full route as GeoJSON coordinates
    final coords = _route
        .map((p) => [p.longitude, p.latitude])
        .toList();

    // Add GeoJSON source with the full route (we'll reveal it progressively)
    try {
      await _mapController!.addSource(
        'route-source',
        GeojsonSourceProperties(
          data: {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': coords.isNotEmpty ? [coords.first] : [],
            }
          },
        ),
      );

      await _mapController!.addLineLayer(
        'route-source',
        'route-layer',
        const LineLayerProperties(
          lineColor: '#FF5252',
          lineWidth: 6.0,
          lineCap: 'round',
          lineJoin: 'round',
        ),
      );
    } catch (e) {
      debugPrint('Flyover: addSource/addLayer error: $e');
    }

    // Fly camera to start of route
    if (_route.isNotEmpty) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_route.first.latitude, _route.first.longitude),
              zoom: 16.0,
              tilt: 60.0,
            ),
          ),
          duration: const Duration(milliseconds: 1500),
        );
      } catch (e) {
        debugPrint('Flyover: initial camera error: $e');
      }
    }

    if (mounted) {
      setState(() => _isStyleLoaded = true);
    }
  }

  double _getBearing(ll.LatLng start, ll.LatLng end) {
    final startLat = start.latitude * math.pi / 180.0;
    final startLng = start.longitude * math.pi / 180.0;
    final endLat = end.latitude * math.pi / 180.0;
    final endLng = end.longitude * math.pi / 180.0;

    final dLng = endLng - startLng;
    final y = math.sin(dLng) * math.cos(endLat);
    final x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    return (math.atan2(y, x) * 180.0 / math.pi + 360.0) % 360.0;
  }

  void _onAnimationTick() {
    if (_mapController == null || _route.isEmpty || !_isStyleLoaded) return;

    final progress = _animationController.value;
    final currentIndex = (progress * (_route.length - 1)).floor().clamp(0, _route.length - 1);

    // Throttle: only update when index actually changes
    if (currentIndex == _lastUpdatedIndex) return;
    _lastUpdatedIndex = currentIndex;

    // Update the drawn route line
    final coordinates = _route
        .take(currentIndex + 1)
        .map((p) => [p.longitude, p.latitude])
        .toList();

    _mapController!.setGeoJsonSource('route-source', {
      'type': 'Feature',
      'geometry': {
        'type': 'LineString',
        'coordinates': coordinates,
      }
    });

    // Move camera along the route
    if (currentIndex < _route.length - 1) {
      final currentPoint = _route[currentIndex];
      final nextPoint = _route[currentIndex + 1];
      final bearing = _getBearing(currentPoint, nextPoint);

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPoint.latitude, currentPoint.longitude),
            zoom: 16.5,
            tilt: 65.0,
            bearing: bearing,
          ),
        ),
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  void _togglePlay() {
    if (!_isStyleLoaded) return; // Don't allow play before map is ready

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _lastUpdatedIndex = -1;
        if (_animationController.isCompleted) {
          _animationController.reset();
        }
        _animationController.forward();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '3D Flyover',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black45,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: styleUrl,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            compassEnabled: false,
            myLocationEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
          ),

          // Loading overlay while style/source not ready
          if (!_isStyleLoaded)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading 3D map...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Play/Pause button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _isStyleLoaded ? _togglePlay : null,
                backgroundColor:
                    _isStyleLoaded ? AppColors.primary : Colors.grey,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: Text(
                  _isPlaying ? 'Pause Flyover' : 'Start Flyover',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
