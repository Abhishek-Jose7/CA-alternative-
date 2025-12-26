import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Ravi Kirana Store");
  final TextEditingController _phoneController = TextEditingController(text: "+91 98765 43210");
  final TextEditingController _gstController = TextEditingController(text: "23ABCDE1234F1Z5");
  
  bool _isEditing = false;

  void _toggleEdit() {
    if (_isEditing) {
      // Save logic (Mock)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
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
            const SizedBox(height: 50),
            
            // Avatar Structure
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryBlue,
              child: Text("RK", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _buildEditableField("Business Name", _nameController, Icons.store),
                   const SizedBox(height: 16),
                   _buildEditableField("Phone", _phoneController, Icons.phone),
                   const SizedBox(height: 16),
                   _buildEditableField("GSTIN", _gstController, Icons.confirmation_number),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditing ? Colors.green : AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _isEditing ? "Save Changes" : "Edit Profile",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // Settings List
            _ProfileItem(title: lang.t('language'), icon: Icons.language, trailing: lang.locale.languageCode.toUpperCase()),
            
             // Chat Language Settings
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                child: Icon(Icons.chat_bubble_outline, color: Colors.purple.shade700, size: 20),
              ),
              title: Text(lang.t('chat_settings')),
              trailing: DropdownButton<String>(
                value: lang.chatLocale.languageCode,
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text("English")),
                  DropdownMenuItem(value: 'hi', child: Text("Hinglish/Hindi")),
                  DropdownMenuItem(value: 'mr', child: Text("Marathi")),
                ],
                onChanged: (val) {
                  if (val != null) lang.setChatLanguage(val);
                },
              ),
            ),

            _ProfileItem(icon: Icons.business, title: lang.t('business_details')),
            _ProfileItem(icon: Icons.subscriptions, title: "Subscription", trailing: "Free Plan"),
            _ProfileItem(icon: Icons.help_outline, title: "Help & Support"),
            _ProfileItem(icon: Icons.logout, title: "Logout", isDestructive: true),
            
            const SizedBox(height: 30),
            const Text("v1.0.0 (Hackathon Build)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: _isEditing ? const BorderSide(color: Colors.blue) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isDestructive;

  const _ProfileItem({required this.icon, required this.title, this.trailing, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.grey.shade700, size: 20),
      ),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black)),
      trailing: trailing != null 
        ? Text(trailing!, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
        : const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    );
  }
}
