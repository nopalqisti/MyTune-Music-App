import 'package:flutter/material.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/models/playlist_model.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/services/auth_service.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final String songId; // ID lagu yang mau dimasukkan

  const AddToPlaylistSheet({super.key, required this.songId});

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
          decoration: const InputDecoration(
            hintText: "Nama Playlist",
            hintStyle: TextStyle(color: kGreyColor),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kGreyColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: kGreyColor)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Buat", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final userId = AuthService().currentUser?.uid;
                if (userId != null) {
                  // 1. Buat Playlist
                  await FirestoreService().createPlaylist(controller.text.trim(), userId);
                  // (Opsional) Langsung masukkan lagu ke playlist baru? 
                  // Untuk sekarang kita tutup dulu dialognya biar user pilih manual di list
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
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return const SizedBox();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.only(top: 16, bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Tambahkan ke Playlist", style: TextStyle(color: kWhiteColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Tombol Buat Playlist Baru
          ListTile(
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: kPrimaryColor),
            ),
            title: const Text("Playlist Baru", style: TextStyle(color: kWhiteColor)),
            onTap: () => _showCreatePlaylistDialog(context),
          ),
          const Divider(color: kSurfaceColor),

          // Daftar Playlist yang Sudah Ada
          Flexible(
            child: StreamBuilder<List<PlaylistModel>>(
              stream: FirestoreService().getUserPlaylists(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                
                final playlists = snapshot.data!;
                if (playlists.isEmpty) return const SizedBox(); // Gak ada playlist

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.music_note, color: kGreyColor),
                      ),
                      title: Text(playlist.name, style: const TextStyle(color: kWhiteColor)),
                      subtitle: Text("${playlist.songIds.length} Lagu", style: const TextStyle(color: kGreyColor, fontSize: 12)),
                      onTap: () async {
                        // Tambahkan lagu ke playlist ini
                        await FirestoreService().addSongToPlaylist(playlist.id, songId);
                        if (context.mounted) {
                          Navigator.pop(context); // Tutup Bottom Sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Ditambahkan ke ${playlist.name}")),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}