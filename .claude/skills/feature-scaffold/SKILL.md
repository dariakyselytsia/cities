---
name: feature-scaffold
description: Scaffold a new Clean-Architecture feature for the Cities Flutter game end to end. Use when adding a new use case, entity, repository, or BLoC (e.g. "add a leaderboard feature", "add a new usecase/bloc"). Walks domain → data → presentation → test following the existing project patterns, keeping strict layer separation.
---

# Feature Scaffold (Clean Architecture)

Build a new feature by moving outward through the layers, mirroring the patterns
already in the codebase. Keep strict layer separation and the **Coding standards**
in `CLAUDE.md` (sealed failures, enums, indexed Isar queries, `Equatable`, real
IDs, typed JSON). Read `game_design.md` first if the feature is gameplay- or
product-facing.

> New code must be born compliant — don't replicate the scaffold's known gaps
> (stringly-typed modes, `hashCode` ids, `.where().findAll()` scans, interface-only
> use cases, states without `Equatable`).

## Reference files (copy these patterns)

- Entity: `lib/domain/entities/city.dart` — plain immutable class, `const` ctor.
- Abstract repository: `lib/domain/repositories/city_repository.dart`.
- Abstract use case: `lib/domain/usecases/validate_city_answer_usecase.dart`
  (callable class with `call(...)`).
- Data model + impl: `lib/data/models/city_model.dart` (Isar `@Collection`,
  `@Index()`, `fromDomain`/`toDomain`) and
  `lib/data/repositories/city_repository_impl.dart`
  (`@LazySingleton(as: XRepository)`).
- BLoC: `lib/presentation/bloc/game_session_bloc.dart` (events/states/handlers,
  use-case injection, try/catch → failure state).
- Test: `test/presentation/bloc/game_session_bloc_test.dart`
  (`bloc_test` + `mocktail`).

## Steps

1. **Domain — entity** (`lib/domain/entities/<name>.dart`): pure Dart, immutable,
   `const` constructor. No Flutter/Isar/Supabase imports. Use **enums** for
   categorical fields (`GameMode`, `AppLanguage`), and keep id types consistent
   with the Isar model. Add `Equatable` if the entity is compared by value.

2. **Domain — repository interface**
   (`lib/domain/repositories/<name>_repository.dart`): abstract methods only,
   returning domain entities (or a sealed `Failure` on the error path — do not
   throw across the boundary).

3. **Domain — use case(s)** (`lib/domain/usecases/<verb>_<name>_usecase.dart`):
   abstract callable class exposing `call(...)`, **plus a concrete implementation**
   — an interface alone is not a finished feature (the current codebase has
   interfaces without impls; do not repeat that). One use case per user intent.

4. **Data — model** (`lib/data/models/<name>_model.dart`): Isar `@Collection`
   class with `Id id = Isar.autoIncrement;`, `@Index()` on **every field queried
   by equality**, and `fromDomain()` / `toDomain()` converters. Add
   `part '<name>_model.g.dart';`. If it parses JSON, give it a typed `fromJson` —
   no `dynamic` leaking out.

5. **Data — repository impl**
   (`lib/data/repositories/<name>_repository_impl.dart`): annotate
   `@LazySingleton(as: <Name>Repository)`, inject `Isar` (and/or Supabase),
   implement the interface, map models ⇄ entities, use `writeTxn` for writes, and
   query through **indexed `.filter()` queries** — never `.where().findAll()` +
   Dart-side `firstWhere`.

6. **Codegen:** run the **flutter-codegen** skill (build_runner + analyze) so the
   Isar `.g.dart` and DI config regenerate.

7. **Presentation — BLoC** (`lib/presentation/bloc/<name>_bloc.dart`): define
   events and sealed states, **all with `Equatable`/`freezed`** (so tests assert
   values); constructor-inject the use cases; handle each event with `on<Event>`
   and wrap failures into a `<Name>Failure` carrying a typed `Failure`. No logic in
   widgets. Prefer a single source-of-truth in-progress state over transient
   double-emits.

8. **Presentation — page/widgets** (`lib/presentation/pages/`): UI talks only to
   the BLoC via `BlocBuilder`/`BlocListener`.

9. **Wiring:** register the BLoC/use cases where the app provides them and ensure
   the repository is resolvable from `getIt` (DI is not fully wired yet — see
   `CLAUDE.md` "known gaps").

10. **Test** (`test/presentation/bloc/<name>_bloc_test.dart`): `bloc_test` +
    `mocktail`, cover every event/state and failure paths. Then run the
    **test-review** skill.

11. **Verify & review:** `flutter analyze` + `flutter test` green, then run the
    **flutter-review** skill before committing with a Conventional Commit.
