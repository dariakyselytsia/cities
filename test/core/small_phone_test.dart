import 'dart:convert';
import 'dart:io';

import 'package:cities/core/router.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/features/game/widgets/chat_bubble.dart';
import 'package:cities/features/game/widgets/game_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// The real text of [key] (`home.play`) in [locale]'s translations.
String _t(Locale locale, String key) {
  Object? value = jsonDecode(
    File('assets/translations/${locale.languageCode}.json').readAsStringSync(),
  );
  for (final part in key.split('.')) {
    value = (value as Map<String, Object?>)[part];
  }
  return value as String;
}

/// An iPhone SE (1st gen): 320 × 568 points.
const _screen = Size(320, 568);

/// A phone keyboard: about 260 points tall.
const _keyboard = 260.0;

/// Loads the bundled fonts, so text is as wide as on a phone (the test
/// font's square glyphs are much wider).
Future<void> _loadFonts() async {
  for (final (family, files) in [
    ('Nunito', ['SemiBold', 'Bold', 'ExtraBold']),
    ('Rubik', ['Regular', 'Medium', 'SemiBold']),
  ]) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('assets/fonts/$family-$file.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(() async {
    await setUpLocalization();
    await _loadFonts();
  });

  for (final locale in const [Locale('uk'), Locale('en')]) {
    testWidgets(
      'on a 320 × 568 phone in ${locale.languageCode}: Play is on screen, '
      'the setup sheet stacks the lists, and with the keyboard open the '
      'city to answer stays visible',
      (tester) async {
        tester.view
          ..physicalSize = _screen * 2
          ..devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        await pumpLocalized(
          tester,
          localizedTestApp(createRouter(), startLocale: locale),
        );

        // Home: Play fits without scrolling (T21's compact layout).
        final play = find.text(_t(locale, 'home.play_sub'));
        expect(tester.getRect(play).bottom, lessThan(_screen.height));

        // The setup sheet: the lists are stacked, so no word breaks.
        await openSetup(tester, play: _t(locale, 'home.play'));
        final ukraine = tester.getRect(find.text(_t(locale, 'list.ukraine')));
        final world = tester.getRect(find.text(_t(locale, 'list.world')));
        expect(world.top, greaterThan(ukraine.bottom));
        expect(tester.takeException(), isNull);

        // A game with the keyboard open: the board turns compact.
        final start = find.text(_t(locale, 'setup.start'));
        await tester.ensureVisible(start);
        await tester.tap(start);
        await settle(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard * 2);
        await tester.pump(botThinkingMax);
        await tester.pump();

        expect(find.byType(StatPills), findsNothing);
        final bubble = find
            .descendant(
              of: find.byType(ChatBubble),
              matching: find.byType(RichText),
            )
            .hitTestable();
        expect(bubble, findsOneWidget, reason: "CityBot's city is visible");
        expect(
          tester.getRect(bubble).bottom,
          lessThan(_screen.height - _keyboard),
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox()); // stops the game's timers
      },
    );
  }
}
