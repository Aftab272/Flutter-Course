# My Medical History 🏥

**Your Medical Records, Organized.**

My Medical History is a personal healthcare record management application designed to help users securely store, manage, search, and organize their medical history in one place.

Built with **Flutter and Dart**, the app allows users to maintain doctor profiles, record medical visits, save diagnoses and prescriptions, upload medical reports, store hospital locations, and synchronize their records with Google Drive.

## 📱 Project Overview

Keeping track of medical records can be difficult when prescriptions, test reports, and doctor information are scattered across different files and folders.

My Medical History provides a centralized digital solution where users can manage their medical information and access previous records whenever needed.

## ✨ Features

### 1. Dashboard
web application/stitch/projects/17169650880731722365/screens/e9cc8e7bf55a43078c1d9b9d6ef88153<img width="375" height="1600" alt="image" src="https://github.com/user-attachments/assets/fa567168-9024-4f48-ac62-73d8f3347c9f" />

* View total doctors, medical visits, medicines, and reports.
* Access recent medical visits.
* View upcoming follow-up dates.
* Quickly add a new medical visit.

### 2. Doctor Management
web application/stitch/projects/17169650880731722365/screens/fc7b6c9730254b7892948885a69b0fd5web application/stitch/projects/17169650880731722365/screens/fc7b6c9730254b7892948885a69b0fd5<img width="396" height="1600" alt="image" src="https://github.com/user-attachments/assets/bf967cfe-2b3c-4f13-b299-745ec97fbd77" />
<img width="396" height="1600" alt="image" src="https://github.com/user-attachments/assets/75e128e7-0a56-4741-9f28-7a03253e4e98" />

* Add and edit doctor profiles.
* Store doctor names, specializations, phone numbers, and photographs.
* Save hospital and clinic information.
* View all visits associated with a particular doctor.
* Reuse existing doctor profiles for future visits.

### 3. Medical Visit History
web application/stitch/projects/17169650880731722365/screens/3d9f202e26934626b11102198cbf9fcc<img width="345" height="1600" alt="image" src="https://github.com/user-attachments/assets/03cbc9f7-19e5-42e9-bf70-ad655f8d1a70" />

* Record the date and time of each visit.
* Save symptoms, diagnosis, and doctor's notes.
* Maintain multiple visits under the same doctor.
* Edit existing records without unnecessarily replacing previous visits.
* Organize medical records chronologically.

### 4. Medicine Management
web application/stitch/projects/17169650880731722365/screens/f1d64cfd05df44c5979f335c263f1ec7<img width="445" height="1600" alt="image" src="https://github.com/user-attachments/assets/2b22f89d-2c89-42c5-adbc-637720d6375a" />

* Record prescribed medicine names.
* Store dosage, frequency, and duration.
* Save before-meal or after-meal instructions.
* View medicines prescribed during previous visits.
* Search historical medicine records.

### 5. Medical Tests and Reports
web application/stitch/projects/17169650880731722365/screens/ebd1249558224d6faecf194673bd410c<img width="598" height="1600" alt="image" src="https://github.com/user-attachments/assets/fd541dfe-daca-4f87-9b94-8d16d996b07c" />

* Record test names, dates, and results.
* Attach laboratory reports and medical documents.
* Support PDF and image attachments.
* View reports associated with specific medical visits.

### 6. Prescription Management

* Capture prescription photographs.
* Upload prescription images or PDFs.
* Preview saved documents.
* Replace or remove attachments when needed.

### 7. Hospital and Location Management
web application/stitch/projects/17169650880731722365/screens/939dcb520f974e0aa81aa6668ea4e450<img width="320" height="1600" alt="image" src="https://github.com/user-attachments/assets/c64df90e-b03d-4291-b802-508e10718c9c" />

* Save hospital or clinic names and addresses.
* Store geographical coordinates.
* Select a location using a map.
* Use GPS to identify the current location.
* Open saved locations in Google Maps.

### 8. Search and Filters

Search medical records using:

* Doctor name
* Hospital or clinic
* Medicine name
* Diagnosis
* Symptoms
* Test name
* Visit date

Filter records by date range, doctor, hospital, diagnosis, medicines, and tests.

### 9. Google Drive Backup and Synchronization

* Connect a Google account.
* Back up medical records and attachments to Google Drive.
* Provide manual synchronization.
* Support automatic synchronization when implemented.
* Display the last synchronization time and status.
* Restore backed-up records when supported.

### 10. Privacy and Security

