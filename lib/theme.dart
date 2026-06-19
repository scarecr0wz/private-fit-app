import 'package:flutter/material.dart';

class AppColors {
  // Core Surfaces
  static const Color background = Color(0xFF121221);
  static const Color surface = Color(0xFF121221);
  static const Color surfaceDim = Color(0xFF121221);
  static const Color surfaceBright = Color(0xFF383848);
  static const Color surfaceContainerLowest = Color(0xFF0C0D1C);
  static const Color surfaceContainerLow = Color(0xFF1A1A2A);
  static const Color surfaceContainer = Color(0xFF1E1E2E);
  static const Color surfaceContainerHigh = Color(0xFF292839);
  static const Color surfaceContainerHighest = Color(0xFF333344);
  static const Color surfaceVariant = Color(0xFF333344);

  // On-surface
  static const Color onSurface = Color(0xFFE3E0F6);
  static const Color onSurfaceVariant = Color(0xFFC7C4D8);
  static const Color onBackground = Color(0xFFE3E0F6);

  // Primary (Electric Indigo / Lavender)
  static const Color primary = Color(0xFFC4C0FF);
  static const Color onPrimary = Color(0xFF2000A4);
  static const Color primaryContainer = Color(0xFF8781FF);
  static const Color onPrimaryContainer = Color(0xFF1B0091);
  static const Color primaryFixed = Color(0xFFE3DFFF);
  static const Color primaryFixedDim = Color(0xFFC4C0FF);
  static const Color inversePrimary = Color(0xFF4F44E2);

  // Secondary (Aquamarine / Teal)
  static const Color secondary = Color(0xFF44E7C3);
  static const Color onSecondary = Color(0xFF00382D);
  static const Color secondaryContainer = Color(0xFF01CAA8);
  static const Color onSecondaryContainer = Color(0xFF004F40);

  // Tertiary (Punch Pink)
  static const Color tertiary = Color(0xFFFFB0CA);
  static const Color onTertiary = Color(0xFF640036);
  static const Color tertiaryContainer = Color(0xFFF1589A);
  static const Color onTertiaryContainer = Color(0xFF58002F);

  // Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);

  // Outline
  static const Color outline = Color(0xFF918FA1);
  static const Color outlineVariant = Color(0xFF464555);

  // Inverse
  static const Color inverseSurface = Color(0xFFE3E0F6);
  static const Color inverseOnSurface = Color(0xFF2F2F3F);
  static const Color surfaceTint = Color(0xFFC4C0FF);
}

class AppTheme {
  // Convenience aliases for common usage
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color tertiary = AppColors.tertiary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color cardBg = AppColors.surfaceContainerHigh;
  static const Color textPrimary = AppColors.onSurface;
  static const Color textSecondary = AppColors.onSurfaceVariant;

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerHigh,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.85),
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.secondary, size: 24);
        }
        return const IconThemeData(color: AppColors.onSurfaceVariant, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          );
        }
        return const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        );
      }),
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.onSurface),
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.01 * 24,
      ),
    ),
    textTheme: const TextTheme(
      // display-lg: 48px, w800, letterSpacing -0.02em
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.96,
        height: 56 / 48,
      ),
      // headline-lg: 32px, w700, letterSpacing -0.01em
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.32,
        height: 40 / 32,
      ),
      // headline-lg-mobile: 24px, w700
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        height: 32 / 24,
      ),
      // title-md: 18px, w600
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        height: 24 / 18,
      ),
      // body-md: 16px, w400
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 24 / 16,
      ),
      // label-md: 14px, w500
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
        height: 20 / 14,
      ),
      // caption: 12px, w400
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 16 / 12,
      ),
    ),
    // Card shape
    splashFactory: InkRipple.splashFactory,
  );
}
