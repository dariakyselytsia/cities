import 'dart:convert';
import 'dart:io';

import 'package:cities/core/theme.dart';
import 'package:cities/data/player_store.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/features/settings/settings_cubit.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:cities/features/stats/stats_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_player_store.dart';

// Without EasyLocalization set up, `.tr()` returns the key, so the tests
// find the keys.

/// The 5-city fixture catalog.
final fixtureCatalog = CityCatalog.fromJson(
  jsonDecode(File('test/fixtures/cities_fixture.json').readAsStringSync()),
);

/// What `main.dart` provides above the app: the catalog, the player store
/// (a fresh fake unless given), and the setup, settings and stats Cubits on
/// that store.
Widget _appProviders({
  required Widget child,
  PlayerStore? store,
  SetupCubit? setup,
  SettingsCubit? settings,
}) {
  final playerStore = store ?? FakePlayerStore();
  return RepositoryProvider<PlayerStore>.value(
    value: playerStore,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => setup ?? SetupCubit(playerStore)),
        BlocProvider(create: (_) => settings ?? SettingsCubit(playerStore)),
        BlocProvider(create: (_) => StatsCubit(playerStore)),
      ],
      child: RepositoryProvider.value(value: fixtureCatalog, child: child),
    ),
  );
}

/// The app around [router], with what `main.dart` provides.
Widget testApp(
  GoRouter router, {
  PlayerStore? store,
  SetupCubit? setup,
  SettingsCubit? settings,
}) => _appProviders(
  store: store,
  setup: setup,
  settings: settings,
  child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
);

/// Lets a page or sheet transition finish (a focused text field's cursor
/// blinks forever, so `pumpAndSettle` can't be used on the game).
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Taps Home's Play (scrolled into view: the test screen is short), which
/// opens the setup sheet. [play] is its label: the key without translations.
Future<void> openSetup(WidgetTester tester, {String play = 'home.play'}) async {
  await tester.ensureVisible(find.text(play));
  await tester.tap(find.text(play));
  await settle(tester);
}

/// Opens the setup sheet and starts a game with the current choice.
Future<void> startGame(
  WidgetTester tester, {
  String play = 'home.play',
  String start = 'setup.start',
}) async {
  await openSetup(tester, play: play);
  await tester.ensureVisible(find.text(start));
  await tester.tap(find.text(start));
  await settle(tester);
}

/// Sets up `easy_localization` for widget tests: it reads and saves the
/// language with shared_preferences, so that plugin's channel gets an empty,
/// in-memory store.
Future<void> setUpLocalization() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/shared_preferences'),
        (call) async =>
            call.method.startsWith('getAll') ? <String, Object>{} : true,
      );
  await EasyLocalization.ensureInitialized();
}

/// [testApp] with the real translations, starting in [startLocale], so
/// switching language re-renders real text.
Widget localizedTestApp(
  GoRouter router, {
  Locale startLocale = const Locale('uk'),
  SettingsCubit? settings,
}) => EasyLocalization(
  supportedLocales: const [Locale('uk'), Locale('en')],
  path: 'assets/translations',
  fallbackLocale: const Locale('en'),
  startLocale: startLocale,
  saveLocale: false,
  child: _appProviders(
    settings: settings,
    child: Builder(
      builder: (context) => MaterialApp.router(
        theme: buildAppTheme(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
      ),
    ),
  ),
);

/// Pumps a [localizedTestApp] and waits until its translations are loaded
/// (until then, `Localizations` shows nothing): they're read from files in
/// real time, which fake test time can't wait for.
Future<void> pumpLocalized(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  for (var i = 0; i < 50 && find.byType(Navigator).evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
