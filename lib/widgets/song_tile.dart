import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/services/firestore_service.dart'; 
import 'package:music_app/screens/edit/edit_screen.dart'; 
import 'package:music_app/widgets/add_to_playlist_sheet.dart'; // IMPORT INI

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  // Fungsi Konfirmasi Hapus (Biarkan seperti sebelumnya)
  void _showDeleteConfirmation(BuildContext context) {
      // ... (Kode sama seperti sebelumnya) ...
      showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kSurfaceColor,
          title: const Text("Hapus Lagu?", style: TextStyle(color: kWhiteColor)),
          content: Text("Anda yakin ingin menghapus lagu '${song.title}'?", style: TextStyle(color: kGreyColor)),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: kGreyColor)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await FirestoreService().deleteSong(song.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lagu berhasil dihapus.")),
                    );
                  }
                } catch (e) {
                   // error handle
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        
        leading: Hero(
          tag: 'album_art_${song.id}', // Tag Unik (Hapus jika animasi bentrok)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.fullAlbumArtUrl, 
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 60, height: 60, color: kGreyColor.withOpacity(0.3),
                  child: const Icon(Icons.music_note, color: kGreyColor),
              ),
            ),
          ),
        ),
        
        title: Text(song.title, style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(song.artist, style: const TextStyle(color: kGreyColor, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: kGreyColor),
          color: kBackgroundColor, 
          onSelected: (String value) {
            if (value == 'playlist') {
              // --- TAMPILKAN BOTTOM SHEET ---
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent, // Agar rounded corner terlihat
                builder: (context) => AddToPlaylistSheet(songId: song.id),
              );
            } else if (value == 'edit') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditScreen(song: song)));
            } else if (value == 'delete') {
              _showDeleteConfirmation(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            // MENU BARU: ADD TO PLAYLIST
            const PopupMenuItem<String>(
              value: 'playlist',
              child: Row(
                children: [
                  Icon(Icons.playlist_add, color: kWhiteColor, size: 20),
                  SizedBox(width: 12),
                  Text('Add to Playlist', style: TextStyle(color: kWhiteColor)),
                ],
              ),
            ),
            const PopupMenuDivider(), // Garis pemisah
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: kGreyColor, size: 20),
                  SizedBox(width: 12),
                  Text('Edit', style: TextStyle(color: kWhiteColor)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),

        onTap: onTap,
      ),
    );
  }
}