* Provide app-lock functionality.
* Support PIN and biometric authentication where implemented.
* Protect sensitive medical records.
* Clearly communicate backup and data-storage behavior.

## 🛠️ Technology Stack

| Technology       | Purpose                                   |
| ---------------- | ----------------------------------------- |
| Flutter          | Cross-platform mobile UI                  |
| Dart             | Application programming language          |
| SQLite           | Local database and offline record storage |
| Google Sign-In   | Google account authentication             |
| Google Drive API | Cloud backup and synchronization          |
| Google Maps      | Hospital location visualization           |
| Geolocation      | GPS coordinates and current location      |
| Camera / Gallery | Capture and select photos                 |
| PDF/Image Viewer | View medical documents                    |

*The listed technologies describe the planned architecture. Actual implementation depends on the packages and services configured in the project.*

## 🗂️ Main Application Modules

The application is organized around the following modules:

1. Authentication and user profile
2. Dashboard
3. Doctor management
4. Hospital management
5. Medical visit records
6. Medicine management
7. Tests and reports
8. Prescription attachments
9. Search and filtering
10. Google Drive backup and synchronization
11. Settings and security

## 🔄 Application Workflow

1. The user opens the application.
2. The user signs in with Google, if authentication is enabled.
3. The user configures Google Drive backup, if desired.
4. The user creates a doctor profile or selects an existing doctor.
5. The user adds a medical visit with the diagnosis, medicines, tests, and prescription.
6. The application saves the visit in the local database.
7. The user can review, edit, search, and filter saved records.
8. When synchronization is configured and available, the application backs up the relevant data to Google Drive.

**Important:** A doctor profile and a medical visit are separate records. A single doctor can have multiple visits, each with its own diagnosis, medicines, reports, and date.

## 💾 Offline Support

The application is designed to support local medical record storage so users can access previously saved records without an internet connection.

Cloud synchronization requires an internet connection. Features that depend on Google Drive, online maps, or other online services may be unavailable offline.

## 🔐 Data Privacy

Medical records contain sensitive personal information. The application should use appropriate authentication, secure local storage, protected file handling, and carefully configured Google Drive permissions.

Users should be informed about what data is stored locally and what data is uploaded to their Google account.

The application is intended for recordkeeping and does not replace professional medical advice, diagnosis, or treatment.

## 🚀 Getting Started

### Prerequisites

Install the following tools:

* Flutter SDK
* Dart SDK (included with Flutter)
* Android Studio
* Android SDK and an Android emulator or physical device
* Git (optional)

### Installation

**Step 1: Clone the repository**

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

**Step 2: Open the project**

```bash
cd your_project_folder
```

**Step 3: Install dependencies**

```bash
flutter pub get
```

**Step 4: Check your Flutter setup**

```bash
flutter doctor
```

**Step 5: Run the application**

```bash
flutter run
```

Replace the repository URL and project folder name with your actual values.

## ⚙️ Google Drive Configuration

To enable Google Drive integration:

1. Create or select a project in Google Cloud Console.
2. Configure the OAuth consent screen.
3. Configure the required Android OAuth client credentials.
4. Enable the Google Drive API.
5. Configure the necessary authentication and Drive permissions.
6. Implement authorized file upload, download, backup, and synchronization.
7. Test account permissions and backup restoration.

Use the narrowest appropriate Drive permissions. For an application that manages its own backup files, consider the `drive.file` scope where it meets the application's requirements.

Google Sign-In alone does not automatically provide permission to read or write Google Drive files.

## 🧪 Testing

Recommended tests include:

* Adding and editing doctor profiles.
* Saving multiple visits under one doctor.
* Searching by medicine and diagnosis.
* Applying multiple filters.
* Uploading prescriptions and test reports.
* Accessing saved records offline.
* Synchronizing records with Google Drive.
* Restoring a backup.
* Testing invalid inputs and interrupted synchronization.
* Verifying access controls and data privacy.

## 🔮 Future Enhancements

* Medical visit reminders.
* Medication reminders.
* Improved encrypted backups.
* Export medical history to PDF.
* Family member medical profiles.
* Advanced health record analytics.
* Multilingual interface, including English and Urdu.
* Improved conflict resolution for multi-device synchronization.

## 🎓 Project Purpose

This project can be developed as a Flutter academic project and expanded into a practical personal medical record management application.

It demonstrates mobile UI/UX design, CRUD operations, data relationships, local persistence, file handling, authentication, cloud integration, and search functionality.

## 📄 License

Choose an appropriate open-source or private-project license before distributing the application.

---

**My Medical History — Your health records, all in one place.**
