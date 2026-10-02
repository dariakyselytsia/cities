import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'features/startup/startup_gate.dart';

/// Root widget: localization, theme, the router, and the startup gate.
class CitiesApp extends StatefulWidget {
  const CitiesApp({super.key});

  @override
  State<CitiesApp> createState() => _CitiesAppState();
}

class _CitiesAppState extends State<CitiesApp> {
  /// Created once, so rebuilds (a language change) keep the navigation stack.
  final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: buildAppTheme(),
      routerConfig: _router,
      // The gate wraps the navigator: splash / error until the catalog is
      // loaded, then every route can read it.
      builder: (context, child) =>
          StartupGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
