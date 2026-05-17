# Unit Test Review Protocol

As an Expert Flutter Architect, rigorously review all unit tests before merging. Use this checklist for every test PR:

## 1. Test Structure & Coverage
- [ ] **Arrange-Act-Assert:** Each test follows the AAA pattern for clarity.
- [ ] **Coverage:** All public BLoC events, states, and use case methods have corresponding tests.
- [ ] **Edge Cases:** Tests include both typical and edge/failure scenarios.

## 2. Isolation & Mocking
- [ ] **No Real Dependencies:** All repositories, use cases, and external services are mocked/faked.
- [ ] **No Side Effects:** Tests do not read/write real files, databases, or network.

## 3. Naming & Readability
- [ ] **Descriptive Names:** Test names clearly state the scenario and expected outcome.
- [ ] **No Magic Values:** Use named constants or builders for test data.

## 4. Assertions & Error Handling
- [ ] **State Assertions:** All expected state transitions are asserted (using bloc_test for BLoCs).
- [ ] **Error Handling:** Failure and exception paths are tested and asserted.

## 5. Maintainability
- [ ] **No Duplicated Logic:** Use setUp/tearDown and helpers to avoid repetition.
- [ ] **Dartdoc:** Complex test suites and custom matchers are documented.

## 6. Actionable Feedback
If any item fails, output a checklist of required fixes. Only approve/merge when all checks pass.
