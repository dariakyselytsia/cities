import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:cities/data/city_loader.dart';
import 'package:cities/engine/city.dart';
import 'package:cities/engine/city_catalog.dart';
import 'package:cities/features/startup/load_error_screen.dart';
import 'package:cities/features/startup/splash_screen.dart';
import 'package:cities/features/startup/startup_cubit.dart';
import 'package:cities/features/startup/startup_gate.dart';
import 'package:cities/features/startup/startup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';

/// A loader that fails [failures] times, then succeeds.
class _FlakyLoader extends CityLoader {
  _FlakyLoader({this.failures = 0});

  int failures;
  final catalog = CityCatalog(const [
    City(id: 1, nameUk: 'Київ', nameEn: 'Kyiv', countryCode: 'UA', population: 1),
  ]);

  @override
  Future<CityLoadResult> load() async {
    if (failures > 0) {
      failures--;
      return const CitiesLoadFailed(CityLoadFailure.invalidData);
    }
    return CitiesLoaded(catalog, Duration.zero);
  }
}

/// A cubit that starts out ready, for widget tests.
class _ReadyCubit extends StartupCubit {
  _ReadyCubit(CityCatalog catalog) : super(CityLoader()) {
    emit(StartupReady(catalog));
  }
}

void main() {
  group('StartupCubit', () {
    final loader = _FlakyLoader();

    blocTest<StartupCubit, StartupState>(
      'loading → ready',
      build: () => StartupCubit(loader),
      act: (cubit) => cubit.load(),
      expect: () => [const StartupLoading(), StartupReady(loader.catalog)],
    );

    blocTest<StartupCubit, StartupState>(
      'loading → failed → (retry) loading → ready',
      build: () => StartupCubit(_FlakyLoader(failures: 1)),
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      expect: () => [
        const StartupLoading(),
        const StartupFailed(CityLoadFailure.invalidData),
        const StartupLoading(),
        isA<StartupReady>(),
      ],
    );

    test('with the real loader and the fixture asset', () async {
      final fixture =
          File('test/fixtures/cities_fixture.json').readAsStringSync();
      final cubit = StartupCubit(
        CityLoader(bundle: FakeAssetBundle({citiesAssetPath: fixture})),
      );
      await cubit.load();
      expect(cubit.state, isA<StartupReady>());
      await cubit.close();
    });
  });

  group('StartupGate', () {
    Widget app(StartupCubit cubit, {Widget? home}) => BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            builder: (context, child) => StartupGate(child: child!),
            home: home ?? const Text('home'),
          ),
        );

    testWidgets('shows the splash while loading', (tester) async {
      await tester.pumpWidget(app(StartupCubit(_FlakyLoader())));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });

    testWidgets('shows the error screen, and retries from it', (tester) async {
      final cubit = StartupCubit(_FlakyLoader(failures: 1));
      await tester.pumpWidget(app(cubit));
      await cubit.load();
      await tester.pump();
      expect(find.byType(LoadErrorScreen), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(find.text('home'), findsOneWidget, reason: 'the retry worked');
    });

    testWidgets('once ready, shows the app and provides the catalog',
        (tester) async {
      final catalog = _FlakyLoader().catalog;
      CityCatalog? provided;
      await tester.pumpWidget(app(
        _ReadyCubit(catalog),
        home: Builder(builder: (context) {
          provided = context.read<CityCatalog>();
          return const Text('home');
        }),
      ));
      expect(find.text('home'), findsOneWidget);
      expect(provided, same(catalog));
    });
  });
}
