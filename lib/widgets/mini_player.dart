import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/screens/player/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  // Widget Like Kecil
  Widget _buildSmallLikeButton(String songId) {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('songs').doc(songId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> likedBy = data['liked_by'] ?? [];
        bool isLiked = likedBy.contains(userId);

        return IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? kPrimaryColor : kGreyColor, // Pakai warna Emas/Primary biar kontras
            size: 20,
          ),
          onPressed: () {
            FirestoreService().toggleLike(songId, userId, isLiked);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final song = audioProvider.currentSong;

        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const PlayerScreen(), 
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Gambar
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  child: Image.network(
                    song.fullAlbumArtUrl,
                    width: 65, height: 65, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(width: 65, height: 65, color: kGreyColor),
                  ),
                ),
                
                const SizedBox(width: 10),

                // 2. Judul & Artis
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                      const SizedBox(height: 2),
                      Text(song.artist, style: const TextStyle(color: kGreyColor, fontSize: 11), maxLines: 1),
                    ],
                  ),
                ),

                // 3. Tombol Like Kecil (Diselipkan di sini)
                _buildSmallLikeButton(song.id),

                // 4. Tombol Kontrol (Play & Next saja agar muat)
                IconButton(
                  onPressed: () => audioProvider.togglePlayPause(),
                  icon: Icon(
                    audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: kWhiteColor, size: 30
                  ),
                ),
                IconButton(
                  onPressed: () => audioProvider.playNext(),
                  icon: const Icon(Icons.skip_next_rounded, color: kWhiteColor, size: 28),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        );
      },
    );
  }
}