import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:music_app/theme.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/screens/upload/upload_screen.dart';
import 'package:music_app/widgets/song_tile.dart'; 
import 'package:music_app/screens/player/player_screen.dart';
import 'package:music_app/providers/audio_provider.dart'; // Import AudioProvider
import 'package:music_app/screens/search/search_screen.dart'; // Import SearchScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kita butuh AuthService untuk mengecek data user saat ini
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // Ambil data user yang sedang login
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        // --- MODIFIKASI DI SINI: Foto Profil Asli ---
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kSurfaceColor,
            // Logika: Jika ada URL foto (dari Google), pakai NetworkImage.
            // Jika tidak ada, biarkan null (nanti diisi child Icon).
            backgroundImage: (currentUser?.photoURL != null)
                ? NetworkImage(currentUser!.photoURL!)
                : null,
            // Jika tidak ada foto, tampilkan Icon Person sebagai gantinya
            child: (currentUser?.photoURL == null)
                ? const Icon(Icons.person, color: kWhiteColor)
                : null,
          ),
        ),
        // --------------------------------------------

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nikmati lagu favoritmu,",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kGreyColor),
            ),
            // Tampilkan nama user jika ada, atau default "Music Lover"
            Text(
              currentUser?.displayName ?? "Music Lover", 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: kWhiteColor),
            onPressed: () {
              // Navigasi ke Halaman Pencarian
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      
      // BODY: Daftar Lagu
      body: StreamBuilder<List<SongModel>>(
        stream: _firestoreService.getSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_off_rounded, size: 80, color: kGreyColor),
                  SizedBox(height: 16),
                  Text("Belum ada lagu. Ayo upload!", style: TextStyle(color: kGreyColor, fontSize: 18)),
                ],
              ),
            );
          }

          // Data lengkap semua lagu
          List<SongModel> songs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              SongModel song = songs[index];
              return SongTile(
                song: song,
                onTap: () {
                  // 1. Panggil AudioProvider untuk memutar Playlist
                  Provider.of<AudioProvider>(context, listen: false).playPlaylist(songs, index);

                  // 2. Buka Halaman Player
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true, 
                      builder: (context) => const PlayerScreen(), 
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // Tombol Upload Melayang
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}