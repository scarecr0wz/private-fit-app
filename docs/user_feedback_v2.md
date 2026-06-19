# User Feedback v2

## 1. Food Section Enhancements
- Di halaman food, untuk riwayat hari ini, data makro dan mikro nutrisinya (karbohidrat, protein, lemak, dll.) perlu divisualisasikan dalam bentuk grafik (misalnya pie chart).

## 2. Activity (Outdoor Run) - Background, Offline, & Bugs
- Pastikan pelacakan Outdoor Run bisa tetap berjalan di background.
- Perlu dipastikan dan didukung agar pelacakan tetap bisa jalan meskipun tanpa koneksi internet (offline).
- Ada isu pada pace saat awal dinyalakan (terlihat seperti error/tidak akurat), namun setelahnya normal.
- **Bug Kritis:** Ketika sedang melakukan activity (sudah di-start), lalu berpindah tab/halaman ke Food, dan kembali lagi ke Activity, state-nya keriset menjadi awal mula (seperti belum di-start). Ini perlu diperbaiki agar state tracking tetap persisten.

## 3. Map History - Colored Polyline by Pace
- Pada Outdoor Run, jalur/polyline di peta perlu dibedakan warnanya berdasarkan pace (kecepatan).
- Jika pace lambat, warna jalurnya merah.
- Jika pace makin cepat, warnanya menjadi hijau (atau menyesuaikan gradient warna saat ini).
- Fitur ini berguna agar di map history nantinya pace pelari bisa langsung terlihat dari warna jalurnya.
