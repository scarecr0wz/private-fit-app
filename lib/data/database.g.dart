// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoodLogsTable extends FoodLogs with TableInfo<$FoodLogsTable, FoodLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    foodName,
    grams,
    calories,
    protein,
    carbs,
    fat,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
    );
  }

  @override
  $FoodLogsTable createAlias(String alias) {
    return $FoodLogsTable(attachedDatabase, alias);
  }
}

class FoodLog extends DataClass implements Insertable<FoodLog> {
  final int id;
  final DateTime date;
  final String foodName;
  final double grams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  const FoodLog({
    required this.id,
    required this.date,
    required this.foodName,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['food_name'] = Variable<String>(foodName);
    map['grams'] = Variable<double>(grams);
    map['calories'] = Variable<double>(calories);
    map['protein'] = Variable<double>(protein);
    map['carbs'] = Variable<double>(carbs);
    map['fat'] = Variable<double>(fat);
    return map;
  }

  FoodLogsCompanion toCompanion(bool nullToAbsent) {
    return FoodLogsCompanion(
      id: Value(id),
      date: Value(date),
      foodName: Value(foodName),
      grams: Value(grams),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
    );
  }

  factory FoodLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      foodName: serializer.fromJson<String>(json['foodName']),
      grams: serializer.fromJson<double>(json['grams']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double>(json['protein']),
      carbs: serializer.fromJson<double>(json['carbs']),
      fat: serializer.fromJson<double>(json['fat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'foodName': serializer.toJson<String>(foodName),
      'grams': serializer.toJson<double>(grams),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double>(protein),
      'carbs': serializer.toJson<double>(carbs),
      'fat': serializer.toJson<double>(fat),
    };
  }

  FoodLog copyWith({
    int? id,
    DateTime? date,
    String? foodName,
    double? grams,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) => FoodLog(
    id: id ?? this.id,
    date: date ?? this.date,
    foodName: foodName ?? this.foodName,
    grams: grams ?? this.grams,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
  );
  FoodLog copyWithCompanion(FoodLogsCompanion data) {
    return FoodLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      grams: data.grams.present ? data.grams.value : this.grams,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('foodName: $foodName, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, foodName, grams, calories, protein, carbs, fat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.foodName == this.foodName &&
          other.grams == this.grams &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat);
}

class FoodLogsCompanion extends UpdateCompanion<FoodLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> foodName;
  final Value<double> grams;
  final Value<double> calories;
  final Value<double> protein;
  final Value<double> carbs;
  final Value<double> fat;
  const FoodLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.foodName = const Value.absent(),
    this.grams = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
  });
  FoodLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String foodName,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) : date = Value(date),
       foodName = Value(foodName),
       grams = Value(grams),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat);
  static Insertable<FoodLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? foodName,
    Expression<double>? grams,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? fat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (foodName != null) 'food_name': foodName,
      if (grams != null) 'grams': grams,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    });
  }

  FoodLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? foodName,
    Value<double>? grams,
    Value<double>? calories,
    Value<double>? protein,
    Value<double>? carbs,
    Value<double>? fat,
  }) {
    return FoodLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      foodName: foodName ?? this.foodName,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('foodName: $foodName, ')
          ..write('grams: $grams, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat')
          ..write(')'))
        .toString();
  }
}

class $WorkoutLogsTable extends WorkoutLogs
    with TableInfo<$WorkoutLogsTable, WorkoutLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateNameMeta = const VerificationMeta(
    'templateName',
  );
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
    'template_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalVolumeKgMeta = const VerificationMeta(
    'totalVolumeKg',
  );
  @override
  late final GeneratedColumn<double> totalVolumeKg = GeneratedColumn<double>(
    'total_volume_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
    'calories_burned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    templateName,
    durationMinutes,
    totalVolumeKg,
    caloriesBurned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('template_name')) {
      context.handle(
        _templateNameMeta,
        templateName.isAcceptableOrUnknown(
          data['template_name']!,
          _templateNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateNameMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('total_volume_kg')) {
      context.handle(
        _totalVolumeKgMeta,
        totalVolumeKg.isAcceptableOrUnknown(
          data['total_volume_kg']!,
          _totalVolumeKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalVolumeKgMeta);
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      templateName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_name'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      totalVolumeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_volume_kg'],
      )!,
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_burned'],
      )!,
    );
  }

  @override
  $WorkoutLogsTable createAlias(String alias) {
    return $WorkoutLogsTable(attachedDatabase, alias);
  }
}

class WorkoutLog extends DataClass implements Insertable<WorkoutLog> {
  final int id;
  final DateTime date;
  final String templateName;
  final int durationMinutes;
  final double totalVolumeKg;
  final double caloriesBurned;
  const WorkoutLog({
    required this.id,
    required this.date,
    required this.templateName,
    required this.durationMinutes,
    required this.totalVolumeKg,
    required this.caloriesBurned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['template_name'] = Variable<String>(templateName);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['total_volume_kg'] = Variable<double>(totalVolumeKg);
    map['calories_burned'] = Variable<double>(caloriesBurned);
    return map;
  }

  WorkoutLogsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutLogsCompanion(
      id: Value(id),
      date: Value(date),
      templateName: Value(templateName),
      durationMinutes: Value(durationMinutes),
      totalVolumeKg: Value(totalVolumeKg),
      caloriesBurned: Value(caloriesBurned),
    );
  }

