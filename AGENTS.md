# AGENTS.md

## Project overview
- Cross-platform Deep Work / focus timer built in Flutter (Dart), targeting macOS, iOS, and Android (web/desktop scaffolding also present).
- Core differentiator: a live world map behind the timer showing small light markers for active users globally (Halo/CoD lobby map vibe).
- UI goal: minimalist, calm, and distraction-free with the timer as the focal element.
- Goal of the app: to help users focus by blocking out distractions and helping them to track their focus time. The eventual goal is to have a 1 stop shop of timing their focus time, blocking distracting apps on whatever platform they are on and to track their time over days and weeks so they can set work goals. 

## Tech stack
- Flutter (Material 3) + Dart.
- State management: BLoC (`bloc`, `flutter_bloc`) with `hydrated_bloc`.
- Firebase: Auth, Firestore, Realtime Database (presence), Analytics, Firebase UI Auth.
- Charts: `fl_chart`.
- Map: `flutter_map`, `flutter_map_cache`, `latlong2`.
- Local storage/cache: Hive (via `hydrated_bloc` and map tile cache).



## Repo layout (key files)
- `lib/main.dart`: app initialization, Firebase setup, DI, routes, theme.
- `lib/homepage.dart`: main landing screen with timer and navigation.
- `lib/timer_page.dart`: timer view with world map overlay.
- `lib/widgets/central_timer.dart`: timer UI + controls.
- `lib/widgets/world_map.dart`: map rendering + live user markers.
- `lib/bloc/`: feature BLoCs (auth, timer, leaderboard, goals, settings, live users, todo).
- `lib/repo/`: Firebase repositories (Auth, Firestore, Realtime DB).
- `lib/models/`: data models (time, timer results, goals, leaderboards, live users).
- `assets/`: map images (currently unused by the map widget).
- `test/`: existing bloc/model tests.
- `android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`: platform scaffolding.
- `build/`: generated output; do not edit or commit.

## Architecture and data flow
- `MultiRepositoryProvider` supplies `FirebaseAuthRepo` and `FirestoreRepo`.
- `MultiBlocProvider` initializes `AuthBloc`, `TimerBloc`, `LeaderboardBloc`, `GoalBloc`, and `SettingsBloc`.
- `TimerBloc` owns session timing; on start it writes presence to Firestore `activeUsers` and posts sessions on confirm.
- `LiveUsersBloc` listens to Firestore `activeUsers` for active markers; Realtime DB is used for on-disconnect presence cleanup.
- `LeaderboardBloc` aggregates sessions into weekly/monthly/today stats and feeds charts + goals.
- `SettingsBloc` persists UI preferences (dark mode, map visibility, notes) via HydratedBloc.

## Firebase data model (current)
- `sessions` collection
  - Fields: `uid`, `timeLeft`, `targetTime`, `completed`, `timeRun`, `breakTime`,
    `timeElapsed`, `startTime`, `timeFinished`, `breaks`, `breakEvents`,
    `sessionEfficiency`, `notes`, `focusRating`.
- `activeUsers` collection
  - Fields: `uid`, `isActive`, `geohash` (4-char).
- `timeGoals` collection
  - Document ID = `uid`; fields include `daily`, `weekly`, `monthly`, `yearly`.
- `goals` collection
  - Used for ToDo/goal tracking (currently partially implemented).

## UI/UX design guidelines (minimalist)
- Prioritize the timer; everything else should be visually subordinate.
- World map stays as a subdued background (low opacity, dark tiles) with tiny, soft-glow markers.
- Keep typography light (thin weights) and spacing generous; avoid cluttered panels.
- Use a restrained palette: neutral base + one accent color.
- Use subtle, purposeful animations only (no flashy effects).
- Ensure layouts scale cleanly on mobile and desktop; avoid fixed pixel sizes where possible.

## Map feature guidelines
- Current map uses Carto dark tiles with `flutter_map` and a cached tile provider.
- Keep markers small (1–3 px) and glowing; avoid labels or overlays on the map.
- Preserve privacy: avoid precise location unless explicitly allowed; use coarse or randomized points.
- Avoid heavy map interaction; current behavior disables interaction.

## Testing expectations (must improve coverage)
- Every logic change should include or update tests.
- Use `bloc_test` + `mocktail` for BLoC event/state testing.
- Add model tests for serialization and calculations when models change.
- Add widget tests for UI changes where feasible (timer, charts, settings).
- Do not hit live Firebase in tests; mock repositories or use fakes.
- Recommended commands:
  - `flutter analyze`
  - `flutter test`

## Development notes / best practices
- Follow `flutter_lints` from `analysis_options.yaml`.
- Prefer `const` widgets and immutable patterns where practical.
- Keep BLoC events/states in their feature folder and avoid business logic in UI widgets.
- Dispose/cancel timers and stream subscriptions in BLoCs to avoid leaks.
- Do not edit generated Firebase files manually:
  - `lib/utility/constants/firebase_options.dart`
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
  - `macos/Runner/GoogleService-Info.plist`
  - Regenerate via FlutterFire CLI when needed.

## Known gaps (scan findings)
- Tests cover only a subset of BLoCs/models; UI and Firebase behaviors are largely untested.
- `lib/services/screentime.dart` is empty (placeholder).
- Duplicate Firebase options file exists at `lib/firebase_options.dart` (unused in `main.dart`).
- Map asset images in `assets/` are not referenced by current code.

## When making changes
- Keep the minimal aesthetic and map-first differentiator intact.
- Maintain or improve test coverage for any changed behavior.
- Update this file if architecture, data model, or workflow changes.

# Agent Instructions – Flutter (Cross-Environment)

This repository is a Flutter application.

## Environment assumptions
- The `flutter` CLI is available on `PATH`.
  - Local macOS: Flutter may be installed via SDK, Homebrew, or FVM.
  - Codex (Linux): Flutter is installed at `/opt/flutter` and added to `PATH` by the environment setup.
- Do **not** use hard-coded absolute paths to Flutter.
- Always invoke Flutter via `flutter` (or `command -v flutter` if needed).

## Working directory
- All Flutter commands should be run from the repository root (where `pubspec.yaml` is located).

## Standard commands
Use the following commands when developing, testing, or fixing issues:

Always verify that all tests are passing, that web builds successfully.
use flutter run to run the app and get a screenshot of any UI changes. 

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
flutter run
