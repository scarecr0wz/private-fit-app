## Session 12 — Flutter ↔ Hono Connect

**Goal**: Ganti semua dummy data dengan API call ke Hono backend.

### 12.1 Setup Dio client

```dart
// lib/data/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const baseUrl = 'http://YOUR_VPS_IP:3000'; // ganti dengan IP VPS

final dioProvider = Provider((ref) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // TODO: ambil token dari secure storage
      final token = 'TOKEN_DARI_LOGIN';
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ));
  return dio;
});
```

### 12.2 Riverpod provider async

```dart
// Contoh untuk dashboard
final dashboardProvider = FutureProvider.autoDispose((ref) async {
  final dio = ref.read(dioProvider);
  final date = DateTime.now().toIso8601String().split('T')[0];
  final res = await dio.get('/api/dashboard/summary', queryParameters: {'date': date});
  return DailySummary.fromJson(res.data);
});
```

### 12.3 Sync strategy

- Simpan ke SQLite dulu saat user input (optimistic update — UI langsung responsif)
- Sync ke Hono API di background
- Kalau offline, queue di SQLite dan retry saat online

**Checkpoint session 12**: App full stack jalan end-to-end.

---