  factory WorkoutLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      templateName: serializer.fromJson<String>(json['templateName']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      totalVolumeKg: serializer.fromJson<double>(json['totalVolumeKg']),
      caloriesBurned: serializer.fromJson<double>(json['caloriesBurned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'templateName': serializer.toJson<String>(templateName),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'totalVolumeKg': serializer.toJson<double>(totalVolumeKg),
      'caloriesBurned': serializer.toJson<double>(caloriesBurned),
    };
  }

  WorkoutLog copyWith({
    int? id,
    DateTime? date,
    String? templateName,
    int? durationMinutes,
    double? totalVolumeKg,
    double? caloriesBurned,
  }) => WorkoutLog(
    id: id ?? this.id,
    date: date ?? this.date,
    templateName: templateName ?? this.templateName,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
  );
  WorkoutLog copyWithCompanion(WorkoutLogsCompanion data) {
    return WorkoutLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      totalVolumeKg: data.totalVolumeKg.present
          ? data.totalVolumeKg.value
          : this.totalVolumeKg,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateName: $templateName, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalVolumeKg: $totalVolumeKg, ')
          ..write('caloriesBurned: $caloriesBurned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    templateName,
    durationMinutes,
    totalVolumeKg,
    caloriesBurned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.templateName == this.templateName &&
          other.durationMinutes == this.durationMinutes &&
          other.totalVolumeKg == this.totalVolumeKg &&
          other.caloriesBurned == this.caloriesBurned);
}

class WorkoutLogsCompanion extends UpdateCompanion<WorkoutLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> templateName;
  final Value<int> durationMinutes;
  final Value<double> totalVolumeKg;
  final Value<double> caloriesBurned;
  const WorkoutLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.templateName = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.totalVolumeKg = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
  });
  WorkoutLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String templateName,
    required int durationMinutes,
    required double totalVolumeKg,
    this.caloriesBurned = const Value.absent(),
  }) : date = Value(date),
       templateName = Value(templateName),
       durationMinutes = Value(durationMinutes),
       totalVolumeKg = Value(totalVolumeKg);
  static Insertable<WorkoutLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? templateName,
    Expression<int>? durationMinutes,
    Expression<double>? totalVolumeKg,
    Expression<double>? caloriesBurned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (templateName != null) 'template_name': templateName,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (totalVolumeKg != null) 'total_volume_kg': totalVolumeKg,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
    });
  }

  WorkoutLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? templateName,
    Value<int>? durationMinutes,
    Value<double>? totalVolumeKg,
    Value<double>? caloriesBurned,
  }) {
    return WorkoutLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      templateName: templateName ?? this.templateName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (totalVolumeKg.present) {
      map['total_volume_kg'] = Variable<double>(totalVolumeKg.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateName: $templateName, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalVolumeKg: $totalVolumeKg, ')
          ..write('caloriesBurned: $caloriesBurned')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _workoutLogIdMeta = const VerificationMeta(
    'workoutLogId',
  );
  @override
  late final GeneratedColumn<int> workoutLogId = GeneratedColumn<int>(
    'workout_log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workoutLogId,
    exerciseName,
    reps,
    weightKg,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_log_id')) {
      context.handle(
        _workoutLogIdMeta,
        workoutLogId.isAcceptableOrUnknown(
          data['workout_log_id']!,
          _workoutLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutLogIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workoutLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workout_log_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int workoutLogId;
  final String exerciseName;
  final int reps;
  final double weightKg;
  const WorkoutSet({
    required this.id,
    required this.workoutLogId,
    required this.exerciseName,
    required this.reps,
    required this.weightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_log_id'] = Variable<int>(workoutLogId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['reps'] = Variable<int>(reps);
    map['weight_kg'] = Variable<double>(weightKg);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      workoutLogId: Value(workoutLogId),
      exerciseName: Value(exerciseName),
      reps: Value(reps),
      weightKg: Value(weightKg),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      workoutLogId: serializer.fromJson<int>(json['workoutLogId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      reps: serializer.fromJson<int>(json['reps']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutLogId': serializer.toJson<int>(workoutLogId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'reps': serializer.toJson<int>(reps),
      'weightKg': serializer.toJson<double>(weightKg),
    };
  }

  WorkoutSet copyWith({
    int? id,
    int? workoutLogId,
    String? exerciseName,
    int? reps,
    double? weightKg,
  }) => WorkoutSet(
    id: id ?? this.id,
    workoutLogId: workoutLogId ?? this.workoutLogId,
    exerciseName: exerciseName ?? this.exerciseName,
    reps: reps ?? this.reps,
    weightKg: weightKg ?? this.weightKg,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      workoutLogId: data.workoutLogId.present
          ? data.workoutLogId.value
          : this.workoutLogId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      reps: data.reps.present ? data.reps.value : this.reps,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('workoutLogId: $workoutLogId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, workoutLogId, exerciseName, reps, weightKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.workoutLogId == this.workoutLogId &&
          other.exerciseName == this.exerciseName &&
          other.reps == this.reps &&
          other.weightKg == this.weightKg);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> workoutLogId;
  final Value<String> exerciseName;
  final Value<int> reps;
  final Value<double> weightKg;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.workoutLogId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.reps = const Value.absent(),
    this.weightKg = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int workoutLogId,
    required String exerciseName,
    required int reps,
    required double weightKg,
  }) : workoutLogId = Value(workoutLogId),
       exerciseName = Value(exerciseName),
       reps = Value(reps),
       weightKg = Value(weightKg);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? workoutLogId,
    Expression<String>? exerciseName,
    Expression<int>? reps,
    Expression<double>? weightKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutLogId != null) 'workout_log_id': workoutLogId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (reps != null) 'reps': reps,
      if (weightKg != null) 'weight_kg': weightKg,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? workoutLogId,
    Value<String>? exerciseName,
    Value<int>? reps,
    Value<double>? weightKg,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      workoutLogId: workoutLogId ?? this.workoutLogId,
      exerciseName: exerciseName ?? this.exerciseName,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutLogId.present) {
      map['workout_log_id'] = Variable<int>(workoutLogId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('workoutLogId: $workoutLogId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogsTable extends ActivityLogs
    with TableInfo<$ActivityLogsTable, ActivityLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
    'calories_burned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routePointsMeta = const VerificationMeta(
    'routePoints',
  );
  @override
  late final GeneratedColumn<String> routePoints = GeneratedColumn<String>(
    'route_points',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherTempMeta = const VerificationMeta(
    'weatherTemp',
  );
  @override
  late final GeneratedColumn<double> weatherTemp = GeneratedColumn<double>(
    'weather_temp',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherHumidityMeta = const VerificationMeta(
    'weatherHumidity',
  );
  @override
  late final GeneratedColumn<double> weatherHumidity = GeneratedColumn<double>(
    'weather_humidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherWindKmhMeta = const VerificationMeta(
    'weatherWindKmh',
  );
  @override
  late final GeneratedColumn<double> weatherWindKmh = GeneratedColumn<double>(
    'weather_wind_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weatherCodeMeta = const VerificationMeta(
    'weatherCode',
  );
  @override
  late final GeneratedColumn<int> weatherCode = GeneratedColumn<int>(
    'weather_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    type,
    durationSeconds,
    distanceMeters,
    caloriesBurned,
    routePoints,
    weatherTemp,
    weatherHumidity,
    weatherWindKmh,
    weatherCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesBurnedMeta);
    }
    if (data.containsKey('route_points')) {
      context.handle(
        _routePointsMeta,
        routePoints.isAcceptableOrUnknown(
          data['route_points']!,
          _routePointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routePointsMeta);
    }
    if (data.containsKey('weather_temp')) {
      context.handle(
        _weatherTempMeta,
        weatherTemp.isAcceptableOrUnknown(
          data['weather_temp']!,
          _weatherTempMeta,
        ),
      );
    }
    if (data.containsKey('weather_humidity')) {
      context.handle(
        _weatherHumidityMeta,
        weatherHumidity.isAcceptableOrUnknown(
          data['weather_humidity']!,
          _weatherHumidityMeta,
        ),
      );
    }
    if (data.containsKey('weather_wind_kmh')) {
      context.handle(
        _weatherWindKmhMeta,
        weatherWindKmh.isAcceptableOrUnknown(
          data['weather_wind_kmh']!,
          _weatherWindKmhMeta,
        ),
      );
    }
    if (data.containsKey('weather_code')) {
      context.handle(
        _weatherCodeMeta,
        weatherCode.isAcceptableOrUnknown(
          data['weather_code']!,
          _weatherCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_burned'],
      )!,
      routePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_points'],
      )!,
      weatherTemp: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_temp'],
      ),
      weatherHumidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_humidity'],
      ),
      weatherWindKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weather_wind_kmh'],
      ),
      weatherCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weather_code'],
      ),
    );
  }

  @override
  $ActivityLogsTable createAlias(String alias) {
    return $ActivityLogsTable(attachedDatabase, alias);
  }
}

class ActivityLog extends DataClass implements Insertable<ActivityLog> {
  final int id;
  final DateTime date;
  final String type;
  final int durationSeconds;
  final double distanceMeters;
  final double caloriesBurned;
  final String routePoints;
  final double? weatherTemp;
  final double? weatherHumidity;
  final double? weatherWindKmh;
  final int? weatherCode;
  const ActivityLog({
    required this.id,
    required this.date,
    required this.type,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.caloriesBurned,
    required this.routePoints,
    this.weatherTemp,
    this.weatherHumidity,
    this.weatherWindKmh,
    this.weatherCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['calories_burned'] = Variable<double>(caloriesBurned);
    map['route_points'] = Variable<String>(routePoints);
    if (!nullToAbsent || weatherTemp != null) {
      map['weather_temp'] = Variable<double>(weatherTemp);
    }
    if (!nullToAbsent || weatherHumidity != null) {
      map['weather_humidity'] = Variable<double>(weatherHumidity);
    }
    if (!nullToAbsent || weatherWindKmh != null) {
      map['weather_wind_kmh'] = Variable<double>(weatherWindKmh);
    }
    if (!nullToAbsent || weatherCode != null) {
      map['weather_code'] = Variable<int>(weatherCode);
    }
    return map;
  }

  ActivityLogsCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogsCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      durationSeconds: Value(durationSeconds),
      distanceMeters: Value(distanceMeters),
      caloriesBurned: Value(caloriesBurned),
      routePoints: Value(routePoints),
      weatherTemp: weatherTemp == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherTemp),
      weatherHumidity: weatherHumidity == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherHumidity),
      weatherWindKmh: weatherWindKmh == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherWindKmh),
      weatherCode: weatherCode == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherCode),
    );
  }

  factory ActivityLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      caloriesBurned: serializer.fromJson<double>(json['caloriesBurned']),
      routePoints: serializer.fromJson<String>(json['routePoints']),
      weatherTemp: serializer.fromJson<double?>(json['weatherTemp']),
      weatherHumidity: serializer.fromJson<double?>(json['weatherHumidity']),
      weatherWindKmh: serializer.fromJson<double?>(json['weatherWindKmh']),
      weatherCode: serializer.fromJson<int?>(json['weatherCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'caloriesBurned': serializer.toJson<double>(caloriesBurned),
      'routePoints': serializer.toJson<String>(routePoints),
      'weatherTemp': serializer.toJson<double?>(weatherTemp),
      'weatherHumidity': serializer.toJson<double?>(weatherHumidity),
      'weatherWindKmh': serializer.toJson<double?>(weatherWindKmh),
      'weatherCode': serializer.toJson<int?>(weatherCode),
    };
  }

  ActivityLog copyWith({
    int? id,
    DateTime? date,
    String? type,
    int? durationSeconds,
    double? distanceMeters,
    double? caloriesBurned,
    String? routePoints,
    Value<double?> weatherTemp = const Value.absent(),
    Value<double?> weatherHumidity = const Value.absent(),
    Value<double?> weatherWindKmh = const Value.absent(),
    Value<int?> weatherCode = const Value.absent(),
  }) => ActivityLog(
    id: id ?? this.id,
    date: date ?? this.date,
    type: type ?? this.type,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    routePoints: routePoints ?? this.routePoints,
    weatherTemp: weatherTemp.present ? weatherTemp.value : this.weatherTemp,
    weatherHumidity: weatherHumidity.present
        ? weatherHumidity.value
        : this.weatherHumidity,
    weatherWindKmh: weatherWindKmh.present
        ? weatherWindKmh.value
        : this.weatherWindKmh,
    weatherCode: weatherCode.present ? weatherCode.value : this.weatherCode,
  );
  ActivityLog copyWithCompanion(ActivityLogsCompanion data) {
    return ActivityLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      routePoints: data.routePoints.present
          ? data.routePoints.value
          : this.routePoints,
      weatherTemp: data.weatherTemp.present
          ? data.weatherTemp.value
          : this.weatherTemp,
      weatherHumidity: data.weatherHumidity.present
          ? data.weatherHumidity.value
          : this.weatherHumidity,
      weatherWindKmh: data.weatherWindKmh.present
          ? data.weatherWindKmh.value
          : this.weatherWindKmh,
      weatherCode: data.weatherCode.present
          ? data.weatherCode.value
          : this.weatherCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('routePoints: $routePoints, ')
          ..write('weatherTemp: $weatherTemp, ')
          ..write('weatherHumidity: $weatherHumidity, ')
          ..write('weatherWindKmh: $weatherWindKmh, ')
          ..write('weatherCode: $weatherCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    type,
    durationSeconds,
    distanceMeters,
    caloriesBurned,
    routePoints,
    weatherTemp,
    weatherHumidity,
    weatherWindKmh,
    weatherCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.caloriesBurned == this.caloriesBurned &&
          other.routePoints == this.routePoints &&
          other.weatherTemp == this.weatherTemp &&
          other.weatherHumidity == this.weatherHumidity &&
          other.weatherWindKmh == this.weatherWindKmh &&
          other.weatherCode == this.weatherCode);
}

