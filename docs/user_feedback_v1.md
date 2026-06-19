# Evaluasi dan Rencana Perbaikan (Smoke Test Feedback v1)

Dokumen ini berisi daftar temuan dari *Smoke Test* pengguna dan rencana aksi untuk mengeksekusinya satu per satu sebelum melangkah ke integrasi Backend (Session 9).

## ✅ 1. Dashboard - Calorie Ring (Cincin Kalori)
- **Status:** **DONE** (Sudah diperbaiki dengan `didUpdateWidget`).
- **Masalah:** Cincin (lingkaran) kalori tidak berputar/terisi untuk memenuhi kebutuhan harian.
- **Rencana Aksi:** Memperbaiki logika animasi dan rasio pada widget `CalorieRing` di `dashboard_screen.dart` agar nilai `consumed` dibagi dengan `goal` tervisualisasi dengan benar.

## ✅ 2. Dashboard - Tombol Aksi (Tambah & FAB)
- **Status:** **DONE** (Sudah disambungkan ke *router* Tab Food dan Activity).
- **Masalah:** Tombol teks "Tambah" pada bagian Makanan dan *Floating Action Button* (+) 3D di pojok kanan bawah belum memiliki fungsi.
- **Rencana Aksi:** Menyambungkan `onTap` pada tombol-tombol tersebut agar mengarahkan pengguna ke Tab *Food* atau membuka *Bottom Sheet* pencatatan cepat.

## ✅ 3. Food Screen - Detail Makro & Gambar Pencarian
- **Status:** **DONE** (Riwayat "Hari Ini" sudah diganti menggunakan StreamBuilder dari SQLite lengkap dengan makro P/C/F, dan pencarian API USDA/Barcode sudah dikonfigurasi untuk menampilkan URL gambar `image_front_url`).
- **Masalah:** Daftar makanan yang dimakan hari ini hanya menampilkan total kalori (kurang detail makro/mikro). Saat pencarian teks, gambar makanan belum muncul (meski sistem Barcode sudah sempurna).
- **Rencana Aksi:** 
  - Memperbarui UI daftar makanan di tab *Food* agar menampilkan Protein, Karbo, dan Lemak.
  - Memodifikasi *response* parser dari API USDA/OpenFoodFacts saat *search* agar mengambil URL gambar (thumbnail) dan menampilkannya di *list*.

## 4. Activity & Stats - Keakuratan & Detail History
- **Masalah:** Di *Activity*, akurasi perhitungan *pace* dan kalori perlu dikonfirmasi. Saat selesai dan masuk ke tab *Stats*, durasi (*timing*) dan kalori kurang menonjol. Selain itu, belum ada fitur klik untuk melihat detail aktivitas (seperti Peta/Rute).
- **Rencana Aksi:** 
  - Validasi formula jarak/waktu (Pace) dan Kalori (MET formula) di `activity_screen.dart`.
  - Memastikan *card* di tab *Stats* menampilkan parameter dengan jelas.
  - Membuat halaman baru `ActivityDetailScreen` (atau dialog) yang dipanggil ketika *card* di Stats diklik. Halaman ini akan membaca titik-titik koordinat dari database dan menggambar ulang rute lari di atas *FlutterMap*.

## 5. Stats Screen - Grafik Kalori & Berat Badan
- **Masalah:** Grafik balok "Kalori Terbakar" dan grafik garis "Tren Berat Badan" masih memakai data *dummy* statis.
- **Rencana Aksi:** 
  - Mengubah *BarChart* agar membaca agregasi data `caloriesBurned` 7 hari terakhir dari tabel `ActivityLogs` dan `WorkoutLogs`.
  - Mengubah *LineChart* agar membaca riwayat tabel `BodyWeights`.

## 6. Gym Screen
- **Status:** *Hold* / Tunda. Perbaikan fokus ke poin 1 sampai 5 terlebih dahulu.
