import 'package:flutter/material.dart';

ThemeData buildSolarTheme() {
  const primaryCrimson = Color(0xFF990000);
  const darkTeal = Color(0xFF004D40);
  const darkGrayText = Color(0xFF1A1A1A);
  const borderGray = Color(0xFF2D3748);

  final scheme = ColorScheme.fromSeed(
    seedColor: primaryCrimson,
    primary: primaryCrimson,
    onPrimary: Colors.white,
    secondary: darkTeal,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: darkGrayText,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryCrimson,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderSide: BorderSide(color: borderGray)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryCrimson, width: 2),
      ),
      labelStyle: TextStyle(color: darkGrayText),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkGrayText),
      bodyMedium: TextStyle(color: darkGrayText),
      titleLarge: TextStyle(color: darkGrayText, fontWeight: FontWeight.bold),
    ),
  );
}
