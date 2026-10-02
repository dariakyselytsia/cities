import 'dart:convert';
import 'dart:io';

import 'package:cities/core/placeholder_screen.dart';
import 'package:cities/core/router.dart';
import 'package:cities/core/theme.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Without EasyLocalization set up, `.tr()` returns the key, so the tests
// find the keys.

final _catalog = CityCatalog.fromJson(
  jsonDecode(File('test/fixtures/cities_fixture.json').readAsStringSync()),
);

Widget _app(GoRouter router) => RepositoryProvider.value(
  value: _catalog,
  child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
);

/// Lets a page transition finish (a focused text field's cursor blinks
/// forever, so `pumpAndSettle` can't be used on the game).
Future<void> _transition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Scrolls Play into view (the test screen is short) and taps it.
Future<void> _tapPlay(WidgetTester tester) async {
  await tester.ensureVisible(find.text('home.play'));
  await tester.tap(find.text('home.play'));
}

void main() {
  testWidgets('Home → Game → (give up) → Home', (tester) async {
    await tester.pumpWidget(_app(createRouter()));
    expect(find.byType(HomeScreen), findsOneWidget);

    await _tapPlay(tester);
    await _transition(tester);
    expect(find.byType(GameView), findsOneWidget);
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.list, CityListKind.ukraine);
    expect(game.difficulty, Difficulty.medium);

    // Back mid-game asks first; giving up returns Home.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await _transition(tester);
    await tester.tap(find.text('game.give_up').last);
    await _transition(tester);
    expect(find.byType(GameView), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox()); // Stops the game's timers.
  });

  testWidgets('Game over → Home', (tester) async {
    await tester.pumpWidget(_app(createRouter()));
    await _tapPlay(tester);
    await _transition(tester);

    await tester.tap(find.byTooltip('game.give_up'));
    await _transition(tester);
    await tester.tap(find.text('game.give_up').last);
    await _transition(tester);
    expect(find.text('game.loss'), findsOneWidget);

    await tester.tap(find.text('game.home'));
    await _transition(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(GameView), findsNothing);
  });

  for (final (tooltip, title) in [
    ('statistics.title', 'statistics.title'),
    ('settings.title', 'settings.title'),
  ]) {
    testWidgets('Home → $title → back', (tester) async {
      await tester.pumpWidget(_app(createRouter()));
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  }

  testWidgets('the stats card opens Statistics', (tester) async {
    await tester.pumpWidget(_app(createRouter()));
    await tester.ensureVisible(find.text('home.best_chain'));
    await tester.tap(find.text('home.best_chain'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceholderScreen), findsOneWidget);
  });

  testWidgets('a game link opens that game; a bad one goes Home', (
    tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(_app(router));

    router.go(Routes.gameFor(CityListKind.world, Difficulty.hard));
    await _transition(tester);
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.list, CityListKind.world);
    expect(game.difficulty, Difficulty.hard);

    router.go('/game?list=mars&difficulty=medium');
    await _transition(tester);
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
