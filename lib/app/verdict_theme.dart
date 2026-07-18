import 'package:flutter/material.dart';

abstract final class VerdictPalette {
  static const ink = Color(0xFF17151A);
  static const paper = Color(0xFFFFF8E8);
  static const pink = Color(0xFFFF5C8A);
  static const blue = Color(0xFF74D7FF);
  static const green = Color(0xFF50D890);
  static const yellow = Color(0xFFFFD84D);
  static const gray = Color(0xFF77747D);
  static const white = Color(0xFFFFFFFF);
}

ThemeData verdictTheme({required bool highContrast}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: VerdictPalette.pink,
    brightness: Brightness.light,
    surface: VerdictPalette.paper,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'SpaceGrotesk',
    colorScheme: scheme,
    scaffoldBackgroundColor: VerdictPalette.paper,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1),
      headlineMedium: TextStyle(fontWeight: FontWeight.w900),
      titleLarge: TextStyle(fontWeight: FontWeight.w900),
      bodyLarge: TextStyle(fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
    ).apply(bodyColor: VerdictPalette.ink, displayColor: VerdictPalette.ink),
    iconTheme: const IconThemeData(color: VerdictPalette.ink),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: VerdictPalette.ink,
      contentTextStyle: TextStyle(
        color: VerdictPalette.white,
        fontWeight: FontWeight.w700,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
  );
}
