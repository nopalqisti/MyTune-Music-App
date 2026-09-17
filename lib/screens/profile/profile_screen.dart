import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final User? user = AuthService().currentUser; // Ambil user yg login

  // Controller untuk edit nama
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "User";
  }

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _updateProfile() async {
    if (user != null && _nameController.text.isNotEmpty) {
      try {
        await user!.updateDisplayName(_nameController.text.trim());
        await user!.reload(); // Refresh data user
        setState(() {
          _isEditing = false;
        });
        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil diperbarui!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: kBackgroundColor,
        actions: [
            // Tombol Logout di pojok kanan atas
            IconButton(
                onPressed: _handleLogout, 
                icon: const Icon(Icons.logout, color: Colors.redAccent)
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Foto Profil Besar
            const CircleAvatar(
              radius: 50,
              backgroundColor: kSurfaceColor,
              child: Icon(Icons.person, size: 50, color: kPrimaryColor),
            ),
            const SizedBox(height: 20),

            // 2. Email (Read Only)
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(color: kGreyColor, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // 3. Edit Nama / Username
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Username", style: TextStyle(color: kGreyColor)),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit, color: kPrimaryColor),
                        onPressed: () {
                          if (_isEditing) {
                            _updateProfile(); // Simpan
                          } else {
                            setState(() => _isEditing = true); // Masuk mode edit
                          }
                        },
                      )
                    ],
                  ),
                  _isEditing
                      ? TextField(
                          controller: _nameController,
                          style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 18),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
                          ),
                          autofocus: true,
                        )
                      : Text(
                          user?.displayName ?? "Belum ada nama",
                          style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}