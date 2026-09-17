import 'package:flutter/material.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Siapkan "Pelayan" (Controller)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Fungsi Daftar (Sign Up)
  void _handleRegister() async {
    // Validasi dasar
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data tidak boleh kosong!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // --- MODIFIKASI PENTING DI SINI ---
      // Gunakan parameter bernama (email: dan password:)
      await _authService.signUp(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
      );

      if (mounted) {
        // Kalau sukses, beri pesan sukses dan kembali
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: kPrimaryColor, content: Text("Akun Berhasil Dibuat! Silakan Login.")),
        );
        Navigator.pop(context); // Kembali ke layar Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Gagal Daftar: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar transparan agar ada tombol "Back" di kiri atas
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Buat Akun Baru",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kWhiteColor),
              ),
              const Text("Daftar untuk mulai mendengarkan", style: TextStyle(color: kGreyColor)),
              
              const SizedBox(height: 40),

              CustomTextField(
                hintText: "Alamat Email",
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              CustomTextField(
                hintText: "Buat Password",
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("REGISTER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}