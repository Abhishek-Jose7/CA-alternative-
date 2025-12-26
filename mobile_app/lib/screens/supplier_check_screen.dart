import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class SupplierCheckScreen extends StatefulWidget {
  const SupplierCheckScreen({super.key});

  @override
  State<SupplierCheckScreen> createState() => _SupplierCheckScreenState();
}

class _SupplierCheckScreenState extends State<SupplierCheckScreen> {
  final _controller = TextEditingController();
  String? _resultStatus; // 'safe' or 'risky'
  bool _isLoading = false;

  void _checkNiyat() async {
    if (_controller.text.length < 15) return;
    setState(() => _isLoading = true);
    
    // Mock API Delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock Logic: If GSTIN ends with '1' -> Safe, else Risky
    final isSafe = _controller.text.endsWith('1'); 
    
    setState(() {
      _isLoading = false;
      _resultStatus = isSafe ? 'safe' : 'risky';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(lang.t('supplier_check_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: lang.t('enter_gstin'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _checkNiyat,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(lang.t('check_niyat')),
              ),
            ),
            const SizedBox(height: 40),
            
            if (_resultStatus != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _resultStatus == 'safe' ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _resultStatus == 'safe' ? Colors.green : Colors.red,
                    width: 2
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _resultStatus == 'safe' ? Icons.check_circle : Icons.warning,
                      color: _resultStatus == 'safe' ? Colors.green : Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _resultStatus == 'safe' ? lang.t('safe') : lang.t('risky'),
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: _resultStatus == 'safe' ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resultStatus == 'safe' ? lang.t('safe_msg') : lang.t('risky_msg'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
