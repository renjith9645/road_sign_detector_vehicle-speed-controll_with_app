import 'package:flutter/material.dart';

class FuturisticTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF050816),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF00FFFF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A1026),
      foregroundColor: Colors.cyanAccent,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: Colors.black,
        elevation: 10,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF101B3A),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}