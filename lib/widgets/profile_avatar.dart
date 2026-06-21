import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../features/profile/profile_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final hasImage = profile.profileImagePath != null && File(profile.profileImagePath!).existsSync();

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/profile'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerHigh,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(profile.profileImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: hasImage
            ? null
            : const Icon(
                Icons.person,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
      ),
    );
  }
}