class ActivityLogsCompanion extends UpdateCompanion<ActivityLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> durationSeconds;
  final Value<double> distanceMeters;
  final Value<double> caloriesBurned;
  final Value<String> routePoints;
  final Value<double?> weatherTemp;
  final Value<double?> weatherHumidity;
  final Value<double?> weatherWindKmh;
  final Value<int?> weatherCode;
  const ActivityLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.routePoints = const Value.absent(),
    this.weatherTemp = const Value.absent(),
    this.weatherHumidity = const Value.absent(),
    this.weatherWindKmh = const Value.absent(),
    this.weatherCode = const Value.absent(),
  });
  ActivityLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String type,
    required int durationSeconds,
    required double distanceMeters,
    required double caloriesBurned,
    required String routePoints,
    this.weatherTemp = const Value.absent(),
    this.weatherHumidity = const Value.absent(),
    this.weatherWindKmh = const Value.absent(),
    this.weatherCode = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       durationSeconds = Value(durationSeconds),
       distanceMeters = Value(distanceMeters),
       caloriesBurned = Value(caloriesBurned),
       routePoints = Value(routePoints);
  static Insertable<ActivityLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
    Expression<double>? caloriesBurned,
    Expression<String>? routePoints,
    Expression<double>? weatherTemp,
    Expression<double>? weatherHumidity,
    Expression<double>? weatherWindKmh,
    Expression<int>? weatherCode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (routePoints != null) 'route_points': routePoints,
      if (weatherTemp != null) 'weather_temp': weatherTemp,
      if (weatherHumidity != null) 'weather_humidity': weatherHumidity,
      if (weatherWindKmh != null) 'weather_wind_kmh': weatherWindKmh,
      if (weatherCode != null) 'weather_code': weatherCode,
    });
  }

  ActivityLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int>? durationSeconds,
    Value<double>? distanceMeters,
    Value<double>? caloriesBurned,
    Value<String>? routePoints,
    Value<double?>? weatherTemp,
    Value<double?>? weatherHumidity,
    Value<double?>? weatherWindKmh,
    Value<int?>? weatherCode,
  }) {
    return ActivityLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      routePoints: routePoints ?? this.routePoints,
      weatherTemp: weatherTemp ?? this.weatherTemp,
      weatherHumidity: weatherHumidity ?? this.weatherHumidity,
      weatherWindKmh: weatherWindKmh ?? this.weatherWindKmh,
      weatherCode: weatherCode ?? this.weatherCode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
    }
    if (routePoints.present) {
      map['route_points'] = Variable<String>(routePoints.value);
    }
    if (weatherTemp.present) {
      map['weather_temp'] = Variable<double>(weatherTemp.value);
    }
    if (weatherHumidity.present) {
      map['weather_humidity'] = Variable<double>(weatherHumidity.value);
    }
    if (weatherWindKmh.present) {
      map['weather_wind_kmh'] = Variable<double>(weatherWindKmh.value);
    }
    if (weatherCode.present) {
      map['weather_code'] = Variable<int>(weatherCode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('routePoints: $routePoints, ')
          ..write('weatherTemp: $weatherTemp, ')
          ..write('weatherHumidity: $weatherHumidity, ')
          ..write('weatherWindKmh: $weatherWindKmh, ')
          ..write('weatherCode: $weatherCode')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightsTable extends BodyWeights
    with TableInfo<$BodyWeightsTable, BodyWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, weightKg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weights';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyWeight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
    );
  }

  @override
  $BodyWeightsTable createAlias(String alias) {
    return $BodyWeightsTable(attachedDatabase, alias);
  }
}

