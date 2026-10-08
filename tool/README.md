# tool/

Developer scripts. They are not part of the app.

## `build_cities.dart` — build `assets/data/cities.json`

Builds the game's city data from [GeoNames](https://www.geonames.org/)
(CC BY 4.0; the attribution is shown in the app under Settings → About).

### 1. Download the dumps
Download these into `tool/geonames/` (the folder is git-ignored) from
https://download.geonames.org/export/dump/:

| File | Size | Used for |
|---|---|---|
| `cities15000.zip` | ~3 MB | **World** list: cities with population ≥ 15,000 |
| `cities5000.zip` | ~5 MB | **Ukraine** list: Ukrainian cities with population ≥ 5,000 |
| `alternateNamesV2.zip` | ~195 MB | Real Ukrainian/English names and aliases (Kiev, Kirovohrad, …) |

The script unzips them itself (with `tar`) the first time.

### 2. Run it (from the project root)
```bash
dart run tool/build_cities.dart
```

It takes about 25 seconds. It prints stats, plus the capitals and largest
cities that have **no Ukrainian name**; those are candidates for manual fixes
(T04).

### What it does
- **Drops non-cities:** city sections (`PPLX`, e.g. Obolon), historical
  (`PPLH`), abandoned (`PPLQ`) and destroyed (`PPLW`) places.
- **Ids** are GeoNames ids, unique across both lists.
- **Ukrainian name:** a real `uk` name from GeoNames, in the Ukrainian
  alphabet only. Latin rows and names with Russian or Serbian letters
  ("Ширяэве", "Мохњин") are rejected.
  - When none exists, the city has no `uk` field and isn't playable in
    Ukrainian. The script never machine-transliterates names *into*
    Ukrainian: that's what produced the old "лес Ескалдес".
- **English name:** the preferred `en` name, else GeoNames' main name.
  - **Ukrainian cities** use the **official transliteration** of their
    Ukrainian name instead (Cabinet of Ministers Resolution No. 55, 2010,
    which is still the standard for place names): Zaporizhzhia, Kryvyi Rih,
    Kamianske. GeoNames' older spellings (Zaporizhzhya) and the
    transliterated old names (Chervonohrad) become aliases. See
    `src/ua_translit.dart`.
- **Aliases:** every other `uk`/`en` name, **including historic ones**
  (Kiev, Кіровоград, Bombay).
  - Nicknames ("Big Apple") and other languages (e.g. Russian) are excluded.
  - Variants that differ only by case, hyphens or apostrophes are removed,
    since the game normalizes those.
- **Output** is minified and sorted by id, and deterministic: the same inputs
  always give a byte-identical file. The format is in `tech_design.md` §4.

The name-selection logic lives in `tool/src/city_builder.dart` and is tested
in `test/tool/`.

## `simulate.dart`: the balance simulator (T20)

```bash
dart run tool/simulate.dart [--games 200]
```

It plays seeded games of the real `Match` and `CityBot` against simulated
players who know the top N cities of an index (Ukraine 30 / 100 / 300,
World 100 / 400 / 1,500) and never run out of time. Each player either
picks a city at random, or **steers**: names the city that leaves CityBot
the fewest options for its next letter.

For each list × language × difficulty it prints the win rate, the average
chain and game length, and the letters games end on. It takes about two
minutes. The player logic is in `src/simulator.dart`.

Use it when you change a tuning value (`TierLimits`,
`Difficulty.minCitiesPerLetter`, `LetterMinimums`, `trapLetterRatio`) or
the city data. It measures knowledge only, not how fast a player recalls a
city, so the turn timers need a real playtest.

## `letter_report.dart`: the numbers behind the letter rule

```bash
dart run tool/letter_report.dart
```

For each list × language it prints:
- which letters are skipped as rare (`LetterMinimums`) and as traps
  (`trapLetterRatio`);
- for every first letter:
  - how many cities start with it, and how many of those each bot knows;
  - how many names would require it, and the ratio of the two.

Use it when you retune the letter rule (game_design §2.3, T20) or after a
data update.

## `render_icons.dart`: app icons and splash images (T21)

```bash
flutter test tool/render_icons.dart
```

It's a test only because it needs the Flutter engine to paint. It draws the
brand mark from `lib/core/brand.dart` (the white pin on coral, the same
shape as the badge on Home and the splash) into every PNG the platforms
need, so they always match the app:

| Output | What it is |
|---|---|
| `ios/…/AppIcon.appiconset/*.png` | every iOS icon size: full-bleed coral, **no alpha channel** (the App Store rejects one) |
| `ios/…/LaunchImage.imageset/*.png` | the 120 pt badge for `LaunchScreen.storyboard` |
| `android/…/mipmap-*/ic_launcher.png` | the legacy icon (before Android 8) |
| `android/…/mipmap-*/ic_launcher_foreground.png`, `…_monochrome.png` | the adaptive icon's pin and the themed-icon layer (Android 13+) |
| `android/…/drawable-*/splash_icon.png` | the 120 dp badge in a 288 dp box: the Android 12+ splash icon, also centered on older launch screens |

The XML around them is written by hand: `mipmap-anydpi-v26/ic_launcher.xml`
(adaptive icon), `values/colors.xml` (coral, cream), `values*/styles.xml`
(splash themes), `drawable/launch_background.xml` and iOS
`LaunchScreen.storyboard`. Run the script again after changing the brand
mark or its sizes (the constants at the top of the script).

## Fixing names: `overrides.json`

GeoNames has gaps and errors. Each fix goes in `tool/overrides.json`, keyed by
GeoNames id, and is applied on every build, so fixes survive re-runs.

