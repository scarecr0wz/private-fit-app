import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';

enum ActivityState { idle, running, paused }

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  ActivityState _state = ActivityState.idle;
  Timer? _timer;

  Duration _duration = Duration.zero;
  double _distanceKm = 0.0;
  int _calories = 0;
  String _pace = "0'00\"";

  final List<LatLng> _routePoints = [];
  LatLng _currentLocation = const LatLng(-6.200000, 106.816666);
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startActivity() {
    setState(() {
      _state = ActivityState.running;
      if (_routePoints.isEmpty) {
        _routePoints.add(_currentLocation);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
        _distanceKm += 0.002;
        _calories += 1;
        _pace = "5'30\"";

        _currentLocation = LatLng(
          _currentLocation.latitude + 0.00005,
          _currentLocation.longitude + 0.00005,
        );
        _routePoints.add(_currentLocation);
        _mapController.move(_currentLocation, _mapController.camera.zoom);
      });
    });
  }

  void _pauseActivity() {
    setState(() {
      _state = ActivityState.paused;
    });
    _timer?.cancel();
  }

  void _resumeActivity() {
    _startActivity();
  }

  void _stopActivity() {
    setState(() {
      _state = ActivityState.idle;
      _duration = Duration.zero;
      _distanceKm = 0.0;
      _calories = 0;
      _pace = "0'00\"";
      _routePoints.clear();
      _currentLocation = const LatLng(-6.200000, 106.816666);
      _mapController.move(_currentLocation, 16.0);
    });
    _timer?.cancel();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.fitapp',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.secondary,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
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
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.95),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _IconBtn3D(
                        icon: Icons.arrow_back,
                        onTap: () {
                          if (context.canPop()) context.pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Outdoor Run',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(
                                  color: Color(0x80C4C0FF),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IconBtn3D(icon: Icons.settings_suggest, onTap: () {}),
                      const SizedBox(width: 8),
                      _IconBtn3D(icon: Icons.my_location, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Stats Overlay
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: _GlassOverlay3D(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Duration',
                          value: _formatDuration(_duration),
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          label: 'Jarak',
                          value: '${_distanceKm.toStringAsFixed(2)} km',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          label: 'Pace',
                          value: _pace,
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          label: 'Kalori',
                          value: '$_calories kcal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Controls
                  SizedBox(
                    height: 64,
                    child: Center(
                      child: _buildActionControls(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildActionControls() {
    if (_state == ActivityState.idle) {
      return _Btn3DPrimary(
        text: 'MULAI',
        icon: Icons.play_arrow,
        width: 176,
        onTap: _startActivity,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleBtn3DSecondary(
          icon: _state == ActivityState.running ? Icons.pause : Icons.play_arrow,
          onTap: _state == ActivityState.running ? _pauseActivity : _resumeActivity,
        ),
        const SizedBox(width: 32),
        _CircleBtn3DError(
          icon: Icons.stop,
          onTap: _stopActivity,
        ),
        const SizedBox(width: 32),
        _CircleBtn3DSecondary(
          icon: Icons.camera_alt,
          onTap: () {},
        ),
      ],
    );
  }
}

class _IconBtn3D extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn3D({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.onSurface, size: 20),
          ),
        ),
      ),
    );
  }
}

class _GlassOverlay3D extends StatelessWidget {
  final Widget child;

  const _GlassOverlay3D({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
                AppColors.surfaceContainer.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 10),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: child,
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _Btn3DPrimary extends StatefulWidget {
  final String text;
  final IconData icon;
  final double width;
  final VoidCallback onTap;

  const _Btn3DPrimary({
    required this.text,
    required this.icon,
    required this.width,
    required this.onTap,
  });

  @override
  State<_Btn3DPrimary> createState() => _Btn3DPrimaryState();
}

class _Btn3DPrimaryState extends State<_Btn3DPrimary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: 56,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5EFBD6), AppColors.secondary, AppColors.secondaryContainer],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(color: Color(0xFF005142), offset: Offset(0, 2)),
                  BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), offset: const Offset(0, 5), blurRadius: 10),
                ]
              : [
                  const BoxShadow(color: Color(0xFF005142), offset: Offset(0, 4)),
                  BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), offset: const Offset(0, 10), blurRadius: 20),
                ],
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: AppColors.onSecondary, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSecondary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn3DSecondary extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn3DSecondary({required this.icon, required this.onTap});

  @override
  State<_CircleBtn3DSecondary> createState() => _CircleBtn3DSecondaryState();
}

class _CircleBtn3DSecondaryState extends State<_CircleBtn3DSecondary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 56,
        height: 56,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.surfaceVariant, AppColors.surfaceContainer],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: _pressed
              ? [const BoxShadow(color: AppColors.surfaceContainerLowest, offset: Offset(0, 2))]
              : [const BoxShadow(color: AppColors.surfaceContainerLowest, offset: Offset(0, 4))],
        ),
        child: Icon(widget.icon, color: AppColors.onSurface, size: 28),
      ),
    );
  }
}

class _CircleBtn3DError extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn3DError({required this.icon, required this.onTap});

  @override
  State<_CircleBtn3DError> createState() => _CircleBtn3DErrorState();
}

class _CircleBtn3DErrorState extends State<_CircleBtn3DError> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 64,
        height: 64,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB4AB), Color(0xFFEF5350)],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(color: AppColors.errorContainer, offset: Offset(0, 2)),
                  BoxShadow(color: const Color(0xFFEF5350).withValues(alpha: 0.2), offset: const Offset(0, 5), blurRadius: 10),
                ]
              : [
                  const BoxShadow(color: AppColors.errorContainer, offset: Offset(0, 4)),
                  BoxShadow(color: const Color(0xFFEF5350).withValues(alpha: 0.2), offset: const Offset(0, 10), blurRadius: 15),
                ],
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: Icon(widget.icon, color: AppColors.onError, size: 32),
      ),
    );
  }
}
