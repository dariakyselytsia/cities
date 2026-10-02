import 'package:cities/core/router.dart';
import 'package:cities/data/player_data.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/home/home_screen.dart';
import 'package:cities/features/settings/settings_screen.dart';
import 'package:cities/features/stats/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_player_store.dart';
import '../helpers/test_app.dart';

/// The stats card's two numbers: the longest chain, then cities discovered.
List<String> _statCard(WidgetTester tester) => [
  for (final label in ['home.best_chain', 'home.cities_discovered'])
    tester
            .widget<Text>(
              find
                  .descendant(
                    of: find
                        .ancestor(
                          of: find.text(label),
                          matching: find.byType(Column),
                        )
                        .first,
                    matching: find.byType(Text),
                  )
                  .first,
            )
            .data ??
        '',
];

void main() {
  testWidgets('Home → Game → (give up) → Home', (tester) async {
    await tester.pumpWidget(testApp(createRouter()));
    expect(find.byType(HomeScreen), findsOneWidget);

    await startGame(tester);
    expect(find.byType(GameView), findsOneWidget);
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.list, CityListKind.ukraine);
    expect(game.difficulty, Difficulty.medium);

    // Back mid-game asks first; giving up returns Home.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await settle(tester);
    await tester.tap(find.text('game.give_up').last);
    await settle(tester);
    expect(find.byType(GameView), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // Stops the game's timers.
  });

  testWidgets('Game over → Home', (tester) async {
    await tester.pumpWidget(testApp(createRouter()));
    await startGame(tester);

    await tester.tap(find.byTooltip('game.give_up'));
    await settle(tester);
    await tester.tap(find.text('game.give_up').last);
    await settle(tester);
    expect(find.text('game.loss'), findsOneWidget);

    await tester.tap(find.text('game.home'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(GameView), findsNothing);
  });

  for (final (title, screen) in [
    ('statistics.title', StatsScreen),
    ('settings.title', SettingsScreen),
  ]) {
    testWidgets('Home → $title → back', (tester) async {
      await tester.pumpWidget(testApp(createRouter()));
      await tester.tap(find.byTooltip(title));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }

  testWidgets('the stats card opens Statistics', (tester) async {
    await tester.pumpWidget(testApp(createRouter()));
    await tester.ensureVisible(find.text('home.best_chain'));
    await tester.tap(find.text('home.best_chain'));
    await tester.pumpAndSettle();
    expect(find.byType(StatsScreen), findsOneWidget);
  });

  testWidgets('the stats card shows saved progress, and a finished game '
      'updates it', (tester) async {
    final store = FakePlayerStore(
      PlayerData(
        discoveredIds: {2988507, 1275339}, // Paris, Mumbai
        longestChain: 4,
        settings: const Settings(firstTurn: Side.player),
      ),
    );
    await tester.pumpWidget(testApp(createRouter(), store: store));
    expect(_statCard(tester), ['4', '2']);

    // Name Kyiv, then give up while CityBot thinks.
    await startGame(tester);
    await tester.enterText(find.byType(TextField), 'Kyiv');
    await tester.tap(find.byTooltip('game.send'));
    await tester.pump();
    await tester.tap(find.byTooltip('game.give_up'));
    await settle(tester);
    await tester.tap(find.text('game.give_up').last);
    await settle(tester);
    await tester.tap(find.text('game.home'));
    await settle(tester);

    expect(find.byType(HomeScreen), findsOneWidget);
    // The longest chain stays 4 (this one was 1); Kyiv is discovered.
    expect(_statCard(tester), ['4', '3']);
    expect(store.data.gamesPlayed, 1);
  });

  testWidgets('a game link opens that game; a bad one goes Home', (
    tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(testApp(router));

    router.go(Routes.gameFor(CityListKind.world, Difficulty.hard));
    await settle(tester);
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.list, CityListKind.world);
    expect(game.difficulty, Difficulty.hard);

    router.go('/game?list=mars&difficulty=medium');
    await settle(tester);
    expect(find.byType(GameView), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  test('game links carry the setup as names', () {
    expect(
      Routes.gameFor(CityListKind.ukraine, Difficulty.easy),
      '/game?list=ukraine&difficulty=easy',
    );
  });
}
