# Card Price Tracker

EU Magic: The Gathering price tracker for **Android** (Flutter). Tracks **Cardmarket** guide trends and **CardTrader** live/Zero mins as **separate labeled series** — never blended.

## Requirements

- Flutter SDK (stable) at `C:\flutter` (no spaces — required on Windows)
- Pub cache at `C:\pub-cache` (`PUB_CACHE` user env var)
- Project checkout at `C:\dev\card-price-tracker` (avoid paths under `C:\Users\...\` when the username has a space)
- Android emulator **or** a USB-debugging physical device

> **Windows note:** Flutter native-asset hooks break if the Flutter SDK or project path contains spaces (e.g. `C:\Users\First Last\...`). Use the paths above.

## Run on Android

```powershell
cd C:\dev\card-price-tracker
flutter pub get
flutter devices
flutter run
```

Pick an Android device/emulator when prompted. iOS folder exists for later; develop/test on Android first.

## First-time setup in the app

1. **Settings → CardTrader**  
   Paste your Bearer token from the CardTrader profile API settings → **Save** → **Test token**.
2. **Settings → Cardmarket guides**  
   Tap **Download & apply CM guides** (public MTG JSON catalogue + daily price guide),  
   **or** **Import CM files** if you already downloaded JSON/CSV.
3. **Search** for MTG cards (pick an expansion for speed) → add to watchlist.
4. **Sync now** to pull CT Zero/direct mins for watchlist cards and refresh CM snapshots.

## Marketplace economics (product rules)

| | Cardmarket | CardTrader |
|---|---|---|
| Signal | Daily guide trend / avg | Live listings |
| Shipping | Per seller (multi-ship risk) | Zero: one outbound from hub |
| In app | `CM trend` columns/charts | `CT Zero min` vs `CT direct min` |

Sticker price ≠ landed cost. Reports and charts keep sources separate.

## Stack

- Flutter + Dart, Android-first
- SQLite via **drift** (multi-game-ready schema; only `mtg` seeded)
- **flutter_secure_storage** for CT token
- **go_router** navigation
- **dio** HTTP, **file_picker** / CSV+JSON for CM ingest, **fl_chart** dual series, **share_plus** CSV export

## Cardmarket data URLs (MTG / game id 1)

- Products: `https://downloads.s3.cardmarket.com/productCatalog/productList/products_singles_1.json`
- Price guide: `https://downloads.s3.cardmarket.com/productCatalog/priceGuide/price_guide_1.json`
