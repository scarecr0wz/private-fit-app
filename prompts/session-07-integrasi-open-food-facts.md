## Session 7 — Integrasi Open Food Facts

**Goal**: Barcode scanner nyambung ke Open Food Facts API yang real.

### 7.1 Tambah dependencies

```yaml
dependencies:
  mobile_scanner: ^4.0.0
  dio: ^5.4.0
```

### 7.2 Open Food Facts API

Endpoint: `https://world.openfoodfacts.org/api/v3/product/{barcode}.json`

Tidak perlu API key. Field yang dipakai:
```
product.product_name
product.nutriments.energy-kcal_100g
product.nutriments.proteins_100g
product.nutriments.carbohydrates_100g
product.nutriments.fat_100g
```

### 7.3 USDA FoodData API

Endpoint: `https://api.nal.usda.gov/fdc/v1/foods/search?query={q}&api_key=DEMO_KEY`

`DEMO_KEY` bisa dipakai untuk development (rate limited). Daftar gratis di https://fdc.nal.usda.gov/api-guide.html untuk limit lebih besar.

**Checkpoint session 7**: Scan barcode produk nyata → dapat data nutrisi.

---