import 'package:isar_community/isar.dart';

part 'stat_entries.g.dart';

/// Embedded key/value rows used to persist domain `Map`s in Isar, which cannot
/// store maps directly. A map is stored as a `List` of these entries and
/// rebuilt at the model boundary (see `fromDomain`/`toDomain`). Fully typed —
/// no `dynamic` and no JSON-string round-tripping.

/// One entry of a `Map<int, int>` (e.g. cityId → usage count).
@embedded
class IntIntEntry {
  int key = 0;
  int value = 0;

  IntIntEntry();
  IntIntEntry.of(this.key, this.value);
}

/// One entry of a `Map<String, int>` (e.g. mode token → high score).
@embedded
class StringIntEntry {
  String key = '';
  int value = 0;

  StringIntEntry();
  StringIntEntry.of(this.key, this.value);
}

/// One entry of a `Map<String, double>` (e.g. mode token → percent discovered).
@embedded
class StringDoubleEntry {
  String key = '';
  double value = 0;

  StringDoubleEntry();
  StringDoubleEntry.of(this.key, this.value);
}
