# Cities (Міста) — Tech Design

> Companion to `game_design.md`. Guiding principle: **the smallest stack that
> ships the MVP well.** No code generation, no database, no backend.

## 1. Stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter (Dart 3) | Already chosen; platform folders are kept (bundle id `com.daria.cities`). |
| State | `flutter_bloc` — **Cubits** | Simple, testable. Events add ceremony we don't need yet. |
| Value equality | `equatable` + Dart 3 `sealed` classes | Exact-state asserts in tests, without codegen. |
| Navigation | `go_router` | Carried over. Only 4 routes + a sheet. |
| Localization | `easy_localization` | Existing `uk`/`en` translation files are reused (pruned). |
| Persistence | `path_provider` → one JSON file | The player's data is small. No Isar, no migrations tooling. |
| Fonts | Bundled `.ttf`: **Nunito** (headings) + **Rubik** (body) | Truly offline. Drop `google_fonts`. The design's Baloo 2 / Poppins have **no Cyrillic**, so they were replaced by the closest rounded faces that have it. |
| Tests | `flutter_test`, `bloc_test`, `fake_async` | The engine is tested with plain unit tests. |

**Removed:** `isar_community`, `get_it`, `injectable`, `build_runner`,
`supabase_flutter`, `google_mobile_ads`, `google_fonts`, `mocktail` (add it back
only if a real need appears).

## 2. Architecture

The core idea is a **pure-Dart game engine** with thin Flutter feature folders
around it.

```
lib/
├── main.dart              # composition root: load data, build stores, runApp
├── app.dart               # MaterialApp.router + theme + localization
├── core/                  # theme.dart (carried over), router.dart, shared widgets
├── engine/                # PURE DART — no package:flutter imports, ever
│   ├── city.dart          # City value class
│   ├── city_list.dart     # CityListKind { ukraine, world }
│   ├── city_catalog.dart  # indexes: name→cities, letter→cities, tiers
│   ├── normalize.dart     # answer normalization (§5)
│   ├── letter_rule.dart   # carried over from the old codebase, with its tests
│   ├── difficulty.dart    # Difficulty { easy, medium, hard } + tuning values
│   ├── bot.dart           # CityBot move selection (Random injected)
│   ├── match.dart         # one game: turns, used-set, score, hints, result
│   └── scoring.dart
├── data/
│   ├── city_loader.dart   # asset → Isolate.run(parse) → CityCatalog
│   └── player_store.dart  # load/save PlayerData as JSON (atomic write)
└── features/
    ├── home/              # HomeScreen
    ├── setup/             # SetupSheet (+ remembers last choice via PlayerStore)
    ├── game/              # GameCubit, GameState, GameScreen, widgets/
    ├── settings/          # SettingsScreen
    └── stats/             # StatsCubit, StatsScreen
```

**Rules**
- `engine/` has no Flutter or I/O. Everything random or time-based is injected
  (`Random`), so the whole game can be simulated in unit tests.
- Widgets talk only to Cubits. Cubits talk to `engine/` and `data/`.
- There is no DI container. `main.dart` constructs `CityCatalog` and
  `PlayerStore` once and provides them with `RepositoryProvider`. Cubits
  receive what they need through their constructors.
- Only add an abstract interface when a test actually needs a fake. In
  practice that means only `PlayerStore`.
- Errors: data loading returns a typed failure. The app shows a friendly error
  screen and never crashes.

## 3. Game loop

`Match` (pure Dart) owns the rules. `GameCubit` owns time and the UI flow.

```
Match(index, difficulty, random, discoveredIds, firstTurn)   // index = catalog.index(list, language)
  botMove()          -> BotPlays(City) | BotGivesUp()
  submit(String)     -> Accepted(Turn) | Rejected(reason)   // empty, notInList, wrongLetter, alreadyUsed
  hint()             -> Turn? (plays a best-known unused city for the player, 0 points;
                              null = no hints left or no city fits, nothing spent)
  timeout()          -> MatchResult (player's turn only)
  surrender()        -> MatchResult (either turn)
  state: turn, requiredLetter, usedIds, history (Turns), score, chain, hintsLeft, result?
```

- `Turn` = city, side, points, isNew, isHint. `MatchResult` = outcome
  (`botGaveUp` | `timeout` | `surrendered`), score (with the win bonus),
  chain, newCityIds and namedCityIds (for `PlayerData`, T18).
