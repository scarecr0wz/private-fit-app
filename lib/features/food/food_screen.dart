import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../../theme.dart';
import '../../data/database.dart';
import 'food_dummy.dart';
import 'package:drift/drift.dart' as drift;
import '../../widgets/profile_avatar.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final _searchController = TextEditingController();
  List<FoodItem> _results = [];
  bool _hasSearched = false;
  bool _isLoading = false;

  String _selectedFilter = 'Today';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  final List<String> _filters = ['Today', 'Yesterday', 'This Week', 'This Month', 'All Time', 'Custom'];

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    if (q.isEmpty) {
      setState(() {
        _hasSearched = false;
        _results = [];
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchOpenFoodFacts(q);
    });
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  String _errorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 429) {
        return 'Terlalu banyak permintaan. Harap tunggu beberapa saat lalu coba lagi.';
      }
      if (e.response?.statusCode != null) {
        return 'Server error (${e.response?.statusCode}). Silakan coba lagi.';
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Koneksi timeout. Periksa koneksi internet Anda.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }
      if (e.type == DioExceptionType.cancel) {
        return ''; // Jangan tampilkan error jika request dibatalkan sengaja
      }
    } else if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  CancelToken? _cancelToken;

  Future<void> _fetchOpenFoodFacts(String query) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results = [];
    });

    try {
      final dio = _createDio();
      final response = await dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        cancelToken: _cancelToken,
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page_size': 15,
        },
      );

      final List products = response.data['products'] ?? [];
      final List<FoodItem> parsedResults = [];

      for (var product in products) {
        final name = product['product_name'] ?? product['product_name_id'] ?? product['product_name_en'] ?? 'Unknown Product';
        if (name == 'Unknown Product' || name.toString().trim().isEmpty) continue;
        
        final nutriments = product['nutriments'] ?? {};
        final energy = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
        final proteins = (nutriments['proteins_100g'] ?? 0).toDouble();
        final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
        final fat = (nutriments['fat_100g'] ?? 0).toDouble();
        final imageUrl = product['image_front_small_url'] ?? product['image_front_url'];

        parsedResults.add(FoodItem(
          id: product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.toString(),
          caloriesPer100g: energy.toInt(),
          protein: proteins,
          carbs: carbs,
          fat: fat,
          imageUrl: imageUrl?.toString(),
        ));
      }

      if (mounted) {
        setState(() {
          _results = parsedResults;
        });
      }
    } catch (e) {
      _showError(_errorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSelect(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFoodSheet3D(food: food),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScannerSheet(),
    );

    if (barcode != null) {
      _fetchProduct(barcode);
    }
  }

  Future<void> _fetchProduct(String barcode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = _createDio();
      final response = await dio.get(
        'https://world.openfoodfacts.org/api/v3/product/$barcode.json',
      );
      if (response.data['status'] == 'success') {
        final product = response.data['product'];
        final nutriments = product['nutriments'] ?? {};
        
        final name = product['product_name'] ?? 'Unknown Product';
        final energy = (nutriments['energy-kcal_100g'] ?? 0).toDouble();
        final proteins = (nutriments['proteins_100g'] ?? 0).toDouble();
        final carbs = (nutriments['carbohydrates_100g'] ?? 0).toDouble();
        final fat = (nutriments['fat_100g'] ?? 0).toDouble();

        final foodItem = FoodItem(
          id: barcode,
          name: name,
          caloriesPer100g: energy.toInt(),
          protein: proteins,
          carbs: carbs,
          fat: fat,
          imageUrl: product['image_front_url'],
        );

        setState(() {
          _hasSearched = true;
          _results = [foodItem];
        });
      } else {
        _showError('Produk tidak ditemukan');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        _showError('Terlalu banyak permintaan. Harap tunggu beberapa saat lalu coba lagi.');
      } else {
        _showError('Produk tidak ditemukan');
      }
    } catch (e) {
      _showError('Produk tidak ditemukan');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted || message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Radial background gradient
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.9),
                  radius: 1.0,
                  colors: [Color(0xFF1E1E3E), AppColors.background],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _buildAppBar(context),
              _buildSearchBar(context),
              if (!_hasSearched) _buildCalendarView(context),
              if (!_hasSearched) _buildFilterDropdown(context),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      )
                    : _hasSearched && _results.isEmpty
                        ? _buildNoResults(context)
                        : !_hasSearched
                            ? _buildTodayHistory(context)
                            : _buildResultsList(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const ProfileAvatar(),
                const SizedBox(width: 10),
                Text(
                  'Food',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        shadows: const [
                          Shadow(
                              color: Color(0x80C4C0FF), blurRadius: 20),
                        ],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x00000000),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              spreadRadius: -2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search,
                  color: AppColors.onSurfaceVariant, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                decoration: InputDecoration(
                  hintText: 'Find your foods...',
                  hintStyle:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: _scanBarcode,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.barcode_reader,
                    color: AppColors.secondary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildDateSelector(),
          _buildQuickChip('This Week'),
          _buildQuickChip('This Month'),
          _buildQuickChip('All Time'),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    bool isDateSelected = ['Today', 'Yesterday', 'Custom'].contains(_selectedFilter);
    String displayLabel = 'Select Date';
    if (_selectedFilter == 'Today' || _selectedFilter == 'Yesterday') {
      displayLabel = _selectedFilter;
    } else if (_selectedFilter == 'Custom' && _customStartDate != null && _customEndDate != null) {
      displayLabel = '${_customStartDate!.day}/${_customStartDate!.month} - ${_customEndDate!.day}/${_customEndDate!.month}';
    } else if (isDateSelected) {
      displayLabel = _selectedFilter;
    }

    return GestureDetector(
      onTap: () => _showDateSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDateSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDateSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined, size: 16, color: isDateSelected ? AppColors.onPrimary : AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              displayLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDateSelected ? AppColors.onPrimary : AppColors.onSurface,
                    fontWeight: isDateSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: isDateSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return ActionChip(
      label: Text(filter),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
    );
  }

  void _showDateSheet(BuildContext context) {
    final options = ['Today', 'Yesterday', 'Custom'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
          ),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...options.map((filter) {
                final isSelected = _selectedFilter == filter;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(
                    filter == 'Today' ? Icons.today :
                    filter == 'Yesterday' ? Icons.update :
                    Icons.edit_calendar,
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                  title: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () async {
                    Navigator.pop(context); // Close the sheet
                    if (filter == 'Custom') {
                      final dateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary,
                                onPrimary: AppColors.onPrimary,
                                surface: AppColors.surfaceContainerHigh,
                                onSurface: AppColors.onSurface,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (dateRange != null) {
                        setState(() {
                          _customStartDate = dateRange.start;
                          _customEndDate = dateRange.end;
                          _selectedFilter = filter;
                        });
                      }
                    } else {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final daysInMonth = lastDayOfMonth.day;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset = math.max(0.0, (now.day - 1) * 60.0 - (screenWidth / 2) + 30.0);
    final ScrollController scrollController = ScrollController(initialScrollOffset: targetOffset);

    return StreamBuilder<List<FoodLog>>(
      stream: (db.select(db.foodLogs)
            ..where((t) => t.date.isBetweenValues(firstDayOfMonth, lastDayOfMonth)))
          .watch(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        final Map<int, double> dailyCalories = {};
        for (final log in logs) {
          final day = log.date.day;
          dailyCalories[day] = (dailyCalories[day] ?? 0) + log.calories;
        }

        const double calorieGoal = 2000.0; // Assumed daily target

        return Container(
          height: 90,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(now.year, now.month, day);
              final isToday = day == now.day;
              final isFuture = day > now.day;

              final cals = dailyCalories[day] ?? 0.0;
              double progress = cals / calorieGoal;
              if (progress > 1.0) progress = 1.0;

              Color ringColor = AppColors.secondary;
              if (progress == 0) {
                ringColor = Colors.transparent;
              } else if (progress < 0.5) {
                ringColor = AppColors.error;
              } else if (progress < 0.8) {
                ringColor = Colors.orange;
              }

              final weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              final dayName = weekDays[date.weekday - 1];

              return Container(
                width: 48,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: isToday ? AppColors.secondary : AppColors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: CustomPaint(
                        painter: _MiniRingPainter(
                          progress: progress,
                          color: ringColor,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isToday ? AppColors.secondary : (isFuture ? AppColors.onSurfaceVariant.withOpacity(0.3) : AppColors.onSurface),
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: isToday ? AppColors.secondary : Colors.transparent
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTodayHistory(BuildContext context) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_selectedFilter == 'Today') {
      start = DateTime(now.year, now.month, now.day);
    } else if (_selectedFilter == 'Yesterday') {
      start = DateTime(now.year, now.month, now.day - 1);
      end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
    } else if (_selectedFilter == 'This Week') {
      start = DateTime(now.year, now.month, now.day - now.weekday + 1);
    } else if (_selectedFilter == 'This Month') {
      start = DateTime(now.year, now.month, 1);
    } else if (_selectedFilter == 'All Time') {
      start = DateTime(2000);
    } else if (_selectedFilter == 'Custom') {
      start = _customStartDate ?? DateTime(now.year, now.month, now.day);
      end = _customEndDate != null
          ? DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59)
          : DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else {
      start = DateTime(now.year, now.month, now.day);
    }

    return StreamBuilder<List<FoodLog>>(
      stream: (db.select(db.foodLogs)
            ..where((t) => t.date.isBetweenValues(start, end))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)]))
          .watch(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _GlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.secondary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFilter == 'Today' ? 'Todays Tip' : 'No Data',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.secondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedFilter == 'Today' ? 'Record what you eat today!' : 'No food logs found for $_selectedFilter.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  child: const Icon(Icons.restaurant,
                      color: AppColors.secondary, size: 44),
                ),
                const SizedBox(height: 16),
                Text(
                  'Search for food or scan a barcode',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ),
          );
        }

        // Hitung total makro dari semua log hari ini
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        for (final log in logs) {
          totalCalories += log.calories;
          totalProtein += log.protein;
          totalCarbs += log.carbs;
          totalFat += log.fat;
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: logs.length + 2,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            if (i == 0) {
              // Pie chart card
              return _NutritionPieChart(
                title: _selectedFilter == 'Today' ? 'Nutrition Today' : 'Nutrition ($_selectedFilter)',
                totalCalories: totalCalories,
                totalProtein: totalProtein,
                totalCarbs: totalCarbs,
                totalFat: totalFat,
              );
            }
            if (i == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 4),
                child: Text(
                  _selectedFilter == 'Today' ? 'What You Ate Today' : 'What You Ate ($_selectedFilter)', 
                  style: Theme.of(context).textTheme.titleMedium
                ),
              );
            }
            final log = logs[i - 2];
            return _GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.foodName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('${log.calories.toInt()} kcal', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('P: ${log.protein.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('C: ${log.carbs.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('F: ${log.fat.toStringAsFixed(1)}g', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('${log.grams.toInt()}g', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off,
              size: 56, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Food not found',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Try different keywords',
              style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _FoodResultCard3D(
        food: _results[i],
        onTap: () => _onSelect(_results[i]),
      ),
    );
  }
}

// ── Reusable Glass Card ────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xB3292839), Color(0xE61E1E2E)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Nutrition Pie Chart (3D Glow Arc Style) ───────────────────────────────────

class _NutritionPieChart extends StatefulWidget {
  final String title;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const _NutritionPieChart({
    super.key,
    this.title = 'Nutrition Today',
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  @override
  State<_NutritionPieChart> createState() => _NutritionPieChartState();
}

class _NutritionPieChartState extends State<_NutritionPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  static const _proteinColor = Color(0xFF5EFBD6);
  static const _carbsColor   = Color(0xFFC4C0FF);
  static const _fatColor     = Color(0xFFFFB4AB);

  static const _proteinGlow  = Color(0xFF00C9A7);
  static const _carbsGlow    = Color(0xFF9B96FF);
  static const _fatGlow      = Color(0xFFFF7F6E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalProtein + widget.totalCarbs + widget.totalFat;
    final hasData = total > 0;

    final segments = [
      _ArcSegment(
        fraction: hasData ? widget.totalProtein / total : 0,
        color: _proteinColor,
        glowColor: _proteinGlow,
        label: 'P',
        index: 0,
      ),
      _ArcSegment(
        fraction: hasData ? widget.totalCarbs / total : 0,
        color: _carbsColor,
        glowColor: _carbsGlow,
        label: 'C',
        index: 1,
      ),
      _ArcSegment(
        fraction: hasData ? widget.totalFat / total : 0,
        color: _fatColor,
        glowColor: _fatGlow,
        label: 'F',
        index: 2,
      ),
    ];

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.secondary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.35), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '${widget.totalCalories.toInt()} kcal',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Color(0x805EFBD6), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart + Legend ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated glow arc chart
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return GestureDetector(
                    onTapDown: (details) {
                      // Hitung sektor mana yang di-tap
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(details.globalPosition);
                      const center = Offset(70, 70);
                      final angle = (math.atan2(
                            local.dy - center.dy,
                            local.dx - center.dx,
                          ) +
                          math.pi / 2 +
                          2 * math.pi) %
                          (2 * math.pi);

                      double cumAngle = 0;
                      for (int i = 0; i < segments.length; i++) {
                        cumAngle += segments[i].fraction * 2 * math.pi;
                        if (angle <= cumAngle) {
                          setState(() => _touchedIndex = _touchedIndex == i ? -1 : i);
                          return;
                        }
                      }
                    },
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _touchedIndex >= 0
                                ? segments[_touchedIndex].glowColor.withValues(alpha: 0.25)
                                : AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(140, 140),
                            painter: _NutritionArcPainter(
                              segments: segments,
                              progress: _animation.value,
                              touchedIndex: _touchedIndex,
                            ),
                          ),
                          // Center info
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_touchedIndex >= 0) ...
                                [
                                  Text(
                                    _touchedIndex == 0
                                        ? '${widget.totalProtein.toStringAsFixed(0)}g'
                                        : _touchedIndex == 1
                                            ? '${widget.totalCarbs.toStringAsFixed(0)}g'
                                            : '${widget.totalFat.toStringAsFixed(0)}g',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: segments[_touchedIndex].color,
                                      shadows: [
                                        Shadow(
                                          color: segments[_touchedIndex]
                                              .glowColor
                                              .withValues(alpha: 0.8),
                                          blurRadius: 14,
                                        )
                                      ],
                                    ),
                                  ),
                                  Text(
                                    segments[_touchedIndex].label == 'P'
                                        ? 'Protein'
                                        : segments[_touchedIndex].label == 'C'
                                            ? 'Karbo'
                                            : 'Lemak',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white54,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ]
                              else ...
                                [
                                  Text(
                                    hasData ? '${(total).toStringAsFixed(0)}g' : '--',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x60C4C0FF),
                                          blurRadius: 12,
                                        )
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    'total',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: _proteinColor,
                      glowColor: _proteinGlow,
                      label: 'Protein',
                      value: '${widget.totalProtein.toStringAsFixed(1)} g',
                      percent: hasData ? (widget.totalProtein / total * 100).round() : 0,
                      isActive: _touchedIndex == 0,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: _carbsColor,
                      glowColor: _carbsGlow,
                      label: 'Karbo',
                      value: '${widget.totalCarbs.toStringAsFixed(1)} g',
                      percent: hasData ? (widget.totalCarbs / total * 100).round() : 0,
                      isActive: _touchedIndex == 1,
                    ),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: _fatColor,
                      glowColor: _fatGlow,
                      label: 'Lemak',
                      value: '${widget.totalFat.toStringAsFixed(1)} g',
                      percent: hasData ? (widget.totalFat / total * 100).round() : 0,
                      isActive: _touchedIndex == 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk arc glow (mirip CalorieRing tapi multi-segment)
class _NutritionArcPainter extends CustomPainter {
  final List<_ArcSegment> segments;
  final double progress;
  final int touchedIndex;

  const _NutritionArcPainter({
    required this.segments,
    required this.progress,
    required this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 11.0;
    const gapAngle = 0.04; // gap antar segmen
    const startAngle = -math.pi / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2A)
      ..strokeWidth = strokeWidth + 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    double currentAngle = startAngle;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.fraction <= 0) continue;

      final totalForSeg = seg.fraction * 2 * math.pi * progress;
      final sweepAngle = (totalForSeg - gapAngle).clamp(0.0, double.infinity);
      if (sweepAngle <= 0) {
        currentAngle += totalForSeg;
        continue;
      }

      final rect = Rect.fromCircle(center: center, radius: radius);
      final isTouched = i == touchedIndex;
      final sw = isTouched ? strokeWidth + 4 : strokeWidth;

      // Glow layer
      final glowPaint = Paint()
        ..color = seg.glowColor.withValues(alpha: isTouched ? 0.55 : 0.30)
        ..strokeWidth = sw + 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(rect, currentAngle, sweepAngle, false, glowPaint);

      // Crisp colored arc
      final arcPaint = Paint()
        ..shader = LinearGradient(
          colors: [seg.color.withValues(alpha: 0.85), seg.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, currentAngle, sweepAngle, false, arcPaint);

      currentAngle += totalForSeg;
    }
  }

  @override
  bool shouldRepaint(_NutritionArcPainter old) =>
      old.progress != progress ||
      old.touchedIndex != touchedIndex ||
      old.segments != segments;
}

class _ArcSegment {
  final double fraction;
  final Color color;
  final Color glowColor;
  final String label;
  final int index;
  const _ArcSegment({
    required this.fraction,
    required this.color,
    required this.glowColor,
    required this.label,
    required this.index,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color glowColor;
  final String label;
  final String value;
  final int percent;
  final bool isActive;

  const _LegendItem({
    required this.color,
    required this.glowColor,
    required this.label,
    required this.value,
    required this.percent,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 10 : 8,
        vertical: isActive ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.35) : Colors.transparent,
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.20),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Dot with glow
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: isActive ? 0.7 : 0.3),
                  blurRadius: isActive ? 8 : 4,
                  spreadRadius: isActive ? 1 : 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? color : AppColors.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? color : AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              shadows: isActive
                  ? [Shadow(color: glowColor.withValues(alpha: 0.6), blurRadius: 6)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food Result Card 3D ───────────────────────────────────────────────────────

class _FoodResultCard3D extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodResultCard3D({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                image: food.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(food.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: food.imageUrl == null
                  ? const Icon(Icons.restaurant, color: AppColors.onSurfaceVariant, size: 22)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${food.caloriesPer100g} kcal / 100g',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.add,
                  color: AppColors.secondary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add Food Bottom Sheet 3D ──────────────────────────────────────────────────

class _AddFoodSheet3D extends StatefulWidget {
  final FoodItem food;
  const _AddFoodSheet3D({required this.food});

  @override
  State<_AddFoodSheet3D> createState() => _AddFoodSheet3DState();
}

class _AddFoodSheet3DState extends State<_AddFoodSheet3D> {
  double _grams = 100;

  int get _calories =>
      (widget.food.caloriesPer100g * _grams / 100).round();
  double get _protein => widget.food.protein * _grams / 100;
  double get _carbs => widget.food.carbs * _grams / 100;
  double get _fat => widget.food.fat * _grams / 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grabber
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.food.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.onSurface),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Gram display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PORSI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_grams.round()}',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'g',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider with 3D thumb via SliderTheme
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerLowest,
              thumbColor: AppColors.secondary,
              overlayColor:
                  AppColors.secondary.withValues(alpha: 0.12),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _grams,
              min: 10,
              max: 500,
              divisions: 49,
              onChanged: (v) => setState(() => _grams = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10g',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      )),
              Text('500g',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      )),
            ],
          ),
          const SizedBox(height: 24),

          // Macro chips 2x2 — 3D style
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.6,
            children: [
              _MacroChip3D(
                  label: 'Kalori',
                  value: '$_calories kcal',
                  color: AppColors.secondary),
              _MacroChip3D(
                  label: 'Protein',
                  value: '${_protein.toStringAsFixed(1)}g',
                  color: AppColors.tertiaryContainer),
              _MacroChip3D(
                  label: 'Karbo',
                  value: '${_carbs.toStringAsFixed(1)}g',
                  color: AppColors.primary),
              _MacroChip3D(
                  label: 'Lemak',
                  value: '${_fat.toStringAsFixed(1)}g',
                  color: AppColors.onSurface),
            ],
          ),
          const SizedBox(height: 24),

          // 3D CTA button
          _Btn3DPrimary(
            label: 'Tambah ke Log',
            onTap: () async {
              // Save to SQLite
              await db.into(db.foodLogs).insert(
                FoodLogsCompanion.insert(
                  date: DateTime.now(),
                  foodName: widget.food.name,
                  grams: _grams,
                  calories: _calories.toDouble(),
                  protein: (widget.food.protein * _grams / 100),
                  carbs: (widget.food.carbs * _grams / 100),
                  fat: (widget.food.fat * _grams / 100),
                ),
              );

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.food.name} disimpan ke Database ($_calories kcal)'),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── 3D Macro Chip ─────────────────────────────────────────────────────────────

class _MacroChip3D extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip3D({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF292839), Color(0xFF1E1E2E)],
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 8,
            offset: Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.03),
            blurRadius: 0,
            offset: const Offset(-1, -1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── 3D Primary Button ────────────────────────────────────────────────────────

class _Btn3DPrimary extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _Btn3DPrimary({required this.label, required this.onTap});

  @override
  State<_Btn3DPrimary> createState() => _Btn3DPrimaryState();
}

class _Btn3DPrimaryState extends State<_Btn3DPrimary> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Color(0xFF8781FF)],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Color(0xFF3622CA),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0xFF3622CA),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

// ── Scanner Sheet ─────────────────────────────────────────────────────────────

class _ScannerSheet extends StatefulWidget {
  const _ScannerSheet();

  @override
  State<_ScannerSheet> createState() => _ScannerSheetState();
}

class _ScannerSheetState extends State<_ScannerSheet> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Grabber
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan Barcode',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.onSurface),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  if (_isScanned) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final String? code = barcodes.first.rawValue;
                    if (code != null) {
                      _isScanned = true;
                      Navigator.pop(context, code);
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const strokeWidth = 3.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final arcPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) => old.progress != progress || old.color != color;
}
