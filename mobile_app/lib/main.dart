import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vyapar_guard/theme/app_theme.dart';
import 'screens/main_wrapper.dart';
import 'providers/language_provider.dart';

void main() {
  runApp(const VyaparGuardApp());
}

class VyaparGuardApp extends StatelessWidget {
  const VyaparGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VyaparGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainWrapper(),
    );
  }
}
