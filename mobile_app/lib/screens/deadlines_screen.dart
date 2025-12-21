import 'package:flutter/material.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deadlines & Calendar")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeadlineCard(
            title: "Reply to Address Notice",
            date: "15 Oct 2025",
            daysLeft: "2 Days Left",
            color: Colors.orange,
            action: "Reply Now",
          ),
           _DeadlineCard(
            title: "GSTR-3B Filing",
            date: "20 Oct 2025",
            daysLeft: "7 Days Left",
            color: Colors.blue,
            action: "Prepare",
          ),
           _DeadlineCard(
            title: "GSTR-1 Filing",
            date: "11 Nov 2025",
            daysLeft: "29 Days Left",
            color: Colors.green,
            action: "View",
          ),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String title;
  final String date;
  final String daysLeft;
  final Color color;
  final String action;

  const _DeadlineCard({
    required this.title,
    required this.date,
    required this.daysLeft,
    required this.color,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_filled, color: color),
                const SizedBox(width: 8),
                Text(daysLeft, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(action),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
