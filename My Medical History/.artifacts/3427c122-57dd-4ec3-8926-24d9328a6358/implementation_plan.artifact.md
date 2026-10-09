# Implementation Plan - My Medical History Flutter App

A production-quality Flutter Android mobile application named **“My Medical History”**, adhering closely to the Google Stitch design guidelines, clean architecture, local persistent database, Google Sign-In, Google Drive backup/synchronization, secure local storage, biometrics, multi-step visit wizard, search, filters, reports preview, and offline capability.

## User Review Required

> [!IMPORTANT]
> - **Database**: Using `sqflite` for local persistent storage with foreign keys maintaining the exact relationship: User → Doctor → Multiple Visits → Medicines, Tests, Prescriptions, Attachments.
> - **Authentication & Sync**: Google Sign-In and Google Drive API integration for backup/synchronization.
> - **Security**: Local App PIN and Biometric authentication (`local_auth`) for secure medical data access.
> - **Location & Maps**: GPS location via `geolocator` and map selection/preview.
> - **File Handling**: Image and PDF picker/preview (`image_picker`, `file_picker`) with local file storage and Google Drive cloud syncing.

## Open Questions

None at this stage; requirements are fully detailed across all 50 points.

## Proposed Changes

### Dependencies & Setup
#### [MODIFY] [pubspec.yaml](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/pubspec.yaml)
- Add dependencies: `sqflite`, `path`, `provider`, `shared_preferences`, `google_sign_in`, `googleapis`, `http`, `local_auth`, `geolocator`, `geocoding`, `image_picker`, `file_picker`, `intl`, `uuid`, `pdf`, `open_file`.

---

### Core Architecture & Database
#### [NEW] [database_helper.dart](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/database/database_helper.dart)
- SQLite database initialization, tables (`users`, `doctors`, `hospitals`, `visits`, `medicines`, `tests`, `attachments`, `sync_logs`), and sample seed data (Dr. Ahmed Khan with sample visits, medicines, tests).

#### [NEW] [models](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/models/)
- Data models for `User`, `Doctor`, `Hospital`, `Visit`, `Medicine`, `Test`, `Attachment`, `Sync`.

#### [NEW] [repositories](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/repositories/)
- Repository classes (`UserRepository`, `DoctorRepository`, `HospitalRepository`, `VisitRepository`, `MedicineRepository`, `TestRepository`, `AttachmentRepository`, `SyncRepository`) for database CRUD operations.

#### [NEW] [services](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/services/)
- `AuthService` (Google Sign-In), `DriveService` (Google Drive backup/sync), `LocationService` (GPS/Map), `BiometricService` (PIN/Fingerprint), `ExportService`.

#### [NEW] [providers](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/providers/)
- State management providers (`AuthProvider`, `MedicalProvider`, `SyncProvider`, `SettingsProvider`, `FilterProvider`) using Provider.

---

### UI Screens & Navigation
#### [NEW] [screens](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/screens/)
- **Splash & Onboarding**: `splash_screen.dart`, `onboarding_screen.dart`
- **Authentication**: `login_screen.dart`, `drive_setup_screen.dart`
- **Home Dashboard**: `home_screen.dart` with stats grid, recent visits, recent doctors, upcoming follow-ups, and quick search.
- **Doctors Module**: `doctors_screen.dart`, `doctor_profile_screen.dart`, `add_edit_doctor_screen.dart`
- **Hospitals Module**: `hospitals_screen.dart`, `add_edit_hospital_screen.dart`
- **Medical Visit Wizard**: Multi-step flow (`add_visit_wizard.dart` covering Doctor selection, Location, Visit info, Medicines, Tests, Attachments, Review).
- **History & Timeline**: `history_screen.dart`, `visit_details_screen.dart`
- **Medicines Module**: `medicines_screen.dart`, `medicine_details_screen.dart`
- **Tests & Reports Module**: `tests_screen.dart`, `reports_screen.dart`, `report_preview_screen.dart`
- **Search & Filters**: `search_screen.dart`, `filter_bottom_sheet.dart`
- **Settings & Security**: `settings_screen.dart`, `backup_sync_screen.dart`, `profile_screen.dart`, `pin_lock_screen.dart`

---

### Theme & Widgets
#### [NEW] [core/theme](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/core/theme/app_theme.dart)
- Material 3 Healthcare Blue theme, typography, rounded cards, soft shadows, responsive layouts.
#### [NEW] [core/widgets](file:///C:/Users/ranaa/OneDrive/Documents/GitHub/Flutter Course/My Medical History/lib/core/widgets/)
- Reusable UI components: empty states, loading states, error states, custom buttons, cards, app bars.

## Verification Plan

### Automated Tests
- Flutter widget tests and unit tests for database helper and models.
- Run `flutter test`.

### Manual Verification
- Verify app launch, onboarding, Google Sign-In, Google Drive connection.
- Verify Doctor CRUD and multi-visit persistence (Dr. Ahmed Khan with multiple visits).
- Verify Visit Add Wizard, Medicines, Tests, Attachments (image/PDF preview).
- Verify Search, Filters, Reports, Timeline.
- Verify Security (PIN / Biometric lock), Backup & Sync, Export.