class BodyWeight extends DataClass implements Insertable<BodyWeight> {
  final int id;
  final DateTime date;
  final double weightKg;
  const BodyWeight({
    required this.id,
    required this.date,
    required this.weightKg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight_kg'] = Variable<double>(weightKg);
    return map;
  }

  BodyWeightsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightsCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: Value(weightKg),
    );
  }

  factory BodyWeight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeight(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
    };
  }

  BodyWeight copyWith({int? id, DateTime? date, double? weightKg}) =>
      BodyWeight(
        id: id ?? this.id,
        date: date ?? this.date,
        weightKg: weightKg ?? this.weightKg,
      );
  BodyWeight copyWithCompanion(BodyWeightsCompanion data) {
    return BodyWeight(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeight(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weightKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeight &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg);
}

class BodyWeightsCompanion extends UpdateCompanion<BodyWeight> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> weightKg;
  const BodyWeightsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
  });
  BodyWeightsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double weightKg,
  }) : date = Value(date),
       weightKg = Value(weightKg);
  static Insertable<BodyWeight> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
    });
  }

  BodyWeightsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? weightKg,
  }) {
    return BodyWeightsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg')
          ..write(')'))
        .toString();
  }
}

class $ExerciseDictionaryTable extends ExerciseDictionary
    with TableInfo<$ExerciseDictionaryTable, ExerciseDictionaryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseDictionaryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumn<String> force = GeneratedColumn<String>(
    'force',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagesMeta = const VerificationMeta('images');
  @override
  late final GeneratedColumn<String> images = GeneratedColumn<String>(
    'images',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    force,
    level,
    mechanic,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    instructions,
    category,
    images,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_dictionary';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseDictionaryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('force')) {
      context.handle(
        _forceMeta,
        force.isAcceptableOrUnknown(data['force']!, _forceMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryMusclesMeta);
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondaryMusclesMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('images')) {
      context.handle(
        _imagesMeta,
        images.isAcceptableOrUnknown(data['images']!, _imagesMeta),
      );
    } else if (isInserting) {
      context.missing(_imagesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseDictionaryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseDictionaryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      force: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}force'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      )!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      images: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images'],
      )!,
    );
  }

  @override
  $ExerciseDictionaryTable createAlias(String alias) {
    return $ExerciseDictionaryTable(attachedDatabase, alias);
  }
}

