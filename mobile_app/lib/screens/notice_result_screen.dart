import 'package:flutter/material.dart';
import '../services/history_service.dart';

class NoticeResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const NoticeResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Robust data extraction: Check if data is nested or flat
    final dynamic raw = data.containsKey('data') ? data['data'] : data;
    final Map<String, dynamic> fields = (raw is Map) ? Map<String, dynamic>.from(raw) : {};

    String valid(dynamic val) {
       if (val == null) return "";
       String s = val.toString();
       if (s.isEmpty || s == 'None' || s == 'Not Found') return "";
       return s;
    }

    String get(List<String> keys) {
      for (var k in keys) {
        if (fields.containsKey(k)) {
           String v = valid(fields[k]);
           if (v.isNotEmpty) return v;
        }
        String title = k[0].toUpperCase() + k.substring(1);
         if (fields.containsKey(title)) {
           String v = valid(fields[title]);
           if (v.isNotEmpty) return v;
        }
      }
      return "Not Available";
    }

    final risk = get(['riskLevel', 'risk_level', 'RiskLevel']).toLowerCase();
    final isSafe = risk.contains('safe') || risk.contains('low');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Analysis"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSafe ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSafe ? Colors.green.shade300 : Colors.orange.shade300),
              ),
              child: Text(
                isSafe ? "SAFE TO IGNORE" : "ACTION REQUIRED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSafe ? Colors.green.shade800 : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Info Cards
            _InfoCard("Notice Type", get(['notice_type', 'type'])),
            _InfoCard("Summary", get(['summary', 'reason', 'description'])),
            _InfoCard("Deadline", get(['deadline', 'due_date', 'date'])),
            _InfoCard("Penalty Demand", get(['penalty', 'amount', 'demand'])),
            _InfoCard("Action Required", get(['action_required', 'action'])),

            const SizedBox(height: 24),
            
            // Save Button
            ElevatedButton.icon(
              onPressed: () {
                 HistoryService().addEntry({
                   'type': 'notice',
                   'title': get(['notice_type', 'type']),
                   'date': DateTime.now().toString().split(' ')[0],
                   'data': fields, // Save the parsed fields
                 });
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notice Saved to Documents")));
              },
              icon: const Icon(Icons.save_alt),
              label: const Text("Save to Docs"),
              style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.white, 
                   foregroundColor: Colors.black, 
                   minimumSize: const Size.fromHeight(56),
                   elevation: 0,
                   side: BorderSide(color: Colors.grey.shade300),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 16),
            
            // Reply Button
            ElevatedButton.icon(
              onPressed: () {
                 // Future: Generate Reply
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Drafting Reply... (Coming Soon)")));
              },  
              icon: const Icon(Icons.edit_document),
              label: const Text("Generate Legal Reply"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A), 
                foregroundColor: Colors.white, 
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),

            const SizedBox(height: 40),
            // Debug view removed as per request
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  const _InfoCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == "Not Available") return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
