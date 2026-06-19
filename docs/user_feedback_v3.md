# User Feedback v3

## 1. Map Activity Icons
- **Masukan**: Icon F1 custom painter dirasa "meh" dan kurang ngejreng.
- **Tindakan**: Mengganti icon sepeda menjadi emoji mobil balap (🏎️) yang beresolusi tinggi, tajam, dan vibran dari sistem operasi, menggantikan bentuk abstrak CustomPaint sebelumnya. Icon sepatu lari (👟) tetap dipertahankan karena sudah bagus.

## 2. Activity "START" Button
- **Masukan**: Tombol "MULAI" diminta diubah menjadi bahasa Inggris.
- **Tindakan**: Teks pada tombol utama di `ActivityScreen` telah diubah dari "MULAI" menjadi "START". Icon juga sedikit diubah menjadi `play_arrow_rounded` agar lebih halus.

## 3. Countdown Loading Bar
- **Masukan**: Saat countdown, hilangkan animasi loading circle (progress bar) di belakang angka.
- **Tindakan**: Elemen `CircularProgressIndicator` di-layer background countdown telah dihapus, menyisakan angka besar bercahaya (glow) agar UI lebih bersih.

## 4. Default Gram di Add Food
- **Masukan**: Swiper jumlah makanan harus otomatis menyesuaikan gramasi default (karena data nutrisi per 100g).
- **Tindakan**: Inisialisasi awal nilai `_grams` pada bottom sheet `_AddFoodSheet3D` diturunkan dari 200g menjadi 100g sehingga otomatis sesuai.

## 5. Activity Screen Metrics Proportions
- **Masukan**: Proporsi teks metrik Activity Screen (Duration, Distance, dsb.) sering wrap/turun baris dan terlihat tidak imbang. Minta jadikan 4-column rata, 1 baris, dengan font konsisten dan pembatas (divider).
- **Tindakan**:
  - `_StatItem` sekarang membungkus teks nilainya dengan `FittedBox(fit: BoxFit.scaleDown)` dan membatasi teks pada `maxLines: 1`. 
  - Seluruh layout metrik menggunakan `Expanded` di dalam `Row` yang diapit oleh vertikal `_buildDivider()`, memastikan proporsi lebar 1:1:1:1 di layar seukuran apapun tanpa teks patah.

## 6. Food Screen Nutrition Legend Wrapping
- **Masukan**: Label nama nutrisi (khususnya "Protein") terpotong jadi 2 baris ("Protei" dan "n"). Kolomnya harus dilebarkan atau dipaskan dan tidak ter-wrap (nowrap).
- **Tindakan**: Di widget `_LegendItem`, penggunaan widget `Expanded` pada teks label dihapus dan diganti dengan `Spacer()`. Hal ini memaksa label untuk menggunakan lebarnya sendiri sesuai panjang kata (mis. "Protein", "Karbo"), kemudian Spacer akan mendorong porsi data gram dan persentase merata ke kanan. Teks tidak akan pernah terpotong.
