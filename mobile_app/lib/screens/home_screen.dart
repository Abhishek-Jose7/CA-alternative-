import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'notice_result_screen.dart';
import 'invoice_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String _loadingText = "";
  String _loadingSubtext = "";

  Future<void> _handleScan(bool isNotice) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
      _loadingText = isNotice ? "Reading document..." : "Scanning invoice...";
      _loadingSubtext = isNotice ? "Understanding GST details..." : "Extracting tables...";
    });

    try {
      final File image = File(pickedFile.path);
      Map<String, dynamic> response;
      
      if (isNotice) {
        response = await _api.decodeNotice(image);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoticeResultScreen(data: response['data'])),
        );
      } else {
        response = await _api.parseInvoice(image);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvoiceResultScreen(data: response['data'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(_loadingText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_loadingSubtext, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              const Text("Hello, Ravi! 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("GST made simple for your shop.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              
              const SizedBox(height: 30),
              
              // Status Overview Cards
              Row(
                children: [
                  Expanded(child: _StatusCard(title: "Notices", value: "2 Safe", color: Colors.green, icon: Icons.shield_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatusCard(title: "Pending", value: "1 Action", color: Colors.orange, icon: Icons.warning_amber)),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Big Action Cards
              const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _ActionCard(
                title: "Scan GST Notice",
                subtitle: "Check for penalties & risks instantly",
                icon: Icons.document_scanner,
                color: const Color(0xFF1A73E8),
                onTap: () => _handleScan(true),
              ),
              
              const SizedBox(height: 16),
              
              _ActionCard(
                title: "Scan Invoice",
                subtitle: "Digitize bills and check GSTIN",
                icon: Icons.receipt_long,
                color: const Color(0xFF34A853),
                onTap: () => _handleScan(false),
              ),
              
              const SizedBox(height: 30),
              
              // Trust Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text("AI-Powered • Secure • Private", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Specs for Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatusCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
