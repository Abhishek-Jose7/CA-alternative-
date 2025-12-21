import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Fintech Palette
  static const Color primaryBlue = Color(0xFF0D47A1); // Deep Trust Blue
  static const Color accentBlue = Color(0xFF42A5F5);  // Lighter Blue for gradients
  static const Color successGreen = Color(0xFF2E7D32); // Money/Safe Green
  static const Color warningOrange = Color(0xFFEF6C00); // Alert Orange
  static const Color backgroundWhite = Color(0xFFF5F7FA); // Modern Slate White
  static const Color cardWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF6C757D);

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
        displayLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 22),
        titleMedium: const TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 18),
        bodyLarge: const TextStyle(color: textDark, fontSize: 16),
        bodyMedium: const TextStyle(color: textGrey, fontSize: 14),
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: textDark),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: primaryBlue.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryBlue);
          }
          return IconThemeData(color: textGrey);
        }),
      ),
    );
  }
}
