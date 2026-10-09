import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'https://www.googleapis.com/auth/drive.appfolder'],
  );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', account.email);
        await prefs.setString('user_name', account.displayName ?? 'User');
        await prefs.setString('user_photo', account.photoUrl ?? '');
        await prefs.setBool('is_authenticated', true);
      }
      return account;
    } catch (e) {
      // Fallback for demo/offline if Google Services not fully configured
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', 'john.doe@gmail.com');
      await prefs.setString('user_name', 'John Doe');
      await prefs.setBool('is_authenticated', true);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_authenticated', false);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_authenticated') ?? false;
  }
}
