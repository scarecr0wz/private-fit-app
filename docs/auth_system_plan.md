# FitApp - Auth System & Database Sync Plan

## 🔍 Analisis Kondisi Saat Ini

1. **Sisi API (Node.js/Hono/Prisma)** 
   Sistem backend sudah **90% siap** untuk *multi-user*. Endpoint `/api/auth/login` dan `/api/auth/register` sudah ada dan menggunakan `bcrypt` serta JWT. Rute data seperti `/food-logs`, `/activities`, dan `/workout-logs` juga sudah diamankan dengan `authMiddleware` yang mem-filter `userId` dari token JWT.

2. **Sisi Flutter App**
   Saat ini aplikasi menggunakan sistem `silentLogin()` di `AuthService`. Artinya, saat aplikasi dibuka pertama kali tanpa UI apa pun, aplikasi akan mendaftarkan dan me-login-kan akun secara paksa (hardcode) sebagai `user@fitapp.com`.

3. **Database Sinkronisasi (Local vs Server)**
   SQLite (via Drift) tidak menyimpan `userId`. Hal ini sangat wajar untuk *local-first mobile app*. Namun, yang berbahaya adalah saat ini belum ada proses pembersihan (*wipe out*) tabel SQLite saat logout. Jika user A logout lalu user B login di device yang sama, user B bisa secara tidak sengaja melihat atau mengubah data lokal milik user A. 

---

## 📋 Action Plan: Sistem Auth & Sinkronisasi Database

Berikut adalah langkah-langkah implementasinya secara urut untuk mengaktifkan sistem User / Multi-Tenant yang *seamless*:

### Tahap 1: Persiapan Flutter Local Database (Drift)
Karena aplikasi menggunakan local-database (SQLite) dan akan digunakan oleh *real user*, kita harus memastikan privasi dan integritas data terjamin.
- **Tugas**: Membuat fungsi `clearAllData()` di dalam class `AppDatabase` (berada di `database.dart`). 
- **Tujuan**: Menghapus seluruh data (*truncate*) dari tabel `FoodLogs`, `WorkoutLogs`, `WorkoutSets`, `ActivityLogs`, dan `BodyWeights`. Ini adalah operasi wajib setiap kali pengguna melakukan **Logout**.

### Tahap 2: Rombak `AuthService` dan State Management (Flutter)
- **Tugas 1**: Hapus fungsi `silentLogin()` yang bersifat hardcode di `lib/data/auth_service.dart`.
- **Tugas 2**: Buat metode otentikasi sungguhan di `AuthService`:
  - `login(String email, String password)`
  - `register(String email, String password)`
  - `logout()`: Menjalankan penghapusan token dari `SharedPreferences` dan men-trigger fungsi `db.clearAllData()` dari Tahap 1.
- **Tugas 3**: Buat Riverpod Provider (misalnya `authStateProvider`) untuk memantau status login di seluruh siklus aplikasi.

### Tahap 3: Pembuatan UI/UX Login & Register (Flutter)
- **Tugas**: Membuat dua halaman baru: `LoginScreen` dan `RegisterScreen` di dalam folder `lib/features/auth/`.
- **Desain**: Tampilan akan dibuat mewah (*premium*) dengan sentuhan *glassmorphism*, gradient halus, serta micro-animations transisi agar sinkron dengan gaya visual fitur FitApp saat ini.

### Tahap 4: Konfigurasi Navigasi (GoRouter)
- **Tugas**: Menyesuaikan `lib/router.dart` dengan logika `redirect`. 
- **Tujuan**: `GoRouter` akan memblokir pengguna agar tidak bisa mengakses layar dashboard, gym, atau food log apabila tidak terdapat `jwt_token` yang valid di dalam *SharedPreferences*. Otomatis melempar pengguna kembali ke `/login`.

### Tahap 5: Perbaikan Siklus Sinkronisasi (Flutter & API)

**Saat pengguna Berhasil Login:**
1. Aplikasi menyimpan JWT token di `SharedPreferences`.
2. *Local Database* dibersihkan untuk berjaga-jaga (`db.clearAllData()`).
3. Sistem memanggil `syncServiceInstance.restoreFromVpsIfEmpty()`. Fungsi ini akan langsung merestore seluruh history data (olahraga, makanan, kalori) dari server VPS ke device lokal (berdasarkan `userId` dari token).

**Saat pengguna melakukan Logout:**
1. JWT Token dihapus dari `SharedPreferences`.
2. *Local Database* dibersihkan `db.clearAllData()` supaya data privasinya hilang sepenuhnya dari device.
3. Dialihkan kembali ke `LoginScreen`.

**Di Sisi API (Backend):**
Melakukan *crosscheck* dan memastikan setiap operasi `DELETE` atau `GET` pada module (seperti `food.ts`, `workout.ts`) selalu mem-validasi klausul `where: { id: resourceId, userId: c.get('userId') }` agar pengguna tidak bisa memodifikasi atau menghapus data milik orang lain.
