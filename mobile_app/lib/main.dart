import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vyapar_guard/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/language_provider.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fix for AssetManifest.json error on Flutter Web
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const VyaparGuardApp());
}

class VyaparGuardApp extends StatefulWidget {
  const VyaparGuardApp({super.key});

  @override
  State<VyaparGuardApp> createState() => _VyaparGuardAppState();
}

class _VyaparGuardAppState extends State<VyaparGuardApp> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FirebaseErrorScreen(message: _error),
      );
    }

    if (!_isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HistoryService()),
      ],
      child: const _AppContent(),
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  final String? message;
  const FirebaseErrorScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                "Firebase Not Configured",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "1. Download google-services.json from Firebase Console.\n"
                "2. Place it in /android/app/.\n"
                "3. For Web, use 'flutterfire configure' or add config to index.html.\n\n"
                "Error Details: ${message ?? 'Unknown'}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Retry or just informative
                },
                child: const Text("Read Setup Guide"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    
    // If authenticated, show main app. If not, show login.
    if (auth.isAuthenticated) {
      // Logic for Onboarding: If user was created in the last 1 minute, show onboarding
      final user = auth.user;
      final isNewUser = user != null && 
          user.metadata.creationTime != null &&
          DateTime.now().difference(user.metadata.creationTime!).inMinutes < 1;
      
      if (isNewUser) {
        return const OnboardingScreen();
      }
      return const MainWrapper();
    } else {
      return const LoginScreen();
    }
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
      home: const AuthGate(),
    );
  }
}
