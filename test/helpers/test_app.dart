import 'dart:convert';
import 'dart:io';

import 'package:cities/core/theme.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/features/setup/setup_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Without EasyLocalization set up, `.tr()` returns the key, so the tests
// find the keys.

/// The 5-city fixture catalog.
final fixtureCatalog = CityCatalog.fromJson(
  jsonDecode(File('test/fixtures/cities_fixture.json').readAsStringSync()),
);

/// The app around [router], with what `main.dart` provides: the catalog and
/// the setup choice.
Widget testApp(GoRouter router, {SetupCubit? setup}) => MultiBlocProvider(
  providers: [BlocProvider(create: (_) => setup ?? SetupCubit())],
  child: RepositoryProvider.value(
    value: fixtureCatalog,
    child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  ),
);

/// Lets a page or sheet transition finish (a focused text field's cursor
/// blinks forever, so `pumpAndSettle` can't be used on the game).
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Taps Home's Play (scrolled into view: the test screen is short), which
/// opens the setup sheet.
Future<void> openSetup(WidgetTester tester) async {
  await tester.ensureVisible(find.text('home.play'));
  await tester.tap(find.text('home.play'));
  await settle(tester);
}

/// Opens the setup sheet and starts a game with the current choice.
Future<void> startGame(WidgetTester tester) async {
  await openSetup(tester);
  await tester.ensureVisible(find.text('setup.start'));
  await tester.tap(find.text('setup.start'));
  await settle(tester);
}
