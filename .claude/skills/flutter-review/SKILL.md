---
name: flutter-review
description: Pre-commit code-review protocol for the Cities Flutter game. Use before any commit, or when the user says "review the code", "check for errors", or "pre-commit check". Checks the pure-Dart engine boundary, Cubit/state safety, data parsing and persistence, localization/theme usage, and null-safety/typing/Dartdoc, then gates the commit until issues are fixed.
---

# Flutter Code Review Protocol

Review the current changes (`git diff` plus staged changes) against
`CLAUDE.md` and the criteria below. Report a checklist of required fixes. Do
**not** produce a commit message until every item passes.

## 1. Architecture boundaries
- [ ] **The engine is pure.** Nothing in `lib/engine/` imports
      `package:flutter/*`, `dart:io`, `path_provider`, or anything under
      `data/` or `features/`.
- [ ] **Rules live in the engine.** Validation, letter rule, normalization,
      scoring, bot choice and end conditions are in `engine/`, not in Cubits or
      widgets.
- [ ] **Widgets talk only to Cubits.** No widget touches `CityCatalog`,
      `PlayerStore` or engine classes directly to *decide* anything. Reading a
      value the state already carries is fine.
- [ ] **No service locator or DI container.** Dependencies are passed through
      constructors and `RepositoryProvider`.
- [ ] **No codegen, no unapproved dependencies.** No build_runner, freezed,
      injectable, Isar, Supabase or ads. Any new `pubspec.yaml` dependency is
      justified by `tech_design.md`.
- [ ] **Scope.** The change matches its `tasks.md` task. It includes nothing
      from game_design **Future**.

## 2. Cubit & state safety
- [ ] States are `sealed` + `Equatable`. Every field is in `props`.
- [ ] There is one in-progress state. Transient info (last rejection, hint)
      rides inside it; no emit that strands the UI.
- [ ] Timers and delays are cancelled in `close()`. Nothing emits after close.
- [ ] Time and randomness are injectable (`fake_async`-testable, seeded
      `Random`).
- [ ] Every end path (win / timeout / give up) reaches the same finish logic,
      and persistence happens there.

## 3. Data & persistence
- [ ] JSON is parsed through typed `fromJson`; `dynamic` doesn't escape the
      parser.
- [ ] Heavy parsing runs off the UI isolate (`Isolate.run`).
- [ ] IO errors come back as typed failures. There's no `catch (e)` →
      `'...$e'` string and no exception thrown across a layer.
- [ ] Missing or corrupt files fall back safely (back up and reset); the app
      never crashes.
- [ ] File writes are atomic (temp file + rename). Schema changes bump
      `version`.
- [ ] City ids are GeoNames ids. Nothing is keyed by `hashCode` or a list
      index.
- [ ] Lookups use the catalog's maps (name → cities, letter → cities). There's
      no linear scan of the whole city list on a hot path.

## 4. UI, localization, theme
- [ ] No hard-coded user-visible strings. Every new key exists in **both**
      `uk.json` and `en.json`.
- [ ] Colors, radii and fonts come from `core/theme.dart` (`AppColors`,
      `AppRadii`, `heading()`, `TextTheme`).
- [ ] Layout survives a small phone and the keyboard being open (no
      overflow). The change was checked on the emulator for UI work.

## 5. Code quality
- [ ] **Null safety:** flag every `!` unless it's provably safe. No `dynamic`.
- [ ] **Enums over strings** for domain values (`CityListKind`, `Difficulty`,
      rejection reasons).
- [ ] **Named constants** for tuning values; no magic numbers in rules.
- [ ] **Dartdoc (`///`)** on public engine classes, Cubits and stores,
      explaining *why*.
- [ ] `flutter analyze` has zero issues and `flutter test` is green. No dead
      code or unused imports.

## 6. Output
- If anything fails, list the required fixes as a checklist and stop. Give no
  commit message.
- If everything passes, give the Conventional Commit message (e.g.
  `feat(engine): add answer normalization (T05)`). Only run `git commit` if
  the user asked for it.
