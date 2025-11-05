import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

// Calm-inspired, modern Material 3 theme (purple primary)
final Color _seed = const Color(0xFF695AD3);

final ThemeData appTheme = _buildLightTheme();
final ThemeData darkAppTheme = _buildDarkTheme();

ThemeData _buildLightTheme() {
  final baseScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
  final colorScheme = baseScheme.copyWith(
    onSurface: const Color(0xFF232443),
    onSurfaceVariant: const Color(0xFF5D5E7C),
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
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      color: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.08), colorScheme.surface),
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
    textTheme: baseText.copyWith(
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: const StadiumBorder(),
      backgroundColor: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.06), colorScheme.surface),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.05), colorScheme.surface),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.primary)),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final baseScheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark);
  final colorScheme = baseScheme.copyWith(
    onSurface: const Color(0xFF232443),
    onSurfaceVariant: const Color(0xFF5D5E7C),
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
    textTheme: baseText.copyWith(
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: const StadiumBorder(),
      backgroundColor: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.10), colorScheme.surface),
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.08), colorScheme.surface),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorScheme.primary)),
    ),
  );
}
