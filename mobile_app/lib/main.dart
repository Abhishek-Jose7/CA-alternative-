import 'package:flutter/material.dart';
import 'package:vyapar_guard/theme/app_theme.dart';
import 'screens/main_wrapper.dart'; // Import MainWrapper instead of HomeScreen

void main() {
  runApp(const VyaparGuardApp());
}

class VyaparGuardApp extends StatelessWidget {
  const VyaparGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VyaparGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use the new AppTheme
      home: const MainWrapper(),
    );
  }
}
