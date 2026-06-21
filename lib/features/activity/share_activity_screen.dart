import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:path_provider/path_provider.dart';
import '../../data/database.dart';
import '../../theme.dart';

class ShareActivityScreen extends StatefulWidget {
  final ActivityLog activity;
  final String imagePath;

  const ShareActivityScreen({
    super.key,
    required this.activity,
    required this.imagePath,
  });

  @override
  State<ShareActivityScreen> createState() => _ShareActivityScreenState();
}

class _ShareActivityScreenState extends State<ShareActivityScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isCapturing = false;

  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _parseRoute();
  }

  void _parseRoute() {
    if (widget.activity.routePoints.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.activity.routePoints) as List;
        for (final p in decoded) {
          _routePoints.add(LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()));
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace() {
    final distKm = widget.activity.distanceMeters / 1000;
    if (distKm <= 0) return "0'00\"";
    final paceMin = (widget.activity.durationSeconds / 60) / distKm;
    final m = paceMin.floor();
    final s = ((paceMin - m) * 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  Future<void> _captureAndShare() async {
    setState(() => _isCapturing = true);

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 3.0,
      );

      if (imageBytes != null) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/fitfad_share_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my activity on FitFad!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Share Activity'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 9 / 16, // Typical Instagram Story aspect ratio
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(widget.imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      // Dark gradient overlay to make text pop
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top left logo
                            Row(
                              children: [
                                const Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'FitFad',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Spacer(),
                            
                            // Route shape
                            if (_routePoints.length > 1)
                              SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: CustomPaint(
                                  painter: _RoutePainter(points: _routePoints),
                                ),
                              ),
                            
                            const SizedBox(height: 20),
                            
                            // Distance big text
                            Text(
                              (widget.activity.distanceMeters / 1000).toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              'Kilometers',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatColumn('Duration', _formatDuration(widget.activity.durationSeconds)),
                                _buildStatColumn('Pace', _formatPace()),
                                _buildStatColumn('Calories', '${widget.activity.caloriesBurned.toInt()}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _captureAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isCapturing 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.share),
                  label: Text(
                    _isCapturing ? 'Preparing...' : 'Share to Story',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<LatLng> points;

  _RoutePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Find bounding box
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = maxLat - minLat;
    final lngRange = maxLng - minLng;

    // To preserve aspect ratio of the route
    final path = Path();
    
    // Compute scale
    double scaleX = size.width / (lngRange == 0 ? 1 : lngRange);
    double scaleY = size.height / (latRange == 0 ? 1 : latRange);
    double scale = scaleX < scaleY ? scaleX : scaleY; // Use min scale to fit
    
    // Center offset
    double offsetX = (size.width - (lngRange * scale)) / 2;
    double offsetY = (size.height - (latRange * scale)) / 2;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      // Note: Map Y axis is inverted (latitude increases going UP, but screen Y increases going DOWN)
      final x = offsetX + (p.longitude - minLng) * scale;
      final y = offsetY + size.height - ((p.latitude - minLat) * scale); // Invert Y
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw shadow first
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // Draw main line
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return false;
  }
}