class ExerciseDictionaryData extends DataClass
    implements Insertable<ExerciseDictionaryData> {
  final String id;
  final String name;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String instructions;
  final String category;
  final String images;
  const ExerciseDictionaryData({
    required this.id,
    required this.name,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    map['primary_muscles'] = Variable<String>(primaryMuscles);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    map['instructions'] = Variable<String>(instructions);
    map['category'] = Variable<String>(category);
    map['images'] = Variable<String>(images);
    return map;
  }

  ExerciseDictionaryCompanion toCompanion(bool nullToAbsent) {
    return ExerciseDictionaryCompanion(
      id: Value(id),
      name: Value(name),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      primaryMuscles: Value(primaryMuscles),
      secondaryMuscles: Value(secondaryMuscles),
      instructions: Value(instructions),
      category: Value(category),
      images: Value(images),
    );
  }

  factory ExerciseDictionaryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseDictionaryData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      force: serializer.fromJson<String?>(json['force']),
      level: serializer.fromJson<String?>(json['level']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      primaryMuscles: serializer.fromJson<String>(json['primaryMuscles']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      instructions: serializer.fromJson<String>(json['instructions']),
      category: serializer.fromJson<String>(json['category']),
      images: serializer.fromJson<String>(json['images']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'force': serializer.toJson<String?>(force),
      'level': serializer.toJson<String?>(level),
      'mechanic': serializer.toJson<String?>(mechanic),
      'equipment': serializer.toJson<String?>(equipment),
      'primaryMuscles': serializer.toJson<String>(primaryMuscles),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'instructions': serializer.toJson<String>(instructions),
      'category': serializer.toJson<String>(category),
      'images': serializer.toJson<String>(images),
    };
  }

  ExerciseDictionaryData copyWith({
    String? id,
    String? name,
    Value<String?> force = const Value.absent(),
    Value<String?> level = const Value.absent(),
    Value<String?> mechanic = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    String? primaryMuscles,
    String? secondaryMuscles,
    String? instructions,
    String? category,
    String? images,
  }) => ExerciseDictionaryData(
    id: id ?? this.id,
    name: name ?? this.name,
    force: force.present ? force.value : this.force,
    level: level.present ? level.value : this.level,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    equipment: equipment.present ? equipment.value : this.equipment,
    primaryMuscles: primaryMuscles ?? this.primaryMuscles,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    instructions: instructions ?? this.instructions,
    category: category ?? this.category,
    images: images ?? this.images,
  );
  ExerciseDictionaryData copyWithCompanion(ExerciseDictionaryCompanion data) {
    return ExerciseDictionaryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      force: data.force.present ? data.force.value : this.force,
      level: data.level.present ? data.level.value : this.level,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      category: data.category.present ? data.category.value : this.category,
      images: data.images.present ? data.images.value : this.images,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseDictionaryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('force: $force, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('category: $category, ')
          ..write('images: $images')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    force,
    level,
    mechanic,
    equipment,
    primaryMuscles,
    secondaryMuscles,
    instructions,
    category,
    images,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseDictionaryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.force == this.force &&
          other.level == this.level &&
          other.mechanic == this.mechanic &&
          other.equipment == this.equipment &&
          other.primaryMuscles == this.primaryMuscles &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.instructions == this.instructions &&
          other.category == this.category &&
          other.images == this.images);
}

class ExerciseDictionaryCompanion
    extends UpdateCompanion<ExerciseDictionaryData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> force;
  final Value<String?> level;
  final Value<String?> mechanic;
  final Value<String?> equipment;
  final Value<String> primaryMuscles;
  final Value<String> secondaryMuscles;
  final Value<String> instructions;
  final Value<String> category;
  final Value<String> images;
  final Value<int> rowid;
  const ExerciseDictionaryCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.force = const Value.absent(),
    this.level = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.equipment = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.instructions = const Value.absent(),
    this.category = const Value.absent(),
    this.images = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseDictionaryCompanion.insert({
    required String id,
    required String name,
    this.force = const Value.absent(),
    this.level = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.equipment = const Value.absent(),
    required String primaryMuscles,
    required String secondaryMuscles,
    required String instructions,
    required String category,
    required String images,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       primaryMuscles = Value(primaryMuscles),
       secondaryMuscles = Value(secondaryMuscles),
       instructions = Value(instructions),
       category = Value(category),
       images = Value(images);
  static Insertable<ExerciseDictionaryData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? force,
    Expression<String>? level,
    Expression<String>? mechanic,
    Expression<String>? equipment,
    Expression<String>? primaryMuscles,
    Expression<String>? secondaryMuscles,
    Expression<String>? instructions,
    Expression<String>? category,
    Expression<String>? images,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (force != null) 'force': force,
      if (level != null) 'level': level,
      if (mechanic != null) 'mechanic': mechanic,
      if (equipment != null) 'equipment': equipment,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (instructions != null) 'instructions': instructions,
      if (category != null) 'category': category,
      if (images != null) 'images': images,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseDictionaryCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? force,
    Value<String?>? level,
    Value<String?>? mechanic,
    Value<String?>? equipment,
    Value<String>? primaryMuscles,
    Value<String>? secondaryMuscles,
    Value<String>? instructions,
    Value<String>? category,
    Value<String>? images,
    Value<int>? rowid,
  }) {
    return ExerciseDictionaryCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      force: force ?? this.force,
      level: level ?? this.level,
      mechanic: mechanic ?? this.mechanic,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
      images: images ?? this.images,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(force.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (images.present) {
      map['images'] = Variable<String>(images.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseDictionaryCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('force: $force, ')
          ..write('level: $level, ')
          ..write('mechanic: $mechanic, ')
          ..write('equipment: $equipment, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructions: $instructions, ')
          ..write('category: $category, ')
          ..write('images: $images, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoodLogsTable foodLogs = $FoodLogsTable(this);
  late final $WorkoutLogsTable workoutLogs = $WorkoutLogsTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $ActivityLogsTable activityLogs = $ActivityLogsTable(this);
  late final $BodyWeightsTable bodyWeights = $BodyWeightsTable(this);
  late final $ExerciseDictionaryTable exerciseDictionary =
      $ExerciseDictionaryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foodLogs,
    workoutLogs,
    workoutSets,
    activityLogs,
    bodyWeights,
    exerciseDictionary,
  ];
}

typedef $$FoodLogsTableCreateCompanionBuilder =
    FoodLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String foodName,
      required double grams,
      required double calories,
      required double protein,
      required double carbs,
      required double fat,
    });
typedef $$FoodLogsTableUpdateCompanionBuilder =
    FoodLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> foodName,
      Value<double> grams,
      Value<double> calories,
      Value<double> protein,
      Value<double> carbs,
      Value<double> fat,
    });

class $$FoodLogsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogsTable> {
  $$FoodLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);
}

class $$FoodLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogsTable,
          FoodLog,
          $$FoodLogsTableFilterComposer,
          $$FoodLogsTableOrderingComposer,
          $$FoodLogsTableAnnotationComposer,
          $$FoodLogsTableCreateCompanionBuilder,
          $$FoodLogsTableUpdateCompanionBuilder,
          (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
          FoodLog,
          PrefetchHooks Function()
        > {
  $$FoodLogsTableTableManager(_$AppDatabase db, $FoodLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> fat = const Value.absent(),
              }) => FoodLogsCompanion(
                id: id,
                date: date,
                foodName: foodName,
                grams: grams,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String foodName,
                required double grams,
                required double calories,
                required double protein,
                required double carbs,
                required double fat,
              }) => FoodLogsCompanion.insert(
                id: id,
                date: date,
                foodName: foodName,
                grams: grams,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogsTable,
      FoodLog,
      $$FoodLogsTableFilterComposer,
      $$FoodLogsTableOrderingComposer,
      $$FoodLogsTableAnnotationComposer,
      $$FoodLogsTableCreateCompanionBuilder,
      $$FoodLogsTableUpdateCompanionBuilder,
      (FoodLog, BaseReferences<_$AppDatabase, $FoodLogsTable, FoodLog>),
      FoodLog,
      PrefetchHooks Function()
    >;
typedef $$WorkoutLogsTableCreateCompanionBuilder =
    WorkoutLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String templateName,
      required int durationMinutes,
      required double totalVolumeKg,
      Value<double> caloriesBurned,
    });
