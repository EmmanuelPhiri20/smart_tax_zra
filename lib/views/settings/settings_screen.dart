import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool fingerprintEnabled = false;

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changePhoneNumber() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Feature coming soon: Update phone number via Firebase."),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to permanently delete your account?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error deleting account: $e"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _toggleFingerprint(bool value) {
    setState(() => fingerprintEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fingerprintEnabled
              ? "Fingerprint authentication enabled."
              : "Fingerprint authentication disabled.",
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final phone = user?.phoneNumber ?? "Not linked";
    final email = user?.email ?? "No email";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF013A80),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("👤 Profile",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Phone: $phone", style: const TextStyle(fontSize: 14)),
                Text("Email: $email", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Options
          _settingsTile(Icons.edit, "Add / Edit Profile Details", Colors.blue,
              () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Feature coming soon."),
                  backgroundColor: Colors.blue),
            );
          }),
          _settingsTile(Icons.phone, "Change Phone Number", Colors.orange,
              _changePhoneNumber),
          _settingsTile(
              Icons.lock, "Change Password", Colors.indigo, _changePassword),

          SwitchListTile(
            value: fingerprintEnabled,
            onChanged: _toggleFingerprint,
            title: const Text("Enable Fingerprint Login"),
            secondary: const Icon(Icons.fingerprint, color: Colors.green),
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade400),
          const SizedBox(height: 10),

          // Delete Account
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text(
              "Delete Account",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
