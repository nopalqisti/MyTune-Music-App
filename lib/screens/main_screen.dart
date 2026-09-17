import 'package:flutter/material.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/widgets/mini_player.dart';

// Import halaman-halaman baru
import 'package:music_app/screens/home/home_screen.dart';
import 'package:music_app/screens/library/library_screen.dart';
import 'package:music_app/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  // Daftar Halaman SUDAH UPDATE
  final List<Widget> _pages = [
    const HomeScreen(),     // 0
    const LibraryScreen(),  // 1
    const ProfileScreen(),  // 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80), 
            child: _pages[_selectedIndex],
          ),
          const Positioned(
            left: 0, right: 0, bottom: 0,
            child: MiniPlayer(), 
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kSurfaceColor,
        selectedItemColor: kPrimaryColor, 
        unselectedItemColor: kGreyColor,  
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Tambahkan ini agar stabil
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}