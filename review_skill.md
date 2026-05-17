# Code Review Protocol

As an Expert Flutter Architect, you must rigorously review code before any commit is made. Whenever asked to "review the code", "check for errors", or perform a "pre-commit check", evaluate the current workspace against these strict criteria:

## 1. Clean Architecture Violations
- [ ] **Domain Layer Isolation:** Ensure the `domain/` folder contains absolutely NO references to Flutter UI (`package:flutter/material.dart`, etc.) or external packages like `isar` or `supabase`. It must only contain pure Dart entities and abstract repositories.
- [ ] **Data Layer Mapping:** Ensure the `data/` layer correctly maps Isar/Supabase models to Domain entities. No UI code here.
- [ ] **Presentation Layer:** Ensure widgets only communicate with BLoCs, not directly with Repositories.

## 2. State Management (BLoC) Safety
- [ ] **Logic in UI:** Are there any complex calculations, string parsing, or timer logic inside Widgets? If yes, flag them. All logic MUST be in BLoC.
- [ ] **Event/State Naming:** Ensure BLoC events and states follow a clear naming convention (e.g., `GameTimerTicked`, `GameScoreUpdated`).

## 3. Database (Isar) Optimization
- [ ] **Indexing:** Check if the `City` model has the `@Index()` annotation on the `firstLetter` field for fast O(1) lookups.
- [ ] **Schema Generation:** If Isar models were modified, remind the user to run `flutter pub run build_runner build`.

## 4. Code Quality & Formatting
- [ ] **Null Safety:** Flag any use of the `!` (bang) operator unless absolutely 100% safe. Suggest safe unwrapping (`if (value != null)` or `?`).
- [ ] **Avoid Dynamic:** Ensure `dynamic` is not used anywhere. Enforce strict typing.
- [ ] **Dartdoc:** Ensure public methods, Repositories, and BLoCs have `///` explanatory comments.

## 5. Actionable Feedback
If the code fails any of these checks, output a checklist of required fixes. Do NOT generate the commit command until these are resolved. If the code passes, provide the terminal command to stage and commit the changes using Conventional Commits.