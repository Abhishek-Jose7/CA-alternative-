import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/history_service.dart';
import '../widgets/hover_scale_card.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool _isPakka = true; // True = Bill, False = Cash
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _save() {
    if (_amountCtrl.text.isNotEmpty) {
      // Save to HistoryService
      HistoryService().addEntry({
        'type': 'expense',
        'title': _descCtrl.text.isEmpty ? (_isPakka ? "Bill Expense" : "Cash Expense") : _descCtrl.text,
        'amount': _amountCtrl.text,
        'date': DateTime.now().toString().split(' ')[0],
        'isPakka': _isPakka,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense Saved!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(lang.t('expense_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Toggle
            HoverScaleCard(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPakka = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isPakka ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            lang.t('pakka'),
                            style: TextStyle(
                              color: _isPakka ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPakka = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                !_isPakka ? Colors.orange : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            lang.t('kaccha'),
                            style: TextStyle(
                              color: !_isPakka ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                labelText: lang.t('amount'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: lang.t('desc'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPakka ? Colors.green : Colors.orange,
                ),
                child: Text(lang.t('save_entry')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
