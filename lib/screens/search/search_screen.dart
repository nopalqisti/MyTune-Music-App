import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/widgets/song_tile.dart';
import 'package:music_app/widgets/custom_textfield.dart'; // Pastikan widget ini ada
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/screens/player/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: kWhiteColor),
          autofocus: true, // Langsung fokus keyboard saat dibuka
          decoration: InputDecoration(
            hintText: "Cari judul lagu atau artis...",
            hintStyle: const TextStyle(color: kGreyColor),
            border: InputBorder.none,
            icon: const Icon(Icons.search, color: kGreyColor),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: kGreyColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = "");
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _query = value.toLowerCase();
            });
          },
        ),
      ),
      body: StreamBuilder<List<SongModel>>(
        stream: FirestoreService().getSongs(), // Ambil semua lagu
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada data lagu.", style: TextStyle(color: kGreyColor)));
          }

          List<SongModel> allSongs = snapshot.data!;
          
          // --- LOGIKA FILTER PENCARIAN ---
          List<SongModel> filteredSongs = allSongs.where((song) {
            final titleLower = song.title.toLowerCase();
            final artistLower = song.artist.toLowerCase();
            return titleLower.contains(_query) || artistLower.contains(_query);
          }).toList();

          if (filteredSongs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 60, color: kGreyColor),
                  const SizedBox(height: 10),
                  Text("Tidak ditemukan hasil untuk '$_query'", style: const TextStyle(color: kGreyColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
              return SongTile(
                song: song,
                onTap: () {
                  // Putar lagu hasil pencarian
                  // Catatan: Kita kirim filteredSongs sebagai playlist agar user bisa next/prev di hasil pencarian
                  Provider.of<AudioProvider>(context, listen: false).playPlaylist(filteredSongs, index);
                  
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
    );
  }
}