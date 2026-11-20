# QR Attendance System — Complete Setup & Deployment Guide

Developer/Publisher: **Creative Stack Agency**  
Tagline: **Smart Attendance. Simple & Secure.**

---

## 1. Prerequisites

Ensure you have the following installed on your machine:
- **Flutter SDK**: 3.24.0 or higher (`flutter --version`)
- **Dart SDK**: 3.5.0 or higher
- **Android Studio / VS Code** with Flutter and Dart plugins
- **Android SDK & Build Tools** (Target SDK 34 / Android 14)
- **Supabase Account** ([supabase.com](https://supabase.com))
- **Google Cloud Console Account** ([console.cloud.google.com](https://console.cloud.google.com))

---

## 2. Supabase Backend Setup

### Step 1: Create a Supabase Project
1. Log in to [supabase.com](https://supabase.com) and create a new project.
2. Choose your region and set a secure database password.

### Step 2: Run Database Migrations
1. In the Supabase Dashboard, open the **SQL Editor**.
2. Run the migration script in:
   `supabase/migrations/001_initial_schema.sql`
3. Run the complete enterprise schema migration in:
   `supabase/migrations/002_complete_schema.sql`

This creates:
- `institutions`, `profiles`, `departments`, `academic_terms`
- `classes`, `subjects`, `enrollments`, `teacher_assignments`
- `attendance_sessions`, `attendance_records`, `backup_history`, `notifications`, `audit_logs`
- Row-Level Security (RLS) policies for Admin, Teacher, and Student roles
- Server-side PostgreSQL function `mark_attendance_secure`

### Step 3: Configure Supabase Credentials in App
Open [`lib/main.dart`](file:///lib/main.dart) and verify your URL and anon key:
```dart
await SupabaseService.initialize(
  url: 'https://ovzlcddhfsymryoyseuh.supabase.co',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## 3. Google Drive OAuth Backup Configuration (Part L)

The app uses least-privilege Google Drive access via `https://www.googleapis.com/auth/drive.file`.

### Step 1: Enable Google Drive API in Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com).
2. Create or select your project.
3. Navigate to **APIs & Services > Library**.
4. Search for **Google Drive API** and click **Enable**.

### Step 2: Configure OAuth Consent Screen
1. Go to **APIs & Services > OAuth consent screen**.
2. Select User Type: **External**.
3. Fill in App Name: `QR Attendance System`, User Support Email, and Developer Contact Email.
4. Add Scope: `https://www.googleapis.com/auth/drive.file`.

### Step 3: Create Android OAuth Client ID
1. Navigate to **APIs & Services > Credentials > Create Credentials > OAuth client ID**.
2. Select Application Type: **Android**.
3. Package Name: `com.creativestackagency.qrattendancesystem` (or your app ID in `android/app/build.gradle`).
4. Generate SHA-1 fingerprint from your debug keystore:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Paste the SHA-1 fingerprint and click **Create**.

> [!NOTE]
> Even if Google Drive OAuth is not configured during local development, the app automatically falls back to **Secure Local Storage Backups** with identical SHA-256 checksum verification and JSON snapshot formatting!

---

## 4. Building & Running the Application

### Get Dependencies
```bash
flutter pub get
```

### Run Static Analysis
```bash
flutter analyze
```
*(Should return: `No issues found!`)*

### Run Automated Test Suite
```bash
flutter test test/widget_test.dart
```
*(Runs widget tests, CSV formula injection sanitizer tests, SHA-256 backup checksum verification, and model tests)*

### Launch on Android Device / Emulator
```bash
flutter run
```

### Build Production Android APK / App Bundle
```bash
# APK
flutter build apk --release

# Android App Bundle (for Google Play Console)
flutter build appbundle --release
```

---

## 5. Default Roles & User Flows

1. **Student Registration**:
   - Register via app with Full Name, Email, Password, and Roll/Student ID Number.
   - Automatically assigned `student` role.
2. **Administrator Role**:
   - For security, `admin` and `teacher` roles cannot be registered through public self-signup.
   - Update user profile role in Supabase dashboard:
     ```sql
     UPDATE profiles SET role = 'admin' WHERE email = 'admin@example.com';
     UPDATE profiles SET role = 'teacher' WHERE email = 'teacher@example.com';
     ```
3. **Teacher Attendance Session**:
   - Log in as Teacher -> Select Subject and Class -> Configure Validity (1-15 min) and Late Threshold.
   - Tap "Start Session & Show QR".
   - Ticking countdown timer rotates token automatically.
4. **Student Scanning**:
   - Tap "Scan Attendance QR" -> Aim camera at Teacher's QR.
   - Automatic offline fallback if device is disconnected; queued in SQLite and synced automatically when online.
