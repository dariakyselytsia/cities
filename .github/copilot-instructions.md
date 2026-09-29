# Cities (Міста) — Copilot instructions

An offline Flutter word game.
- The player duels **CityBot**: each city starts with the last valid letter
  of the previous one.
- The player has a per-turn countdown, and wins when the bot runs out of
  cities it knows.
- Ukraine or World city lists; Ukrainian and English UI.

**Read first:**
- `game_design.md`: rules, scope, and what is *Future*.
- `tech_design.md`: stack, architecture, data.
- `tasks.md`: the task board, worked in order.

`CLAUDE.md` holds the full conventions. These instructions summarize them.

## Stack
- Flutter/Dart with `flutter_bloc` (**Cubits**), `equatable`, `go_router`,
  `easy_localization` (uk/en) and `path_provider` (player data as a JSON
  file).
- Tests: `bloc_test`, `fake_async`.
- **Not used:** code generation (build_runner/freezed/injectable), Isar or any
  database, get_it, Supabase, ads.
- City data is a bundled JSON asset loaded into memory.
- Fonts are bundled: Nunito (headings) and Rubik (body).

## Architecture
```
lib/main.dart      composition root (no DI container)
lib/app.dart       MaterialApp + theme + localization
lib/core/          theme (AppColors, AppRadii, AppFonts, heading()), router
lib/engine/        PURE DART game rules — no Flutter, no dart:io; Random/time injected
lib/data/          city_loader (asset → isolate → CityCatalog), player_store (JSON file)
lib/features/<x>/  <x>_cubit.dart, <x>_state.dart, <x>_screen.dart, widgets/
```

## Rules
- Game rules live in `engine/`. Cubits own timers and flow. Widgets only
  render Cubit state.
- States and outcomes are `sealed` + `Equatable`. A wrong answer is a value
  (`Rejected(reason)`), not an error. IO failures are typed values, never
  stringified exceptions, and the app never crashes on bad data.
- Enums, not strings, for domain values. City ids are GeoNames ids. Parse JSON
  with typed `fromJson`. No `dynamic`, no unchecked `!`.
- All UI text is localized, with keys added to **both** `uk.json` and
  `en.json`. Styling comes from `core/theme.dart`.
- Tuning values (tiers, timers, points) are named constants.
- `///` Dartdoc on public engine classes, Cubits and stores, explaining *why*.

## Workflow
1. Take the next task in `tasks.md`. Branch from **`main`**:
   `feature/T07-city-catalog`, `fix/…` or `chore/…`.
2. Build only that task, and meet its **Done when** criteria.
3. `flutter analyze` must be clean and `flutter test` green. Check UI changes
   on the Android emulator (`Pixel_8_API_36`).
4. Tick the task in `tasks.md`, then commit with Conventional Commits
   (`feat(engine): add city catalog (T06)`).
