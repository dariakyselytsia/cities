// Renders the store screenshots and the Play feature graphic (T22) from the
// real screens, with the real fonts and city data, in both languages:
//
//   flutter test tool/render_store_images.dart
//
// Output, in store/screenshots/<size>/<language>/:
//   1-home.png, 2-game.png (a duel in progress), 3-win.png, 4-stats.png
// for Google Play phones (1080 × 1920) and the App Store's 6.9″ iPhone
// (1320 × 2868), plus store/feature-graphic-<language>.png (1024 × 500).
//
// The games are scripted (ScriptedBot) and the statistics are sample data,
// so the images come out the same on every run. Rerun it after UI changes.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cities/core/brand.dart';
import 'package:cities/core/router.dart';
import 'package:cities/core/theme.dart';
import 'package:cities/data/player_data.dart';
import 'package:cities/data/player_store.dart';
import 'package:cities/engine/bot.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/engine/city_list.dart';
import 'package:cities/engine/difficulty.dart';
import 'package:cities/engine/match.dart';
import 'package:cities/features/game/game_cubit.dart';
import 'package:cities/features/game/game_screen.dart';
import 'package:cities/features/settings/settings_cubit.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:cities/features/stats/stats_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers/fake_player_store.dart';
import '../test/helpers/fonts.dart';
import '../test/helpers/scripted_bot.dart';
import '../test/helpers/test_app.dart';
import 'src/png.dart';

/// A store's screenshot size: [pixels] at [pixelRatio], with the phone's
/// status bar and home indicator areas left empty ([top], [bottom], in
/// logical pixels).
typedef _Device = ({
  String name,
  Size pixels,
  double pixelRatio,
  double top,
  double bottom,
});

const List<_Device> _devices = [
  // Play: 9:16 (Play rejects images more than twice as tall as wide). 2.625
  // makes it a 411 × 731 phone.
  (
    name: 'play',
    pixels: Size(1080, 1920),
    pixelRatio: 2.625,
    top: 24,
    bottom: 0,
  ),
  // App Store 6.9″ (iPhone 16 Pro Max class): 440 × 956 points.
  (
    name: 'ios-6.9',
    pixels: Size(1320, 2868),
    pixelRatio: 3,
    top: 54,
    bottom: 34,
  ),
];

/// The scripted duel in each language, on the World list: CityBot's cities,
/// the player's answers (the last one wins the game), and what the player
/// is typing in the mid-duel shot.
const _duels = {
  'en': (
    bot: ['Paris', 'Lisbon', 'Istanbul'],
    player: ['Seoul', 'Nairobi', 'London'],
    typing: 'Lo',
  ),
  'uk': (
    bot: ['Лондон', 'Лісабон', 'Ісламабад'],
    player: ['Неаполь', 'Найробі', 'Дублін'],
    typing: 'Ду',
  ),
};

const _list = CityListKind.world;
const _difficulty = Difficulty.medium;

final _shot = GlobalKey();

void main() {
  late CityCatalog catalog;

  setUpAll(() async {
    await setUpLocalization();
    await loadAppFonts(icons: true);
    catalog = CityCatalog.fromJson(
      jsonDecode(File('assets/data/cities.json').readAsStringSync()),
    );
  });

  // One test for everything: after a test ends, easy_localization doesn't
  // load its translations again in the next one.
  testWidgets('store images', (tester) async {
    // Real, blurred shadows (tests draw them flat by default); restored
    // before the test ends, as the framework requires.
    debugDisableShadows = false;
    try {
      for (final device in _devices) {
        for (final locale in const [Locale('uk'), Locale('en')]) {
          await _screens(tester, catalog, device, locale);
        }
      }
      for (final locale in const [Locale('uk'), Locale('en')]) {
        await _featureGraphic(tester, catalog, locale);
      }
    } finally {
      debugDisableShadows = true;
    }
  });
}

