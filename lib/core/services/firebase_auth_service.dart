import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk handle Firebase Authentication
///
/// Features:
/// - Email/Password authentication
/// - User session management
/// - Auto-sync user UID dengan local database
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user UID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register with email and password
  ///
  /// Returns: User credential if successful, null if failed
  Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Registration Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Registration Error: $e');
      return null;
    }
  }

  /// Sign in with email and password
  ///
  /// Returns: User credential if successful, null if failed
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Sign In Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password Reset Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Update user email (requires recent authentication)
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }
    } on FirebaseAuthException catch (e) {
      print('Update Email Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      print('Update Password Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Re-authenticate user (required before sensitive operations)
  Future<UserCredential?> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      return await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Re-authentication Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      print('Delete Account Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Get Firebase Auth error message in Bahasa
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan. Hubungi administrator.';
      case 'user-disabled':
        return 'Akun Anda telah dinonaktifkan.';
      case 'user-not-found':
        return 'User tidak ditemukan. Periksa email Anda.';
      case 'wrong-password':
        return 'Password salah. Coba lagi.';
      case 'invalid-credential':
        return 'Kredensial tidak valid. Periksa email dan password Anda.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'requires-recent-login':
        return 'Operasi memerlukan login ulang. Silakan login kembali.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
