import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/models/playlist_model.dart';
import '../config.dart'; 

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ==================== BAGIAN LAGU (SONGS) ====================

  Future<void> addSong(SongModel song) async {
    try {
      String relativeImagePath = song.albumArtPath.replaceFirst(Config.baseUrl, "");
      String relativeAudioPath = song.songUrlPath.replaceFirst(Config.baseUrl, "");

      SongModel songToSave = SongModel(
        title: song.title,
        artist: song.artist,
        albumArtPath: relativeImagePath, 
        songUrlPath: relativeAudioPath,   
        uploadedBy: song.uploadedBy,
        likedBy: [],
      );

      await _db.collection('songs').add(songToSave.toMap());
    } catch (e) {
      throw Exception("Gagal simpan data: $e");
    }
  }

  Stream<List<SongModel>> getSongs() {
    return _db.collection('songs').orderBy('uploaded_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SongModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteSong(String songId) async {
    await _db.collection('songs').doc(songId).delete();
  }
  
  Future<void> updateSong(String songId, String newTitle, String newArtist) async {
    await _db.collection('songs').doc(songId).update({'title': newTitle, 'artist': newArtist});
  }

  Future<void> toggleLike(String songId, String userId, bool isCurrentlyLiked) async {
    final docRef = _db.collection('songs').doc(songId);
    if (isCurrentlyLiked) {
      await docRef.update({'liked_by': FieldValue.arrayRemove([userId])});
    } else {
      await docRef.update({'liked_by': FieldValue.arrayUnion([userId])});
    }
  }

  // ==================== BAGIAN PLAYLIST ====================

  // 1. Buat Playlist Baru
  Future<void> createPlaylist(String name, String userId) async {
    PlaylistModel newPlaylist = PlaylistModel(
      name: name,
      creatorId: userId,
      songIds: [], 
    );
    await _db.collection('playlists').add(newPlaylist.toMap());
  }

  // 2. Ambil Daftar Playlist Milik User (SUDAH DIPERBAIKI)
  Stream<List<PlaylistModel>> getUserPlaylists(String userId) {
    return _db.collection('playlists')
        .where('creator_id', isEqualTo: userId)
        // --- CATATAN PENTING ---
        // Baris di bawah ini saya matikan (//) agar loading tidak macet.
        // Jika Anda ingin mengaktifkannya lagi, Anda WAJIB membuat Index di Firebase Console.
        // .orderBy('created_at', descending: true) 
        // -----------------------
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PlaylistModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // 3. Tambah Lagu ke Playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _db.collection('playlists').doc(playlistId).update({
      'song_ids': FieldValue.arrayUnion([songId])
    });
  }
}