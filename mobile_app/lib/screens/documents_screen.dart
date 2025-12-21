import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Documents")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: "All", isSelected: true),
                _FilterChip(label: "Notices"),
                _FilterChip(label: "Invoices"),
                _FilterChip(label: "Filings"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          const Text("Recent Scans", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          _DocTile(
            title: "Address Verification",
            date: "12 Oct 2025",
            type: "Notice",
            status: "SAFE",
            statusColor: Colors.green,
            icon: Icons.shield_outlined,
          ),
           _DocTile(
            title: "Invoice #INV-992",
            date: "10 Oct 2025",
            type: "Invoice",
            amount: "₹ 12,500",
            icon: Icons.receipt_long,
          ),
          _DocTile(
            title: "Show Cause Notice",
            date: "05 Sep 2025",
            type: "Notice",
            status: "ACTION REQ",
            statusColor: Colors.orange,
            icon: Icons.warning_amber,
          ),
          _DocTile(
            title: "Invoice #INV-881",
            date: "01 Sep 2025",
            type: "Invoice",
            amount: "₹ 4,200",
            icon: Icons.receipt_long,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (val) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(color: isSelected ? Colors.blue.shade900 : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String date;
  final String type;
  final String? status;
  final Color? statusColor;
  final String? amount;
  final IconData icon;

  const _DocTile({
    required this.title,
    required this.date,
    required this.type,
    this.status,
    this.statusColor,
    this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.blueGrey),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("$type • $date"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status!, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            if (amount != null)
               Text(amount!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