- Moving out of turn or after the end throws a `StateError`: that's a
  programming error, not a game event.
- Hints pick randomly within the best tier that still has an unused city for
  the letter.

`GameCubit` state is a `sealed` hierarchy:
- `GameLoading`
- `GamePlaying`, which carries: history, whose turn, required letter, seconds
  left, score, hints left, and the last rejection
- `GameOver`, which carries the result summary

Flow:
1. On start, the cubit calls `botMove()` after a short "thinking" delay.
2. On the player's turn, it runs the countdown (a 1-second `Timer.periodic`).
3. When an answer is accepted, control passes to the bot.
4. When the bot gives up, the player wins. On timeout or surrender, the player
   loses.
5. On `GameOver`, the result is folded into `PlayerData` and saved.

Keeping the bot turn a discrete step is the seam for future PvP.

## 4. City data

### Source
**GeoNames** (CC BY 4.0, attribution shown in Settings → About):
- World: `cities15000` (all with population ≥ 15,000).
- Ukraine: `cities5000` filtered to `UA`, for fuller coverage of towns.
- `alternateNamesV2`: real `uk` and `en` names plus aliases (Kiev,
  Кіровоград, …). This replaces the old machine-transliterated Ukrainian names
  (e.g. "лес Ескалдес").
- Excluded feature codes: `PPLX` (city sections such as Obolon or Podil),
  `PPLH`, `PPLQ` and `PPLW`.
- **Manual fixes:** `tool/overrides.json`, keyed by GeoNames id. It fills in
  missing Ukrainian names (all capitals, well-known cities), fixes renamed
  Ukrainian cities, and excludes city districts and duplicates.
- **City districts** that GeoNames lists as towns (Pudong, Üsküdar, Paris's
  arrondissements) are removed in two ways:
  - automatically, by name patterns and for city-states (Hong Kong,
    Singapore, Macau);
  - by review: the build flags places near a much bigger city, and each
    decision is an `exclude` override. Distance alone can't decide: Kawasaki
    and Ōta both border Tokyo, but only Ōta is part of it.
- **English names of Ukrainian cities:** the official transliteration
  (KMU No. 55, 2010) of the Ukrainian name. GeoNames' spellings become
  aliases.
- Result:
  - **World:** 31,407 cities, 7,177 of them with a Ukrainian name.
  - **Ukraine:** 848 cities, all with a Ukrainian name.

### Build pipeline
- A reproducible script, `tool/build_cities.dart`, reads the GeoNames dumps
  (not committed) and writes compact assets that *are* committed. The output
  is deterministic. See `tool/README.md`.
- The script needs a manual review pass on tiers 1–2 names; those are the
  cities players see most.

### Asset format
One compact file, `assets/data/cities.json`. It is minified, with short keys:

```json
{"v":1,"cities":[
  {"id":703448,"uk":"Київ","en":"Kyiv","cc":"UA","cap":true,"pop":2952301,
   "akaEn":["Kiev"]}
]}
```

- `uk` is **optional**. A city without it is not in the Ukrainian-language
  indexes, so World in Ukrainian ≈ 7k cities. `cap`, `akaUk`, `akaEn` and
  `uaOnly` are omitted when false or empty.
- The Ukraine list is `cc == "UA"`, including the extra towns below 15k, which
  are flagged `"uaOnly":true`. The World list is every city that is not
  `uaOnly`.
- Ids are GeoNames ids: unique across both lists. **Old bug fixed:** the old
  Ukraine and World files both started their ids at 1, so their ids collided.
- Actual size: **1.91 MB** (the old files were 7.8 MB of pretty-printed JSON
  with redundant fields).

