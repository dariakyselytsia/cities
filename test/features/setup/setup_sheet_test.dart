import 'package:cities/core/router.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/home/home_screen.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:cities/features/setup/setup_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_player_store.dart';
import '../../helpers/test_app.dart';

/// Whether the option titled [title] is marked selected.
bool _isSelected(WidgetTester tester, String title) => tester
    .widgetList<Semantics>(
      find.ancestor(of: find.text(title), matching: find.byType(Semantics)),
    )
    .any((semantics) => semantics.properties.selected ?? false);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pump();
}

void main() {
  testWidgets('Play opens the sheet with Ukraine / Medium chosen', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(createRouter()));
    await openSetup(tester);

    expect(find.byType(SetupSheet), findsOneWidget);
    expect(_isSelected(tester, 'list.ukraine'), isTrue);
    expect(_isSelected(tester, 'list.world'), isFalse);
    expect(_isSelected(tester, 'difficulty.medium'), isTrue);
    // Each difficulty shows its seconds per turn.
    expect(find.text('setup.turn_time'), findsNWidgets(3));
  });

  testWidgets('the chosen list and difficulty drive the game, and are '
      'remembered', (tester) async {
    final setup = SetupCubit(FakePlayerStore());
    await tester.pumpWidget(testApp(createRouter(), setup: setup));
    await openSetup(tester);
    await _tap(tester, 'list.world');
    await _tap(tester, 'difficulty.hard');
    expect(_isSelected(tester, 'list.world'), isTrue);
    expect(_isSelected(tester, 'difficulty.hard'), isTrue);

    await _tap(tester, 'setup.start');
    // While CityBot thinks, the badge shows the turn time the player will
    // get: Hard's 20 s.
    await tester.pump();
    expect(find.text('${Difficulty.hard.turnTime.inSeconds}'), findsOneWidget);
    await settle(tester);
    expect(find.byType(SetupSheet), findsNothing);
    final game = tester.widget<GameView>(find.byType(GameView));
    expect(game.list, CityListKind.world);
    expect(game.difficulty, Difficulty.hard);
    await tester.pump(botThinkingMax);

    // Leave the game; the sheet opens with the last choice.
    await tester.tap(find.byTooltip('game.give_up'));
    await settle(tester);
    await tester.tap(find.text('game.give_up').last);
    await settle(tester);
    await tester.tap(find.text('game.home'));
    await settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    await openSetup(tester);
    expect(_isSelected(tester, 'list.world'), isTrue);
    expect(_isSelected(tester, 'difficulty.hard'), isTrue);
    expect(
      setup.state,
      const GameSetup(list: CityListKind.world, difficulty: Difficulty.hard),
    );
  });

  testWidgets('dismissing the sheet starts nothing', (tester) async {
    await tester.pumpWidget(testApp(createRouter()));
    await openSetup(tester);
    await tester.tapAt(const Offset(10, 10)); // the barrier above the sheet
    await settle(tester);
    expect(find.byType(SetupSheet), findsNothing);
    expect(find.byType(GameView), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
