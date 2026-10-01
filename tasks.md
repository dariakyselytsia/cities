# Cities (Міста) — MVP Task Board

> Our lightweight ticket system. It implements `game_design.md` + `tech_design.md`.
> Work top to bottom: each task builds on the ones before it.
>
> **Status:** `[ ]` todo · `[~]` in progress · `[x]` done
> **Size:** S ≈ a few hours · M ≈ a day · L ≈ 2–3 days

## How we work a task
1. Branch from `main`: `feature/T07-city-catalog` (use `fix/` or `chore/` as fits).
2. Build only what the task describes. If you notice something extra, add it
   as a new task here.
3. The acceptance criteria are met, `flutter analyze` is clean, and
   `flutter test` is green.
4. Commit with Conventional Commits, merge to `main`, and tick the box here in
   the same commit.
5. Any task that adds UI adds its strings in **both** `uk` and `en`.

## Why this order
- **M0 first.** The old `CLAUDE.md` still enforces Isar, injectable, etc., which
  would steer every later task wrong.
- **Data before engine.** The city data is the riskiest part: big GeoNames
  dumps and name quality. Tiers, aliases and ids all depend on it, so we
  surface problems early. (If data stalls, engine work can continue on a small
  test fixture.)
- **Engine before UI.** All the rules are pure Dart and fully tested before
  any screen exists, so the UI stays thin.
- **Playable as early as possible (M3).** Get one real game on a phone, then
  build the shell around it. Playtesting informs everything after.
- **Persistence and stats last.** They only record results, so they're easy to
  add once the game loop is stable.

---

## Overview

| # | Task | Milestone | Size | Status |
|---|---|---|---|---|
| T00 | Dev environment: Android SDK + emulator | M0 Reset | S | [x] |
| T01 | Reset project skeleton | M0 Reset | M | [x] |
| T02 | Update CLAUDE.md & project skills | M0 Reset | S | [x] |
| T03 | GeoNames build script → `cities.json` | M1 Data | L | [x] |
| T04 | Name review & overrides | M1 Data | M | [x] |
| T23 | World list: filter big-city districts | M1 Data | M | [x] |
| T24 | World list: review tiers 2–3 (districts + duplicates) | M1 Data | M | [ ] |
| T05 | `City` model + answer normalization | M2 Engine | M | [x] |
| T06 | `CityCatalog` (indexes, lists, tiers) | M2 Engine | M | [x] |
| T07 | Letter rule on the catalog | M2 Engine | S | [x] |
| T08 | Difficulty + CityBot | M2 Engine | M | [x] |
| T09 | `Match` — rules, scoring, hints, result | M2 Engine | L | [x] |
| T10 | City loader + splash + composition root | M3 Playable | M | [x] |
| T11 | `GameCubit` (turns, timer, bot delay) | M3 Playable | L | [x] |
| T12 | Game screen (chat UI) | M3 Playable | L | [ ] |
| T13 | Game-over view | M3 Playable | S | [ ] |
| T26 | Pause the turn timer when the app is in the background | M3 Playable | S | [ ] |
| T14 | Home screen + router | M4 App shell | M | [ ] |
| T15 | Setup sheet (list + difficulty) | M4 App shell | S | [ ] |
| T16 | Settings screen (language + About) | M4 App shell | S | [ ] |
| T17 | `PlayerStore` (JSON persistence) | M5 Progress | M | [ ] |
| T18 | Record results + new-city bonus + Home stats card | M5 Progress | M | [ ] |
| T19 | Statistics screen | M5 Progress | M | [ ] |
| T25 | Review rare-letter skipping | M6 Release | S | [ ] |
| T20 | Balance simulator + tuning pass | M6 Release | M | [ ] |
| T21 | Polish pass | M6 Release | M | [ ] |
| T22 | Release prep | M6 Release | M | [ ] |

---

## M0 — Reset

### T00 · Dev environment: Android SDK + emulator · S
We can't see the app on a phone yet: this machine has no Android SDK and no
emulator. It's needed from T10 onward (cold-start timing) and for T12
(🎯 playable on a phone).

Steps:
- Install Android Studio (it includes the SDK, platform-tools and the
  emulator), or install just the command-line tools.
- Point Flutter at it: `flutter config --android-sdk <path>`, or set
  `ANDROID_HOME`.
- Accept the licenses: `flutter doctor --android-licenses`.
- Create an AVD, e.g. a Pixel with a recent API level, x86_64 image. Enable
  hardware acceleration (Windows Hypervisor Platform).
- Optional: enable USB debugging on a real Android phone. Real-device timing
  matters for T10.

iOS: building needs a Mac with Xcode. Until one is available, iOS is checked
through a cloud build (e.g. Codemagic or GitHub Actions macOS) at the latest
by T22.

