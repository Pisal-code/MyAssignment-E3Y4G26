import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_shop/screens/login_screen.dart'; // Make sure path matches your project

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 25),

            const Text("Account",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildSettingsGroup([
              const _SettingsTile(icon: Icons.person_outline, title: "Manage Profile"),
              const _SettingsTile(icon: Icons.lock_outline, title: "Password & Security"),
              const _SettingsTile(icon: Icons.translate, title: "Language", trailing: "English"),
            ]),

            const SizedBox(height: 25),

            const Text("About us",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildSettingsGroup([
              const _SettingsTile(icon: Icons.chat_bubble_outline, title: "Feedback"),
              const _SettingsTile(icon: Icons.description_outlined, title: "Terms and Conditions"),
              const _SettingsTile(icon: Icons.verified_user_outlined, title: "Policies"),
            ]),

            const SizedBox(height: 25),

            _buildSettingsGroup([
              _SettingsTile(
                icon: Icons.logout,
                title: "Log out",
                isDestructive: true,
                onTap: () async {
                  // Firebase logout
                  await FirebaseAuth.instance.signOut();
                  // Navigate to login screen and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(),
      builder: (context, snapshot) {
        String name = "";
        String email = user?.email ?? "";
        String photoUrl = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "";
          photoUrl = data['profileUrl'] ?? "";
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: photoUrl.isNotEmpty
                    ? AssetImage(photoUrl)
                    : const AssetImage("assets/user/profile.jpeg") as ImageProvider,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_note_outlined,
                    color: Colors.grey, size: 28),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black,
        ),
      ),
      trailing: trailing != null
          ? Text(trailing!, style: const TextStyle(color: Colors.grey))
          : null,
      onTap: onTap ?? () {},
    );
  }
}