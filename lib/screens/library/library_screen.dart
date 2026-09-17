import 'package:flutter/material.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/widgets/song_tile.dart';
import 'package:provider/provider.dart';
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/screens/player/player_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KITA UBAH JADI 3 TAB
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          title: const Text("Koleksi Kamu"),
          bottom: const TabBar(
            indicatorColor: kPrimaryColor,
            labelColor: kPrimaryColor,
            unselectedLabelColor: kGreyColor,
            isScrollable: true, // Agar tab bisa digeser jika layar sempit
            tabs: [
              Tab(text: "Lagu Saya"), 
              Tab(text: "Disukai"),   // Tab Liked Songs KEMBALI ADA
              Tab(text: "Playlist"),   
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyUploadsTab(),
            _LikedSongsTab(), // Widget Liked Songs KEMBALI ADA
            _PlaylistsTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- TAB 1: LAGU UPLOAD SAYA ----------------
class _MyUploadsTab extends StatelessWidget {
  const _MyUploadsTab();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = AuthService().currentUser?.uid ?? "";

    return StreamBuilder<List<SongModel>>(
      stream: FirestoreService().getSongs(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        if (!snapshot.hasData) return const SizedBox();

        final mySongs = snapshot.data!.where((s) => s.uploadedBy == currentUserId).toList();

        if (mySongs.isEmpty) return const Center(child: Text("Kamu belum mengupload lagu.", style: TextStyle(color: kGreyColor)));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mySongs.length,
          itemBuilder: (context, index) {
            final song = mySongs[index];
            return SongTile(
              song: song,
              onTap: () {
                Provider.of<AudioProvider>(context, listen: false).playPlaylist(mySongs, index);
                Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => const PlayerScreen()));
              },
            );
          },
        );
      },
    );
  }
}

// ---------------- TAB 2: LAGU YANG DISUKAI (DIKEMBALIKAN) ----------------
class _LikedSongsTab extends StatelessWidget {
  const _LikedSongsTab();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = AuthService().currentUser?.uid ?? "";

    return StreamBuilder<List<SongModel>>(
      stream: FirestoreService().getSongs(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        if (!snapshot.hasData) return const SizedBox();

        // Filter lagu yang di array 'likedBy' ada ID saya
        final likedSongs = snapshot.data!.where((s) => s.likedBy.contains(currentUserId)).toList();

        if (likedSongs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 60, color: kGreyColor),
                const SizedBox(height: 16),
                const Text("Belum ada lagu disukai.", style: TextStyle(color: kGreyColor)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: likedSongs.length,
          itemBuilder: (context, index) {
            final song = likedSongs[index];
            return SongTile(
              song: song,
              onTap: () {
                Provider.of<AudioProvider>(context, listen: false).playPlaylist(likedSongs, index);
                Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => const PlayerScreen()));
              },
            );
          },
        );
      },
    );
  }
}

// ---------------- TAB 3: DAFTAR PLAYLIST ----------------
class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        title: const Text("Playlist Baru", style: TextStyle(color: kWhiteColor)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: kWhiteColor),
          autofocus: true,
          decoration: const InputDecoration(hintText: "Nama Playlist", hintStyle: TextStyle(color: kGreyColor)),
        ),
        actions: [
          TextButton(child: const Text("Batal", style: TextStyle(color: kGreyColor)), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Buat", style: TextStyle(color: kPrimaryColor)),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final userId = AuthService().currentUser?.uid;
                if (userId != null) {
                  await FirestoreService().createPlaylist(controller.text.trim(), userId);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = AuthService().currentUser?.uid ?? "";

    return Stack(
      children: [
        StreamBuilder<List<PlaylistModel>>(
          stream: FirestoreService().getUserPlaylists(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            
            final playlists = snapshot.data ?? [];

            if (playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.queue_music, size: 60, color: kGreyColor),
                    const SizedBox(height: 16),
                    const Text("Belum ada playlist.", style: TextStyle(color: kGreyColor)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showCreatePlaylistDialog(context),
                      child: const Text("Buat Playlist Pertama", style: TextStyle(color: kPrimaryColor)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  leading: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.music_note, color: kPrimaryColor, size: 30),
                  ),
                  title: Text(playlist.name, style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
                  subtitle: Text("${playlist.songIds.length} Lagu", style: const TextStyle(color: kGreyColor)),
                  onTap: () {
                    // TODO: Nanti bisa ditambah fitur buka detail playlist
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Buka ${playlist.name}")));
                  },
                );
              },
            );
          },
        ),
        
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "btn_playlist", 
            backgroundColor: kSurfaceColor,
            onPressed: () => _showCreatePlaylistDialog(context),
            child: const Icon(Icons.add, color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}