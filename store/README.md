# store/

Everything the store listings need (T22), ready for publishing (T29).

| File | What it is |
|---|---|
| `listing-uk.md`, `listing-en.md` | The listing text for both stores. Each field has its character limit in brackets. |
| `forms.md` | Answers to the store forms: Data safety, content rating, App Store privacy, categories, contacts. |
| `screenshots/play/<lang>/` | Google Play phone screenshots, 1080 × 1920. |
| `screenshots/ios-6.9/<lang>/` | App Store 6.9″ iPhone screenshots, 1320 × 2868. |
| `feature-graphic-<lang>.png` | The Play feature graphic, 1024 × 500. |
| `play-icon-512.png` | The Play icon, 512 × 512. |

The privacy policy is published from `docs/privacy/index.html` (see
`RELEASE.md`).

## Regenerating

- **Listing lengths:** after editing the text, check every field against
  its limit with `dart run tool/check_listing.dart`.
- **Screenshots and feature graphic:** `flutter test tool/render_store_images.dart`
  renders them from the real screens, with scripted games and sample
  statistics, so they come out the same every time. Rerun it after UI
  changes.
- **Play icon:** `flutter test tool/render_icons.dart` (with the app icons).

Apple's screenshot sizes change now and then: check App Store Connect's
current list before uploading (T29).
