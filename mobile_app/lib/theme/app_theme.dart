import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Fintech Palette
  // Premium Fintech Palette (Navy Blue & White)
  static const Color primaryBlue = Color(0xFF001F54); // Navy Blue
  static const Color accentBlue = Color(0xFF00A8E8); // Bright Cyan for accents
  static const Color successGreen = Color(0xFF00C853); // Vibrant Green
  static const Color warningOrange = Color(0xFFFFAB00); // Amber
  static const Color backgroundWhite = Color(0xFFF0F4F8); // Cool White
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF0A1929); // Very Dark Blue-Grey
  static const Color textGrey = Color(0xFF64748B); // Blue-Grey

  static List<BoxShadow> get softShadows => [
        BoxShadow(
          color: const Color(0xFF001F54).withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFF001F54).withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: successGreen,
        tertiary: warningOrange,
        surface: cardWhite,
        background: backgroundWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundWhite,

      // Typography
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: const TextStyle(
            color: textDark, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: const TextStyle(
            color: textDark, fontWeight: FontWeight.w700, fontSize: 22),
        titleMedium: const TextStyle(
            color: textDark, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: const TextStyle(color: textDark, fontSize: 16),
        bodyMedium: const TextStyle(color: textGrey, fontSize: 14),
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryBlue,
        elevation: 10,
        indicatorColor: Colors.white.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
          }
          return TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              fontSize: 13);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: Colors.white, size: 26);
          }
          return IconThemeData(color: Colors.white.withOpacity(0.9), size: 24);
        }),
      ),
    );
  }
}
