import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme.dart';
import '../../data/database.dart';

class ActivityDetailScreen extends StatelessWidget {
  final ActivityLog activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // ── Parse route points + pace ───────────────────────────────────────────
    List<LatLng> routePoints = [];
    List<double> paceValues = []; // min/km per titik, -1 = tidak diketahui

    if (activity.routePoints.isNotEmpty) {
      try {
        final decoded = jsonDecode(activity.routePoints) as List;
        for (final p in decoded) {
          routePoints.add(LatLng(p['lat'], p['lng']));
          paceValues.add((p['pace'] ?? -1.0).toDouble());
        }
      } catch (e) {
        // ignore parsing error
      }
    }

    // ── Overall pace ────────────────────────────────────────────────────────
    String paceStr = "0'00\"";
    final distanceKm = activity.distanceMeters / 1000;
    if (distanceKm > 0) {
      final minutes = activity.durationSeconds / 60.0;
      final paceValue = minutes / distanceKm;
      final paceMinutes = paceValue.floor();
      final paceSeconds = ((paceValue - paceMinutes) * 60).floor();
      paceStr = "$paceMinutes'${paceSeconds.toString().padLeft(2, '0')}\"";
    }

    final durationMin = activity.durationSeconds ~/ 60;
    final durationSec = activity.durationSeconds % 60;
    final durationStr =
        "${durationMin.toString().padLeft(2, '0')}:${durationSec.toString().padLeft(2, '0')}";

    // ── Build colored polylines by pace ─────────────────────────────────────
    final coloredPolylines = _buildColoredPolylines(routePoints, paceValues);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Activity Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: routePoints.isNotEmpty
                          ? routePoints.first
                          : const LatLng(0, 0),
                      initialZoom: 15.0,
                      interactionOptions:
                          const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        errorTileCallback: (tile, error, stackTrace) {},
                      ),
                      // Colored polylines per segmen pace
                      if (coloredPolylines.isNotEmpty)
                        PolylineLayer(polylines: coloredPolylines),
                      // Marker start
                      if (routePoints.isNotEmpty)
                        MarkerLayer(
                          markers: [
                            // Titik Start
                            Marker(
                              point: routePoints.first,
                              width: 28,
                              height: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5EFBD6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x995EFBD6),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.play_arrow,
                                      color: Colors.black, size: 14),
                                ),
                              ),
                            ),
                            // Titik Finish
                            Marker(
                              point: routePoints.last,
                              width: 28,
                              height: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF5350),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x99EF5350),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.stop,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Pace Legend overlay
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _PaceLegend(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    distanceKm.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                  Text(
                    'Kilometer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(label: 'DURATION', value: durationStr),
                      _StatItem(label: 'PACE', value: paceStr),
                      _StatItem(
                          label: 'CALORIES',
                          value: '${activity.caloriesBurned.toInt()}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Buat list Polyline berwarna berdasarkan pace tiap segmen.
  /// Slow (>7 min/km) = merah, Fast (<4 min/km) = hijau, tengah = gradient.
  List<Polyline> _buildColoredPolylines(
      List<LatLng> points, List<double> paceValues) {
    if (points.length < 2) {
      // Fallback: polyline tunggal warna default
      if (points.length == 2) {
        return [
          Polyline(
              points: points,
              color: AppColors.secondary,
              strokeWidth: 5.0)
        ];
      }
      return [];
    }

    final List<Polyline> polylines = [];

    for (int i = 0; i < points.length - 1; i++) {
      final segPoints = [points[i], points[i + 1]];
      final rawPace = paceValues.length > i + 1 ? paceValues[i + 1] : -1.0;
      final color = _paceToColor(rawPace);

      polylines.add(Polyline(
        points: segPoints,
        color: color,
        strokeWidth: 5.0,
        strokeCap: StrokeCap.round,
      ));
    }

    return polylines;
  }

  /// Merah (lambat ≥ 8 min/km) → Kuning (4-8 min/km) → Hijau (cepat ≤ 4 min/km)
  Color _paceToColor(double paceMinPerKm) {
    if (paceMinPerKm < 0) {
      // Tidak diketahui: warna netral
      return AppColors.secondary.withValues(alpha: 0.7);
    }

    // Clamp antara 3 (sangat cepat) dan 9 (sangat lambat)
    final t = ((paceMinPerKm - 3.0) / (9.0 - 3.0)).clamp(0.0, 1.0);

    // t=0 → hijau cepat, t=1 → merah lambat
    if (t < 0.5) {
      // Hijau → Kuning
      return Color.lerp(
        const Color(0xFF00E676), // hijau
        const Color(0xFFFFEB3B), // kuning
        t * 2,
      )!;
    } else {
      // Kuning → Merah
      return Color.lerp(
        const Color(0xFFFFEB3B), // kuning
        const Color(0xFFEF5350), // merah
        (t - 0.5) * 2,
      )!;
    }
  }
}

// ── Pace Legend Widget ────────────────────────────────────────────────────────

class _PaceLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PACE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 9,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Gradient bar
          Container(
            width: 80,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00E676), // hijau = cepat
                  Color(0xFFFFEB3B), // kuning = sedang
                  Color(0xFFEF5350), // merah = lambat
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fast', style: _legendTextStyle),
              Text('Slow', style: _legendTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const _legendTextStyle = TextStyle(
    color: Colors.white70,
    fontSize: 9,
    fontWeight: FontWeight.w500,
  );
}

// ── Stat Item ────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}
