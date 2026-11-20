import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_attendance_system/core/widgets/status_badge.dart';
import 'package:qr_attendance_system/core/widgets/app_button.dart';
import 'package:qr_attendance_system/core/widgets/empty_state.dart';
import 'package:qr_attendance_system/models/app_models.dart';
import 'package:qr_attendance_system/services/export_service.dart';
import 'package:qr_attendance_system/services/google_drive_service.dart';

void main() {
  group('Core Widget Tests', () {
    testWidgets('StatusBadge renders correctly with appropriate status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: 'present',
              type: StatusType.success,
            ),
          ),
        ),
      );

      expect(find.text('PRESENT'), findsOneWidget);
    });

    testWidgets('AppButton shows label and triggers callback on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit Attendance',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Attendance'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton displays CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading Action',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Action'), findsNothing);
    });

    testWidgets('EmptyState displays title, message and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox_rounded,
              title: 'No Classes Found',
              message: 'Please add your first class.',
            ),
          ),
        ),
      );

      expect(find.text('No Classes Found'), findsOneWidget);
      expect(find.text('Please add your first class.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });
  });

  group('CSV Export & Security Tests', () {
    test('CSV export sanitizes formula injection vulnerabilities', () {
      final records = [
        AttendanceRecord(
          id: 'rec-1',
          sessionId: 'sess-1',
          studentId: '=cmd|’ /C calc’!A0', // Potential CSV formula injection
          scannedAt: DateTime.parse('2026-10-22T10:00:00Z'),
          status: 'present',
          isOfflineSynced: true,
        ),
      ];

      final csvString = ExportService.generateCsvReport(records: records);

      // Must be prefixed with single quote to neutralize formula execution in Excel/Sheets
      expect(csvString.contains("`=cmd|’ /C calc’!A0") || csvString.contains("'=cmd"), isTrue);
    });
  });

  group('Google Drive Backup & Integrity Tests', () {
    test('Checksum calculation and verification works accurately', () {
      final payload = {
        'institution_id': 'inst-123',
        'departments': [
          {'name': 'Computer Science', 'status': 'active'},
        ],
        'classes': [
          {'name': 'CS-A', 'section': 'Morning'},
        ],
      };

      final checksum = GoogleDriveService.calculateChecksum(payload);
      expect(checksum.isNotEmpty, isTrue);
      expect(checksum.length, 64); // SHA-256 is 64 hex characters

      final backupData = {
        'metadata': {
          'checksum': checksum,
          'schema_version': '1.0',
        },
        'payload': payload,
      };

      expect(GoogleDriveService.verifyChecksum(backupData), isTrue);

      // Verify corrupted payload is detected and rejected
      final corruptedData = {
        'metadata': {
          'checksum': checksum,
          'schema_version': '1.0',
        },
        'payload': {
          'institution_id': 'inst-tampered',
        },
      };

      expect(GoogleDriveService.verifyChecksum(corruptedData), isFalse);
    });
  });

  group('Model Serialization Tests', () {
    test('DepartmentModel serialization round-trip', () {
      final dept = DepartmentModel(
        id: 'dept-1',
        institutionId: 'inst-1',
        name: 'Electrical Engineering',
        status: 'active',
      );

      final json = dept.toJson();
      final revived = DepartmentModel.fromJson(json);

      expect(revived.id, 'dept-1');
      expect(revived.name, 'Electrical Engineering');
      expect(revived.status, 'active');
    });

    test('ClassModel serialization round-trip', () {
      final cls = ClassModel(
        id: 'cls-1',
        institutionId: 'inst-1',
        name: 'BSCS 8th',
        section: 'A',
        departmentId: 'dept-1',
        academicTermId: 'term-1',
      );

      final json = cls.toJson();
      final revived = ClassModel.fromJson(json);

      expect(revived.name, 'BSCS 8th');
      expect(revived.section, 'A');
      expect(revived.departmentId, 'dept-1');
    });
  });
}
