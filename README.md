# Card Price Tracker

EU Magic: The Gathering price tracker for Android (Flutter). Tracks **Cardmarket** guide trends and **CardTrader** live/Zero mins separately — never blended.

## Requirements

- Flutter SDK (stable) — this machine uses `%USERPROFILE%\flutter`
- Android emulator or physical device (v1 target)

## Run (Android)

```powershell
cd %USERPROFILE%\Projects\card-price-tracker
flutter pub get
flutter run
```

Use an Android emulator or a USB-connected device with debugging enabled.

## Stack (scaffolded)

| Package | Role |
|---------|------|
| `drift` / `drift_flutter` | Local SQLite |
| `flutter_secure_storage` | CardTrader bearer token |
| `go_router` | Navigation |
| `dio` | HTTP (CardTrader API, CM guide fetch) |

iOS folder is present for a later ship; develop and test on Android first.
