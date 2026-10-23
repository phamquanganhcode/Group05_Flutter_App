import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream theo dõi trạng thái đăng nhập
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Lấy thông tin người dùng hiện tại
  static User? get currentUser => _auth.currentUser;

  static bool _isLoading = false;

  /// Đăng nhập bằng tài khoản Google (Tự động thích ứng Web và Mobile)
  static Future<UserCredential?> signInWithGoogle() async {
    if (_isLoading) return null;
    _isLoading = true;
    try {
      if (kIsWeb) {
        // NỀN TẢNG WEB: Sử dụng Google Auth Provider popup trực tiếp từ Firebase
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // NỀN TẢNG ANDROID / IOS: Sử dụng GoogleSignIn native qua SHA-1 và google-services.json
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // Người dùng hủy bỏ

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'cancelled-popup-request' ||
          e.code == 'popup-closed-by-user') {
        print('Popup cancelled or closed by user: ${e.code}');
        return null;
      }
      print('Lỗi FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Đăng xuất khỏi hệ thống
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
    }
  }
}
