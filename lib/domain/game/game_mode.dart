/// Game modes available in the MVP. Extensible for future modes (capitals,
/// specific countries) — see `game_design.md` roadmap.
enum GameMode {
  ukraine,
  world;

  /// Whether only Ukrainian cities are valid. Also selects the UA name fields
  /// and dataset during gameplay.
  bool get isUkraine => this == GameMode.ukraine;

  /// Stable token persisted in Isar and used by legacy JSON data.
  String get storageValue => isUkraine ? 'UA' : 'WORLD';

  /// Parses a stored/legacy token back into a [GameMode]. Anything that is not
  /// `'UA'` is treated as [GameMode.world].
  static GameMode fromStorage(String value) =>
      value.trim().toUpperCase() == 'UA' ? GameMode.ukraine : GameMode.world;
}
