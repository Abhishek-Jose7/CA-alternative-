import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../providers/language_provider.dart';
import 'notice_result_screen.dart';
import 'invoice_result_screen.dart';
import 'supplier_check_screen.dart';
import 'expenses_screen.dart';

import '../theme/app_theme.dart';

import '../widgets/hover_scale_card.dart';
import '../widgets/glass_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String _loadingText = "";
  String _loadingSubtext = "";

  Future<void> _handleScan(bool isNotice) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    final lang = Provider.of<LanguageProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _loadingText = isNotice ? "Reading..." : "Scanning...";
      _loadingSubtext = "Processing...";
    });

    try {
      Map<String, dynamic> response;
      if (isNotice) {
        response = await _api.decodeNotice(pickedFile, language: lang.locale.languageCode);
        if (!mounted) return;
        _navigateWithMotion(NoticeResultScreen(data: response['data']));
      } else {
        response = await _api.parseInvoice(pickedFile);
        if (!mounted) return;
        _navigateWithMotion(InvoiceResultScreen(data: response['data']));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateWithMotion(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryBlue),
              const SizedBox(height: 24),
              Text(_loadingText, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(_loadingSubtext,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        slivers: [
          // 1. Premium Sliver App Bar with Health Score
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF001F54), Color(0xFF003380)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(lang.t('app_title').toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 10,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text("Namaste,",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w300)),
                                    const SizedBox(width: 8),
                                    Text(
                                        FirebaseAuth.instance.currentUser?.displayName?.split(" ")[0] ?? "User",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            // Actions Row
                            Row(
                              children: [
                                // Notification Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1))
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("No new notifications"))
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Language Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1))
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: lang.locale.languageCode,
                                      dropdownColor: const Color(0xFF0F172A),
                                      icon: const Icon(Icons.language, color: Colors.white, size: 20),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          lang.setLanguage(newValue);
                                        }
                                      },
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'en',
                                            child: Text("Eng", style: TextStyle(color: Colors.white, fontSize: 13))),
                                        DropdownMenuItem(
                                            value: 'hi',
                                            child: Text("हिंदी", style: TextStyle(color: Colors.white, fontSize: 13))),
                                        DropdownMenuItem(
                                            value: 'mr',
                                            child: Text("मराठी", style: TextStyle(color: Colors.white, fontSize: 13))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(height: 32),
                        // Dynamic Health Score Card
                        ListenableBuilder(
                          listenable: HistoryService(),
                          builder: (context, child) {
                            final score = HistoryService().calculateHealthScore();
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 64,
                                    width: 64,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            height: 64,
                                            width: 64,
                                            child: CircularProgressIndicator(
                                              value: score / 100,
                                              strokeWidth: 6,
                                              backgroundColor: Colors.white24,
                                              valueColor: AlwaysStoppedAnimation(
                                                  score > 70 ? Colors.greenAccent : (score > 40 ? Colors.orangeAccent : Colors.redAccent)),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text("$score%",
                                              style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(lang.t('health_score'),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20)),
                                        const SizedBox(height: 4),
                                        Text(
                                            score == 100 
                                              ? lang.t('health_good') 
                                              : (score > 70 ? "Checks pass. Stay alert." : "Action Needed: Check Notices!"),
                                            style: TextStyle(
                                                color: Colors.white.withOpacity(0.8),
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1.5 Pending Setup Notification
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final gstin = data['gstin'] ?? "";
                          if (gstin.isNotEmpty) return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade800),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Setup Pending",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    Text(
                                      "Please fill in your business details in Profile.",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // This is a bit tricky since we are in a tab, but for now just show a message 
                                  // or we could use the wrapper state to switch tabs if we had a controller.
                                  // For simplicity, we'll just advise them to go to Profile.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Go to Profile tab to complete setup")),
                                  );
                                },
                                child: Text("FILL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    Text(lang.t('quick_actions'),
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Grid Actions
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            title: lang.t('scan_invoice'),
                            icon: Icons.document_scanner_outlined,
                            color: Color(0xFF2979FF),
                            onTap: () => _handleScan(false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionTile(
                            title: lang.t('check_notice'),
                            icon: Icons.warning_amber_rounded,
                            color: Color(0xFFFF9100),
                            onTap: () => _handleScan(true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            title: lang.t('supplier_check'),
                            icon: Icons.shield_outlined,
                            color: Color(0xFF00BFA5),
                            onTap: () => _navigateWithMotion(
                                const SupplierCheckScreen()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionTile(
                            title: lang.t('expense_manager'),
                            icon: Icons.account_balance_wallet_outlined,
                            color: Color(0xFF3D5AFE),
                            onTap: () =>
                                _navigateWithMotion(const ExpensesScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Upcoming Deadlines Section
                    Text("Upcoming Deadlines", // You might want to localize this
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ListenableBuilder(
                        listenable: HistoryService(),
                        builder: (context, child) {
                          final deadlines = HistoryService().getUpcomingDeadlines();
                          return Row(
                            children: deadlines.map((d) => _DeadlineCard(
                              date: d['date'],
                              month: d['month'],
                              title: d['title'],
                              status: d['status'],
                              isUrgent: d['isUrgent'],
                            )).toList(),
                          );
                        }
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Stream (Connected to History)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang.t('recent_activity'),
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(lang.t('view_all'),
                            style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ListenableBuilder(
                      listenable: HistoryService(),
                      builder: (context, child) {
                        final invoices = HistoryService().invoices;
                        if (invoices.isEmpty) {
                           // Fallback to dummy data if empty
                           return Column(children: const [
                             _ActivityItem(
                                title: "Rent Invoice #902",
                                time: "Sample",
                                amount: "₹12,000",
                                isCredit: false,
                             ),
                             _ActivityItem(
                                title: "ITC Claimed",
                                time: "Sample",
                                amount: "+ ₹4,500",
                                isCredit: true,
                             ),
                           ]);
                        }
                        
                        return Column(
                          children: invoices.map((inv) {
                             // Safe extraction of data
                             final details = inv.containsKey('data') ? inv['data'] : inv;
                             final summary = details['invoiceDetails'] ?? {};
                             final vendor = details['vendor'] ?? {};
                             
                             return _ActivityItem(
                                title: vendor['name'] ?? "Invoice",
                                time: "Just now",
                                amount: "₹${summary['totalAmount'] ?? 0}",
                                isCredit: false,
                             );
                          }).toList(),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScaleCard(
      onTap: onTap,
      child: Container(
        height: 112, // Multiple of 8 (14 * 8)
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          // Shadows are handled by HoverScaleCard
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassIcon(
              icon: icon,
              color: color,
              size: 48,
              iconSize: 24,
            ),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String date;
  final String month;
  final String title;
  final String status;
  final bool isUrgent;

  const _DeadlineCard(
      {required this.date,
      required this.month,
      required this.title,
      required this.status,
      this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144, // Multiple of 8 (18 * 8)
      margin: const EdgeInsets.only(right: 16), // Fixed to 16px (8pt grid)
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFF4F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent
            ? Border.all(color: Colors.red.shade100)
            : Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(date,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.red : Colors.black)),
              const SizedBox(width: 4),
              Text(month,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(status,
              style: TextStyle(
                  fontSize: 12, color: isUrgent ? Colors.red : Colors.green)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final String amount;
  final bool isCredit;

  const _ActivityItem(
      {required this.title,
      required this.time,
      required this.amount,
      required this.isCredit});

  @override
  Widget build(BuildContext context) {
    return HoverScaleCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Fixed to 16px (8pt grid)
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Shadows handled by HoverScaleCard
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long,
                      size: 20, color: Colors.black54),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(time,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
