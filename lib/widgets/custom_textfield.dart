import 'package:flutter/material.dart';
import '../theme.dart'; // Panggil file tema untuk akses warna

class CustomTextField extends StatelessWidget {
  final String hintText; // Teks petunjuk (misal: "Email")
  final IconData icon;   // Ikon di sebelah kiri
  final bool isPassword; // Apakah ini password (teks jadi bintang2)?
  final TextEditingController controller; // Si "Pelayan" pencatat teks

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false, // Defaultnya bukan password
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10), // Jarak atas-bawah
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Fungsi menyembunyikan password
        style: const TextStyle(color: kWhiteColor), // Warna teks yang diketik
        
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kGreyColor), // Ikon abu-abu
          hintText: hintText,
          hintStyle: const TextStyle(color: kGreyColor),
          filled: true,
          fillColor: kSurfaceColor, // Warna latar kotak (Abu tua)
          
          // Garis pinggir melengkung (Border)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Hilangkan garis hitam default
          ),
        ),
      ),
    );
  }
}