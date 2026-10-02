import 'package:bloc_test/bloc_test.dart';
import 'package:cities/core/router.dart';
import 'package:cities/data/player_data.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/settings/settings_cubit.dart';
import 'package:cities/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_player_store.dart';
import '../../helpers/test_app.dart';

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.settings_rounded));
  await tester.pumpAndSettle();
}

/// The app bar's back button (`pageBack` looks for an English tooltip).
Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(setUpLocalization);

  group('SettingsCubit', () {
    test('CityBot starts for a new player', () {
      expect(
        SettingsCubit(FakePlayerStore()).state,
        const Settings(firstTurn: Side.bot),
      );
    });

    test('starts from the saved settings', () {
      final store = FakePlayerStore(
        const PlayerData(settings: Settings(firstTurn: Side.player)),
      );
      expect(
        SettingsCubit(store).state,
        const Settings(firstTurn: Side.player),
      );
    });

    late FakePlayerStore store;
    blocTest<SettingsCubit, Settings>(
      'remembers and saves who starts',
      setUp: () => store = FakePlayerStore(),
      build: () => SettingsCubit(store),
      act: (cubit) => cubit.setFirstTurn(Side.player),
      expect: () => const [Settings(firstTurn: Side.player)],
      verify: (_) => expect(
        store.data,
        const PlayerData(settings: Settings(firstTurn: Side.player)),
      ),
    );
  });

  testWidgets('"Me" makes the player open the next game', (tester) async {
    final settings = SettingsCubit(FakePlayerStore());
    await tester.pumpWidget(testApp(createRouter(), settings: settings));
    await _openSettings(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await _tapText(tester, 'settings.first_turn_player');
    expect(settings.state.firstTurn, Side.player);

    await _back(tester);
    await startGame(tester);
    // No bot move: the player's turn, any city, and the clock runs.
    expect(find.text('game.your_turn_any'), findsOneWidget);
    expect(find.byType(GameView), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the licenses page opens from About', (tester) async {
    await tester.pumpWidget(testApp(createRouter()));
    await _openSettings(tester);
    await _tapText(tester, 'settings.licenses');
    expect(find.byType(LicensePage), findsOneWidget);
  });

  // Last, and the only test with real translations: easy_localization keeps
  // them loaded for the rest of the file (so `.tr()` would stop returning
  // keys), and a load started in one test can't finish in the next.
  testWidgets('switching language re-renders the app (About included), and '
      'game names follow it', (tester) async {
    await pumpLocalized(tester, localizedTestApp(createRouter()));
    expect(find.text('Грати'), findsOneWidget);

    await _openSettings(tester);
    expect(find.text('Налаштування'), findsOneWidget);
    await _tapText(tester, 'English');
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Who starts'), findsOneWidget);

    // About: the version and the GeoNames CC BY 4.0 attribution.
    await tester.ensureVisible(find.text('Licenses'));
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(
      find.textContaining('GeoNames (geonames.org), licensed under CC BY 4.0'),
      findsOneWidget,
    );

    await _back(tester);
    expect(find.text('Play'), findsOneWidget);

    // A new game shows its cities in English.
    await startGame(tester, play: 'Play', start: 'Start');
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.language.name, 'en');
    // CityBot's city is shown by its English name (the Ukraine list of the
    // fixture: Kyiv, Lviv, Kharkiv).
    await tester.pump(botThinkingMax);
    final shown = [
      for (final name in ['Kyiv', 'Lviv', 'Kharkiv'])
        if (find.text(name, findRichText: true).evaluate().isNotEmpty) name,
    ];
    expect(shown, hasLength(1));

    await tester.pumpWidget(const SizedBox()); // Stops the game's timers.
  });
}
