import 'package:flutter/material.dart';
import '../weather/weather_service.dart';
import '../../theme.dart';

/// Glassmorphism weather card shown on the dashboard.
/// Fetches current weather from Open-Meteo and displays temperature,
/// humidity, wind speed, and exercise suitability.
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherData? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await WeatherService.instance.fetchCurrent();
      if (!mounted) return;
      setState(() {
        _weather = data;
        _loading = false;
        if (data == null) _error = 'Enable location to see weather';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load weather';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Match the glass-dark gradient used by _ActivityCard & _MealList
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xB3292839),
            Color(0xE61E1E2E),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _loading
          ? const _LoadingState()
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _WeatherContent(weather: _weather!, onRefresh: _load),
    );
  }
}

// ─── Loading State ────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Fetching weather...',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          const Text('🌡️', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary.withValues(alpha: 0.5),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Full Weather Content ─────────────────────────────────────────────────────

class _WeatherContent extends StatelessWidget {
  final WeatherData weather;
  final VoidCallback onRefresh;

  const _WeatherContent({required this.weather, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final suit = weather.suitability;

    // Suitability uses app palette colours instead of raw hex
    final (Color suitColor, Color suitBg) = switch (suit) {
      ExerciseSuitability.great => (
          AppColors.secondary,                              // aquamarine
          AppColors.secondary.withValues(alpha: 0.12),
        ),
      ExerciseSuitability.fair => (
          const Color(0xFFFFD166),                         // warm amber
          const Color(0x18FFD166),
        ),
      ExerciseSuitability.poor => (
          AppColors.tertiary,                               // punch pink
          AppColors.tertiary.withValues(alpha: 0.12),
        ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: emoji + temp + refresh ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(weather.weatherEmoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Feels like ${weather.apparentTemp.toStringAsFixed(1)}°C  •  ${weather.weatherDescription}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRefresh,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.refresh,
                    color: AppColors.primary.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Stats chips row ───────────────────────────────────────────
          Row(
            children: [
              _Chip(icon: '💧', label: '${weather.humidity.toInt()}%', sublabel: 'Humidity'),
              const SizedBox(width: 10),
              _Chip(
                  icon: '💨',
                  label: '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
                  sublabel: 'Wind'),
              const SizedBox(width: 10),
              _Chip(
                  icon: '🌧️',
                  label: '${weather.precipitation.toStringAsFixed(1)} mm',
                  sublabel: 'Rain'),
            ],
          ),

          const SizedBox(height: 14),

          // ── Suitability banner ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: suitBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: suitColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Text(suit.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suit.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: suitColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;

  const _Chip({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          // Subtle surface-container tint – same as icon container in _ActivityCard
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
