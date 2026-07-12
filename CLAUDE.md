# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**Cities (Міста)** — an offline-first educational word game for iOS/Android. The
core loop: the player types a city name starting with the *last valid letter* of
the previous city, against a countdown timer, scoring points (with a bonus for
cities never named before across all sessions). Two modes: **Ukraine-only** and
**World**.

`game_design.md` is the **source of truth** for product scope, game rules,
screens, scoring, and the future roadmap. Read it before implementing gameplay,
UI, or data-model changes. Do **not** build roadmap items (interactive map,
country/capitals modes, multiplayer) for the MVP — but keep the architecture
open to them.

## Tech stack

- **Framework:** Flutter (Dart SDK `^3.11.5`)
- **State management:** `flutter_bloc ^8.1.5`
- **DI:** `get_it ^7.6.7` + `injectable ^2.3.2` (codegen)
- **Local DB:** `isar_community ^3.3.2` (+ `isar_community_flutter_libs`) —
  maintained drop-in fork of the abandoned Isar 3; same API, modern-analyzer
  codegen. Import `package:isar_community/isar.dart`. Opened once via an
  injectable `@module` (`lib/di/register_module.dart`) using `path_provider`.
- **Remote (BaaS):** `supabase_flutter ^2.5.2` — global leaderboards, anon auth
- **Ads:** `google_mobile_ads ^5.1.0` — rewarded (hints/revive) + banner
- **Localization:** `easy_localization ^3.0.3` — Ukrainian & English
- **Navigation:** `go_router ^13.2.2`
- **Codegen:** `build_runner ^2.4.8`
- **Testing (dev):** `bloc_test`, `mocktail`, `flutter_lints ^6.0.0`

## Architecture

Clean Architecture + Repository pattern. **Strict layer separation — enforce it:**

- **`domain/`** — pure Dart only. Entities, abstract repositories, abstract
  use cases. **No** imports of `package:flutter/*`, `isar`, or `supabase`.
- **`data/`** — Isar `@Collection` models, Supabase clients, repository
  implementations. Maps data models ⇄ domain entities. No UI code.
- **`presentation/`** — BLoCs, pages, widgets. Widgets talk **only** to BLoCs,
  never directly to repositories. All business logic (timer, scoring, validation,
  session) lives in BLoCs — never in widgets.

Error handling is functional: model failures as sealed BLoC states (e.g.
`GameSessionFailure`); never crash the app on a database miss.

### Directory map (`lib/`)

```
lib/
├── main.dart
├── domain/
│   ├── entities/         # plain immutable classes (City, GameSession, User, UserStats, ...)
│   ├── repositories/     # abstract interfaces only
│   └── usecases/         # callable abstract classes (call(...))
├── data/
│   ├── models/           # Isar @Collection models (+ generated .g.dart) with fromDomain/toDomain
│   └── repositories/     # @LazySingleton(as: XRepository) Isar-backed impls
├── presentation/
│   ├── bloc/             # GameSessionBloc (+ UserProfile/UserStats blocs)
│   └── pages/
└── di/                   # get_it + injectable config
```

## Conventions

- **Strict null safety.** Avoid the `!` bang operator unless provably safe; prefer
  `if (x != null)` / `?.` / `??`.
- **No `dynamic`.** Enforce explicit types.
- **Dartdoc (`///`)** on repositories, BLoCs, and non-trivial use cases — explain
  *why* an algorithmic choice was made (string parsing, DB querying).
- **Isar indexing:** put `@Index()` on hot lookup fields (e.g. `firstLetterUA`,
  `firstLetterEN` on `CityModel`) for fast gameplay lookups.
- **Patterns to mirror** (already in the codebase):
  - Entities: plain immutable classes with `const` constructors (no Equatable).
  - Use cases: callable classes exposing `call(...)`.
  - Data models: `fromDomain()` / `toDomain()` converters.
  - Tests: `bloc_test` + `mocktail`; see
    `test/presentation/bloc/game_session_bloc_test.dart` as the reference suite.

## Coding standards

These are decided project standards — enforce them in review and new code:

