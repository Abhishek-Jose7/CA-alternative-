import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';
import 'documents_screen.dart';
import 'chat_screen.dart';
import 'tithi_calendar_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      if (!lang.hasAskedLanguage) {
        _showLanguageDialog(lang);
      }
    });
  }

  void _showLanguageDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Select your Language / भाषा चुनें"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              onTap: () {
                lang.setLanguage('en');
                lang.markAsked();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("हिंदी (Hindi)"),
              onTap: () {
                lang.setLanguage('hi');
                lang.markAsked();
                Navigator.pop(ctx);
              },
            ),
             ListTile(
              title: const Text("मराठी (Marathi)"),
              onTap: () {
                lang.setLanguage('mr');
                lang.markAsked();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DocumentsScreen(),
    const ChatScreen(),
    const TithiCalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          indicatorColor: Colors.blue.shade100,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          elevation: 5,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Color(0xFF1E40AF)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description, color: Color(0xFF1E40AF)),
              label: 'Docs',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy, color: Color(0xFF1E40AF)),
              label: 'Ask CA',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: Color(0xFF1E40AF)),
              label: 'Deadlines',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFF1E40AF)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
