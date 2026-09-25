import 'package:flutter/material.dart';

ThemeData buildSolarTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFF59E0B),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