```json
"710554": {
  "_name": "Sheptytskyi (renamed from Червоноград)",
  "uk": "Шептицький",
  "akaUk": ["Червоноград"]
}
```

| Field | Effect |
|---|---|
| `uk` | Replaces the Ukrainian name. The old one is dropped; list it in `akaUk` if it's still a valid alias, e.g. a pre-renaming name. Must use the Ukrainian alphabet. |
| `en` | Replaces the English name. The old one is kept as an alias. |
| `akaUk`, `akaEn` | Extra aliases. |
| `exclude` | `true` drops the place (a city district listed as a town, a duplicate). `false` records a review decision to **keep** it (see City districts below). |
| `_name` | A note for humans; ignored by the build. |

The build **fails** on an unknown field, a `uk` name outside the Ukrainian
alphabet, or an id that isn't in the lists, so typos can't slip through.

To find an id, search `tool/review/cities_review.csv`, or the GeoNames dump
by name.

### What's in it (512 entries)
- 13 Ukrainian cities where GeoNames still shows the pre-renaming name
  (Червоноград → Шептицький, Кіровськ → Голубівка, …). The old name is kept
  as an alias.
- Ukrainian towns with no `uk` name, typos ("Часткове" → Чистякове;
  "Ширяэве" → Ширяєве and "Середнэ Водяне" → Середнє Водяне, with a Russian
  `э`), and 4 city districts excluded.
- The 5 New York City boroughs excluded: they're parts of New York, not
  cities. Manhattan, Kansas stays.
- All 36 capitals GeoNames has no Ukrainian name for (Лісабон, Тегеран,
  Белград, …).
- ~130 well-known cities without one (Йокогама, Ізмір, Франкфурт-на-Майні,
  Марракеш, …).
- Wrong names (Delhi was "Старе Делі"; Russian spellings "Испарта",
  "Игдир" → Іспарта, Ігдир), and awkward English names
  ("Sharjah city" → Sharjah).
- The T23 district review of the World top 1,500: 87 districts excluded
  (Pudong, Iztapalapa, Üsküdar, Luanda's communes, Soweto, Tokyo's wards, …),
  5 duplicates merged into the surviving entry (Pimpri → Pimpri-Chinchwad,
  Wanxian → Wanzhou), and 109 places reviewed and kept.
- The T24 review of every World city CityBot can play (see below): 4 more
  districts (Mokotów, Xizhi, Randburg, Roodepoort), 20 duplicates and parts
  of cities (Lexington-Fayette, Bangkok Noi/Yai, Indian cantonments,
  Montréal-Nord, …), and 75 places reviewed and kept (Bonn, Newark,
  Gatineau, Kansas City, Kansas, …).

## City districts

GeoNames lists many districts of big cities as ordinary towns: Pudong
(Shanghai), Üsküdar (Istanbul), Iztapalapa (Mexico City), Paris's
arrondissements. The build handles them in two ways (`src/districts.dart`).

**1. Automatic, list-wide.** These are always excluded:
- names that say they're districts: numbered arrondissements
  ("Paris 15 Vaugirard"), Japanese wards ("Ōta-ku"), Vietnamese
  "Quận …"/"Huyện …", housing estates ("… Estate", but not "Estates"),
  "(Kreis 3)", "District"/"subdistrict";
- in the city-states Hong Kong, Singapore and Macau, everything except the
  capital (GeoNames has ~170 neighborhoods there).

An `"exclude": false` override protects a place from these rules.

**2. Flagged for review.** A place within 25 km of a same-country city at
least 3× bigger is a **district candidate**. Distance alone can't decide:
Kawasaki and Ōta both border Tokyo, but only Ōta is part of it. And
admin-code rules fail too (GeoNames files Venice under Mestre). So a person
decides, and records it in `overrides.json`:
- `"exclude": true`: part of the bigger city (a district, borough, commune
  of the city, or a neighborhood);
- `"exclude": false`: its own municipality, even if it's in the metro area
  (Kawasaki, Guarulhos, Niterói, the Metro Manila cities).

**3. Duplicates, flagged for review (T24).** A place within 15 km of a
bigger one in the same country, whose name equals or extends the bigger
one's ("Tempe Junction", "Makakilo City", "Delhi Cantonment"), is a
**duplicate candidate**. The review decides on the smaller place: `true`
drops it (move a useful name onto the survivor as an alias), `false` keeps
both (Kansas City, Kansas next to Kansas City, Missouri).

**What must be reviewed: the cities CityBot can play.** The build asks the
engine which World cities a Hard CityBot knows in either language (its
tiers plus the per-letter minimum, about 2,100 cities) and prints how many
district and duplicate candidates among them have no decision yet. It
follows any retuning automatically. **Keep it at 0.** Those candidates are
listed in the review sheet. Candidates further down the list are only
counted: players may name them, but CityBot never plays them.

## Review sheet: `review/cities_review.csv`

Each build also writes a sheet for human review. It's UTF-8 with a BOM, so it
opens correctly in Excel.

- **Sections:** the World top 1,500 and Ukraine top 150 by population, plus
  any capital or Ukrainian city still missing a Ukrainian name, and the
  pending district and duplicate candidates among the cities CityBot can
  play.
- **`status` column:** `missing_uk`, `override`, `district?` or
  `duplicate?` (a pending candidate).
- **`note` column:** for a district candidate, the bigger city it's next to
  ("near Shanghai (5 km)"); for a duplicate, the place it may repeat
  ("same as Delhi (11034555, 11.2 km)").
- It's committed, so a diff shows what a GeoNames update or an override
  changed.
