import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/history_service.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(title: const Text("My Documents"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListenableBuilder(
        listenable: HistoryService(),
        builder: (context, child) {
          final history = HistoryService().history;
          // Filter only docs (invoices and notices)
          final docs = history.where((e) => ['invoice', 'notice'].contains(e['type'])).toList();

          if (docs.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   const Text("No documents saved yet"),
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
               // Reverse order to show newest first? NO, usually history is appended.
               // Let's reverse access:
               final doc = docs[docs.length - 1 - index];
               
               // Extract logic
               String title = doc['title'] ?? "Document";
               String date = doc['date'] ?? "";
               String type = (doc['type'] ?? "Doc").toString().toUpperCase();
               String status = doc['status'] ?? ""; 
               Color statusColor = Colors.grey;
               IconData icon = Icons.description;
               
               if (type == 'INVOICE') {
                  icon = Icons.receipt_long;
                  title = doc['data']?['vendor']?['name'] ?? "Invoice";
                  final amt = doc['data']?['invoiceDetails']?['totalAmount'];
                  if (amt != null) status = "₹$amt";
                  statusColor = Colors.blue;
               } else if (type == 'NOTICE') {
                  icon = Icons.warning_amber_rounded;
                  title = doc['data']?['notice_type'] ?? "GST Notice";
                  final risk = doc['data']?['riskLevel']?.toString().toLowerCase() ?? "";
                  if (risk.contains("safe")) {
                     status = "SAFE";
                     statusColor = Colors.green;
                  } else {
                     status = "ACTION REQ";
                     statusColor = Colors.orange;
                  }
               }

               return _DocTile(
                 title: title,
                 date: date,
                 type: type,
                 trailingText: status,
                 trailingColor: statusColor,
                 icon: icon,
                 onTap: () {
                    _showDocPreview(context, title, type);
                 },
               );
            },
          );
        }
      ),
    );
  }

  void _showDocPreview(BuildContext context, String title, String type) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title, style: const TextStyle(fontSize: 16)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                    type == "INVOICE" ? Icons.receipt_long : Icons.warning_amber_rounded,
                    size: 80, 
                    color: Colors.blueGrey.shade200
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Preview of $title",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      "This is a placeholder for the actual document file.\nIn a real app, the PDF or Image would be rendered here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
               padding: const EdgeInsets.all(16),
               child: ElevatedButton.icon(
                 onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading...")));
                 },
                 icon: const Icon(Icons.download),
                 label: const Text("Download Document"),
                 style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
               ),
            )
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String date;
  final String type;
  final String trailingText;
  final Color trailingColor;
  final IconData icon;
  final VoidCallback onTap;

  const _DocTile({
    required this.title,
    required this.date,
    required this.type,
    required this.trailingText,
    required this.trailingColor,
    required this.icon,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade50,
            child: Icon(icon, color: Colors.blueGrey),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text("$type • $date", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          trailing: Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
             decoration: BoxDecoration(
               color: trailingColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(trailingText, style: TextStyle(color: trailingColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
