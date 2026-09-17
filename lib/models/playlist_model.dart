import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String creatorId;
  final List<String> songIds; // Menyimpan ID lagu-lagu yang ada di playlist
  final DateTime? createdAt;

  PlaylistModel({
    this.id = '',
    required this.name,
    required this.creatorId,
    this.songIds = const [],
    this.createdAt,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PlaylistModel(
      id: documentId,
      name: map['name'] ?? 'Untitled Playlist',
      creatorId: map['creator_id'] ?? '',
      songIds: List<String>.from(map['song_ids'] ?? []),
      createdAt: map['created_at'] != null ? (map['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creator_id': creatorId,
      'song_ids': songIds,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}