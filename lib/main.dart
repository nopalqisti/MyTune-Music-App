import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; 
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/screens/auth/login_screen.dart';
import 'package:music_app/screens/home/home_screen.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/screens/main_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioProvider()),
      ],
      child: MaterialApp(
        title: 'MyTune Music',
        debugShowCheckedModeBanner: false,
        theme: musicAppTheme, // Menggunakan tema dari theme.dart
        home: StreamBuilder(
          stream: AuthService().authStateChanges, // Menggunakan getter baru
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }
            if (snapshot.hasData) {
              return const MainScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}