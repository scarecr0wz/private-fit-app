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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A3E), Color(0xFF0D1B2A)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Fetching weather...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
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
          const Text('🌡️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.white38, size: 20),
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
    final (suitColor, suitBg) = switch (suit) {
      ExerciseSuitability.great => (
          const Color(0xFF00E676),
          const Color(0x1500E676),
        ),
      ExerciseSuitability.fair => (
          const Color(0xFFFFB300),
          const Color(0x15FFB300),
        ),
      ExerciseSuitability.poor => (
          const Color(0xFFFF5252),
          const Color(0x15FF5252),
        ),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: emoji + temp + refresh ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(weather.weatherEmoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Feels like ${weather.apparentTemp.toStringAsFixed(1)}°C  •  ${weather.weatherDescription}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
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
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Stats chips row ─────────────────────────────────────────
          Row(
            children: [
              _Chip(icon: '💧', label: '${weather.humidity.toInt()}%', sublabel: 'Humidity'),
              const SizedBox(width: 10),
              _Chip(icon: '💨', label: '${weather.windSpeedKmh.toStringAsFixed(1)} km/h', sublabel: 'Wind'),
              const SizedBox(width: 10),
              _Chip(icon: '🌧️', label: '${weather.precipitation.toStringAsFixed(1)} mm', sublabel: 'Rain'),
            ],
          ),

          const SizedBox(height: 14),

          // ── Suitability banner ──────────────────────────────────────
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
                Text(suit.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suit.label,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 13,
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
