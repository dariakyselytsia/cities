---
name: feature-scaffold
description: Scaffold a feature for the Cities Flutter game end to end — pure-Dart engine logic, data access, Cubit + state, screen, and tests — following tech_design.md. Use when implementing a task from tasks.md or adding a new screen, Cubit, engine rule, or store (e.g. "implement T11", "add the setup sheet", "add a new engine rule").
---

# Feature Scaffold

Build outward from the pure-Dart core. Follow `CLAUDE.md` (rules + coding
standards) and `tech_design.md`. If the feature is gameplay- or UI-facing, read
the relevant part of `game_design.md` first. If it's a task from `tasks.md`,
its **Done when** list is the definition of finished.

## 0. Plan
- Identify which layers the feature touches: `engine/`, `data/`,
  `features/<name>/`, `core/`. Many tasks touch only one or two.
- List the behaviors to test *before* writing code: rules, edge cases, and end
  conditions.

## 1. Engine (`lib/engine/`) — only if there are rules
- Pure Dart only: no `package:flutter`, no `dart:io`, no assets.
- Inject `Random` and durations; never call `DateTime.now()` or `Random()`
  inside rules.
- Value classes are immutable with `const` constructors and `Equatable`.
  Outcomes are `sealed` classes (`Accepted` / `Rejected(reason)`, `BotMove.city`
  / `BotMove.giveUp`).
- Tuning numbers (tiers, timers, points) are named constants, e.g. in
  `difficulty.dart` / `scoring.dart`.
- `///` Dartdoc explaining *why* for any non-obvious rule.
- **Tests first-class:** `test/engine/<file>_test.dart`, plain `test()` with
  real objects and no mocks. Use table-driven cases for normalization and
  letter rules, and seeded `Random` for the bot and match.

## 2. Data (`lib/data/`) — only if it reads assets or files
- Parse JSON through typed `fromJson`; `dynamic` stays inside the parser.
- Heavy parsing goes in `Isolate.run`.
- Errors come back as typed failure values (sealed), never thrown to the
  caller and never stringified.
- If a Cubit test will need to fake it, define a small abstract interface
  (like `PlayerStore`) plus the file-backed implementation.
- Tests: fixture files under `test/fixtures/`, and a temp directory for file
  I/O. Cover the missing-file and corrupt-file paths.

## 3. Cubit (`lib/features/<name>/<name>_cubit.dart` + `<name>_state.dart`)
- The state is a `sealed` hierarchy with `Equatable` (e.g. `GameLoading` /
  `GamePlaying` / `GameOver`). Keep one source-of-truth "in progress" state.
  Put transient info (last rejection) *inside* it rather than emitting
  separate states.
- The Cubit owns timers/delays (`Timer`, `Future.delayed`) and calls `engine/`
  and `data/`. It holds no game rules itself.
- Dependencies come in through the constructor. There is no service locator.
- Cancel timers in `close()`.
- Tests: `test/features/<name>/<name>_cubit_test.dart` with `bloc_test`.
  Use `fake_async` for anything time-based. Assert **exact** states, not just
  `isA<>()`.

## 4. Screen & widgets (`lib/features/<name>/<name>_screen.dart`, `widgets/`)
- Only `BlocBuilder` / `BlocListener` / `BlocConsumer`, with no logic in
  widgets.
- Styling: `AppColors`, `AppRadii`, `heading()` and the `TextTheme` from
  `core/theme.dart`.
- If you're porting a screen, take its look from `archive/v0`:
  `git show archive/v0:lib/presentation/pages/<file>.dart`. Copy **visuals
  only**, never the old wiring.
- Every user-visible string goes through `easy_localization`, with keys in
  **both** `assets/translations/uk.json` and `en.json`.
- Tests: a widget smoke test (renders each state, main tap paths).

## 5. Wiring
- Build long-lived dependencies in `main.dart` and provide them with
  `RepositoryProvider`.
- Create the Cubit where the route/screen is built (`BlocProvider`) so it's
  disposed on exit.
- Add routes in `core/router.dart` (after T14).

## 6. Verify
- `flutter analyze` is clean and `flutter test` is green.
- UI changes: run on the emulator and check a screenshot. See `CLAUDE.md` →
  Dev environment.
- Run **test-review** on new tests and **flutter-review** on the diff.
- Tick the task in `tasks.md`, then end with the wrap-up (commit message ·
  summary · next steps).
