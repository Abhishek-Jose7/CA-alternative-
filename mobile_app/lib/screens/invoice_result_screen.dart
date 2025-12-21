import 'package:flutter/material.dart';

class InvoiceResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const InvoiceResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final fields = data['data'] ?? {};
    final tax = fields['tax'] ?? {};

    // Helper to format currency
    String fmt(dynamic val) => val?.toString() ?? "0";

    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Row("Vendor", fields['vendorName'] ?? "Unknown"),
            _Row("Invoice Date", fields['date'] ?? "N/A"),
            _Row("Total Amount", "₹${fmt(fields['totalAmount'])}"),
            const Divider(),
            _Row("CGST", "₹${fmt(tax['cgst'])}"),
            _Row("SGST", "₹${fmt(tax['sgst'])}"),
            _Row("IGST", "₹${fmt(tax['igst'])}"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invoice Saved Successfully"))
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Save Invoice"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
