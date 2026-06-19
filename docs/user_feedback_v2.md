# User Feedback v2

## 1. Food Section Enhancements
- Di halaman food, untuk riwayat hari ini, data makro dan mikro nutrisinya (karbohidrat, protein, lemak, dll.) perlu divisualisasikan dalam bentuk grafik (misalnya pie chart).
- ✅ **Done (v1):** Ditambahkan pie chart makro nutrisi menggunakan fl_chart.
- ✅ **Done (v2 - Follow Up):** Style pie chart direvamp menjadi custom `CustomPaint` arc glow + gradient + animasi entry, mengikuti style `CalorieRing` di dashboard. Setiap segmen punya glow berwarna, center menampilkan info interaktif (tap untuk lihat gram & nama), legend menampilkan highlight animasi saat aktif.

## 2. Activity (Outdoor Run) - Background, Offline, & Bugs
- Pastikan pelacakan Outdoor Run bisa tetap berjalan di background.
- Perlu dipastikan dan didukung agar pelacakan tetap bisa jalan meskipun tanpa koneksi internet (offline).
- Ada isu pada pace saat awal dinyalakan (terlihat seperti error/tidak akurat), namun setelahnya normal.
- **Bug Kritis:** Ketika sedang melakukan activity (sudah di-start), lalu berpindah tab/halaman ke Food, dan kembali lagi ke Activity, state-nya keriset menjadi awal mula (seperti belum di-start). Ini perlu diperbaiki agar state tracking tetap persisten.
- ✅ **Done:** Semua poin di atas sudah dieksekusi via singleton `ActivityService` (ChangeNotifier), pace threshold 50m, dan `errorTileCallback` untuk offline fallback. Indikator LIVE ditambahkan di header.
- ✅ **Done (Follow Up):** Stats overlay (Duration, Distance, Pace, Calories) di Outdoor Run diubah dari label teks menjadi icon saja (timer, straighten, speed, local_fire_department) agar lebih compact dan visual.

## 3. Map History - Colored Polyline by Pace
- Pada Outdoor Run, jalur/polyline di peta perlu dibedakan warnanya berdasarkan pace (kecepatan).
- Jika pace lambat, warna jalurnya merah.
- Jika pace makin cepat, warnanya menjadi hijau (atau menyesuaikan gradient warna saat ini).
- Fitur ini berguna agar di map history nantinya pace pelari bisa langsung terlihat dari warna jalurnya.
- ✅ **Done (v1):** Colored polyline per-segmen sudah jalan. Hijau=cepat (<4 min/km), Kuning=sedang, Merah=lambat (>8 min/km). Pace per titik disimpan ke JSON routePoints.
- ✅ **Done (v2 - Follow Up):** Ditambahkan:
  - **Checkpoint markers di peta**: setiap 0.5 km ada pinpoint berupa bubble berwarna (warna = pace) yang menampilkan jarak dan pace saat itu.
  - **Pace History list** di bawah stats: bar chart horizontal per 0.5 km, warna bar = pace, ditampilkan jarak dan label pace di kiri-kanan.
  - **Marker Start (▶ hijau) dan Finish (■ merah)** di peta.
  - **Pace Legend overlay** di pojok kanan bawah peta.

## 4. Activity Type & Map Markers
- Sebelum klik "MULAI", tambahkan seleksi aktivitas (pop-up/bottom sheet) antara "Running" atau "Cycling".
- Tampilkan countdown 5 detik sebelum start sesudah memilih tipe aktivitas.
- Data dan tampilan harus berbeda antara running (pace) dan cycling (speed).
- Custom icon (marker) di map pas record dan pas detail:
  - Sepeda (Cycling): Mobil F1 (stylized Red Bull).
  - Lari (Running): Icon Sepatu (👟).
- ✅ **Done:** 
  - Pop-up selector bergaya 3D card (`Running` dan `Cycling`).
  - Animasi countdown overlay fullscreen 5 detik sebelum track.
  - Custom Painter untuk mobil Red Bull F1 (dark blue, red, yellow details).
  - Integrasi icon custom di current position marker (saat record) dan finish marker (saat detail activity) berdasarkan `activityType`.
