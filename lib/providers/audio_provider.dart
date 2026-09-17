import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/config.dart';

// Class ini adalah "Otak" musik global kita.
// Ia turunan dari ChangeNotifier, artinya ia bisa memberi tahu UI jika ada data yang berubah.
class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // --- STATE VARIABLES (Data yang dipantau) ---
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  List<SongModel> _playlist = []; // Daftar lagu yang sedang aktif
  int _currentIndex = -1;         // Lagu nomor berapa yang sedang diputar

  // --- GETTERS (Cara UI mengambil data) ---
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;

  // Getter pintar untuk mendapatkan lagu yang sedang aktif saat ini
  SongModel? get currentSong {
    if (_currentIndex != -1 && _playlist.isNotEmpty && _currentIndex < _playlist.length) {
      return _playlist[_currentIndex];
    }
    return null;
  }

  // --- CONSTRUCTOR (Dipanggil sekali saat aplikasi mulai) ---
  AudioProvider() {
    _setupListeners();
  }

  void _setupListeners() {
    // Mendengarkan total durasi lagu
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners(); // Beri tahu UI ada perubahan!
    });

    // Mendengarkan posisi detik berjalan
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners(); // Beri tahu UI ada perubahan!
    });

    // Mendengarkan kalau lagu selesai -> Otomatis Next
    _audioPlayer.onPlayerComplete.listen((event) {
      playNext();
    });
  }

  // --- MAIN METHODS (Fungsi-fungsi Kontrol) ---

  // 1. Fungsi untuk memulai playlist baru dari Home Screen
  Future<void> playPlaylist(List<SongModel> songs, int initialIndex) async {
    _playlist = songs;
    _currentIndex = initialIndex;
    notifyListeners(); // Update UI agar tahu playlist berubah
    await _playCurrentSong();
  }

  // Fungsi internal untuk memutar lagu berdasarkan _currentIndex
  Future<void> _playCurrentSong() async {
    if (currentSong == null) return;

    try {
      await _audioPlayer.stop(); // Stop lagu sebelumnya
      // Gunakan getter pintar fullSongUrl dari model
      await _audioPlayer.play(UrlSource(currentSong!.fullSongUrl));
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print("Error playing audio global: $e");
      _isPlaying = false;
      notifyListeners();
    }
  }

  // 2. Play / Pause Toggle
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    } else {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
    notifyListeners();
  }

  // 3. Seek (Geser Slider)
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // 4. Play Next
  void playNext() {
    if (_playlist.isEmpty) return;
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0; // Looping ke awal
    }
    _playCurrentSong();
    notifyListeners();
  }

  // 5. Play Previous
  void playPrevious() {
    if (_playlist.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1; // Looping ke akhir
    }
    _playCurrentSong();
    notifyListeners();
  }

  // PENTING: Matikan player saat aplikasi benar-benar ditutup (opsional tapi bagus)
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}