/// Home, the duel, the win and Statistics on [device] in [locale].
Future<void> _screens(
  WidgetTester tester,
  CityCatalog catalog,
  _Device device,
  Locale locale,
) async {
  // A fresh tree, so the previous app's language isn't reused.
  await tester.pumpWidget(const SizedBox());
  final language = locale.languageCode;
  final dir = 'store/screenshots/${device.name}/$language';
  _useDevice(tester, device);
  final duel = _duels[language]!;
  final store = FakePlayerStore(_sampleData(catalog, duel.player));

  // Home and Statistics, through the app's router.
  final router = createRouter();
  await _pumpUntil(
    tester,
    _app(
      locale: locale,
      store: store,
      catalog: catalog,
      child: (context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
      ),
    ),
  );
  await _capture(tester, device, '$dir/1-home.png');
  router.push(Routes.stats);
  await tester.pumpAndSettle();
  await _capture(tester, device, '$dir/4-stats.png');

  // The duel, with a scripted CityBot. A fresh tree first: the next
  // app's translations load only once no Navigator is left.
  await tester.pumpWidget(const SizedBox());
  final index = catalog.index(
    _list,
    language == 'uk' ? NameLanguage.uk : NameLanguage.en,
  );
  City city(String name) => index.lookup(name).first;
  final cubit = GameCubit(
    createMatch: (discoveredIds) => Match(
      index: index,
      difficulty: _difficulty,
      random: Random(1),
      discoveredIds: discoveredIds,
      firstTurn: Side.bot,
      bot: ScriptedBot(index, [for (final name in duel.bot) city(name)]),
    ),
    store: store,
    random: Random(1),
  );
  await _pumpUntil(
    tester,
    _app(
      locale: locale,
      store: store,
      catalog: catalog,
      child: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: BlocProvider.value(
          value: cubit..start(),
          child: GameView(
            list: _list,
            difficulty: _difficulty,
            language: index.language,
          ),
        ),
      ),
    ),
  );
  for (final answer in duel.player.take(2)) {
    await tester.pump(botThinkingMax);
    cubit.submit(answer);
    await tester.pump();
  }
  await tester.pump(botThinkingMax);
  await tester.enterText(find.byType(TextField), duel.typing);
  await tester.pump(const Duration(seconds: 7)); // the clock runs
  await tester.pump(const Duration(milliseconds: 600)); // cursor on
  await _capture(tester, device, '$dir/2-game.png');

  cubit.submit(duel.player.last);
  await tester.pump(botThinkingMax); // CityBot has nothing left
  await tester.pump(const Duration(seconds: 1));
  await _capture(tester, device, '$dir/3-win.png');

  await tester.pumpWidget(const SizedBox()); // stops the timers
  await cubit.close();
}

const _Device _featureDevice = (
  name: 'feature',
  pixels: Size(1024, 500),
  pixelRatio: 1,
  top: 0,
  bottom: 0,
);

/// The Play feature graphic in [locale].
Future<void> _featureGraphic(
  WidgetTester tester,
  CityCatalog catalog,
  Locale locale,
) async {
  await tester.pumpWidget(const SizedBox());
  _useDevice(tester, _featureDevice);
  await _pumpUntil(
    tester,
    _app(
      locale: locale,
      store: FakePlayerStore(),
      catalog: catalog,
      child: (context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const _FeatureGraphic(),
      ),
    ),
  );
  await _capture(
    tester,
    _featureDevice,
    'store/feature-graphic-${locale.languageCode}.png',
  );
}

