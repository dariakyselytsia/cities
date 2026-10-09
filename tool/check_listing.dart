// Checks the store listing text in store/listing-*.md against each field's
// character limit, the number in brackets after the field's heading (T22).
//
//   dart run tool/check_listing.dart
//
// Exits with 1 if any field is too long.

import 'dart:io';

final _field = RegExp(r'## (.+?) \[(\d+)\]\n\n```\n(.*?)\n```', dotAll: true);

void main() {
  var over = false;
  final files =
      Directory('store')
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'listing-\w+\.md$').hasMatch(f.path))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final text = file.readAsStringSync().replaceAll('\r\n', '\n');
    stdout.writeln(file.path);
    for (final match in _field.allMatches(text)) {
      final name = match.group(1) ?? '';
      final limit = int.parse(match.group(2) ?? '0');
      final length = (match.group(3) ?? '').runes.length;
      final ok = length <= limit;
      over |= !ok;
      stdout.writeln(
        '  ${ok ? 'ok  ' : 'OVER'} ${'$length'.padLeft(5)} / $limit  $name',
      );
    }
  }
  if (over) exit(1);
}
