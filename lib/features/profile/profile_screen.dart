import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme.dart';
import 'profile_provider.dart';
import '../../data/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.9),
                  radius: 1.0,
                  colors: [
                    Color(0xFF1E1E3E),
                    AppColors.background,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Avatar & Name
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                ref.read(profileProvider.notifier).updateProfile(profileImagePath: pickedFile.path);
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainerHigh,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                image: profile.profileImagePath != null && File(profile.profileImagePath!).existsSync()
                                    ? DecorationImage(
                                        image: FileImage(File(profile.profileImagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: profile.profileImagePath == null || !File(profile.profileImagePath!).existsSync()
                                  ? const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.onSurfaceVariant,
                                      size: 40,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (profile.email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _editName(context, ref, profile.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Edit Name',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sections
                    _buildSectionHeader(context, 'Body Measurements'),
                    const SizedBox(height: 12),
                    _buildGlassCard(
                      children: [
                        _buildListTile(context, Icons.wc, 'Gender', profile.gender, () => _editGender(context, ref, profile.gender)),
                        _buildDivider(),
                        _buildListTile(context, Icons.cake, 'Age', '${profile.age} years', () => _editNumber(context, ref, 'Age', profile.age.toDouble(), (v) => ref.read(profileProvider.notifier).updateProfile(age: v.toInt()))),
                        _buildDivider(),
                        _buildListTile(context, Icons.height, 'Height', '${profile.height} cm', () => _editNumber(context, ref, 'Height (cm)', profile.height, (v) => ref.read(profileProvider.notifier).updateProfile(height: v))),
                        _buildDivider(),
                        _buildListTile(context, Icons.monitor_weight, 'Weight', '${profile.weight} kg', () => _editNumber(context, ref, 'Weight (kg)', profile.weight, (v) => ref.read(profileProvider.notifier).updateProfile(weight: v))),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _buildSectionHeader(context, 'Fitness Goals'),
                    const SizedBox(height: 12),
                    _buildGlassCard(
                      children: [
                        _buildListTile(context, Icons.flag, 'Main Goal', profile.mainGoal, () => _editMainGoal(context, ref, profile.mainGoal)),
                        _buildDivider(),
                        _buildListTile(context, Icons.track_changes, 'Target Weight', '${profile.targetWeight} kg', () => _editNumber(context, ref, 'Target Weight (kg)', profile.targetWeight, (v) => ref.read(profileProvider.notifier).updateProfile(targetWeight: v))),
                        _buildDivider(),
                        _buildListTile(context, Icons.directions_run, 'Activity Level', profile.activityLevel, () => _editActivityLevel(context, ref, profile.activityLevel)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(authServiceProvider).logout();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xB3292839),
            Color(0xE61E1E2E),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  // --- EDIT MODALS ---

  void _editName(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter your name",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(profileProvider.notifier).updateProfile(name: controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _editNumber(BuildContext context, WidgetRef ref, String title, double currentValue, Function(double) onSave) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Edit $title', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter value",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                onSave(val);
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _editOptions(BuildContext context, WidgetRef ref, String title, List<String> options, String currentValue, Function(String) onSave) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: TextStyle(color: opt == currentValue ? AppColors.primary : Colors.white)),
              trailing: opt == currentValue ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                onSave(opt);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _editGender(BuildContext context, WidgetRef ref, String current) => _editOptions(context, ref, 'Gender', ['Male', 'Female', 'Other'], current, (v) => ref.read(profileProvider.notifier).updateProfile(gender: v));
  void _editMainGoal(BuildContext context, WidgetRef ref, String current) => _editOptions(context, ref, 'Main Goal', ['Lose Weight', 'Maintain Weight', 'Build Muscle'], current, (v) => ref.read(profileProvider.notifier).updateProfile(mainGoal: v));
  void _editActivityLevel(BuildContext context, WidgetRef ref, String current) => _editOptions(context, ref, 'Activity Level', ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'], current, (v) => ref.read(profileProvider.notifier).updateProfile(activityLevel: v));
}
