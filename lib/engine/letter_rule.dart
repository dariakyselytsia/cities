/// Pure implementation of the "next city" letter rule from `game_design.md`.
///
/// The next city must start with the **last valid letter** of the previous city.
/// A letter is "valid" only if at least one city in the current dataset starts
/// with it — so trailing letters that nothing starts with (the Ukrainian soft
/// sign `ь`, `и`, `й`, apostrophes, whitespace, …) are skipped by walking
/// backwards until a playable letter is found. This dataset-driven approach
/// needs no hard-coded exception list: whatever letters are unplayable in the
/// current mode are simply absent from [availableFirstLetters] and get skipped.
class LetterRule {
  const LetterRule._();

  /// Returns the letter the next city must start with, given the [previousCity]
  /// name and the set of lower-cased first letters that exist in the current
  /// mode's dataset. Returns `null` when the previous city has no playable
  /// trailing letter at all (a dead end).
  static String? requiredNextLetter(
    String previousCity,
    Set<String> availableFirstLetters,
  ) {
    final normalized = previousCity.trim().toLowerCase();
    for (var i = normalized.length - 1; i >= 0; i--) {
      final ch = normalized[i];
      if (availableFirstLetters.contains(ch)) return ch;
    }
    return null;
  }

  /// Whether [candidateFirstLetter] (the answer's first letter) satisfies the
  /// rule for [previousCity]. The opening move ([previousCity] empty) is always
  /// allowed.
  static bool isValidNext({
    required String previousCity,
    required String candidateFirstLetter,
    required Set<String> availableFirstLetters,
  }) {
    if (previousCity.trim().isEmpty) return true;
    final required = requiredNextLetter(previousCity, availableFirstLetters);
    if (required == null) return false;
    return candidateFirstLetter.toLowerCase() == required;
  }
}
