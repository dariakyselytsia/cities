# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**Cities (Міста).** An offline educational word game for iOS/Android.
- The player duels **CityBot**, taking turns naming cities; each city starts
  with the *last valid letter* of the previous one.
- Each player turn has a countdown. You **win when CityBot runs out of cities
  it knows**; you lose on timeout or by giving up.
- Difficulty (Easy/Medium/Hard) sets the bot's vocabulary.
- City lists: **Ukraine** or **World**. UI languages: Ukrainian and English.

The project was **rewritten from scratch** in Sept 2026. The old scaffold
(Isar, get_it/injectable, Supabase, ads) is archived at tag `archive/v0`. Use it
only as a *visual* reference when porting screens. Never copy its architecture.

## Source-of-truth documents — read before working

| Doc | Owns |
|---|---|
| `game_design.md` | Product scope, game rules, scoring, screens, and what is **Future** (not MVP) |
| `tech_design.md` | Stack, architecture, data format, normalization, persistence, testing |
| `tasks.md` | The task board (T00, T01, …) in build order, each with "Done when" criteria |

- Work happens **task by task from `tasks.md`**.
- Don't build Future items (endurance mode, leaderboards, ads, map, PvP,
  sound, …), but don't design them out either.
- If a task reveals new work, add it to `tasks.md` as a new task rather than
  expanding scope.

## Stack

Flutter (Dart `^3.11.5`):
- `flutter_bloc` (**Cubits**) for state;
- `equatable` for value equality;
- `go_router` for navigation;
- `easy_localization` for `uk`/`en`, with files in `assets/translations/`;
- `path_provider` for the player-data JSON file.

Dev dependencies: `bloc_test`, `fake_async`, `flutter_lints`.

**No code generation** (no build_runner, freezed or injectable), **no
database**, **no backend**, **no ads**. Adding a dependency needs a reason that
`tech_design.md` supports. Mention it in the wrap-up.

Fonts are bundled: **Nunito** for headings, **Rubik** for body. Both cover
Cyrillic; the design's Baloo 2/Poppins don't.

## Architecture (`lib/`)

```
main.dart        # composition root — builds CityCatalog / PlayerStore, provides them
app.dart         # MaterialApp(.router) + theme + localization
core/            # theme.dart (AppColors, AppRadii, AppFonts, heading()), router, shared widgets
engine/          # PURE DART game rules: city, catalog, normalize, letter_rule, bot, match, scoring
data/            # city_loader (asset → isolate → CityCatalog), player_store (JSON file)
features/<name>/ # <name>_cubit.dart, <name>_state.dart, <name>_screen.dart, widgets/
```

Tests mirror this layout under `test/`.

### Rules — enforce in new code and review
- **`engine/` is pure Dart.**
  - No `package:flutter`, no `dart:io`, no asset or file access.
  - Anything random or time-based is injected (`Random`, durations) so games
    are deterministic in tests.
  - All game rules live here, not in Cubits or widgets.
- **Cubits orchestrate; widgets render.**
  - Cubits own timers, delays and flow, and call `engine/` and `data/`.
  - Widgets talk only to Cubits: no rules, parsing or timers in widgets.
- **No DI container.**
  - Construct dependencies in `main.dart`, provide them with
    `RepositoryProvider`, and pass them to Cubits via their constructors.
  - Add an abstract interface only when a test needs a fake (e.g.
    `PlayerStore`).
- **States and results are `sealed` + `Equatable`,** so tests can assert exact
  values.
- **A rejection is a value, not an error.** A wrong answer is
  `Rejected(reason)`. Only infrastructure problems (asset load, file I/O) are
  failures. They are modeled as typed values, never thrown across layers and
  never stringified (`'...$e'`). The app never crashes on bad or missing data;
  it shows a friendly screen or falls back.

## Coding standards
- **Enums, not strings,** for domain values: `CityListKind`, `Difficulty`, etc.
  Convert string⇄enum only at the JSON boundary.
- **Real IDs:** a city's id is its GeoNames id, the same in both lists. Never
  use `hashCode` or a made-up id.
- **Typed JSON:** parse through typed `fromJson` factories. `dynamic` must not
  escape the parsing code.
- **Null safety:** avoid `!` unless it's provably safe. Prefer `?.`, `??`,
  pattern matching. No `dynamic`.
- **Dartdoc (`///`)** on public engine classes, Cubits and stores. Explain
  *why*, especially for normalization, letter-rule and tiering choices.
- **UI strings are always localized.** Add every key to **both** `uk.json` and
  `en.json`. No hard-coded user-visible text.
- **Styling via the theme:** use `AppColors`, `AppRadii`, `heading()` and the
  `TextTheme`. No ad-hoc colors or font families in widgets.
- **Tuning values** (tier sizes, timers, scores) are named constants in
  `engine/`, never magic numbers inline.

## Commands

```bash
flutter pub get
flutter analyze          # must be clean before commit
flutter test
flutter run              # on the emulator (see Dev environment)
```

## Workflow
1. Pick the next task in `tasks.md`. Branch from **`main`**:
   `feature/T07-city-catalog`, `fix/…` or `chore/…`.
2. Implement only that task. Meet its **Done when** criteria.
3. `flutter analyze` must be clean and `flutter test` green. For UI changes,
   also check the screen on the emulator (screenshot it; see below).
4. Tick the task's box in `tasks.md` in the same change.
5. **Don't commit, merge or push unless the user asks.** When asked: use a
   Conventional Commit (`feat(engine): add city catalog (T06)`) and
   fast-forward merge into `main`.
6. **Always end a unit of work with a wrap-up** containing exactly these three
   parts:
   - **Commit message:** a ready-to-use Conventional Commit line.
   - **Summary:** what changed and why, in a few bullets.
   - **Proposed next steps:** the 1–3 highest-leverage follow-ups, in order
     (usually the next tasks in `tasks.md`).

## Dev environment (Windows)
- **Android:** SDK at `D:\Android\Sdk`, JDK 17 at `D:\Android\jdk-17` (set via
  `flutter config`), AVD `Pixel_8_API_36`.
  - Launch it with `flutter emulators --launch Pixel_8_API_36`.
  - If it's stuck "offline", cold boot it:
    `D:\Android\Sdk\emulator\emulator.exe -avd Pixel_8_API_36 -no-snapshot-load`.
- **Memory is tight.** The Gradle heap is capped at 2G in
  `android/gradle.properties`; don't raise it. If the emulator dies during a
  build, run `android\gradlew --stop`.
- **Visual check:**
  `adb shell screencap -p /sdcard/s.png` + `adb pull` into the scratchpad,
  then read the PNG.
- **iOS** can't be built here (no Mac). It will be checked through a cloud
  build before release (T22).

## Skills
- **feature-scaffold:** build a feature end to end (engine → data → Cubit →
  screen → tests).
- **flutter-review:** pre-commit review against the rules above.
- **test-review:** review unit, Cubit and widget tests.
