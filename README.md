# VERDICT

Six guesses. One verdict.

VERDICT is an offline-first daily word game for Android and iOS with a
Neubrutalist interface. The current build includes Classic mode, UTC daily
puzzles, local game restoration, stats and streaks, a spoiler-free clipboard
share result, help, and high-contrast settings.

## Requirements

- Flutter 3.44 or newer
- Dart 3.12 or newer
- iOS 14 or newer
- Android 8.0 / API 26 or newer

The Android application ID and iOS bundle identifier are both
`com.maskedsyntax.verdict`.

## Development

```sh
flutter pub get
flutter analyze
flutter test
dart test packages/verdict_engine
flutter run
```

The framework-independent game engine is in `packages/verdict_engine`. Word
asset provenance and generation details are in `assets/words/README.md`.

## Roadmap Boundaries

Online leaderboard, auth, ads, purchases, analytics, and notifications are not
initialized in the offline MVP. Their contracts live in
`lib/core/services/future_services.dart`; production SDKs and credentials will
be added only when those phases are implemented.
