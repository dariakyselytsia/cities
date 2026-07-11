---
name: test-review
description: Unit-test review protocol for the Cities Flutter game. Use when reviewing or writing unit tests, or before merging test changes. Checks AAA structure, full BLoC event/state and use-case coverage, mocking/isolation, naming, bloc_test state assertions, and maintainability. Reference suite: test/presentation/bloc/game_session_bloc_test.dart.
---

# Unit Test Review Protocol

As an Expert Flutter Architect, rigorously review unit tests before merging. Apply
this checklist to every test change. The existing
`test/presentation/bloc/game_session_bloc_test.dart` is the reference for the
project's `bloc_test` + `mocktail` style.

## 1. Structure & coverage

- [ ] **Arrange-Act-Assert:** Each test clearly separates setup, action, and
      assertion.
- [ ] **Coverage:** Every public BLoC event, emitted state, and use-case method
      has a corresponding test.
- [ ] **Edge cases:** Both typical and edge/failure scenarios are covered (timer
      expiry, invalid city, duplicate city, repository throw, etc.).

## 2. Isolation & mocking

- [ ] **No real dependencies:** Repositories, use cases, and external services are
      mocked/faked (`class MockX extends Mock implements XUseCase`).
- [ ] **No side effects:** Tests never touch real files, databases, or the
      network.
- [ ] **Data-layer isolation:** Repository/data-layer tests use a mocked repo or a
      fake/registered `Isar` instance — never open a real database. Prefer testing
      through the domain interface with `mocktail`.

## 3. Naming & readability

- [ ] **Descriptive names:** Test descriptions state the scenario and expected
      outcome.
- [ ] **No magic values:** Test data uses named constants or builders.

## 4. Assertions & error handling

- [ ] **Value-based assertions, not just types.** Once BLoC states have
      `Equatable`/`freezed`, assert the *actual* emitted values — exact score,
      `timerSeconds`, session/history — via concrete state instances. Bare
      `isA<State>()` alone is insufficient (the current
      `game_session_bloc_test.dart` only type-checks; strengthen it as states gain
      `Equatable`).
- [ ] **Error paths:** Failure and exception paths are asserted, and assert the
      **typed `Failure`** carried by the failure state — not merely that *some*
      failure was emitted.
- [ ] **Interaction checks:** Use `verify(...)` / `any(named: ...)` to confirm the
      right use cases were invoked.

## 5. Maintainability

- [ ] **No duplicated logic:** `setUp`/`tearDown` and helper builders remove
      repetition.
- [ ] **Dartdoc:** Complex suites and custom matchers are documented.

## 6. Actionable feedback

- If any item fails, output a checklist of required fixes and withhold approval.
- Only approve/merge when every check passes, and confirm `flutter test` is green.
