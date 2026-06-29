# PLANTIVA Mobile App

PLANTIVA is a Flutter mobile application for banana leaf disease detection, scan history, crop analytics, treatment recommendations, and educational disease guide content.

The app uses Firebase Authentication, Cloud Firestore, Firebase Storage, and an offline TensorFlow Lite model.

## Features

- Email/password registration and login
- Google Sign-In
- Forgot password reset link
- User profile with contact number, location, and profile photo
- Camera scan and gallery upload
- Offline banana disease classification using TensorFlow Lite
- Scan validation for low-confidence, unclear, invalid, or unrelated images
- Recent scans with Firebase-backed image storage
- Scan details and treatment recommendations
- Analytics and crop wellness dashboard
- Disease guide with images, prevention tips, and educational links
- In-app alert settings, help center, and privacy/security options

## Supported Classes

- Banana Black Sigatoka Disease
- Banana Bract Mosaic Virus Disease
- Banana Healthy Leaf
- Banana Insect Pest Disease
- Banana Moko Disease
- Banana Panama Disease
- Banana Yellow Sigatoka Disease

## Setup

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase Requirements

Required Firebase files:

- `android/app/google-services.json`
- `lib/firebase_options.dart`

Firebase services used:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

For Google Sign-In on Android, configure SHA-1 and SHA-256 fingerprints in the Firebase Android app.

## Disclaimer

PLANTIVA provides AI-assisted disease detection and educational guidance. For severe or uncertain cases, users should consult an agriculture expert or local agriculture office.