**Done when:**
- `flutter doctor` shows the Android toolchain ✓;
- `flutter emulators` lists the AVD;
- `flutter run` launches the T01 skeleton on the emulator.

**Setup notes (done 2026-09-29):**
- Everything lives on `D:\Android`, because C: has little free space:
  - SDK: `D:\Android\Sdk` (API 36, build-tools 36.1.0);
  - JDK: `D:\Android\jdk-17`, used by Flutter via `flutter config --jdk-dir`.
    The system Java 8 is untouched.
  - AVD: `Pixel_8_API_36` in `D:\Android\avd` (user env var
    `ANDROID_AVD_HOME`). `ANDROID_HOME` is also set as a user env var.
- Acceleration: WHPX (Windows Hypervisor Platform) — no admin changes were
  needed.
- Run it:
  - start the phone with `flutter emulators --launch Pixel_8_API_36`, or
    from VS Code's device picker;
  - then `flutter run`.
- If the emulator hangs "offline" after a crash, cold boot it:
  `D:\Android\Sdk\emulator\emulator.exe -avd Pixel_8_API_36 -no-snapshot-load`.
- Memory: the machine has little free commit memory (a fixed 10 GB pagefile,
  plus WSL/SQL Server running). Gradle's heap is capped at 2 GB in
  `android/gradle.properties`, because Flutter's 8 GB default crashed.
- If the emulator dies during builds, stop idle build daemons with
  `android\gradlew --stop`, or make the Windows pagefile system-managed
  (needs admin).
- First Android build: ~7.5 min. Incremental builds are much faster.

### T01 · Reset project skeleton · M
Start from scratch while keeping what carries over (tech_design §8).
- Delete the old `lib/` and `test/` contents and the generated files
  (`*.g.dart`, `di.config.dart`).
- Carry over:
  - `theme.dart` → `lib/core/`;
  - `letter_rule.dart` + its tests → `lib/engine/`, `test/engine/`.
- `pubspec.yaml`:
  - remove isar_community, get_it, injectable, build_runner,
    supabase_flutter, google_mobile_ads, google_fonts and mocktail;
  - add equatable, path_provider and fake_async (dev).
- Bundle the fonts as `.ttf` files under `assets/fonts/`, and switch
  the theme to them. We bundled Nunito + Rubik: the design's Baloo 2 / Poppins
  have no Cyrillic.
- A minimal `main.dart`/`app.dart` shows one placeholder screen with the theme
  and `easy_localization`.
- Keep the old `assets/data/*.json` until T03 replaces them.

**Done when:**
- the app builds and launches (verified on Windows desktop; the Android launch
  check moved to T00, iOS to a Mac / cloud build);
- `flutter analyze` is clean and the letter-rule tests pass;
- no codegen is left in the project.

### T02 · Update CLAUDE.md & project skills · S
- Rewrite `CLAUDE.md` for the new stack and architecture: engine / data /
  features, the no-codegen rule, and the conventions.
- Point it at `game_design.md`, `tech_design.md` and `tasks.md`, and remove
  the old remediation roadmap.
- Skills:
  - delete `flutter-codegen`;
  - update `feature-scaffold` and `flutter-review` (drop the Isar and
    injectable checks; add "engine must be pure Dart");
  - check `test-review`.
- Also update `.github/copilot-instructions.md` and
  `.github/agents/Agent.agent.md`.

**Done when:** no doc or skill references Isar, get_it, injectable,
build_runner, Supabase or ads as current tech.

---

## M1 — City data

### T03 · GeoNames build script → `cities.json` · L
Write `tool/build_cities.dart`. The GeoNames inputs are downloaded manually
and are **not committed** (`tool/geonames/` goes in `.gitignore`):
- `cities15000` for World;
- `cities5000` filtered to `UA` for Ukraine;
- `alternateNamesV2`, which must be **streamed** (it is huge).

The script:
- reads `uk` and `en` preferred names and aliases. When there's no real `uk`
  name, `uk` is left out; there's no transliteration. The script reports those
  cities for T04;
- marks capitals from feature code `PPLC`;
- adds `pop`, and `uaOnly` for towns under 15k;
- writes minified `assets/data/cities.json` in the format from tech_design §4;
- has a `tool/README.md` that explains how to download the inputs and run it.

**Done when:**
- output is deterministic (running twice gives identical files);
- the file is ≤ 3 MB;
- ids are GeoNames ids;
- Kyiv has `akaEn: ["Kiev", …]`;
- spot checks give sensible Ukrainian names, e.g. "Андорра-ла-Велья" rather
  than "Андорра ла Велла".

**Result (2026-09-30):**
- 1.92 MB; a byte-identical rebuild in ~25 s.
- World 31,733 cities (7,021 with a `uk` name); Ukraine 852 (843 with `uk`).
- Kyiv has `akaEn: ["Kiev"]`, and historic names are kept as aliases
  (Кіровоград → Кропивницький).
