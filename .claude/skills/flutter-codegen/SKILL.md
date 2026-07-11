---
name: flutter-codegen
description: Run Dart code generation (build_runner) and verify the build for the Cities Flutter game. Use after editing anything that requires codegen — @injectable DI modules, Isar @Collection models, or freezed classes — or when generated .g.dart / DI config is stale or missing. Regenerates, runs flutter analyze, and fixes warnings before commit.
---

# Flutter Codegen & Verification

Use whenever a change touches code that depends on `build_runner`:

- Isar `@Collection` models (regenerates `*.g.dart` schema)
- `@injectable` / `@LazySingleton` DI registrations (regenerates the injectable
  config)
- `freezed` classes, if introduced

## Steps

1. **Ensure deps are present:**
   ```bash
   flutter pub get
   ```
   Note: `build_runner` currently sits under regular `dependencies` in
   `pubspec.yaml` — it belongs in `dev_dependencies`. Flag this if you touch the
   file, but it does not block generation.

2. **Regenerate:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   Use `--delete-conflicting-outputs` to avoid stale-output conflicts. For an
   active editing session, `dart run build_runner watch --delete-conflicting-outputs`
   is an option.

3. **Confirm outputs updated:** the relevant `*.g.dart` files (Isar models) and
   the injectable config regenerated. If DI codegen produced a real generated
   config, ensure `lib/di/` wires `getIt.init()` to it (today
   `lib/di/injectable_config.dart` is an empty hand-written stub — replacing it
   with real generated output is the intended direction).

4. **Analyze & fix:**
   ```bash
   flutter analyze
   ```
   Fix **all** warnings and errors — no dead code, no unused imports.

5. **Test:**
   ```bash
   flutter test
   ```

6. **Only then** proceed to commit (Conventional Commits) or hand back to
   **flutter-review**.

## Notes

- Never hand-edit generated `*.g.dart` files — change the source annotation and
  regenerate.
- If generation fails, read the first error in the build log; it's usually a
  malformed annotation or a missing `part '<file>.g.dart';` directive.