- **Error handling — sealed failures.** Model failures as a sealed `Failure`
  hierarchy and typed failure states (e.g. `GameSessionFailure(Failure)`); do not
  throw across layer boundaries and never swallow an error into a raw `'...$e'`
  string. Use cases/repositories surface a `Failure`, not a stringified exception.
- **Enums, not stringly-typed values.** Domain values are enums:
  `GameMode { ukraine, world }`, `AppLanguage { ua, en }`. No `'UA'`/`'WORLD'`
  string literals threaded through events, use cases, or entities.
- **Indexed Isar queries only.** Never `collection.where().findAll()` followed by
  a Dart-side `firstWhere`/filter — that is an O(n) table scan that defeats Isar.
  Query through indexes (`.filter().<field>EqualTo(...)`) and add `@Index()` to
  any field queried by equality (e.g. `nameUA`/`nameEN`,
  `GameSessionModel.sessionId`).
- **`Equatable` (or `freezed`) on every BLoC event and state** so tests can assert
  exact values (score, timer, history), not just `isA<Type>()`.
- **Real IDs only.** Never use `hashCode` (or any fabricated value) as an entity
  id — carry the real `City.id`.
- **Typed JSON, no leaking `dynamic`.** Parse assets/DTOs through a typed
  `fromJson` factory; `dynamic` must not escape the `data/` layer.
- **Consistent id types** between a domain entity and its Isar model (don't pair a
  `String` domain id with an int `Id` in the model).

## Commands

```bash
flutter pub get
flutter analyze                                          # must be clean before commit
flutter test
dart run build_runner build --delete-conflicting-outputs # after DI / Isar / model edits
```

## Workflow

1. Branch from **`main`**: `feature/<name>`, `fix/<name>`, or `chore/<name>`.
   (There is no `develop` branch — ignore older docs that say otherwise.)
2. Write clean, null-safe code; keep logic in BLoCs.
3. If you edited `@injectable` modules, Isar `@Collection` models, or freezed
   classes, run `build_runner` (see Commands) — or use the **flutter-codegen** skill.
4. Run `flutter analyze` and `flutter test`; fix **all** warnings/failures before
   committing.
5. Commit with **Conventional Commits** (`feat(game): add countdown timer bloc`,
   `fix(data): correct Isar index for firstLetter`).
6. **Always end a unit of work with a wrap-up** for the user, containing exactly
   three parts:
   - **Commit message** — a ready-to-use Conventional Commit line (do not run
     `git commit` unless asked; just provide the message).
   - **Summary** — what changed and why, in a few bullets.
   - **Proposed next steps** — the 1–3 highest-leverage follow-ups, ordered.

## Skills

- **flutter-review** — pre-commit code review (architecture, BLoC, Isar, null-safety).
- **test-review** — unit-test review (AAA, coverage, mocking, `bloc_test`).
- **flutter-codegen** — run `build_runner` + `flutter analyze` after codegen edits.
- **feature-scaffold** — scaffold a new Clean-Architecture feature end to end.

## Current state & remediation roadmap

This is an **early scaffold**. The Clean Architecture layering, Isar model↔domain
mapping, `GameSessionBloc`, and its test suite are structurally sound — the plan
is to **improve, not rewrite**. Execute the roadmap below in priority order.

### P0 — make it run ✅ DONE

- ✅ **DI wired & generated.** `lib/di/di.dart` (`@InjectableInit`) +
  `lib/di/register_module.dart` (`@module`, `@preResolve` `Isar` via `Isar.open` +
  `path_provider`) now generate a real `lib/di/di.config.dart`. The stub and the
  duplicate `getIt` are gone. `flutter analyze` is error-free; the 13 BLoC tests
  pass.
- ✅ **5 game use cases implemented & registered** (`*_usecase_impl.dart`:
  start / validate / hint / revive / end). NOTE: these are baseline
  implementations — the **full core game algorithm is still P1** (see below):
  ь/и soft-sign backtracking, per-session uniqueness, scoring, and the
  absolute-new-city bonus are not done yet. The 6 user/stats use cases remain
  interface-only (not on the P0 path).
