# 🔐 FitApp — Security Penetration Testing Report
**Date:** 2026-06-30  
**Scope:** fitapp-api (Node.js/Hono backend) + Flutter client  
**Status:** Read-Only Audit (No Changes Made)

---

## 🚨 Executive Summary

| Severity | Count |
|----------|-------|
| 🔴 Critical | 4 |
| 🟠 High | 4 |
| 🟡 Medium | 5 |
| 🔵 Low / Info | 4 |

---

## 🔴 CRITICAL

---

### [CRIT-01] Hardcoded Credentials in docker-compose.yml (Plaintext) — ✅ FIXED
**File:** [`docker-compose.yml` L10-L24](file:///C:/xampp/htdocs/fit-app/fitapp-api/docker-compose.yml#L10-L24)

```yaml
# SEBELUMNYA:
- DATABASE_URL=postgresql://postgres:Nasigoreng123%40@db:5432/fitapp?schema=public
- JWT_SECRET=Nasigoreng123@
...
POSTGRES_PASSWORD: Nasigoreng123@

# SEKARANG (FIXED):
- DATABASE_URL=${DATABASE_URL}
- JWT_SECRET=${JWT_SECRET}
...
POSTGRES_USER: ${POSTGRES_USER}
POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
POSTGRES_DB: ${POSTGRES_DB}
```

**Status Perbaikan:**
Semua kredensial hardcoded di `docker-compose.yml` telah diganti menggunakan variable substitution (`${VAR_NAME}`). File konfigurasi `.env` telah ditambahkan di level lokal server (dan sudah masuk `.gitignore`), serta disediakan file `.env.example` sebagai referensi aman untuk repositori git.

**Catatan Keamanan Penting:**
* Meskipun sudah aman dari kebocoran repositori, file `.env` di server lokal masih menggunakan password default `'Nasigoreng123@'`.
* **Rekomendasi:** Wajib mengganti password default ini dengan string acak berkekuatan tinggi (misalnya min. 16 karakter alfanumerik acak) sebelum server dideploy ke environment produksi.

---

### [CRIT-02] JWT_SECRET Fallback ke Weak Default Key — ✅ FIXED
**File:** [`src/lib/config.ts`](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/lib/config.ts)

```ts
if (!process.env.JWT_SECRET) {
  throw new Error('JWT_SECRET environment variable must be set before starting the server')
}

export const JWT_SECRET = process.env.JWT_SECRET
```

**Status Perbaikan:**
Dibuat file konfigurasi terpusat di `src/lib/config.ts` yang memvalidasi keberadaan `JWT_SECRET` pada saat *startup* aplikasi. Jika variabel lingkungan tersebut tidak dikonfigurasi, server akan langsung berhenti (*crash*) dengan pesan error yang jelas dan aman daripada menggunakan fallback *weak default key* yang berbahaya. Duplikasi pembacaan `process.env.JWT_SECRET` di routes dan middleware telah dihapus dan diganti dengan import dari file konfigurasi ini.

---

### [CRIT-03] .env File Berisi DB Password di VCS — ✅ FIXED
**File:** [`.htaccess`](file:///C:/xampp/htdocs/fit-app/.htaccess) dan [`fitapp-api/.htaccess`](file:///C:/xampp/htdocs/fit-app/fitapp-api/.htaccess)

```apache
# Prevent directory listing
Options -Indexes

# Block direct access to env files
<FilesMatch "^\.env.*$">
    Require all denied
</FilesMatch>

# Return 404 for git, environment, and docker configurations via Apache
RedirectMatch 404 /\.(git|gitignore|gitattributes|env|env\.example|env\.production)$
RedirectMatch 404 /(docker-compose\.yml|Dockerfile|package\.json|package-lock\.json|tsconfig\.json)$
```

**Status Perbaikan:**
Meskipun file `.env` sudah masuk `.gitignore`, lokasinya di dalam direktori `htdocs` (web root XAMPP) berisiko terekspos langsung via browser (HTTP). Kami telah menambahkan file `.htaccess` baik di root project maupun di subdirektori `fitapp-api/` untuk memblokir direktori listing (`Options -Indexes`), mengamankan akses ke seluruh file `.env` (`Require all denied`), serta melempar HTTP 404 jika ada request ke git config, docker files, package configurations, atau environment files.

---

### [CRIT-04] No Rate Limiting — Brute Force Attack Terbuka
**File:** [`routes/auth.ts` L51-L62](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/auth.ts#L51-L62)

```ts
authRoutes.post('/login', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')
  const user = await prisma.user.findUnique({ where: { email } })
  if (!user) return c.json({ error: 'Email atau password salah' }, 401)
  const valid = await bcrypt.compare(password, user.passwordHash)
  ...
```

**Problem:**  
Endpoint `/api/auth/login` **tidak memiliki rate limiting sama sekali**. Attacker bisa melakukan:
- **Brute force attack**: Mencoba ribuan kombinasi password tanpa hambatan
- **Credential stuffing**: Test bocoran password dari breach lain
- **DoS via bcrypt**: bcrypt `cost=10` butuh ~100ms per compare → 1000 request/detik bisa overwhelm CPU

**Attack Scenario:**
```bash
# Script attacker sederhana, tidak ada yang menghentikannya:
for password in $(cat rockyou.txt); do
  curl -X POST http://117.53.144.210:3000/api/auth/login \
    -d '{"email":"victim@email.com","password":"'$password'"}'
done
```

---

## 🟠 HIGH

---

### [HIGH-01] Verbose Debug Logging di Production — Data Leakage
**File:** [`src/index.ts` L18-L27](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/index.ts#L18-L27)  
**File:** [`middleware/auth.ts` L9, L19](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/middleware/auth.ts#L9-L19)

```ts
// index.ts
console.log(`[REALTIME DEBUG] Payload ${c.req.method} ${c.req.path}:`, JSON.stringify(body, null, 2))

// auth.ts
console.log('[REALTIME DEBUG] Auth ditolak: Header Authorization tidak valid atau kosong ->', header)
console.log('[REALTIME DEBUG] Auth ditolak: Token gagal diverifikasi ->', err)
```

**Problem:**  
Semua **payload request dicetak ke log server** termasuk email dan password saat login/register. Juga mencetak raw Authorization header. Ini berbahaya karena:
- **Password plaintext bisa muncul di log** jika ada bug sebelum hashing
- Server logs biasanya diakses oleh lebih banyak orang daripada codebase
- Jika ada log aggregator (CloudWatch, Datadog, dll), data sensitif tersebar ke lebih banyak sistem
- Attack surface untuk **log injection** jika input tidak di-sanitize

**File terdampak:**
- `routes/auth.ts` L26, L30, L34, L37, L40, L43 — semua log berisi email
- `sync_service.dart` L27, L29 — print ke flutter debug console

---

### [HIGH-02] CORS Wildcard — Semua Origin Diterima
**File:** [`src/index.ts` L15](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/index.ts#L15)

```ts
app.use('*', cors())
```

**Problem:**  
`cors()` tanpa konfigurasi = **`Access-Control-Allow-Origin: *`** (wildcard). Ini berarti:
- **Semua website** di internet bisa membuat request ke API ini dari browser user
- Bisa dieksploitasi untuk **CSRF-like attacks** dimana website jahat memancing user yang sudah login untuk mengirim request ke API
- Kredensial (cookie-based) tidak akan dikirim, tapi karena auth pakai Bearer token yang disimpan di SharedPreferences, ini masih berbahaya dalam skenario tertentu

---

### [HIGH-03] JWT Token Tidak Punya Expiry (No Expiration)
**File:** [`routes/auth.ts` L41, L60](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/auth.ts#L41)

```ts
const token = await sign({ sub: user.id, email: user.email }, JWT_SECRET)
// Tidak ada field 'exp' ataupun 'iat'!
```

**Problem:**  
JWT yang di-sign **tidak memiliki `exp` (expiration) claim**. Artinya:
- Token yang bocor (dicuri, di-leak, ditemukan di log) **berlaku selamanya**
- Tidak ada mekanisme untuk "memaksa logout" user yang sudah dikompromikan
- Jika JWT_SECRET pernah bocor dan kemudian diganti, token lama **tetap valid** karena tidak ada expiry

**Attack Scenario:** Jika seseorang mendapatkan JWT dari log/traffic sniffing, mereka bisa menggunakannya **months/years** kemudian.

---

### [HIGH-04] Server IP Address Hardcoded di Client Code
**File:** [`api_client.dart` L6](file:///C:/xampp/htdocs/fit-app/lib/data/api_client.dart#L6)

```dart
const baseUrl = 'http://117.53.144.210:3000';
```

**Problem:**  
- IP VPS **ter-expose secara publik** di source code (dan potentially di compiled binary APK)
- Komunikasi menggunakan **HTTP (bukan HTTPS)** — semua data termasuk JWT token dan data kesehatan dikirim dalam **plaintext** melalui jaringan
- Attacker di jaringan yang sama (coffee shop, WiFi publik) bisa melakukan **Man-in-the-Middle (MitM) attack** dan mencuri JWT token atau inject response palsu
- Tanpa certificate pinning, MITM attack sangat mudah dilakukan dengan tools seperti mitmproxy atau Burp Suite

---

## 🟡 MEDIUM

---

### [MED-01] No Input Sanitization untuk Date Query Parameter
**File:** [`routes/food.ts` L25-L35](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/food.ts#L25-L35)  
Juga di `workout.ts`, `activity.ts`, `dashboard.ts`

```ts
const dateStr = c.req.query('date')
const start = new Date(dateStr)   // ← Tidak ada validasi format!
start.setUTCHours(0, 0, 0, 0)
```

**Problem:**  
`dateStr` digunakan langsung di `new Date()` tanpa validasi. Jika input aneh seperti:
- `?date=Invalid Date` → `start = Invalid Date` → Prisma query bisa berperilaku tidak terduga
- `?date=<script>alert(1)</script>` → tidak langsung berbahaya di sini, tapi tidak ter-sanitize
- `?date=1 OR 1=1` → meskipun Prisma melindungi dari SQL injection, date parsing yang gagal bisa menyebabkan error 500 yang membocorkan stack trace

---

### [MED-02] calorieGoal Di-Hardcode — Logic Manipulation Possible
**File:** [`routes/dashboard.ts` L38](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/dashboard.ts#L38)

```ts
// Contoh hardcode calorieGoal. Nantinya bisa dari setting/tabel Profile user.
const calorieGoal = 2400
```

**Problem:**  
Ini bukan security vuln langsung, tapi menandakan adanya **incomplete business logic**. Jika nanti `calorieGoal` diambil dari user input tanpa validasi, ini bisa menjadi pintu untuk **business logic attack** (contoh: set calorie goal ke 0 atau nilai negatif untuk mengacaukan kalkulasi).

---

### [MED-03] Tidak Ada Account Enumeration Protection
**File:** [`routes/auth.ts` L28-L32](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/auth.ts#L28-L32)

```ts
const exists = await prisma.user.findUnique({ where: { email } })
if (exists) {
  return c.json({ error: 'Email sudah terdaftar' }, 400)  // ← Konfirmasi email exist!
}
```

**Problem:**  
Register endpoint **mengkonfirmasi apakah suatu email sudah terdaftar**. Login endpoint juga (`'Email atau password salah'` vs waktu respons yang berbeda). Attacker bisa meng-enumerate email yang valid di sistem dengan:
```bash
curl -X POST .../api/auth/register -d '{"email":"target@gmail.com","password":"test12345"}'
# Jika "Email sudah terdaftar" → email ini ada di database!
```
Ini memudahkan **targeted phishing** dan **credential stuffing**.

---

### [MED-04] Profile Data Disimpan di SharedPreferences Tanpa Enkripsi
**File:** [`profile_provider.dart` L62-L74](file:///C:/xampp/htdocs/fit-app/lib/features/profile/profile_provider.dart#L62-L74)  
**File:** [`auth_service.dart` L38-L39](file:///C:/xampp/htdocs/fit-app/lib/data/auth_service.dart#L38-L39)

```dart
await prefs.setString('jwt_token', token);  // JWT tersimpan plaintext!
await prefs.setString('profile_email', email);
await prefs.setDouble('profile_weight', weight);
// dll...
```

**Problem:**  
`SharedPreferences` di Android menyimpan data sebagai XML di `/data/data/[package]/shared_prefs/` yang:
- Pada device yang di-**root** (rooted), bisa dibaca langsung oleh aplikasi lain atau attacker
- Jika device di-backup (ADB backup), file SharedPreferences bisa di-extract
- **JWT token tersimpan plaintext** → jika device jatuh ke tangan salah, token bisa dicuri tanpa perlu password

---

### [MED-05] Tidak Ada Error Handling di Login Route
**File:** [`routes/auth.ts` L51-L62](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/routes/auth.ts#L51-L62)

```ts
authRoutes.post('/login', zValidator('json', registerSchema), async (c) => {
  const { email, password } = c.req.valid('json')
  const user = await prisma.user.findUnique({ where: { email } })
  // ← Tidak ada try/catch!
  ...
```

**Problem:**  
Route `/login` **tidak memiliki try/catch block** (berbeda dengan `/register` yang sudah ada). Jika terjadi database error:
- Server akan **crash/return 500** dengan stack trace yang berisi informasi sensitif (nama tabel, query structure, dll)
- Stack trace bisa membocorkan **internal architecture** ke attacker

---

## 🔵 LOW / INFO

---

### [INFO-01] HTTP bukan HTTPS — No TLS/SSL
**File:** [`api_client.dart` L6](file:///C:/xampp/htdocs/fit-app/lib/data/api_client.dart#L6)

```dart
const baseUrl = 'http://117.53.144.210:3000';
```

Sudah disebutkan di HIGH-04, tapi perlu ditekankan secara terpisah: **Seluruh komunikasi client-server tidak terenkripsi**. Data kesehatan (berat badan, kalori, rute GPS) dikirim plaintext.

---

### [INFO-02] No Request Size Limiting — DoS Potential
**File:** [`src/index.ts`](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/index.ts)

Tidak ada limit pada ukuran request body. Untuk route seperti `/api/activities` yang menerima `routePoints` sebagai string JSON panjang, attacker bisa mengirim payload sangat besar (beberapa MB) untuk:
- Exhausting memory server
- Memperlambat server (karena body dibaca dan di-parse)

---

### [INFO-03] PrismaClient Singleton Tanpa Connection Pooling Config
**File:** [`lib/db.ts`](file:///C:/xampp/htdocs/fit-app/fitapp-api/src/lib/db.ts)

```ts
export const prisma = new PrismaClient()
```

Tanpa konfigurasi `connectionLimit`, di bawah beban tinggi bisa terjadi connection pool exhaustion. Ini lebih ke availability/DoS concern daripada security langsung.

---

### [INFO-04] Dockerfile Menggunakan `npm install` bukan `npm ci`
**File:** [`Dockerfile` L9](file:///C:/xampp/htdocs/fit-app/fitapp-api/Dockerfile#L9)

```dockerfile
RUN npm install
```

`npm install` tidak menggunakan `package-lock.json` secara ketat, memungkinkan dependency yang di-resolve berbeda antar build (**supply chain attack surface**). Sebaiknya `npm ci` untuk reproducible builds.

---

## 📊 Attack Surface Summary

```
Internet
    │
    ▼
[Port 3000] ─── No HTTPS, No Rate Limit, CORS * ───► Hono API Server
                                                          │
                        ┌─────────────────────────────────┤
                        │                                 │
               /api/auth/login            /api/food-logs, /workout-logs,
               /api/auth/register         /api/activities, /api/dashboard
                   (PUBLIC)                   (JWT Protected ✓)
                   ↑ Brute Force                ↑ Token tanpa expiry
                   ↑ No Rate Limit              ↑ Hardcoded JWT secret
                   ↑ Account enum               ↑ Verbose debug logs
                        │
                        ▼
               PostgreSQL (port tidak terekspose langsung ✓)
               Password hardcoded di docker-compose ⚠️
```

---

## 🏆 Priority Fix Ranking

| Priority | Issue | Effort | Impact |
|----------|-------|--------|--------|
| 1 | Ganti semua hardcoded credentials di docker-compose.yml | Low | 🔴 Critical |
| 2 | Setup HTTPS (Let's Encrypt / Nginx reverse proxy) | Medium | 🔴 Critical |
| 3 | Tambahkan JWT expiry (`exp: Math.floor(Date.now()/1000) + 86400`) | Low | 🟠 High |
| 4 | Tambahkan rate limiting di `/api/auth/login` | Low | 🔴 Critical |
| 5 | Hapus semua verbose debug logging dari production | Low | 🟠 High |
| 6 | Restrict CORS ke domain spesifik | Low | 🟠 High |
| 7 | JWT_SECRET wajib di env, tidak ada fallback | Low | 🔴 Critical |
| 8 | Validasi format date parameter | Low | 🟡 Medium |
| 9 | Gunakan flutter_secure_storage untuk simpan JWT | Medium | 🟡 Medium |
| 10 | Tambah try/catch di login route | Low | 🟡 Medium |

---

> [!NOTE]
> Laporan ini adalah **read-only audit** — tidak ada perubahan yang dilakukan ke codebase. Semua temuan di atas bersifat observasional berdasarkan code review statis.
