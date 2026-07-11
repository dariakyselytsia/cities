---
name: flutter-review
description: Pre-commit code-review protocol for the Cities Flutter game. Use before any commit, or when the user says "review the code", "check for errors", or "pre-commit check". Evaluates Clean Architecture layer separation, BLoC state-management safety, Isar indexing, and null-safety/typing/Dartdoc, then gates the commit until issues are fixed.
---

# Flutter Code Review Protocol

As an Expert Flutter Architect, rigorously review the current changes **before any
commit**. Review the working diff (`git diff` / staged changes) against these
criteria. Report a checklist of required fixes; do **not** produce the commit
command until every item passes.

## 1. Clean Architecture violations

- [ ] **Domain isolation:** `domain/` contains **no** references to Flutter UI
      (`package:flutter/*`), `isar`, or `supabase`. Pure Dart entities and
      abstract repositories/use cases only.
- [ ] **Data mapping:** `data/` correctly maps Isar/Supabase models ⇄ domain
      entities (via `fromDomain`/`toDomain`). No UI code in this layer.
- [ ] **Presentation boundaries:** Widgets communicate only with BLoCs, never
      directly with repositories.

## 2. State management (BLoC) safety

- [ ] **No logic in UI:** No calculations, string parsing, timer logic, or
      validation inside widgets — all of it belongs in a BLoC.
- [ ] **Event/State naming:** BLoC events and states follow clear, consistent
      names (e.g. `GameTimerTicked`, `GameScoreUpdated`, `GameSessionFailure`).
- [ ] **Failure handling:** Errors surface as sealed failure states, not
      unhandled exceptions; the app never crashes on a DB miss.

## 3. Database (Isar) optimization

- [ ] **No table scans.** Reject `collection.where().findAll()` followed by a
      Dart-side `firstWhere`/filter — it's an O(n) scan that defeats Isar. Require
      indexed queries (`.filter().<field>EqualTo(...)`). This is a known offender
      in `city_repository_impl.getCityByName` and
      `game_session_repository_impl.getSession/getSessionsForUser`.
- [ ] **Indexing:** Every field queried by equality carries `@Index()` (e.g.
      `firstLetterUA`/`firstLetterEN`, and `nameUA`/`nameEN`,
      `GameSessionModel.sessionId` once those are queried through indexes).
- [ ] **Schema regen:** If Isar `@Collection` models changed, the `.g.dart` files
      were regenerated — remind the user to run
      `dart run build_runner build --delete-conflicting-outputs`
      (or use the **flutter-codegen** skill).

## 3b. Project standards (see CLAUDE.md → Coding standards)

- [ ] **Sealed failures, not string errors.** Errors surface as a sealed
      `Failure` + typed failure state — reject `catch (e)` that stuffs `'...$e'`
      into a message, and reject exceptions thrown across layer boundaries.
- [ ] **Enums, not magic strings.** `mode`/`language` use `GameMode` /
      `AppLanguage` enums — flag any `'UA'`/`'WORLD'`/`'en'` string literals.
- [ ] **Real IDs.** Reject `hashCode` or any fabricated value used as an entity id
      (known offender: `game_session_bloc.dart` used-city ids). Carry `City.id`.
- [ ] **`Equatable`/`freezed` on BLoC events & states** so value assertions are
      possible.
- [ ] **No leaking `dynamic`.** Untyped `json.decode` access (`e['id']` …) must be
      wrapped in a typed `fromJson`; `dynamic` must not escape `data/`.
- [ ] **DI wired.** New repositories/use cases are actually registered
      (`@LazySingleton`/`@Injectable`) and resolvable from `getIt`, and any needed
      `Isar` instance is provided by a real injectable `@module` — not a
      hand-written stub.

## 4. Code quality & formatting

- [ ] **Null safety:** Flag every `!` (bang) operator unless provably 100% safe;
      suggest `if (x != null)`, `?.`, or `??`.
- [ ] **No `dynamic`:** Enforce explicit typing everywhere.
- [ ] **Dartdoc:** Public repositories, BLoCs, and non-trivial use cases have
      `///` comments explaining *why* (especially algorithmic choices).
- [ ] **Analyzer clean:** `flutter analyze` passes with zero warnings; no dead
      code or unused imports.

## 5. Actionable feedback

- If any check fails, output a concise checklist of the required fixes and stop —
  do **not** generate the commit command.
- If everything passes, provide the Conventional Commit command to stage and
  commit (e.g. `git add -A && git commit -m "feat(game): add countdown timer bloc"`).
