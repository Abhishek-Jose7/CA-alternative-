import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Notices', 'Invoices', 'Filings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        slivers: [
          // 1. Premium Header
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "My Documents",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF001F54), Color(0xFF003380)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Category Filter Chips
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _categories.map((cat) {
                    final bool isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategory = cat);
                        },
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textGrey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // 3. Document List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ListenableBuilder(
              listenable: HistoryService(),
              builder: (context, child) {
                final history = HistoryService().history;
                
                // Filtering Logic
                var docs = history.where((e) => ['invoice', 'notice'].contains(e['type'])).toList();
                if (_selectedCategory == 'Notices') {
                  docs = docs.where((e) => e['type'] == 'notice').toList();
                } else if (_selectedCategory == 'Invoices') {
                  docs = docs.where((e) => e['type'] == 'invoice').toList();
                } else if (_selectedCategory == 'Filings') {
                  docs = []; // Placeholder for actual filings
                }

                if (docs.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "No $_selectedCategory found",
                            style: GoogleFonts.outfit(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = docs[docs.length - 1 - index];
                      String title = doc['title'] ?? "Document";
                      String date = doc['date'] ?? "";
                      String type = (doc['type'] ?? "Doc").toString().toUpperCase();
                      String status = doc['status'] ?? ""; 
                      Color statusColor = Colors.grey;
                      IconData icon = Icons.description;
                      
                      if (type == 'INVOICE') {
                        icon = Icons.receipt_long;
                        title = doc['data']?['vendor']?['name'] ?? title;
                        final amt = doc['data']?['invoiceDetails']?['totalAmount'];
                        if (amt != null) status = "₹$amt";
                        statusColor = AppTheme.primaryBlue;
                      } else if (type == 'NOTICE') {
                        icon = Icons.warning_amber_rounded;
                        title = doc['data']?['notice_type'] ?? title;
                        final risk = doc['data']?['riskLevel']?.toString().toLowerCase() ?? "";
                        if (risk.contains("safe")) {
                          status = "SAFE";
                          statusColor = Colors.green;
                        } else {
                          status = "ACTION REQ";
                          statusColor = Colors.orange;
                        }
                      }

                      if (doc['data']?['needs_ca_review'] == true) {
                        status = "CA REVIEW REQ";
                        statusColor = Colors.redAccent;
                      }

                      return _DocTile(
                        title: title,
                        date: date,
                        type: type,
                        trailingText: status,
                        trailingColor: statusColor,
                        icon: icon,
                        onTap: () => _showDocPreview(context, doc),
                      );
                    },
                    childCount: docs.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload functionality coming soon!")),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDocPreview(BuildContext context, Map<String, dynamic> doc) {
    final String type = (doc['type'] ?? "").toString().toUpperCase();
    final String title = doc['title'] ?? "Document";
    final data = doc['data'] ?? {};
    final ragGuidance = data['guidance'];
    final validation = data['validation'];
    final needsCa = data['needs_ca_review'] == true;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
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
              if (needsCa)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent.withOpacity(0.1),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Awaiting Chartered Accountant Review (High Risk)",
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade50,
                child: Center(
                  child: Icon(
                    type == "INVOICE" ? Icons.receipt_long : Icons.warning_amber_rounded,
                    size: 80, 
                    color: Colors.blueGrey.shade200
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ragGuidance != null) ...[
                      const Text("🏛️ LEGAL GUIDANCE (RAG)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 4),
                      Text(ragGuidance, style: const TextStyle(fontSize: 13)),
                      const Divider(height: 24),
                    ],
                    if (validation != null) ...[
                      const Text("⚙️ HYBRID LOGIC VALIDATION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 4),
                      if (validation['errors'].isNotEmpty)
                         ...validation['errors'].map((e) => Text("❌ $e", style: const TextStyle(color: Colors.red, fontSize: 12))).toList(),
                      if (validation['warnings'].isNotEmpty)
                         ...validation['warnings'].map((w) => Text("⚠️ $w", style: const TextStyle(color: Colors.orange, fontSize: 12))).toList(),
                      if (validation['warnings'].isEmpty && validation['errors'].isEmpty)
                         const Text("✅ Mathematical and format checks passed.", style: TextStyle(color: Colors.green, fontSize: 12)),
                      const Divider(height: 24),
                    ],
                    Text(
                      "Full extraction data is stored for your records. You can download the physical copy below.",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Padding(
                 padding: const EdgeInsets.all(16),
                 child: Row(
                   children: [
                     Expanded(
                       child: OutlinedButton.icon(
                         onPressed: () => Navigator.pop(ctx),
                         icon: const Icon(Icons.share),
                         label: const Text("Share"),
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: ElevatedButton.icon(
                         onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloading...")));
                         },
                         icon: const Icon(Icons.download),
                         label: const Text("Download"),
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                       ),
                     ),
                   ],
                 ),
              )
            ],
          ),
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