- ✅ **Isar opened/registered** via the `@module` above.
- ✅ **Assets declared** under `flutter: assets:` in `pubspec.yaml`.
- ✅ **Migrated `isar` → `isar_community`** (the original Isar 3 was abandoned and
  its generator is incompatible with this Flutter's analyzer). Import swapped
  across all models/repos.

### P1 — correctness & modeling

- ✅ **Core game algorithm implemented.** `domain/game/letter_rule.dart` does the
  last-valid-letter rule with dataset-driven ь/и backtracking (unit-tested);
  `ValidateCityAnswerUseCase` now returns a `ValidationOutcome`
  (`domain/game/validation_outcome.dart`) covering existence, per-session
  uniqueness, the letter rule, and base scoring. Remaining: the absolute-new-city
  bonus is wired but gated on `historicUsedCityIds` — it stays off until the
  User/UserStats history below is persisted. ✅ `use_hint_usecase_impl.dart` now
  honors the required next letter (dataset-driven backtracking, same `LetterRule`)
  and only suggests unused cities.
- ✅ **User/UserStats persistence fixed.** The `@ignore`d `Map` fields now
  persist as Isar **embedded key/value lists** (`data/models/stat_entries.dart`:
  `IntIntEntry`, `StringIntEntry`, `StringDoubleEntry`) — fully typed, no
  `dynamic`/JSON-string round-tripping. `UserModel.highScores` and all three
  `UserStatsModel` maps (`cityUsageCount`, `highScores`, `usedCitiesPercent`)
  convert map⇄list at the `fromDomain`/`toDomain` boundary. `User`↔`UserStats`
  is a real **`IsarLink`**; `UserRepositoryImpl.saveUser` puts the stats row,
  the user, then saves the link, and `getUser` `.load()`s it before mapping.
  Round-trip mapping tests lock the conversion (incl. empty-map and
  independent-`UserStatsModel` cases). Remaining: `GameSessionSummary.mode` is
  still a `String` (unwired stats path); a `UserStatsRepository` impl and the
  end-of-session `recalculateStatistics` wiring are still stubs, so the
  absolute-new-city bonus stays gated until the BLoC actually reads/writes
  lifetime history.
- ✅ **Indexed queries replace full-table scans.** Added `@Index()` on
  `CityModel.nameUA/nameEN`, `GameSessionModel.sessionId`, `UserModel.userId`;
  the repos now use `where().<field>EqualTo(...).findFirst()` instead of
  `.where().findAll()` + Dart `firstWhere`. `saveSession`/`saveUser` now **upsert
  by business key** (reuse the existing Isar id) instead of duplicating on every
  save. Still O(n) by design: `getSessionsForUser` (needs an indexed `userId` on
  the session model) and `CityRepository.loadCities`/`availableFirstLetters`
  (re-read the asset each call — a caching cleanup for later).
- ✅ **Real IDs.** `game_session_bloc.dart` now stores the matched `City.id`
  (from the `ValidationOutcome`), not `cityName.hashCode`. The BLoC is also
  authoritative over the previous city (`_lastAcceptedCityName`) and accumulates
  `GameSession.score`.
- ✅ **`GameMode` / `AppLanguage` enums** (`domain/game/`) replace stringly-typed
  `mode`/`language` across the entity, events, use cases, BLoC, and UI. The Isar
  model stores stable tokens via `storageValue`/`code` and parses back with
  `fromStorage`/`fromCode` — the only string↔enum boundary. (`GameSession.id`
  stays `String`, mapped to the model's `sessionId` String; Isar's int `Id` is a
  separate internal PK — no mismatch.) Remaining: `GameSessionSummary.mode` is
  still a `String` (unwired stats path).
- ✅ **`Equatable`** added to BLoC events/states and the value objects they expose
  (`GameSession`, `City`, `ValidationOutcome`) via `equatable`. Tests now assert
  full state values (see the accepted-answer `blocTest`).
- ✅ **State model simplified to one source of truth.** `GameSessionInProgress`
  is now the single "board" state; it carries the last verdict (`lastOutcome`)
  and last `hint` inline. The transient `AnswerValidated` / `HintUsed` states are
  gone — they were rendered by `BlocBuilder` and *replaced* the board, stranding
  the player with no way back. Every in-progress emission (answer, hint, timer
  tick) goes through one `_emitInProgress` helper reading BLoC fields
  (`_lastOutcome`/`_lastHint`); a new action replaces them, a timer tick
  preserves them. UI updated (board shows verdict/hint inline; `session` field
  is now `GameSession`, not `dynamic`). Adding the missing start/revive/end
  use-case unit tests surfaced and fixed a real bug: **revive and end rebuilt the
  session without `score`, silently resetting it to 0** — the final score is now
  preserved on both.
- ✅ **Sealed `Failure`** replaces `try/catch`-into-message-string. A sealed
  `Failure` hierarchy (`domain/core/failure.dart`: `DataFailure`, `AssetFailure`,
  `SessionNotFoundFailure`, `NoActiveSessionFailure`, `UnknownFailure`) and a
  sealed `Result<T>` (`domain/core/result.dart`: `Success` / `ResultFailure`)
  are returned by all five game use cases instead of throwing across the
  domain↔presentation boundary. The BLoC pattern-matches `Result` and emits
  `GameSessionFailure(Failure)` (typed, `Equatable`); a `_guard` helper maps any
  unexpected throw to `UnknownFailure` (defense-in-depth). Rejections
  (wrong-letter / not-found / already-used) stay `Success(ValidationOutcome)` —
  only infra errors are failures. Tests assert exact failure values. Remaining:
  the interface-only user/stats use cases still return raw types (unwired path);
  the UI keeps a `GameSessionFailure.message` bridge until localization maps
  `Failure` subtypes to copy.

### P2 — hygiene

- ✅ Moved `build_runner` to `dev_dependencies` (P0).
- ✅ Removed the dead `test/widget_test.dart` counter template (P0).
- ✅ Removed the duplicate doc-comment block on `GameSessionBloc`.
- Import the `domain.dart` barrel in `main.dart` instead of each use case.

### UI / app shell (in progress)

- ✅ **App shell wired.** `main.dart` now runs `EasyLocalization` →
  `MaterialApp.router` with `buildAppTheme()` (`lib/core/theme.dart`, placeholder
  palette) and `appRouter` (`lib/core/router.dart`). Four `go_router` routes
  (`/`, `/settings`, `/game`, `/leaderboard`); the game route scopes its
  `GameSessionBloc` (built from DI use cases) so it's created on entry and
  disposed on exit. `easy_localization` is set up with `uk`/`en` under
  `assets/translations/` (fallback `en`).
- ✅ **Theme built to the shared design** (`lib/core/theme.dart`): "vibrant"
  palette (`AppColors` — coral `#FF6B5B`, teal `#17B0A6`, yellow, purple, cream
  `#FBF7F0`, ink `#22303A`, colored glows), `AppRadii`, Baloo 2 + Poppins via
  `google_fonts`, and rounded component themes. (Offline-first caveat: fonts
  fetch on first run — bundle the `.ttf`s before release.)
- ✅ **Four screens styled to the design:** Home (hero + coral/teal glow CTAs),
  Settings (language radios [live], city-list checks, gameplay toggles),
  Leaderboard (Weekly/Global/Friends pills, podium, list), and the **Game chat
  screen** (right-aligned coral city bubbles, timer badge, score, hint chip,
  rejection banner, input bar). The game route auto-starts a Ukraine session.
- ✅ **BLoC exposes chat history.** `GameSessionInProgress.history` (`List<String>`
  of accepted city names, session-language) accumulates in the BLoC; preserved
  across a revive, cleared on start. Test updated.
- ✅ **"Start with «X»" cue wired end-to-end.** `ValidationOutcome.nextLetter`
  (computed in `ValidateCityAnswerUseCaseImpl` from the accepted city via the
  same `LetterRule` backtracking) → BLoC `_requiredLetter` →
  `GameSessionInProgress.requiredLetter` → the game screen's turn banner
  (opening move shows "name any city"). Unit-tested.
- ✅ **Game-over shows the final score.** `GameSessionEnded.score` carries the
  score on timeout/surrender; the game screen has a **Surrender** action and a
  game-over view with Play Again / Home.
- ✅ **Settings wired into gameplay.** An app-wide `SettingsCubit`
  (`presentation/bloc/settings_cubit.dart`, provided above the router) holds the
  city-list selection and sound pref. The game route reads it at start:
  city-list → `GameMode` (Ukraine-only → ukraine, else world). The countdown
  always runs — per `game_design.md` §2 the timer is a fixed loss condition, so
  there is no untimed toggle. Sound flag is held but not consumed (no audio yet).
  **Persisted across launches** via `shared_preferences` (a `SettingsStore`
  abstraction backs `SettingsCubit`; see `presentation/bloc/settings_store.dart`).
  Cubit + persistence unit-tested.
- ✅ **Display language is decoupled from game mode.** `GameMode` now selects only
  the **dataset** (Ukraine-only vs World); the **display/matching language** is a
  separate `AppLanguage` sourced from the app locale (`context.locale` →
  `AppLanguage.fromCode`), so the World list can be played with Ukrainian names.
  `CityRepository.getCityByName`/`availableFirstLetters` take an explicit
  `isUkrainianLanguage` (names/first letters) distinct from `isUkraineMode`
  (dataset); `StartSession`/`StartGameSessionUseCase` carry a `language`, stored on
  `GameSession.language`, and the BLoC/use cases pick `nameUA/EN` + `firstLetterUA/EN`
  by language, not mode. Fixes the bug where World mode always showed English names.
  (Regression-tested at the use-case level: "World dataset played in Ukrainian".)
- ✅ **CityBot is the game loop (Player vs. CityBot).** `game_design.md` §2's
  main-and-only mode is implemented. `GetBotCityUseCase`
  (`domain/usecases/get_bot_city_usecase*.dart`, `@LazySingleton`) returns a
  `BotMove` (`domain/game/bot_move.dart`: the chosen `City` + the letter the player
  must then answer), picking a **random** unused city that satisfies the letter rule
  via the same `LetterRule` backtracking as validation (the `Random` is injectable
  so tests seed it; games stay varied). `GameSessionBloc` models the
  opponent turn as a **discrete `BotTurn` event** it dispatches to itself: CityBot
  opens the game, and each accepted player answer triggers a `BotTurn` reply, so the
  loop is bot-open → player-answer → bot-reply → … The used-city set is **shared**
  (the next answer's letter rule checks `_lastCityName`, the last city named by
  *either* side), the **timer resets each player turn** (`_turnDuration`), and an
  exhausted pool (bot returns `null`) ends the round (endurance framing — no
  "beat the bot" win). Chat history is now `List<ChatMessage>` (`{text, isBot}`),
  rendered as left (bot) / right (player) bubbles. Keeping `BotTurn` discrete is the
  seam for future PvP (swap `BotTurn` → a network turn). Fully unit-tested (bot
  opening, shared-chain reply, rejection-no-reply, exhausted-pool end).
- **Other design vs. code deltas (design is richer — kept to MVP):** **Play Online**
  (multiplayer — roadmap, not MVP), a **Statistics** screen and full **Win/Lose**
  screens (not yet built; simplified to one game-over view), a **3rd language
  (Español)** (app is UA/EN only), and **city-list multi-select** (domain models a
  single `GameMode`, so "both" currently plays World). Leaderboard data is a
  **UI-only stub** (not fetched). *(Settings prefs now persist across launches via
  `shared_preferences` — the old "not persisted" gap is closed.)*

### Not yet wired (expected at this stage)

`google_mobile_ads` and `supabase_flutter` are declared but unintegrated (ads,
global leaderboard). `user_profile_bloc` / `user_stats_bloc` are empty stubs; no
`UserStatsRepository` impl yet, so the absolute-new-city bonus stays gated.
