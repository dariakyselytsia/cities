import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';

/// Composition root. There is no DI container: dependencies (city catalog,
/// player store) are built here and handed down explicitly — see
/// `tech_design.md` §2.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const CitiesApp(),
    ),
  );
}
