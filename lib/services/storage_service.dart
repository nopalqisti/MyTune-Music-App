import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // Import file konfigurasi IP kita

class StorageService {
  // Kita gunakan URL dari file config.dart
  final String _uploadUrl = Config.uploadUrl;

  // Fungsi baru untuk upload file ke Server Lokal (PHP)
  // Menerima: File fisik
  // Mengembalikan: URL Lokal file tersebut (String)
  Future<String> uploadFileToPHP(File file) async {
    try {
      print("Memulai upload ke: $_uploadUrl"); // Debugging

      // 1. Buat request Multipart (standar untuk kirim file)
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // 2. Tambahkan file ke dalam request dengan nama field 'file' (sesuai di PHP)
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // 3. Kirim request ke server dan tunggu responnya
      var streamedResponse = await request.send();

      // 4. Baca respon server
      var response = await http.Response.fromStream(streamedResponse);

      print("Status Code Server: ${response.statusCode}"); // Debugging
      print("Respon Server: ${response.body}"); // Debugging

      // 5. Cek hasilnya
      if (response.statusCode == 200) {
        // Ubah respon JSON string menjadi Map/Object Dart
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // Jika PHP bilang sukses, kembalikan URL lokalnya
          return jsonResponse['url'];
        } else {
          // Jika PHP bilang gagal (misal ekstensi salah)
          throw Exception("PHP Upload Error: ${jsonResponse['message']}");
        }
      } else {
        // Jika servernya sendiri error (misal 404 Not Found atau 500 Internal Server Error)
        throw Exception("Server Error (Status ${response.statusCode}). Gagal terhubung ke script PHP.");
      }
    } catch (e) {
      // print("Error di StorageService: $e");
      rethrow; // Lempar error ke UI agar muncul Snackbar merah
    }
  }
}