import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import 'notice_result_screen.dart';
import 'invoice_result_screen.dart';
import 'supplier_check_screen.dart';
import 'add_expense_screen.dart';

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
        response = await _api.decodeNotice(pickedFile);
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
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lang.t('app_title'),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text("${lang.t('hello')} Ravi",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18, // Reduced from 24
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            // Language Dropdown
                            DropdownButton<String>(
                              value: lang.locale.languageCode,
                              dropdownColor: const Color(0xFF0F172A),
                              icon: const Icon(Icons.language,
                                  color: Colors.white),
                              underline: Container(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  lang.setLanguage(newValue);
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                    value: 'en',
                                    child: Text("Eng",
                                        style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(
                                    value: 'hi',
                                    child: Text("हिंदी",
                                        style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(
                                    value: 'mr',
                                    child: Text("मराठी",
                                        style: TextStyle(color: Colors.white))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Health Score Card
                        Container(
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
                                height: 80,
                                width: 80,
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: SizedBox(
                                        height: 80,
                                        width: 80,
                                        child: CircularProgressIndicator(
                                          value: 0.85,
                                          strokeWidth: 8,
                                          backgroundColor: Colors.white24,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.greenAccent),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text("85%",
                                          style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  32)), // Increased from 20
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
                                            fontSize: 20)), // Increased from 16
                                    const SizedBox(height: 4),
                                    Text(lang.t('health_good'),
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                _navigateWithMotion(const AddExpenseScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity Stream (Simplified)
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
                    const _ActivityItem(
                      title: "Rent Invoice #902",
                      time: "2 hours ago",
                      amount: "₹12,000",
                      isCredit: false,
                    ),
                    const _ActivityItem(
                      title: "ITC Claimed",
                      time: "Yesterday",
                      amount: "+ ₹4,500",
                      isCredit: true,
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
