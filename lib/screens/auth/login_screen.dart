import 'package:flutter/material.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/widgets/custom_textfield.dart';
import 'package:music_app/screens/auth/register_screen.dart';
import 'package:music_app/screens/main_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Login Biasa
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password wajib diisi")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(email: _emailController.text.trim(), password: _passwordController.text.trim());
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Login Google
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Gagal Google Login: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note_rounded, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              Text("My Tune", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: kWhiteColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              CustomTextField(hintText: "Email", icon: Icons.email, controller: _emailController),
              CustomTextField(hintText: "Password", icon: Icons.lock, isPassword: true, controller: _passwordController),
              const SizedBox(height: 30),

              // Tombol Login Biasa
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 15),
              const Text("ATAU", style: TextStyle(color: kGreyColor, fontSize: 12)),
              const SizedBox(height: 15),

              // --- TOMBOL GOOGLE DENGAN ICON ASLI (MODIFIKASI DI SINI) ---
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kGreyColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: kSurfaceColor, // Sedikit background agar logo lebih pop
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Google Asli (Dari Internet)
                      Image.network(
                        "https://developers.google.com/identity/images/g-logo.png",
                        height: 24,
                        width: 24,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: kWhiteColor), // Fallback jika offline
                      ),
                      const SizedBox(width: 12),
                      const Text("Masuk dengan Google", style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // -----------------------------------------------------------

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun? ", style: TextStyle(color: kGreyColor)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text("Daftar", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}