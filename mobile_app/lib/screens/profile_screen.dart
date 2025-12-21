import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text("RK", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text("Ravi Kirana Store", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("+91 98765 43210", style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 8),
            Chip(
              label: const Text("GSTIN: 23ABCDE1234F1Z5"),
              backgroundColor: Colors.grey.shade100,
            ),
            const SizedBox(height: 32),
            
            _ProfileItem(icon: Icons.language, title: "Language", trailing: "English"),
            _ProfileItem(icon: Icons.business, title: "Business Details"),
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
