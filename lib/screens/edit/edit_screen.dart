import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import 'package:music_app/services/firestore_service.dart';
import 'package:music_app/theme.dart';
import 'package:music_app/widgets/custom_textfield.dart';

class EditScreen extends StatefulWidget {
  // Menerima data lagu yang ingin diedit
  final SongModel song;

  const EditScreen({super.key, required this.song});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Controller untuk input text
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // --- PENTING: Isi controller dengan data lama saat halaman dibuka ---
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani proses Simpan Perubahan
  void _handleUpdate() async {
    // Validasi sederhana
    if (_titleController.text.trim().isEmpty || _artistController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Judul dan Artis tidak boleh kosong.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil service untuk update data di Firestore
      await FirestoreService().updateSong(
        widget.song.id, // ID Lagu
        _titleController.text.trim(), // Judul Baru
        _artistController.text.trim(), // Artis Baru
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: kPrimaryColor, content: Text("Perubahan berhasil disimpan!")),
        );
        Navigator.pop(context); // Kembali ke Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("Gagal update: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Info Lagu"),
      ),
      // Stack untuk loading overlay
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan gambar cover (read-only, tidak bisa diedit)
                Center(
                  child: Container(
                    height: 150, width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.song.fullAlbumArtUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: kSurfaceColor, child: const Icon(Icons.music_note, color: kGreyColor)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "(Gambar dan File Audio tidak dapat diubah)",
                    style: TextStyle(color: kGreyColor, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 30),

                // Form Edit Judul & Artis
                CustomTextField(
                  hintText: "Judul Lagu",
                  icon: Icons.title,
                  controller: _titleController,
                ),
                CustomTextField(
                  hintText: "Artist",
                  icon: Icons.person_outline,
                  controller: _artistController,
                ),
                const SizedBox(height: 40),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
            ),
        ],
      ),
    );
  }
}