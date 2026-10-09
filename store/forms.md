# Store forms, answered in advance

The answers the Play Console and App Store Connect ask for, so T29 is
copy and paste. They rely on facts checked in T22: the release build asks
for **no permissions** (no INTERNET), there are no ads, accounts, analytics
or third-party SDKs, and progress stays in a file on the device.

## Shared details

| Field | Answer |
|---|---|
| Developer name | Dariia Kyselytsia |
| Contact email | daria.kyselytsia@gmail.com |
| Website / support URL | https://dariakyselytsia.github.io/cities/ |
| Privacy policy URL | https://dariakyselytsia.github.io/cities/privacy/ |
| App id / bundle id | `com.kyselytsia.cities` |
| Price | Free, no in-app purchases |
| Languages | Ukrainian (primary), English |
| Countries | All |
| Copyright (App Store) | 2026 Dariia Kyselytsia |

## Google Play Console

**App content**
- **Privacy policy:** the URL above.
- **Ads:** No, the app contains no ads.
- **App access:** All functionality is available without special access
  (no login).
- **Data safety:**
  - Does your app collect or share any of the required user data types?
    **No.**
  - Result: "No data collected", "No data shared".
- **Government app:** No. **Financial features:** None. **Health:** None.
- **News app:** No.
- **Content rating (IARC questionnaire):**
  - Category: **Game** (Puzzle / word).
  - Violence, fear, sexuality, crude humor, language, controlled
    substances: **No** to all.
  - Gambling or simulated gambling: **No**.
  - Users can interact or exchange content: **No**. CityBot is a built-in
    bot, not other people.
  - Shares the user's location: **No**. Allows digital purchases: **No**.
  - Expected ratings: PEGI 3, ESRB Everyone, USK 0, IARC 3+.
- **Target audience and content:** **an open decision for T29.**
  - Including under-13s puts the app under Google's Families policy. It
    already complies: no ads, no data, no third-party SDKs. But it means
    a stricter review and the store's teacher-approved style checks.
  - 13 and over is the quicker first review.

**Store settings**
- App category: **Game → Word**. Tags: Word, Educational, Trivia.
- Email: the contact email above. Website: the support URL above.

**Listing:** `store/listing-uk.md` (default language: Ukrainian) and
`store/listing-en.md` (English, translation added in the console).

**Graphics:** `store/screenshots/` (phone screenshots), the feature graphic
and the 512 × 512 icon. See `store/README.md`.

## App Store Connect

**App information**
- Primary category: **Games**, subcategory **Word**. Secondary category:
  **Education**.
- Content rights: the app shows third-party content (GeoNames city data)
  and has the right to: CC BY 4.0, credited in Settings → About.
- Age rating: answer **None** to every content question → **4+**.
- Made for Kids: **No** (same open decision as on Play: "Kids" category
  apps get a stricter review).

**App privacy ("nutrition label")**
- Do you or your third-party partners collect data from this app? **No.**
- Result: **Data Not Collected**.

**Export compliance**
- `ITSAppUsesNonExemptEncryption = NO` is set in `Info.plist`, so App Store
  Connect doesn't ask on every upload. The app uses no encryption beyond
  what iOS itself provides.

**Version information:** the listing files (promotional text, description,
keywords, subtitle), the support URL, and screenshots for the 6.9″ and
6.5″ iPhone sizes from `store/screenshots/`.

**App Review notes (suggested)**
```
Cities is an offline word game: the player and a built-in bot (CityBot) take turns naming cities, each starting with the last letter of the previous one. No login, no network access, no data collected. To try it: tap Play → Start, and answer CityBot's city with a city starting with the highlighted letter (e.g. after "Kyiv", type "Vinnytsia").
```
