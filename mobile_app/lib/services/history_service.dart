import 'package:flutter/foundation.dart';

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<Map<String, dynamic>> _invoices = [];

  List<Map<String, dynamic>> get invoices => List.unmodifiable(_invoices);

  void addInvoice(Map<String, dynamic> invoice) {
    _invoices.add(invoice);
    notifyListeners();
  }
}
