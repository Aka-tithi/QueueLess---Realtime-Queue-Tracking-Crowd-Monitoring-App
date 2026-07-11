# QueueLess - Technology Stack

## Languages & Runtime
- **Dart** ^3.11.0 (Flutter SDK constraint)
- **Flutter** (Material 3, multi-platform)
- **Kotlin** (Android runner — MainActivity.kt)
- **Swift** (iOS/macOS runner)
- **C++** (Windows runner)

## Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^2.15.1 | Auth, Realtime DB, storage |
| `supabase` | ^2.3.0 | Supabase Dart client |
| `provider` | ^6.1.2 | State management (ChangeNotifier) |
| `firebase_core` | ^4.9.0 | Firebase SDK init (present but secondary) |
| `firebase_auth` | ^6.5.1 | Firebase Auth (present but Supabase is primary) |
| `cloud_firestore` | ^6.4.1 | Firestore (present but Supabase is primary) |
| `uuid` | ^4.5.3 | UUID generation |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

## Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_lints` | ^6.0.0 | Lint rules |
| `flutter_test` | SDK | Widget testing |

## Backend: Supabase
- **Auth**: email/password sign-in, sign-up, password reset
- **Database tables**: `locations`, `favorites`, `queue_records`
- **Realtime**: `.stream(primaryKey: ['id'])` for live location data
- **Config**: URL and anon key set in `main.dart` (replace placeholders before running)

## Build & Run Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d chrome    # Run on web
flutter build apk        # Android release build
flutter build ios        # iOS release build
flutter build windows    # Windows release build
flutter test             # Run widget tests
```

## App Version
`1.0.0+1` (pubspec.yaml)

## Theme
- Material 3 (`useMaterial3: true`)
- Font family: **Poppins** (referenced in theme; must be added to pubspec assets if not already)
- Color scheme: Deep Blue primary (`#1E3A8A`), Sky Blue secondary (`#3B82F6`), Teal accent (`#14B8A6`)

## Environment
- `.env.example` present — copy to `.env` and fill Supabase credentials
- `android/app/google-services.json` present for Firebase (Android)
- `firebase.json` present at project root
