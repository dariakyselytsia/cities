import 'package:cities/core/router.dart';
import 'package:cities/data/player_data.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/features/setup/setup_sheet.dart';
import 'package:cities/features/stats/statistics.dart';
import 'package:cities/features/stats/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_player_store.dart';
import '../../helpers/test_app.dart';

Future<void> _openStats(WidgetTester tester, FakePlayerStore store) async {
  await tester.pumpWidget(testApp(createRouter(), store: store));
  await tester.tap(find.byTooltip('statistics.title'));
  await tester.pumpAndSettle();
  expect(find.byType(StatsScreen), findsOneWidget);
}

/// The fixture's Kyiv, Lviv and Paris: two of 3 Ukraine cities, three of 5
/// World cities.
final _played = PlayerData(
  discoveredIds: const {703448, 702550, 2988507},
  gamesPlayed: 4,
  gamesWon: 3,
  longestChain: 9,
  records: {
    const GameSetup(list: CityListKind.world, difficulty: Difficulty.hard):
        const ModeRecord(wins: 3, losses: 1, bestScore: 310),
  },
);

void main() {
  testWidgets('a new player sees a welcome, and Play opens the setup sheet', (
    tester,
  ) async {
    await _openStats(tester, FakePlayerStore());
    expect(find.text('statistics.empty_title'), findsOneWidget);
    expect(find.text('statistics.records'), findsNothing);

    await tester.tap(find.text('home.play'));
    await settle(tester);
    expect(find.byType(SetupSheet), findsOneWidget);
  });

  testWidgets('the summary, the six modes and discovery', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await _openStats(tester, FakePlayerStore(_played));

    // Summary: played, won, win rate, longest chain, discovered.
    expect(find.text('4'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2)); // games won, and discovered
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);

    // One mode played (World · Hard): 3 : 1, best 310; the other five "—".
    expect(find.text('3 : 1', findRichText: true), findsOneWidget);
    expect(find.text('310'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(5));

    // Discovery: 2 of 3 Ukraine cities, 3 of 5 World cities.
    expect(find.text('66.7%'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);
    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .map((bar) => bar.value);
    expect(bars, [closeTo(2 / 3, 1e-9), 0.6]);
  });

  test('shares: one decimal; a found city never shows as 0.0%', () {
    String share(int found, int total, [String locale = 'en']) =>
        StatsScreen.formatShare(Discovery(found: found, total: total), locale);
    expect(share(0, 7177), '0.0%');
    expect(share(2, 7177), '< 0.1%');
    expect(share(8, 7177), '0.1%');
    expect(share(1, 848), '0.1%');
    expect(share(848, 848), '100.0%');
    expect(share(2, 7177, 'uk'), '< 0,1%');
  });

  testWidgets('it updates when a game is recorded', (tester) async {
    final store = FakePlayerStore();
    await _openStats(tester, store);
    expect(find.text('statistics.empty_title'), findsOneWidget);

    await store.update((data) => _played);
    await tester.pump();
    expect(find.text('statistics.empty_title'), findsNothing);
    expect(find.text('75%'), findsOneWidget);
  });
}
