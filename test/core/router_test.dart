import 'package:cities/core/placeholder_screen.dart';
import 'package:cities/core/router.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/home/home_screen.dart';
import 'package:cities/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

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
    ('statistics.title', PlaceholderScreen),
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
    expect(find.byType(PlaceholderScreen), findsOneWidget);
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