typedef $$WorkoutLogsTableUpdateCompanionBuilder =
    WorkoutLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> templateName,
      Value<int> durationMinutes,
      Value<double> totalVolumeKg,
      Value<double> caloriesBurned,
    });

class $$WorkoutLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );
}

class $$WorkoutLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutLogsTable,
          WorkoutLog,
          $$WorkoutLogsTableFilterComposer,
          $$WorkoutLogsTableOrderingComposer,
          $$WorkoutLogsTableAnnotationComposer,
          $$WorkoutLogsTableCreateCompanionBuilder,
          $$WorkoutLogsTableUpdateCompanionBuilder,
          (
            WorkoutLog,
            BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLog>,
          ),
          WorkoutLog,
          PrefetchHooks Function()
        > {
  $$WorkoutLogsTableTableManager(_$AppDatabase db, $WorkoutLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> templateName = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<double> totalVolumeKg = const Value.absent(),
                Value<double> caloriesBurned = const Value.absent(),
              }) => WorkoutLogsCompanion(
                id: id,
                date: date,
                templateName: templateName,
                durationMinutes: durationMinutes,
                totalVolumeKg: totalVolumeKg,
                caloriesBurned: caloriesBurned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String templateName,
                required int durationMinutes,
                required double totalVolumeKg,
                Value<double> caloriesBurned = const Value.absent(),
              }) => WorkoutLogsCompanion.insert(
                id: id,
                date: date,
                templateName: templateName,
                durationMinutes: durationMinutes,
                totalVolumeKg: totalVolumeKg,
                caloriesBurned: caloriesBurned,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutLogsTable,
      WorkoutLog,
      $$WorkoutLogsTableFilterComposer,
      $$WorkoutLogsTableOrderingComposer,
      $$WorkoutLogsTableAnnotationComposer,
      $$WorkoutLogsTableCreateCompanionBuilder,
      $$WorkoutLogsTableUpdateCompanionBuilder,
      (
        WorkoutLog,
        BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLog>,
      ),
      WorkoutLog,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      required int workoutLogId,
      required String exerciseName,
      required int reps,
      required double weightKg,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<int> id,
      Value<int> workoutLogId,
      Value<String> exerciseName,
      Value<int> reps,
      Value<double> weightKg,
    });

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get workoutLogId => $composableBuilder(
    column: $table.workoutLogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get workoutLogId => $composableBuilder(
    column: $table.workoutLogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get workoutLogId => $composableBuilder(
    column: $table.workoutLogId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (
            WorkoutSet,
            BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet>,
          ),
          WorkoutSet,
          PrefetchHooks Function()
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workoutLogId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                workoutLogId: workoutLogId,
                exerciseName: exerciseName,
                reps: reps,
                weightKg: weightKg,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workoutLogId,
                required String exerciseName,
                required int reps,
                required double weightKg,
              }) => WorkoutSetsCompanion.insert(
                id: id,
                workoutLogId: workoutLogId,
                exerciseName: exerciseName,
                reps: reps,
                weightKg: weightKg,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (
        WorkoutSet,
        BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet>,
      ),
      WorkoutSet,
      PrefetchHooks Function()
    >;
typedef $$ActivityLogsTableCreateCompanionBuilder =
    ActivityLogsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String type,
      required int durationSeconds,
      required double distanceMeters,
      required double caloriesBurned,
      required String routePoints,
      Value<double?> weatherTemp,
      Value<double?> weatherHumidity,
      Value<double?> weatherWindKmh,
      Value<int?> weatherCode,
    });
