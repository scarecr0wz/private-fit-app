import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../theme.dart';
import 'activity_service.dart';
import 'activity_icons.dart';

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

  // ── Activity Type Selector popup ────────────────────────────────────────
  void _showActivityTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ActivityTypePicker(
        onSelected: (type) async {
          Navigator.of(context).pop();

          // Check connectivity
          try {
            final connectivityResultList = await Connectivity().checkConnectivity();
            final isOffline = connectivityResultList.contains(ConnectivityResult.none);

            if (isOffline && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "You are offline, the map won't be loaded correctly but your route will still be recorded",
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (_) {}

          _svc.beginCountdown(type);
        },
      ),
    );
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
                      width: 48,
                      height: 48,
                      child: _svc.activityType == OutdoorActivityType.bike
                          ? const RedBullF1Car(size: 48)
                          : const RunningShoeIcon(size: 48),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _svc.state == ActivityState.idle
                                ? 'Outdoor'
                                : _svc.activityType.label,
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
                          if (_svc.state != ActivityState.idle)
                            Text(
                              _svc.activityType == OutdoorActivityType.run
                                  ? '🏃 Running'
                                  : '🚴 Cycling',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                        ],
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
                  // Stats Grid — icons dinamis berdasarkan tipe
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
                          // Pace (running) atau Speed (cycling)
                          icon: _svc.activityType == OutdoorActivityType.run
                              ? Icons.speed_outlined
                              : Icons.electric_bolt_outlined,
                          value: _svc.speedDisplay,
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

          // 4. Countdown overlay
          if (_svc.state == ActivityState.countdown)
            _CountdownOverlay(
              count: _svc.countdownValue,
              activityType: _svc.activityType,
              onCancel: () => _svc.cancelCountdown(),
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
    // Saat countdown: sembunyikan controls (overlay yang tampil)
    if (_svc.state == ActivityState.countdown) {
      return const SizedBox.shrink();
    }

    if (_svc.state == ActivityState.idle) {
      return _Btn3DPrimary(
        text: 'START',
        icon: Icons.play_arrow_rounded,
        width: 176,
        onTap: _showActivityTypeSelector,
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

// ── Activity Type Picker (Bottom Sheet) ──────────────────────────────────────

class _ActivityTypePicker extends StatelessWidget {
  final void Function(OutdoorActivityType) onSelected;

  const _ActivityTypePicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Pilih Aktivitas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Setelah memilih, akan ada countdown 5 detik',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white38,
                ),
          ),
          const SizedBox(height: 32),

          // Cards row
          Row(
            children: [
              Expanded(
                child: _ActivityTypeCard(
                  icon: '🏃',
                  label: 'Running',
                  subtitle: 'Pace • Jarak • Kalori',
                  color: AppColors.secondary,
                  glowColor: const Color(0xFF00C9A7),
                  onTap: () => onSelected(OutdoorActivityType.run),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActivityTypeCard(
                  icon: '🚴',
                  label: 'Cycling',
                  subtitle: 'Speed (km/h) • Jarak • Kalori',
                  color: AppColors.primary,
                  glowColor: const Color(0xFF9B96FF),
                  onTap: () => onSelected(OutdoorActivityType.bike),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTypeCard extends StatefulWidget {
  final String icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;

  const _ActivityTypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_ActivityTypeCard> createState() => _ActivityTypeCardState();
}

class _ActivityTypeCardState extends State<_ActivityTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.18),
                widget.color.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
                color: widget.color.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                        color: widget.glowColor.withValues(alpha: 0.6),
                        blurRadius: 8)
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Countdown Overlay ─────────────────────────────────────────────────────────

class _CountdownOverlay extends StatelessWidget {
  final int count;
  final OutdoorActivityType activityType;
  final VoidCallback onCancel;

  const _CountdownOverlay({
    required this.count,
    required this.activityType,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color = activityType == OutdoorActivityType.run
        ? AppColors.secondary
        : AppColors.primary;
    final glow = activityType == OutdoorActivityType.run
        ? const Color(0xFF00C9A7)
        : const Color(0xFF9B96FF);
    final progress = (5 - count) / 5.0; // 0.0 → 1.0

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated label
            Text(
              activityType == OutdoorActivityType.run ? '🏃 Running' : '🚴 Cycling',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),

            // Circle countdown
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // Countdown number
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      '$count',
                      key: ValueKey(count),
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: color,
                        shadows: [
                          Shadow(
                            color: glow.withValues(alpha: 0.8),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Bersiap...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 40),

            // Cancel button
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Text(
                  'BATAL',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
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


