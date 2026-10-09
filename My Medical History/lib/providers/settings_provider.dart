import 'package:flutter/foundation.dart';
import '../services/biometric_service.dart';

class SettingsProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  bool appLockEnabled = false;
  bool isBiometricSupported = false;

  Future<void> loadSettings() async {
    appLockEnabled = await _biometricService.isAppLockEnabled();
    isBiometricSupported = await _biometricService.isBiometricAvailable();
    notifyListeners();
  }

  Future<void> setAppLock(bool enabled) async {
    await _biometricService.setAppLockEnabled(enabled);
    appLockEnabled = enabled;
    notifyListeners();
  }

  Future<bool> authenticate() async {
    return await _biometricService.authenticate();
  }
}