### At load
- Parse in a background isolate (`Isolate.run`) behind a short splash screen.
- `CityCatalog` (`engine/city_catalog.dart`) builds one `CityIndex` per
  list × language:
  - `lookup(answer)`: normalized name → `List<City>`, including aliases. It is
    a list because names can repeat (Victoria, Kingston); it's sorted most
    populous first, and the first unused match wins.
  - `startingWith(letter)`: the cities whose **display name** starts with the
    letter, best known first (tier, then population).
  - `playableLetters`: the letters at least `LetterMinimums` cities start
    with (Ukraine 5, World 20). The letter rule skips all others.
    `requiredLetterAfter(city)` applies `LetterRule` to the city's display
    name.
  - `tierOf(city)`: tiers come from population rank within the **list**. They
    are the same in both languages, because a city is as famous in either;
    a city with no Ukrainian name is simply missing from the Ukrainian index.
    Rank limits are the `TierLimits` constants. Capitals of **sovereign
    states** are forced into T1. Territory capitals are excluded by a list of
    territory country codes, since a population threshold would also drop
    Vatican City.
- Each name is normalized once per language and shared by both lists. The
  whole catalog builds in ~0.2 s on a desktop.

## 5. Answer normalization

The same normalization is applied to the player's input and to every dataset
name/alias:
1. Lowercase.
2. Remove apostrophes and quote marks (`'` `’` `ʼ` `` ` `` `ʻ` `ʾ` `ʿ` `”` …),
   so "Кам'янець" = "Камянець".
3. Latin: strip diacritics (ã→a, é→e, ł→l, ß→ss), including accents sent as
   separate combining marks. Ukrainian: `ґ`→`г`. Russian-style `ё`→`е`, and
   `ы`/`э` stay distinct. A decomposed `й`/`ї` is recomposed first, so it
   doesn't lose its mark.
4. Every run of non-letters (spaces, hyphens, dashes, dots, brackets,
   slashes) becomes one space; trim. "St. Louis" = "St Louis",
   "Івано-Франківськ" = "Івано Франківськ".
5. The letter rule runs on the **display name's** letters, with the same
   folding applied, so "Кам'янець" ends in `ь`→`ц`.

This lives in `engine/normalize.dart` (`normalizeName`) and is table-driven
and heavily unit-tested. A dataset test also checks that every name in
`cities.json` normalizes to plain letters of its language, so a new accented
letter from a GeoNames update can't silently become unmatchable.

## 6. Persistence

`PlayerData` is saved to `<app documents>/player_data.json` with an atomic
write (write to a temp file, then rename):

```
version
discoveredIds: Set<int>                 // every city the player ever named (not hinted)
records: {list×difficulty: {wins, losses, bestScore}}
gamesPlayed, gamesWon, longestChain
lastSetup: {list, difficulty}
settings: {firstTurn: bot | player}     // "Who starts" (game_design §2.2)
```

The locale is persisted by `easy_localization` itself.

The schema is versioned. Unknown or corrupt data is backed up and reset, so
the app never crashes.

## 7. Testing strategy
- **Engine (most of the value):**
  - normalization tables;
  - the letter rule (carried over);
  - the tier split;
  - bot vocabulary and give-up behavior;
  - `Match` scoring, new-city bonus, hints, used-set;
  - a seeded "simulate a full game" test.
- **Cubits:** `bloc_test` + `fake_async` for the timer, bot delay, timeout,
  win, and saving on `GameOver`.
- **Data:** a round-trip test for `PlayerStore` and the corrupt-file fallback,
  plus a loader test on a small fixture asset.
- **Widgets:** a smoke test per screen.
- Gate: `flutter analyze` must be clean and `flutter test` must be green before
  every commit.

## 8. What carries over from `archive/v0`
- `lib/core/theme.dart`: palette, radii, typography (switched to bundled fonts).
- The screen *visuals* (widget trees for Home, Game chat, Settings,
  Statistics), rewired to the new Cubits.
- `letter_rule.dart` and its tests.
- `assets/translations/*.json`, pruned to the MVP strings.
- The `ios/` and `android/` folders (bundle id, icons).

Everything else is rebuilt.

## 9. Build order
1. Tag `archive/v0` on `main`. Start a rewrite branch and clear `lib/` and
   `test/`.
2. Data: `tool/build_cities.dart` → `cities.json`, then review the tier-1/2
   names.
3. Engine + tests (normalize, catalog, letter rule, bot, match).
4. Game screen + `GameCubit`, which makes the game playable end to end.
5. Setup sheet, Home, Game-over, Settings.
6. `PlayerStore` + Statistics.
7. Playtest, then tune the tier sizes and timers.
8. Rewrite `CLAUDE.md` and the project skills to match (`flutter-codegen` is
   obsolete; update `feature-scaffold`).
