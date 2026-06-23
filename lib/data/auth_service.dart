import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'database.dart';
import 'sync_service.dart';
import '../features/profile/profile_provider.dart';

// Menyimpan status login: true = logged in, false = logged out
final authStateProvider = StateProvider<bool>((ref) => false);

final authServiceProvider = Provider((ref) => AuthService(ref.read(dioProvider), ref));

class AuthService {
  final Dio _dio;
  final Ref _ref;

  AuthService(this._dio, this._ref);

  /// Cek apakah user sudah login (punya token)
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final isLoggedIn = token != null;
    _ref.read(authStateProvider.notifier).state = isLoggedIn;
    return isLoggedIn;
  }

  /// Login dengan email dan password
  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      
      // Bersihkan data lokal sisa user sebelumnya (jika ada)
      await db.clearAllData();
      
      _ref.read(authStateProvider.notifier).state = true;
      
      // Sinkronkan email ke profil
      _ref.read(profileProvider.notifier).updateProfile(email: email);
      
      // Langsung sinkronisasikan data user ini dari VPS
      await _ref.read(syncServiceProvider).restoreFromVpsIfEmpty();
      
      print("✅ Login Berhasil & Data Tersinkronisasi");
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Terjadi kesalahan saat login';
      throw Exception(message);
    }
  }

  /// Register akun baru
  Future<void> register(String email, String password, String name) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      
      // Bersihkan data lokal sisa user sebelumnya (jika ada)
      await db.clearAllData();
      
      _ref.read(authStateProvider.notifier).state = true;
      
      // Sinkronkan email dan nama ke profil
      _ref.read(profileProvider.notifier).updateProfile(email: email, name: name);
      
      print("✅ Registrasi & Login Berhasil");
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Terjadi kesalahan saat register';
      throw Exception(message);
    }
  }

  /// Logout: Hapus token dan bersihkan data lokal
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    
    // Hapus semua data di SQLite untuk alasan privasi
    await db.clearAllData();
    
    _ref.read(authStateProvider.notifier).state = false;
    print("✅ Logout Berhasil & Database Lokal Dibersihkan");
  }
}
