import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

final authServiceProvider = Provider((ref) => AuthService(ref.read(dioProvider)));

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Menjalankan silent login (tanpa UI) saat aplikasi dibuka pertama kali
  Future<void> silentLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('jwt_token');

    // Jika sudah ada token, anggap sudah login
    if (currentToken != null) return;

    // Hardcoded credentials untuk aplikasi private ini
    const email = 'user@fitapp.com';
    const password = 'private_user_secret_123';

    try {
      // Coba login
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await prefs.setString('jwt_token', token);
      print("✅ Silent Login Berhasil");
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        // Jika gagal karena belum punya akun, otomatis register
        print("ℹ️ Belum ada akun, mencoba registrasi...");
        try {
          final regResponse = await _dio.post('/api/auth/register', data: {
            'email': email,
            'password': password,
          });
          final token = regResponse.data['token'];
          await prefs.setString('jwt_token', token);
          print("✅ Registrasi & Login Berhasil");
        } catch (regError) {
          print("❌ Registrasi gagal: $regError");
        }
      } else {
        print("❌ Silent Login gagal: $e");
      }
    }
  }
}
