# QR Attendance System

Developer/Publisher: **Creative Stack Agency**  
Tagline: **Smart Attendance. Simple & Secure.**

---

A complete, production-grade Flutter Android application for schools, colleges, and universities. Features secure role-based portals for Administrators, Faculty, and Students, short-lived QR code attendance with countdown timers, Supabase PostgreSQL backend with Row-Level Security (RLS), offline SQLite sync engine, Google Drive OAuth backup & restore with SHA-256 verification, and CSV/PDF reporting.

---

## Key Features Implemented

### 1. Role-Based Dashboards & Workflows
- **Administrator Portal**:
  - Live metric statistics (Total Classes, Subjects, Active Students, Faculty Members).
  - Complete CRUD modules for **Classes & Sections**, **Courses & Subjects**, **Departments**, **Academic Terms**, and **User Management** (Enrollment & Course Assignments).
  - Institutional Attendance Reports with multi-parameter filtering.
  - Google Drive Cloud Backup & Restore center.
  - Immutable Security Audit Logs.
- **Teacher / Faculty Portal**:
  - Dynamic QR session generation with real-time ticking countdown timer (`MM:SS`).
  - Configurable session validity slider (1–15 mins) and late threshold (1–30 mins).
  - Live polling attendance roster showing scanned students in real time.
  - Instant session termination and attendance exports.
- **Student Portal**:
  - High-performance QR Code camera scanner viewfinder with target reticle.
  - Distinct modal feedback (Present, Late, Expired, Already Marked, Offline Queued).
  - Real-time overall attendance percentage calculation and recent scan log.
  - Offline sync status monitor.

### 2. High-Performance Design System (Part C)
- Material 3 Design System conforming to strict institutional tokens:
  - Deep Navy Blue (`#0F172A`) for authoritative surfaces and headers.
  - Royal Blue (`#1D4ED8`) for primary buttons and interactive highlights.
  - Sky Blue (`#0EA5E9`) for accent tags and progress rings.
  - Emerald Green, Amber, and Red semantic status badges.
- Smooth Light & Dark mode switching with persistent user preference.
- English & Urdu bilingual localization support (`localeProvider`).

### 3. Enterprise Database & Security Architecture
- PostgreSQL Row-Level Security (RLS) policies enforcing multi-role boundaries.
- Server-side UTC-clock verified attendance RPC function (`mark_attendance_secure`).
- Public self-registration restricted strictly to Students; prevents privilege escalation to Admin.
- Password recovery email flow.

### 4. Offline Attendance & Reactive Sync Queue (Part N)
- Seamless offline attendance capture into encrypted local SQLite database (`attendance_queue.db`).
- Reactive background synchronization worker listening to `connectivity_plus` events.
- Manual "Sync Now" button with retry count tracking and failure details.

### 5. Google Drive Backup & Restore Module (Part L)
- Google OAuth 2.0 integration with least-privilege `drive.file` scope.
- Structured JSON snapshot containing institutional metadata, academic entities, and attendance records.
- SHA-256 cryptographic checksum calculation preventing corrupted file restorations.
- Dual-mode support: Syncs to Google Drive root folder `QR_Attendance_Backups` and local device storage.
- Interactive restore confirmation dialog with record counts and Merge vs. Overwrite options.

### 6. Reports & Security-Sanitized Exports (Part P & Q)
- Filterable attendance reporting by Class, Course, Status, and Date Range.
- Professional multi-page PDF generation via `pdf` & `printing` with summary cards and tabular roster.
- CSV export protected against CSV Formula Injection vulnerabilities (`=`, `+`, `-`, `@` escaped).

---

## Technology Stack

- **Framework**: Flutter 3.24+ / Dart 3.5+
- **State Management**: Flutter Riverpod 3.x (`Notifier`, `NotifierProvider`)
- **Navigation**: GoRouter 14+ declarative routing
- **Backend & Auth**: Supabase Flutter & PostgreSQL with RLS
- **Camera & QR**: `mobile_scanner`, `qr_flutter`
- **Offline Storage**: SQLite via `sqflite`
- **Cloud Backup**: `google_sign_in` & `googleapis` (Drive API v3)
- **Exports**: `csv`, `pdf`, `printing`
- **Testing**: `flutter_test` suite with 100% passing tests

---

## Verification & Quality Assurance

- **Static Analysis**: `flutter analyze` -> `No issues found! (0 errors, 0 warnings)`
- **Automated Tests**: `flutter test test/widget_test.dart` -> `8/8 tests passed`
  - Core Widget rendering (StatusBadge, AppButton, EmptyState)
  - CSV formula injection sanitization
  - SHA-256 backup checksum verification & corruption detection
  - Entity serialization round-trips

---

## Getting Started

Refer to [`SETUP_GUIDE.md`](file:///SETUP_GUIDE.md) for full instructions on configuring Supabase, Google Cloud OAuth, and building release artifacts.
