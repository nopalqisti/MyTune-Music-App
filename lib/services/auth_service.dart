import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign In

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instance Google Sign In

  // Getter user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Login Email & Password
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 2. Register Email & Password
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // 3. LOGIN GOOGLE (BARU)
  Future<User?> signInWithGoogle() async {
    try {
      // Memicu alur autentikasi Google (muncul popup pilih akun)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User membatalkan login
      }

      // Mendapatkan detail autentikasi dari request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Membuat kredensial baru
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Masuk ke Firebase dengan kredensial Google
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
      
    } catch (e) {
      print("Error Google Sign In: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Logout dari Google juga
    await _auth.signOut();
  }
}