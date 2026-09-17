import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:music_app/providers/audio_provider.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/services/auth_service.dart'; // Import Auth
import 'package:music_app/services/firestore_service.dart'; // Import Firestore Service

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Widget Khusus Tombol Like yang Realtime
  Widget _buildLikeButton(String songId) {
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return const SizedBox(); // Hide jika belum login

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('songs').doc(songId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Icon(Icons.favorite_border, color: kGreyColor);
        }

        // Ambil data terbaru dari database
        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> likedBy = data['liked_by'] ?? [];
        bool isLiked = likedBy.contains(userId);

        return IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.redAccent : kWhiteColor,
            size: 30,
          ),
          onPressed: () {
            // Panggil fungsi toggleLike di service
            FirestoreService().toggleLike(songId, userId, isLiked);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final currentSong = provider.currentSong;

        if (currentSong == null) {
          return const Scaffold(
            backgroundColor: kBackgroundColor,
            body: Center(child: Text("Tidak ada lagu yang diputar", style: TextStyle(color: kWhiteColor))),
          );
        }

        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: kWhiteColor),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
            title: const Text("Now Playing", style: TextStyle(color: kWhiteColor)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Gambar Cover
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          currentSong.fullAlbumArtUrl,
                          fit: BoxFit.cover,
                          height: 300, width: 300,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 300, width: 300, color: kSurfaceColor,
                            child: const Icon(Icons.music_note, size: 100, color: kGreyColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Judul, Artis, dan tombol LIKE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     // Spacer kosong agar teks di tengah tetap rapi, tombol like di kanan
                     const SizedBox(width: 40), 
                     
                     Expanded(
                       child: Column(
                         children: [
                           Text(
                             currentSong.title,
                             style: const TextStyle(color: kWhiteColor, fontSize: 24, fontWeight: FontWeight.bold),
                             textAlign: TextAlign.center,
                             maxLines: 1, overflow: TextOverflow.ellipsis,
                           ),
                           const SizedBox(height: 8),
                           Text(
                             currentSong.artist,
                             style: const TextStyle(color: kGreyColor, fontSize: 18),
                             textAlign: TextAlign.center,
                           ),
                         ],
                       ),
                     ),

                     // TOMBOL LIKE REALTIME
                     _buildLikeButton(currentSong.id),
                  ],
                ),
                
                const SizedBox(height: 30),

                // 3. Slider & Waktu
                Column(
                  children: [
                    Slider(
                      min: 0,
                      max: provider.duration.inSeconds.toDouble(),
                      value: provider.position.inSeconds.toDouble().clamp(0.0, provider.duration.inSeconds.toDouble()),
                      onChanged: (value) {
                        provider.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: kPrimaryColor,
                      inactiveColor: kSurfaceColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(provider.position), style: const TextStyle(color: kGreyColor)),
                          Text(_formatDuration(provider.duration), style: const TextStyle(color: kGreyColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Tombol Kontrol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: provider.playPrevious,
                      icon: const Icon(Icons.skip_previous_rounded, color: kWhiteColor, size: 40),
                    ),
                    GestureDetector(
                      onTap: provider.togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
                        child: Icon(
                          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black, size: 50,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: provider.playNext,
                      icon: const Icon(Icons.skip_next_rounded, color: kWhiteColor, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}