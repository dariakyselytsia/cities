import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/startup/startup_gate.dart';

/// Root widget: localization, theme, and the startup gate. Routing
/// (`go_router`) arrives with the Home screen in T14.
class CitiesApp extends StatelessWidget {
  const CitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: buildAppTheme(),
      // The gate wraps the navigator: splash / error until the catalog is
      // loaded, then every route can read it.
      builder: (context, child) =>
          StartupGate(child: child ?? const SizedBox.shrink()),
      home: const HomeScreen(),
    );
  }
}
