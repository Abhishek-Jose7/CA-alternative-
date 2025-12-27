import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hover_scale_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: "Ravi Kirana Store");
  final TextEditingController _phoneController =
      TextEditingController(text: "+91 98765 43210");
  final TextEditingController _gstController =
      TextEditingController(text: "23ABCDE1234F1Z5");

  bool _isEditing = false;

  void _toggleEdit() {
    if (_isEditing) {
      // Save logic (Mock)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profile Updated!")));
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // 1. Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.2),
                              width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text("RK",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _toggleEdit,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isEditing ? Icons.check : Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _gstController.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Edit Profile / Save Changes Pill Button
                  InkWell(
                    onTap: _toggleEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isEditing ? AppTheme.primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _isEditing
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEditing ? Icons.check : Icons.edit_outlined,
                            size: 14,
                            color: _isEditing
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isEditing ? "Save Changes" : "Edit Profile",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _isEditing
                                    ? Colors.white
                                    : Colors.grey.shade800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Mini Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(label: "Invoices", value: "42"),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _MiniStat(label: "Plan", value: "Pro", isPremium: true),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _MiniStat(label: "Saved", value: "₹12k"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Account Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 12),
                    child: Text("ACCOUNT DETAILS",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2)),
                  ),
                  HoverScaleCard(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _AccountRow(
                            label: "Business Name",
                            controller: _nameController,
                            icon: Icons.store_outlined,
                            isEditing: _isEditing,
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          _AccountRow(
                            label: "Phone Number",
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            isEditing: _isEditing,
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          _AccountRow(
                            label: "GSTIN",
                            controller: _gstController,
                            icon: Icons.confirmation_number_outlined,
                            isEditing: _isEditing,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Settings Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 12),
                    child: Text("PREFERENCES",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2)),
                  ),
                  HoverScaleCard(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SettingsRow(
                            icon: Icons.language,
                            title: lang.t('language'),
                            trailing: Text(
                                lang.locale.languageCode.toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue)),
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          _SettingsRow(
                            icon: Icons.chat_bubble_outline,
                            title: lang.t('chat_settings'),
                            trailing: DropdownButton<String>(
                              value: lang.chatLocale.languageCode,
                              underline: Container(),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18, color: Colors.grey),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.w600),
                              items: const [
                                DropdownMenuItem(
                                    value: 'en', child: Text("English")),
                                DropdownMenuItem(
                                    value: 'hi', child: Text("Hinglish")),
                                DropdownMenuItem(
                                    value: 'mr', child: Text("Marathi")),
                              ],
                              onChanged: (val) {
                                if (val != null) lang.setChatLanguage(val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Support Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 12),
                    child: Text("SUPPORT",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2)),
                  ),
                  HoverScaleCard(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const _SettingsRow(
                            icon: Icons.help_outline,
                            title: "Help & Support",
                          ),
                          Divider(
                              height: 1,
                              color: Colors.grey.shade100,
                              indent: 60),
                          const _SettingsRow(
                            icon: Icons.logout,
                            title: "Logout",
                            isDestructive: true,
                            showChevron: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text("v1.0.0 (Hackathon Build)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isPremium;

  const _MiniStat(
      {required this.label, required this.value, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPremium ? AppTheme.primaryBlue : AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isEditing;

  const _AccountRow({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blueGrey.shade400, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                isEditing
                    ? Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: AppTheme.primaryBlue, width: 1)),
                        ),
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    : Text(controller.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool isDestructive;
  final bool showChevron;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.isDestructive = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.blueGrey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppTheme.textDark,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (showChevron && trailing == null)
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