- Andorra la Vella has **no** `uk` name in GeoNames, so it now has none
  instead of a bad one. 36 capitals lack a `uk` name (Lisbon, Tehran,
  Belgrade, New Delhi, …) and are handed to T04.
- The asset is **not yet declared in `pubspec.yaml`**. That happens in T10,
  when the loader reads it.

### T04 · Name review & overrides · M
- The script also writes a review CSV of the top ~1,500 World and ~150
  Ukraine cities by population, plus all cities where the `uk` name is
  missing.
  - Priorities: the 36 capitals without a `uk` name, and big cities without
    one (Tehran, Hyderabad, Yokohama, Giza, …).
  - Also the 9 Ukrainian towns without one (Kadiyivka, Liubotyn,
    Ovidiopol, …).
- Fix names in `tool/overrides.json` (by id: name/alias/exclude) and apply
  them on every build, so fixes survive re-runs.
- Delete the old `cities_ua.json` and `cities_world.json`.

**Done when:** the top-tier names read correctly in both languages, and the
overrides are applied automatically.

**Result (2026-09-30):**
- `tool/overrides.json` has 209 fixes, validated at build time: unknown
  fields, non-Cyrillic `uk` and unknown ids all fail the build.
- The review sheet is `tool/review/cities_review.csv`.
- Coverage now:
  - every capital has a `uk` name;
  - all 848 Ukrainian cities have one;
  - World in Ukrainian has 7,185 cities (up from 7,021).
- 13 renamed Ukrainian cities that GeoNames still showed under their old
  names are fixed (Червоноград → Шептицький, …). They were found by checking
  where the `uk` and `en` names disagree; the old names remain aliases.
  - Айдар (Новопсков), Вільне (Просяна) and Любимівка (Дзержинський) rely on
    GeoNames alone and haven't been independently confirmed.
- Excluded: 4 Ukrainian city districts (Черемушки, Біличі, …) and the 5 New
  York City boroughs.
- The overrides were reviewed. The only junk left is the alias "Топез" on
  Чистякове (a GeoNames typo, harmless). Removing aliases isn't supported.
- **Extra:** Ukrainian cities' English names now follow the official
  transliteration (KMU No. 55, 2010), e.g. Zaporizhzhia, Kryvyi Rih.
  GeoNames' spellings and transliterated old names are aliases.
- The old `cities_ua.json` and `cities_world.json` are deleted. The output is
  1.93 MB and deterministic.
- Known limit: names are as current as GeoNames plus the overrides. A
  renaming GeoNames doesn't know yet needs a one-line override.

### T23 · World list: filter big-city districts · M
Added after the T04 review.

GeoNames codes many big-city districts as ordinary towns (`PPLA2`/`PPLA3`),
not `PPLX`. Examples: Pudong and Minhang (Shanghai), Üsküdar and Esenyurt
(Istanbul), Iztapalapa (Mexico City), Tokyo's wards (Ōta-ku). Hard CityBot
could play them.
- Find candidates automatically: places whose coordinates fall inside a much
  larger city in the same country (e.g. within ~15 km of a city ≥ 5× their
  population), plus name patterns (`-ku`, `District`, `Qū`).
- Also seen during T05: the Paris arrondissements ("Paris 15 Vaugirard") and
  Marseille's ("Marseille 01"), Hong Kong housing estates ("Choi Wan Estate
  (I & II)"), and Hawaiian census areas ("Makiki / Lower Punchbowl /
  Tantalus").
- Review the list and add `exclude` overrides. Or, if the heuristic proves
  reliable, have the build apply it.

**Done when:** the World top 1,500 contains no known districts, and the rule
or overrides are documented in `tool/README.md`.

Do this before T20 (balance tuning), because districts distort the tiers.

