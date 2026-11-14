# Ọkọwookwu (Igbo Dictionary)

A fast, offline-first Igbo–English dictionary mobile app built with Flutter, backed by a secure Supabase Edge Function proxy and SQLite local caching.

## Download
Grab the latest Android APK directly from the [Releases](https://github.com/EzekweGideon001/Flutter-Blubber/releases) page.

## Features
- **Bilingual Search:** Search in Igbo (with or without diacritics) or English with smart relevance ranking.
- **Offline Caching:** Previously searched words are cached locally in SQLite for instant offline access.
- **Over-the-Air Updates:** Built with Shorebird for seamless Dart code patches.

## Setup & Configuration
To run or fork this project with your own backend:
1. Obtain a free API key from [IgboAPI](https://igboapi.com/).
2. Deploy the Supabase Edge Function inside `supabase/functions/search-proxy/` and set your secret:
   ```bash
   supabase secrets set IGBO_API_KEY=your_igbo_api_key
3. Update `_proxyUrl` in `lib/services/api_service.dart` to point to your deployed Supabase Edge Function URL.
4. *(Optional)* If you plan to distribute your own fork with Shorebird OTA updates, run `shorebird init` to replace the `app_id` in `shorebird.yaml` with your own.

## Release Builds
Releases are managed via Shorebird to support over-the-air (OTA) patches:
```bash
shorebird release android --artifact apk
