import 'package:flutter/material.dart';

// Calm-inspired, modern Material 3 theme
final Color _seed = const Color(0xFF254159); // deep, calming blue

final ThemeData appTheme = _buildLightTheme();
final ThemeData darkAppTheme = _buildDarkTheme();

ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.3),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFF0F1720),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      color: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.03), colorScheme.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.3),
    ),
  );
}
