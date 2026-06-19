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

class _Flyover3DScreenState extends State<Flyover3DScreen> with SingleTickerProviderStateMixin {
  MapLibreMapController? _mapController;
  final List<ll.LatLng> _route = [];
  bool _isPlaying = false;
  
  late AnimationController _animationController;
  
  static const String mapTilerKey = 'KV6n4yl6DjwIdqdqA9NM';
  static const String styleUrl = 'https://api.maptiler.com/maps/outdoor-v2/style.json?key=$mapTilerKey';

  @override
  void initState() {
    super.initState();
    _parseRoute();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: math.max(10, _route.length ~/ 2)), // Dynamic duration
    );
    _animationController.addListener(_onAnimationTick);
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _parseRoute() {
    if (widget.activity.routePoints.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.activity.routePoints) as List;
        for (final p in decoded) {
          _route.add(ll.LatLng(p['lat'], p['lng']));
        }
      } catch (_) {}
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() async {
    
    // Setup line layer
    await _mapController?.addSource("route-source", const GeojsonSourceProperties(
      data: {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": []
        }
      }
    ));
    
    await _mapController?.addLineLayer(
      "route-source",
      "route-layer",
      const LineLayerProperties(
        lineColor: "#FF5252", // AppColors.primary roughly
        lineWidth: 6.0,
        lineCap: "round",
        lineJoin: "round",
      ),
    );

    // Initial camera position
    if (_route.isNotEmpty) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_route.first.latitude, _route.first.longitude),
            zoom: 15.0,
            tilt: 60.0,
          )
        ),
      );
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

    final bearing = math.atan2(y, x) * 180.0 / math.pi;
    return (bearing + 360.0) % 360.0;
  }

  void _onAnimationTick() async {
    if (_mapController == null || _route.isEmpty) return;
    
    final progress = _animationController.value;
    final currentIndex = (progress * (_route.length - 1)).floor();
    
    // Draw line up to currentIndex
    final coordinates = _route.take(currentIndex + 1).map((p) => [p.longitude, p.latitude]).toList();
    
    await _mapController?.setGeoJsonSource("route-source", {
      "type": "Feature",
      "geometry": {
        "type": "LineString",
        "coordinates": coordinates
      }
    });

    // Update camera
    if (currentIndex < _route.length - 1) {
      final currentPoint = _route[currentIndex];
      final nextPoint = _route[currentIndex + 1];
      final bearing = _getBearing(currentPoint, nextPoint);
      
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPoint.latitude, currentPoint.longitude),
            zoom: 16.5,
            tilt: 65.0,
            bearing: bearing,
          )
        ),
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('3D Flyover', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _togglePlay,
                backgroundColor: AppColors.primary,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                label: Text(
                  _isPlaying ? 'Pause Flyover' : 'Start Flyover',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
