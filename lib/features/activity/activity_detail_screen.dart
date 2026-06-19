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
    List<LatLng> routePoints = [];
    if (activity.routePoints != null && activity.routePoints!.isNotEmpty) {
      try {
        final decoded = jsonDecode(activity.routePoints!) as List;
        for (final p in decoded) {
          routePoints.add(LatLng(p['lat'], p['lng']));
        }
      } catch (e) {
        // ignore parsing error
      }
    }

    // Calculate pace
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
    final durationStr = "${durationMin.toString().padLeft(2, '0')}:${durationSec.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Detail Aktivitas'),
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
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: routePoints.isNotEmpty ? routePoints.first : const LatLng(0, 0),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  if (routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          color: AppColors.secondary,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  if (routePoints.isNotEmpty)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: routePoints.last,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                      _StatItem(label: 'WAKTU', value: durationStr),
                      _StatItem(label: 'PACE', value: paceStr),
                      _StatItem(label: 'KALORI', value: '${activity.caloriesBurned.toInt()}'),
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
}

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
