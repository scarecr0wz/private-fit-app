import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme.dart';
import '../../data/database.dart';
import 'activity_icons.dart';

// ─── Data model untuk checkpoint pace ────────────────────────────────────────

class _PaceCheckpoint {
  final LatLng point;
  final double paceMinPerKm;
  final double distanceKm;
  _PaceCheckpoint({
    required this.point,
    required this.paceMinPerKm,
    required this.distanceKm,
  });
}

// ─── Main Screen ──────────────────────────────────────────────────────────────

class ActivityDetailScreen extends StatelessWidget {
  final ActivityLog activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // ── Parse route points + pace ───────────────────────────────────────────
    List<LatLng> routePoints = [];
    List<double> paceValues = []; // min/km per titik, -1 = tidak diketahui
    double elevationGain = 0.0;
    double currentBaselineAlt = 0.0;
    
    // For Elevation Chart
    List<FlSpot> elevationSpots = [];
    double cumulativeDist = 0.0;
    double minAlt = double.infinity;
    double maxAlt = double.negativeInfinity;

    if (activity.routePoints.isNotEmpty) {
      try {
        final decoded = jsonDecode(activity.routePoints) as List;
        for (int i = 0; i < decoded.length; i++) {
          final p = decoded[i];
          final point = LatLng(p['lat'], p['lng']);
          routePoints.add(point);
          paceValues.add((p['pace'] ?? -1.0).toDouble());

          if (i > 0) {
            cumulativeDist += _distBetween(routePoints[i - 1], point);
          }

          if (p.containsKey('alt')) {
            final double alt = (p['alt'] as num).toDouble();
            elevationSpots.add(FlSpot(cumulativeDist, alt));
            if (alt < minAlt) minAlt = alt;
            if (alt > maxAlt) maxAlt = alt;

            if (i == 0) {
              currentBaselineAlt = alt;
            } else {
              final altDiff = alt - currentBaselineAlt;
              if (altDiff >= 2.0) {
                elevationGain += altDiff;
                currentBaselineAlt = alt;
              } else if (altDiff <= -2.0) {
                currentBaselineAlt = alt;
              }
            }
          }
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

    // ── Build pace checkpoints (setiap 0.5 km) ──────────────────────────────
    final checkpoints = _buildPaceCheckpoints(routePoints, paceValues);

    // ── Build pace history list untuk ditampilkan di bawah ──────────────────
    final paceHistory = _buildPaceHistory(routePoints, paceValues);

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
          // ── Map section ─────────────────────────────────────────────────
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
                      // Markers: start, finish, checkpoints
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
                              width: 48,
                              height: 48,
                              child: activity.type == 'bike'
                                  ? const RedBullF1Car(size: 48)
                                  : const RunningShoeIcon(size: 48),
                            ),
                            // Pace checkpoints
                            ...checkpoints.map((cp) => Marker(
                              point: cp.point,
                              width: 52,
                              height: 28,
                              child: _PaceMarker(checkpoint: cp),
                            )),
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

          // ── Stats + Pace History ─────────────────────────────────────────
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  // Distance headline
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
                  const SizedBox(height: 24),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _StatItem(label: 'DURATION', value: durationStr)),
                      Expanded(child: _StatItem(label: 'PACE', value: paceStr)),
                      Expanded(child: _StatItem(label: 'ELEV GAIN', value: '${elevationGain.toInt()}m')),
                      Expanded(
                        child: _StatItem(
                          label: 'CALORIES',
                          value: '${activity.caloriesBurned.toInt()}'),
                      ),
                    ],
                  ),

                  // Pace History List
                  if (paceHistory.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Icon(Icons.timeline,
                            color: AppColors.secondary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Pace History',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...paceHistory.map((entry) => _PaceHistoryRow(entry: entry)),
                  ],

                  // Elevation Profile Chart
                  if (elevationSpots.isNotEmpty && maxAlt > minAlt) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.terrain,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Elevation Profile',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: cumulativeDist,
                          minY: minAlt - (maxAlt - minAlt) * 0.2, // bottom pad
                          maxY: maxAlt + (maxAlt - minAlt) * 0.2, // top pad
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                    '${val.toInt()}m',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 9),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: elevationSpots,
                              isCurved: true,
                              curveSmoothness: 0.15,
                              color: AppColors.primary,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.5),
                                    AppColors.primary.withValues(alpha: 0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<Polyline> _buildColoredPolylines(
      List<LatLng> points, List<double> paceValues) {
    if (points.length < 2) return [];

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

  /// Checkpoint setiap 0.5 km
  List<_PaceCheckpoint> _buildPaceCheckpoints(
      List<LatLng> points, List<double> paceValues) {
    if (points.length < 2) return [];

    final List<_PaceCheckpoint> result = [];
    double cumDist = 0;
    double nextCheckpoint = 0.5;

    for (int i = 1; i < points.length; i++) {
      final segDist = _distBetween(points[i - 1], points[i]);
      cumDist += segDist;

      while (cumDist >= nextCheckpoint) {
        final pace = paceValues.length > i ? paceValues[i] : -1.0;
        if (pace > 0) {
          result.add(_PaceCheckpoint(
            point: points[i],
            paceMinPerKm: pace,
            distanceKm: nextCheckpoint,
          ));
        }
        nextCheckpoint += 0.5;
      }
    }
    return result;
  }

  /// Pace history: tiap 0.5km atau lebih
  List<_PaceHistoryEntry> _buildPaceHistory(
      List<LatLng> points, List<double> paceValues) {
    if (points.length < 2) return [];

    final List<_PaceHistoryEntry> result = [];
    double cumDist = 0;
    double nextCheckpoint = 0.5;

    // Accumulate paces for the current segment
    final List<double> segPaces = [];

    for (int i = 1; i < points.length; i++) {
      final segDist = _distBetween(points[i - 1], points[i]);
      cumDist += segDist;
      final pace = paceValues.length > i ? paceValues[i] : -1.0;
      if (pace > 0) segPaces.add(pace);

      while (cumDist >= nextCheckpoint && segPaces.isNotEmpty) {
        final avgPace = segPaces.reduce((a, b) => a + b) / segPaces.length;
        
        double? diff;
        if (result.isNotEmpty) {
          diff = avgPace - result.last.paceMinPerKm;
        }

        final paceMin = avgPace.floor();
        final paceSec = ((avgPace - paceMin) * 60).floor();
        result.add(_PaceHistoryEntry(
          distanceKm: nextCheckpoint,
          paceMinPerKm: avgPace,
          paceLabel: "$paceMin'${paceSec.toString().padLeft(2, '0')}\"",
          diffMinPerKm: diff,
        ));
        segPaces.clear();
        nextCheckpoint += 0.5;
      }
    }
    return result;
  }

  double _distBetween(LatLng a, LatLng b) {
    // Simplified — use Geolocator's formula approximation in km
    final dLat = (b.latitude - a.latitude) * (3.14159265 / 180);
    final dLon = (b.longitude - a.longitude) * (3.14159265 / 180);
    final sin2Lat = (dLat / 2) * (dLat / 2);
    final sin2Lon = (dLon / 2) * (dLon / 2);
    final cosLat =
        (a.latitude * 3.14159265 / 180).abs() < 1e-9 ? 1.0 : 1.0;
    final a2 = sin2Lat + cosLat * sin2Lon;
    return 6371 * 2 * (a2 < 1 ? a2 : 1); // approximate km
  }

  Color _paceToColor(double paceMinPerKm) {
    if (paceMinPerKm < 0) {
      return AppColors.secondary.withValues(alpha: 0.7);
    }
    final t = ((paceMinPerKm - 3.0) / (9.0 - 3.0)).clamp(0.0, 1.0);
    if (t < 0.5) {
      return Color.lerp(
        const Color(0xFF00E676),
        const Color(0xFFFFEB3B),
        t * 2,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFFFEB3B),
        const Color(0xFFEF5350),
        (t - 0.5) * 2,
      )!;
    }
  }
}

