import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/app_providers.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _torchOn = false;
  bool _frontCamera = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleToken(String token) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await _scannerController.stop();

    try {
      final user = ref.read(authUserProvider);
      final db = ref.read(databaseServiceProvider);
      if (user == null) {
        _showResultDialog('Authentication Required', 'Please log in to record attendance.', false);
        return;
      }

      // Check connectivity (Part N - Offline Mode)
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        final queueService = ref.read(offlineQueueServiceProvider);
        await queueService.queueAttendance(
          id: const Uuid().v4(),
          sessionId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          studentId: user.id,
          qrToken: token,
          scannedAt: DateTime.now().toUtc(),
        );
        _showResultDialog(
          'Saved Offline',
          'No internet connection detected. Attendance scan queued locally in SQLite database and marked as Pending Sync.',
          true,
          isPendingSync: true,
        );
        return;
      }

      // Online: Call secure database marking
      final result = await db.markAttendance(
        qrToken: token,
        studentId: user.id,
      );

      if (!mounted) return;
      final bool success = result['success'] == true;
      final String? status = result['status'];
      final String message = result['message'] ?? 'Attendance processed';

      String title;
      if (success) {
        title = status == 'late' ? 'Marked Late' : 'Marked Present!';
      } else {
        title = 'Attendance Not Recorded';
      }

      _showResultDialog(
        title,
        message,
        success,
        isLate: status == 'late',
      );
    } catch (e) {
      if (!mounted) return;
      _showResultDialog('Attendance Error', 'Failed to submit attendance: $e', false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(String title, String message, bool success, {bool isLate = false, bool isPendingSync = false}) {
    IconData icon;
    Color iconColor;
    Color headerBg;

    if (isPendingSync) {
      icon = Icons.cloud_upload_outlined;
      iconColor = AppColors.skyBlue;
      headerBg = AppColors.skyBlueLight;
    } else if (success) {
      if (isLate) {
        icon = Icons.access_time_filled_rounded;
        iconColor = AppColors.warningDark;
        headerBg = AppColors.warningLight;
      } else {
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.successDark;
        headerBg = AppColors.successLight;
      }
    } else {
      icon = Icons.error_outline_rounded;
      iconColor = AppColors.errorDark;
      headerBg = AppColors.errorLight;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'OK',
              onPressed: () {
                Navigator.pop(dialogCtx);
                context.pop();
              },
              variant: success ? AppButtonVariant.primary : AppButtonVariant.outlined,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Attendance QR'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Toggle Flash',
            onPressed: () async {
              await _scannerController.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: Icon(_frontCamera ? Icons.camera_front : Icons.camera_rear),
            tooltip: 'Switch Camera',
            onPressed: () async {
              await _scannerController.switchCamera();
              setState(() => _frontCamera = !_frontCamera);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleToken(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Viewfinder Frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.skyBlueAccent, width: 3.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.royalBlue.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
          // Instruction Overlay Card
          Positioned(
            bottom: 36,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black.withValues(alpha: 0.75),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: AppColors.skyBlueAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Align the teacher’s dynamic QR code inside the viewfinder to record attendance.',
                        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
