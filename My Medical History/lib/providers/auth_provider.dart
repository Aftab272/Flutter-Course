import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isAuthenticated = false;
  bool isLoading = false;
  String userName = 'John Doe';
  String userEmail = 'john.doe@gmail.com';
  String userPhoto = '';

  Future<void> checkAuthStatus() async {
    isLoading = true;
    notifyListeners();
    isAuthenticated = await _authService.isAuthenticated();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
      isAuthenticated = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    isAuthenticated = false;
    notifyListeners();
  }
}
