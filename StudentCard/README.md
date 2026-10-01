# Student Digital ID Card & Campus Dashboard

A Flutter Mobile Application designed to display a student's Digital ID Card and Campus Dashboard.

This project focuses on UI design, widget usage, proper layout, alignment, spacing, and basic user interaction.

---

## Objective

The objective of this project is to develop a Flutter-based Student Digital ID Card and Campus Dashboard.

The application does not require any external backend, database, or API. All the student information and course data are used locally for demonstration purposes.

---

## Features

- Student Digital ID Card
- Student Profile
- Student Profile Picture
- Green Active/Online Status Indicator
- Student Name
- Roll Number
- Department
- Semester
- Current Semester Courses
- Scrollable Course List
- Quick Notes Section
- Text Input Field
- Submit Button
- Navigation Drawer
- Search Action Icon
- Clean and Responsive Mobile UI

---

## Functional & Widget Requirements

### 1. Header & Navigation

The application uses a `Scaffold` as the main screen structure.

An `AppBar` is used at the top of the application.

The AppBar contains:

- Application Title
- Drawer Menu Icon
- Search Action Icon

A `Drawer` widget is also included for student profile and navigation options.

---

### 2. Student Profile & Digital ID Card

A Digital ID Card is created using the `Card` widget.

A `Container` is used inside the card for styling and layout.

The student's profile picture is displayed using a `CircleAvatar`.

A green Active/Online status dot is displayed over the profile picture.

The `Stack` widget is used to overlay the green status indicator on the profile picture.

`Positioned` is used to correctly place the status dot.

---

### 3. Student Information & Alignment

The application displays the following student information:

- Student Name
- Roll Number
- Department
- Semester

`Column` and `Row` widgets are used to properly align the student information.

`Padding` is used to provide space around the content.

`SizedBox` is used to provide proper spacing between different UI elements.

---

### 4. Courses / Subjects List

The application displays the student's current semester enrolled courses.

The course list is created dynamically using `ListView.builder`.

Each course is displayed using a `ListTile`.

Example courses include:

- Web Engineering
- Software Engineering
- Computer Networks
- Artificial Intelligence
- Information Security

The course list is scrollable so that multiple subjects can be displayed.

---

### 5. Quick Notes / User Input

A Quick Note section is provided at the bottom of the dashboard.

A `TextField` is used to receive input from the user.

An `ElevatedButton` is provided to submit the entered note.

A `SnackBar` can be used to display a confirmation message after submitting the note.

---

## Flutter Widgets Used

The following Flutter widgets are used in this project:

```text
Scaffold
AppBar
Drawer
Card
Container
Stack
Positioned
CircleAvatar
Column
Row
Padding
SizedBox
ListView.builder
ListTile
TextField
ElevatedButton
SnackBar
Text
Icon
IconButton
Project Structure
student_dashboard/
│
├── lib/
│   └── main.dart
│
├── android/
├── ios/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
Requirements

To run this project, the following software is required:

Flutter SDK
Android Studio
Android SDK
Android device or Android Emulator
USB Debugging enabled when using a physical Android device
How to Run the Project
Step 1: Check Flutter Installation

Open the terminal and run:

flutter doctor
Step 2: Check Connected Devices

Run:

flutter devices
Step 3: Run the Application

To run the application on an Android device:

flutter run

Or specify a particular device:

flutter run -d DEVICE_ID

Example:

flutter run -d 1474040591000308
Testing Device

The application was tested on:

Device: Infinix X6728B
Operating System: Android 15
API Level: 35
Architecture: android-arm64
Connection: USB
Backend & API

This project does not use any external backend or API.

There is no requirement for:

Backend Server
Database
Firebase
REST API
Authentication Server

The project is mainly focused on Flutter UI development.

Learning Outcomes

Through this project, the following Flutter concepts were practiced:

Flutter project structure
Material Design
Scaffold
AppBar
Drawer Navigation
Card Design
Container Styling
CircleAvatar
Stack and Positioned
Row and Column
Padding and SizedBox
ListView.builder
ListTile
TextField
ElevatedButton
SnackBar
Basic UI interaction
Mobile responsive layout
Student Information
Name: Muhammad Aftab Akram
Program: BS Computer Science
Semester: 5th Semester
Department: Computer Science
Purpose

This project is developed for educational and academic purposes to demonstrate the implementation of a Student Digital ID Card and Campus Dashboard using Flutter.
