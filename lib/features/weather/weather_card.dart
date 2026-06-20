import 'package:flutter/material.dart';
import '../weather/weather_service.dart';
import '../../theme.dart';

/// Glassmorphism weather card shown on the dashboard.
/// Fetches current weather from Open-Meteo and displays temperature,
/// humidity, wind speed, and exercise suitability.
class WeatherCard extends StatefulWidget {
  final Widget? greeting;
  const WeatherCard({super.key, this.greeting});

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
    final weatherContent = _loading
        ? const _LoadingState()
        : _error != null
            ? _ErrorState(message: _error!, onRetry: _load)
            : _WeatherContent(weather: _weather!, onRefresh: _load);

    if (widget.greeting != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: widget.greeting!),
              const SizedBox(width: 16),
              Flexible(child: weatherContent),
            ],
          ),
          if (!_loading && _error == null && _weather != null) ...[
            const SizedBox(height: 20),
            _WeatherDetails(weather: _weather!),
          ],
        ],
      );
    }

    return weatherContent;
  }
}

// ─── Loading State ────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Loading...',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Error',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.tertiary,
              ),
        ),
        IconButton(
          onPressed: onRetry,
          icon: Icon(
            Icons.refresh,
            color: AppColors.tertiary.withValues(alpha: 0.8),
            size: 16,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
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
    return GestureDetector(
      onTap: onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
              ),
              const SizedBox(width: 8),
              Text(weather.weatherEmoji, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${weather.cityName} • ${weather.weatherDescription}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.right,
          ),
          if (weather.forecastMessage != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                weather.forecastMessage!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Weather Details (Chips & Banner) ─────────────────────────────────────────

class _WeatherDetails extends StatelessWidget {
  final WeatherData weather;

  const _WeatherDetails({required this.weather});

  @override
  Widget build(BuildContext context) {
    final suit = weather.suitability;
    final (Color suitColor, Color suitBg) = switch (suit) {
      ExerciseSuitability.great => (
          AppColors.secondary,                              
          AppColors.secondary.withValues(alpha: 0.12),
        ),
      ExerciseSuitability.fair => (
          const Color(0xFFFFD166),                         
          const Color(0x18FFD166),
        ),
      ExerciseSuitability.poor => (
          AppColors.tertiary,                               
          AppColors.tertiary.withValues(alpha: 0.12),
        ),
    };

    return Column(
      children: [
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
                  weather.suitabilityMessage,
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
