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
| `exclude` | `true` drops the place (e.g. a city district listed as a town). |
| `_name` | A note for humans; ignored by the build. |

The build **fails** on an unknown field, a `uk` name outside the Ukrainian
alphabet, or an id that isn't in the lists, so typos can't slip through.

To find an id, search `tool/review/cities_review.csv`, or the GeoNames dump
by name.

### What's in it (211 entries)
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
- Wrong names (Delhi was "Старе Делі"), and awkward English names
  ("Sharjah city" → Sharjah).

## Review sheet: `review/cities_review.csv`

Each build also writes a sheet for human review. It's UTF-8 with a BOM, so it
opens correctly in Excel.

- **Sections:** the World top 1,500 and Ukraine top 150 by population, plus
  any capital or Ukrainian city still missing a Ukrainian name.
- **`status` column:** `missing_uk` or `override`.
- It's committed, so a diff shows what a GeoNames update or an override
  changed.
