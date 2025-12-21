import 'package:flutter/material.dart';

class NoticeResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const NoticeResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Ensure we handle the nested data structure from the backend correctly
    final fields = data['data'] ?? {};
    final String riskLevel = fields['riskLevel'] ?? 'Unknown';
    // Logic for safe vs action
    final bool isSafe = ['safe', 'low'].contains(riskLevel.toLowerCase());
    
    return Scaffold(
      appBar: AppBar(title: const Text("Notice Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Chip(
                label: Text(
                  isSafe ? "SAFE" : "ACTION REQUIRED", 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                backgroundColor: isSafe ? Colors.green : Colors.orange,
                labelStyle: const TextStyle(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard("Summary", fields['summary'] ?? "No Information"),
            _InfoCard("Deadline", fields['deadline'] ?? "None"),
            _InfoCard("Penalty", fields['penalty'] ?? "None"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reply Generation Module - Coming Soon"))
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Generate Reply"),
            ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