/// Pumps [app] and waits until its translations have loaded and the first
/// route is built: they're read from files in real time, which fake test
/// time alone can't wait for, and the loading also needs fake time to pass
/// (like `pumpLocalized`, without its `pumpAndSettle`: the game's cursor
/// blinks forever).
Future<void> _pumpUntil(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  for (var i = 0; i < 500 && find.byType(Navigator).evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  if (find.byType(Navigator).evaluate().isEmpty) {
    throw StateError('The app did not build: translations not loaded');
  }
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void _useDevice(WidgetTester tester, _Device device) {
  tester.view
    ..physicalSize = device.pixels
    ..devicePixelRatio = device.pixelRatio
    ..padding = FakeViewPadding(
      top: device.top * device.pixelRatio,
      bottom: device.bottom * device.pixelRatio,
    );
  addTearDown(tester.view.reset);
}

/// What `main.dart` provides, around [child], with the real translations
/// and the full city catalog; wrapped in the boundary that is captured.
Widget _app({
  required Locale locale,
  required PlayerStore store,
  required CityCatalog catalog,
  required Widget Function(BuildContext context) child,
}) => RepaintBoundary(
  key: _shot,
  child: EasyLocalization(
    supportedLocales: const [Locale('uk'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: locale,
    saveLocale: false,
    child: RepositoryProvider<PlayerStore>.value(
      value: store,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SetupCubit(store)),
          BlocProvider(create: (_) => SettingsCubit(store)),
          BlocProvider(create: (_) => StatsCubit(store)),
        ],
        child: RepositoryProvider.value(
          value: catalog,
          child: Builder(builder: child),
        ),
      ),
    ),
  ),
);

/// A player with a few weeks of games: wins and losses in most modes, and
/// the best-known cities discovered (but not the duel's, so they are new).
PlayerData _sampleData(CityCatalog catalog, List<String> duelCities) {
  final byPopulation = [...catalog.cities]
    ..sort((a, b) => b.population.compareTo(a.population));
  final ukrainian = byPopulation.where((c) => c.countryCode == 'UA');
  final skip = {
    for (final name in duelCities) ...[name.toLowerCase()],
  };
  bool keep(City c) =>
      !skip.contains(c.nameEn.toLowerCase()) &&
      !skip.contains((c.name(NameLanguage.uk) ?? '').toLowerCase());
  return PlayerData(
    discoveredIds: {
      for (final c in byPopulation.where(keep).take(140)) c.id,
      for (final c in ukrainian.where(keep).take(45)) c.id,
    },
    records: {
      const GameSetup(list: CityListKind.ukraine, difficulty: Difficulty.easy):
          const ModeRecord(wins: 6, losses: 1, bestScore: 420),
      const GameSetup(
        list: CityListKind.ukraine,
        difficulty: Difficulty.medium,
      ): const ModeRecord(
        wins: 4,
        losses: 3,
        bestScore: 610,
      ),
      const GameSetup(list: CityListKind.world, difficulty: Difficulty.easy):
          const ModeRecord(wins: 3, losses: 1, bestScore: 380),
      const GameSetup(list: CityListKind.world, difficulty: Difficulty.medium):
          const ModeRecord(wins: 2, losses: 2, bestScore: 520),
      const GameSetup(list: CityListKind.world, difficulty: Difficulty.hard):
          const ModeRecord(losses: 2, bestScore: 240),
    },
    gamesPlayed: 24,
    gamesWon: 15,
    longestChain: 18,
    lastSetup: const GameSetup(list: _list, difficulty: _difficulty),
  );
}

/// Saves the app as the device shows it, without an alpha channel.
Future<void> _capture(WidgetTester tester, _Device device, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_shot),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: device.pixelRatio);
    await writePng(image, path, opaque: true);
    image.dispose();
  });
}

/// The Play feature graphic: the brand badge, the name and the tagline over
/// Home's color blobs.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    Widget blob(double size, Color color) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    return Material(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned(
            left: -160,
            bottom: -220,
            child: blob(520, AppColors.teal.withValues(alpha: 0.28)),
          ),
          Positioned(
            right: -140,
            top: -200,
            child: blob(500, AppColors.yellow),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandBadge(size: 200),
                const SizedBox(width: 56),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'app_title'.tr(),
                      style: heading(size: 110, weight: FontWeight.w800),
                    ),
                    Text(
                      'home.tagline'.tr(),
                      style: heading(
                        size: 32,
                        weight: FontWeight.w600,
                        color: AppColors.coral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
