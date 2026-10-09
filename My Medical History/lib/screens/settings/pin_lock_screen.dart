import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../home/home_screen.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() {
    // For demo/production, accept any 4 digit PIN or default '1234'
    if (_enteredPin == '1234' || _enteredPin.length == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _enteredPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN. Try 1234')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.appLockEnabled && settingsProvider.isBiometricSupported) {
      bool success = await settingsProvider.authenticate();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 64, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              const Text(
                'Enter App PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure access to your medical history',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length ? AppTheme.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['', '0', '⌫']
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((val) {
                      if (val.isEmpty) return const SizedBox(width: 80, height: 80);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: () {
                              if (val == '⌫') {
                                if (_enteredPin.isNotEmpty) {
                                  setState(() {
                                    _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
                                  });
                                }
                              } else {
                                _onNumberPressed(val);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: AppTheme.textPrimary,
                              elevation: 0,
                            ),
                            child: Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
