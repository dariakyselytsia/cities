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
- **Ukrainian name:** a real `uk` name from GeoNames, Cyrillic only.
  - When none exists, the city has no `uk` field and isn't playable in
    Ukrainian. The script never machine-transliterates names.
- **English name:** the preferred `en` name, else GeoNames' main name.
- **Aliases:** every other `uk`/`en` name, **including historic ones**
  (Kiev, Кіровоград, Bombay).
  - Nicknames ("Big Apple") and other languages (e.g. Russian) are excluded.
  - Variants that differ only by case, hyphens or apostrophes are removed,
    since the game normalizes those.
- **Output** is minified and sorted by id, and deterministic: the same inputs
  always give a byte-identical file. The format is in `tech_design.md` §4.

The name-selection logic lives in `tool/src/city_builder.dart` and is tested
in `test/tool/city_builder_test.dart`.
