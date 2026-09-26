import 'package:flutter/material.dart';

/// Visual tokens for the ERP. Keep feature code semantic (primary, error,
/// surface) instead of embedding brand colours in workflow widgets.
abstract final class SolarColors {
  static const canvas = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const slate50 = Color(0xFFF1F5F9);
  static const slate100 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate500 = Color(0xFF64748B);
  static const charcoal = Color(0xFF1E293B);
  static const crimson = Color(0xFFDC2626);
  static const deepRed = Color(0xFFB91C1C);
  static const success = Color(0xFF15803D);
  static const warning = Color(0xFFB45309);
  static const info = Color(0xFF0369A1);
}

ThemeData buildSolarTheme() {
  const radius = Radius.circular(10);
  const outline = OutlineInputBorder(
    borderRadius: BorderRadius.all(radius),
    borderSide: BorderSide(color: SolarColors.slate300),
  );
  final scheme = ColorScheme.fromSeed(
    seedColor: SolarColors.crimson,
    primary: SolarColors.crimson,
    onPrimary: Colors.white,
    secondary: SolarColors.info,
    onSecondary: Colors.white,
    surface: SolarColors.surface,
    onSurface: SolarColors.charcoal,
    error: SolarColors.deepRed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: SolarColors.canvas,
    dividerColor: SolarColors.slate100,
    appBarTheme: const AppBarTheme(
      backgroundColor: SolarColors.surface,
      foregroundColor: SolarColors.charcoal,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      titleTextStyle: TextStyle(
        color: SolarColors.charcoal,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: const CardThemeData(
      color: SolarColors.surface,
      elevation: 0,
      shadowColor: Color(0x160F172A),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: SolarColors.slate100),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        backgroundColor: SolarColors.crimson,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: SolarColors.charcoal,
        side: const BorderSide(color: SolarColors.slate300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: SolarColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: outline,
      enabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(radius),
        borderSide: BorderSide(color: SolarColors.crimson, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(radius),
        borderSide: BorderSide(color: SolarColors.deepRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(radius),
        borderSide: BorderSide(color: SolarColors.deepRed, width: 2),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: SolarColors.slate500),
      helperStyle: TextStyle(color: SolarColors.slate500),
      errorStyle: TextStyle(
        color: SolarColors.deepRed,
        fontWeight: FontWeight.w600,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: SolarColors.crimson,
      unselectedLabelColor: SolarColors.slate500,
      indicatorColor: SolarColors.crimson,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: SolarColors.slate100,
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(SolarColors.slate50),
      dataRowMinHeight: 52,
      dataRowMaxHeight: 64,
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: SolarColors.charcoal,
      ),
      dividerThickness: 1,
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: SolarColors.slate100),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: SolarColors.charcoal,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: SolarColors.charcoal,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: SolarColors.charcoal,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: SolarColors.charcoal),
      bodyMedium: TextStyle(color: SolarColors.charcoal),
      bodySmall: TextStyle(color: SolarColors.slate500),
    ),
  );
}
