# FocusMate

An ADHD-friendly smart reminder and daily task management application built with Flutter.

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0 — [install guide](https://docs.flutter.dev/get-started/install)
- Android Studio or Xcode (for device/emulator)
- Git

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Isar schema files and Riverpod providers
dart run build_runner build --delete-conflicting-outputs

# 3. Run on a connected device or emulator
flutter run
```

> **Important:** Step 2 must be run before the first build.  
> It generates `*.g.dart` files for Isar models and Riverpod annotations.

---

## Architecture

```
lib/
├── main.dart                   # App entry point
├── app.dart                    # Root widget + theme + router
├── core/
│   ├── constants/              # App constants, colours
│   ├── theme/                  # Light & dark ThemeData
│   ├── router/                 # GoRouter config + route names
│   └── utils/                  # Date/time helpers
├── data/
│   ├── models/                 # Isar collections (task, reminder, etc.)
│   └── repositories/           # CRUD operations on each model
├── domain/                     # (reserved for use-cases / entities)
├── presentation/
│   ├── providers/              # Riverpod providers
│   ├── screens/                # One folder per screen
│   └── widgets/                # Reusable UI components
└── services/
    ├── database/               # DatabaseService (Isar singleton)
    └── notification/           # NotificationService (flutter_local_notifications)
```

## Key Features (MVP)

| Feature | Status |
|---|---|
| Quick Task Creation | ✅ |
| Custom Reminders | ✅ |
| Snooze & Reschedule | ✅ |
| Daily Dashboard | ✅ |
| Task Completion Tracking | ✅ |
| Task Breakdown (Subtasks) | ✅ |
| Focus Timer (Pomodoro) | ✅ |
| Recurring Routines | ✅ |
| Brain Dump | ✅ |
| Offline-first (Isar) | ✅ |
| Light & Dark theme | ✅ |

## Technology Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| State Management | Riverpod 2 |
| Navigation | GoRouter |
| Local Database | Isar |
| Notifications | flutter_local_notifications |
| Backend (future) | Firebase |

## Notifications

FocusMate uses exact alarms (`USE_EXACT_ALARM`) on Android 12+.  
On Android 13+ the user will be prompted for POST_NOTIFICATIONS permission on first launch.

## Generating Code

After adding or changing any Isar model or Riverpod `@riverpod` annotation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Running Tests

```bash
flutter test
```
