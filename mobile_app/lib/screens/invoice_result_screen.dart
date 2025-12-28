import 'package:flutter/material.dart';
import '../widgets/hover_scale_card.dart';
import '../services/history_service.dart';

class InvoiceResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const InvoiceResultScreen({super.key, required this.data});

  @override
  @override
  Widget build(BuildContext context) {
    // Determine if we have the new structured data or old flat data
    final dynamic rawData = data.containsKey('data') ? data['data'] : data;
    final Map<String, dynamic> invoiceData =
        rawData is Map<String, dynamic> ? rawData : {};

    final details = invoiceData['invoiceDetails'] ?? {};
    final vendor = invoiceData['vendor'] ?? {};
    final customer = invoiceData['customer'] ?? {};
    final List lineItems = invoiceData['lineItems'] ?? [];
    final List taxAnalysis = invoiceData['taxAnalysis'] ?? [];
    Map<String, dynamic> summary = Map<String, dynamic>.from(invoiceData['summary'] ?? {});
    
    // Fallback Calculation Logic
    // If backend extracted 0 for totals, try to calculate from components
    double totalTaxable = double.tryParse(summary['totalTaxable']?.toString() ?? "0") ?? 0;
    double totalTax = double.tryParse(summary['totalTax']?.toString() ?? "0") ?? 0;
    
    // Only recalculate TAXABLE if it's missing. Do NOT touch Grand Total.
    if (totalTaxable == 0 && taxAnalysis.isNotEmpty) {
      for (var tax in taxAnalysis) {
        totalTaxable += double.tryParse(tax['taxableValue']?.toString() ?? "0") ?? 0;
      }
      summary['totalTaxable'] = totalTaxable;
    }
    
    if (totalTax == 0 && taxAnalysis.isNotEmpty) {
      for (var tax in taxAnalysis) {
         totalTax += (double.tryParse(tax['cgst']?.toString() ?? "0") ?? 0) + 
                     (double.tryParse(tax['sgst']?.toString() ?? "0") ?? 0) +
                     (double.tryParse(tax['igst']?.toString() ?? "0") ?? 0);
      }
      summary['totalTax'] = totalTax;
    }
    
    // TRUST THE INVOICE TOTAL. Do not recompute from taxable.
    double grandTotal = double.tryParse(details['totalAmount']?.toString() ?? "0") ?? 0;
    
    // If extraction failed completely, Try summing line items as a last resort
    if (grandTotal == 0 && lineItems.isNotEmpty) {
        for (var item in lineItems) {
            grandTotal += double.tryParse(item['amount']?.toString() ?? "0") ?? 0;
        }
        // Update the display detail too
        details['totalAmount'] = grandTotal;
    }

    // Payment Logic
    double received = double.tryParse(details['receivedAmount']?.toString() ?? "0") ?? 0;
    double balance = grandTotal - received;
    
    // Update details map for display
    details['balanceAmount'] = balance; 

    
    // Fallback for old style data if needed (optional, but good for safety)
    if (invoiceData.isEmpty) {
        return Scaffold(
            appBar: AppBar(title: const Text("Invoice Details")),
            body: const Center(child: Text("No detailed data found.")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text("Invoice Verified"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (Invoice No, Date, Amount)
            _buildHeaderCard(details),
            const SizedBox(height: 16),

            // 2. Vendor & Customer Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPartyCard("Vendor", vendor, Colors.blue.shade50)),
                const SizedBox(width: 12),
                Expanded(child: _buildPartyCard("Customer", customer, Colors.orange.shade50)),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Line Items Table
            const Text("Line Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildLineItemsTable(lineItems),
            const SizedBox(height: 16),

            // 4. Tax Analysis Table (if exists)
            if (taxAnalysis.isNotEmpty) ...[
                const Text("Tax Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTaxTable(taxAnalysis),
                const SizedBox(height: 16),
            ],

            // 5. Summary & Totals
            _buildSummaryCard(summary, details),
            
            const SizedBox(height: 24),
            
            // 6. Action Buttons
            Row(
                children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implement Edit
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Edit feature coming soon")));
                            },
                            child: const Text("Edit"),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                                // Save to History
                                HistoryService().addInvoice(data);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Invoice Saved to History"))
                                );
                                
                                // wait a bit then pop
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                });
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                            child: const Text("Confirm & Save"),
                        ),
                    ),
                ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Invoice No", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(details['invoiceNumber']?.toString() ?? "N/A", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Date", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(details['invoiceDate']?.toString() ?? "N/A", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text("₹${details['totalAmount'] ?? 0}", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue[900])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyCard(String title, Map data, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(data['name'] ?? "Unknown", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
           if (data['gstin'] != null)
            Text("GST: ${data['gstin']}", style: const TextStyle(fontSize: 11, color: Colors.black54)),
           if (data['address'] != null)
            Text(data['address'], style: const TextStyle(fontSize: 11, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLineItemsTable(List items) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowHeight: 48,
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(cells: [
              DataCell(Container(
                  width: 120, 
                  child: Text(item['description'] ?? "Item", overflow: TextOverflow.ellipsis),
              )),
              DataCell(Text(item['qty']?.toString() ?? "1")),
              DataCell(Text(item['rate']?.toString() ?? "0")),
              DataCell(Text(item['amount']?.toString() ?? "0", style: const TextStyle(fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaxTable(List taxes) {
     return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        headingRowHeight: 36,
        dataRowHeight: 40,
        columnSpacing: 15,
         columns: const [
            DataColumn(label: Text('Rate', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('Taxable', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('CGST', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('SGST', style: TextStyle(fontSize: 12))),
          ],
          rows: taxes.map<DataRow>((tax) {
            return DataRow(cells: [
              DataCell(Text(tax['rate']?.toString() ?? "0%", style: const TextStyle(fontSize: 12))),
              DataCell(Text(tax['taxableValue']?.toString() ?? "0", style: const TextStyle(fontSize: 12))),
              DataCell(Text(tax['cgst']?.toString() ?? "0", style: const TextStyle(fontSize: 12))),
              DataCell(Text(tax['sgst']?.toString() ?? "0", style: const TextStyle(fontSize: 12))),
            ]);
          }).toList(),
      ),
     );
  }

  Widget _buildSummaryCard(Map summary, Map details) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow("Taxable Amount", "₹${summary['totalTaxable'] ?? 0}"),
            _summaryRow("Total Tax", "+ ₹${summary['totalTax'] ?? 0}"),
            _summaryRow("Round Off", "₹${summary['roundOff'] ?? 0}"),
            const Divider(),
             _summaryRow("Total", "₹${summary['grandTotal'] ?? details['totalAmount'] ?? 0}", isBold: true),
             const SizedBox(height: 8),
             if (details['receivedAmount'] != null)
                _summaryRow("Paid / Received", "- ₹${details['receivedAmount']}", color: Colors.green),
             if (details['balanceAmount'] != null)
                _summaryRow("Balance Due", "₹${details['balanceAmount']}", color: Colors.red, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color ?? Colors.black
          )),
        ],
      ),
    );
  }
}
