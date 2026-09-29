---
name: test-review
description: Unit-test review protocol for the Cities Flutter game. Use when reviewing or writing tests, or before merging test changes. Checks AAA structure, coverage of engine rules / Cubit states / data failure paths, determinism (seeded Random, fake_async), fakes over mocks, value-based assertions, naming, and maintainability.
---

# Unit Test Review Protocol

Review every test change against this checklist.

Test layout mirrors `lib/`:
- `test/engine/` holds plain unit tests;
- `test/data/` holds fixture- and temp-dir-based tests;
- `test/features/` holds `bloc_test` Cubit tests and widget smoke tests.

## 1. Structure & coverage
- [ ] **Arrange-Act-Assert** is visible in each test.
- [ ] **Engine:** every rule and outcome is covered, including:
  - each rejection reason (not in list / wrong letter / already used);
  - letter-rule backtracking (`ь`, `и`, `й`, apostrophes);
  - normalization cases;
  - tier boundaries;
  - bot give-up;
  - scoring (new city vs. seen, hint = 0, win bonus);
  - each end condition.
- [ ] **Cubits:** every public method and every state transition is covered,
      including the win, timeout and give-up paths.
- [ ] **Data:** round-trip, missing file, corrupt file, version mismatch.
- [ ] **Edge cases,** not just the happy path.

## 2. Determinism & isolation
- [ ] **Seeded randomness:** bot and match tests pass an explicit `Random(seed)`.
      No real randomness in assertions.
- [ ] **Fake time:** anything with timers or delays runs under `fake_async`.
      No real `Future.delayed` waits and no flaky sleeps.
- [ ] **Real objects over mocks.**
  - The engine is pure: test it with real objects and small fixture catalogs.
  - Use hand-written fakes for interfaces (e.g. `FakePlayerStore`).
  - Add `mocktail` only if a fake becomes unwieldy; it's not in the stack by
    default.
- [ ] **No side effects:** no network. File I/O only in a temp dir that's
      cleaned up. No real app documents directory.

## 3. Naming & readability
- [ ] Descriptions state the scenario and the expected outcome ("rejects a
      city already used by the bot").
- [ ] Test data uses named fixtures or builders (`kyiv`, `lviv`,
      `fixtureCatalog()`), not unexplained literals.
- [ ] Table-driven cases (input → expected) for normalization and the letter
      rule.

## 4. Assertions
- [ ] **Exact values, not types.** Assert full `Equatable` states and outcomes
      (score, timer seconds, history, reason), not bare `isA<>()`.
- [ ] **Failure paths assert the typed failure** that was produced, not just
      "something failed".
- [ ] Interaction checks on fakes (e.g. "saved once on game over") where
      behavior depends on them.

## 5. Maintainability
- [ ] Shared setup goes in `setUp` or helper builders; no copy-pasted
      arrangements.
- [ ] Fixtures live in `test/fixtures/` and stay small: only the cities the
      tests need.
- [ ] Complex suites have a short `///` note on what they cover and why.

## 6. Output
- If anything fails, list the required fixes and withhold approval.
- Approve only when every check passes and `flutter test` is green.
