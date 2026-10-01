import 'dart:math';

import 'package:cities/core/theme.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/letter_rule.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/features/game/game_cubit.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/game/widgets/chat_bubble.dart';
import 'package:cities/features/game/widgets/turn_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/chain_cities.dart';
import '../../helpers/scripted_bot.dart';

// Without EasyLocalization set up, `.tr()` returns the key, so the tests
// find the keys.

/// A game view with a scripted bot, pushed over a "home" page.
Widget _app(List<City> botScript) => MaterialApp(
  theme: buildAppTheme(),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => GameCubit(
                createMatch: () => Match(
                  index: chainIndex,
                  difficulty: Difficulty.medium,
                  random: Random(1),
                  bot: ScriptedBot(chainIndex, botScript),
                ),
                random: Random(1),
              )..start(),
              child: const GameView(
                list: CityListKind.world,
                difficulty: Difficulty.medium,
                language: NameLanguage.en,
              ),
            ),
          ),
        ),
        child: const Text('home'),
      ),
    ),
  ),
);

Future<void> _openGame(WidgetTester tester, List<City> botScript) async {
  await tester.pumpWidget(_app(botScript));
  await tester.tap(find.text('home'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400)); // the page transition
}

/// Lets CityBot finish thinking.
Future<void> _botThinks(WidgetTester tester) => tester.pump(botThinkingMax);

/// The chat bubble of the city named [name].
Finder _bubble(String name) => find.byWidgetPredicate(
  (widget) => widget is ChatBubble && widget.turn.city.nameEn == name,
);

/// The parts of [name]'s bubble drawn in [color].
List<String> _inColor(WidgetTester tester, String name, Color color) {
  final text = tester
      .widget<RichText>(
        find
            .descendant(of: _bubble(name), matching: find.byType(RichText))
            .first, // the name; then the points
      )
      .text;
  final parts = <String>[];
  text.visitChildren((span) {
    if (span is TextSpan && span.style?.color == color) {
      parts.add(span.text ?? '');
    }
    return true;
  });
  return parts;
}

String? _typed(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller?.text;

/// Disposes the game, so its timers stop before the test ends.
Future<void> _close(WidgetTester tester) => tester.pumpWidget(const SizedBox());

void main() {
  testWidgets('a full game: answer, rejection, hint, win, play again', (
    tester,
  ) async {
    await _openGame(tester, [kyiv, seoul]);
    expect(find.text('game.bot_thinking'), findsOneWidget);

    await _botThinks(tester);
    expect(_bubble('Kyiv'), findsOneWidget);
    expect(_inColor(tester, 'Kyiv', AppColors.teal), [
      'v',
    ], reason: 'the next letter is teal');
    expect(find.text('game.your_turn_letter'), findsOneWidget);
    expect(find.text('30'), findsOneWidget, reason: 'the timer badge');

    // A wrong answer is shown inline and stays in the field to fix.
    await tester.enterText(find.byType(TextField), 'Paris');
    await tester.tap(find.byTooltip('game.send'));
    await tester.pump();
    expect(find.text('game.rejection.not_in_list'), findsOneWidget);
    expect(_typed(tester), 'Paris');

    // The keyboard's send action works too; an accepted answer clears it.
    await tester.enterText(find.byType(TextField), 'vilnius');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(_bubble('Vilnius'), findsOneWidget);
    expect(
      _inColor(tester, 'Vilnius', AppColors.tealLight),
      ['s'],
      reason: 'the next letter moved to the newest city',
    );
    expect(_inColor(tester, 'Kyiv', AppColors.teal), isEmpty);
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('game.rejection.not_in_list'), findsNothing);
    expect(_typed(tester), isEmpty);
    expect(find.text('game.bot_thinking'), findsOneWidget);

    await _botThinks(tester);
    expect(_bubble('Seoul'), findsOneWidget);

    await tester.tap(find.byTooltip('game.hint'));
    await tester.pump();
    expect(_bubble('Lima'), findsOneWidget);
    expect(find.text('2'), findsOneWidget, reason: 'hints left');

    // The script is over: CityBot gives up.
    await _botThinks(tester);
    expect(find.text('game.win'), findsOneWidget);
    expect(find.text('game.outcome.botGaveUp'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('game.play_again'));
    await tester.pump();
    expect(find.text('game.bot_thinking'), findsOneWidget);
    expect(_bubble('Kyiv'), findsNothing);

    await _close(tester);
  });

  testWidgets('giving up asks first, then ends the game as a loss', (
    tester,
  ) async {
    await _openGame(tester, [kyiv]);
    await _botThinks(tester);

    await tester.tap(find.byTooltip('game.give_up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('game.keep_playing'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('game.your_turn_letter'), findsOneWidget);

    await tester.tap(find.byTooltip('game.give_up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('game.give_up').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('game.loss'), findsOneWidget);
    expect(find.text('game.outcome.surrendered'), findsOneWidget);

    await _close(tester);
  });

  testWidgets('the timer runs out: a loss', (tester) async {
    await _openGame(tester, [kyiv]);
    await _botThinks(tester);

    await tester.pump(const Duration(seconds: 25));
    expect(find.text('5'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('game.loss'), findsOneWidget);
    expect(find.text('game.outcome.timeout'), findsOneWidget);

    await _close(tester);
  });

  testWidgets('back mid-game is giving up: it asks, then leaves', (
    tester,
  ) async {
    await _openGame(tester, [kyiv]);
    await _botThinks(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('game.give_up_title'), findsOneWidget);

    await tester.tap(find.text('game.give_up').last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(GameView), findsNothing);

    await _close(tester);
  });

  testWidgets(
    'the newest city marks the next letter and the skipped rare ones',
    (tester) async {
      const kremenets = City(
        id: 1,
        nameUk: 'Кременець',
        nameEn: 'Kremenets',
        countryCode: 'UA',
        population: 20000,
      );
      // «е» and «ц» start too few cities to be asked for; «ь» starts none.
      final marks = LetterRule.letterMarks(
        'Кременець',
        const {'к', 'н'},
        startingLetters: const {'к', 'н', 'е', 'ц'},
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              turn: const Turn(city: kremenets, side: Side.bot),
              language: NameLanguage.uk,
              marks: marks,
            ),
          ),
        ),
      );
      final finder = find.byType(ChatBubble);
      expect(finder, findsOneWidget);
      final text = tester.widget<RichText>(
        find.descendant(of: finder, matching: find.byType(RichText)),
      );
      final colored = <String, String>{};
      text.text.visitChildren((span) {
        final color = span.style?.color;
        if (span is TextSpan && color != null) {
          colored[span.text ?? ''] = switch (color) {
            AppColors.coral => 'first',
            AppColors.teal => 'next',
            _ => 'other',
          };
        }
        return true;
      });
      expect(colored, {
        'К': 'first',
        'н': 'next',
        // «е» and «ц» may be played too: the same teal.
        'е': 'next',
        'ц': 'next',
      }, reason: '«реме» and «ь» are plain');
    },
  );

  test('allowed letters are quoted and joined with "or"', () {
    // Without EasyLocalization, 'game.or'.tr() is the key itself.
    expect(quoteLetters(['к']), '«К»');
    expect(quoteLetters(['к', 'е']), '«К» game.or «Е»');
    expect(quoteLetters(['н', 'е', 'ц']), '«Н», «Е» game.or «Ц»');
  });
}
