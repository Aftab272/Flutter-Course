# Implementation Plan - QR Attendance System

Complete production-grade Flutter Android application with Supabase backend, role-based dashboards (Admin, Teacher, Student), QR Attendance with short-lived tokens, SQLite offline queue, Google Drive backup/restore, CSV/PDF reports, and Material 3 responsive UI.

## User Review Required

- **Supabase & Google Drive Credentials**: The app uses placeholder environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, Google Client ID). Users will need to configure their Supabase project and Google Cloud Console OAuth client.
- **Roles & RLS**: Strict Row Level Security (RLS) policies will be enforced on Supabase for Admin, Teacher, and Student roles.

## Proposed Changes

### 1. Backend & SQL Schema (`supabase/migrations/`)
- Complete SQL schema for users/profiles, institutions, classes, subjects, enrollments, teacher_assignments, attendance_sessions, attendance_records, audit_logs.
- Supabase RLS policies and secure server functions for attendance validation and token checking.

### 2. Core Models & Services (`lib/models/`, `lib/services/`)
- **Models**: Profile, ClassModel, SubjectModel, AttendanceSession, AttendanceRecord, AuditLog, OfflineQueueItem.
- **Services**:
  - `SupabaseService`: Client wrapper and auth.
  - `DatabaseService`: CRUD operations for classes, sessions, attendance.
  - `OfflineQueueService`: SQLite (`sqflite`) storage for offline attendance scanning and sync.
  - `GoogleDriveService`: OAuth Google Drive backup and restore with checksum & validation.
  - `ExportService`: CSV and PDF report generation.

### 3. State Management & Routing (`lib/providers/`, `lib/router/`)
- Riverpod state providers for Auth, Theme, Sessions, Attendance, Offline Sync, Drive Backup.
- GoRouter navigation with role-based redirection (Admin, Teacher, Student).

### 4. UI & Theming (`lib/ui/`)
- Material 3 theme with blue, sky-blue, and white palette, light/dark mode support.
- Screens for Auth (Login, Register), Admin Dashboard & Management, Teacher Dashboard & QR Generator/Session Manager, Student Dashboard & QR Scanner, Profile, Offline Queue, Google Drive Backup & Restore, Reports & Analytics.

### 5. Documentation (`README.md`)
- Comprehensive setup guide, Supabase migration instructions, RLS rules, Google Drive OAuth setup, test and release APK build instructions.

## Verification Plan

### Automated Tests
- Run `flutter test` for core logic and unit tests.
### Manual Verification
- Verify app compilation via `flutter build apk --debug`.
- Test role navigation, QR scanning simulation, offline queue sync, and export features.
