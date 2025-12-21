import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A73E8), // Google Blue
        brightness: Brightness.light,
        surface: const Color(0xFFF8F9FA),
        primary: const Color(0xFF1A73E8),
        secondary: const Color(0xFF34A853), // Google Green
        error: const Color(0xFFEA4335),     // Google Red
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        bodyLarge: const TextStyle(fontSize: 16),
        labelLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