typedef $$ActivityLogsTableUpdateCompanionBuilder =
    ActivityLogsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> type,
      Value<int> durationSeconds,
      Value<double> distanceMeters,
      Value<double> caloriesBurned,
      Value<String> routePoints,
      Value<double?> weatherTemp,
      Value<double?> weatherHumidity,
      Value<double?> weatherWindKmh,
      Value<int?> weatherCode,
    });

class $$ActivityLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routePoints => $composableBuilder(
    column: $table.routePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherTemp => $composableBuilder(
    column: $table.weatherTemp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherHumidity => $composableBuilder(
    column: $table.weatherHumidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weatherWindKmh => $composableBuilder(
    column: $table.weatherWindKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weatherCode => $composableBuilder(
    column: $table.weatherCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routePoints => $composableBuilder(
    column: $table.routePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherTemp => $composableBuilder(
    column: $table.weatherTemp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherHumidity => $composableBuilder(
    column: $table.weatherHumidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weatherWindKmh => $composableBuilder(
    column: $table.weatherWindKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weatherCode => $composableBuilder(
    column: $table.weatherCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogsTable> {
  $$ActivityLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routePoints => $composableBuilder(
    column: $table.routePoints,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherTemp => $composableBuilder(
    column: $table.weatherTemp,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherHumidity => $composableBuilder(
    column: $table.weatherHumidity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weatherWindKmh => $composableBuilder(
    column: $table.weatherWindKmh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weatherCode => $composableBuilder(
    column: $table.weatherCode,
    builder: (column) => column,
  );
}

class $$ActivityLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogsTable,
          ActivityLog,
          $$ActivityLogsTableFilterComposer,
          $$ActivityLogsTableOrderingComposer,
          $$ActivityLogsTableAnnotationComposer,
          $$ActivityLogsTableCreateCompanionBuilder,
          $$ActivityLogsTableUpdateCompanionBuilder,
          (
            ActivityLog,
            BaseReferences<_$AppDatabase, $ActivityLogsTable, ActivityLog>,
          ),
          ActivityLog,
          PrefetchHooks Function()
        > {
  $$ActivityLogsTableTableManager(_$AppDatabase db, $ActivityLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double> caloriesBurned = const Value.absent(),
                Value<String> routePoints = const Value.absent(),
                Value<double?> weatherTemp = const Value.absent(),
                Value<double?> weatherHumidity = const Value.absent(),
                Value<double?> weatherWindKmh = const Value.absent(),
                Value<int?> weatherCode = const Value.absent(),
              }) => ActivityLogsCompanion(
                id: id,
                date: date,
                type: type,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                caloriesBurned: caloriesBurned,
                routePoints: routePoints,
                weatherTemp: weatherTemp,
                weatherHumidity: weatherHumidity,
                weatherWindKmh: weatherWindKmh,
                weatherCode: weatherCode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String type,
                required int durationSeconds,
                required double distanceMeters,
                required double caloriesBurned,
                required String routePoints,
                Value<double?> weatherTemp = const Value.absent(),
                Value<double?> weatherHumidity = const Value.absent(),
                Value<double?> weatherWindKmh = const Value.absent(),
                Value<int?> weatherCode = const Value.absent(),
              }) => ActivityLogsCompanion.insert(
                id: id,
                date: date,
                type: type,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                caloriesBurned: caloriesBurned,
                routePoints: routePoints,
                weatherTemp: weatherTemp,
                weatherHumidity: weatherHumidity,
                weatherWindKmh: weatherWindKmh,
                weatherCode: weatherCode,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogsTable,
      ActivityLog,
      $$ActivityLogsTableFilterComposer,
      $$ActivityLogsTableOrderingComposer,
      $$ActivityLogsTableAnnotationComposer,
      $$ActivityLogsTableCreateCompanionBuilder,
      $$ActivityLogsTableUpdateCompanionBuilder,
      (
        ActivityLog,
        BaseReferences<_$AppDatabase, $ActivityLogsTable, ActivityLog>,
      ),
      ActivityLog,
      PrefetchHooks Function()
    >;
typedef $$BodyWeightsTableCreateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> id,
      required DateTime date,
      required double weightKg,
    });
typedef $$BodyWeightsTableUpdateCompanionBuilder =
    BodyWeightsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<double> weightKg,
    });

class $$BodyWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);
}

class $$BodyWeightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyWeightsTable,
          BodyWeight,
          $$BodyWeightsTableFilterComposer,
          $$BodyWeightsTableOrderingComposer,
          $$BodyWeightsTableAnnotationComposer,
          $$BodyWeightsTableCreateCompanionBuilder,
          $$BodyWeightsTableUpdateCompanionBuilder,
          (
            BodyWeight,
            BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>,
          ),
          BodyWeight,
          PrefetchHooks Function()
        > {
  $$BodyWeightsTableTableManager(_$AppDatabase db, $BodyWeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
              }) =>
                  BodyWeightsCompanion(id: id, date: date, weightKg: weightKg),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double weightKg,
              }) => BodyWeightsCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyWeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyWeightsTable,
      BodyWeight,
      $$BodyWeightsTableFilterComposer,
      $$BodyWeightsTableOrderingComposer,
      $$BodyWeightsTableAnnotationComposer,
      $$BodyWeightsTableCreateCompanionBuilder,
      $$BodyWeightsTableUpdateCompanionBuilder,
      (
        BodyWeight,
        BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>,
      ),
      BodyWeight,
      PrefetchHooks Function()
    >;
typedef $$ExerciseDictionaryTableCreateCompanionBuilder =
    ExerciseDictionaryCompanion Function({
      required String id,
      required String name,
      Value<String?> force,
      Value<String?> level,
      Value<String?> mechanic,
      Value<String?> equipment,
      required String primaryMuscles,
      required String secondaryMuscles,
      required String instructions,
      required String category,
      required String images,
      Value<int> rowid,
    });
typedef $$ExerciseDictionaryTableUpdateCompanionBuilder =
    ExerciseDictionaryCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> force,
      Value<String?> level,
      Value<String?> mechanic,
      Value<String?> equipment,
      Value<String> primaryMuscles,
      Value<String> secondaryMuscles,
      Value<String> instructions,
      Value<String> category,
      Value<String> images,
      Value<int> rowid,
    });

class $$ExerciseDictionaryTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseDictionaryTable> {
  $$ExerciseDictionaryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseDictionaryTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseDictionaryTable> {
  $$ExerciseDictionaryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get images => $composableBuilder(
    column: $table.images,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseDictionaryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseDictionaryTable> {
  $$ExerciseDictionaryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get force =>
      $composableBuilder(column: $table.force, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get images =>
      $composableBuilder(column: $table.images, builder: (column) => column);
}

class $$ExerciseDictionaryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseDictionaryTable,
          ExerciseDictionaryData,
          $$ExerciseDictionaryTableFilterComposer,
          $$ExerciseDictionaryTableOrderingComposer,
          $$ExerciseDictionaryTableAnnotationComposer,
          $$ExerciseDictionaryTableCreateCompanionBuilder,
          $$ExerciseDictionaryTableUpdateCompanionBuilder,
          (
            ExerciseDictionaryData,
            BaseReferences<
              _$AppDatabase,
              $ExerciseDictionaryTable,
              ExerciseDictionaryData
            >,
          ),
          ExerciseDictionaryData,
          PrefetchHooks Function()
        > {
  $$ExerciseDictionaryTableTableManager(
    _$AppDatabase db,
    $ExerciseDictionaryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseDictionaryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseDictionaryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseDictionaryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String> primaryMuscles = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<String> instructions = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> images = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseDictionaryCompanion(
                id: id,
                name: name,
                force: force,
                level: level,
                mechanic: mechanic,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                category: category,
                images: images,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> force = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                required String primaryMuscles,
                required String secondaryMuscles,
                required String instructions,
                required String category,
                required String images,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseDictionaryCompanion.insert(
                id: id,
                name: name,
                force: force,
                level: level,
                mechanic: mechanic,
                equipment: equipment,
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles,
                instructions: instructions,
                category: category,
                images: images,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseDictionaryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseDictionaryTable,
      ExerciseDictionaryData,
      $$ExerciseDictionaryTableFilterComposer,
      $$ExerciseDictionaryTableOrderingComposer,
      $$ExerciseDictionaryTableAnnotationComposer,
      $$ExerciseDictionaryTableCreateCompanionBuilder,
      $$ExerciseDictionaryTableUpdateCompanionBuilder,
      (
        ExerciseDictionaryData,
        BaseReferences<
          _$AppDatabase,
          $ExerciseDictionaryTable,
          ExerciseDictionaryData
        >,
      ),
      ExerciseDictionaryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoodLogsTableTableManager get foodLogs =>
      $$FoodLogsTableTableManager(_db, _db.foodLogs);
  $$WorkoutLogsTableTableManager get workoutLogs =>
      $$WorkoutLogsTableTableManager(_db, _db.workoutLogs);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$ActivityLogsTableTableManager get activityLogs =>
      $$ActivityLogsTableTableManager(_db, _db.activityLogs);
  $$BodyWeightsTableTableManager get bodyWeights =>
      $$BodyWeightsTableTableManager(_db, _db.bodyWeights);
  $$ExerciseDictionaryTableTableManager get exerciseDictionary =>
      $$ExerciseDictionaryTableTableManager(_db, _db.exerciseDictionary);
}
