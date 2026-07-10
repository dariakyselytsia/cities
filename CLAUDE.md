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

- **Implement the full core game algorithm** (the P0 use cases are baselines):
  last-valid-letter rule with ь/и soft-sign backtracking, per-session uniqueness,
  scoring + absolute-new-city bonus (needs persisted historic `usedCityIds`).
  Lives in `validate_city_answer_usecase_impl.dart` / `use_hint_usecase_impl.dart`.
- **Fix User/UserStats persistence.** `Map` fields and the `UserModel.stats`
  `@Collection`-as-field were `@ignore`d to unblock codegen — they are NOT
  persisted. Model them properly: serialize maps (JSON string or embedded list)
  and link `User`↔`UserStats` via `IsarLink`.
- **Replace full-table scans with indexed queries** in
  `city_repository_impl.getCityByName` and
  `game_session_repository_impl.getSession/getSessionsForUser` (see Coding
  standards → Indexed Isar queries).
- **Stop fabricating IDs.** `game_session_bloc.dart` uses `cityName.hashCode` as a
  used-city id — carry the real `City.id`.
- **Introduce `GameMode` / `AppLanguage` enums** and reconcile `GameSession.id`
  type with its Isar model.
- **Add `Equatable`** to BLoC events/states, then strengthen tests to assert
  values.
- **Simplify the state model** — a correct answer currently double-emits
  `GameSessionInProgress` + `AnswerValidated` (the latter carries no session).
  Prefer one source-of-truth in-progress state carrying the last result.
- **Sealed `Failure`** instead of `try/catch`-into-message-string.

### P2 — hygiene

- ✅ Moved `build_runner` to `dev_dependencies` (P0).
- ✅ Removed the dead `test/widget_test.dart` counter template (P0).
- Remove the duplicate doc-comment block on `GameSessionBloc`.
- Import the `domain.dart` barrel in `main.dart` instead of each use case.

### Not yet wired (expected at this stage)

`go_router`, `easy_localization`, `google_mobile_ads`, `supabase_flutter` are
declared but unintegrated; `main.dart` uses a plain
`MaterialApp(home: GameSessionScreen())`. `user_profile_bloc` /
`user_stats_bloc` are empty stubs.
