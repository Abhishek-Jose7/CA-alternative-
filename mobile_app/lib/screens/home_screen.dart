import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String? _result;

  Future<void> _scanNotice() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final res = await _api.decodeNotice(File(pickedFile.path));
        setState(() => _result = "Notice Decoded:\n${res['data']['summary']}");
      } catch (e) {
        setState(() => _result = "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scanInvoice() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final res = await _api.parseInvoice(File(pickedFile.path));
        setState(() => _result = "Invoice Parsed:\nVendor: ${res['data']['vendorName']}\nTotal: ${res['data']['totalAmount']}");
      } catch (e) {
        setState(() => _result = "Error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VyaparGuard (Pocket CA)")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_result != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(_result!,
                                  style: const TextStyle(fontSize: 16)))),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                      onPressed: _scanNotice,
                      icon: const Icon(Icons.warning_amber),
                      label: const Text("Scan GST Notice")),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                      onPressed: _scanInvoice,
                      icon: const Icon(Icons.receipt),
                      label: const Text("Scan Invoice")),
                ],
              ),
      ),
    );
  }
}