**Result (2026-09-30):**
- **No reliable automatic rule exists**, so the build only flags
  candidates. Checked against the data:
  - Distance flags real cities: Kawasaki, Guarulhos, Callao and Islamabad all
    border bigger ones.
  - GeoNames admin codes are right in some countries (Warsaw's and Madrid's
    districts share the city's code), but wrong elsewhere. US counties would
    drop Glendale and Pasadena, and it would drop **Venice** (filed under
    Mestre).
- **Automatic** (`tool/src/districts.dart`), list-wide: name patterns
  (arrondissements, `-ku`, `Quận`/`Huyện`, `Estate`, `(Kreis N)`,
  `District`) plus Hong Kong, Singapore and Macau neighborhoods. It removes
  225 places with no false positives.
- **Reviewed:**
  - Candidates are places within 25 km of a same-country city ≥ 3× bigger.
  - `exclude` became three-valued: `true` = drop; `false` = reviewed, keep
    (it also beats the automatic rules); omitted = pending.
  - Decisions for the top 1,500: 87 districts excluded, 5 duplicates merged
    (the old name is kept as an alias), 109 places kept.
  - Beyond the 25 km net, it also excludes the outer Shanghai districts,
    Tanggu, Beylikdüzü, Najafgarh, Narela, and Tokyo's wards.
- The build prints the pending counts: **top 1,500: 0**, top 5,000: 786.
  The review sheet gains a `district_candidates` section and a `note` column
  ("near Shanghai (5 km)").
- World is now 31,407 cities (7,177 with a `uk` name), 1.91 MB.
- The rest moves to T24.

### T24 · World list: review tiers 2–3 (districts + duplicates) · M
Added after T23. Hard CityBot knows tiers 1–3 (≈ the World top 5,000), so
those need the same cleanup as the top 1,500.
- Decide the 786 pending `district_candidates` in the review sheet. Most are
  real suburbs (Paris's communes, Milan's comuni); the districts cluster in a
  few cities (Hanoi, Bangkok, Kuala Lumpur, Warsaw, London, Delhi, Luanda).
- Duplicates: the same place listed twice, usually within a few km under a
  similar name ("Tempe" / "Tempe Junction", "Makakilo" / "Makakilo City",
  Hawaiian census areas like "Makiki / Lower Punchbowl / Tantalus"). A
  name-plus-distance check found ~150 pairs list-wide.
- Worth a look: a population copied from another place (the small Sahiwal
  had the big one's 538,344).

**Done when:** the build reports 0 pending candidates in the World top 5,000,
and no known duplicate pairs remain there.

Do this before T20: the balance simulator should run on clean tiers.

---

## M2 — Engine (pure Dart, `lib/engine/`)

### T05 · `City` model + answer normalization · M
- `City` is an immutable value class (`Equatable`) with a `fromJson` factory.
  No `dynamic` escapes it.
- `normalize.dart` implements every rule in tech_design §5: case, whitespace,
  hyphens, apostrophes, Latin diacritics, `ґ→г`, `ё→е`.

**Done when:** a table-driven test covers each rule with real examples:
Кам'янець-Подільський, São Paulo, Kraków, Ґалаґан.

**Result (2026-09-30):**
- `lib/engine/city.dart`: `City` + `NameLanguage { uk, en }`, with
  `name(language)` / `aliases(language)`. `fromJson` is strict: a bad field
  throws `FormatException`, which the loader (T10) turns into a typed
  failure.
- `lib/engine/normalize.dart`: `normalizeName()`. Beyond §5 as first written,
  it also turns dots, brackets and slashes into spaces ("St. Louis"), removes
  the transliteration marks `ʻ ʾ ʿ`, and recomposes a decomposed `й`/`ї` so
  it doesn't lose its mark. tech_design §5 is updated.
- The diacritic table covers every accented letter in the data. A dataset
  test checks that each name in `cities.json` normalizes to plain letters of
  its language.
- **Data fix found by that test:** the build now accepts only the Ukrainian
  alphabet in `uk` names. It dropped "Мохњин" (Myanmar; Serbian `њ`), and two
  overrides fix typos with a Russian `э`: Ширяєве, Середнє Водяне.

### T06 · `CityCatalog` · M
Build it from the decoded JSON. It stays pure and takes no asset I/O.
- `CityListKind { ukraine, world }`.
- For each list × language:
  - name→`List<City>` (including aliases);
  - letter→cities, sorted by fame;
  - the set of playable first letters.
- Tiers come from population rank within each list, with capitals forced to
  T1. Tier sizes come from constants.
  - Only capitals of **sovereign states** get the T1 boost. GeoNames `PPLC`
    also marks territory capitals (Флаїнг-Фіш-Коув, 1,355 people;
    Вест-Айленд, 120), which Easy CityBot must not play.
  - E.g. require a minimum population for the boost, or keep a list of
    territory country codes.

**Done when:** tests on a small fixture JSON cover alias lookup, duplicate
names (the most populous wins), tier boundaries and the capital override.

**Result (2026-10-01):**
- `lib/engine/city_list.dart`: `CityListKind` (with `contains`),
  `tierCount = 4`, and `TierLimits` (cumulative rank limits, `standard` =
  game_design's guesses).
- `lib/engine/city_catalog.dart`: `CityCatalog.fromJson` → four `CityIndex`
  (list × language), each with `lookup`, `startingWith`, `firstLetters`,
  `tierOf` and `cities` (in fame order).
  - Tiers are per list, the same in both languages.
  - Sovereign capitals are forced into T1. Territories are excluded by an
    explicit list of country codes (`nonSovereignCountryCodes`): a population
    threshold would also drop Vatican City (829 people).
- **Letters use the display name only:** Mumbai is under «м», even though
  "Бомбей" is accepted as an answer. Whether an alias answer must match the
  letter by its own spelling is T09's call.
- **Speed:** the first build took 4.2 s, because `normalizeName` cost
  ~44 µs per name. It's now one pass with no regex (49 ms for 43k names).
  Names are also normalized once per language, and the catalog builds in
  ~0.2 s. Invisible literal combining marks in the source are now `\u`
  escapes.
- **Data fix found by the dataset test:** "Испарта" and "Игдир" (Russian
  spellings) → Іспарта, Ігдир. The test now fails if any Ukrainian name
  starts with «ь» or «и».

### T07 · Letter rule on the catalog · S
- Plug the carried-over `LetterRule` into the catalog's playable letters and
  the normalization.

**Done when:** tests cover `ь`/`и`/`й` backtracking and apostrophes
(Кам'янець → «ц»), plus an English case.

**Result (2026-10-01):**
- **Rule change (decided with Daria):** a letter is playable only if enough
  cities in the list start with it: `LetterMinimums`, Ukraine 5 and World 20
  (tuning values for T20).
  - The purely data-driven rule made «й» playable in World (Йокогама, Йорк).
    145 names end in «й» but only 16 start with it, so games would jam.
  - A single minimum doesn't fit both lists: at 20, Ukraine would lose «а».
  - Now skipped: «й ї щ» in World, «ї ц е ф є щ» in Ukraine. «ь» and «и»
    are skipped everywhere. game_design §2.3 is updated.
- `LetterRule` reads the **normalized display name**, so apostrophes and
  hyphens don't count and «ґ» reads as «г». It returns `null` (any letter
  will do) for a dead end, like the opening move. `startsWithRequired` checks
  an answer.
- `CityIndex.playableLetters` and `requiredLetterAfter(city)`.
- Tests: a table covering «ь», «и», «й», «ї» backtracking, apostrophe
  variants, «ґ», English (Kraków → «w», "St. John's" → «s»), dead ends, and
  real-data checks. The actual city is "Кам'янець-Подільський" (→ «к»), so
  «ц» is tested on Кременець: «ц» in World, «н» in Ukraine.

### T08 · Difficulty + CityBot · M
- `Difficulty { easy, medium, hard }` has its vocabulary tiers, turn timer and
  win multiplier as named tuning constants.
- `CityBot.move(...)` returns a random unused vocabulary city that satisfies
  the letter rule, weighted toward fame, or `giveUp`. `Random` is injected.

**Done when:** seeded tests show:
- the bot never plays outside its tiers;
- it never repeats a city;
- it gives up exactly when its vocabulary is exhausted for the letter.

**Result (2026-10-01):**
- `lib/engine/difficulty.dart`: `Difficulty { easy, medium, hard }` with
  `maxTier` (1/2/3), `turnTime` (45/30/20 s) and `winMultiplier` (1/2/3).
- `lib/engine/bot.dart`:
  - `CityBot(index, difficulty, random).move(requiredLetter, usedIds)`
    returns `BotPlays(city)` or `BotGivesUp()`.
  - A `null` letter (the opening move, or after a dead end) allows any known
    city.
  - `botTierWeights = [4, 2, 1, 1]`: weighted by tier, uniform within one.
  - `knows(city)` exposes the vocabulary, for T09 and the simulator.
- Tests: seeded play-outs per difficulty. They check no repeats, only the
  bot's own tiers, and that it gives up exactly when the letter's vocabulary
  runs out. Also covered: the tier-1 share (≈ 80% against one tier-3
  rival), the opening move, determinism, and the Difficulty values.
- **Real vocabulary sizes** (Easy / Medium / Hard):

  | List / language | Easy | Medium | Hard |
  |---|---|---|---|
  | Ukraine | 50 | 150 | 300 |
  | World, English | 429 | 1,559 | 5,038 |
  | World, Ukrainian | 388 | 993 | 2,138 |

  Ukrainian World games get a much smaller Hard bot, because many tier 2–3
  cities have no Ukrainian name (tiers are per list, T06). Noted for T20.

### T09 · `Match` · L
One game's rules, as in tech_design §3:
- `botMove()`, `submit()` → `Accepted` / `Rejected(reason)`, `hint()`,
  `surrender()`, `timeout()`;
- one shared used-set;
- scoring: +10, or +25 for a city new to the player, 0 for a hint, and the win
  bonus × difficulty;
- the chain counter, 3 hints, and the result.

It takes the player's `discoveredIds` as input.

**Done when:**
- unit tests cover every rejection reason, the scoring rules, hint rules and
  every end condition;
- a seeded "full game" simulation test runs a game to a win and to a loss.

**Result (2026-10-01):**
- `lib/engine/scoring.dart`: the point values and `winPoints(difficulty)`.
- `lib/engine/match.dart`: `Match`, `Turn`, `SubmitResult` (`Accepted` /
  `Rejected(RejectionReason)`), `MatchOutcome` and `MatchResult`, as in
  tech_design §3.
- **Rule decided here, provisionally:** an answer may fit the required
  letter by the typed text **or** by the city's display name ("Bombay"
  works for «b» and «m»). The next letter always comes from the display
  name. game_design §2.4 is updated, and the rule is flagged in §6 "Open
  questions" for the T20 playtest.
- **Who starts:** `Match(firstTurn: Side.player)` lets the player open (any
  letter). The default is the bot. The setting is wired up in T11/T16/T17.
- Among same-named cities, the most populous one that fits and is unused is
  played. Hints pick at random within the best tier still available.
- `Match(bot: …)` lets tests script the bot's moves.
- Tests: 29 unit tests (all 4 rejection reasons, scoring and the new-city
  bonus, hints, every end, turn errors). The full-game simulation runs on the
  real data in both languages: a player who knows every city beats Easy, and
  one who knows only tier 1 loses to Hard, for 5 seeds each. It checks the
  rules on every move.

---

## M3 — Playable

### T10 · City loader + splash + composition root · M
- `data/city_loader.dart`: read the asset → `Isolate.run(parse)` →
  `CityCatalog`, returning a typed failure on error.
- `main.dart` builds the catalog and provides it with `RepositoryProvider`.
- Show a splash while loading and a friendly error screen on failure.

**Done when:**
- a loader test on a fixture asset passes;
- a cold start on a real mid-range Android device loads in about 1 s or less
  (measure it and write the number in the PR/commit).

**Result (2026-10-01):**
- `lib/data/city_loader.dart`: `CityLoader.load()` reads the asset (not
  cached), then decodes and indexes it in `Isolate.run`. It returns
  `CitiesLoaded(catalog, loadTime)` or `CitiesLoadFailed(missingAsset |
  invalidData)` and never throws. Details go to `FlutterError.reportError`,
  and one `city_loader: N cities in X ms` line goes to logcat on every
  launch.
- `lib/features/startup/`: `StartupCubit` (Loading / Ready / Failed, with
  retry), `SplashScreen`, `LoadErrorScreen` ("Try again"), and
  `StartupGate`. The gate sits in `MaterialApp.builder` and provides
  `CityCatalog` above the navigator, so T14's router fits in unchanged.
- `main.dart` builds the loader and the cubit. `cities.json` is declared in
  `pubspec.yaml`. The startup strings are in both `uk.json` and `en.json`.
- Tests: the loader on a fixture asset, a missing asset, 4 kinds of bad data
  and the real file; the cubit (including retry); the gate's three states
  (the catalog is provided to routes).
- **Measured:** a release APK on the x86_64 emulator (Pixel 8, API 36, WHPX)
  loads the cities in **651 / 803 / 865 ms** over 3 cold starts (the
  activity's first frame comes at 1.3–1.9 s, with the splash shown
  meanwhile). There's no real device here, so the real mid-range phone
  check is still open and moves to T22 (the release build).
- Seen on the emulator: Android's native launch screen is still the white
  default with the Flutter logo before the cream splash. That's T21
  (native splash).

### T11 · `GameCubit` · L
- A `sealed` state: `GameLoading` / `GamePlaying` / `GameOver`, as in
  tech_design §3.
- It wraps `Match` and adds:
  - the player countdown (per difficulty; it does not reset on a wrong answer);
  - the bot "thinking" delay (0.6–1.2 s);
  - hint, give up and timeout;
  - who starts: pass the "Who starts" setting (T16) as `Match(firstTurn:)`.
    When the player opens, the countdown starts right away.

**Done when:** `bloc_test` + `fake_async` cover:
- bot opens → player answers → bot replies;
- a rejection keeps the timer running;
- timeout → loss, bot give-up → win, hint → 0 points.

**Result (2026-10-01):**
- `lib/features/game/`: `GameState` (`GameLoading` / `GamePlaying` /
  `GameOver`) and `GameCubit`.
  - `GamePlaying` carries the history, whose turn, the required letter,
    seconds left, score, hints left and the last rejection. `GameOver`
    carries the `MatchResult` and the history (for T13's list of cities).
  - The cubit takes a `createMatch` factory, so the setup (list,
    difficulty, who starts, discovered cities) stays with whoever builds it,
    and `start()` again is "Play again" (T13).
  - The countdown is a 1-s `Timer.periodic` that runs only on the player's
    turn. It restarts from the full turn time on every new player turn, but
    not on a rejection. On the bot's turn the state shows the full time.
  - Answers, hints and give-ups at the wrong moment (while the bot thinks,
    after the end) are ignored rather than thrown: they're UI races. A hint
    that finds no city does nothing.
  - Timers are cancelled on `close()`, on give-up, and on `start()`.
- `engine/bot.dart`: the thinking time is a tuning value, `botThinkingMin` /
  `botThinkingMax` (0.6–1.2 s), drawn by `botThinkingTime(random)`.
- `ScriptedBot` moved to `test/helpers/` and is shared by the match and
  cubit tests.
- Tests: in `fake_async`, a full game (the bot opens → the player answers →
  the bot replies → the bot gives up → win, with the exact score), the
  thinking window, ticks and timeout → loss, rejections keeping the timer,
  a hint for 0 points, a hint with no city, give-up while the bot thinks,
  the player opening (countdown right away), and close stopping timers.
  `bloc_test` covers the initial state, ignored actions and Play again.
- Found: nothing pauses the countdown when the app goes to the background
  (a phone call loses the game). Added as T26.

### T12 · Game screen (chat UI) · L
Port the visuals from `archive/v0` (`game_session_screen.dart`):
- bot bubbles on the left, player bubbles on the right, with an accented first
  letter;
- the turn banner ("your turn — «Х»" / "CityBot is thinking…");
- a timer badge, a score pill, a hint button with its count, and Give up;
- an auto-focused input and an inline rejection message.

For now a temporary route starts a fixed Ukraine / Medium game.

**Done when:** **🎯 a full game is playable on a phone.** There is a widget
smoke test.

### T13 · Game-over view · S
- Show Win/Loss, score, cities you named, and new cities discovered
  (in-memory until T18).
- Play again / Home.

**Done when:** it is reached from all three end paths (bot gives up, timeout,
give up).

### T26 · Pause the turn timer in the background · S
Found in T11: the countdown keeps running when the app goes to the
background, so a phone call or a notification can lose the game on timeout.
- `GameCubit.pause()` / `resume()`: stop and restart the countdown (and the
  bot's thinking), keeping the seconds left.
- The game screen calls them on `AppLifecycleState` changes.
- **Decided (2026-10-01):** while paused, the chat is **blurred** under a big
  pause icon (‖), so nobody can study the chat or look a city up with the
  clock stopped. Back in the app, the game stays paused until the player taps
  the overlay, then the countdown resumes. `GamePlaying` gets an `isPaused`
  flag; the overlay is a widget over the chat (no rules in it).

**Done when:**
- a `fake_async` test shows no time passes while paused;
- on the emulator, home button → back to the app shows the blurred chat with
  the pause icon, and a tap resumes with the same seconds left.

---

## M4 — App shell

### T14 · Home screen + router · M
- Port the Home visuals from `archive/v0`: hero, Play, Settings icon and
  Statistics icon. The stats card is a placeholder until T18.
- `go_router` routes: `/`, `/game`, `/settings`, `/stats`.

**Done when:** you can navigate Home ↔ Game ↔ Home, and the temporary route
from T12 is removed.

### T15 · Setup sheet · S
- Play opens a bottom sheet: list (Ukraine/World) + difficulty + Start.
- It remembers the last choice (in memory until T17/T18).

**Done when:** the chosen list and difficulty drive the game, including the
timer and the bot's vocabulary.

### T16 · Settings screen · S
- Language: Ukrainian / English, applied live and persisted by
  `easy_localization`.
- **Who starts:** CityBot (default) / Me (game_design §2.2). It's kept in
  memory until T17, then saved in `PlayerData`. The engine side is done
  (`Match(firstTurn:)`, T09).
- An About section with the version and the GeoNames CC BY 4.0 attribution.
- Prune `assets/translations` down to the strings actually used.

**Done when:** switching language re-renders every screen, and game names
follow the app language.

---

## M5 — Progress

### T17 · `PlayerStore` · M
- The `PlayerData` model from tech_design §6, with a versioned schema,
  including the settings (who starts, T16).
- JSON file in the app documents directory, with an atomic write (temp file,
  then rename).
- A corrupt or unknown file is backed up and reset. It never crashes.

**Done when:** tests cover the round-trip, a missing file, a corrupt file, and
the version field.

### T18 · Record results + new-city bonus + Home stats card · M
- On `GameOver`, fold the result into `PlayerData` and save it:
  discovered ids, per list × difficulty W/L and best score, games played/won,
  longest chain.
- Feed `discoveredIds` into `Match`, which makes the **+25 new-city bonus
  live**.
- Persist the last setup.
- The Home stats card shows real numbers and refreshes when you return to Home.

**Done when:**
- cubit tests show the save happens on every end path;
- stats survive an app restart;
- a city is "new" only the first time you name it.

### T19 · Statistics screen · M
- Port the visuals from `archive/v0`.
- Summary: games played, games won, win rate, longest chain, cities
  discovered.
- A per list × difficulty record (6 cells).
- Discovery progress bars: Ukraine % and World %, with counts.

**Done when:** it matches `game_design.md` §3.6, and there's an empty state for
a new player.

---

## M6 — Release readiness

### T25 · Review rare-letter skipping · S
Added after T07, at Daria's request. The T07 rule skips a letter when fewer
than `LetterMinimums` cities start with it (Ukraine 5, World 20). Today that
skips «й ї щ» in World and «ї ц е ф є щ» in Ukraine, plus «ь» and «и»
everywhere.

Review whether that's the right set:
- **Measure demand, not just supply.** A letter is a trap when many names
  *require* it (after skipping) but few cities start with it. The raw
  starter count also skips harmless letters. Numbers for uk names, at T07:

  | List | Letter | Names ending in it | Cities starting with it |
  |---|---|---|---|
  | World | «й» | 145 | 16 (Йоганнесбург, Йокогама, Йорк, …) |
  | World | «щ» | 1 | 4 (Щецин, …) |
  | World | «ї» | 21 | 2 (Їньчуань, …) |
  | Ukraine | «е» | 138 (the "-ське" names) | 2 (Енергодар, Есхар) |
  | Ukraine | «ф» | 1 | 3 (Феодосія, Фастів, Фонтанка) |
  | Ukraine | «є» | 2 | 4 (Євпаторія, Єнакієве, …) |
  | Ukraine | «щ» | 0 | 4 (Щастя, …) |
  | Ukraine | «ц» | the "-ець" names (via «ь») | 2 (Царичанка, Циркуни) |

  So «щ» and «ф» could stay playable, while «й» and Ukraine's «е» are real
  traps. "Names ending in it" counts only the last character; the review
  should count the letter actually *required* after skipping (e.g. «ц» after
  "-ець").
- **Popular cities behind a skipped letter:** Енергодар («е») is well known,
  and so are Щецин, Йоганнесбург and Йокогама. Today they can only be played
  as an opening move. Making «е» playable would bring back the trap
  (138 names → 2 cities), so keeping Енергодар reachable probably needs the
  option below.
- **Option, likely post-MVP:** let the player answer with **either** letter.
  If an unused city starting with the rare letter exists, the player (and
  maybe the bot) may use it, or fall back to the previous letter as today.
  Then no letter is lost and nothing jams. It's listed in game_design §5 as
  "Rare-letter choice"; the review decides whether it's worth pulling into
  MVP.
- Use the T20 simulator to check how often games end on each letter.

**Done when:** the skip rule (the metric and its values, per list) is decided
and documented in game_design §2.3, including what happens to Енергодар, and
the "either letter" option is either scheduled or left in Future.

Do this before T20 finalizes the tuning values.

### T20 · Balance simulator + tuning pass · M
- `tool/simulate.dart` runs many seeded games of the bot against a "player"
  that knows the top N cities.
- It reports the average game length and how often the bot gives up per
  list × difficulty.
- Tune the tier sizes and timers so that Easy is winnable, Medium is a
  challenge and Hard is rare.
- Compare World games in each language. The Hard bot knows 5,038 cities in
  English but 2,138 in Ukrainian, because tiers are per list and many cities
  lack a Ukrainian name (T08). Decide whether the uk index should get its own
  tier limits.
- Also tune `LetterMinimums` (T07, reviewed in T25): report how often games
  end on a rare letter (e.g. «а» in the Ukraine list: 232 names end in it, 16
  start with it).
- Then do a real playtest with 2–3 people, and settle game_design §6
  "Open questions" (the alias-letter rule, the skipped letters, who starts
  by default).

**Done when:** the tuning constants are updated and the reasoning is noted in
a comment.

### T21 · Polish pass · M
- Bot thinking animation, auto-scroll of the chat, keyboard handling on small
  screens, and haptics on accept/reject (optional).
- Localized app name (Міста / Cities).
- App icon and native splash.

**Done when:** no layout overflow on a small phone (iPhone SE size), and the
app works in both languages.

### T22 · Release prep · M
- Version/build numbers and release signing (Android keystore, iOS team).
- A privacy policy: the app collects no data.
- Store listing text in UA/EN and screenshots.
- A TestFlight + Play internal testing build.
- Measure the cold-start load on a real mid-range Android phone. It should
  be about 1 s or less (T10 measured 0.65–0.87 s on the emulator); read the
  `city_loader:` line in logcat.

**Done when:** testers can install it from TestFlight and Play internal
testing.

---

## Later (from game_design.md §5 — not scheduled)
Endurance mode · leaderboards (local → global) · rewarded ads (hints/revive) +
banners · richer stats · interactive map · country/capitals modes · merged pool ·
PvP · sound · typo tolerance · daily challenge · rare-letter choice (see T25).
