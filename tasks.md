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
| T04 | Name review & overrides | M1 Data | M | [ ] |
| T05 | `City` model + answer normalization | M2 Engine | M | [ ] |
| T06 | `CityCatalog` (indexes, lists, tiers) | M2 Engine | M | [ ] |
| T07 | Letter rule on the catalog | M2 Engine | S | [ ] |
| T08 | Difficulty + CityBot | M2 Engine | M | [ ] |
| T09 | `Match` — rules, scoring, hints, result | M2 Engine | L | [ ] |
| T10 | City loader + splash + composition root | M3 Playable | M | [ ] |
| T11 | `GameCubit` (turns, timer, bot delay) | M3 Playable | L | [ ] |
| T12 | Game screen (chat UI) | M3 Playable | L | [ ] |
| T13 | Game-over view | M3 Playable | S | [ ] |
| T14 | Home screen + router | M4 App shell | M | [ ] |
| T15 | Setup sheet (list + difficulty) | M4 App shell | S | [ ] |
| T16 | Settings screen (language + About) | M4 App shell | S | [ ] |
| T17 | `PlayerStore` (JSON persistence) | M5 Progress | M | [ ] |
| T18 | Record results + new-city bonus + Home stats card | M5 Progress | M | [ ] |
| T19 | Statistics screen | M5 Progress | M | [ ] |
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

---

## M2 — Engine (pure Dart, `lib/engine/`)

### T05 · `City` model + answer normalization · M
- `City` is an immutable value class (`Equatable`) with a `fromJson` factory.
  No `dynamic` escapes it.
- `normalize.dart` implements every rule in tech_design §5: case, whitespace,
  hyphens, apostrophes, Latin diacritics, `ґ→г`, `ё→е`.

**Done when:** a table-driven test covers each rule with real examples:
Кам'янець-Подільський, São Paulo, Kraków, Ґалаґан.

### T06 · `CityCatalog` · M
Build it from the decoded JSON. It stays pure and takes no asset I/O.
- `CityListKind { ukraine, world }`.
- For each list × language:
  - name→`List<City>` (including aliases);
  - letter→cities, sorted by fame;
  - the set of playable first letters.
- Tiers come from population rank within each list, with capitals forced to
  T1. Tier sizes come from constants.

**Done when:** tests on a small fixture JSON cover alias lookup, duplicate
names (the most populous wins), tier boundaries and the capital override.

### T07 · Letter rule on the catalog · S
- Plug the carried-over `LetterRule` into the catalog's playable letters and
  the normalization.

**Done when:** tests cover `ь`/`и`/`й` backtracking and apostrophes
(Кам'янець → «ц»), plus an English case.

### T08 · Difficulty + CityBot · M
- `Difficulty { easy, medium, hard }` has its vocabulary tiers, turn timer and
  win multiplier as named tuning constants.
- `CityBot.move(...)` returns a random unused vocabulary city that satisfies
  the letter rule, weighted toward fame, or `giveUp`. `Random` is injected.

**Done when:** seeded tests show:
- the bot never plays outside its tiers;
- it never repeats a city;
- it gives up exactly when its vocabulary is exhausted for the letter.

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

### T11 · `GameCubit` · L
- A `sealed` state: `GameLoading` / `GamePlaying` / `GameOver`, as in
  tech_design §3.
- It wraps `Match` and adds:
  - the player countdown (per difficulty; it does not reset on a wrong answer);
  - the bot "thinking" delay (0.6–1.2 s);
  - hint, give up and timeout.

**Done when:** `bloc_test` + `fake_async` cover:
- bot opens → player answers → bot replies;
- a rejection keeps the timer running;
- timeout → loss, bot give-up → win, hint → 0 points.

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
- An About section with the version and the GeoNames CC BY 4.0 attribution.
- Prune `assets/translations` down to the strings actually used.

**Done when:** switching language re-renders every screen, and game names
follow the app language.

---

## M5 — Progress

### T17 · `PlayerStore` · M
- The `PlayerData` model from tech_design §6, with a versioned schema.
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

### T20 · Balance simulator + tuning pass · M
- `tool/simulate.dart` runs many seeded games of the bot against a "player"
  that knows the top N cities.
- It reports the average game length and how often the bot gives up per
  list × difficulty.
- Tune the tier sizes and timers so that Easy is winnable, Medium is a
  challenge and Hard is rare.
- Then do a real playtest with 2–3 people.

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

**Done when:** testers can install it from TestFlight and Play internal
testing.

---

## Later (from game_design.md §5 — not scheduled)
Endurance mode · leaderboards (local → global) · rewarded ads (hints/revive) +
banners · richer stats · interactive map · country/capitals modes · merged pool ·
PvP · sound · typo tolerance · daily challenge.
