# QR Attendance System — Technical Architecture Document

Developer/Publisher: **Creative Stack Agency**  
Tagline: **Smart Attendance. Simple & Secure.**

---

## 1. High-Level Architecture Overview

```
                               +-----------------------------+
                               |     Flutter Client App      |
                               | (Material 3 + Riverpod 3.x) |
                               +--------------+--------------+
                                              |
               +------------------------------+-----------------------------+
               |                                                            |
               v                                                            v
+-------------------------------+                            +-------------------------------+
|  Supabase Auth & PostgreSQL   |                            |   Offline & Cloud Sync Hub    |
| - Row Level Security (RLS)    |                            | - SQLite Queue (sqflite)      |
| - Server-Side RPC Functions   |                            | - Reactive Connectivity Sync  |
| - Audit Logging & Webhooks    |                            | - Google Drive API (OAuth 2.0)|
+-------------------------------+                            +-------------------------------+
```

The system implements a layered clean architecture:
1. **Presentation Layer**: Material 3 Design System, Riverpod state notifiers, responsive scaffold for mobile/tablet.
2. **Business Logic Layer**: QR token rotation, countdown timers, role-based route guards, CSV/PDF export processors.
3. **Data Access Layer**: Supabase PostgreSQL client, SQLite offline cache, Google Drive REST client.

---

## 2. Design System Tokens (Part C)

- **Color Palette**:
  - `navyDark` (`#0F172A`): Primary headings and navigation surfaces.
  - `royalBlue` (`#1D4ED8`): Primary action buttons and selected states.
  - `skyBlue` (`#0EA5E9`): Secondary accents, progress rings, and information chips.
  - `bgLight` (`#F8FAFC`) / `bgDark` (`#0B0F19`): Background surfaces.
  - Semantic Status Colors: `success` (`#10B981`), `warning` (`#F59E0B`), `error` (`#EF4444`).
- **Typography**: Inter/Roboto styled Material 3 typography (`h1`, `h2`, `h3`, `body`, `caption`).
- **Theme Persistence**: Riverpod `themeModeProvider` stored in `SharedPreferences`.
- **Localization**: English and Urdu strings toggleable via `localeProvider`.

---

## 3. Database Schema & Row-Level Security (RLS) (Part J & K)

All tables strictly enforce PostgreSQL Row-Level Security:
- **`institutions`**: Multi-tenant institutional configuration.
- **`profiles`**: User metadata extending `auth.users` with `role` (`admin`, `teacher`, `student`) and `student_id_number`.
- **`departments` & `academic_terms`**: Organizational taxonomy.
- **`classes` & `subjects`**: Academic offerings and course codes.
- **`enrollments` & `teacher_assignments`**: Many-to-many relationship mappings.
- **`attendance_sessions`**: Teacher-generated active sessions with expiration timestamp, token hash, and late threshold.
- **`attendance_records`**: Student scan entries with composite unique constraint `(session_id, student_id)` to prevent duplicate marking.
- **`backup_history`**: Audit trail of manual and cloud database backups.
- **`audit_logs`**: Tamper-evident ledger of administrative actions.

### Server-Side RPC Function
```sql
mark_attendance_secure(p_qr_token, p_student_id, p_offline_timestamp)
```
- Compares against server UTC clock.
- Enforces validity duration and marks as `present` or `late` based on `late_threshold_minutes`.
- Prevents client-side clock manipulation.

---

## 4. Offline Attendance & Reactive Sync Engine (Part N)

```
[Student Scans QR]
        |
   Is Online?
  /          \
Yes           No
 |             |
Send to RPC   Insert into SQLite `attendance_queue.db`
               |
      [Network Restored via connectivity_plus]
               |
      Auto-Sync Worker Iterates Over Queue
               |
      Calls `mark_attendance_secure`
        /             \
   Success           Failure
      |                 |
Remove from SQLite   Mark Status 'failed' & Log Reason
```

---

## 5. Google Drive Backup & Restore Module (Part L)

- **Least-Privilege OAuth Scope**: `https://www.googleapis.com/auth/drive.file`.
- **Format**: Structured JSON snapshot containing `metadata` (timestamp, app_version, schema_version, record_counts, SHA-256 checksum) and `payload` (all academic tables).
- **Target Folder**: `QR_Attendance_Backups` in user's root Google Drive.
- **Restore Engine**:
  1. Downloads and parses JSON.
  2. Computes SHA-256 hash of payload and compares against metadata checksum.
  3. Displays confirmation dialog with record counts preview.
  4. Supports **Merge & Update (Safe)** or **Complete Overwrite**.