// ── Pace Checkpoint Marker ────────────────────────────────────────────────────

class _PaceMarker extends StatelessWidget {
  final _PaceCheckpoint checkpoint;

  const _PaceMarker({required this.checkpoint});

  @override
  Widget build(BuildContext context) {
    final paceMin = checkpoint.paceMinPerKm.floor();
    final paceSec = ((checkpoint.paceMinPerKm - paceMin) * 60).floor();
    final paceLabel = "$paceMin'${paceSec.toString().padLeft(2, '0')}\"";

    final color = _paceToColor(checkpoint.paceMinPerKm);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            '${checkpoint.distanceKm.toStringAsFixed(1)}k\n$paceLabel',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ),
        // Pin
        Container(
          width: 2,
          height: 6,
          color: color,
        ),
      ],
    );
  }

  Color _paceToColor(double paceMinPerKm) {
    if (paceMinPerKm < 0) return AppColors.secondary;
    final t = ((paceMinPerKm - 3.0) / (9.0 - 3.0)).clamp(0.0, 1.0);
    if (t < 0.5) {
      return Color.lerp(const Color(0xFF00E676), const Color(0xFFFFEB3B), t * 2)!;
    } else {
      return Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFEF5350), (t - 0.5) * 2)!;
    }
  }
}

// ── Pace History Row ──────────────────────────────────────────────────────────

