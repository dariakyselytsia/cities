import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'data/city_loader.dart';
import 'features/startup/startup_cubit.dart';

/// Composition root. There is no DI container: dependencies are built here
/// and handed down explicitly (tech_design §2).
///
/// The city catalog loads in the background behind a splash
/// (`StartupGate`), so the first frame isn't held up by 1.9 MB of JSON.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: BlocProvider(
        create: (_) => StartupCubit(CityLoader())..load(),
        child: const CitiesApp(),
      ),
    ),
  );
}
