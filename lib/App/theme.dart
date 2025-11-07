import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

import 'package:nudge/shared/style/palette.dart';

final Color _seed = AppColors.button;

final ThemeData appTheme = _buildLightTheme();
final ThemeData darkAppTheme = _buildDarkTheme();

ThemeData _buildLightTheme() {
  final baseScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
  final colorScheme = baseScheme.copyWith(
    primary: AppColors.icon,
    primaryContainer: AppColors.button,
    secondary: AppColors.button,
    surface: AppColors.surface,
    background: AppColors.gradientBottom,
    onSurface: AppColors.title,
    onSurfaceVariant: AppColors.bodyMuted,
    outline: AppColors.frameOutline,
    outlineVariant: AppColors.frameOutline,
  );
  final baseText = GoogleFonts.plusJakartaSansTextTheme();
  final display = GoogleFonts.plusJakartaSansTextTheme();
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    // Make Scaffold transparent so our global gradient shows through
    scaffoldBackgroundColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.frameOutline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.button,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: AppColors.button,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.icon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    iconTheme: const IconThemeData(color: AppColors.icon),
    textTheme: baseText.copyWith(
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.title),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.title),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.title),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.title),
      bodyLarge: baseText.bodyLarge?.copyWith(color: AppColors.title),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35, color: AppColors.title),
      bodySmall: baseText.bodySmall?.copyWith(color: AppColors.bodyMuted),
      labelSmall: baseText.labelSmall?.copyWith(color: AppColors.bodyMuted),
    ),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: AppColors.frameOutline),
      shape: const StadiumBorder(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.button,
      labelStyle: const TextStyle(color: AppColors.title),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.frameOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.frameOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.button),
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final baseScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
  final colorScheme = baseScheme.copyWith(
    onSurface: AppColors.title,
    onSurfaceVariant: AppColors.bodyMuted,
  );
  final baseText = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme);
  final display = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: AppColors.surface.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.frameOutline.withOpacity(0.4)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.button,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: AppColors.button,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.icon,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    iconTheme: const IconThemeData(color: AppColors.icon),
    textTheme: baseText.copyWith(
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.title),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.title),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.title),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.title),
      bodyLarge: baseText.bodyLarge?.copyWith(color: AppColors.title),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35, color: AppColors.title),
      bodySmall: baseText.bodySmall?.copyWith(color: AppColors.bodyMuted),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: AppColors.frameOutline.withOpacity(0.5)),
      shape: const StadiumBorder(),
      backgroundColor: AppColors.surface.withOpacity(0.08),
      selectedColor: AppColors.button,
      labelStyle: const TextStyle(color: AppColors.title),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.frameOutline.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.frameOutline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.button),
      ),
    ),
  );
}