class _PaceHistoryEntry {
  final double distanceKm;
  final double paceMinPerKm;
  final String paceLabel;
  final double? diffMinPerKm;

  _PaceHistoryEntry({
    required this.distanceKm,
    required this.paceMinPerKm,
    required this.paceLabel,
    this.diffMinPerKm,
  });
}

class _PaceHistoryRow extends StatelessWidget {
  final _PaceHistoryEntry entry;

  const _PaceHistoryRow({required this.entry});

  Color _paceToColor(double pace) {
    if (pace < 0) return AppColors.secondary;
    final t = ((pace - 3.0) / (9.0 - 3.0)).clamp(0.0, 1.0);
    if (t < 0.5) {
      return Color.lerp(const Color(0xFF00E676), const Color(0xFFFFEB3B), t * 2)!;
    } else {
      return Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFEF5350), (t - 0.5) * 2)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _paceToColor(entry.paceMinPerKm);
    // Bar width: normalized against 10 min/km max
    final barFraction = (1 - ((entry.paceMinPerKm - 3.0) / 7.0).clamp(0.0, 1.0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // KM label
          SizedBox(
            width: 44,
            child: Text(
              '${entry.distanceKm.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 8),

          // Bar
          Expanded(
            child: Stack(
              children: [
                // Background
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Filled bar
                FractionallySizedBox(
                  widthFactor: barFraction.clamp(0.05, 1.0),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.7), color],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Pace label
          SizedBox(
            width: 44,
            child: Text(
              entry.paceLabel,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),

          // Difference badge
          if (entry.diffMinPerKm != null) _buildDiffBadge(entry.diffMinPerKm!),
        ],
      ),
    );
  }

  Widget _buildDiffBadge(double diff) {
    if (diff.abs() < 0.016) return const SizedBox(width: 48); // Kosong jika beda kurang dari 1 detik
    
    final isFaster = diff < 0; 
    final diffSecs = (diff.abs() * 60).round();
    final diffMin = diffSecs ~/ 60;
    final diffSecRemainder = diffSecs % 60;
    
    String diffStr;
    if (diffMin > 0) {
      diffStr = "$diffMin'${diffSecRemainder.toString().padLeft(2, '0')}\"";
    } else {
      diffStr = "$diffSecRemainder\"";
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isFaster ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFaster ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down,
            size: 10,
            color: isFaster ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 2),
          Text(
            diffStr,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isFaster ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
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
          Container(
            width: 80,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00E676),
                  Color(0xFFFFEB3B),
                  Color(0xFFEF5350),
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
