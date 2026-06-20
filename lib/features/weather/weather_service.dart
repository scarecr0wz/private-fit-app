import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

// ─── WMO Weather Code helpers ────────────────────────────────────────────────

class WmoWeather {
  static String emoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 2) return '🌤️';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️'; // fog/haze
    if (code <= 59) return '🌦️'; // drizzle
    if (code <= 69) return '🌧️'; // rain
    if (code <= 79) return '❄️'; // snow
    if (code <= 84) return '🌧️'; // rain showers
    if (code <= 87) return '🌨️'; // snow showers
    if (code <= 99) return '⛈️'; // thunderstorm
    return '🌡️';
  }

  static String description(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mostly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 84) return 'Rain Showers';
    if (code <= 87) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  /// True jika kondisi = hujan/badai/salju
  static bool isPrecipitation(int code) => code >= 51;

  static bool isThunderstorm(int code) => code >= 80;
}

// ─── Exercise Suitability ────────────────────────────────────────────────────

enum ExerciseSuitability { great, fair, poor }

extension ExerciseSuitabilityExt on ExerciseSuitability {
  String get label {
    switch (this) {
      case ExerciseSuitability.great:
        return 'Great for exercise! 💪';
      case ExerciseSuitability.fair:
        return 'Okay to exercise, be careful';
      case ExerciseSuitability.poor:
        return 'Not ideal for outdoor exercise';
    }
  }

  String get emoji {
    switch (this) {
      case ExerciseSuitability.great:
        return '💪';
      case ExerciseSuitability.fair:
        return '⚠️';
      case ExerciseSuitability.poor:
        return '🚫';
    }
  }

  String get reason {
    switch (this) {
      case ExerciseSuitability.great:
        return 'Clear weather, comfortable temperature & low humidity';
      case ExerciseSuitability.fair:
        return 'Conditions are acceptable but monitor weather closely';
      case ExerciseSuitability.poor:
        return 'Rain, extreme temperature, strong winds or high humidity';
    }
  }
}

// ─── Weather Data Model ───────────────────────────────────────────────────────

class WeatherData {
  final double temperature;      // °C
  final double apparentTemp;     // feels like °C
  final double humidity;         // %
  final double windSpeedKmh;     // km/h
  final double precipitation;    // mm
  final int weatherCode;         // WMO code
  final DateTime fetchedAt;

  WeatherData({
    required this.temperature,
    required this.apparentTemp,
    required this.humidity,
    required this.windSpeedKmh,
    required this.precipitation,
    required this.weatherCode,
    required this.fetchedAt,
  });

  String get weatherEmoji => WmoWeather.emoji(weatherCode);
  String get weatherDescription => WmoWeather.description(weatherCode);

  ExerciseSuitability get suitability {
    // Poor: thunderstorm, heavy rain, extreme heat (>35°C), extreme cold (<5°C),
    //        very strong wind (>50 km/h), or heavy precipitation (>5mm/h)
    if (WmoWeather.isThunderstorm(weatherCode)) return ExerciseSuitability.poor;
    if (temperature > 35 || temperature < 5) return ExerciseSuitability.poor;
    if (windSpeedKmh > 50) return ExerciseSuitability.poor;
    if (precipitation > 5) return ExerciseSuitability.poor;

    // Fair: rain/drizzle, warm (30-35°C), moderate wind (30-50 km/h),
    //        high humidity (>80%), or moderate precipitation (1-5mm/h)
    if (WmoWeather.isPrecipitation(weatherCode)) return ExerciseSuitability.fair;
    if (temperature > 30) return ExerciseSuitability.fair;
    if (windSpeedKmh > 30) return ExerciseSuitability.fair;
    if (humidity > 80) return ExerciseSuitability.fair;
    if (precipitation > 1) return ExerciseSuitability.fair;

    return ExerciseSuitability.great;
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemp: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      fetchedAt: DateTime.now(),
    );
  }
}

// ─── Weather Service ─────────────────────────────────────────────────────────

class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  WeatherData? _cached;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 15);

  bool get isCacheValid =>
      _cached != null &&
      _lastFetch != null &&
      DateTime.now().difference(_lastFetch!) < _cacheDuration;

  WeatherData? get cached => _cached;

  /// Fetch weather for the device's current GPS location.
  /// Returns cached data if fresh, or null on error.
  Future<WeatherData?> fetchCurrent() async {
    if (isCacheValid) return _cached;

    try {
      final pos = await _getCurrentPosition();
      if (pos == null) return _cached; // return stale if available

      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'current': [
            'temperature_2m',
            'apparent_temperature',
            'relative_humidity_2m',
            'wind_speed_10m',
            'weather_code',
            'precipitation',
          ].join(','),
          'wind_speed_unit': 'kmh',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );

      final data = WeatherData.fromJson(resp.data as Map<String, dynamic>);
      _cached = data;
      _lastFetch = DateTime.now();
      return data;
    } catch (e) {
      return _cached; // return stale data on error rather than crashing
    }
  }

  /// Fetch weather for a specific lat/lng (used when snapshotting at activity start).
  Future<WeatherData?> fetchForLocation(double lat, double lng) async {
    try {
      final resp = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': [
            'temperature_2m',
            'apparent_temperature',
            'relative_humidity_2m',
            'wind_speed_10m',
            'weather_code',
            'precipitation',
          ].join(','),
          'wind_speed_unit': 'kmh',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );
      return WeatherData.fromJson(resp.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // low = faster, battery-friendly
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void invalidateCache() {
    _lastFetch = null;
  }
}
