import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme.dart';
import 'activity_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _svc = ActivityService.instance;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onServiceChanged);
    _initMap();
  }

  @override
  void dispose() {
    _svc.removeListener(_onServiceChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {});
    // Ikuti lokasi terbaru di peta saat tracking
    if (_svc.routePoints.isNotEmpty) {
      _mapController.move(_svc.routePoints.last, _mapController.camera.zoom);
    }
  }

  Future<void> _initMap() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 16.0);
      }
    } catch (_) {}
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  LatLng get _mapCenter =>
      _svc.routePoints.isNotEmpty ? _svc.routePoints.last : const LatLng(-6.200000, 106.816666);

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
              initialCenter: _mapCenter,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.fitapp',
                // Offline fallback: jika tile gagal dimuat, tidak crash
                errorTileCallback: (tile, error, stackTrace) {},
              ),
              if (_svc.routePoints.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _svc.routePoints,
                      color: AppColors.secondary,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              if (_svc.routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _svc.routePoints.last,
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

          // 2. Top Bar
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
                      // Indikator background running
                      if (_svc.state == ActivityState.running)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      _IconBtn3D(icon: Icons.my_location, onTap: () {
                        if (_svc.routePoints.isNotEmpty) {
                          _mapController.move(_svc.routePoints.last, 16.0);
                        }
                      }),
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
                          icon: Icons.timer_outlined,
                          value: _formatDuration(_svc.duration),
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.straighten_outlined,
                          value: '${_svc.distanceKm.toStringAsFixed(2)}km',
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.speed_outlined,
                          value: _svc.pace,
                        ),
                      ),
                      _buildDivider(),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.local_fire_department_outlined,
                          value: '${_svc.calories}',
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
    if (_svc.state == ActivityState.idle) {
      return _Btn3DPrimary(
        text: 'START',
        icon: Icons.play_arrow,
        width: 176,
        onTap: () => _svc.startActivity(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleBtn3DSecondary(
          icon: _svc.state == ActivityState.running ? Icons.pause : Icons.play_arrow,
          onTap: _svc.state == ActivityState.running
              ? () => _svc.pauseActivity()
              : () => _svc.resumeActivity(),
        ),
        const SizedBox(width: 32),
        _CircleBtn3DError(
          icon: Icons.stop,
          onTap: () => _svc.stopActivity(),
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
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          size: 16,
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
