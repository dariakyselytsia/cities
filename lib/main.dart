import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'di/di.dart';
import 'presentation/bloc/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uk'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: BlocProvider(
        create: (_) => SettingsCubit(),
        child: const CitiesApp(),
      ),
    ),
  );
}

/// Root widget: wires localization, theme, and the go_router configuration.
class CitiesApp extends StatelessWidget {
  const CitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
