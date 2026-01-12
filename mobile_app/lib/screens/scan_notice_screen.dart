import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';
import 'notice_result_screen.dart';
import '../services/history_service.dart';
import 'package:provider/provider.dart';

class ScanNoticeScreen extends StatefulWidget {
  const ScanNoticeScreen({super.key});

  @override
  State<ScanNoticeScreen> createState() => _ScanNoticeScreenState();
}

class _ScanNoticeScreenState extends State<ScanNoticeScreen> {
  final ApiService _api = ApiService();

  Future<void> _captureAndAnalyze() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    if (!mounted) return;
    
    // Navigate to loading screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
    );

    try {
      final File image = File(pickedFile.path);
      // Determine complexity based on file size or type if needed, here just calling API
      final response = await _api.decodeNotice(image);
      
      if (!mounted) return;

      // Save to history
      final history = Provider.of<HistoryService>(context, listen: false);
      history.addEntry({
        'type': 'notice',
        'title': response['data']?['notice_type'] ?? 'GST Notice',
        'date': response['data']?['deadline'] ?? DateTime.now().toIso8601String().split('T')[0],
        'data': response['data']
      });
      
      // Remove loading screen (pop) then replace current screen with Result
      Navigator.pop(context); // Pop Loading
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NoticeResultScreen(data: response['data']),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Pop Loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan GST Notice")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              "Take a clear photo of the GST notice",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _captureAndAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Open Camera"),
            ),
          ],
        ),
      ),
    );
  }
}
