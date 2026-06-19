## Session 3 — Food Logger UI

**Goal**: Layar log makanan dengan search dummy, input manual, dan placeholder barcode scanner.

### 3.1 Dummy data makanan

Buat `lib/features/food/food_dummy.dart`:

```dart
class FoodItem {
  final String name;
  final int caloriesPer100g;
  final double protein;
  final double carbs;
  final double fat;
  const FoodItem({
    required this.name,
    required this.caloriesPer100g,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

final dummyFoodDb = [
  FoodItem(name: 'Nasi putih', caloriesPer100g: 130, protein: 2.7, carbs: 28.1, fat: 0.3),
  FoodItem(name: 'Ayam goreng', caloriesPer100g: 246, protein: 23.0, carbs: 7.8, fat: 13.6),
  FoodItem(name: 'Telur rebus', caloriesPer100g: 155, protein: 13.0, carbs: 1.1, fat: 11.0),
  FoodItem(name: 'Tempe goreng', caloriesPer100g: 220, protein: 14.0, carbs: 12.0, fat: 11.5),
  FoodItem(name: 'Pisang', caloriesPer100g: 89, protein: 1.1, carbs: 23.0, fat: 0.3),
  FoodItem(name: 'Roti gandum', caloriesPer100g: 247, protein: 9.0, carbs: 41.0, fat: 3.4),
  FoodItem(name: 'Susu full cream', caloriesPer100g: 61, protein: 3.2, carbs: 4.8, fat: 3.3),
  FoodItem(name: 'Oatmeal', caloriesPer100g: 389, protein: 17.0, carbs: 66.0, fat: 7.0),
];
```

### 3.2 `lib/features/food/food_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'food_dummy.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final _search = TextEditingController();
  List<FoodItem> _results = [];

  void _onSearch(String q) {
    setState(() {
      _results = q.isEmpty
        ? []
        : dummyFoodDb.where((f) => f.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _onSelect(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddFoodSheet(food: food),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Makanan', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _search,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari makanan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Barcode scanner — session 7')),
                      );
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.restaurant, size: 48, color: Color(0xFF9090A8)),
                          const SizedBox(height: 12),
                          Text('Ketik nama makanan atau scan barcode',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final food = _results[i];
                        return ListTile(
                          title: Text(food.name),
                          subtitle: Text('${food.caloriesPer100g} kcal / 100g'),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () => _onSelect(food),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddFoodSheet extends StatefulWidget {
  final FoodItem food;
  const _AddFoodSheet({required this.food});

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  double _grams = 100;

  int get _calories => (widget.food.caloriesPer100g * _grams / 100).round();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.food.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text('Porsi: ${_grams.round()} gram', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _grams,
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (v) => setState(() => _grams = v),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(label: 'Kalori', value: '$_calories kcal'),
              _MacroChip(label: 'Protein', value: '${(widget.food.protein * _grams / 100).toStringAsFixed(1)}g'),
              _MacroChip(label: 'Karbo', value: '${(widget.food.carbs * _grams / 100).toStringAsFixed(1)}g'),
              _MacroChip(label: 'Lemak', value: '${(widget.food.fat * _grams / 100).toStringAsFixed(1)}g'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.food.name} ditambahkan ($_calories kcal)')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tambah ke Log'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}
```

**Checkpoint session 3**: Bisa search makanan, pilih, atur porsi dengan slider, lihat kalori + makro real-time.

---