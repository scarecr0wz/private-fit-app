import 'dart:convert';
import 'package:flutter/services.dart';
import 'database.dart';
import 'package:drift/drift.dart' as drift;

class ExerciseSeeder {
  static Future<void> seedIfEmpty() async {
    final count = await db.exerciseDictionary.count().getSingle();
    if (count > 0) {
      return; // Already seeded
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final List<ExerciseDictionaryCompanion> companions = [];

      for (var item in jsonList) {
        companions.add(ExerciseDictionaryCompanion.insert(
          id: item['id'] as String,
          name: item['name'] as String,
          force: drift.Value(item['force'] as String?),
          level: drift.Value(item['level'] as String?),
          mechanic: drift.Value(item['mechanic'] as String?),
          equipment: drift.Value(item['equipment'] as String?),
          primaryMuscles: (item['primaryMuscles'] as List).join(','),
          secondaryMuscles: (item['secondaryMuscles'] as List).join(','),
          instructions: (item['instructions'] as List).join('\n'),
          category: item['category'] as String,
          images: (item['images'] as List).join(','),
        ));
      }

      // Batch insert is extremely fast for large datasets
      await db.batch((batch) {
        batch.insertAll(db.exerciseDictionary, companions);
      });

      print("Successfully seeded ${companions.length} exercises from JSON");
    } catch (e) {
      print("Error seeding exercises: $e");
    }
  }
}
