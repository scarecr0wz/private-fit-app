## Session 13 — Polish & Bugfix

- Loading skeleton saat fetch data
- Error state + retry button
- Empty state yang proper (bukan layar kosong)
- Token expiry handling (auto logout)
- Deploy Hono ke VPS dengan `bun src/index.ts` di belakang nginx reverse proxy

---

## Catatan Penting

**Kalori burn GPS** — pakai formula MET sederhana, cukup akurat untuk personal use:
```
kalori = MET × berat_badan_kg × durasi_jam
// MET lari ~8.0, sepeda santai ~6.0, sepeda cepat ~10.0
```

**Peta** — `flutter_map` pakai tile OpenStreetMap gratis, tidak perlu billing. Bisa upgrade ke Mapbox free tier kalau mau tampilan lebih bagus.

**TDEE** — input manual dulu di settings (target kalori per hari). Bisa tambah kalkulator otomatis Harris-Benedict di session polish.

**Offline GPS tracking** — `geolocator` bisa jalan di background iOS, tapi perlu aktifkan `Background Modes → Location updates` di Xcode → Signing & Capabilities.

**Deploy Hono ke VPS**:
```bash
# Di VPS
bun src/index.ts &

# Nginx config (reverse proxy)
# location /api { proxy_pass http://localhost:3000; }
```