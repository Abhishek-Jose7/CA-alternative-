import 'package:flutter/foundation.dart';

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal() {
    // Check deadlines on init
    checkComplianceStatus();
    generateDummyData();
  }

  final List<Map<String, dynamic>> _history = [];
  
  // Getter for items (invoices + notices)
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  List<Map<String, dynamic>> get invoices => _history.where((e) => e['type'] == 'invoice').toList();

  void addEntry(Map<String, dynamic> data) {
    final entry = Map<String, dynamic>.from(data);
    // Ensure timestamp
    if (!entry.containsKey('timestamp')) {
       entry['timestamp'] = DateTime.now().toIso8601String();
    }
    // Ensure type
    if (!entry.containsKey('type')) {
       entry['type'] = 'entry';
    }
    
    _history.insert(0, entry);
    notifyListeners();
  }

  // Alias for backward compatibility
  void addInvoice(Map<String, dynamic> invoice) {
     var data = Map<String, dynamic>.from(invoice);
     data['type'] = 'invoice';
     addEntry(data);
  }

  final List<Map<String, dynamic>> _deadlines = [];

  // --- 1. DYNAMIC HEALTH SCORE ENGINE ---
  int calculateHealthScore() {
    int score = 100; // Base Score
    
    // Penalize for High Risk Notices
    int highRiskNotices = _history.where((e) => 
      e['type'] == 'notice' && 
      (e['riskLevel']?.toString().toLowerCase().contains('high') ?? false)
    ).length;
    
    // Penalize for Medium Risk
    int mediumRiskNotices = _history.where((e) => 
      e['type'] == 'notice' && 
      (e['riskLevel']?.toString().toLowerCase().contains('medium') ?? false)
    ).length;

    score -= (highRiskNotices * 15);
    score -= (mediumRiskNotices * 5);

    // Compliance Check
    if (DateTime.now().day > 20) {
       // score -= 5; 
    }

    return score.clamp(0, 100);
  }

  // --- 2. REAL DUE DATE CALCULATOR ---
  List<Map<String, dynamic>> getUpcomingDeadlines() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> deadlines = [];

    // Helper to format Date
    String getMonth(int month) => ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][month - 1];

    // GSTR-1 (Due 11th)
    DateTime gstr1Date = DateTime(now.year, now.month, 11);
    if (now.day > 11) {
      gstr1Date = DateTime(now.year, now.month + 1, 11);
    }
    
    // GSTR-3B (Due 20th)
    DateTime gstr3bDate = DateTime(now.year, now.month, 20);
    if (now.day > 20) {
      gstr3bDate = DateTime(now.year, now.month + 1, 20);
    }

    // Add GSTR-1
    final daysToGstr1 = gstr1Date.difference(now).inDays;
    deadlines.add({
      'title': 'GSTR-1',
      'date': '${gstr1Date.day}',
      'month': getMonth(gstr1Date.month),
      'status': daysToGstr1 <= 2 ? 'Urgent: Due in $daysToGstr1 days' : 'Due in $daysToGstr1 days',
      'isUrgent': daysToGstr1 <= 3
    });

    // Add GSTR-3B
    final daysToGstr3b = gstr3bDate.difference(now).inDays;
    deadlines.add({
      'title': 'GSTR-3B',
      'date': '${gstr3bDate.day}',
      'month': getMonth(gstr3bDate.month),
      'status': daysToGstr3b <= 2 ? 'Urgent: Due in $daysToGstr3b days' : 'Due in $daysToGstr3b days',
      'isUrgent': daysToGstr3b <= 3
    });

    // Add User Deadlines
    for (var d in _deadlines) {
       DateTime date = d['date'];
       if (date.isBefore(now.subtract(const Duration(days: 1)))) continue; // Skip past

       final days = date.difference(now).inDays;
       deadlines.add({
         'title': d['title'],
         'date': '${date.day}',
         'month': getMonth(date.month),
         'status': days <= 2 ? 'Urgent: Due in $days days' : 'Due in $days days',
         'isUrgent': days <= 3
       });
    }

    // Sort by nearest
    deadlines.sort((a, b) => (int.tryParse(a['status'].split(' ')[2]) ?? 0).compareTo((int.tryParse(b['status'].split(' ')[2]) ?? 0)));

    return deadlines;
  }

  void addDeadline(String title, DateTime date) {
    _deadlines.add({'title': title, 'date': date});
    notifyListeners();
  }

  // --- 3. NOTIFICATION SYSTEM (Logic Only) ---
  void checkComplianceStatus() {
    // This method simulates the background job that would run daily
    final deadlines = getUpcomingDeadlines();
    for (var d in deadlines) {
      if (d['isUrgent']) {
        if (kDebugMode) {
          print("PUSH NOTIFICATION TRIGGERED: ${d['title']} is due soon!");
        }
      }
    }
  }

  void generateDummyData() {
    if (_history.isNotEmpty) return;

    _history.addAll([
       {
         'type': 'notice',
         'title': 'Show Cause Notice', 
         'date': '2024-12-25',
         'riskLevel': 'High',
         'status': 'ACTION REQ',
         'data': {
             'notice_type': 'Show Cause Notice',
             'summary': 'Discrepancy in GSTR-3B vs 2A',
             'deadline': '10 Jan 2025',
             'penalty': '₹ 15,400',
             'riskLevel': 'High',
             'action_required': 'Submit reconciliation within 15 days.'
         }
       },
       {
         'type': 'invoice',
         'title': 'Ramesh Trading Co.',
         'date': '2024-12-20',
         'data': {
            'vendor': {'name': 'Ramesh Trading Co.'},
            'invoiceDetails': {'totalAmount': '24,500'}
         }
       },
       {
         'type': 'expense',
         'title': 'Shop Rent',
         'amount': '12000',
         'date': '2024-12-01',
         'isPakka': true
       },
       {
         'type': 'expense',
         'title': 'Tea & Snacks',
         'amount': '450',
         'date': '2024-12-28',
         'isPakka': false
       },
       {
         'type': 'expense',
         'title': 'Electricity Bill',
         'amount': '3200',
         'date': '2024-12-25',
         'isPakka': true
       },
       {
         'type': 'expense',
         'title': 'Local Transport',
         'amount': '120',
         'date': '2024-12-24',
         'isPakka': false
       },
       {
         'type': 'expense',
         'title': 'Stationery',
         'amount': '850',
         'date': '2024-12-22',
         'isPakka': true
       },
       {
         'type': 'expense',
         'title': 'Cleaning Staff',
         'amount': '1500',
         'date': '2024-12-15',
         'isPakka': false
       },
       {
         'type': 'expense',
         'title': 'Internet Bill',
         'amount': '1100',
         'date': '2024-12-10',
         'isPakka': true
       },
       {
         'type': 'notice',
         'title': 'Intimation of Tax',
         'date': '2024-11-15',
         'riskLevel': 'Low',
         'status': 'SAFE',
         'data': {
             'notice_type': 'Intimation',
             'summary': 'Routine intimation of tax assessed.',
             'deadline': '-',
             'penalty': '0',
             'riskLevel': 'Low',
             'action_required': 'None.'
         }
       }
    ]);
    notifyListeners();
  }
}
