import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/city_loader.dart';
import 'data/player_store.dart';
import 'features/settings/settings_cubit.dart';
import 'features/setup/setup_cubit.dart';
import 'features/startup/startup_cubit.dart';
import 'features/stats/stats_cubit.dart';

/// Composition root. There is no DI container: dependencies are built here
/// and handed down explicitly (tech_design §2).
///
/// The city catalog loads in the background behind a splash
/// (`StartupGate`), so the first frame isn't held up by 1.9 MB of JSON. The
/// player's data is small, so it's read before the first frame: the setup
/// and settings start from it.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final playerStore = FilePlayerStore();
  await playerStore.load();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: RepositoryProvider<PlayerStore>.value(
        value: playerStore,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => StartupCubit(CityLoader())..load()),
            // Above the router, so every screen and new game sees them.
            BlocProvider(create: (_) => SetupCubit(playerStore)),
            BlocProvider(create: (_) => SettingsCubit(playerStore)),
            BlocProvider(create: (_) => StatsCubit(playerStore)),
          ],
          child: const CitiesApp(),
        ),
      ),
    ),
  );
}
