# Firebase setup for Smart Locket (production auth)

This app uses **Firebase Authentication** for production sign-in (email/password, Google, Apple). Follow these steps before building or deploying.

## 1. Create a Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project (or use an existing one).
3. Add an **Android** app:
   - Package name: `com.example.smart_locket_flutter` (or your `applicationId` from `android/app/build.gradle`).
   - Download `google-services.json` and place it in `android/app/`.
4. Add an **iOS** app (if you build for iOS):
   - Bundle ID: match your iOS app (e.g. `com.example.smartLocketFlutter`).
   - Download `GoogleService-Info.plist` and add it to the `ios/Runner` folder in Xcode (or copy into `ios/Runner/`).

## 2. Enable sign-in methods in Firebase

In Firebase Console → **Authentication** → **Sign-in method**:

- **Email/Password**: Enable.
- **Google**: Enable and configure (OAuth client IDs as needed for Android/iOS/Web).
- **Apple**: Enable (required for Apple App Store if you offer Apple Sign-In).

## 3. Generate Flutter Firebase config

From the project root (the folder that contains `pubspec.yaml`):

```bash
dart run flutterfire_cli:flutterfire configure
```

- Log in to Firebase when prompted.
- Select the project and platforms (Android, iOS, etc.).
- This overwrites `lib/firebase_options.dart` with your project’s config.

If you prefer not to use the CLI, you can edit `lib/firebase_options.dart` manually and set:

- `apiKey`, `appId`, `messagingSenderId`, `projectId`
- Optionally `authDomain`, `storageBucket` (e.g. for Web or Storage).

## 4. Android

- **Google Sign-In**: If you use Google Sign-In, ensure the SHA-1 (and SHA-256) of your signing key are added in Firebase Console → Project settings → Your apps → Android app. For debug, run:

  ```bash
  cd android && ./gradlew signingReport
  ```

- The `google-services` plugin is already applied in `android/app/build.gradle`.

## 5. iOS

- **Apple Sign-In**: In Xcode, open `ios/Runner.xcworkspace` → select **Runner** → **Signing & Capabilities** → add **Sign in with Apple**.
- Ensure `GoogleService-Info.plist` is in `ios/Runner` and included in the Xcode project.

## 6. Run the app

```bash
flutter pub get
flutter run
```

After `flutterfire configure`, the app will use your Firebase project for auth. If you see auth or config errors, double-check the package name / bundle ID and that the correct `google-services.json` and `GoogleService-Info.plist` are in place.
