import 'dart:io'; // Untuk menangani File fisik
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Pilih MP3
import 'package:image_picker/image_picker.dart'; // Pilih Gambar
import 'package:firebase_auth/firebase_auth.dart';

// Import file-file buatan kita sendiri
import 'package:music_app/theme.dart';
import 'package:music_app/widgets/custom_textfield.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/auth_service.dart';
import 'package:music_app/services/storage_service.dart';
import 'package:music_app/services/firestore_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // --- 1. VARIABEL STATE ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  
  File? _selectedImage; // Menyimpan file gambar yang dipilih user
  File? _selectedAudio; // Menyimpan file audio yang dipilih user
  String? _audioFileName; // Nama file audionya (untuk ditampilkan di UI)
  
  bool _isLoading = false; // Status loading saat upload

  // Siapkan Service-service yang diperlukan
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // --- 2. FUNGSI PILIH GAMBAR (Image Picker) ---
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path); // Simpan path gambarnya
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error pilih gambar: $e")));
    }
  }

  // --- 3. FUNGSI PILIH MP3 (File Picker) ---
  Future<void> _pickAudio() async {
    try {
      // Membuka file picker khusus untuk file AUDIO
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio, 
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAudio = File(result.files.single.path!); // Simpan path MP3
          _audioFileName = result.files.single.name; // Simpan nama filenya
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error pilih audio: $e")));
    }
  }

  // --- 4. FUNGSI UPLOAD UTAMA (Jantungnya Halaman Ini) ---
  void _handleUpload() async {
    print("TOMBOL UPLOAD DITEKAN");
    // Validasi: Pastikan semua data sudah diisi
    if (_titleController.text.isEmpty || _artistController.text.isEmpty || _selectedImage == null || _selectedAudio == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Mohon lengkapi semua data (Gambar & Audio wajib)!")),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai Loading

    try {
      // A. Dapatkan ID user yang sedang login (si pengupload)
      User? currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception("User tidak terdeteksi, silakan login ulang.");

      print("Sedang mengupload gambar..."); // Debugging log
      // B. Upload Gambar Cover ke Server PHP -> Dapat URL Localhost
      String imageUrl = await _storageService.uploadFileToPHP(_selectedImage!);
      print("Sukses upload gambar. URL: $imageUrl");

      print("Sedang mengupload audio..."); // Debugging log
      // C. Upload File MP3 ke Server PHP -> Dapat URL Localhost
      String audioUrl = await _storageService.uploadFileToPHP(_selectedAudio!);
      print("Sukses upload audio. URL: $audioUrl");

      // --- BAGIAN INI YANG DIPERBAIKI ---
      // D. Bungkus semua data jadi objek SongModel
      SongModel newSong = SongModel(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        // Perbaiki nama parameter sesuai model baru (albumArtPath, songUrlPath)
        albumArtPath: imageUrl, 
        songUrlPath: audioUrl,  
        uploadedBy: currentUser.uid, // ID User
        // uploadedAt akan diisi otomatis oleh server di fungsi toMap() model
      );

      // E. Simpan data SongModel ke Firestore Database
      // Fungsi addSong sekarang menerima satu objek SongModel utuh
      await _firestoreService.addSong(newSong);
      // -----------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: kPrimaryColor, content: Text("Lagu Berhasil Diupload!")),
        );
        Navigator.pop(context); // Tutup halaman upload, kembali ke Home
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Gagal Upload: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop Loading
    }
  }

  // --- 5. TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Lagu barumu!"),
      ),
      // Stack digunakan agar loading indicator bisa muncul di atas semua konten
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- AREA PILIH GAMBAR COVER ---
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kSurfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGreyColor.withValues(alpha: 0.5)),
                      // Jika gambar sudah dipilih, tampilkan sebagai background
                      image: _selectedImage != null 
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null
                    ),
                    // Jika belum pilih gambar, tampilkan ikon kamera
                    child: _selectedImage == null 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 50, color: kPrimaryColor),
                            SizedBox(height: 10),
                            Text("Tap untuk pilih Album Cover", style: TextStyle(color: kGreyColor)),
                          ],
                        )
                      : null,
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- INPUT TEXT ---
                CustomTextField(hintText: "Judul Lagu", icon: Icons.title, controller: _titleController),
                CustomTextField(hintText: "Artist", icon: Icons.person_outline, controller: _artistController),

                const SizedBox(height: 20),

                // --- AREA PILIH FILE MP3 ---
                const Text("Audio File", style: TextStyle(fontWeight: FontWeight.bold, color: kGreyColor)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickAudio,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kPrimaryColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.audio_file_rounded, color: kPrimaryColor, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          // Tampilkan nama file jika sudah dipilih, atau teks petunjuk
                          child: Text(
                            _audioFileName ?? "Tap Untuk memilih MP3 file",
                            style: TextStyle(
                              color: _audioFileName != null ? kWhiteColor : kGreyColor,
                              fontWeight: _audioFileName != null ? FontWeight.bold : FontWeight.normal
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedAudio != null) const Icon(Icons.check_circle, color: kPrimaryColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- TOMBOL UPLOAD ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpload, // Matikan tombol saat loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("UPLOAD KE CLOUD", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          // --- LOADING OVERLAY ---
          // Jika sedang loading, tampilkan layar hitam transparan + spinner
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimaryColor),
                    SizedBox(height: 20),
                    Text("Mengupload... mohon tunggu sebentar", style: TextStyle(color: kWhiteColor)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}