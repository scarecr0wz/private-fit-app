import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String? profileImagePath;
  final String name;
  final String email;
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String mainGoal;
  final double targetWeight;
  final String activityLevel;

  UserProfile({
    this.profileImagePath,
    this.name = 'User',
    this.email = '',
    this.gender = 'Male',
    this.age = 25,
    this.height = 175.0,
    this.weight = 70.0,
    this.mainGoal = 'Build Muscle',
    this.targetWeight = 75.0,
    this.activityLevel = 'Moderately Active',
  });

  UserProfile copyWith({
    String? profileImagePath,
    String? name,
    String? email,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? mainGoal,
    double? targetWeight,
    String? activityLevel,
  }) {
    return UserProfile(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      mainGoal: mainGoal ?? this.mainGoal,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(UserProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserProfile(
      profileImagePath: prefs.getString('profile_image_path'),
      name: prefs.getString('profile_name') ?? 'User',
      email: prefs.getString('profile_email') ?? '',
      gender: prefs.getString('profile_gender') ?? 'Male',
      age: prefs.getInt('profile_age') ?? 25,
      height: prefs.getDouble('profile_height') ?? 175.0,
      weight: prefs.getDouble('profile_weight') ?? 70.0,
      mainGoal: prefs.getString('profile_mainGoal') ?? 'Build Muscle',
      targetWeight: prefs.getDouble('profile_targetWeight') ?? 75.0,
      activityLevel: prefs.getString('profile_activityLevel') ?? 'Moderately Active',
    );
  }

  Future<void> updateProfile({
    String? profileImagePath,
    String? name,
    String? email,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? mainGoal,
    double? targetWeight,
    String? activityLevel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (profileImagePath != null) await prefs.setString('profile_image_path', profileImagePath);
    if (name != null) await prefs.setString('profile_name', name);
    if (email != null) await prefs.setString('profile_email', email);
    if (gender != null) await prefs.setString('profile_gender', gender);
    if (age != null) await prefs.setInt('profile_age', age);
    if (height != null) await prefs.setDouble('profile_height', height);
    if (weight != null) await prefs.setDouble('profile_weight', weight);
    if (mainGoal != null) await prefs.setString('profile_mainGoal', mainGoal);
    if (targetWeight != null) await prefs.setDouble('profile_targetWeight', targetWeight);
    if (activityLevel != null) await prefs.setString('profile_activityLevel', activityLevel);

    state = state.copyWith(
      profileImagePath: profileImagePath,
      name: name,
      email: email,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      mainGoal: mainGoal,
      targetWeight: targetWeight,
      activityLevel: activityLevel,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
