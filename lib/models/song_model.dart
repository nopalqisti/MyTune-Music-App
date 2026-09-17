import 'package:cloud_firestore/cloud_firestore.dart';
import '../config.dart'; 

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String albumArtPath; 
  final String songUrlPath;  
  final String uploadedBy; 
  final DateTime? uploadedAt; 
  
  // --- FIELD BARU: Daftar User ID yang menyukai lagu ini ---
  final List<String> likedBy; 
  // ---------------------------------------------------------

  SongModel({
    this.id = '',
    required this.title,
    required this.artist,
    required this.albumArtPath, 
    required this.songUrlPath,
    required this.uploadedBy,
    this.uploadedAt,
    this.likedBy = const [], // Defaultnya kosong
  });

  String get fullAlbumArtUrl {
    if (albumArtPath.isEmpty || albumArtPath.startsWith('http')) {
      return albumArtPath;
    }
    return Config.baseUrl + albumArtPath;
  }

  String get fullSongUrl {
    if (songUrlPath.isEmpty || songUrlPath.startsWith('http')) {
      return songUrlPath;
    }
    return Config.baseUrl + songUrlPath;
  }

  factory SongModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SongModel(
      id: documentId,
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      albumArtPath: map['album_art'] ?? '', 
      songUrlPath: map['song_url'] ?? '',   
      uploadedBy: map['uploaded_by'] ?? '',
      uploadedAt: map['uploaded_at'] != null ? (map['uploaded_at'] as Timestamp).toDate() : null,
      
      // Ambil data like, jika null dianggap list kosong
      likedBy: List<String>.from(map['liked_by'] ?? []), 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album_art': albumArtPath, 
      'song_url': songUrlPath,   
      'uploaded_by': uploadedBy,
      'uploaded_at': FieldValue.serverTimestamp(),
      
      // Simpan data like ke database
      'liked_by': likedBy, 
    };
  }
}