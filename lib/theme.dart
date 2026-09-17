import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Warna Utama
const Color kPrimaryColor = Color(0xFFFFD700); // Emas
const Color kBackgroundColor = Color(0xFF121212); // Hitam
const Color kSurfaceColor = Color(0xFF1E1E1E); // Abu Gelap
const Color kWhiteColor = Colors.white; // Putih
const Color kGreyColor = Colors.grey; // Abu-abu

// Definisi Tema Global
final ThemeData musicAppTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryColor,
    surface: kSurfaceColor,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 20),
    iconTheme: IconThemeData(color: kWhiteColor),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurfaceColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor)),
  ),
);