import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[50], // As requested
      ),
      home: const HomeScreen(),
    );
  }
}
