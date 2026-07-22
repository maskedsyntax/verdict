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

## Optional Leaderboard

Supabase anonymous auth and the Classic top-10 leaderboard activate only when a
URL and publishable key are supplied through `--dart-define`. See
`supabase/README.md` for deployment and security details. Without those values,
the same build remains offline-only.

The linked development project stores its publishable key in macOS Keychain.
Run the connected app with:

```sh
./tool/run_connected.sh
```

## Optional Ads

Debug builds use Google's official test IDs for results/stats banners, one
post-game interstitial per session, and opt-in rewarded letter hints. UMP consent
gates every ad request. Release ads remain disabled unless all production IDs
are supplied:

```sh
flutter run \
  --dart-define=ADMOB_ANDROID_APP_ID=YOUR_ANDROID_APP_ID \
  --dart-define=ADMOB_BANNER_UNIT_ID=YOUR_BANNER_UNIT_ID \
  --dart-define=ADMOB_INTERSTITIAL_UNIT_ID=YOUR_INTERSTITIAL_UNIT_ID \
  --dart-define=ADMOB_REWARDED_UNIT_ID=YOUR_REWARDED_UNIT_ID
```

For Android release builds, also export `ADMOB_ANDROID_APP_ID`. For iOS, replace
the test `ADMOB_APP_ID` in `ios/Flutter/Release.xcconfig` and supply
`ADMOB_IOS_APP_ID` as a Dart define. Missing or Google test IDs disable release
ad requests. Purchases and analytics remain disabled behind service contracts.
